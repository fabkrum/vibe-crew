#!/usr/bin/env bash
# scripts/add-mcp-server.sh
# Adds a new MCP server entry to .mcp.json from the registry.
# Complement to enable-mcp-server.sh (which toggles existing entries).
# Usage:
#   add-mcp-server.sh <server-key>             # Add single server (disabled by default)
#   add-mcp-server.sh <server-key> --enable    # Add and enable immediately
#   add-mcp-server.sh --all-recommended        # Add all TDR-matched servers not in .mcp.json
#   add-mcp-server.sh --list                   # List all registry servers with status
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

# --- Detect plugin root ---
if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

REGISTRY_FILE="$PLUGIN_ROOT/templates/mcp-registry.json"
MCP_FILE="$PLUGIN_ROOT/.mcp.json"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"
SYNC_SCRIPT="$PLUGIN_ROOT/scripts/sync-mcp-from-tdr.sh"
ENABLE_SCRIPT="$PLUGIN_ROOT/scripts/enable-mcp-server.sh"

# --- Validate registry ---
if [[ ! -f "$REGISTRY_FILE" ]]; then
  echo "ERROR: MCP registry not found at $REGISTRY_FILE" >&2
  exit 1
fi

if [[ ! -f "$MCP_FILE" ]]; then
  echo "ERROR: .mcp.json not found at $MCP_FILE" >&2
  exit 1
fi

# --- List mode ---
list_servers() {
  echo "MCP Server Registry"
  echo "==================="
  echo ""
  printf "%-20s %-10s %-8s %s\n" "Key" "Category" "Status" "Description"
  printf "%-20s %-10s %-8s %s\n" "---" "--------" "------" "-----------"

  local keys
  keys=$(jq -r '.servers | keys[]' "$REGISTRY_FILE")

  while IFS= read -r key; do
    local name category description in_mcp status
    name=$(jq -r --arg k "$key" '.servers[$k].name' "$REGISTRY_FILE")
    category=$(jq -r --arg k "$key" '.servers[$k].category' "$REGISTRY_FILE")
    description=$(jq -r --arg k "$key" '.servers[$k].description' "$REGISTRY_FILE")
    in_mcp=$(jq -r --arg k "$key" '.mcpServers | has($k)' "$MCP_FILE")

    if [[ "$in_mcp" == "true" ]]; then
      local disabled
      disabled=$(jq -r --arg k "$key" '.mcpServers[$k].disabled // false' "$MCP_FILE")
      if [[ "$disabled" == "true" ]]; then
        status="added"
      else
        status="active"
      fi
    else
      status="--"
    fi

    printf "%-20s %-10s %-8s %s\n" "$key" "$category" "$status" "$description"
  done <<< "$keys"

  echo ""
  echo "Status: active = in .mcp.json and enabled, added = in .mcp.json but disabled, -- = not added"
}

