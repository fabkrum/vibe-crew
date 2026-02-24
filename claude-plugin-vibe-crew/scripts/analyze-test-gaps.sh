#!/usr/bin/env bash
# scripts/analyze-test-gaps.sh
# Compares source files vs test files to identify untested modules.
# Calculates baseline coverage estimation.
# Outputs JSON with test gap analysis.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- Find source files ---
SOURCE_FILES=$(find "$PROJECT_ROOT" -maxdepth 6 \
  \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) \
  -not -name "*.test.*" -not -name "*.spec.*" -not -name "*.d.ts" \
  -not -path "*/node_modules/*" -not -path "*/.next/*" \
  -not -path "*/dist/*" -not -path "*/build/*" \
  -not -path "*/__tests__/*" -not -path "*/tests/*" \
  -not -path "*/.vibecrew/*" -not -path "*/coverage/*" \
  -not -name "*.config.*" -not -name "*.setup.*" \
  2>/dev/null || echo "")

SOURCE_COUNT=0
if [[ -n "$SOURCE_FILES" ]]; then
  SOURCE_COUNT=$(echo "$SOURCE_FILES" | grep -c '.' 2>/dev/null || echo "0")
fi

# --- Find test files ---
TEST_FILES=$(find "$PROJECT_ROOT" -maxdepth 6 \
  \( -name "*.test.*" -o -name "*.spec.*" \) \
  -not -path "*/node_modules/*" -not -path "*/.next/*" \
  -not -path "*/dist/*" -not -path "*/.vibecrew/*" \
  2>/dev/null || echo "")

TEST_COUNT=0
if [[ -n "$TEST_FILES" ]]; then
  TEST_COUNT=$(echo "$TEST_FILES" | grep -c '.' 2>/dev/null || echo "0")
fi

# --- Detect test framework ---
TEST_FRAMEWORK="unknown"
if [[ -f "$PROJECT_ROOT/vitest.config.ts" || -f "$PROJECT_ROOT/vitest.config.js" ]]; then
  TEST_FRAMEWORK="vitest"
elif [[ -f "$PROJECT_ROOT/jest.config.ts" || -f "$PROJECT_ROOT/jest.config.js" || -f "$PROJECT_ROOT/jest.config.json" ]]; then
  TEST_FRAMEWORK="jest"
