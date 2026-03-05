#!/usr/bin/env bash
# scripts/expertise-update.sh
# Update outcome/confidence/deprecation on an existing expertise record.
# Usage: expertise-update.sh --id <record-id> --domain <domain>
#          [--outcome <status>] [--confidence <0-1>] [--deprecated true|false]
#          [--deprecation-reason "text"] [--superseded-by <id>]
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/lock.sh"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"

# --- Parse arguments ---
RECORD_ID=""
DOMAIN=""
OUTCOME=""
CONFIDENCE=""
DEPRECATED=""
DEPRECATION_REASON=""
SUPERSEDED_BY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --id) RECORD_ID="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --outcome) OUTCOME="$2"; shift 2 ;;
    --confidence) CONFIDENCE="$2"; shift 2 ;;
    --deprecated) DEPRECATED="$2"; shift 2 ;;
    --deprecation-reason) DEPRECATION_REASON="$2"; shift 2 ;;
    --superseded-by) SUPERSEDED_BY="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$RECORD_ID" ]]; then echo "ERROR: --id is required" >&2; exit 1; fi
if [[ -z "$DOMAIN" ]]; then echo "ERROR: --domain is required" >&2; exit 1; fi

JSONL_FILE="$EXPERTISE_DIR/${DOMAIN}.jsonl"

if [[ ! -f "$JSONL_FILE" ]]; then
  echo "ERROR: Domain file not found: ${DOMAIN}.jsonl" >&2
  exit 1
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Acquire lock ---
acquire_named_lock "expertise-${DOMAIN}" "expertise-update"

# --- Update the record ---
FOUND=false
TMP="${JSONL_FILE}.tmp.$$"

while IFS= read -r line; do
  LINE_ID=$(echo "$line" | jq -r '.id' 2>/dev/null || echo "")
  if [[ "$LINE_ID" == "$RECORD_ID" ]]; then
    FOUND=true
    UPDATED="$line"

    if [[ -n "$OUTCOME" ]]; then
      UPDATED=$(echo "$UPDATED" | jq -c --arg v "$OUTCOME" '.outcome_status = $v')
    fi
    if [[ -n "$CONFIDENCE" ]]; then
      UPDATED=$(echo "$UPDATED" | jq -c --argjson v "$CONFIDENCE" '.confidence = $v')
    fi
    if [[ -n "$DEPRECATED" ]]; then
      if [[ "$DEPRECATED" == "true" ]]; then
        UPDATED=$(echo "$UPDATED" | jq -c '.deprecated = true')
      else
        UPDATED=$(echo "$UPDATED" | jq -c '.deprecated = false')
      fi
    fi
    if [[ -n "$DEPRECATION_REASON" ]]; then
      UPDATED=$(echo "$UPDATED" | jq -c --arg v "$DEPRECATION_REASON" '.deprecation_reason = $v')
    fi
    if [[ -n "$SUPERSEDED_BY" ]]; then
      UPDATED=$(echo "$UPDATED" | jq -c --arg v "$SUPERSEDED_BY" '.superseded_by = $v')
    fi

    UPDATED=$(echo "$UPDATED" | jq -c --arg ts "$TIMESTAMP" '.updated_at = $ts')
    echo "$UPDATED"
  else
    echo "$line"
  fi
done < "$JSONL_FILE" > "$TMP"

if [[ "$FOUND" == "true" ]]; then
  mv "$TMP" "$JSONL_FILE"
  release_named_lock "expertise-${DOMAIN}"
  echo "Updated record $RECORD_ID in ${DOMAIN}.jsonl"
  exit 0
else
  rm -f "$TMP"
  release_named_lock "expertise-${DOMAIN}"
  echo "ERROR: Record $RECORD_ID not found in ${DOMAIN}.jsonl" >&2
  exit 1
fi