# --- Add a single server ---
add_server() {
  local server_key="$1"
  local enable_flag="${2:-}"

  # Look up in registry
  local exists
  exists=$(jq -r --arg k "$server_key" '.servers | has($k)' "$REGISTRY_FILE")
  if [[ "$exists" != "true" ]]; then
    echo "ERROR: Server '$server_key' not found in registry." >&2
    echo "Run 'add-mcp-server.sh --list' to see available servers." >&2
    exit 1
  fi

  # Check if already in .mcp.json
  local in_mcp
  in_mcp=$(jq -r --arg k "$server_key" '.mcpServers | has($k)' "$MCP_FILE")
  if [[ "$in_mcp" == "true" ]]; then
    echo "Server '$server_key' already exists in .mcp.json. No changes needed."
    # If --enable flag, ensure it's enabled
    if [[ "$enable_flag" == "--enable" ]]; then
      bash "$ENABLE_SCRIPT" "$server_key" enable 2>/dev/null || true
    fi
    jq -n --arg server "$server_key" --arg action "exists" '{ server: $server, action: $action }'
    exit 0
  fi

  # Build the server entry from registry
  local command args env_obj disabled_val
  command=$(jq -r --arg k "$server_key" '.servers[$k].command' "$REGISTRY_FILE")
  args=$(jq --arg k "$server_key" '.servers[$k].args' "$REGISTRY_FILE")
  env_obj=$(jq --arg k "$server_key" '.servers[$k].env' "$REGISTRY_FILE")

  if [[ "$enable_flag" == "--enable" ]]; then
    disabled_val="false"
  else
    disabled_val="true"
  fi

  # Convert env descriptions to empty strings
  local env_empty
  env_empty=$(echo "$env_obj" | jq 'with_entries(.value = "")')

  # Inject into .mcp.json
  local updated_mcp
  updated_mcp=$(jq \
    --arg key "$server_key" \
    --arg cmd "$command" \
    --argjson args "$args" \
    --argjson env "$env_empty" \
    --argjson disabled "$disabled_val" \
    '.mcpServers[$key] = { command: $cmd, args: $args, env: $env, disabled: $disabled }' \
    "$MCP_FILE")

  local tmp_mcp="${MCP_FILE}.tmp"
  echo "$updated_mcp" > "$tmp_mcp"

  # Validate JSON
  if ! jq empty "$tmp_mcp" 2>/dev/null; then
    echo "ERROR: JSON validation failed for .mcp.json" >&2
    rm -f "$tmp_mcp"
    exit 1
  fi

  mv "$tmp_mcp" "$MCP_FILE"

  # Sync to .vibecrew/config.json if it exists
  if [[ -f "$CONFIG_FILE" ]]; then
    local config_key enabled_val
    config_key=$(echo "$server_key" | tr '-' '_')
    if [[ "$enable_flag" == "--enable" ]]; then
      enabled_val="true"
    else
      enabled_val="false"
    fi

    local updated_config
    updated_config=$(jq --arg key "$config_key" --argjson val "$enabled_val" \
      '.mcp_servers[$key] = $val' "$CONFIG_FILE")

    local tmp_config="${CONFIG_FILE}.tmp"
    echo "$updated_config" > "$tmp_config"

    if ! jq empty "$tmp_config" 2>/dev/null; then
      echo "WARNING: Failed to update config.json — JSON validation failed." >&2
      rm -f "$tmp_config"
    else
      mv "$tmp_config" "$CONFIG_FILE"
    fi
  fi

  # Determine auth requirement
  local auth_required="false"
  local env_count
  env_count=$(echo "$env_obj" | jq 'length')
  if [[ "$env_count" -gt 0 ]]; then
    auth_required="true"
  fi

  echo "Server '$server_key' added to .mcp.json (disabled=$disabled_val)."

  jq -n \
    --arg server "$server_key" \
    --arg action "added" \
    --argjson auth_required "$auth_required" \
    '{ server: $server, action: $action, auth_required: $auth_required }'
}

# --- All recommended mode ---
add_all_recommended() {
  # Get recommended servers from sync script (capture JSON output)
  local sync_output
  if ! sync_output=$(bash "$SYNC_SCRIPT" 2>/dev/null); then
    echo "ERROR: Failed to run sync-mcp-from-tdr.sh. Ensure a TDR file exists." >&2
    exit 1
  fi

  local recommended
  recommended=$(echo "$sync_output" | jq -r '.servers_recommended[]?.key // empty' 2>/dev/null)

  if [[ -z "$recommended" ]]; then
    echo "No new servers to recommend. All TDR-matched servers are already in .mcp.json."
    exit 0
  fi

  local added=0
  while IFS= read -r key; do
    echo "--- Adding $key ---"
    add_server "$key" || true
    ((added++))
  done <<< "$recommended"

  echo ""
  echo "Added $added server(s). Run 'enable-mcp-server.sh <name> enable' to activate."
}

# --- Main ---
if [[ $# -lt 1 ]]; then
  echo "Usage:" >&2
  echo "  add-mcp-server.sh <server-key>             # Add single server (disabled)" >&2
  echo "  add-mcp-server.sh <server-key> --enable    # Add and enable immediately" >&2
  echo "  add-mcp-server.sh --all-recommended        # Add all TDR-matched servers" >&2
  echo "  add-mcp-server.sh --list                   # List all registry servers" >&2
  exit 1
fi

case "$1" in
  --list)
    list_servers
    ;;
  --all-recommended)
    add_all_recommended
    ;;
  *)
    add_server "$1" "${2:-}"
    ;;
esac

exit 0
