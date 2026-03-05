#!/usr/bin/env bash
# scripts/check-plan-staleness.sh
# Compares plan-referenced files against plan_commit_sha to detect codebase drift.
# Usage: check-plan-staleness.sh <plan-file-path> <plan-commit-sha>
# Always exits 0 (informational). Outputs JSON staleness report.

set -euo pipefail

PLAN_FILE="${1:-}"
PLAN_SHA="${2:-}"

# --- Helpers ---

json_error() {
  local msg="$1"
  cat <<EOF
{"stale":false,"error":"$msg"}
EOF
  exit 0
}

# --- Validation ---

if [[ -z "$PLAN_FILE" || -z "$PLAN_SHA" ]]; then
  json_error "Usage: check-plan-staleness.sh <plan-file> <plan-commit-sha>"
fi

if [[ ! -f "$PLAN_FILE" ]]; then
  json_error "Plan file not found: $PLAN_FILE"
fi

# Validate SHA is a valid git object
if ! git rev-parse --verify "$PLAN_SHA" &>/dev/null; then
  json_error "Invalid git SHA: $PLAN_SHA"
fi

CURRENT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "")
if [[ -z "$CURRENT_SHA" ]]; then
  json_error "Not in a git repository"
fi

# --- Extract file paths from plan ---

declare -a PLAN_FILES=()

