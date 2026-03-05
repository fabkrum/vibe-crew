#!/usr/bin/env bash
# scripts/verify-plan-goals.sh
# Pre-execution plan verification: checks goal coverage, dependency integrity,
# and context budget estimation before the Builder begins implementation.
# Returns JSON with verification results and pass/fail status.
# Usage: verify-plan-goals.sh <plan-file-path> <backlog-file-path> <feature-id>

set -euo pipefail

PLAN_FILE="${1:-}"
BACKLOG_FILE="${2:-.vibecrew/backlog.json}"
FEATURE_ID="${3:-}"

if [[ -z "$PLAN_FILE" || ! -f "$PLAN_FILE" ]]; then
  echo '{"pass": false, "error": "Plan file not found", "checks": {}}'
  exit 1
fi

if [[ -z "$FEATURE_ID" ]]; then
  echo '{"pass": false, "error": "Feature ID required", "checks": {}}'
  exit 1
fi

# --- Check 1: Goal Coverage ---
# Extract acceptance criteria from backlog
CRITERIA_JSON="[]"
if [[ -f "$BACKLOG_FILE" ]]; then
  CRITERIA_JSON=$(jq -r --arg id "$FEATURE_ID" \
    '(.features // [])[] | select(.id == $id) | .spec.acceptance_criteria // []' \
    "$BACKLOG_FILE" 2>/dev/null || echo "[]")
fi

CRITERIA_COUNT=$(echo "$CRITERIA_JSON" | jq 'length' 2>/dev/null || echo "0")

# Count structured tasks in plan
TASK_COUNT=$(grep -cE '^### Task [0-9]+:' "$PLAN_FILE" 2>/dev/null || true)
TASK_COUNT="${TASK_COUNT:-0}"

# Check if each criterion has some coverage in the plan
UNCOVERED_CRITERIA="[]"
if [[ "$CRITERIA_COUNT" -gt 0 && "$TASK_COUNT" -gt 0 ]]; then
  PLAN_CONTENT=$(cat "$PLAN_FILE")
  while IFS= read -r criterion; do
    # Extract key words from criterion (3+ char words)
    KEY_WORDS=$(echo "$criterion" | tr '[:upper:]' '[:lower:]' | grep -oE '[a-z]{3,}' | head -5)
    FOUND=0
    for word in $KEY_WORDS; do
      if echo "$PLAN_CONTENT" | tr '[:upper:]' '[:lower:]' | grep -q "$word"; then
        FOUND=$((FOUND + 1))
      fi
    done
    # If fewer than 2 key words appear in the plan, flag as potentially uncovered
    if [[ "$FOUND" -lt 2 ]]; then
      UNCOVERED_CRITERIA=$(echo "$UNCOVERED_CRITERIA" | jq --arg c "$criterion" '. + [$c]')
    fi
  done < <(echo "$CRITERIA_JSON" | jq -r '.[]' 2>/dev/null)
fi

UNCOVERED_COUNT=$(echo "$UNCOVERED_CRITERIA" | jq 'length' 2>/dev/null || echo "0")
GOAL_COVERAGE_PASS=true
if [[ "$UNCOVERED_COUNT" -gt 0 ]]; then
  GOAL_COVERAGE_PASS=false
fi

# --- Check 2: Dependency Integrity ---
# Verify files referenced in tasks exist (for "modify" actions) or that parent dirs exist (for "create" actions)
MISSING_DEPS="[]"
MODIFY_FILES=$(grep -A1 '^\- \*\*Files\*\*' "$PLAN_FILE" 2>/dev/null | grep -oE '`[^`]+`' | tr -d '`' | sort -u || true)

for filepath in $MODIFY_FILES; do
  # Skip template placeholders
  [[ "$filepath" == *"{{"* ]] && continue
  [[ "$filepath" == *"path/to"* ]] && continue

  # Check if the file is marked as "modify" in context
  IS_MODIFY=$(grep -A1 "$filepath" "$PLAN_FILE" 2>/dev/null | grep -c "modify" || true)
  IS_MODIFY="${IS_MODIFY:-0}"
  if [[ "$IS_MODIFY" -gt 0 && ! -f "$filepath" ]]; then
    MISSING_DEPS=$(echo "$MISSING_DEPS" | jq --arg f "$filepath" '. + [$f]')
  fi
