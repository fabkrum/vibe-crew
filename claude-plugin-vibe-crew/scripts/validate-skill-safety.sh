#!/usr/bin/env bash
# scripts/validate-skill-safety.sh
# Quality gate for discovered skills. 5 safety checks.
# Usage:   validate-skill-safety.sh <github-url-or-local-path>
# Exit 0 if safe, Exit 1 if rejected.
# Output:  JSON with pass/fail per check and overall verdict.

set -euo pipefail

SOURCE="${1:-}"

if [[ -z "$SOURCE" ]]; then
  echo "Usage: validate-skill-safety.sh <github-url-or-local-path>" >&2
  exit 1
fi

# --- Detect plugin root ---
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

REGISTRY_FILE="$PLUGIN_ROOT/templates/companion-skills.json"

# --- Initialize result ---
VERDICT="pass"
WARNINGS="[]"
DANGEROUS_PATTERNS="[]"
TRUSTED_AUTHOR=false
REPO_STARS=0
REPO_LICENSE="unknown"
SKILL_SIZE_KB=0
HAS_SCRIPTS=false
SKILL_NAME=""

# --- Determine source type and extract info ---
IS_LOCAL=false
REPO_OWNER=""
REPO_NAME=""
TEMP_DIR=""

if [[ -d "$SOURCE" ]]; then
  IS_LOCAL=true
  SKILL_NAME=$(basename "$SOURCE")
