#!/usr/bin/env bash
# scripts/recommend-mcp-servers.sh
# Scans the TDR and recommends MCP servers not yet in .mcp.json.
# Usage:
#   recommend-mcp-servers.sh                    # Auto-detect TDR, human-readable output
#   recommend-mcp-servers.sh <path-to-tdr>      # Explicit TDR path
#   recommend-mcp-servers.sh --json             # JSON output mode (auto-detect TDR)
#   recommend-mcp-servers.sh <path-to-tdr> --json
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

# --- Parse args ---
TDR_FILE=""
JSON_MODE=false

for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    *) [[ -z "$TDR_FILE" ]] && TDR_FILE="$arg" ;;
  esac
done

# --- Validate registry ---
if [[ ! -f "$REGISTRY_FILE" ]]; then
  echo "ERROR: MCP registry not found at $REGISTRY_FILE" >&2
  exit 1
fi

if [[ ! -f "$MCP_FILE" ]]; then
  echo "ERROR: .mcp.json not found at $MCP_FILE" >&2
  exit 1
fi

# --- Find TDR file ---
if [[ -z "$TDR_FILE" ]]; then
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

# --- Read TDR content (case-insensitive) ---
TDR_CONTENT=$(tr '[:upper:]' '[:lower:]' < "$TDR_FILE")

# --- Scan registry for matches ---
ALREADY_ENABLED=()
ALREADY_ADDED=()
RECOMMENDED=()
RECOMMENDED_JSON="[]"

KEYS=$(jq -r '.servers | keys[]' "$REGISTRY_FILE")

while IFS= read -r key; do
  # Get patterns for this server
  PATTERNS=$(jq -r --arg k "$key" '.servers[$k].patterns[]' "$REGISTRY_FILE")
  MATCHED=false

  while IFS= read -r pattern; do
    if echo "$TDR_CONTENT" | grep -q "$pattern"; then
      MATCHED=true
      break
    fi
  done <<< "$PATTERNS"

  if [[ "$MATCHED" != "true" ]]; then
    continue
  fi

  # Check if already in .mcp.json
  IN_MCP=$(jq -r --arg k "$key" '.mcpServers | has($k)' "$MCP_FILE")

  if [[ "$IN_MCP" == "true" ]]; then
    DISABLED=$(jq -r --arg k "$key" '.mcpServers[$k].disabled // false' "$MCP_FILE")
    if [[ "$DISABLED" == "false" ]]; then
      ALREADY_ENABLED+=("$key")
    else
      ALREADY_ADDED+=("$key")
    fi
  else
    RECOMMENDED+=("$key")

    # Build recommendation detail
    NAME=$(jq -r --arg k "$key" '.servers[$k].name' "$REGISTRY_FILE")
    DESC=$(jq -r --arg k "$key" '.servers[$k].description' "$REGISTRY_FILE")
    DOCS=$(jq -r --arg k "$key" '.servers[$k].docs_url' "$REGISTRY_FILE")
    ENV_KEYS=$(jq -r --arg k "$key" '.servers[$k].env | keys[]' "$REGISTRY_FILE" 2>/dev/null || true)

    AUTH_REQUIRED=false
    ENV_VARS_JSON="[]"
    if [[ -n "$ENV_KEYS" ]]; then
      AUTH_REQUIRED=true
      ENV_VARS_JSON=$(echo "$ENV_KEYS" | jq -R . | jq -s .)
    fi

    RECOMMENDED_JSON=$(echo "$RECOMMENDED_JSON" | jq \
      --arg key "$key" \
      --arg name "$NAME" \
      --arg desc "$DESC" \
      --argjson auth "$AUTH_REQUIRED" \
      --argjson env_vars "$ENV_VARS_JSON" \
      --arg docs "$DOCS" \
      '. + [{ key: $key, name: $name, description: $desc, auth_required: $auth, env_vars: $env_vars, docs_url: $docs }]')
  fi
done <<< "$KEYS"

# --- Output ---
if [[ "$JSON_MODE" == "true" ]]; then
  ENABLED_JSON="[]"
  if [[ ${#ALREADY_ENABLED[@]} -gt 0 ]]; then
    ENABLED_JSON=$(printf '%s\n' "${ALREADY_ENABLED[@]}" | jq -R . | jq -s .)
  fi

  ADDED_JSON="[]"
  if [[ ${#ALREADY_ADDED[@]} -gt 0 ]]; then
    ADDED_JSON=$(printf '%s\n' "${ALREADY_ADDED[@]}" | jq -R . | jq -s .)
  fi

  jq -n \
    --arg tdr_file "$TDR_FILE" \
    --argjson enabled "$ENABLED_JSON" \
    --argjson added "$ADDED_JSON" \
    --argjson recommended "$RECOMMENDED_JSON" \
    '{
      tdr_file: $tdr_file,
      servers_active: $enabled,
      servers_added_disabled: $added,
      servers_recommended: $recommended,
      total_active: ($enabled | length),
      total_recommended: ($recommended | length)
    }'
else
  echo "MCP Server Recommendations (based on TDR)"
  echo "=========================================="
  echo ""

  if [[ ${#ALREADY_ENABLED[@]} -gt 0 ]]; then
    echo "Active servers (already enabled):"
    for key in "${ALREADY_ENABLED[@]}"; do
      NAME=$(jq -r --arg k "$key" '.servers[$k].name' "$REGISTRY_FILE")
      echo "  $key — $NAME"
    done
    echo ""
  fi

  if [[ ${#ALREADY_ADDED[@]} -gt 0 ]]; then
    echo "Added but disabled:"
    for key in "${ALREADY_ADDED[@]}"; do
      NAME=$(jq -r --arg k "$key" '.servers[$k].name' "$REGISTRY_FILE")
      echo "  $key — $NAME (run: enable-mcp-server.sh $key enable)"
    done
    echo ""
  fi

  if [[ ${#RECOMMENDED[@]} -gt 0 ]]; then
    printf "%-20s %-50s %s\n" "Server" "Description" "Auth"
    printf "%-20s %-50s %s\n" "------" "-----------" "----"

    for key in "${RECOMMENDED[@]}"; do
      NAME=$(jq -r --arg k "$key" '.servers[$k].name' "$REGISTRY_FILE")
      DESC=$(jq -r --arg k "$key" '.servers[$k].description' "$REGISTRY_FILE")
      ENV_KEYS=$(jq -r --arg k "$key" '.servers[$k].env | keys | join(", ")' "$REGISTRY_FILE" 2>/dev/null || true)

      if [[ -n "$ENV_KEYS" ]]; then
        AUTH="$ENV_KEYS"
      else
        AUTH="none (CLI auth)"
      fi

      printf "%-20s %-50s %s\n" "$key" "$DESC" "$AUTH"
    done

    echo ""
    echo "To add a server:  bash scripts/add-mcp-server.sh <server-key>"
    echo "To add all:       bash scripts/add-mcp-server.sh --all-recommended"
  else
    echo "No new servers to recommend — all TDR-matched servers are already configured."
  fi
fi

exit 0
