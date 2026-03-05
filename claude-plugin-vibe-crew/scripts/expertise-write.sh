#!/usr/bin/env bash
# scripts/expertise-write.sh
# Append a typed expertise record to a domain JSONL file.
# Uses advisory locking and atomic write (temp file + mv).
# Usage: expertise-write.sh --domain <domain> --type <type> --tier <tier> \
#          --content "text" [--context "text"] [--outcome <status>] \
#          [--confidence <0-1>] [--tags "tag1,tag2"] [--session-id <id>] \
#          [--feature-id <id>] [--source-agent <agent>]
# Output: JSON record written to stdout
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/expertise-id.sh"
source "$SCRIPT_DIR/lib/lock.sh"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"

# --- Parse arguments ---
DOMAIN=""
TYPE=""
TIER=""
CONTENT=""
CONTEXT=""
OUTCOME="pending"
CONFIDENCE="0.70"
TAGS=""
SESSION_ID=""
FEATURE_ID="null"
SOURCE_AGENT="user"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain) DOMAIN="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --tier) TIER="$2"; shift 2 ;;
    --content) CONTENT="$2"; shift 2 ;;
    --context) CONTEXT="$2"; shift 2 ;;
    --outcome) OUTCOME="$2"; shift 2 ;;
    --confidence) CONFIDENCE="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --feature-id) FEATURE_ID="$2"; shift 2 ;;
    --source-agent) SOURCE_AGENT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

# --- Validate required fields ---
VALID_DOMAINS=("conventions" "patterns" "failures" "decisions" "performance")
VALID_TYPES=("convention" "pattern" "failure" "decision" "reference" "guide")
VALID_TIERS=("foundational" "tactical" "observational")
VALID_OUTCOMES=("success" "failure" "mixed" "pending")

validate_enum() {
  local value="$1" name="$2"
  shift 2
  local valid=("$@")
  for v in "${valid[@]}"; do
    [[ "$v" == "$value" ]] && return 0
  done
  echo "ERROR: Invalid $name '$value'. Must be one of: ${valid[*]}" >&2
  exit 1
}

if [[ -z "$DOMAIN" ]]; then echo "ERROR: --domain is required" >&2; exit 1; fi
if [[ -z "$TYPE" ]]; then echo "ERROR: --type is required" >&2; exit 1; fi
if [[ -z "$TIER" ]]; then echo "ERROR: --tier is required" >&2; exit 1; fi
if [[ -z "$CONTENT" ]]; then echo "ERROR: --content is required" >&2; exit 1; fi

validate_enum "$DOMAIN" "domain" "${VALID_DOMAINS[@]}"
validate_enum "$TYPE" "type" "${VALID_TYPES[@]}"
validate_enum "$TIER" "tier" "${VALID_TIERS[@]}"
validate_enum "$OUTCOME" "outcome" "${VALID_OUTCOMES[@]}"

# Truncate content and context
CONTENT="${CONTENT:0:500}"
CONTEXT="${CONTEXT:0:200}"

# --- Generate ID and timestamp ---
RECORD_ID=$(generate_expertise_id)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

if [[ -z "$SESSION_ID" ]]; then
  SESSION_ID="session-$(date -u +%Y-%m-%d)-unknown"
fi

# --- Build tags JSON array ---
TAGS_JSON="[]"
if [[ -n "$TAGS" ]]; then
  TAGS_JSON=$(echo "$TAGS" | tr ',' '\n' | jq -R '.' | jq -s '.')
fi

# --- Build feature_id value ---
FEATURE_VAL="null"
if [[ "$FEATURE_ID" != "null" && -n "$FEATURE_ID" ]]; then
  FEATURE_VAL="\"$FEATURE_ID\""
fi

# --- Ensure directory exists ---
mkdir -p "$EXPERTISE_DIR"

# --- Build JSON record ---
RECORD=$(jq -n \
  --arg id "$RECORD_ID" \
  --arg type "$TYPE" \
  --arg tier "$TIER" \
  --arg domain "$DOMAIN" \
  --arg content "$CONTENT" \
  --arg context "$CONTEXT" \
  --arg outcome "$OUTCOME" \
  --argjson confidence "$CONFIDENCE" \
  --argjson tags "$TAGS_JSON" \
  --arg created_at "$TIMESTAMP" \
  --arg updated_at "$TIMESTAMP" \
  --arg session_id "$SESSION_ID" \
  --arg source_agent "$SOURCE_AGENT" \
  '{
    id: $id,
    type: $type,
    tier: $tier,
    domain: $domain,
    content: $content,
    context: $context,
    outcome_status: $outcome,
    confidence: $confidence,
    tags: $tags,
    created_at: $created_at,
    updated_at: $updated_at,
    session_id: $session_id,
    feature_id: null,
    source_agent: $source_agent,
    deprecated: false,
    deprecation_reason: null,
    access_count: 0,
    last_accessed_at: null,
    superseded_by: null
  }')

# Set feature_id if provided
if [[ "$FEATURE_ID" != "null" && -n "$FEATURE_ID" ]]; then
  RECORD=$(echo "$RECORD" | jq --arg fid "$FEATURE_ID" '.feature_id = $fid')
fi

# --- Acquire lock and write atomically ---
JSONL_FILE="$EXPERTISE_DIR/${DOMAIN}.jsonl"
acquire_named_lock "expertise-${DOMAIN}" "expertise-write"

# Compact JSON to single line and append
COMPACT=$(echo "$RECORD" | jq -c '.')
echo "$COMPACT" >> "$JSONL_FILE"

release_named_lock "expertise-${DOMAIN}"

# Output the written record
echo "$COMPACT"
exit 0
