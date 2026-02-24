#!/usr/bin/env bash
# scripts/detect-perf-baselines.sh
# Checks .vibecrew/perf-tests/ for performance test results matching the active feature.
# Used by calculate-vibe-score.sh and /wrap.
# Usage: detect-perf-baselines.sh [project_root]
# Output: JSON object to stdout

set -euo pipefail

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
PERF_DIR="$PROJECT_ROOT/.vibecrew/perf-tests"

BASELINES_EXIST=false
TEST_TYPES="[]"

if [[ -f "$STATE_FILE" && -d "$PERF_DIR" ]]; then
  # Get active feature ID
  FEATURE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")

  if [[ -n "$FEATURE_ID" ]]; then
    # Find perf test results for this feature
    PERF_FILES=$(ls -1 "$PERF_DIR"/perf-"${FEATURE_ID}"-*.json 2>/dev/null || true)

    if [[ -n "$PERF_FILES" ]]; then
      BASELINES_EXIST=true
      # Extract unique test types from all matching result files
      TEST_TYPES=$(echo "$PERF_FILES" | while read -r f; do
        jq -r '.test_type // empty' "$f" 2>/dev/null
      done | sort -u | jq -Rc '[., inputs]')
    fi
  else
    # No active feature — check for any perf results
    ANY_RESULTS=$(ls -1 "$PERF_DIR"/*.json 2>/dev/null | head -1)
    if [[ -n "$ANY_RESULTS" ]]; then
      BASELINES_EXIST=true
      TEST_TYPES=$(ls -1 "$PERF_DIR"/*.json 2>/dev/null | while read -r f; do
        jq -r '.test_type // empty' "$f" 2>/dev/null
      done | sort -u | jq -Rc '[., inputs]')
    fi
  fi
fi

jq -n \
  --argjson baselines_exist "$BASELINES_EXIST" \
  --argjson test_types "$TEST_TYPES" \
  '{
    baselines_exist: $baselines_exist,
    test_types: $test_types
  }'