# Method 1: Structured task format (### Task N: blocks → **Files**: lines)
while IFS= read -r line; do
  if [[ "$line" =~ ^\-\ \*\*Files\*\*:\ (.+)$ ]]; then
    files_line="${BASH_REMATCH[1]}"
    # Extract backtick-quoted paths
    while [[ "$files_line" =~ \`([^\`]+)\` ]]; do
      PLAN_FILES+=("${BASH_REMATCH[1]}")
      files_line="${files_line#*\`${BASH_REMATCH[1]}\`}"
    done
  fi
done < "$PLAN_FILE"

# Method 2: Legacy format — ## Files to Create / ## Files to Modify tables
in_files_table=false
while IFS= read -r line; do
  # Detect table headers
  if [[ "$line" =~ ^##\ Files\ to\ (Create|Modify) ]]; then
    in_files_table=true
    continue
  fi
  # End table on next heading or empty line after table
  if $in_files_table; then
    if [[ "$line" =~ ^## ]] && [[ ! "$line" =~ ^##\ Files\ to ]]; then
      in_files_table=false
      continue
    fi
    # Skip table header rows (| File | Purpose | etc.)
    if [[ "$line" =~ ^\|.*\-\-\- ]]; then
      continue
    fi
    # Extract backtick-quoted paths from table rows
    if [[ "$line" =~ ^\| ]]; then
      while [[ "$line" =~ \`([^\`]+)\` ]]; do
        PLAN_FILES+=("${BASH_REMATCH[1]}")
        line="${line#*\`${BASH_REMATCH[1]}\`}"
      done
    fi
  fi
done < "$PLAN_FILE"

# Method 3: Inline backtick-quoted paths that look like file paths (fallback)
# Only grab paths with extensions to avoid false positives
while IFS= read -r line; do
  # Skip lines already handled by structured task format
  [[ "$line" =~ ^\-\ \*\*Files\*\*: ]] && continue
  # Match backtick-quoted strings that look like file paths
  remaining="$line"
  while [[ "$remaining" =~ \`([a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+)\` ]]; do
    candidate="${BASH_REMATCH[1]}"
    # Only add if it has a directory separator (looks like a real path)
    if [[ "$candidate" == */* ]]; then
      PLAN_FILES+=("$candidate")
    fi
    remaining="${remaining#*\`$candidate\`}"
  done
done < "$PLAN_FILE"

# Deduplicate plan files (bash 3 compatible — no associative arrays)
declare -a UNIQUE_PLAN_FILES=()
for f in "${PLAN_FILES[@]}"; do
  already_seen=false
  for existing in "${UNIQUE_PLAN_FILES[@]+"${UNIQUE_PLAN_FILES[@]}"}"; do
    if [[ "$f" == "$existing" ]]; then
      already_seen=true
      break
    fi
  done
  if ! $already_seen; then
    UNIQUE_PLAN_FILES+=("$f")
  fi
done

# --- If no plan files found, report not stale ---

if [[ ${#UNIQUE_PLAN_FILES[@]} -eq 0 ]]; then
  cat <<EOF
{"stale":false,"plan_sha":"$PLAN_SHA","current_sha":"$CURRENT_SHA","commits_since_plan":0,"affected_files":[],"unaffected_plan_files":[],"severity":"none","recommendation":"proceed"}
EOF
  exit 0
fi

# --- Get changed files since plan SHA ---

CHANGED_FILES=$(git diff --name-only "$PLAN_SHA..HEAD" 2>/dev/null || echo "")
COMMITS_SINCE=$(git rev-list --count "$PLAN_SHA..HEAD" 2>/dev/null || echo "0")

# --- Intersect plan files with changed files ---

declare -a AFFECTED=()
declare -a UNAFFECTED=()
TOTAL_INSERTIONS=0
TOTAL_DELETIONS=0
HAS_DELETED=false

for plan_file in "${UNIQUE_PLAN_FILES[@]}"; do
  matched=false
  while IFS= read -r changed; do
    [[ -z "$changed" ]] && continue
    if [[ "$plan_file" == "$changed" ]]; then
      matched=true
      break
    fi
  done <<< "$CHANGED_FILES"

  if $matched; then
    # Get stat for this file
    stat_line=$(git diff "$PLAN_SHA..HEAD" --numstat -- "$plan_file" 2>/dev/null || echo "")
    insertions=0
    deletions=0
    change_type="modified"

    if [[ -n "$stat_line" ]]; then
      insertions=$(echo "$stat_line" | awk '{print $1}')
      deletions=$(echo "$stat_line" | awk '{print $2}')
      # Handle binary files
      [[ "$insertions" == "-" ]] && insertions=0
      [[ "$deletions" == "-" ]] && deletions=0
    fi

    # Check if file was deleted
    if ! git show "HEAD:$plan_file" &>/dev/null 2>&1; then
      change_type="deleted"
      HAS_DELETED=true
    # Check if file was renamed (appears in diff but different path)
    elif git diff --diff-filter=R --name-only "$PLAN_SHA..HEAD" 2>/dev/null | grep -qF "$plan_file"; then
      change_type="renamed"
      HAS_DELETED=true
    fi

    AFFECTED+=("{\"path\":\"$plan_file\",\"change_type\":\"$change_type\",\"insertions\":$insertions,\"deletions\":$deletions}")
    TOTAL_INSERTIONS=$((TOTAL_INSERTIONS + insertions))
    TOTAL_DELETIONS=$((TOTAL_DELETIONS + deletions))
  else
    UNAFFECTED+=("\"$plan_file\"")
  fi
done

# --- Determine severity ---

NUM_AFFECTED=${#AFFECTED[@]}
TOTAL_LINES=$((TOTAL_INSERTIONS + TOTAL_DELETIONS))

if [[ $NUM_AFFECTED -eq 0 ]]; then
  SEVERITY="none"
  RECOMMENDATION="proceed"
  STALE=false
elif $HAS_DELETED; then
  SEVERITY="critical"
  RECOMMENDATION="refresh_plan"
  STALE=true
elif [[ $NUM_AFFECTED -ge 3 ]] || [[ $TOTAL_LINES -gt 50 ]]; then
  SEVERITY="major"
  RECOMMENDATION="refresh_plan"
  STALE=true
else
  SEVERITY="minor"
  RECOMMENDATION="review_changes"
  STALE=true
fi

# --- Build JSON output ---

# Build affected_files array
AFFECTED_JSON="["
for i in "${!AFFECTED[@]}"; do
  [[ $i -gt 0 ]] && AFFECTED_JSON+=","
  AFFECTED_JSON+="${AFFECTED[$i]}"
done
AFFECTED_JSON+="]"

# Build unaffected_plan_files array
UNAFFECTED_JSON="["
for i in "${!UNAFFECTED[@]}"; do
  [[ $i -gt 0 ]] && UNAFFECTED_JSON+=","
  UNAFFECTED_JSON+="${UNAFFECTED[$i]}"
done
UNAFFECTED_JSON+="]"

cat <<EOF
{"stale":$STALE,"plan_sha":"$PLAN_SHA","current_sha":"$CURRENT_SHA","commits_since_plan":$COMMITS_SINCE,"affected_files":$AFFECTED_JSON,"unaffected_plan_files":$UNAFFECTED_JSON,"severity":"$SEVERITY","recommendation":"$RECOMMENDATION"}
EOF

exit 0
