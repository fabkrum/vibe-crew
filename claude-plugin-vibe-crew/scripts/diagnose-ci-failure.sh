#!/usr/bin/env bash
# scripts/diagnose-ci-failure.sh
# Pattern-match CI error logs to categorize and extract relevant lines.
# Reads CI log from stdin or first argument (file path).
# Outputs JSON diagnosis.
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

# Read log input from file argument or stdin
if [ $# -ge 1 ] && [ -f "$1" ]; then
  LOG_CONTENT=$(cat "$1")
elif [ ! -t 0 ]; then
  LOG_CONTENT=$(cat)
else
  echo '{"category": "unknown", "confidence": "low", "match_counts": {}, "relevant_lines": [], "summary": "No log input provided."}'
  exit 0
fi

# Bail out if log is empty
if [ -z "$LOG_CONTENT" ]; then
  echo '{"category": "unknown", "confidence": "low", "match_counts": {}, "relevant_lines": [], "summary": "Empty log input."}'
  exit 0
fi

# Count matches for each failure category
COUNT_BUILD=$(echo "$LOG_CONTENT" | grep -ciE "error TS[0-9]|SyntaxError|Cannot find module|Module not found|Build failed|tsc.*error|Type error|TypeError|ReferenceError" 2>/dev/null || echo "0")
COUNT_TEST=$(echo "$LOG_CONTENT" | grep -ciE "FAIL[^U]|AssertionError|AssertionError|Expected.*received|test failed|Tests:.*failed|FAILED|jest.*fail|vitest.*fail|✗|✕|assert\." 2>/dev/null || echo "0")
COUNT_LINT=$(echo "$LOG_CONTENT" | grep -ciE "eslint|prettier|Lint error|style error|lint.*warning|lint.*error|formatting" 2>/dev/null || echo "0")
COUNT_DEP=$(echo "$LOG_CONTENT" | grep -ciE "npm ERR|Could not resolve|peer dep|ERESOLVE|ModuleNotFoundError|No matching version|ENOENT.*node_modules|package.*not found|yarn error" 2>/dev/null || echo "0")
COUNT_ENV=$(echo "$LOG_CONTENT" | grep -ciE "ENOENT|env:.*not found|command not found|Permission denied|ENOMEM|EACCES|No such file or directory|\.nvmrc|engines.*node" 2>/dev/null || echo "0")

# Trim whitespace from counts
COUNT_BUILD=$(echo "$COUNT_BUILD" | tr -d '[:space:]')
COUNT_TEST=$(echo "$COUNT_TEST" | tr -d '[:space:]')
COUNT_LINT=$(echo "$COUNT_LINT" | tr -d '[:space:]')
COUNT_DEP=$(echo "$COUNT_DEP" | tr -d '[:space:]')
COUNT_ENV=$(echo "$COUNT_ENV" | tr -d '[:space:]')

# Ensure counts are valid integers (default to 0)
COUNT_BUILD=${COUNT_BUILD:-0}
COUNT_TEST=${COUNT_TEST:-0}
COUNT_LINT=${COUNT_LINT:-0}
COUNT_DEP=${COUNT_DEP:-0}
COUNT_ENV=${COUNT_ENV:-0}

# Determine primary category (highest match count)
MAX_COUNT=0
PRIMARY="unknown"

if [ "$COUNT_BUILD" -gt "$MAX_COUNT" ]; then
  MAX_COUNT=$COUNT_BUILD
  PRIMARY="build"
fi
if [ "$COUNT_TEST" -gt "$MAX_COUNT" ]; then
  MAX_COUNT=$COUNT_TEST
  PRIMARY="test"
fi
if [ "$COUNT_LINT" -gt "$MAX_COUNT" ]; then
  MAX_COUNT=$COUNT_LINT
  PRIMARY="lint"
fi
if [ "$COUNT_DEP" -gt "$MAX_COUNT" ]; then
  MAX_COUNT=$COUNT_DEP
  PRIMARY="dep"
fi
if [ "$COUNT_ENV" -gt "$MAX_COUNT" ]; then
  MAX_COUNT=$COUNT_ENV
  PRIMARY="env"
fi

# Determine confidence based on match count and separation from runner-up
TOTAL=$((COUNT_BUILD + COUNT_TEST + COUNT_LINT + COUNT_DEP + COUNT_ENV))
if [ "$TOTAL" -eq 0 ]; then
  CONFIDENCE="low"
  PRIMARY="unknown"
elif [ "$MAX_COUNT" -ge 10 ]; then
  CONFIDENCE="high"
elif [ "$MAX_COUNT" -ge 3 ]; then
  CONFIDENCE="medium"
else
  CONFIDENCE="low"
fi

# Extract the 20 most relevant error lines (lines matching error patterns)
RELEVANT_LINES=$(echo "$LOG_CONTENT" | grep -iE \
  "error|Error|ERROR|fail|FAIL|FAILED|warning|cannot|not found|missing|denied|invalid|unexpected|refused|timeout|exception|panic|fatal|abort" \
  2>/dev/null | head -20 || echo "")

# Generate a one-line summary based on the primary category
case "$PRIMARY" in
  build)
    SUMMARY="Build failure detected — likely type errors, missing imports, or syntax issues."
    ;;
  test)
    SUMMARY="Test failure detected — likely failing assertions or snapshot mismatches."
    ;;
  lint)
    SUMMARY="Lint failure detected — likely ESLint or Prettier violations."
    ;;
  dep)
    SUMMARY="Dependency failure detected — likely missing or incompatible packages."
    ;;
  env)
    SUMMARY="Environment failure detected — likely missing commands, env vars, or permissions."
    ;;
  *)
    SUMMARY="Unable to confidently categorize the failure. Manual review recommended."
    ;;
esac

# Build the JSON output using jq for proper escaping
RELEVANT_JSON=$(echo "$RELEVANT_LINES" | jq -R -s 'split("\n") | map(select(length > 0))')

jq -n \
  --arg category "$PRIMARY" \
  --arg confidence "$CONFIDENCE" \
  --argjson count_build "$COUNT_BUILD" \
  --argjson count_test "$COUNT_TEST" \
  --argjson count_lint "$COUNT_LINT" \
  --argjson count_dep "$COUNT_DEP" \
  --argjson count_env "$COUNT_ENV" \
  --argjson relevant_lines "$RELEVANT_JSON" \
  --arg summary "$SUMMARY" \
  '{
    category: $category,
    confidence: $confidence,
    match_counts: {
      build: $count_build,
      test: $count_test,
      lint: $count_lint,
      dep: $count_dep,
      env: $count_env
    },
    relevant_lines: $relevant_lines,
    summary: $summary
  }'

exit 0
