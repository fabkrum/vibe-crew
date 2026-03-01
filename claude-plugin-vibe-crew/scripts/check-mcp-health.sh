#!/usr/bin/env bash
# scripts/check-mcp-health.sh
# Health-check enabled MCP servers from .mcp.json
# Attempts to start each enabled server with a timeout, reports pass/fail.
# Exit 0 always (health checks are non-blocking)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MCP_CONFIG="$PLUGIN_ROOT/.mcp.json"
TIMEOUT_SECS=5
RESULTS=()

if [[ ! -f "$MCP_CONFIG" ]]; then
  echo '{"servers":[],"warning":"No .mcp.json found"}'
  exit 0
fi

# Check if Node.js is available (all servers use npx)
if ! command -v npx &>/dev/null; then
  echo '{"servers":[],"warning":"npx not available — skipping MCP health checks"}'
  exit 0
fi

# Get enabled servers
ENABLED_SERVERS=$(jq -r '.mcpServers | to_entries[] | select(.value.disabled != true) | .key' "$MCP_CONFIG" 2>/dev/null)

if [[ -z "$ENABLED_SERVERS" ]]; then
  echo '{"servers":[],"summary":{"total":0,"healthy":0,"failed":0}}'
  exit 0
fi

TOTAL=0; HEALTHY=0; FAILED=0

while IFS= read -r server; do
  [[ -z "$server" ]] && continue
  ((TOTAL++))

  # Get command and args
  CMD=$(jq -r ".mcpServers.\"$server\".command" "$MCP_CONFIG")
  ARGS=$(jq -r ".mcpServers.\"$server\".args // [] | join(\" \")" "$MCP_CONFIG")

  # Try to start the server with a timeout
  # We just check if the process starts without immediate error
  ERROR_MSG=""
  if timeout "$TIMEOUT_SECS" bash -c "$CMD $ARGS </dev/null >/dev/null 2>/tmp/mcp-health-$server.err &
    PID=\$!
    sleep 1
    if kill -0 \$PID 2>/dev/null; then
      kill \$PID 2>/dev/null || true
      wait \$PID 2>/dev/null || true
      exit 0
    else
      wait \$PID 2>/dev/null
      exit \$?
    fi" 2>/dev/null; then
    STATUS="ok"
    ((HEALTHY++))
  else
    STATUS="failed"
    ((FAILED++))
    ERROR_MSG=$(head -1 /tmp/mcp-health-"$server".err 2>/dev/null || echo "Process exited or timed out")
  fi

  # Clean up temp file
  rm -f /tmp/mcp-health-"$server".err

  if [[ -n "$ERROR_MSG" ]]; then
    RESULTS+=("{\"server\":\"$server\",\"status\":\"$STATUS\",\"error\":$(echo "$ERROR_MSG" | jq -Rs '.')}")
  else
    RESULTS+=("{\"server\":\"$server\",\"status\":\"$STATUS\"}")
  fi
done <<< "$ENABLED_SERVERS"

# Build output JSON
if [[ ${#RESULTS[@]} -gt 0 ]]; then
  SERVERS_JSON=$(printf '%s,' "${RESULTS[@]}" | sed 's/,$//')
else
  SERVERS_JSON=""
fi

jq -n --argjson servers "[$SERVERS_JSON]" \
  --argjson total "$TOTAL" --argjson healthy "$HEALTHY" --argjson failed "$FAILED" \
  '{servers:$servers, summary:{total:$total, healthy:$healthy, failed:$failed}}'

exit 0
