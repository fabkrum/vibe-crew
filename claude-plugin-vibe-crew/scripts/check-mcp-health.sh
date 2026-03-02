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
HEALTH_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$HEALTH_TMPDIR"' EXIT

while IFS= read -r server; do
  [[ -z "$server" ]] && continue
  TOTAL=$(( TOTAL + 1 ))

  # Get command and args as array (safe — no shell interpolation)
  CMD=$(jq -r ".mcpServers.\"$server\".command" "$MCP_CONFIG")
  ARGS_ARRAY=()
  while IFS= read -r arg; do
    [[ -n "$arg" ]] && ARGS_ARRAY+=("$arg")
  done < <(jq -r ".mcpServers.\"$server\".args // [] | .[]" "$MCP_CONFIG")

  # Sanitize server name for temp file usage
  SAFE_SERVER="$(printf '%s' "$server" | tr -cd '[:alnum:]._-')"
  ERR_FILE="$HEALTH_TMPDIR/mcp-health-${SAFE_SERVER}.err"

  # Try to start the server with a timeout
  # We just check if the process starts without immediate error
  TIMEOUT_CMD=""
  if command -v timeout &>/dev/null; then
    TIMEOUT_CMD="timeout"
  elif command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout"
  fi
  ERROR_MSG=""
  _RUN_WITH_TIMEOUT() {
    if [[ -n "${TIMEOUT_CMD:-}" ]]; then
      "$TIMEOUT_CMD" "$TIMEOUT_SECS" "$@"
    else
      # No timeout command available — run with background kill pattern
      "$@" &
      local pid=$!
      ( sleep "$TIMEOUT_SECS" && kill "$pid" 2>/dev/null ) &
      local watchdog=$!
      wait "$pid" 2>/dev/null
      local rc=$?
      kill "$watchdog" 2>/dev/null || true
      wait "$watchdog" 2>/dev/null || true
      return $rc
    fi
  }
  if _RUN_WITH_TIMEOUT bash -c '
    "$@" </dev/null >/dev/null 2>"$0" &
    PID=$!
    sleep 1
    if kill -0 $PID 2>/dev/null; then
      kill $PID 2>/dev/null || true
      wait $PID 2>/dev/null || true
      exit 0
    else
      wait $PID 2>/dev/null
      exit $?
    fi' "$ERR_FILE" "$CMD" ${ARGS_ARRAY[@]+"${ARGS_ARRAY[@]}"} 2>/dev/null; then
    STATUS="ok"
    HEALTHY=$(( HEALTHY + 1 ))
  else
    STATUS="failed"
    FAILED=$(( FAILED + 1 ))
    ERROR_MSG=$(head -1 "$ERR_FILE" 2>/dev/null || echo "Process exited or timed out")
  fi

    # Deep health check: send JSON-RPC initialize request
    if [[ "$STATUS" == "ok" ]]; then
      INIT_REQUEST='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"vibecrew-healthcheck","version":"1.0.0"}}}'
      INIT_RESPONSE=""
      INIT_RESPONSE=$(echo "$INIT_REQUEST" | _RUN_WITH_TIMEOUT "$CMD" ${ARGS_ARRAY[@]+"${ARGS_ARRAY[@]}"} 2>/dev/null || echo "")
      if [[ -n "$INIT_RESPONSE" ]]; then
        HAS_RESULT=$(echo "$INIT_RESPONSE" | jq -r '.result // empty' 2>/dev/null || echo "")
        if [[ -z "$HAS_RESULT" ]]; then
          STATUS="degraded"
        fi
      fi
    fi

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
