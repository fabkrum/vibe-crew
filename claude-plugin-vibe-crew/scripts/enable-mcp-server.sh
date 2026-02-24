#!/usr/bin/env bash
# scripts/enable-mcp-server.sh
# Toggle an MCP server's disabled flag in .mcp.json and sync .vibecrew/config.json
# Usage:
#   enable-mcp-server.sh <server-name>              # Enable a server
#   enable-mcp-server.sh <server-name> enable       # Enable a server (explicit)
#   enable-mcp-server.sh <server-name> disable      # Disable a server
# Idempotent: safe to run multiple times
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

# --- Detect plugin root ---
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

MCP_FILE="$PLUGIN_ROOT/.mcp.json"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

# --- Validation ---
if [[ $# -lt 1 ]]; then
  echo "Usage: enable-mcp-server.sh <server-name> [enable|disable]" >&2
  exit 1
fi

SERVER_NAME="$1"
ACTION="${2:-enable}"

if [[ "$ACTION" != "enable" ]] && [[ "$ACTION" != "disable" ]]; then
  echo "ERROR: Action must be 'enable' or 'disable', got '$ACTION'." >&2
  exit 1
fi

if [[ ! -f "$MCP_FILE" ]]; then
  echo "ERROR: .mcp.json not found at $MCP_FILE" >&2
  exit 1
fi

# --- Check server exists ---
SERVER_EXISTS=$(jq -r --arg name "$SERVER_NAME" '.mcpServers | has($name)' "$MCP_FILE")
if [[ "$SERVER_EXISTS" != "true" ]]; then
  echo "ERROR: Server '$SERVER_NAME' not found in .mcp.json" >&2
  echo "Available servers:" >&2
  jq -r '.mcpServers | keys[]' "$MCP_FILE" >&2
  exit 1
fi

# --- Determine target disabled value ---
if [[ "$ACTION" == "enable" ]]; then
  DISABLED_VALUE="false"
else
  DISABLED_VALUE="true"
fi

# --- Check current state ---
CURRENT_DISABLED=$(jq -r --arg name "$SERVER_NAME" '.mcpServers[$name].disabled // false' "$MCP_FILE")
if [[ "$CURRENT_DISABLED" == "$DISABLED_VALUE" ]]; then
  echo "Server '$SERVER_NAME' is already ${ACTION}d. No changes needed."
  exit 0
fi

# --- Check for empty env vars on enable ---
if [[ "$ACTION" == "enable" ]]; then
  ENV_KEYS=$(jq -r --arg name "$SERVER_NAME" '.mcpServers[$name].env // {} | keys[]' "$MCP_FILE" 2>/dev/null || true)
  if [[ -n "$ENV_KEYS" ]]; then
    MISSING_VARS=()
    while IFS= read -r key; do
      VALUE=$(jq -r --arg name "$SERVER_NAME" --arg key "$key" '.mcpServers[$name].env[$key] // ""' "$MCP_FILE")
      if [[ -z "$VALUE" || "$VALUE" == '${'"$key"'}' ]]; then
        # Check if the env var is set in the environment
        if [[ -z "${!key:-}" ]]; then
          MISSING_VARS+=("$key")
        fi
      fi
    done <<< "$ENV_KEYS"
    if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
      echo "WARNING: The following environment variables are not set:" >&2
      for var in "${MISSING_VARS[@]}"; do
        echo "  - $var" >&2
      done
      echo "Server '$SERVER_NAME' will be enabled, but may not function without these variables." >&2
    fi
  fi
fi

# --- Update .mcp.json ---
UPDATED_MCP=$(jq --arg name "$SERVER_NAME" --argjson disabled "$DISABLED_VALUE" \
  '.mcpServers[$name].disabled = $disabled' "$MCP_FILE")

TMP_MCP="${MCP_FILE}.tmp"
echo "$UPDATED_MCP" > "$TMP_MCP"

# Validate JSON
if ! jq empty "$TMP_MCP" 2>/dev/null; then
  echo "ERROR: JSON validation failed for .mcp.json" >&2
  rm -f "$TMP_MCP"
  exit 1
fi

mv "$TMP_MCP" "$MCP_FILE"

# --- Sync .vibecrew/config.json if it exists ---
if [[ -f "$CONFIG_FILE" ]]; then
  # Convert server name: hyphens to underscores for config.json key
  CONFIG_KEY=$(echo "$SERVER_NAME" | tr '-' '_')
  ENABLED_VALUE="true"
  [[ "$ACTION" == "disable" ]] && ENABLED_VALUE="false"

  UPDATED_CONFIG=$(jq --arg key "$CONFIG_KEY" --argjson val "$ENABLED_VALUE" \
    '.mcp_servers[$key] = $val' "$CONFIG_FILE")

  TMP_CONFIG="${CONFIG_FILE}.tmp"
  echo "$UPDATED_CONFIG" > "$TMP_CONFIG"

  if ! jq empty "$TMP_CONFIG" 2>/dev/null; then
    echo "WARNING: Failed to update config.json — JSON validation failed." >&2
    rm -f "$TMP_CONFIG"
  else
    mv "$TMP_CONFIG" "$CONFIG_FILE"
  fi
fi

echo "Server '$SERVER_NAME' ${ACTION}d successfully."
exit 0
