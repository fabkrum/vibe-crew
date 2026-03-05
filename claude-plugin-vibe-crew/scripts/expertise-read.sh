#!/usr/bin/env bash
# scripts/expertise-read.sh
# Query expertise records by domain/tier/type/tags, updates access_count.
# Usage: expertise-read.sh [--domain <domain>] [--tier <tier>] [--type <type>]
#          [--tags "tag1,tag2"] [--limit <N>] [--no-update] [--deprecated]
# Output: JSON array of matching records to stdout
# Exit 0 on success

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"

# --- Parse arguments ---
DOMAIN=""
TIER=""
TYPE=""
TAGS=""
LIMIT="50"
NO_UPDATE=false
SHOW_DEPRECATED=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain) DOMAIN="$2"; shift 2 ;;
    --tier) TIER="$2"; shift 2 ;;
    --type) TYPE="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --no-update) NO_UPDATE=true; shift ;;
    --deprecated) SHOW_DEPRECATED=true; shift ;;
    *) shift ;;
  esac
done

# --- Check if expertise directory exists ---
if [[ ! -d "$EXPERTISE_DIR" ]]; then
  echo "[]"
  exit 0
fi

# --- Determine which files to read ---
FILES=()
if [[ -n "$DOMAIN" ]]; then
  if [[ -f "$EXPERTISE_DIR/${DOMAIN}.jsonl" ]]; then
    FILES+=("$EXPERTISE_DIR/${DOMAIN}.jsonl")
  fi
else
  for f in "$EXPERTISE_DIR"/*.jsonl; do
    [[ -f "$f" ]] && FILES+=("$f")
  done
fi

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "[]"
  exit 0
fi

# --- Read and filter records ---
# Build jq filter
JQ_FILTER="."

if [[ "$SHOW_DEPRECATED" != "true" ]]; then
  JQ_FILTER="$JQ_FILTER | select(.deprecated != true)"
fi

if [[ -n "$TIER" ]]; then
  JQ_FILTER="$JQ_FILTER | select(.tier == \"$TIER\")"
fi

if [[ -n "$TYPE" ]]; then
  JQ_FILTER="$JQ_FILTER | select(.type == \"$TYPE\")"
fi

if [[ -n "$TAGS" ]]; then
  # Convert comma-separated tags to jq array check
  IFS=',' read -ra TAG_ARRAY <<< "$TAGS"
  for tag in "${TAG_ARRAY[@]}"; do
    tag=$(echo "$tag" | xargs) # trim whitespace
    JQ_FILTER="$JQ_FILTER | select(.tags | index(\"$tag\"))"
  done
fi

# Read all matching files, filter, sort by confidence desc, limit
RESULTS=$(cat "${FILES[@]}" 2>/dev/null | jq -c "$JQ_FILTER" 2>/dev/null | jq -s "sort_by(-.confidence) | .[:$LIMIT]" 2>/dev/null || echo "[]")

# --- Update access counts if not --no-update ---
if [[ "$NO_UPDATE" != "true" && "$RESULTS" != "[]" ]]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  # Get IDs of accessed records
  ACCESSED_IDS=$(echo "$RESULTS" | jq -r '.[].id' 2>/dev/null || true)

  if [[ -n "$ACCESSED_IDS" ]]; then
    for file in "${FILES[@]}"; do
      [[ -f "$file" ]] || continue
      TMP="${file}.tmp.$$"
      # Update access_count and last_accessed_at for matching IDs
      while IFS= read -r line; do
        LINE_ID=$(echo "$line" | jq -r '.id' 2>/dev/null || echo "")
        if echo "$ACCESSED_IDS" | grep -qF "$LINE_ID"; then
          echo "$line" | jq -c --arg ts "$TIMESTAMP" '.access_count += 1 | .last_accessed_at = $ts'
        else
          echo "$line"
        fi
      done < "$file" > "$TMP"
      mv "$TMP" "$file"
    done
  fi
fi

echo "$RESULTS"
exit 0
