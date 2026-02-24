#!/usr/bin/env bash
# scripts/rollback-checkpoint.sh
# Rolls back to a target commit using either revert or reset mode.
# Used by /undo to execute the user-confirmed rollback.
# Usage: rollback-checkpoint.sh <target-hash> <mode>
#   mode: "revert" — creates a new commit reversing changes (safe for pushed commits)
#         "reset"  — moves HEAD back with --soft (safe for unpushed commits)
# Output: JSON object with result details

set -euo pipefail

# --- Validate arguments ---
if [[ $# -lt 2 ]]; then
  echo '{"error": true, "message": "Usage: rollback-checkpoint.sh <target-hash> <mode>"}' >&2
  exit 0
fi

TARGET="$1"
MODE="$2"

# --- Validate target commit exists ---
if ! git cat-file -t "$TARGET" 2>/dev/null | grep -q "commit\|tag"; then
  # Try resolving as a short hash or tag
  RESOLVED="$(git rev-parse "$TARGET" 2>/dev/null || echo "")"
  if [[ -z "$RESOLVED" ]]; then
    jq -n --arg target "$TARGET" \
      '{"error": true, "message": ("Target commit not found: " + $target)}'
    exit 0
  fi
  TARGET="$RESOLVED"
fi

# --- Validate mode ---
if [[ "$MODE" != "revert" && "$MODE" != "reset" ]]; then
  jq -n --arg mode "$MODE" \
    '{"error": true, "message": ("Invalid mode: " + $mode + ". Must be revert or reset.")}'
  exit 0
fi

# --- Execute rollback ---
if [[ "$MODE" == "revert" ]]; then
  # Revert creates a new commit that undoes changes between target and HEAD
  BEFORE_HEAD="$(git rev-parse HEAD 2>/dev/null)"
  if git revert --no-commit "${TARGET}..HEAD" 2>/dev/null; then
    git commit -m "revert: rollback to $(echo "$TARGET" | cut -c1-7)" 2>/dev/null || true
    AFTER_HEAD="$(git rev-parse HEAD 2>/dev/null)"
    AFTER_SUBJECT="$(git log -1 --format='%s' 2>/dev/null || echo "")"
    jq -n \
      --arg mode "revert" \
      --arg target "$TARGET" \
      --arg before_head "$BEFORE_HEAD" \
      --arg after_head "$AFTER_HEAD" \
      --arg after_subject "$AFTER_SUBJECT" \
      '{"error": false, "mode": $mode, "target": $target, "before_head": $before_head, "after_head": $after_head, "after_subject": $after_subject}'
  else
    # Revert failed — abort and report
    git revert --abort 2>/dev/null || true
    jq -n --arg target "$TARGET" \
      '{"error": true, "message": ("Revert failed. There may be conflicts. Reverted changes have been aborted. Target: " + $target)}'
  fi

elif [[ "$MODE" == "reset" ]]; then
  # Soft reset moves HEAD back but keeps all changes staged
  BEFORE_HEAD="$(git rev-parse HEAD 2>/dev/null)"
  if git reset --soft "$TARGET" 2>/dev/null; then
    AFTER_HEAD="$(git rev-parse HEAD 2>/dev/null)"
    AFTER_SUBJECT="$(git log -1 --format='%s' 2>/dev/null || echo "")"
    jq -n \
      --arg mode "reset" \
      --arg target "$TARGET" \
      --arg before_head "$BEFORE_HEAD" \
      --arg after_head "$AFTER_HEAD" \
      --arg after_subject "$AFTER_SUBJECT" \
      '{"error": false, "mode": $mode, "target": $target, "before_head": $before_head, "after_head": $after_head, "after_subject": $after_subject}'
  else
    jq -n --arg target "$TARGET" \
      '{"error": true, "message": ("Reset failed. Target: " + $target)}'
  fi
fi

exit 0
