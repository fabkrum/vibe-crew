#!/usr/bin/env bash
# scripts/analyze-feature-dependencies.sh
# Analyzes backlog features and groups them into parallel execution waves.
# Features with no unmet dependencies can run in parallel within the same wave.
# Usage: analyze-feature-dependencies.sh [backlog-path]
# Outputs: JSON with waves (groups of independent features).
# Exit 0 on success, Exit 1 on error.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BACKLOG_FILE="${1:-$PROJECT_ROOT/.vibecrew/backlog.json}"

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo '{"error":"backlog.json not found"}' >&2
  exit 1
fi

# Get all planned features sorted by priority
PLANNED=$(jq -c '[.features[] | select(.column == "planned")] | sort_by(.priority)' "$BACKLOG_FILE" 2>/dev/null)
PLANNED_COUNT=$(echo "$PLANNED" | jq 'length')

if [[ "$PLANNED_COUNT" -eq 0 ]]; then
  echo '{"waves":[],"total_features":0,"parallel_possible":false}'
  exit 0
fi

# Get already-done feature IDs (dependencies already satisfied)
DONE_IDS=$(jq -c '[.features[] | select(.column == "done" or .column == "review") | .id]' "$BACKLOG_FILE" 2>/dev/null)

# Build waves iteratively in bash (simpler than jq recursion)
# A feature can be in wave N if all its dependencies are in waves 0..N-1 or already done
ASSIGNED="$DONE_IDS"
REMAINING=$(echo "$PLANNED" | jq -c '[.[].id]')
WAVES="[]"

MAX_ITER="$PLANNED_COUNT"
ITER=0

while true; do
  REMAINING_COUNT=$(echo "$REMAINING" | jq 'length')
  if [[ "$REMAINING_COUNT" -eq 0 ]]; then
    break
  fi

  ITER=$((ITER + 1))
  if [[ "$ITER" -gt "$MAX_ITER" ]]; then
    # Circular deps — add remaining as skipped
    WAVES=$(echo "$WAVES" | jq --argjson rem "$REMAINING" '. + [$rem]')
    REMAINING="[]"
    break
  fi

  # Find features in REMAINING whose deps are all in ASSIGNED
  WAVE=$(jq -nc --argjson planned "$PLANNED" --argjson assigned "$ASSIGNED" --argjson remaining "$REMAINING" '
    ($planned | map({key: .id, value: (.depends_on // [])}) | from_entries) as $dep_map |
    [$remaining[] | . as $fid |
      ($dep_map[$fid] // []) as $deps |
      if ($deps | length) == 0 then $fid
      elif ($deps | all(. as $d | $assigned | index($d) != null)) then $fid
      else empty
      end
    ]
  ')

  WAVE_COUNT=$(echo "$WAVE" | jq 'length')
  if [[ "$WAVE_COUNT" -eq 0 ]]; then
    # No progress — remaining have unresolvable deps
    WAVES=$(echo "$WAVES" | jq --argjson rem "$REMAINING" '. + [$rem]')
    REMAINING="[]"
    break
  fi

  WAVES=$(echo "$WAVES" | jq --argjson w "$WAVE" '. + [$w]')
  ASSIGNED=$(echo "$ASSIGNED" | jq --argjson w "$WAVE" '. + $w')
  REMAINING=$(echo "$REMAINING" | jq --argjson w "$WAVE" '. - $w')
done

# Build output
jq -nc --argjson waves "$WAVES" --argjson total "$PLANNED_COUNT" '
  {
    waves: $waves,
    total_features: $total,
    total_waves: ($waves | length),
    parallel_possible: ([$waves[] | select(length > 1)] | length > 0),
    max_parallelism: (if ($waves | length) > 0 then ($waves | map(length) | max) else 0 end)
  }
'

exit 0
