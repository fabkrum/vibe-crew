#!/usr/bin/env bash
# scripts/sync-mcp-from-tdr.sh
# Reads the TDR file and auto-enables MCP servers for matching technologies.
# Uses templates/mcp-registry.json for pattern matching when available,
# falls back to hardcoded mappings for backward compatibility.
# Usage:
#   sync-mcp-from-tdr.sh                    # Auto-detect TDR file
#   sync-mcp-from-tdr.sh <path-to-tdr>      # Explicit TDR path
# Outputs JSON report of what was enabled and what is recommended.
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
ADD_SCRIPT="$PLUGIN_ROOT/scripts/add-mcp-server.sh"
REGISTRY_FILE="$PLUGIN_ROOT/templates/mcp-registry.json"
MCP_FILE="$PLUGIN_ROOT/.mcp.json"
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

# --- Match and enable ---
ENABLED=()
SKIPPED=()
RECOMMENDED_JSON="[]"

if [[ -f "$REGISTRY_FILE" ]]; then
  # --- Registry-driven matching ---
  KEYS=$(jq -r '.servers | keys[]' "$REGISTRY_FILE")

  while IFS= read -r key; do
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

    # Check if server is already in .mcp.json
    IN_MCP=$(jq -r --arg k "$key" '.mcpServers | has($k)' "$MCP_FILE")

    if [[ "$IN_MCP" == "true" ]]; then
      # Server exists — enable it
      if bash "$ENABLE_SCRIPT" "$key" enable 2>/dev/null; then
        ENABLED+=("$key")
      else
        SKIPPED+=("$key")
      fi
    else
      # Server not in .mcp.json — add and enable it from registry
      if bash "$ADD_SCRIPT" "$key" --enable 2>/dev/null; then
        ENABLED+=("$key")
      else
        # Add failed — recommend it instead
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
    fi
  done <<< "$KEYS"
else
  # --- Fallback: hardcoded mappings (backward compatibility) ---
  echo "WARNING: MCP registry not found at $REGISTRY_FILE. Using hardcoded mappings." >&2
  FALLBACK_MAPPINGS=(
    "supabase:supabase"
    "stripe:stripe"
    "vercel:vercel"
    "figma:figma"
    "sentry:sentry"
  )

  for mapping in "${FALLBACK_MAPPINGS[@]}"; do
    PATTERN="${mapping%%:*}"
    SERVER="${mapping##*:}"

    if echo "$TDR_CONTENT" | grep -q "$PATTERN"; then
      # Try enable first (if already in .mcp.json), otherwise add
      if bash "$ENABLE_SCRIPT" "$SERVER" enable 2>/dev/null; then
        ENABLED+=("$SERVER")
      elif bash "$ADD_SCRIPT" "$SERVER" --enable 2>/dev/null; then
        ENABLED+=("$SERVER")
      else
        SKIPPED+=("$SERVER")
      fi
    fi
  done
fi

# --- Output JSON report ---
ENABLED_JSON="[]"
if [[ ${#ENABLED[@]} -gt 0 ]]; then
  ENABLED_JSON=$(printf '%s\n' "${ENABLED[@]}" | jq -R . | jq -s .)
fi

SKIPPED_JSON="[]"
if [[ ${#SKIPPED[@]} -gt 0 ]]; then
  SKIPPED_JSON=$(printf '%s\n' "${SKIPPED[@]}" | jq -R . | jq -s .)
fi

TOTAL_RECOMMENDED=$(echo "$RECOMMENDED_JSON" | jq 'length')

jq -n \
  --arg tdr_file "$TDR_FILE" \
  --argjson enabled "$ENABLED_JSON" \
  --argjson skipped "$SKIPPED_JSON" \
  --argjson recommended "$RECOMMENDED_JSON" \
  --argjson enabled_count "${#ENABLED[@]}" \
  --argjson recommended_count "$TOTAL_RECOMMENDED" \
  '{
    tdr_file: $tdr_file,
    servers_enabled: $enabled,
    servers_skipped: $skipped,
    servers_recommended: $recommended,
    total_enabled: $enabled_count,
    total_recommended: $recommended_count,
    note: "Servers were enabled based on technology mentions in the TDR. Set required environment variables for authenticated servers."
  }'

exit 0
