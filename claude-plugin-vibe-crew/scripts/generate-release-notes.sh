#!/usr/bin/env bash
# scripts/generate-release-notes.sh
# Parses git log with conventional commits and generates release notes JSON.
# Called by /wrap and the Doc Generator agent.
# Usage: generate-release-notes.sh [since_tag] [output_file]
# Output: JSON release notes to stdout or output_file

set -euo pipefail

SINCE_TAG="${1:-}"
OUTPUT_FILE="${2:-}"

# --- Verify git repo ---
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  jq -n '{
    version: "unreleased",
    date: (now | strftime("%Y-%m-%d")),
    sections: { features: [], fixes: [], refactors: [], docs: [], other: [] },
    stats: { total_commits: 0, files_changed: 0, insertions: 0, deletions: 0 }
  }'
  exit 0
fi

# --- Determine range ---
if [[ -n "$SINCE_TAG" ]]; then
  # Verify the tag exists
  if ! git rev-parse "$SINCE_TAG" &>/dev/null; then
    echo "Error: Tag '$SINCE_TAG' not found." >&2
    exit 1
  fi
  RANGE="${SINCE_TAG}..HEAD"
else
  # Find last tag, or fall back to first commit
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  if [[ -n "$LAST_TAG" ]]; then
    RANGE="${LAST_TAG}..HEAD"
  else
    # All commits from the beginning
    RANGE=""
  fi
fi

# --- Detect version ---
if [[ -n "$SINCE_TAG" ]]; then
  # Try to detect next version from package.json
  VERSION=$(jq -r '.version // empty' package.json 2>/dev/null || echo "")
  if [[ -z "$VERSION" ]]; then
    VERSION="unreleased"
  fi
else
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
  VERSION=$(jq -r '.version // empty' package.json 2>/dev/null || echo "")
  if [[ -z "$VERSION" ]]; then
    if [[ -n "$LAST_TAG" ]]; then
      VERSION="$LAST_TAG"
    else
      VERSION="unreleased"
    fi
  fi
fi

TODAY=$(date +%Y-%m-%d)

# --- Parse commits ---
# Get one-line log with hash
if [[ -n "$RANGE" ]]; then
  GIT_LOG=$(git log "$RANGE" --oneline --no-merges 2>/dev/null || echo "")
else
  GIT_LOG=$(git log --oneline --no-merges 2>/dev/null || echo "")
fi

# Initialize JSON arrays for each section
FEATURES="[]"
FIXES="[]"
REFACTORS="[]"
DOCS="[]"
OTHER="[]"

# Parse each commit line
while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  # Extract hash (first word) and rest of message
  HASH=$(echo "$line" | awk '{print $1}')
  MESSAGE=$(echo "$line" | cut -d' ' -f2-)

  # Match conventional commit pattern: type(scope): description
  # Regex assigned to variable to avoid bash parsing issues with parentheses
  local_re='^(feat|fix|refactor|docs|chore|test|style|perf|build|ci|revert)(\(([^)]+)\))?:[[:space:]](.+)$'
  if [[ "$MESSAGE" =~ $local_re ]]; then
    TYPE="${BASH_REMATCH[1]}"
    SCOPE="${BASH_REMATCH[3]:-}"
    DESC="${BASH_REMATCH[4]}"

    COMMIT_JSON=$(jq -n \
      --arg hash "$HASH" \
      --arg scope "$SCOPE" \
      --arg message "$DESC" \
      '{hash: $hash, scope: $scope, message: $message}')

    case "$TYPE" in
      feat)
        FEATURES=$(echo "$FEATURES" | jq --argjson c "$COMMIT_JSON" '. + [$c]')
        ;;
      fix)
        FIXES=$(echo "$FIXES" | jq --argjson c "$COMMIT_JSON" '. + [$c]')
        ;;
      refactor)
        REFACTORS=$(echo "$REFACTORS" | jq --argjson c "$COMMIT_JSON" '. + [$c]')
        ;;
      docs)
        DOCS=$(echo "$DOCS" | jq --argjson c "$COMMIT_JSON" '. + [$c]')
        ;;
      *)
        OTHER=$(echo "$OTHER" | jq --argjson c "$COMMIT_JSON" '. + [$c]')
        ;;
    esac
  else
    # Non-conventional commit goes to "other"
    COMMIT_JSON=$(jq -n \
      --arg hash "$HASH" \
      --arg message "$MESSAGE" \
      '{hash: $hash, scope: "", message: $message}')
    OTHER=$(echo "$OTHER" | jq --argjson c "$COMMIT_JSON" '. + [$c]')
  fi
done <<< "$GIT_LOG"

# --- Gather stats ---
if [[ -n "$RANGE" ]]; then
  TOTAL_COMMITS=$(git rev-list --count "$RANGE" --no-merges 2>/dev/null || echo "0")
  DIFFSTAT=$(git diff --shortstat "$RANGE" 2>/dev/null || echo "")
else
  TOTAL_COMMITS=$(git rev-list --count HEAD --no-merges 2>/dev/null || echo "0")
  # For full history, diff from root
  FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD 2>/dev/null | head -1 || echo "")
  if [[ -n "$FIRST_COMMIT" ]]; then
    DIFFSTAT=$(git diff --shortstat "$FIRST_COMMIT" HEAD 2>/dev/null || echo "")
  else
    DIFFSTAT=""
  fi
fi

# Parse diffstat: " 23 files changed, 450 insertions(+), 120 deletions(-)"
FILES_CHANGED=0
INSERTIONS=0
DELETIONS=0

if [[ -n "$DIFFSTAT" ]]; then
  FILES_CHANGED=$(echo "$DIFFSTAT" | grep -oE '[0-9]+ files? changed' | grep -oE '[0-9]+' || echo "0")
  INSERTIONS=$(echo "$DIFFSTAT" | grep -oE '[0-9]+ insertions?' | grep -oE '[0-9]+' || echo "0")
  DELETIONS=$(echo "$DIFFSTAT" | grep -oE '[0-9]+ deletions?' | grep -oE '[0-9]+' || echo "0")
fi

# --- Build final JSON ---
RESULT=$(jq -n \
  --arg version "$VERSION" \
  --arg date "$TODAY" \
  --argjson features "$FEATURES" \
  --argjson fixes "$FIXES" \
  --argjson refactors "$REFACTORS" \
  --argjson docs "$DOCS" \
  --argjson other "$OTHER" \
  --argjson total_commits "$TOTAL_COMMITS" \
  --argjson files_changed "${FILES_CHANGED:-0}" \
  --argjson insertions "${INSERTIONS:-0}" \
  --argjson deletions "${DELETIONS:-0}" \
  '{
    version: $version,
    date: $date,
    sections: {
      features: $features,
      fixes: $fixes,
      refactors: $refactors,
      docs: $docs,
      other: $other
    },
    stats: {
      total_commits: $total_commits,
      files_changed: $files_changed,
      insertions: $insertions,
      deletions: $deletions
    }
  }')

# --- Output ---
if [[ -n "$OUTPUT_FILE" ]]; then
  # Ensure output directory exists
  mkdir -p "$(dirname "$OUTPUT_FILE")"
  echo "$RESULT" > "$OUTPUT_FILE"
else
  echo "$RESULT"
fi
