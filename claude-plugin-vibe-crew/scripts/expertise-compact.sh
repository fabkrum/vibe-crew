#!/usr/bin/env bash
# scripts/expertise-compact.sh
# Tier-based pruning + dedup + 500-record cap enforcement per domain.
# Called by /wrap after Performance Coach.
# Usage: expertise-compact.sh [--session-count <N>]
# Output: Summary of pruning actions
# Exit 0 on success

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set PROJECT_ROOT before sourcing lock.sh so it resolves correctly
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export PROJECT_ROOT

source "$SCRIPT_DIR/lib/lock.sh"

EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"

# --- Parse arguments ---
SESSION_COUNT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-count) SESSION_COUNT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# Auto-detect session count from scores directory
if [[ -z "$SESSION_COUNT" ]]; then
  SESSION_COUNT=$(find "$PROJECT_ROOT/.vibecrew/scores" -maxdepth 1 -name 'score-*.json' 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ ! -d "$EXPERTISE_DIR" ]]; then
  echo "No expertise directory found. Nothing to compact."
  exit 0
fi

# Check if any JSONL files exist
JSONL_FILES=()
for f in "$EXPERTISE_DIR"/*.jsonl; do
  [[ -f "$f" ]] && JSONL_FILES+=("$f")
done

if [[ ${#JSONL_FILES[@]} -eq 0 ]]; then
  echo "Expertise compact: deprecated=0 deduped=0 capped=0"
  exit 0
fi

CAP_PER_DOMAIN=500
TOTAL_DEPRECATED=0
TOTAL_DEDUPED=0
TOTAL_CAPPED=0

# --- Get list of done features for tactical expiry ---
DONE_FEATURES="[]"
if [[ -f "$BACKLOG_FILE" ]]; then
  DONE_FEATURES=$(jq -c '[.features[] | select(.column == "done") | .id]' "$BACKLOG_FILE" 2>/dev/null || echo "[]")
fi

# Cross-platform hash function
_content_hash() {
  if command -v md5sum &>/dev/null; then
    echo "$1" | md5sum | cut -d' ' -f1
  elif command -v md5 &>/dev/null; then
    echo "$1" | md5
  else
    # Fallback: use first 64 chars as "hash"
    echo "${1:0:64}"
  fi
}

for JSONL_FILE in "${JSONL_FILES[@]}"; do
  DOMAIN=$(basename "$JSONL_FILE" .jsonl)
  acquire_named_lock "expertise-${DOMAIN}" "expertise-compact"

  TMP="${JSONL_FILE}.tmp.$$"
  DEPRECATED_COUNT=0
  DEDUP_COUNT=0

  # Pass 1: Apply tier-based deprecation rules
  RECORDS=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    IS_DEPRECATED=$(echo "$line" | jq -r '.deprecated // false' 2>/dev/null || echo "false")
    if [[ "$IS_DEPRECATED" == "true" ]]; then
      RECORDS+=("$line")
      continue
    fi

    TIER=$(echo "$line" | jq -r '.tier' 2>/dev/null || echo "")
    ACCESS_COUNT=$(echo "$line" | jq -r '.access_count // 0' 2>/dev/null || echo "0")

    SHOULD_DEPRECATE=false

    # Observational: expires after 10 sessions
    if [[ "$TIER" == "observational" && "$SESSION_COUNT" -gt 10 ]]; then
      CREATED=$(echo "$line" | jq -r '.created_at' 2>/dev/null || echo "")
      if [[ -n "$CREATED" ]]; then
        SCORES_AFTER=$(find "$PROJECT_ROOT/.vibecrew/scores" -maxdepth 1 -name 'score-*.json' 2>/dev/null | while read -r sf; do
          SF_TS=$(jq -r '.timestamp // ""' "$sf" 2>/dev/null || echo "")
          [[ -n "$SF_TS" && "$SF_TS" > "$CREATED" ]] && echo "$sf"
        done | wc -l | tr -d ' ')
        if [[ "$SCORES_AFTER" -ge 10 ]]; then
          SHOULD_DEPRECATE=true
        fi
      fi
    fi

    # Tactical: expires 5 sessions after feature reaches done
    if [[ "$TIER" == "tactical" ]]; then
      FEATURE_ID=$(echo "$line" | jq -r '.feature_id // ""' 2>/dev/null || echo "")
      if [[ -n "$FEATURE_ID" && "$FEATURE_ID" != "null" ]]; then
        IS_DONE=$(echo "$DONE_FEATURES" | jq --arg fid "$FEATURE_ID" 'index($fid) != null' 2>/dev/null || echo "false")
        if [[ "$IS_DONE" == "true" ]]; then
          FEATURE_DONE_AT=$(jq -r --arg fid "$FEATURE_ID" '.features[] | select(.id == $fid) | .updated_at // ""' "$BACKLOG_FILE" 2>/dev/null || echo "")
          if [[ -n "$FEATURE_DONE_AT" ]]; then
            SCORES_AFTER=$(find "$PROJECT_ROOT/.vibecrew/scores" -maxdepth 1 -name 'score-*.json' 2>/dev/null | while read -r sf; do
              SF_TS=$(jq -r '.timestamp // ""' "$sf" 2>/dev/null || echo "")
              [[ -n "$SF_TS" && "$SF_TS" > "$FEATURE_DONE_AT" ]] && echo "$sf"
            done | wc -l | tr -d ' ')
            if [[ "$SCORES_AFTER" -ge 5 ]]; then
              SHOULD_DEPRECATE=true
            fi
          fi
        fi
      fi
    fi

    # Access-based: 0 accesses after 20 sessions → deprecated
    if [[ "$ACCESS_COUNT" -eq 0 && "$SESSION_COUNT" -ge 20 ]]; then
      SHOULD_DEPRECATE=true
    fi

    if [[ "$SHOULD_DEPRECATE" == "true" ]]; then
      line=$(echo "$line" | jq -c '.deprecated = true | .deprecation_reason = "auto-pruned by compact"')
      DEPRECATED_COUNT=$((DEPRECATED_COUNT + 1))
    fi

    RECORDS+=("$line")
  done < "$JSONL_FILE"

  # Pass 2: Dedup by content (keep first occurrence — highest confidence if pre-sorted)
  SEEN_CONTENTS=()
  DEDUPED_RECORDS=()

  for record in "${RECORDS[@]+"${RECORDS[@]}"}"; do
    [[ -z "$record" ]] && continue
    CONTENT=$(echo "$record" | jq -r '.content' 2>/dev/null || echo "")
    CONTENT_HASH=$(_content_hash "$CONTENT")

    DUP=false
    for seen in "${SEEN_CONTENTS[@]+"${SEEN_CONTENTS[@]}"}"; do
      if [[ "$seen" == "$CONTENT_HASH" ]]; then
        DUP=true
        DEDUP_COUNT=$((DEDUP_COUNT + 1))
        break
      fi
    done

    if [[ "$DUP" == "false" ]]; then
      SEEN_CONTENTS+=("$CONTENT_HASH")
      DEDUPED_RECORDS+=("$record")
    fi
  done

  # Pass 3: Cap enforcement (500 per domain)
  CAPPED_COUNT=0
  RECORD_COUNT=${#DEDUPED_RECORDS[@]}

  if [[ "$RECORD_COUNT" -gt "$CAP_PER_DOMAIN" ]]; then
    printf '%s\n' "${DEDUPED_RECORDS[@]}" | jq -c '.' | jq -s '
      sort_by(
        (if .deprecated then 1 else 0 end),
        (if .tier == "foundational" then 0 elif .tier == "tactical" then 1 else 2 end),
        -.confidence
      ) | .[:'"$CAP_PER_DOMAIN"']
    ' 2>/dev/null | jq -c '.[]' > "$TMP"
    CAPPED_COUNT=$((RECORD_COUNT - CAP_PER_DOMAIN))
  else
    printf '%s\n' "${DEDUPED_RECORDS[@]}" > "$TMP"
  fi

  mv "$TMP" "$JSONL_FILE"
  release_named_lock "expertise-${DOMAIN}"

  TOTAL_DEPRECATED=$((TOTAL_DEPRECATED + DEPRECATED_COUNT))
  TOTAL_DEDUPED=$((TOTAL_DEDUPED + DEDUP_COUNT))
  TOTAL_CAPPED=$((TOTAL_CAPPED + CAPPED_COUNT))

  if [[ $((DEPRECATED_COUNT + DEDUP_COUNT + CAPPED_COUNT)) -gt 0 ]]; then
    echo "$DOMAIN: deprecated=$DEPRECATED_COUNT deduped=$DEDUP_COUNT capped=$CAPPED_COUNT"
  fi
done

echo "Expertise compact: deprecated=$TOTAL_DEPRECATED deduped=$TOTAL_DEDUPED capped=$TOTAL_CAPPED"
exit 0
