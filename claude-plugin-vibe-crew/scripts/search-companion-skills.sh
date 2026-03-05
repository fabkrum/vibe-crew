#!/usr/bin/env bash
# scripts/search-companion-skills.sh
# Tiered skill search: Anthropic → official vendor → skills.sh.
# Stops at the first priority level that returns results.
# Usage:   search-companion-skills.sh <keyword> [--limit 5]
# Output:  JSON array of { name, author, source, install_command, description, priority }

set -euo pipefail

KEYWORD="${1:-}"
LIMIT=5

# Parse arguments
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit) LIMIT="${2:-5}"; shift 2 ;;
    *)       shift ;;
  esac
done

if [[ -z "$KEYWORD" ]]; then
  echo "Usage: search-companion-skills.sh <keyword> [--limit N]" >&2
  exit 1
fi

KEYWORD_LOWER=$(echo "$KEYWORD" | tr '[:upper:]' '[:lower:]')
RESULTS="[]"

# --- Helper: check GitHub repo for SKILL.md files ---
check_github_repo() {
  local repo="$1"
  local priority="$2"

  # Use GitHub API to check for skill folders
  local api_result
  api_result=$(curl -sf -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${repo}/contents" 2>/dev/null || echo "")

  if [[ -z "$api_result" ]]; then
    return 1
  fi

  # Look for directories that might be skills (contain SKILL.md)
  local dirs
  dirs=$(echo "$api_result" | jq -r '.[] | select(.type == "dir") | .name' 2>/dev/null || echo "")

  if [[ -z "$dirs" ]]; then
    return 1
  fi

  local found=false
  while IFS= read -r dir; do
    [[ -z "$dir" ]] && continue

    # Check if directory name matches keyword or contains SKILL.md
    local dir_lower
    dir_lower=$(echo "$dir" | tr '[:upper:]' '[:lower:]')

    if [[ "$dir_lower" == *"$KEYWORD_LOWER"* ]] || [[ "$KEYWORD_LOWER" == *"$dir_lower"* ]]; then
      # Verify SKILL.md exists in this directory
      local skill_check
      skill_check=$(curl -sf -o /dev/null -w "%{http_code}" \
        "https://api.github.com/repos/${repo}/contents/${dir}/SKILL.md" 2>/dev/null || echo "404")

      if [[ "$skill_check" == "200" ]]; then
        local author
        author=$(echo "$repo" | cut -d'/' -f1)
        RESULTS=$(echo "$RESULTS" | jq \
          --arg name "$dir" \
          --arg author "$author" \
          --arg source "https://github.com/${repo}" \
          --arg install "npx skills add ${repo} --skill ${dir}" \
          --arg desc "Skill '${dir}' from ${repo}" \
          --arg priority "$priority" \
          '. + [{name: $name, author: $author, source: $source, install_command: $install, description: $desc, priority: $priority}]')
        found=true
      fi
    fi

    # Respect limit
    local count
    count=$(echo "$RESULTS" | jq 'length')
    if [[ "$count" -ge "$LIMIT" ]]; then
      break
    fi
  done <<< "$dirs"

  $found
}

# --- Priority 1: Anthropic skills ---
if check_github_repo "anthropics/skills" "anthropic" 2>/dev/null; then
  echo "$RESULTS" | jq ".[:$LIMIT]"
  exit 0
fi

# --- Priority 2: Official vendor repos ---
# Try common repo patterns for the technology vendor
VENDOR_REPOS=(
  "${KEYWORD_LOWER}/agent-skills"
  "${KEYWORD_LOWER}/skills"
  "${KEYWORD_LOWER}-labs/agent-skills"
)

for repo in "${VENDOR_REPOS[@]}"; do
  if check_github_repo "$repo" "vendor" 2>/dev/null; then
    echo "$RESULTS" | jq ".[:$LIMIT]"
    exit 0
  fi
done

# --- Priority 3: skills.sh / broader GitHub search ---
# Try npx skills find if available
if command -v npx &>/dev/null; then
  SKILLS_OUTPUT=$(npx skills find "$KEYWORD" --json 2>/dev/null || echo "")
  if [[ -n "$SKILLS_OUTPUT" ]] && echo "$SKILLS_OUTPUT" | jq empty 2>/dev/null; then
    PARSED=$(echo "$SKILLS_OUTPUT" | jq --arg kw "$KEYWORD_LOWER" --argjson lim "$LIMIT" \
      '[.[] | {
        name: .name,
        author: (.author // .owner // "unknown"),
        source: (.url // .source // ""),
        install_command: (.install // ("npx skills add " + (.source // ""))),
        description: (.description // ""),
        priority: "community"
      }][:$lim]' 2>/dev/null || echo "[]")

    if [[ "$PARSED" != "[]" ]]; then
      echo "$PARSED"
      exit 0
    fi
  fi
fi

# Fallback: GitHub search for repos with SKILL.md matching keyword
SEARCH_RESULT=$(curl -sf -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/search/repositories?q=${KEYWORD_LOWER}+agent-skills+in:name&sort=stars&per_page=${LIMIT}" 2>/dev/null || echo "")

if [[ -n "$SEARCH_RESULT" ]]; then
  PARSED=$(echo "$SEARCH_RESULT" | jq --argjson lim "$LIMIT" \
    '[.items // [] | .[] | select(.stargazers_count >= 50) | {
      name: .name,
      author: .owner.login,
      source: .html_url,
      install_command: ("npx skills add " + .full_name),
      description: (.description // ""),
      priority: "community"
    }][:$lim]' 2>/dev/null || echo "[]")

  if [[ "$PARSED" != "[]" ]] && [[ -n "$PARSED" ]]; then
    echo "$PARSED"
    exit 0
  fi
fi

# No results found
echo "[]"
exit 0
