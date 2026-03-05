#!/usr/bin/env bash
# scripts/detect-fix-commits.sh
# Scans recent git log for fix: conventional commits that lack accompanying test changes.
# Used by /wrap to trigger regression test skeleton generation.
# Usage: detect-fix-commits.sh [since-ref]
#   since-ref: git ref to start from (default: searches last 50 commits)
# Output: JSON array of fix commits needing regression tests
# Exit 0 always

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SINCE_REF="${1:-}"

# --- Determine git log range ---
GIT_LOG_ARGS=("--format=%H %s")
if [[ -n "$SINCE_REF" ]]; then
  GIT_LOG_ARGS+=("${SINCE_REF}..HEAD")
else
  GIT_LOG_ARGS+=("-n" "50")
fi

# --- Scan for fix: commits ---
FIX_COMMITS="[]"

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  HASH="${line%% *}"
  MESSAGE="${line#* }"

  # Match fix: or fix(scope): pattern
  if ! echo "$MESSAGE" | grep -qE '^fix(\([^)]+\))?:'; then
    continue
  fi

  # Parse type, scope, description
  TYPE="fix"
  SCOPE=""
  DESCRIPTION=""

  if echo "$MESSAGE" | grep -qE '^fix\(([^)]+)\):'; then
    SCOPE=$(echo "$MESSAGE" | sed -E 's/^fix\(([^)]+)\):.*/\1/')
    DESCRIPTION=$(echo "$MESSAGE" | sed -E 's/^fix\([^)]+\):[[:space:]]*//')
  else
    DESCRIPTION=$(echo "$MESSAGE" | sed -E 's/^fix:[[:space:]]*//')
  fi

  # Check if this commit also modified test files
  HAS_TEST_CHANGES=false
  TEST_FILES_IN_COMMIT=$(git -C "$PROJECT_ROOT" diff-tree --root --no-commit-id --name-only -r "$HASH" 2>/dev/null | \
    grep -E '\.(test|spec)\.(ts|tsx|js|jsx)$|__tests__/|\.bats$' || true)
  if [[ -n "$TEST_FILES_IN_COMMIT" ]]; then
    HAS_TEST_CHANGES=true
  fi

  # Get changed files
  FILES_CHANGED=$(git -C "$PROJECT_ROOT" diff-tree --root --no-commit-id --name-only -r "$HASH" 2>/dev/null | jq -R -s 'split("\n") | map(select(. != ""))' || echo "[]")

  # Parse issue number from message (fixes #N, closes #N, resolves #N)
  ISSUE_NUMBER="null"
  if echo "$MESSAGE" | grep -qEi '(fix(es)?|clos(es|ing)?|resolv(es|ing)?)\s+#[0-9]+'; then
    ISSUE_NUMBER=$(echo "$MESSAGE" | grep -oEi '#[0-9]+' | head -1 | tr -d '#')
  fi

  # Skip commits that already have test changes
  if [[ "$HAS_TEST_CHANGES" == "true" ]]; then
    continue
  fi

  # Add to results
  FIX_COMMITS=$(echo "$FIX_COMMITS" | jq \
    --arg hash "$HASH" \
    --arg type "$TYPE" \
    --arg scope "$SCOPE" \
    --arg desc "$DESCRIPTION" \
    --argjson issue "${ISSUE_NUMBER:-null}" \
    --argjson files "$FILES_CHANGED" \
    --argjson has_tests "$HAS_TEST_CHANGES" \
    '. + [{
      hash: $hash,
      type: $type,
      scope: $scope,
      description: $desc,
      issue_number: $issue,
      files_changed: $files,
      has_test_changes: $has_tests
    }]')

done < <(git -C "$PROJECT_ROOT" log "${GIT_LOG_ARGS[@]}" 2>/dev/null || true)

echo "$FIX_COMMITS"
exit 0
