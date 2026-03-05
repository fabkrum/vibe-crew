#!/usr/bin/env bash
# scripts/calculate-vibe-score.sh
# Pre-calculation of score metrics for the Vibe Score system.
# Called by /wrap to gather data before the Performance Coach agent scores.
# Usage: calculate-vibe-score.sh [project_root]
# Output: JSON metrics object to stdout

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source error logging and compat
source "$SCRIPT_DIR/lib/error-log.sh"
source "$SCRIPT_DIR/lib/compat.sh"

# --- Timeout helper (120s default) ---
_VIBE_TIMEOUT_CMD=$(_compat_timeout_cmd)
_run_with_timeout() {
  local seconds="${1:-120}"
  shift
  if [[ -n "$_VIBE_TIMEOUT_CMD" ]]; then
    "$_VIBE_TIMEOUT_CMD" "$seconds" "$@"
  else
    "$@"
  fi
}

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
  # Read active feature ID from state (use .id specifically, not the whole object)
  ACTIVE_FEATURE_ID=$(safe_jq "$STATE_FILE" '.active_feature.id // empty' "")

  if [[ -n "$ACTIVE_FEATURE_ID" && "$ACTIVE_FEATURE_ID" != "null" ]]; then
    # Tier 2 phases: plan, design, code, test, docs
    PHASES_COMPLETED=$(jq -c \
      '.active_feature.phases_completed // []' \
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
  ACTIVE_FEATURE_ID=$(safe_jq "$STATE_FILE" '.active_feature.id // empty' "")

  if [[ -n "$ACTIVE_FEATURE_ID" && "$ACTIVE_FEATURE_ID" != "null" ]]; then
    CRITERIA=$(jq -r \
      --arg feat "$ACTIVE_FEATURE_ID" \
      '.features[]? | select(.id == $feat or .name == $feat) | .spec.acceptance_criteria // empty' \
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
    TEST_OUTPUT=$(cd "$PROJECT_ROOT" && _run_with_timeout 120 npm test -- --reporter=json 2>/dev/null || { log_error "calculate-vibe-score" "Test suite failed or timed out"; echo ""; })

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
    if (cd "$PROJECT_ROOT" && _run_with_timeout 120 npm run build 2>/dev/null 1>/dev/null); then
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
    if (cd "$PROJECT_ROOT" && _run_with_timeout 120 npm run lint 2>/dev/null 1>/dev/null); then
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

# --- 9.5. Visual verification detection ---
VISUAL_VERIFIED=false
VISUAL_CLEAN=false
VISUAL_TOKEN_VIOLATIONS=0
VISUAL_CONSOLE_ERRORS=0

# Check builder-complete.signal for visual_verification data
SIGNALS_DIR="$PROJECT_ROOT/.vibecrew/signals"
if [[ -d "$SIGNALS_DIR" ]]; then
  LATEST_BUILDER_SIGNAL=$(ls -1t "$SIGNALS_DIR"/builder-complete.signal 2>/dev/null | head -1 || true)
  if [[ -n "$LATEST_BUILDER_SIGNAL" && -f "$LATEST_BUILDER_SIGNAL" ]]; then
    VV_DATA=$(jq -r '.visual_verification // empty' "$LATEST_BUILDER_SIGNAL" 2>/dev/null || echo "")
    if [[ -n "$VV_DATA" && "$VV_DATA" != "null" ]]; then
      VV_SKIPPED=$(echo "$VV_DATA" | jq -r '.skipped // false' 2>/dev/null || echo "true")
      if [[ "$VV_SKIPPED" != "true" ]]; then
        VISUAL_VERIFIED=true
        VISUAL_CONSOLE_ERRORS=$(echo "$VV_DATA" | jq -r '.console_errors // 0' 2>/dev/null || echo "0")
        VISUAL_TOKEN_VIOLATIONS=$(echo "$VV_DATA" | jq -r '.token_violations // 0' 2>/dev/null || echo "0")
        if [[ "$VISUAL_CONSOLE_ERRORS" -eq 0 && "$VISUAL_TOKEN_VIOLATIONS" -eq 0 ]]; then
          VISUAL_CLEAN=true
        fi
      fi
    fi
  fi
fi

# Also check latest review report for visual-compliance findings
if [[ -f "$STATE_FILE" && -d "$PROJECT_ROOT/.vibecrew/reviews" ]]; then
  FEATURE_ID_VC=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
  if [[ -n "$FEATURE_ID_VC" ]]; then
    LATEST_REVIEW_VC=$(ls -1t "$PROJECT_ROOT/.vibecrew/reviews"/review-"${FEATURE_ID_VC}"-*.json 2>/dev/null | head -1 || true)
    if [[ -n "$LATEST_REVIEW_VC" && -f "$LATEST_REVIEW_VC" ]]; then
      REVIEW_VC_COUNT=$(jq '[.findings[]? | select(.category == "visual-compliance")] | length' "$LATEST_REVIEW_VC" 2>/dev/null || echo "0")
      if [[ "$REVIEW_VC_COUNT" -gt 0 ]]; then
        VISUAL_VERIFIED=true
        # Add review visual violations to signal violations
        REVIEW_TOKEN_V=$(jq '[.findings[]? | select(.category == "visual-compliance" and .severity != "critical")] | length' "$LATEST_REVIEW_VC" 2>/dev/null || echo "0")
        REVIEW_CONSOLE_E=$(jq '[.findings[]? | select(.category == "visual-compliance" and .severity == "critical")] | length' "$LATEST_REVIEW_VC" 2>/dev/null || echo "0")
        VISUAL_TOKEN_VIOLATIONS=$(( VISUAL_TOKEN_VIOLATIONS > REVIEW_TOKEN_V ? VISUAL_TOKEN_VIOLATIONS : REVIEW_TOKEN_V ))
        VISUAL_CONSOLE_ERRORS=$(( VISUAL_CONSOLE_ERRORS > REVIEW_CONSOLE_E ? VISUAL_CONSOLE_ERRORS : REVIEW_CONSOLE_E ))
        if [[ "$VISUAL_CONSOLE_ERRORS" -gt 0 || "$VISUAL_TOKEN_VIOLATIONS" -gt 0 ]]; then
          VISUAL_CLEAN=false
        fi
      fi
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

# --- 11.5. Plan revision count ---
PLAN_REVISION_COUNT=0

if [[ -f "$STATE_FILE" ]]; then
  PLAN_REVISION_COUNT=$(safe_jq "$STATE_FILE" '.active_feature.plan_revision_count // 0' "0")
fi

# --- 12. Drift detection metrics ---
DRIFT_WARNINGS=0
DRIFT_ESCALATIONS=0
DRIFT_CALLS_SINCE_PROGRESS=0

DRIFT_FILE="$PROJECT_ROOT/.vibecrew/drift-tracker.json"
if [[ -f "$DRIFT_FILE" ]]; then
  DRIFT_WARNINGS=$(jq -r '.warnings.soft_count // 0' "$DRIFT_FILE" 2>/dev/null || echo "0")
  DRIFT_ESCALATIONS=$(jq -r '.escalations.hard_count // 0' "$DRIFT_FILE" 2>/dev/null || echo "0")
  DRIFT_CALLS_SINCE_PROGRESS=$(jq -r '.calls_since_progress // 0' "$DRIFT_FILE" 2>/dev/null || echo "0")
fi

# --- 13a. Agent efficiency metrics ---
AGENT_INEFFICIENCY=0
AGENT_EFFICIENCY_BONUS=0

if [[ -x "$SCRIPT_DIR/analyze-agent-effectiveness.sh" ]]; then
  AGENT_ANALYSIS=$(bash "$SCRIPT_DIR/analyze-agent-effectiveness.sh" 2>/dev/null || echo '{"agents":[],"inefficiency_patterns":[]}')
  # Check for write-heavy agents below threshold across 3+ sessions
  INEFFICIENT_COUNT=$(echo "$AGENT_ANALYSIS" | jq '[.agents[]? | select(.flags | index("excessive_exploration") != null)] | length' 2>/dev/null || echo "0")
  if [[ "$INEFFICIENT_COUNT" -gt 0 ]]; then
    AGENT_INEFFICIENCY=1
  fi
  # Check if ALL agents are above baseline for 3+ sessions
  TOTAL_AGENTS=$(echo "$AGENT_ANALYSIS" | jq '[.agents[]? | select(.sessions_analyzed >= 3)] | length' 2>/dev/null || echo "0")
  FLAGGED_AGENTS=$(echo "$AGENT_ANALYSIS" | jq '[.agents[]? | select(.flags | length > 0)] | length' 2>/dev/null || echo "0")
  if [[ "$TOTAL_AGENTS" -gt 0 && "$FLAGGED_AGENTS" -eq 0 ]]; then
    AGENT_EFFICIENCY_BONUS=1
  fi
fi

# --- 13b. Fix-without-regression detection ---
FIX_WITHOUT_REGRESSION=0

if [[ -x "$SCRIPT_DIR/detect-fix-commits.sh" ]]; then
  FIX_COMMITS=$(bash "$SCRIPT_DIR/detect-fix-commits.sh" 2>/dev/null || echo "[]")
  FIX_WITHOUT_REGRESSION=$(echo "$FIX_COMMITS" | jq 'length' 2>/dev/null || echo "0")
fi

# --- 13. Erosion detection metrics ---
EROSION_SCORE=0
EROSION_RATING="unknown"
EROSION_FLAGS=0

if [[ -x "$SCRIPT_DIR/calculate-erosion-score.sh" ]]; then
  EROSION_OUTPUT=$(bash "$SCRIPT_DIR/calculate-erosion-score.sh" "$PROJECT_ROOT" 2>/dev/null || echo '{}')
  EROSION_SCORE=$(echo "$EROSION_OUTPUT" | jq -r '.score // 0' 2>/dev/null || echo "0")
  EROSION_RATING=$(echo "$EROSION_OUTPUT" | jq -r '.rating // "unknown"' 2>/dev/null || echo "unknown")
  EROSION_FLAGS=$(echo "$EROSION_OUTPUT" | jq -r '(.deductions | length) // 0' 2>/dev/null || echo "0")
fi

# --- 14. Output JSON ---
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
  --argjson visual_verified "$VISUAL_VERIFIED" \
  --argjson visual_clean "$VISUAL_CLEAN" \
  --argjson visual_token_violations "$VISUAL_TOKEN_VIOLATIONS" \
  --argjson visual_console_errors "$VISUAL_CONSOLE_ERRORS" \
  --argjson review_completed "$REVIEW_COMPLETED" \
  --argjson review_findings "$REVIEW_FINDINGS" \
  --argjson perf_baselines_exist "$PERF_BASELINES_EXIST" \
  --argjson perf_test_types "$PERF_TEST_TYPES" \
  --argjson plan_revision_count "$PLAN_REVISION_COUNT" \
  --argjson drift_warnings "$DRIFT_WARNINGS" \
  --argjson drift_escalations "$DRIFT_ESCALATIONS" \
  --argjson drift_calls_since_progress "$DRIFT_CALLS_SINCE_PROGRESS" \
  --argjson erosion_score "$EROSION_SCORE" \
  --arg erosion_rating "$EROSION_RATING" \
  --argjson erosion_flags "$EROSION_FLAGS" \
  --argjson fix_without_regression "$FIX_WITHOUT_REGRESSION" \
  --argjson agent_inefficiency "$AGENT_INEFFICIENCY" \
  --argjson agent_efficiency_bonus "$AGENT_EFFICIENCY_BONUS" \
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
    visual_verified: $visual_verified,
    visual_clean: $visual_clean,
    visual_token_violations: $visual_token_violations,
    visual_console_errors: $visual_console_errors,
    review_completed: $review_completed,
    review_findings: $review_findings,
    perf_baselines_exist: $perf_baselines_exist,
    perf_test_types: $perf_test_types,
    plan_revision_count: $plan_revision_count,
    drift_warnings: $drift_warnings,
    drift_escalations: $drift_escalations,
    drift_calls_since_progress: $drift_calls_since_progress,
    erosion_score: $erosion_score,
    erosion_rating: $erosion_rating,
    erosion_flags: $erosion_flags,
    fix_without_regression: $fix_without_regression,
    agent_inefficiency: $agent_inefficiency,
    agent_efficiency_bonus: $agent_efficiency_bonus
  }'
