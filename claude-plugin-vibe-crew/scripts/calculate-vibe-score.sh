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

# --- 7. TDD discipline detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TDD_DETECTED=false
TDD_CYCLE_COUNT=0

if [[ -x "$SCRIPT_DIR/detect-tdd-discipline.sh" ]]; then
  TDD_OUTPUT=$(bash "$SCRIPT_DIR/detect-tdd-discipline.sh" "$PROJECT_ROOT" 2>/dev/null || echo '{}')
  TDD_DETECTED=$(echo "$TDD_OUTPUT" | jq -r '.discipline_detected // false' 2>/dev/null || echo "false")
  TDD_CYCLE_COUNT=$(echo "$TDD_OUTPUT" | jq -r '.cycle_count // 0' 2>/dev/null || echo "0")
fi

# --- 8. E2E test detection ---
E2E_EXISTS=false
E2E_PASSED=false

E2E_FILES=$(find "$PROJECT_ROOT" \
  -type f \( -name "*.spec.ts" -o -name "*.spec.js" \) \
  -path "*/e2e/*" \
  -not -path "*/node_modules/*" \
  2>/dev/null || true)

if [[ -n "$E2E_FILES" ]]; then
  E2E_EXISTS=true
  # Check if Playwright results exist from recent run
  if [[ -d "$PROJECT_ROOT/test-results" ]] || [[ -d "$PROJECT_ROOT/playwright-report" ]]; then
    E2E_PASSED=true
  fi
fi

# --- 9. a11y check detection ---
A11Y_CLEAN=false
A11Y_EXISTS=false

if [[ -d "$PROJECT_ROOT/.vibecrew/a11y" ]]; then
  LATEST_A11Y=$(ls -1t "$PROJECT_ROOT/.vibecrew/a11y"/audit-*.json 2>/dev/null | head -1)
  if [[ -n "$LATEST_A11Y" && -f "$LATEST_A11Y" ]]; then
    A11Y_EXISTS=true
    CRITICAL_COUNT=$(jq -r '.summary.critical // 0' "$LATEST_A11Y" 2>/dev/null || echo "0")
    SERIOUS_COUNT=$(jq -r '.summary.serious // 0' "$LATEST_A11Y" 2>/dev/null || echo "0")
    if [[ "$CRITICAL_COUNT" -eq 0 && "$SERIOUS_COUNT" -eq 0 ]]; then
      A11Y_CLEAN=true
    fi
  fi
fi

# --- 10. Code review detection ---
REVIEW_COMPLETED=false
REVIEW_FINDINGS=0

if [[ -x "$SCRIPT_DIR/detect-review-status.sh" ]]; then
  REVIEW_OUTPUT=$(bash "$SCRIPT_DIR/detect-review-status.sh" "$PROJECT_ROOT" 2>/dev/null || echo '{}')
  REVIEW_COMPLETED=$(echo "$REVIEW_OUTPUT" | jq -r '.review_completed // false' 2>/dev/null || echo "false")
  REVIEW_FINDINGS=$(echo "$REVIEW_OUTPUT" | jq -r '.findings_count // 0' 2>/dev/null || echo "0")
fi

# --- 11. Performance baseline detection ---
PERF_BASELINES_EXIST=false
PERF_TEST_TYPES="[]"

if [[ -x "$SCRIPT_DIR/detect-perf-baselines.sh" ]]; then
  PERF_OUTPUT=$(bash "$SCRIPT_DIR/detect-perf-baselines.sh" "$PROJECT_ROOT" 2>/dev/null || echo '{}')
  PERF_BASELINES_EXIST=$(echo "$PERF_OUTPUT" | jq -r '.baselines_exist // false' 2>/dev/null || echo "false")
  PERF_TEST_TYPES=$(echo "$PERF_OUTPUT" | jq -c '.test_types // []' 2>/dev/null || echo "[]")
fi

# --- 12. Output JSON ---
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
  --argjson tdd_detected "$TDD_DETECTED" \
  --argjson tdd_cycle_count "$TDD_CYCLE_COUNT" \
  --argjson e2e_exists "$E2E_EXISTS" \
  --argjson e2e_passed "$E2E_PASSED" \
  --argjson a11y_exists "$A11Y_EXISTS" \
  --argjson a11y_clean "$A11Y_CLEAN" \
  --argjson review_completed "$REVIEW_COMPLETED" \
  --argjson review_findings "$REVIEW_FINDINGS" \
  --argjson perf_baselines_exist "$PERF_BASELINES_EXIST" \
  --argjson perf_test_types "$PERF_TEST_TYPES" \
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
    all_phases_complete: $all_phases_complete,
    tdd_detected: $tdd_detected,
    tdd_cycle_count: $tdd_cycle_count,
    e2e_exists: $e2e_exists,
    e2e_passed: $e2e_passed,
    a11y_exists: $a11y_exists,
    a11y_clean: $a11y_clean,
    review_completed: $review_completed,
    review_findings: $review_findings,
    perf_baselines_exist: $perf_baselines_exist,
    perf_test_types: $perf_test_types
  }'
