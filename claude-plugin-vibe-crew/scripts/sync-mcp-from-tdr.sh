#!/usr/bin/env bash
# scripts/sync-mcp-from-tdr.sh
# Reads the TDR file and auto-enables MCP servers for matching technologies.
# Usage:
#   sync-mcp-from-tdr.sh                    # Auto-detect TDR file
#   sync-mcp-from-tdr.sh <path-to-tdr>      # Explicit TDR path
# Outputs JSON report of what was enabled.
# Called by Workflow Orchestrator after TDR approval.
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

# --- Detect plugin root ---
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

ENABLE_SCRIPT="$PLUGIN_ROOT/scripts/enable-mcp-server.sh"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- Find TDR file ---
TDR_FILE="${1:-}"

if [[ -z "$TDR_FILE" ]]; then
  # Auto-detect: look for TDR files in common locations
  for candidate in \
    "$PROJECT_ROOT/docs/TDR"*.md \
    "$PROJECT_ROOT/docs/tdr"*.md \
    "$PROJECT_ROOT/TDR"*.md \
    "$PROJECT_ROOT/tdr"*.md; do
    if [[ -f "$candidate" ]]; then
      TDR_FILE="$candidate"
      break
    fi
  done
fi

if [[ -z "$TDR_FILE" ]] || [[ ! -f "$TDR_FILE" ]]; then
  echo "ERROR: No TDR file found. Provide a path or ensure a TDR-*.md exists in docs/." >&2
  exit 1
fi

# --- Read TDR content (case-insensitive matching) ---
TDR_CONTENT=$(tr '[:upper:]' '[:lower:]' < "$TDR_FILE")

# --- Technology-to-MCP-server mapping ---
# Each entry: "search_pattern:server_name"
MAPPINGS=(
  "supabase:supabase"
  "stripe:stripe"
  "vercel:vercel"
  "figma:figma"
  "sentry:sentry"
)

# --- Match and enable ---
ENABLED=()
SKIPPED=()

for mapping in "${MAPPINGS[@]}"; do
  PATTERN="${mapping%%:*}"
  SERVER="${mapping##*:}"

  if echo "$TDR_CONTENT" | grep -q "$PATTERN"; then
    if bash "$ENABLE_SCRIPT" "$SERVER" enable 2>/dev/null; then
      ENABLED+=("$SERVER")
    else
      SKIPPED+=("$SERVER")
    fi
  fi
done

# --- Output JSON report ---
ENABLED_JSON="[]"
if [[ ${#ENABLED[@]} -gt 0 ]]; then
  ENABLED_JSON=$(printf '%s\n' "${ENABLED[@]}" | jq -R . | jq -s .)
fi

SKIPPED_JSON="[]"
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  SKIPPED_JSON=$(printf '%s\n' "${SKIPPED[@]}" | jq -R . | jq -s .)
fi

jq -n \
  --arg tdr_file "$TDR_FILE" \
  --argjson enabled "$ENABLED_JSON" \
  --argjson skipped "$SKIPPED_JSON" \
  --argjson enabled_count "${#ENABLED[@]}" \
  '{
    tdr_file: $tdr_file,
    servers_enabled: $enabled,
    servers_skipped: $skipped,
    total_enabled: $enabled_count,
    note: "Servers were enabled based on technology mentions in the TDR. Set required environment variables for authenticated servers."
  }'

exit 0
