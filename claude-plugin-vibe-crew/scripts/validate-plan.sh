#!/usr/bin/env bash
# scripts/validate-plan.sh
# Validates a plan.md file for structured tasks and EARS-format acceptance criteria.
# Exits 0 on valid plans, exits 1 on structural issues (missing fields).
# Usage: validate-plan.sh <plan-file-path> [backlog-file-path] [feature-id]

set -euo pipefail

PLAN_FILE="${1:-}"
BACKLOG_FILE="${2:-}"
FEATURE_ID="${3:-}"

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
  echo '{"valid": false, "error": "Plan file not found", "task_count": 0, "missing_fields": []}'
  exit 1
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

# Check for EARS-format acceptance criteria (if backlog and feature ID provided)
EARS_COUNT=0
NON_EARS_COUNT=0
EARS_CHECK="skipped"

if [[ -n "$BACKLOG_FILE" && -f "$BACKLOG_FILE" && -n "$FEATURE_ID" ]]; then
  CRITERIA_JSON=$(jq -r --arg id "$FEATURE_ID" \
    '(.features // [])[] | select(.id == $id) | .spec.acceptance_criteria // []' \
    "$BACKLOG_FILE" 2>/dev/null || echo "[]")
  CRITERIA_COUNT=$(echo "$CRITERIA_JSON" | jq 'length' 2>/dev/null || echo "0")

  if [[ "$CRITERIA_COUNT" -gt 0 ]]; then
    while IFS= read -r criterion; do
      if echo "$criterion" | grep -qiE '(WHEN .+ (THE SYSTEM )?SHALL|IF .+ THEN .+ SHALL|WHERE .+ SHALL|WHILE .+ SHALL|THE SYSTEM SHALL)'; then
        EARS_COUNT=$((EARS_COUNT + 1))
      else
        NON_EARS_COUNT=$((NON_EARS_COUNT + 1))
      fi
    done < <(echo "$CRITERIA_JSON" | jq -r '.[]' 2>/dev/null)
    EARS_CHECK="checked"
  fi
fi

# Check for test coverage mapping (Nyquist) — advisory only
NYQUIST_STATUS="skipped"
NYQUIST_GAPS=0
if [[ -n "$BACKLOG_FILE" && -f "$BACKLOG_FILE" && -n "$FEATURE_ID" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  if [[ -x "$SCRIPT_DIR/map-test-coverage.sh" ]]; then
    NYQUIST_OUTPUT=$(bash "$SCRIPT_DIR/map-test-coverage.sh" "$PLAN_FILE" "$BACKLOG_FILE" "$FEATURE_ID" 2>/dev/null || echo '{}')
    NYQUIST_MAPPED=$(echo "$NYQUIST_OUTPUT" | jq -r '.mapped // false' 2>/dev/null || echo "false")
    if [[ "$NYQUIST_MAPPED" == "true" ]]; then
      NYQUIST_STATUS="checked"
      NYQUIST_GAPS=$(echo "$NYQUIST_OUTPUT" | jq -r '.gaps // 0' 2>/dev/null || echo "0")
    fi
  fi
fi

jq -n \
  --argjson structured true \
  --argjson task_count "$TASK_COUNT" \
  --argjson missing_field_count "$TOTAL_MISSING" \
  --argjson missing_fields "$MISSING" \
  --arg ears_check "$EARS_CHECK" \
  --argjson ears_count "$EARS_COUNT" \
  --argjson non_ears_count "$NON_EARS_COUNT" \
  --arg nyquist_status "$NYQUIST_STATUS" \
  --argjson nyquist_gaps "$NYQUIST_GAPS" \
  '{structured: $structured, task_count: $task_count, missing_field_count: $missing_field_count, missing_fields: $missing_fields, ears: {status: $ears_check, ears_count: $ears_count, non_ears_count: $non_ears_count}, nyquist: {status: $nyquist_status, gaps: $nyquist_gaps}}'

# Exit non-zero if structural issues found (missing required fields)
if [[ "$TOTAL_MISSING" -gt 0 ]]; then
  exit 1
fi

exit 0
