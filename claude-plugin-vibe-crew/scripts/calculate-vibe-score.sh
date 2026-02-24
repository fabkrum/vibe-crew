#!/usr/bin/env bash
# scripts/calculate-vibe-score.sh
# Pre-calculation of score metrics for the Vibe Score system.
# Called by /wrap to gather data before the Performance Coach agent scores.
# Usage: calculate-vibe-score.sh [project_root]
# Output: JSON metrics object to stdout

set -euo pipefail

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"

# --- Helper: safe jq with fallback ---
safe_jq() {
  local file="$1" query="$2" default="$3"
  if [[ -f "$file" ]]; then
    jq -r "$query" "$file" 2>/dev/null || echo "$default"
  else
    echo "$default"
  fi
}

# --- 1. Phase completion data ---
PHASES_COMPLETED="[]"
PHASES_SKIPPED=0
ALL_PHASES_COMPLETE=false

if [[ -f "$STATE_FILE" ]]; then
  # Read active feature's phase data from state
  ACTIVE_FEATURE=$(safe_jq "$STATE_FILE" '.active_feature // empty' "")

  if [[ -n "$ACTIVE_FEATURE" && "$ACTIVE_FEATURE" != "null" ]]; then
    # Tier 2 phases: plan, design, code, test, docs
    PHASES_COMPLETED=$(jq -c \
      '[.features[.active_feature].phases // {} | to_entries[] | select(.value.status == "complete") | .key]' \
      "$STATE_FILE" 2>/dev/null || echo "[]")

    TOTAL_PHASES=5
    COMPLETED_COUNT=$(echo "$PHASES_COMPLETED" | jq 'length' 2>/dev/null || echo "0")
    PHASES_SKIPPED=$(( TOTAL_PHASES - COMPLETED_COUNT ))

    if [[ "$COMPLETED_COUNT" -eq "$TOTAL_PHASES" ]]; then
      ALL_PHASES_COMPLETE=true
    fi
  else
    # Check Tier 1 foundation phases
    PHASES_COMPLETED=$(jq -c \
      '[.foundation.artifacts // {} | to_entries[] | select(.value.status == "complete") | .key]' \
      "$STATE_FILE" 2>/dev/null || echo "[]")

    FOUNDATION_COMPLETE=$(safe_jq "$STATE_FILE" '.foundation.complete // false' "false")
    if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
      ALL_PHASES_COMPLETE=true
      PHASES_SKIPPED=0
    else
      TOTAL_ARTIFACTS=$(jq '[.foundation.artifacts // {} | to_entries[] | .key] | length' "$STATE_FILE" 2>/dev/null || echo "5")
      COMPLETED_COUNT=$(echo "$PHASES_COMPLETED" | jq 'length' 2>/dev/null || echo "0")
      PHASES_SKIPPED=$(( TOTAL_ARTIFACTS - COMPLETED_COUNT ))
    fi
  fi
fi

# --- 2. Feature spec check ---
HAS_SPEC=false

if [[ -f "$BACKLOG_FILE" ]]; then
  # Check if any active feature in the backlog has non-empty acceptance_criteria
  ACTIVE_FEATURE=$(safe_jq "$STATE_FILE" '.active_feature // empty' "")

  if [[ -n "$ACTIVE_FEATURE" && "$ACTIVE_FEATURE" != "null" ]]; then
    CRITERIA=$(jq -r \
      --arg feat "$ACTIVE_FEATURE" \
      '.features[]? | select(.id == $feat or .name == $feat) | .acceptance_criteria // empty' \
      "$BACKLOG_FILE" 2>/dev/null || echo "")

    if [[ -n "$CRITERIA" && "$CRITERIA" != "null" && "$CRITERIA" != "[]" && "$CRITERIA" != "" ]]; then
      HAS_SPEC=true
    fi
  fi
fi

# --- 3. Test artifacts ---
TESTS_EXIST=false
TEST_COUNT=0
TEST_FAILURES=0
TESTS_PASSED=false
COVERAGE_PERCENT=0