elif [[ -f "$PROJECT_ROOT/package.json" ]]; then
  HAS_VITEST=$(jq -r '.devDependencies.vitest // .dependencies.vitest // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
  HAS_JEST=$(jq -r '.devDependencies.jest // .dependencies.jest // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
  if [[ -n "$HAS_VITEST" ]]; then
    TEST_FRAMEWORK="vitest"
  elif [[ -n "$HAS_JEST" ]]; then
    TEST_FRAMEWORK="jest"
  fi
fi

# --- Detect E2E framework ---
E2E_FRAMEWORK="none"
if [[ -f "$PROJECT_ROOT/playwright.config.ts" || -f "$PROJECT_ROOT/playwright.config.js" ]]; then
  E2E_FRAMEWORK="playwright"
elif [[ -d "$PROJECT_ROOT/cypress" || -f "$PROJECT_ROOT/cypress.config.ts" || -f "$PROJECT_ROOT/cypress.config.js" ]]; then
  E2E_FRAMEWORK="cypress"
fi

# --- Find untested modules ---
UNTESTED="[]"
if [[ -n "$SOURCE_FILES" ]]; then
  while IFS= read -r src_file; do
    [[ -z "$src_file" ]] && continue

    # Derive expected test file name
    BASENAME=$(basename "$src_file" | sed 's/\.\(ts\|tsx\|js\|jsx\)$//')
    DIRNAME=$(dirname "$src_file")
    REL_PATH="${src_file#$PROJECT_ROOT/}"

    # Check for test file variants
    HAS_TEST=false
    for ext in "test.ts" "test.tsx" "test.js" "test.jsx" "spec.ts" "spec.tsx" "spec.js" "spec.jsx"; do
      # Check same directory
      if [[ -f "$DIRNAME/$BASENAME.$ext" ]]; then
        HAS_TEST=true
        break
      fi
      # Check __tests__ subdirectory
      if [[ -f "$DIRNAME/__tests__/$BASENAME.$ext" ]]; then
        HAS_TEST=true
        break
      fi
    done

    # Check project-level test directories
    if [[ "$HAS_TEST" == "false" ]]; then
      for test_dir in "tests" "__tests__" "test"; do
        for ext in "test.ts" "test.tsx" "spec.ts" "spec.tsx"; do
          if [[ -f "$PROJECT_ROOT/$test_dir/$BASENAME.$ext" ]]; then
            HAS_TEST=true
            break 2
          fi
        done
      done
    fi

    if [[ "$HAS_TEST" == "false" ]]; then
      UNTESTED=$(echo "$UNTESTED" | jq --arg f "$REL_PATH" '. + [$f]')
    fi
  done <<< "$SOURCE_FILES"
fi

UNTESTED_COUNT=$(echo "$UNTESTED" | jq 'length')

# --- Calculate coverage estimate ---
COVERAGE_ESTIMATE="null"
if [[ "$SOURCE_COUNT" -gt 0 ]]; then
  TESTED_COUNT=$((SOURCE_COUNT - UNTESTED_COUNT))
  COVERAGE_ESTIMATE=$(echo "$TESTED_COUNT $SOURCE_COUNT" | awk '{printf "%.1f", ($1 / $2) * 100}')
fi

# --- Check for CI test integration ---
CI_TESTS="false"
if [[ -d "$PROJECT_ROOT/.github/workflows" ]]; then
  if grep -rlq "test" "$PROJECT_ROOT/.github/workflows/" 2>/dev/null; then
    CI_TESTS="true"
  fi
elif [[ -f "$PROJECT_ROOT/.gitlab-ci.yml" ]]; then
  if grep -q "test" "$PROJECT_ROOT/.gitlab-ci.yml" 2>/dev/null; then
    CI_TESTS="true"
  fi
fi

# --- Check for coverage config ---
HAS_COVERAGE_CONFIG="false"
if [[ -f "$PROJECT_ROOT/.nycrc" || -f "$PROJECT_ROOT/.nycrc.json" || -f "$PROJECT_ROOT/.c8rc" ]]; then
  HAS_COVERAGE_CONFIG="true"
fi
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  HAS_C8=$(jq -r '.devDependencies.c8 // .devDependencies["@vitest/coverage-v8"] // .devDependencies["@vitest/coverage-istanbul"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
  if [[ -n "$HAS_C8" ]]; then
    HAS_COVERAGE_CONFIG="true"
  fi
fi

# --- Output JSON ---
jq -n \
  --argjson src_count "$SOURCE_COUNT" \
  --argjson test_count "$TEST_COUNT" \
  --argjson untested "$UNTESTED" \
  --argjson untested_count "$UNTESTED_COUNT" \
  --argjson coverage "${COVERAGE_ESTIMATE:-null}" \
  --arg test_fw "$TEST_FRAMEWORK" \
  --arg e2e_fw "$E2E_FRAMEWORK" \
  --arg ci_tests "$CI_TESTS" \
  --arg cov_config "$HAS_COVERAGE_CONFIG" \
  '{
    source_file_count: $src_count,
    test_file_count: $test_count,
    untested_modules: ($untested | .[:20]),
    untested_count: $untested_count,
    coverage_estimate_percent: $coverage,
    test_framework: $test_fw,
    e2e_framework: $e2e_fw,
    ci_integration: (if $ci_tests == "true" then true else false end),
    coverage_config: (if $cov_config == "true" then true else false end)
  }'

exit 0
