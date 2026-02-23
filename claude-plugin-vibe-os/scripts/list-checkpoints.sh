#!/usr/bin/env bash
# scripts/list-checkpoints.sh
# Lists all VibeOS checkpoint tags and recent git commits.
# Used by /undo to present available rollback targets.
# Usage: list-checkpoints.sh
# Output: JSON object with "checkpoints" and "recent_commits" arrays

set -euo pipefail

# --- Collect VibeOS checkpoint tags ---
CHECKPOINTS="[]"
while IFS= read -r tag; do
  [[ -z "$tag" ]] && continue
  HASH="$(git rev-list -1 "$tag" 2>/dev/null || echo "")"
  [[ -z "$HASH" ]] && continue
  SHORT_HASH="${HASH:0:7}"
  SUBJECT="$(git log -1 --format='%s' "$HASH" 2>/dev/null || echo "")"
  DATE="$(git log -1 --format='%aI' "$HASH" 2>/dev/null || echo "")"
  TAG_MESSAGE="$(git tag -l --format='%(contents)' "$tag" 2>/dev/null || echo "")"
  CHECKPOINTS="$(echo "$CHECKPOINTS" | jq \
    --arg tag "$tag" \
    --arg hash "$SHORT_HASH" \
    --arg full_hash "$HASH" \
    --arg subject "$SUBJECT" \
    --arg date "$DATE" \
    --arg message "$TAG_MESSAGE" \
    '. + [{"tag": $tag, "hash": $hash, "full_hash": $full_hash, "subject": $subject, "date": $date, "message": $message}]'
  )"
done < <(git tag -l 'vibeos-checkpoint-*' --sort=-creatordate 2>/dev/null)

# --- Collect 10 most recent commits ---
RECENT="[]"
while IFS=$'\t' read -r hash subject date; do
  [[ -z "$hash" ]] && continue
  SHORT_HASH="${hash:0:7}"
  RECENT="$(echo "$RECENT" | jq \
    --arg hash "$SHORT_HASH" \
    --arg full_hash "$hash" \
    --arg subject "$subject" \
    --arg date "$date" \
    '. + [{"hash": $hash, "full_hash": $full_hash, "subject": $subject, "date": $date}]'
  )"
done < <(git log -10 --format='%H%x09%s%x09%aI' 2>/dev/null)

# --- Output combined JSON ---
jq -n \
  --argjson checkpoints "$CHECKPOINTS" \
  --argjson recent_commits "$RECENT" \
  '{"checkpoints": $checkpoints, "recent_commits": $recent_commits}'

exit 0
