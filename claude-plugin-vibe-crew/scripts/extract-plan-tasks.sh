#!/usr/bin/env bash
# scripts/extract-plan-tasks.sh
# Extracts structured tasks from plan.md into JSON for the Code phase.
# Returns {"structured": false} for legacy plans without structured tasks.
# Usage: extract-plan-tasks.sh <plan-file-path> [--milestone <name>]
# Exit 0 always.

set -euo pipefail

PLAN_FILE="${1:-}"
MILESTONE_FILTER=""

# Parse optional --milestone flag
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --milestone)
      MILESTONE_FILTER="${2:-}"
      shift 2 || break
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
  echo '{"structured": false, "tasks": [], "error": "Plan file not found"}'
  exit 0
fi

# Check for structured tasks
TASK_COUNT=$(grep -cE '^### Task [0-9]+:' "$PLAN_FILE" 2>/dev/null || true)
TASK_COUNT="${TASK_COUNT:-0}"

if [[ "$TASK_COUNT" -eq 0 ]]; then
  echo '{"structured": false, "tasks": []}'
  exit 0
fi

# Parse tasks into JSON
TASKS="[]"
CURRENT_INDEX=0
CURRENT_NAME=""
CURRENT_FILES=""
CURRENT_ACTION=""
CURRENT_VERIFY=""
CURRENT_DONE=""
IN_TASK=false

flush_task() {
  if [[ "$IN_TASK" == true && -n "$CURRENT_NAME" ]]; then
    # Parse files into structured format
    FILES_JSON="[]"
    if [[ -n "$CURRENT_FILES" ]]; then
      # Extract file paths and actions from the Files field
      # Format: `path/to/file.ts` (create|modify), `path/to/other.ts` (modify)
      while IFS= read -r file_entry; do
        file_entry=$(echo "$file_entry" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        [[ -z "$file_entry" ]] && continue
        FILE_PATH=$(echo "$file_entry" | grep -oE '`[^`]+`' | head -1 | tr -d '`' || echo "")
        FILE_ACTION=$(echo "$file_entry" | grep -oE '\((create|modify|delete)\)' | tr -d '()' || echo "modify")
        if [[ -n "$FILE_PATH" ]]; then
          FILES_JSON=$(echo "$FILES_JSON" | jq --arg p "$FILE_PATH" --arg a "${FILE_ACTION:-modify}" '. + [{"path": $p, "action": $a}]')
        fi
      done <<< "$(echo "$CURRENT_FILES" | tr ',' '\n')"
    fi

    TASKS=$(echo "$TASKS" | jq \
      --argjson index "$CURRENT_INDEX" \
      --arg name "$CURRENT_NAME" \
      --argjson files "$FILES_JSON" \
      --arg action "$CURRENT_ACTION" \
      --arg verify "$CURRENT_VERIFY" \
      --arg done_criteria "$CURRENT_DONE" \
      '. + [{"index": $index, "name": $name, "files": $files, "action": $action, "verify": $verify, "done_criteria": $done_criteria}]')
  fi
}

while IFS= read -r line; do
  if [[ "$line" =~ ^###\ Task\ ([0-9]+):\ (.+)$ ]]; then
    flush_task
    CURRENT_INDEX="${BASH_REMATCH[1]}"
    CURRENT_NAME="${BASH_REMATCH[2]}"
    CURRENT_FILES=""
    CURRENT_ACTION=""
    CURRENT_VERIFY=""
    CURRENT_DONE=""
    IN_TASK=true
  elif [[ "$IN_TASK" == true ]]; then
    if [[ "$line" =~ ^\-\ \*\*Files\*\*:\ (.+)$ ]]; then
      CURRENT_FILES="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^\-\ \*\*Action\*\*:\ (.+)$ ]]; then
      CURRENT_ACTION="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^\-\ \*\*Verify\*\*:\ (.+)$ ]]; then
      CURRENT_VERIFY=$(echo "${BASH_REMATCH[1]}" | sed 's/^`//' | sed 's/`$//')
    elif [[ "$line" =~ ^\-\ \*\*Done\ when\*\*:\ (.+)$ ]]; then
      CURRENT_DONE="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^###\  || "$line" =~ ^##\  ]]; then
      # Hit next section heading — end of tasks
      flush_task
      IN_TASK=false
    fi
  fi
done < "$PLAN_FILE"

# Flush the last task
flush_task

# Apply milestone filter if specified
if [[ -n "$MILESTONE_FILTER" ]]; then
  # Filter is informational — the caller should scope tasks to the milestone's files
  echo "$TASKS" | jq --arg milestone "$MILESTONE_FILTER" \
    '{structured: true, tasks: ., milestone_filter: $milestone}'
else
  echo "$TASKS" | jq '{structured: true, tasks: .}'
fi

exit 0
