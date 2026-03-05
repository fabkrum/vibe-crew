#!/usr/bin/env bash
# scripts/pause-feature.sh
# Pauses the active feature: commits WIP, creates handoff, marks as paused,
# optionally cleans up worktree while preserving the branch.
# Usage: pause-feature.sh [--cleanup-worktree]
# Exit 0 on success, 1 on error.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
HANDOFFS_DIR="$VIBECREW_DIR/handoffs"

CLEANUP_WORKTREE=false
if [[ "${1:-}" == "--cleanup-worktree" ]]; then
  CLEANUP_WORKTREE=true
fi

# --- Validate state ---
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"error": "No state.json found", "paused": false}'
  exit 1
fi

FEATURE_ID=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
FEATURE_NAME=$(jq -r '.active_feature.name // empty' "$STATE_FILE" 2>/dev/null || echo "")
PHASE=$(jq -r '.active_feature.phase // empty' "$STATE_FILE" 2>/dev/null || echo "")
WORKTREE=$(jq -r '.active_feature.worktree // empty' "$STATE_FILE" 2>/dev/null || echo "")

if [[ -z "$FEATURE_ID" || "$FEATURE_ID" == "null" ]]; then
  echo '{"error": "No active feature to pause", "paused": false}'
  exit 1
fi

# --- Commit any uncommitted work ---
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
DIRTY=$(git status --porcelain 2>/dev/null || echo "")
WIP_COMMIT=""

if [[ -n "$DIRTY" ]]; then
  git add -A >/dev/null 2>&1 || true
  git commit -m "wip(${FEATURE_NAME}): pause checkpoint

Paused at phase: ${PHASE}
Feature: ${FEATURE_ID}" >/dev/null 2>&1 || true
  WIP_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "")
fi

CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "")

# --- Create pause handoff file ---
mkdir -p "$HANDOFFS_DIR"
HANDOFF_FILE="$HANDOFFS_DIR/pause-${FEATURE_ID}.md"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat > "$HANDOFF_FILE" <<EOF
# Pause Handoff: ${FEATURE_NAME}

## State at Pause
- **Feature**: ${FEATURE_NAME} (${FEATURE_ID})
- **Phase**: ${PHASE}
- **Branch**: ${BRANCH}
- **Commit**: ${CURRENT_COMMIT}
- **Paused at**: ${TIMESTAMP}
- **WIP commit**: ${WIP_COMMIT:-none}

## Resume Instructions
Run \`/resume\` to continue this feature. The system will:
1. Restore state.json to point to this feature
2. Recreate worktree from branch \`${BRANCH}\` (if needed)
3. Resume at the \`${PHASE}\` phase

## Context
$(git log --oneline -5 2>/dev/null || echo "No git history available")
EOF

# --- Update state.json: mark as paused ---
PHASES_COMPLETED=$(jq -c '.active_feature.phases_completed // []' "$STATE_FILE" 2>/dev/null || echo "[]")
PLAN_REVISION=$(jq -r '.active_feature.plan_revision_count // 0' "$STATE_FILE" 2>/dev/null || echo "0")
PLAN_SHA=$(jq -r '.active_feature.plan_commit_sha // null' "$STATE_FILE" 2>/dev/null || echo "null")

# Store paused feature info and clear active feature
TMP_STATE=$(mktemp)
jq --arg fid "$FEATURE_ID" \
   --arg fname "$FEATURE_NAME" \
   --arg phase "$PHASE" \
   --arg branch "$BRANCH" \
   --arg commit "$CURRENT_COMMIT" \
   --arg ts "$TIMESTAMP" \
   --arg worktree "${WORKTREE:-}" \
   --argjson phases "$PHASES_COMPLETED" \
   --argjson plan_rev "$PLAN_REVISION" \
   --argjson plan_sha "$PLAN_SHA" \
   '
   .paused_feature = {
     id: $fid,
     name: $fname,
     phase: $phase,
     branch: $branch,
     commit: $commit,
     paused_at: $ts,
     worktree: $worktree,
     phases_completed: $phases,
     plan_revision_count: $plan_rev,
     plan_commit_sha: $plan_sha
   } |
   .active_feature = {
     id: null,
     name: null,
     worktree: null,
     phase: null,
     phases_completed: [],
     plan_revision_count: 0,
     plan_commit_sha: null
   } |
   .updated_at = $ts
   ' "$STATE_FILE" > "$TMP_STATE" && mv "$TMP_STATE" "$STATE_FILE"

# --- Cleanup worktree if requested ---
WORKTREE_CLEANED=false
if [[ "$CLEANUP_WORKTREE" == "true" && -n "$WORKTREE" && "$WORKTREE" != "null" ]]; then
  if [[ -d "$WORKTREE" ]]; then
    git worktree remove "$WORKTREE" --force 2>/dev/null || true
    WORKTREE_CLEANED=true
  fi
fi

# --- Output ---
cat <<EOF
{
  "paused": true,
  "feature_id": "${FEATURE_ID}",
  "feature_name": "${FEATURE_NAME}",
  "phase": "${PHASE}",
  "branch": "${BRANCH}",
  "commit": "${CURRENT_COMMIT}",
  "handoff_file": "${HANDOFF_FILE}",
  "worktree_cleaned": ${WORKTREE_CLEANED},
  "wip_commit": "${WIP_COMMIT:-null}"
}
EOF

exit 0
