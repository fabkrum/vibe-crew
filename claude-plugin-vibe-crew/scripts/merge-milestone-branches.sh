#!/usr/bin/env bash
# scripts/merge-milestone-branches.sh
# Merges parallel milestone sub-branches back into the feature branch.
# Usage: merge-milestone-branches.sh <feature-branch> <milestone-branch-1> [milestone-branch-2] ...
# Output: JSON report of merge results
# Exit 0 on success (even partial), Exit 1 on fatal error

set -euo pipefail

FEATURE_BRANCH="${1:-}"
shift || true

if [[ -z "$FEATURE_BRANCH" ]]; then
  echo '{"error": "Usage: merge-milestone-branches.sh <feature-branch> <branch1> [branch2] ..."}' >&2
  exit 1
fi

MILESTONE_BRANCHES=("$@")

if [[ ${#MILESTONE_BRANCHES[@]} -eq 0 ]]; then
  echo '{"error": "No milestone branches specified"}' >&2
  exit 1
fi

# Ensure we're on the feature branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
if [[ "$CURRENT_BRANCH" != "$FEATURE_BRANCH" ]]; then
  git checkout "$FEATURE_BRANCH" 2>/dev/null || {
    echo "{\"error\": \"Cannot checkout $FEATURE_BRANCH\"}" >&2
    exit 1
  }
fi

RESULTS="[]"
CONFLICTS=0
MERGED=0

for branch in "${MILESTONE_BRANCHES[@]}"; do
  # Check branch exists
  if ! git rev-parse --verify "$branch" &>/dev/null; then
    RESULTS=$(echo "$RESULTS" | jq --arg b "$branch" '. + [{"branch": $b, "status": "not_found"}]')
    continue
  fi

  # Attempt merge
  MERGE_OUTPUT=""
  if MERGE_OUTPUT=$(git merge "$branch" --no-edit 2>&1); then
    MERGED=$((MERGED + 1))
    RESULTS=$(echo "$RESULTS" | jq --arg b "$branch" '. + [{"branch": $b, "status": "merged"}]')
  else
    # Merge conflict
    CONFLICTS=$((CONFLICTS + 1))
    # Get conflicting files
    CONFLICT_FILES=$(git diff --name-only --diff-filter=U 2>/dev/null | head -10 | jq -R . | jq -s .)
    # Abort the merge
    git merge --abort 2>/dev/null || true
    RESULTS=$(echo "$RESULTS" | jq --arg b "$branch" --argjson files "$CONFLICT_FILES" \
      '. + [{"branch": $b, "status": "conflict", "conflicting_files": $files}]')
  fi
done

jq -n \
  --arg feature_branch "$FEATURE_BRANCH" \
  --argjson merged "$MERGED" \
  --argjson conflicts "$CONFLICTS" \
  --argjson results "$RESULTS" \
  '{feature_branch: $feature_branch, merged: $merged, conflicts: $conflicts, results: $results}'

exit 0
