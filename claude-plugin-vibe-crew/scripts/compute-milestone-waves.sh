#!/usr/bin/env bash
# scripts/compute-milestone-waves.sh
# Reads milestones from backlog.json for a feature, performs topological sort
# into dependency waves via jq + bash arrays.
# Usage: compute-milestone-waves.sh <feature-id>
# Output: JSON with wave groupings
# Exit 0 on success, Exit 1 on cycle detection or error

set -euo pipefail

FEATURE_ID="${1:-}"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"

if [[ -z "$FEATURE_ID" ]]; then
  echo '{"error": "Usage: compute-milestone-waves.sh <feature-id>"}' >&2
  exit 1
fi

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo '{"error": "backlog.json not found"}' >&2
  exit 1
fi

# Extract milestones for this feature
MILESTONES=$(jq --arg id "$FEATURE_ID" '
  .features[] | select(.id == $id) | .spec.milestones // []
' "$BACKLOG_FILE" 2>/dev/null || echo "[]")

MILESTONE_COUNT=$(echo "$MILESTONES" | jq 'length')

if [[ "$MILESTONE_COUNT" -eq 0 ]]; then
  echo '{"waves": [], "sequential": true, "reason": "no milestones"}'
  exit 0
fi

# Safety check: if >3 milestones lack explicit depends_on, fall back to sequential
MISSING_DEPS=$(echo "$MILESTONES" | jq '[.[] | select(.depends_on == null or (.depends_on | length == 0))] | length')
if [[ "$MISSING_DEPS" -gt 3 ]]; then
  # Build sequential waves (one milestone per wave)
  WAVES=$(echo "$MILESTONES" | jq '[.[] | [.name]] ')
  echo "$WAVES" | jq '{waves: ., sequential: true, reason: "too many milestones without explicit depends_on (>3), falling back to sequential"}'
  exit 0
fi

# Topological sort into waves using jq
# Wave 0: milestones with no dependencies (or empty depends_on)
# Wave N: milestones whose dependencies are all in waves 0..N-1
# Note: Uses reduce instead of until due to jq-apple until() bug with array inputs
RESULT=$(echo "$MILESTONES" | jq '
  # Validate: check all depends_on references exist
  (map(.name)) as $all_names |
  (map(.depends_on // []) | flatten | unique) as $all_deps |
  ($all_deps - $all_names) as $missing |
  if ($missing | length) > 0 then
    error("Unknown dependencies: \($missing | join(", "))")
  else . end |

  # Kahn-style topological sort into waves via reduce
  {waves: [], remaining: [.[].name], deps: (map({key: .name, value: (.depends_on // [])}) | from_entries)} |
  reduce range(20) as $i (.;
    if (.remaining | length) == 0 then .
    else
      .deps as $d |
      .remaining as $r |
      # Find milestones whose unresolved deps (still in remaining) are empty
      [.remaining[] | select(
        [($d[.] // [])[] | select(. as $dep | $r | any(. == $dep))] | length == 0
      )] as $wave |
      if ($wave | length) == 0 then
        .remaining = [] | .error = "Cycle detected among: \($r | join(", "))"
      else
        .waves += [$wave] |
        .remaining = [.remaining[] | select(. as $n | $wave | any(. == $n) | not)]
      end
    end
  ) |
  if .error then
    {waves: [], sequential: false, error: .error}
  else
    {waves: .waves, sequential: (.waves | all(length == 1)), milestone_count: (.waves | flatten | length)}
  end
')

# Check for cycle error
HAS_ERROR=$(echo "$RESULT" | jq 'has("error") and (.error != null)')
if [[ "$HAS_ERROR" == "true" ]]; then
  echo "$RESULT" >&2
  exit 1
fi

echo "$RESULT"
exit 0
