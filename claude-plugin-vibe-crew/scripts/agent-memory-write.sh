#!/usr/bin/env bash
# scripts/agent-memory-write.sh
# Writes a memory entry for a specific agent.
# Usage: agent-memory-write.sh --agent <name> --domain <domain> --content <text> [--ttl <days>]
# Memory entries are stored as JSONL in .vibecrew/memory/<agent>/<domain>.jsonl
# Exit 0 on success, Exit 1 on error.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEMORY_BASE="$PROJECT_ROOT/.vibecrew/memory"

# Defaults
AGENT=""
DOMAIN=""
CONTENT=""
TTL_DAYS=90
MAX_ENTRIES_PER_DOMAIN=50
MAX_FILE_SIZE_KB=100

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)   AGENT="$2"; shift 2 ;;
    --domain)  DOMAIN="$2"; shift 2 ;;
    --content) CONTENT="$2"; shift 2 ;;
    --ttl)     TTL_DAYS="$2"; shift 2 ;;
    *)         echo '{"error":"Unknown argument: '"$1"'"}'; exit 1 ;;
  esac
done

if [[ -z "$AGENT" || -z "$DOMAIN" || -z "$CONTENT" ]]; then
  echo '{"error":"Required: --agent, --domain, --content"}'
  exit 1
fi

# Sanitize inputs (alphanumeric, hyphens, underscores only)
AGENT="$(echo "$AGENT" | tr -cd 'a-zA-Z0-9_-')"
DOMAIN="$(echo "$DOMAIN" | tr -cd 'a-zA-Z0-9_-')"

AGENT_DIR="$MEMORY_BASE/$AGENT"
MEMORY_FILE="$AGENT_DIR/$DOMAIN.jsonl"

mkdir -p "$AGENT_DIR"

# Build entry
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
EXPIRES_AT="$(date -u -v+"${TTL_DAYS}d" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "+${TTL_DAYS} days" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "")"

ENTRY=$(jq -nc \
  --arg content "$CONTENT" \
  --arg ts "$TIMESTAMP" \
  --arg exp "$EXPIRES_AT" \
  --argjson ttl "$TTL_DAYS" \
  '{content: $content, created_at: $ts, expires_at: $exp, ttl_days: $ttl}')

# Check for duplicate content (skip if identical entry exists)
if [[ -f "$MEMORY_FILE" ]]; then
  DUPE=$(jq -r --arg c "$CONTENT" 'select(.content == $c) | .content' "$MEMORY_FILE" 2>/dev/null | head -1)
  if [[ -n "$DUPE" ]]; then
    echo '{"written":false,"reason":"duplicate","agent":"'"$AGENT"'","domain":"'"$DOMAIN"'"}'
    exit 0
  fi
fi

# Append entry
echo "$ENTRY" >> "$MEMORY_FILE"

# Enforce max entries per domain (prune oldest)
if [[ -f "$MEMORY_FILE" ]]; then
  LINE_COUNT=$(wc -l < "$MEMORY_FILE" | tr -d ' ')
  if [[ "$LINE_COUNT" -gt "$MAX_ENTRIES_PER_DOMAIN" ]]; then
    PRUNE_COUNT=$((LINE_COUNT - MAX_ENTRIES_PER_DOMAIN))
    tail -n "$MAX_ENTRIES_PER_DOMAIN" "$MEMORY_FILE" > "$MEMORY_FILE.tmp"
    mv "$MEMORY_FILE.tmp" "$MEMORY_FILE"
  fi
fi

# Enforce max file size (prune oldest half if over limit)
if [[ -f "$MEMORY_FILE" ]]; then
  FILE_SIZE_KB=$(du -k "$MEMORY_FILE" | cut -f1)
  if [[ "$FILE_SIZE_KB" -gt "$MAX_FILE_SIZE_KB" ]]; then
    HALF=$(( $(wc -l < "$MEMORY_FILE" | tr -d ' ') / 2 ))
    tail -n "$HALF" "$MEMORY_FILE" > "$MEMORY_FILE.tmp"
    mv "$MEMORY_FILE.tmp" "$MEMORY_FILE"
  fi
fi

echo '{"written":true,"agent":"'"$AGENT"'","domain":"'"$DOMAIN"'","entries":'$(wc -l < "$MEMORY_FILE" | tr -d ' ')'}'
exit 0
