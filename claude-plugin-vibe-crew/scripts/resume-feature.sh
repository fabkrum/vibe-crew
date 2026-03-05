#!/usr/bin/env bash
# scripts/resume-feature.sh
# Resumes a paused feature: restores state, recreates worktree if needed.
# Usage: resume-feature.sh [feature-id]
# If no feature-id, resumes the most recently paused feature.
# Exit 0 on success, 1 on error.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
HANDOFFS_DIR="$VIBECREW_DIR/handoffs"

REQUESTED_ID="${1:-}"

# --- Validate state ---
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"error": "No state.json found", "resumed": false}'
  exit 1
fi

# Check if there's already an active feature
ACTIVE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
if [[ -n "$ACTIVE_ID" && "$ACTIVE_ID" != "null" ]]; then
  echo "{\"error\": \"Feature '${ACTIVE_ID}' is already active. Pause it first.\", \"resumed\": false}"
  exit 1
fi

# --- Find paused feature ---
PAUSED_ID=$(jq -r '.paused_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")

if [[ -z "$PAUSED_ID" || "$PAUSED_ID" == "null" ]]; then
  echo '{"error": "No paused feature found in state.json", "resumed": false}'
  exit 1
fi

# If a specific ID was requested, verify it matches
if [[ -n "$REQUESTED_ID" && "$REQUESTED_ID" != "$PAUSED_ID" ]]; then
  echo "{\"error\": \"Requested feature '${REQUESTED_ID}' does not match paused feature '${PAUSED_ID}'\", \"resumed\": false}"
  exit 1
fi

# --- Read paused feature data ---
FEATURE_NAME=$(jq -r '.paused_feature.name // empty' "$STATE_FILE")
PHASE=$(jq -r '.paused_feature.phase // empty' "$STATE_FILE")
BRANCH=$(jq -r '.paused_feature.branch // empty' "$STATE_FILE")
COMMIT=$(jq -r '.paused_feature.commit // empty' "$STATE_FILE")
WORKTREE_PATH=$(jq -r '.paused_feature.worktree // empty' "$STATE_FILE")
PHASES_COMPLETED=$(jq -c '.paused_feature.phases_completed // []' "$STATE_FILE")
PLAN_REVISION=$(jq -r '.paused_feature.plan_revision_count // 0' "$STATE_FILE")
PLAN_SHA=$(jq -c '.paused_feature.plan_commit_sha // null' "$STATE_FILE")

# --- Checkout the feature branch ---
WORKTREE_CREATED=false
if [[ -n "$BRANCH" && "$BRANCH" != "null" ]]; then
  # Check if branch exists
  if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
    # If a worktree path was specified and doesn't exist, recreate it
    if [[ -n "$WORKTREE_PATH" && "$WORKTREE_PATH" != "null" && ! -d "$WORKTREE_PATH" ]]; then
      mkdir -p "$(dirname "$WORKTREE_PATH")"
      git worktree add "$WORKTREE_PATH" "$BRANCH" 2>/dev/null || true
      WORKTREE_CREATED=true
    fi
  fi
fi

# --- Restore state.json ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_STATE=$(mktemp)
jq --arg fid "$PAUSED_ID" \
   --arg fname "$FEATURE_NAME" \
   --arg phase "$PHASE" \
   --arg worktree "${WORKTREE_PATH:-}" \
   --argjson phases "$PHASES_COMPLETED" \
   --argjson plan_rev "$PLAN_REVISION" \
   --argjson plan_sha "$PLAN_SHA" \
   --arg ts "$TIMESTAMP" \
   '
   .active_feature = {
     id: $fid,
     name: $fname,
     worktree: (if $worktree == "" then null else $worktree end),
     phase: $phase,
     phases_completed: $phases,
     plan_revision_count: $plan_rev,
     plan_commit_sha: $plan_sha
   } |
   del(.paused_feature) |
   .updated_at = $ts
   ' "$STATE_FILE" > "$TMP_STATE" && mv "$TMP_STATE" "$STATE_FILE"

# --- Clean up pause handoff (mark as consumed) ---
HANDOFF_FILE="$HANDOFFS_DIR/pause-${PAUSED_ID}.md"
if [[ -f "$HANDOFF_FILE" ]]; then
  mv "$HANDOFF_FILE" "${HANDOFF_FILE%.md}.resumed.md" 2>/dev/null || true
fi

# --- Output ---
cat <<EOF
{
  "resumed": true,
  "feature_id": "${PAUSED_ID}",
  "feature_name": "${FEATURE_NAME}",
  "phase": "${PHASE}",
  "branch": "${BRANCH}",
  "worktree_created": ${WORKTREE_CREATED},
  "handoff_file": "${HANDOFF_FILE}"
}
EOF

exit 0
