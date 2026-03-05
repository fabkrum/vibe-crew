#!/usr/bin/env bash
# scripts/map-test-coverage.sh
# Pre-execution test coverage mapping (Nyquist pattern).
# Analyzes project test files, maps them to feature acceptance criteria,
# and identifies gaps that need Wave 0 test scaffolding.
#
# Usage: map-test-coverage.sh <plan-file> <backlog-file> <feature-id> [project-root]
# Output: JSON with coverage mapping, gaps, and Wave 0 tasks.
# Exit 0 always (advisory, never blocks).

set -euo pipefail

PLAN_FILE="${1:-}"
BACKLOG_FILE="${2:-}"
FEATURE_ID="${3:-}"
PROJECT_ROOT="${4:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

# --- Validate inputs ---
if [[ -z "$PLAN_FILE" || -z "$BACKLOG_FILE" || -z "$FEATURE_ID" ]]; then
  echo '{"error": "Usage: map-test-coverage.sh <plan-file> <backlog-file> <feature-id>", "mapped": false}'
  exit 0
fi

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo '{"error": "Backlog file not found", "mapped": false}'
  exit 0
fi

# --- Detect test framework ---
TEST_FRAMEWORK="unknown"
TEST_DIR=""
TEST_PATTERN=""

if [[ -f "$PROJECT_ROOT/vitest.config.ts" || -f "$PROJECT_ROOT/vitest.config.js" ]]; then
  TEST_FRAMEWORK="vitest"
  TEST_PATTERN="*.test.ts *.test.tsx *.spec.ts *.spec.tsx"
elif [[ -f "$PROJECT_ROOT/jest.config.ts" || -f "$PROJECT_ROOT/jest.config.js" || -f "$PROJECT_ROOT/jest.config.json" ]]; then
  TEST_FRAMEWORK="jest"
  TEST_PATTERN="*.test.ts *.test.tsx *.test.js *.test.jsx *.spec.ts *.spec.tsx"
elif [[ -f "$PROJECT_ROOT/playwright.config.ts" ]]; then
  TEST_FRAMEWORK="playwright"
  TEST_PATTERN="*.spec.ts *.test.ts"
elif [[ -f "$PROJECT_ROOT/cypress.config.ts" || -f "$PROJECT_ROOT/cypress.config.js" ]]; then
  TEST_FRAMEWORK="cypress"
  TEST_PATTERN="*.cy.ts *.cy.tsx *.cy.js"
