#!/usr/bin/env bash
# scripts/recommend-companion-skills.sh
# Two-tier companion skill discovery: registry match + skills.sh search.
# Usage:
#   recommend-companion-skills.sh                       # Auto-detect TDR
#   recommend-companion-skills.sh <path-to-tdr>         # Explicit TDR path
#   recommend-companion-skills.sh --detect-only          # Just detect installed
#   recommend-companion-skills.sh --registry-only        # Skip skills.sh search
# Output: JSON with installed, registry_recommended, discovered, rejected, unmatched_technologies
# Called by Workflow Orchestrator after TDR approval and by /setup for detection.

set -euo pipefail

# --- Detect plugin root ---
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

REGISTRY_FILE="$PLUGIN_ROOT/templates/companion-skills.json"
SEARCH_SCRIPT="$PLUGIN_ROOT/scripts/search-companion-skills.sh"
VALIDATE_SCRIPT="$PLUGIN_ROOT/scripts/validate-skill-safety.sh"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

DETECT_ONLY=false
REGISTRY_ONLY=false
TDR_FILE=""

# --- Parse arguments ---
for arg in "$@"; do
  case "$arg" in
    --detect-only)  DETECT_ONLY=true ;;
    --registry-only) REGISTRY_ONLY=true ;;
    *)              TDR_FILE="$arg" ;;
  esac
done

