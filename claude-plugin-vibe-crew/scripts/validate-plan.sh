#!/usr/bin/env bash
# scripts/validate-plan.sh
# Validates a plan.md file for structured tasks.
# Informational only — always exits 0.
# Usage: validate-plan.sh <plan-file-path>

set -euo pipefail

PLAN_FILE="${1:-}"

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
  echo '{"valid": false, "error": "Plan file not found", "task_count": 0, "missing_fields": []}'
  exit 0
fi

# Count structured tasks (### Task N: headings)
TASK_COUNT=$(grep -cE '^### Task [0-9]+:' "$PLAN_FILE" 2>/dev/null || true)
TASK_COUNT="${TASK_COUNT:-0}"

if [[ "$TASK_COUNT" -eq 0 ]]; then
  echo '{"structured": false, "task_count": 0, "message": "No structured tasks found — legacy plan format"}'
  exit 0
fi

# Check required fields per task
MISSING_FILES=0
MISSING_ACTION=0
MISSING_VERIFY=0
MISSING_DONE=0

# Extract task blocks and check for required fields
CURRENT_TASK=""
while IFS= read -r line; do
  if [[ "$line" =~ ^###\ Task\ [0-9]+: ]]; then
    # Check previous task's fields (if any)
    if [[ -n "$CURRENT_TASK" ]]; then
      [[ "$HAS_FILES" -eq 0 ]] && MISSING_FILES=$((MISSING_FILES + 1))
      [[ "$HAS_ACTION" -eq 0 ]] && MISSING_ACTION=$((MISSING_ACTION + 1))
      [[ "$HAS_VERIFY" -eq 0 ]] && MISSING_VERIFY=$((MISSING_VERIFY + 1))
      [[ "$HAS_DONE" -eq 0 ]] && MISSING_DONE=$((MISSING_DONE + 1))
    fi
    CURRENT_TASK="$line"
    HAS_FILES=0
    HAS_ACTION=0
    HAS_VERIFY=0
    HAS_DONE=0
  fi
  [[ "$line" =~ ^\-\ \*\*Files\*\* ]] && HAS_FILES=1
  [[ "$line" =~ ^\-\ \*\*Action\*\* ]] && HAS_ACTION=1
  [[ "$line" =~ ^\-\ \*\*Verify\*\* ]] && HAS_VERIFY=1
  [[ "$line" =~ ^\-\ \*\*Done\ when\*\* ]] && HAS_DONE=1
done < "$PLAN_FILE"

# Check last task
if [[ -n "$CURRENT_TASK" ]]; then
  [[ "$HAS_FILES" -eq 0 ]] && MISSING_FILES=$((MISSING_FILES + 1))
  [[ "$HAS_ACTION" -eq 0 ]] && MISSING_ACTION=$((MISSING_ACTION + 1))
  [[ "$HAS_VERIFY" -eq 0 ]] && MISSING_VERIFY=$((MISSING_VERIFY + 1))
  [[ "$HAS_DONE" -eq 0 ]] && MISSING_DONE=$((MISSING_DONE + 1))
fi

# Build missing fields array
MISSING="[]"
[[ "$MISSING_FILES" -gt 0 ]] && MISSING=$(echo "$MISSING" | jq --arg n "$MISSING_FILES" '. + ["Files (\($n) tasks)"]')
[[ "$MISSING_ACTION" -gt 0 ]] && MISSING=$(echo "$MISSING" | jq --arg n "$MISSING_ACTION" '. + ["Action (\($n) tasks)"]')
[[ "$MISSING_VERIFY" -gt 0 ]] && MISSING=$(echo "$MISSING" | jq --arg n "$MISSING_VERIFY" '. + ["Verify (\($n) tasks)"]')
[[ "$MISSING_DONE" -gt 0 ]] && MISSING=$(echo "$MISSING" | jq --arg n "$MISSING_DONE" '. + ["Done when (\($n) tasks)"]')

TOTAL_MISSING=$((MISSING_FILES + MISSING_ACTION + MISSING_VERIFY + MISSING_DONE))

jq -n \
  --argjson structured true \
  --argjson task_count "$TASK_COUNT" \
  --argjson missing_field_count "$TOTAL_MISSING" \
  --argjson missing_fields "$MISSING" \
  '{structured: $structured, task_count: $task_count, missing_field_count: $missing_field_count, missing_fields: $missing_fields}'

exit 0