elif [[ "$SOURCE" =~ ^https://github.com/([^/]+)/([^/]+) ]]; then
  REPO_OWNER="${BASH_REMATCH[1]}"
  REPO_NAME="${BASH_REMATCH[2]}"
  SKILL_NAME="$REPO_NAME"
elif [[ "$SOURCE" =~ ^([^/]+)/([^/]+)$ ]]; then
  REPO_OWNER="${BASH_REMATCH[1]}"
  REPO_NAME="${BASH_REMATCH[2]}"
  SKILL_NAME="${BASH_REMATCH[2]}"
  SOURCE="https://github.com/${SOURCE}"
fi

# --- Gate 1: Trusted author check ---
if [[ -n "$REPO_OWNER" ]] && [[ -f "$REGISTRY_FILE" ]]; then
  IS_TRUSTED=$(jq -r --arg owner "$REPO_OWNER" \
    '.trusted_authors | map(ascii_downcase) | index($owner | ascii_downcase) != null' \
    "$REGISTRY_FILE" 2>/dev/null || echo "false")

  if [[ "$IS_TRUSTED" == "true" ]]; then
    TRUSTED_AUTHOR=true
  else
    WARNINGS=$(echo "$WARNINGS" | jq --arg w "Author '$REPO_OWNER' is not in the trusted authors list" '. + [$w]')
  fi
elif [[ "$IS_LOCAL" == "true" ]]; then
  TRUSTED_AUTHOR=true  # Local paths are trusted by default
fi

# --- Gate 2: Repo health (GitHub only) ---
if [[ -n "$REPO_OWNER" ]] && [[ -n "$REPO_NAME" ]]; then
  REPO_INFO=$(curl -sf -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}" 2>/dev/null || echo "")

  if [[ -n "$REPO_INFO" ]]; then
    REPO_STARS=$(echo "$REPO_INFO" | jq -r '.stargazers_count // 0')
    REPO_LICENSE=$(echo "$REPO_INFO" | jq -r '.license.spdx_id // "none"')
    PUSHED_AT=$(echo "$REPO_INFO" | jq -r '.pushed_at // ""')

    # Check star count
    if [[ "$REPO_STARS" -lt 20 ]]; then
      VERDICT="fail"
      WARNINGS=$(echo "$WARNINGS" | jq --arg w "Repository has fewer than 20 stars ($REPO_STARS)" '. + [$w]')
    fi

    # Check license
    if [[ "$REPO_LICENSE" == "none" ]] || [[ "$REPO_LICENSE" == "null" ]]; then
      VERDICT="fail"
      WARNINGS=$(echo "$WARNINGS" | jq '. + ["Repository has no license"]')
    fi

    # Check last commit (6 months staleness)
    if [[ -n "$PUSHED_AT" ]]; then
      PUSHED_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$PUSHED_AT" "+%s" 2>/dev/null || \
                     date -d "$PUSHED_AT" "+%s" 2>/dev/null || echo "0")
      NOW_EPOCH=$(date "+%s")
      SIX_MONTHS=$((180 * 24 * 60 * 60))

      if [[ "$PUSHED_EPOCH" -gt 0 ]] && [[ $((NOW_EPOCH - PUSHED_EPOCH)) -gt $SIX_MONTHS ]]; then
        VERDICT="fail"
        WARNINGS=$(echo "$WARNINGS" | jq '. + ["No commits in the last 6 months"]')
      fi
    fi
  else
    WARNINGS=$(echo "$WARNINGS" | jq '. + ["Could not fetch repository information from GitHub"]')
  fi
fi

# --- Gate 3 & 4: SKILL.md scan and dangerous pattern detection ---
SKILL_CONTENT=""

if [[ "$IS_LOCAL" == "true" ]]; then
  SKILL_FILE="$SOURCE/SKILL.md"
  if [[ -f "$SKILL_FILE" ]]; then
    SKILL_CONTENT=$(cat "$SKILL_FILE")
    SKILL_SIZE_KB=$(echo "scale=1; $(wc -c < "$SKILL_FILE") / 1024" | bc 2>/dev/null || echo "0")
  fi
elif [[ -n "$REPO_OWNER" ]] && [[ -n "$REPO_NAME" ]]; then
  # Try to fetch SKILL.md from repo root
  SKILL_CONTENT=$(curl -sf \
    "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/SKILL.md" 2>/dev/null || \
    curl -sf \
    "https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/master/SKILL.md" 2>/dev/null || echo "")

  if [[ -n "$SKILL_CONTENT" ]]; then
    SKILL_SIZE_KB=$(echo "scale=1; ${#SKILL_CONTENT} / 1024" | bc 2>/dev/null || echo "0")
  fi
fi

# Gate 3: Size check
if [[ -n "$SKILL_CONTENT" ]]; then
  SIZE_BYTES=${#SKILL_CONTENT}
  if [[ "$SIZE_BYTES" -gt 15360 ]]; then  # 15KB
    VERDICT="fail"
    WARNINGS=$(echo "$WARNINGS" | jq --arg s "$SKILL_SIZE_KB" '. + ["SKILL.md is too large (" + $s + "KB, max 15KB)"]')
  fi
fi

# Gate 4: Dangerous patterns
DANGER_PATTERNS=(
  'rm -rf'
  'curl.*\|.*sh'
  'eval '
  'eval\('
  'exec\('
  'process\.env'
  'base64.*decode'
  'base64 -d'
  'fetch\('
)

if [[ -n "$SKILL_CONTENT" ]]; then
  for pattern in "${DANGER_PATTERNS[@]}"; do
    if echo "$SKILL_CONTENT" | grep -qiE "$pattern"; then
      VERDICT="fail"
      DANGEROUS_PATTERNS=$(echo "$DANGEROUS_PATTERNS" | jq --arg p "$pattern" '. + [$p]')
    fi
  done
fi

# --- Gate 5: Script audit ---
if [[ "$IS_LOCAL" == "true" ]] && [[ -d "$SOURCE/scripts" ]]; then
  HAS_SCRIPTS=true

  for script_file in "$SOURCE/scripts/"*; do
    [[ -f "$script_file" ]] || continue

    SCRIPT_CONTENT=$(cat "$script_file")

    # Check for network calls
    if echo "$SCRIPT_CONTENT" | grep -qiE '(curl|wget|fetch|http:|https:)'; then
      # Allow GitHub URLs only
      NON_GITHUB=$(echo "$SCRIPT_CONTENT" | grep -iE '(curl|wget|fetch)' | grep -viE 'github\.com' || true)
      if [[ -n "$NON_GITHUB" ]]; then
        VERDICT="fail"
        DANGEROUS_PATTERNS=$(echo "$DANGEROUS_PATTERNS" | jq \
          --arg p "Script $(basename "$script_file") makes non-GitHub network calls" '. + [$p]')
      fi
    fi

    # Check for file deletion outside project
    if echo "$SCRIPT_CONTENT" | grep -qE 'rm\s+(-rf?|--recursive)\s+(/|~|\$HOME)'; then
      VERDICT="fail"
      DANGEROUS_PATTERNS=$(echo "$DANGEROUS_PATTERNS" | jq \
        --arg p "Script $(basename "$script_file") deletes files outside project" '. + [$p]')
    fi

    # Check for env var exfiltration
    if echo "$SCRIPT_CONTENT" | grep -qiE '(curl|wget|fetch).*\$(.*_KEY|.*_SECRET|.*_TOKEN)'; then
      VERDICT="fail"
      DANGEROUS_PATTERNS=$(echo "$DANGEROUS_PATTERNS" | jq \
        --arg p "Script $(basename "$script_file") may exfiltrate environment variables" '. + [$p]')
    fi
  done
elif [[ -n "$REPO_OWNER" ]] && [[ -n "$REPO_NAME" ]]; then
  # Check if repo has a scripts directory
  SCRIPTS_CHECK=$(curl -sf -o /dev/null -w "%{http_code}" \
    "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contents/scripts" 2>/dev/null || echo "404")
  if [[ "$SCRIPTS_CHECK" == "200" ]]; then
    HAS_SCRIPTS=true
    WARNINGS=$(echo "$WARNINGS" | jq '. + ["Skill has scripts/ directory — review manually before installing"]')
  fi
fi

# --- Output result ---
jq -n \
  --arg skill "$SKILL_NAME" \
  --arg source "$SOURCE" \
  --arg verdict "$VERDICT" \
  --argjson trusted_author "$TRUSTED_AUTHOR" \
  --argjson repo_stars "$REPO_STARS" \
  --arg repo_license "$REPO_LICENSE" \
  --arg skill_size_kb "$SKILL_SIZE_KB" \
  --argjson dangerous_patterns "$DANGEROUS_PATTERNS" \
  --argjson has_scripts "$HAS_SCRIPTS" \
  --argjson warnings "$WARNINGS" \
  '{
    skill: $skill,
    source: $source,
    verdict: $verdict,
    trusted_author: $trusted_author,
    repo_stars: $repo_stars,
    repo_license: $repo_license,
    skill_size_kb: ($skill_size_kb | tonumber),
    dangerous_patterns: $dangerous_patterns,
    has_scripts: $has_scripts,
    warnings: $warnings
  }'

if [[ "$VERDICT" == "fail" ]]; then
  exit 1
fi

exit 0