elif ls "$PROJECT_ROOT"/tests/*.bats >/dev/null 2>&1; then
  TEST_FRAMEWORK="bats"
  TEST_PATTERN="*.bats"
fi

# --- Count existing test files ---
TEST_FILE_COUNT=0
if [[ "$TEST_FRAMEWORK" != "unknown" ]]; then
  for pat in $TEST_PATTERN; do
    COUNT=$(find "$PROJECT_ROOT" -name "$pat" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l | tr -d ' ')
    TEST_FILE_COUNT=$((TEST_FILE_COUNT + COUNT))
  done
fi

# --- Extract acceptance criteria from backlog ---
CRITERIA_JSON=$(jq -r --arg id "$FEATURE_ID" \
  '(.features // [])[] | select(.id == $id) | .spec.acceptance_criteria // []' \
  "$BACKLOG_FILE" 2>/dev/null || echo "[]")

CRITERIA_COUNT=$(echo "$CRITERIA_JSON" | jq 'length' 2>/dev/null || echo "0")

if [[ "$CRITERIA_COUNT" -eq 0 ]]; then
  jq -n \
    --arg framework "$TEST_FRAMEWORK" \
    --argjson test_files "$TEST_FILE_COUNT" \
    '{mapped: true, framework: $framework, test_files: $test_files, criteria_count: 0, covered: 0, gaps: 0, wave_zero_tasks: [], message: "No acceptance criteria found in backlog"}'
  exit 0
fi

# --- Extract plan task file paths for mapping ---
PLAN_FILES="[]"
if [[ -f "$PLAN_FILE" ]]; then
  PLAN_FILES=$(grep -oE '`[^`]+\.(ts|tsx|js|jsx|py|rs|go|sh)`' "$PLAN_FILE" 2>/dev/null | tr -d '`' | jq -R -s 'split("\n") | map(select(length > 0))' || echo "[]")
fi

# --- Map criteria to existing tests ---
# Look for test files that reference keywords from each criterion
COVERED=0
GAPS="[]"
COVERAGE_MAP="[]"

while IFS= read -r criterion; do
  [[ -z "$criterion" ]] && continue

  # Extract key terms from criterion (nouns and verbs, skip EARS keywords)
  KEY_TERMS=$(echo "$criterion" | tr '[:upper:]' '[:lower:]' | \
    sed 's/\b\(when\|the\|system\|shall\|if\|then\|while\|where\|a\|an\|is\|are\|be\|to\|of\|in\|for\|and\|or\)\b//g' | \
    tr -cs '[:alnum:]' '\n' | sort -u | head -5 | tr '\n' '|' | sed 's/|$//')

  FOUND_TEST=""
  if [[ -n "$KEY_TERMS" && "$TEST_FRAMEWORK" != "unknown" ]]; then
    for pat in $TEST_PATTERN; do
      MATCH=$(find "$PROJECT_ROOT" -name "$pat" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | \
        xargs grep -Eli "$KEY_TERMS" 2>/dev/null | head -1 || true)
      if [[ -n "$MATCH" ]]; then
        FOUND_TEST="$MATCH"
        break
      fi
    done
  fi

  if [[ -n "$FOUND_TEST" ]]; then
    COVERED=$((COVERED + 1))
    COVERAGE_MAP=$(echo "$COVERAGE_MAP" | jq --arg c "$criterion" --arg t "$FOUND_TEST" '. + [{"criterion": $c, "test_file": $t, "status": "covered"}]')
  else
    GAPS=$(echo "$GAPS" | jq --arg c "$criterion" '. + [$c]')
    COVERAGE_MAP=$(echo "$COVERAGE_MAP" | jq --arg c "$criterion" '. + [{"criterion": $c, "test_file": null, "status": "gap"}]')
  fi
done < <(echo "$CRITERIA_JSON" | jq -r '.[]' 2>/dev/null)

GAP_COUNT=$(echo "$GAPS" | jq 'length')

# --- Generate Wave 0 tasks for gaps ---
WAVE_ZERO="[]"
if [[ "$GAP_COUNT" -gt 0 ]]; then
  TASK_NUM=0
  while IFS= read -r gap_criterion; do
    [[ -z "$gap_criterion" ]] && continue
    TASK_NUM=$((TASK_NUM + 1))
    WAVE_ZERO=$(echo "$WAVE_ZERO" | jq \
      --arg name "Wave 0 Task ${TASK_NUM}: Test scaffold for criterion" \
      --arg criterion "$gap_criterion" \
      --arg framework "$TEST_FRAMEWORK" \
      '. + [{"task": $name, "criterion": $criterion, "framework": $framework, "action": "Create test file with describe/it block matching this acceptance criterion. Test should fail (red) before implementation."}]')
  done < <(echo "$GAPS" | jq -r '.[]' 2>/dev/null)
fi

# --- Output ---
jq -n \
  --argjson mapped true \
  --arg framework "$TEST_FRAMEWORK" \
  --argjson test_files "$TEST_FILE_COUNT" \
  --argjson criteria_count "$CRITERIA_COUNT" \
  --argjson covered "$COVERED" \
  --argjson gaps "$GAP_COUNT" \
  --argjson coverage_map "$COVERAGE_MAP" \
  --argjson gap_criteria "$GAPS" \
  --argjson wave_zero_tasks "$WAVE_ZERO" \
  '{
    mapped: $mapped,
    framework: $framework,
    test_files: $test_files,
    criteria_count: $criteria_count,
    covered: $covered,
    gaps: $gaps,
    coverage_percent: (if $criteria_count > 0 then (($covered * 100) / $criteria_count | floor) else 0 end),
    coverage_map: $coverage_map,
    gap_criteria: $gap_criteria,
    wave_zero_tasks: $wave_zero_tasks
  }'

exit 0