# --- Detect installed skills ---
detect_installed() {
  local installed="[]"
  local skill_dirs=(
    "$HOME/.claude/skills"
    "$PROJECT_ROOT/.claude/skills"
  )

  for dir in "${skill_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
      for skill_path in "$dir"/*/; do
        if [[ -d "$skill_path" ]]; then
          local name
          name=$(basename "$skill_path")
          installed=$(echo "$installed" | jq --arg n "$name" --arg p "$skill_path" \
            '. + [{"name": $n, "path": $p}]')
        fi
      done
    fi
  done

  echo "$installed"
}

INSTALLED=$(detect_installed)

# --- Detect-only mode ---
if [[ "$DETECT_ONLY" == "true" ]]; then
  jq -n --argjson installed "$INSTALLED" \
    '{ installed: $installed, registry_recommended: [], discovered: [], rejected: [], unmatched_technologies: [] }'
  exit 0
fi

# --- Find TDR file ---
if [[ -z "$TDR_FILE" ]]; then
  for candidate in \
    "$PROJECT_ROOT/docs/TDR"*.md \
    "$PROJECT_ROOT/docs/tdr"*.md \
    "$PROJECT_ROOT/TDR"*.md \
    "$PROJECT_ROOT/tdr"*.md; do
    if [[ -f "$candidate" ]]; then
      TDR_FILE="$candidate"
      break
    fi
  done
fi

if [[ -z "$TDR_FILE" ]] || [[ ! -f "$TDR_FILE" ]]; then
  echo "ERROR: No TDR file found. Provide a path or ensure a TDR-*.md exists in docs/." >&2
  exit 1
fi

# --- Read TDR content (case-insensitive) ---
TDR_CONTENT=$(tr '[:upper:]' '[:lower:]' < "$TDR_FILE")

# --- Check registry ---
if [[ ! -f "$REGISTRY_FILE" ]]; then
  echo "ERROR: Registry not found at $REGISTRY_FILE" >&2
  exit 1
fi

REGISTRY_RECOMMENDED="[]"
MATCHED_TECHNOLOGIES="[]"
ALL_TDR_TECHNOLOGIES="[]"

# Extract technology keywords from TDR (lines containing technology names)
SKILL_KEYS=$(jq -r '.skills | keys[]' "$REGISTRY_FILE")

while IFS= read -r key; do
  PATTERNS=$(jq -r --arg k "$key" '.skills[$k].tdr_patterns[]' "$REGISTRY_FILE")
  MATCHED=false

  while IFS= read -r pattern; do
    if echo "$TDR_CONTENT" | grep -q "$pattern"; then
      MATCHED=true
      # Track matched technology
      MATCHED_TECHNOLOGIES=$(echo "$MATCHED_TECHNOLOGIES" | jq --arg p "$pattern" \
        'if (. | index($p)) then . else . + [$p] end')
      break
    fi
  done <<< "$PATTERNS"

  if [[ "$MATCHED" != "true" ]]; then
    continue
  fi

  # Check if already installed
  SKILL_INSTALLED=$(echo "$INSTALLED" | jq --arg k "$key" '[.[] | select(.name == $k)] | length > 0')
  if [[ "$SKILL_INSTALLED" == "true" ]]; then
    continue
  fi

  # Add to recommendations
  NAME=$(jq -r --arg k "$key" '.skills[$k].name' "$REGISTRY_FILE")
  DESC=$(jq -r --arg k "$key" '.skills[$k].description' "$REGISTRY_FILE")
  AUTHOR=$(jq -r --arg k "$key" '.skills[$k].author' "$REGISTRY_FILE")
  INSTALL_CMD=$(jq -r --arg k "$key" '.skills[$k].install' "$REGISTRY_FILE")
  SOURCE=$(jq -r --arg k "$key" '.skills[$k].source' "$REGISTRY_FILE")
  CATEGORY=$(jq -r --arg k "$key" '.skills[$k].category' "$REGISTRY_FILE")
  ADAPTATION=$(jq -r --arg k "$key" '.skills[$k].agent_adaptation // empty' "$REGISTRY_FILE")

  REGISTRY_RECOMMENDED=$(echo "$REGISTRY_RECOMMENDED" | jq \
    --arg key "$key" \
    --arg name "$NAME" \
    --arg desc "$DESC" \
    --arg author "$AUTHOR" \
    --arg install "$INSTALL_CMD" \
    --arg source "$SOURCE" \
    --arg category "$CATEGORY" \
    --arg adaptation "$ADAPTATION" \
    '. + [{
      key: $key,
      name: $name,
      description: $desc,
      author: $author,
      install: $install,
      source: $source,
      category: $category,
      agent_adaptation: (if $adaptation == "" then null else ($adaptation | fromjson? // $adaptation) end)
    }]')
done <<< "$SKILL_KEYS"

# --- Identify unmatched technologies ---
# Extract common technology keywords from TDR that don't match any registry pattern
UNMATCHED="[]"
DISCOVERED="[]"
REJECTED="[]"

# Common technology patterns to look for in TDR
TECH_KEYWORDS=("prisma" "drizzle" "mongodb" "redis" "firebase" "clerk" "auth0" "netlify" "railway" "docker" "kubernetes" "terraform" "shopify")

for tech in "${TECH_KEYWORDS[@]}"; do
  if echo "$TDR_CONTENT" | grep -q "$tech"; then
    # Check if this tech was already matched by registry
    ALREADY_MATCHED=$(echo "$MATCHED_TECHNOLOGIES" | jq --arg t "$tech" '[.[] | select(. == $t)] | length > 0')
    if [[ "$ALREADY_MATCHED" != "true" ]]; then
      UNMATCHED=$(echo "$UNMATCHED" | jq --arg t "$tech" '. + [$t]')
    fi
  fi
done

# --- Tier 2: skills.sh search for unmatched technologies ---
if [[ "$REGISTRY_ONLY" != "true" ]] && [[ $(echo "$UNMATCHED" | jq 'length') -gt 0 ]]; then
  UNMATCHED_LIST=$(echo "$UNMATCHED" | jq -r '.[]')

  while IFS= read -r tech; do
    [[ -z "$tech" ]] && continue

    # Search for skills matching this technology
    if [[ -x "$SEARCH_SCRIPT" ]]; then
      SEARCH_RESULTS=$(bash "$SEARCH_SCRIPT" "$tech" --limit 3 2>/dev/null || echo "[]")

      if [[ "$SEARCH_RESULTS" != "[]" ]] && [[ -n "$SEARCH_RESULTS" ]]; then
        # Validate each discovered skill
        while IFS= read -r skill_json; do
          [[ -z "$skill_json" ]] && continue
          SKILL_SOURCE=$(echo "$skill_json" | jq -r '.source // empty')

          if [[ -n "$SKILL_SOURCE" ]] && [[ -x "$VALIDATE_SCRIPT" ]]; then
            VALIDATION=$(bash "$VALIDATE_SCRIPT" "$SKILL_SOURCE" 2>/dev/null || echo '{"verdict":"fail"}')
            VERDICT=$(echo "$VALIDATION" | jq -r '.verdict // "fail"')

            if [[ "$VERDICT" == "pass" ]]; then
              DISCOVERED=$(echo "$DISCOVERED" | jq --argjson s "$skill_json" --argjson v "$VALIDATION" \
                '. + [$s + {validation: $v}]')
            else
              REJECTED=$(echo "$REJECTED" | jq --argjson s "$skill_json" --argjson v "$VALIDATION" \
                '. + [$s + {validation: $v}]')
            fi
          fi
        done < <(echo "$SEARCH_RESULTS" | jq -c '.[]')
      fi
    fi
  done <<< "$UNMATCHED_LIST"
fi

# --- Output JSON report ---
jq -n \
  --argjson installed "$INSTALLED" \
  --argjson registry_recommended "$REGISTRY_RECOMMENDED" \
  --argjson discovered "$DISCOVERED" \
  --argjson rejected "$REJECTED" \
  --argjson unmatched "$UNMATCHED" \
  '{
    installed: $installed,
    registry_recommended: $registry_recommended,
    discovered: $discovered,
    rejected: $rejected,
    unmatched_technologies: $unmatched
  }'

exit 0
