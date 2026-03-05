#!/usr/bin/env bash
# scripts/expertise-prime.sh
# Generate token-efficient markdown context for agent injection (max 2000 tokens).
# Reads relevant expertise records based on the requesting agent's role.
# Usage: expertise-prime.sh --agent <agent-name> [--max-tokens <N>]
# Output: Markdown-formatted expertise context to stdout
# Exit 0 always (fail open)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"

# --- Parse arguments ---
AGENT=""
MAX_TOKENS=2000

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --max-tokens) MAX_TOKENS="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$AGENT" ]]; then
  echo "ERROR: --agent is required" >&2
  exit 1
fi

# --- Agent-to-domain/type mapping ---
# Each agent gets specific record types and domains
case "$AGENT" in
  builder)
    TYPES=("pattern" "convention" "reference")
    DOMAINS=("conventions" "patterns")
    ;;
  code-reviewer)
    TYPES=("convention" "decision")
    DOMAINS=("conventions" "decisions")
    ;;
  stack-scout)
    TYPES=("decision" "failure")
    DOMAINS=("decisions" "failures")
    ;;
  performance-coach)
    TYPES=("failure" "convention")
    DOMAINS=("failures" "conventions" "performance")
    ;;
  *)
    # Default: all non-deprecated foundational records
    TYPES=()
    DOMAINS=()
    ;;
esac

# --- Check if expertise directory exists ---
if [[ ! -d "$EXPERTISE_DIR" ]]; then
  exit 0
fi

# --- Collect records ---
ALL_RECORDS="[]"

if [[ ${#DOMAINS[@]} -gt 0 ]]; then
  for domain in "${DOMAINS[@]}"; do
    if [[ -f "$EXPERTISE_DIR/${domain}.jsonl" ]]; then
      # Read non-deprecated records, filter by types
      DOMAIN_RECORDS=$(cat "$EXPERTISE_DIR/${domain}.jsonl" 2>/dev/null | jq -c 'select(.deprecated != true)' 2>/dev/null || true)
      if [[ -n "$DOMAIN_RECORDS" ]]; then
        ALL_RECORDS=$(echo "$ALL_RECORDS"; echo "$DOMAIN_RECORDS")
      fi
    fi
  done
else
  # Default: read all domains
  for f in "$EXPERTISE_DIR"/*.jsonl; do
    [[ -f "$f" ]] || continue
    DOMAIN_RECORDS=$(cat "$f" 2>/dev/null | jq -c 'select(.deprecated != true)' 2>/dev/null || true)
    if [[ -n "$DOMAIN_RECORDS" ]]; then
      ALL_RECORDS=$(echo "$ALL_RECORDS"; echo "$DOMAIN_RECORDS")
    fi
  done
fi

# Combine into array, filter by types if specified, sort by tier (foundational first) then confidence
TYPE_FILTER="."
if [[ ${#TYPES[@]} -gt 0 ]]; then
  TYPE_ARRAY=$(printf '"%s",' "${TYPES[@]}")
  TYPE_ARRAY="[${TYPE_ARRAY%,}]"
  TYPE_FILTER="select(.type as \$t | $TYPE_ARRAY | index(\$t))"
fi

FILTERED=$(echo "$ALL_RECORDS" | jq -c "$TYPE_FILTER" 2>/dev/null | jq -s '
  sort_by(
    (if .tier == "foundational" then 0 elif .tier == "tactical" then 1 else 2 end),
    -.confidence,
    -.access_count
  )' 2>/dev/null || echo "[]")

RECORD_COUNT=$(echo "$FILTERED" | jq 'length' 2>/dev/null || echo "0")

if [[ "$RECORD_COUNT" -eq 0 ]]; then
  exit 0
fi

# --- Generate markdown output (token-efficient) ---
# Estimate ~4 chars per token; limit output to MAX_TOKENS * 4 chars
MAX_CHARS=$((MAX_TOKENS * 4))
OUTPUT=""
CHAR_COUNT=0

OUTPUT="--- Expertise Context ($AGENT) ---"$'\n'
CHAR_COUNT=${#OUTPUT}

# Group by tier for readability
for tier in foundational tactical observational; do
  TIER_RECORDS=$(echo "$FILTERED" | jq -c ".[] | select(.tier == \"$tier\")" 2>/dev/null || true)
  [[ -z "$TIER_RECORDS" ]] && continue

  SECTION_HEADER=""
  case "$tier" in
    foundational) SECTION_HEADER="[F] " ;;
    tactical)     SECTION_HEADER="[T] " ;;
    observational) SECTION_HEADER="[O] " ;;
  esac

  while IFS= read -r record; do
    CONTENT=$(echo "$record" | jq -r '.content' 2>/dev/null || continue)
    CONTEXT=$(echo "$record" | jq -r '.context // ""' 2>/dev/null || echo "")
    CONF=$(echo "$record" | jq -r '.confidence' 2>/dev/null || echo "0")

    LINE="${SECTION_HEADER}${CONTENT}"
    if [[ -n "$CONTEXT" && "$CONTEXT" != "null" ]]; then
      LINE="$LINE — $CONTEXT"
    fi
    LINE="$LINE"$'\n'

    LINE_LEN=${#LINE}
    if [[ $((CHAR_COUNT + LINE_LEN)) -gt $MAX_CHARS ]]; then
      break 2  # Exit both loops
    fi

    OUTPUT="${OUTPUT}${LINE}"
    CHAR_COUNT=$((CHAR_COUNT + LINE_LEN))
  done <<< "$TIER_RECORDS"
done

OUTPUT="${OUTPUT}---"$'\n'

echo "$OUTPUT"

# --- Update access counts for records that were included ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
INCLUDED_IDS=$(echo "$FILTERED" | jq -r '.[].id' 2>/dev/null || true)
if [[ -n "$INCLUDED_IDS" ]]; then
  for domain_file in "$EXPERTISE_DIR"/*.jsonl; do
    [[ -f "$domain_file" ]] || continue
    TMP="${domain_file}.tmp.$$"
    CHANGED=false
    while IFS= read -r line; do
      LINE_ID=$(echo "$line" | jq -r '.id' 2>/dev/null || echo "")
      if echo "$INCLUDED_IDS" | grep -qF "$LINE_ID"; then
        echo "$line" | jq -c --arg ts "$TIMESTAMP" '.access_count += 1 | .last_accessed_at = $ts'
        CHANGED=true
      else
        echo "$line"
      fi
    done < "$domain_file" > "$TMP"
    if [[ "$CHANGED" == "true" ]]; then
      mv "$TMP" "$domain_file"
    else
      rm -f "$TMP"
    fi
  done
fi

exit 0
