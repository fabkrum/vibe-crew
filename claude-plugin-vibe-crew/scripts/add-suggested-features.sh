#!/usr/bin/env bash
# scripts/add-suggested-features.sh
# Add features from competitive analysis to backlog.json with status 'suggested'.
# Usage: add-suggested-features.sh '<json-array>'
# Input: JSON array of features, e.g.:
#   [{"name": "Dark mode", "description": "...", "priority": "differentiator"}]
# Each feature gets: column="idea", source="competitive-analysis", labels=["competitive-analysis"]
# Deduplicates by name (case-insensitive).
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Read features JSON from argument or stdin
if [[ $# -gt 0 ]]; then
  FEATURES_JSON="$1"
else
  FEATURES_JSON=$(cat)
fi

# Validate input is valid JSON array
if ! echo "$FEATURES_JSON" | jq -e 'type == "array"' >/dev/null 2>&1; then
  jq -n '{"error": "Input must be a JSON array of features.", "status": "error"}'
  exit 0
fi

FEATURE_COUNT=$(echo "$FEATURES_JSON" | jq 'length')
if [[ "$FEATURE_COUNT" -eq 0 ]]; then
  jq -n '{"status": "skipped", "message": "No features to add.", "added": 0, "skipped": 0}'
  exit 0
fi

# Check backlog exists
if [[ ! -f "$BACKLOG_FILE" ]]; then
  jq -n '{"error": "backlog.json not found. Run /setup first.", "status": "error"}'
  exit 0
fi

# Get next feature ID
LAST_ID=$(jq -r '[.features[].id] | map(ltrimstr("feat-") | tonumber) | max // 0' "$BACKLOG_FILE" 2>/dev/null || echo "0")
NEXT_NUM=$((LAST_ID + 1))

# Read existing feature names for deduplication (lowercase)
EXISTING_NAMES=$(jq -r '[.features[].name | ascii_downcase] | .[]' "$BACKLOG_FILE" 2>/dev/null || echo "")

ADDED=0
SKIPPED=0
ADDED_IDS="[]"

# Process each feature
for i in $(seq 0 $((FEATURE_COUNT - 1))); do
  FEAT_NAME=$(echo "$FEATURES_JSON" | jq -r ".[$i].name // empty")
  FEAT_DESC=$(echo "$FEATURES_JSON" | jq -r ".[$i].description // \"\"")
  FEAT_PRIORITY=$(echo "$FEATURES_JSON" | jq -r ".[$i].priority // \"nice-to-have\"")

  if [[ -z "$FEAT_NAME" ]]; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Deduplicate by name (case-insensitive)
  FEAT_NAME_LOWER=$(echo "$FEAT_NAME" | tr '[:upper:]' '[:lower:]')
  if echo "$EXISTING_NAMES" | grep -qxF "$FEAT_NAME_LOWER" 2>/dev/null; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Map priority string to numeric priority
  case "$FEAT_PRIORITY" in
    must-have) PRIORITY_NUM=1 ;;
    differentiator) PRIORITY_NUM=2 ;;
    nice-to-have) PRIORITY_NUM=3 ;;
    *) PRIORITY_NUM=3 ;;
  esac

  FEATURE_ID=$(printf "feat-%03d" "$NEXT_NUM")
  NEXT_NUM=$((NEXT_NUM + 1))

  # Build and add feature entry using update-backlog-raw.sh
  ENTRY=$(jq -n \
    --arg id "$FEATURE_ID" \
    --arg name "$FEAT_NAME" \
    --arg desc "$FEAT_DESC" \
    --argjson priority "$PRIORITY_NUM" \
    --arg priority_label "$FEAT_PRIORITY" \
    --arg ts "$TIMESTAMP" \
    '{
      id: $id,
      name: $name,
      description: $desc,
      column: "idea",
      priority: $priority,
      labels: ["competitive-analysis"],
      spec: {
        problem_statement: $desc,
        acceptance_criteria: [],
        ui_description: null,
        business_logic: [],
        technical_notes: ("Priority: " + $priority_label + " (from competitive analysis)")
      },
      source: "competitive-analysis",
      type: "feature",
      worktree: null,
      phases_completed: [],
      sessions: [],
      created_at: $ts,
      updated_at: $ts,
      completed_at: null
    }')

  bash "$SCRIPT_DIR/update-backlog-raw.sh" \
    '.features += [$entry]' \
    --argjson entry "$ENTRY" 2>/dev/null

  if [[ $? -eq 0 ]]; then
    ADDED=$((ADDED + 1))
    ADDED_IDS=$(echo "$ADDED_IDS" | jq --arg id "$FEATURE_ID" '. + [$id]')
    # Add to existing names for dedup within this batch
    EXISTING_NAMES="${EXISTING_NAMES}
${FEAT_NAME_LOWER}"
  else
    SKIPPED=$((SKIPPED + 1))
  fi
done

# Output summary
jq -n \
  --argjson added "$ADDED" \
  --argjson skipped "$SKIPPED" \
  --argjson added_ids "$ADDED_IDS" \
  '{
    "status": "complete",
    "added": $added,
    "skipped": $skipped,
    "feature_ids": $added_ids,
    "message": (($added | tostring) + " features added to backlog, " + ($skipped | tostring) + " skipped (duplicate or invalid)")
  }'

exit 0