done

MISSING_DEP_COUNT=$(echo "$MISSING_DEPS" | jq 'length' 2>/dev/null || echo "0")
DEPENDENCY_PASS=true
if [[ "$MISSING_DEP_COUNT" -gt 0 ]]; then
  DEPENDENCY_PASS=false
fi

# --- Check 3: Context Budget Estimation ---
# Estimate context usage based on task count and file count
FILE_COUNT=$(echo "$MODIFY_FILES" | grep -c '.' 2>/dev/null || true)
FILE_COUNT="${FILE_COUNT:-0}"

# Rough heuristic: each task uses ~2-3% context, each file read uses ~1%
ESTIMATED_CONTEXT=$((TASK_COUNT * 3 + FILE_COUNT * 1))
CONTEXT_BUDGET_PASS=true
CONTEXT_WARNING=""
if [[ "$ESTIMATED_CONTEXT" -gt 40 ]]; then
  CONTEXT_BUDGET_PASS=false
  CONTEXT_WARNING="Estimated context usage (${ESTIMATED_CONTEXT}%) exceeds 40% budget. Consider splitting into milestones."
elif [[ "$ESTIMATED_CONTEXT" -gt 30 ]]; then
  CONTEXT_WARNING="Estimated context usage (${ESTIMATED_CONTEXT}%) is high. Monitor during execution."
fi

# --- Check 4: EARS-format Acceptance Criteria ---
EARS_COUNT=0
NON_EARS_COUNT=0
if [[ "$CRITERIA_COUNT" -gt 0 ]]; then
  while IFS= read -r criterion; do
    # Check for EARS patterns: WHEN...SHALL, IF...THEN...SHALL, WHERE...SHALL, WHILE...SHALL
    if echo "$criterion" | grep -qiE '(WHEN .+ (THE SYSTEM )?SHALL|IF .+ THEN .+ SHALL|WHERE .+ SHALL|WHILE .+ SHALL|THE SYSTEM SHALL)'; then
      EARS_COUNT=$((EARS_COUNT + 1))
    else
      NON_EARS_COUNT=$((NON_EARS_COUNT + 1))
    fi
  done < <(echo "$CRITERIA_JSON" | jq -r '.[]' 2>/dev/null)
fi

EARS_PASS=true
if [[ "$NON_EARS_COUNT" -gt 0 && "$EARS_COUNT" -eq 0 ]]; then
  EARS_PASS=false
fi

# --- Overall Result ---
OVERALL_PASS=true
if [[ "$GOAL_COVERAGE_PASS" == "false" || "$DEPENDENCY_PASS" == "false" ]]; then
  OVERALL_PASS=false
fi

jq -n \
  --argjson pass "$OVERALL_PASS" \
  --argjson criteria_count "$CRITERIA_COUNT" \
  --argjson task_count "$TASK_COUNT" \
  --argjson goal_coverage_pass "$GOAL_COVERAGE_PASS" \
  --argjson uncovered_criteria "$UNCOVERED_CRITERIA" \
  --argjson dependency_pass "$DEPENDENCY_PASS" \
  --argjson missing_deps "$MISSING_DEPS" \
  --argjson context_budget_pass "$CONTEXT_BUDGET_PASS" \
  --arg context_warning "$CONTEXT_WARNING" \
  --argjson estimated_context "$ESTIMATED_CONTEXT" \
  --argjson ears_pass "$EARS_PASS" \
  --argjson ears_count "$EARS_COUNT" \
  --argjson non_ears_count "$NON_EARS_COUNT" \
  '{
    pass: $pass,
    checks: {
      goal_coverage: {
        pass: $goal_coverage_pass,
        criteria_count: $criteria_count,
        task_count: $task_count,
        uncovered_criteria: $uncovered_criteria
      },
      dependency_integrity: {
        pass: $dependency_pass,
        missing_dependencies: $missing_deps
      },
      context_budget: {
        pass: $context_budget_pass,
        estimated_percent: $estimated_context,
        warning: $context_warning
      },
      ears_format: {
        pass: $ears_pass,
        ears_count: $ears_count,
        non_ears_count: $non_ears_count
      }
    }
  }'

# Exit non-zero when critical checks fail
if [[ "$OVERALL_PASS" == "false" ]]; then
  exit 1
fi

exit 0