# Look for test files
TEST_FILES=$(find "$PROJECT_ROOT" \
  -type f \( -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.ts" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.vibecrew/*" \
  2>/dev/null || true)

if [[ -n "$TEST_FILES" ]]; then
  TESTS_EXIST=true
fi

# Run npm test if package.json exists and has a test script
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  HAS_TEST_SCRIPT=$(jq -r '.scripts.test // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")

  if [[ -n "$HAS_TEST_SCRIPT" ]]; then
    TEST_OUTPUT=$(cd "$PROJECT_ROOT" && npm test -- --reporter=json 2>/dev/null || true)

    if [[ -n "$TEST_OUTPUT" ]]; then
      # Try to parse as JSON (vitest/jest JSON reporter output)
      PARSED_TOTAL=$(echo "$TEST_OUTPUT" | jq -r '.numTotalTests // .testResults // empty' 2>/dev/null || echo "")

      if [[ -n "$PARSED_TOTAL" && "$PARSED_TOTAL" != "null" ]]; then
        # Jest-style JSON output
        TEST_COUNT=$(echo "$TEST_OUTPUT" | jq -r '.numTotalTests // 0' 2>/dev/null || echo "0")
        TEST_FAILURES=$(echo "$TEST_OUTPUT" | jq -r '.numFailedTests // 0' 2>/dev/null || echo "0")

        if [[ "$TEST_FAILURES" -eq 0 && "$TEST_COUNT" -gt 0 ]]; then
          TESTS_PASSED=true
        fi

        # Try to extract coverage
        COVERAGE_PERCENT=$(echo "$TEST_OUTPUT" | jq -r \
          '.coverageMap // .coverage // empty |
           if type == "object" then
             [to_entries[].value.s | to_entries[] | .value] |
             if length > 0 then (map(select(. > 0)) | length) / length * 100 | floor else 0 end
           else 0 end' 2>/dev/null || echo "0")
      else
        # Fallback: try vitest-style JSON
        TEST_COUNT=$(echo "$TEST_OUTPUT" | jq -r '.testResults | map(.assertionResults | length) | add // 0' 2>/dev/null || echo "0")
        TEST_FAILURES=$(echo "$TEST_OUTPUT" | jq -r '.testResults | map(.assertionResults | map(select(.status == "failed")) | length) | add // 0' 2>/dev/null || echo "0")

        if [[ "$TEST_FAILURES" -eq 0 && "$TEST_COUNT" -gt 0 ]]; then
          TESTS_PASSED=true
        fi
      fi

      TESTS_EXIST=true
    fi
  fi
fi

# --- 4. Build check ---
BUILD_PASSES=false

if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  HAS_BUILD=$(jq -r '.scripts.build // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")

  if [[ -n "$HAS_BUILD" ]]; then
    if (cd "$PROJECT_ROOT" && npm run build 2>/dev/null 1>/dev/null); then
      BUILD_PASSES=true
    fi
  else
    # No build script -- not applicable, treat as passing
    BUILD_PASSES=true
  fi
else
  # No package.json -- not applicable
  BUILD_PASSES=true
fi

# --- 5. Lint check ---
LINT_CLEAN=false

if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  HAS_LINT=$(jq -r '.scripts.lint // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")

  if [[ -n "$HAS_LINT" ]]; then
    if (cd "$PROJECT_ROOT" && npm run lint 2>/dev/null 1>/dev/null); then
      LINT_CLEAN=true
    fi
  else
    # No lint script -- not applicable, treat as clean
    LINT_CLEAN=true
  fi
else
  # No package.json -- not applicable
  LINT_CLEAN=true
fi

# --- 6. Output JSON ---
# Use jq to construct proper JSON (handles escaping)
jq -n \
  --argjson tests_exist "$TESTS_EXIST" \
  --argjson tests_passed "$TESTS_PASSED" \
  --argjson test_count "$TEST_COUNT" \
  --argjson test_failures "$TEST_FAILURES" \
  --argjson coverage_percent "$COVERAGE_PERCENT" \
  --argjson build_passes "$BUILD_PASSES" \
  --argjson lint_clean "$LINT_CLEAN" \
  --argjson has_spec "$HAS_SPEC" \
  --argjson phases_completed "$PHASES_COMPLETED" \
  --argjson phases_skipped "$PHASES_SKIPPED" \
  --argjson all_phases_complete "$ALL_PHASES_COMPLETE" \
  '{
    tests_exist: $tests_exist,
    tests_passed: $tests_passed,
    test_count: $test_count,
    test_failures: $test_failures,
    coverage_percent: $coverage_percent,
    build_passes: $build_passes,
    lint_clean: $lint_clean,
    has_spec: $has_spec,
    phases_completed: $phases_completed,
    phases_skipped: $phases_skipped,
    all_phases_complete: $all_phases_complete
  }'
