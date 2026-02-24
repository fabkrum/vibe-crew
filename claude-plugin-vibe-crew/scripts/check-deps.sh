#!/usr/bin/env bash
# scripts/check-deps.sh
# Validate all VibeCrew dependencies
# Returns JSON with status of each dependency
# Exit 0: all required dependencies met
# Exit 1: required dependency missing

set -euo pipefail

PASS=0; FAIL=0; WARN=0; RESULTS=()

check_dep() {
  local name="$1" command="$2" min_version="$3" install_hint="$4" required="$5"
  local version_flag="${6:---version}"

  if ! command -v "$command" &> /dev/null; then
    RESULTS+=("{\"name\":\"$name\",\"status\":\"missing\",\"required\":\"$min_version\",\"install\":\"$install_hint\",\"level\":\"$required\"}")
    [ "$required" = "required" ] && ((FAIL++)) || ((WARN++))
    return
  fi

  local version
  version=$("$command" $version_flag 2>&1 | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  RESULTS+=("{\"name\":\"$name\",\"status\":\"ok\",\"found\":\"${version:-unknown}\",\"required\":\"$min_version\",\"level\":\"$required\"}")
  ((PASS++))
}

# Required dependencies
check_dep "Claude Code" "claude" "2.0.0" "npm install -g @anthropic-ai/claude-code" "required"
check_dep "Git" "git" "2.30.0" "xcode-select --install" "required"
check_dep "GitHub CLI" "gh" "2.0.0" "brew install gh" "required"
check_dep "Node.js" "node" "18.0.0" "brew install node" "required" "--version"
check_dep "jq" "jq" "1.6" "brew install jq" "required"

# Recommended dependencies
check_dep "terminal-notifier" "terminal-notifier" "2.0.0" "brew install terminal-notifier" "recommended"

# Check gh auth status
GH_AUTH="ok"
if command -v gh &>/dev/null && ! gh auth status &>/dev/null 2>&1; then
  GH_AUTH="not_authenticated"
  ((FAIL++))
fi

# Build output JSON
DEPS_JSON=$(printf '%s,' "${RESULTS[@]}" | sed 's/,$//')
jq -n --argjson deps "[$DEPS_JSON]" --arg gh_auth "$GH_AUTH" \
  --argjson pass "$PASS" --argjson fail "$FAIL" --argjson warn "$WARN" \
  '{dependencies:$deps, gh_authenticated:$gh_auth, summary:{passed:$pass, required_failed:$fail, recommended_missing:$warn, ready:($fail==0)}}'

[ "$FAIL" -gt 0 ] && exit 1 || exit 0
