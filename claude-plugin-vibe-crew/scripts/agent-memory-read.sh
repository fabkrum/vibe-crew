#!/usr/bin/env bash
# scripts/agent-memory-read.sh
# Reads memory entries for a specific agent, optionally filtered by domain.
# Automatically prunes expired entries (TTL enforcement).
# Usage: agent-memory-read.sh --agent <name> [--domain <domain>] [--limit <n>]
# Exit 0 on success (outputs JSONL or summary), Exit 1 on error.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
MEMORY_BASE="$PROJECT_ROOT/.vibecrew/memory"

# Defaults
AGENT=""
DOMAIN=""
LIMIT=20
FORMAT="summary"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)   AGENT="$2"; shift 2 ;;
    --domain)  DOMAIN="$2"; shift 2 ;;
    --limit)   LIMIT="$2"; shift 2 ;;
    --format)  FORMAT="$2"; shift 2 ;;
    *)         echo '{"error":"Unknown argument: '"$1"'"}'; exit 1 ;;
  esac
done

if [[ -z "$AGENT" ]]; then
  echo '{"error":"Required: --agent"}'
  exit 1
fi

# Sanitize
AGENT="$(echo "$AGENT" | tr -cd 'a-zA-Z0-9_-')"
DOMAIN="$(echo "$DOMAIN" | tr -cd 'a-zA-Z0-9_-')"

AGENT_DIR="$MEMORY_BASE/$AGENT"

if [[ ! -d "$AGENT_DIR" ]]; then
  echo '{"agent":"'"$AGENT"'","entries":[],"count":0}'
  exit 0
fi

NOW="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Determine which files to read
if [[ -n "$DOMAIN" ]]; then
  FILES=("$AGENT_DIR/$DOMAIN.jsonl")
else
  FILES=("$AGENT_DIR"/*.jsonl)
fi

# Collect and filter entries (prune expired)
RESULTS="[]"
for file in "${FILES[@]}"; do
  [[ -f "$file" ]] || continue

  DOMAIN_NAME="$(basename "$file" .jsonl)"

  # Read entries, filter out expired, add domain tag
  VALID_ENTRIES=$(jq -c --arg now "$NOW" --arg dom "$DOMAIN_NAME" \
    'select(.expires_at == "" or .expires_at >= $now) | . + {domain: $dom}' \
    "$file" 2>/dev/null || true)

  if [[ -n "$VALID_ENTRIES" ]]; then
    # Re-write file without expired entries (TTL pruning)
    KEPT=$(jq -c --arg now "$NOW" 'select(.expires_at == "" or .expires_at >= $now)' "$file" 2>/dev/null || true)
    if [[ -n "$KEPT" ]]; then
      echo "$KEPT" > "$file.tmp"
      mv "$file.tmp" "$file"
    else
      rm -f "$file"
    fi

    # Accumulate results
    RESULTS=$(echo "$RESULTS" | jq --argjson new "$(echo "$VALID_ENTRIES" | jq -s '.')" '. + $new')
  else
    # All expired — remove file
    rm -f "$file"
  fi
done

# Apply limit (most recent first)
RESULTS=$(echo "$RESULTS" | jq --argjson lim "$LIMIT" '[sort_by(.created_at) | reverse | .[:$lim] | .[]]')
COUNT=$(echo "$RESULTS" | jq 'length')

if [[ "$FORMAT" == "summary" ]]; then
  # Output a concise markdown summary for agent context injection
  if [[ "$COUNT" -eq 0 ]]; then
    echo '{"agent":"'"$AGENT"'","entries":[],"count":0}'
    exit 0
  fi

  echo "### Agent Memory: $AGENT"
  echo ""
  echo "$RESULTS" | jq -r '.[] | "- **[\(.domain)]** \(.content) _(\(.created_at | split("T")[0]))_"'
  echo ""
  echo "_\(${COUNT}) entries loaded_"
else
  # Raw JSON output
  jq -nc --arg agent "$AGENT" --argjson entries "$RESULTS" --argjson count "$COUNT" \
    '{agent: $agent, entries: $entries, count: $count}'
fi

exit 0
