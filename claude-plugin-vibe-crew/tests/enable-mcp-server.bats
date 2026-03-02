#!/usr/bin/env bats
# tests/enable-mcp-server.bats
# Tests for scripts/enable-mcp-server.sh — toggle MCP server disabled flag

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/enable-mcp-server.sh"

  # Back up real plugin .mcp.json
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_MCP="$PLUGIN_ROOT/.mcp.json"
  BACKUP_MCP="$PLUGIN_ROOT/.mcp.json.bak"
  cp "$ORIGINAL_MCP" "$BACKUP_MCP"

  # Create a test .mcp.json with mixed enabled/disabled servers
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "disabled": false
    },
    "supabase": {
      "command": "npx",
      "args": ["-y", "supabase-mcp-server@latest"],
      "env": {
        "SUPABASE_URL": "",
        "SUPABASE_SERVICE_ROLE_KEY": ""
      },
      "disabled": true
    },
    "stripe": {
      "command": "npx",
      "args": ["-y", "@stripe/mcp@latest"],
      "env": {
        "STRIPE_SECRET_KEY": ""
      },
      "disabled": true
    }
  }
}
EOF

  cd "$TEST_PROJECT_DIR"
}

teardown() {
  if [[ -f "$BACKUP_MCP" ]]; then
    mv "$BACKUP_MCP" "$ORIGINAL_MCP"
  fi
  teardown_vibecrew_dir
}

# =============================================================================
# No arguments — usage
# =============================================================================

@test "no arguments: prints usage and exits 1" {
  run bash "$SCRIPT"
  assert_failure
  assert_output --partial "Usage:"
}

# =============================================================================
# Enable a disabled server
# =============================================================================

@test "enable disabled server: sets disabled to false" {
  run bash "$SCRIPT" supabase enable
  assert_success
  assert_output --partial "enableed successfully" || assert_output --partial "enabled successfully"

  local disabled
  disabled=$(jq -r '.mcpServers.supabase.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "false" ]
}

@test "enable server (implicit action): defaults to enable" {
  run bash "$SCRIPT" supabase
  assert_success

  local disabled
  disabled=$(jq -r '.mcpServers.supabase.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "false" ]
}

# =============================================================================
# Disable an enabled server
# =============================================================================

@test "disable enabled server: sets disabled to true" {
  run bash "$SCRIPT" context7 disable
  assert_success
  assert_output --partial "disabled successfully" || assert_output --partial "disabled successfully"

  local disabled
  disabled=$(jq -r '.mcpServers.context7.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "true" ]
}

# =============================================================================
# Server not found
# =============================================================================

@test "nonexistent server: exits 1 with error" {
  run bash "$SCRIPT" nonexistent-server enable
  assert_failure
  assert_output --partial "not found in .mcp.json"
}

@test "nonexistent server: lists available servers" {
  run bash "$SCRIPT" nonexistent-server enable
  assert_failure
  assert_output --partial "Available servers:"
}

# =============================================================================
# Invalid action
# =============================================================================

@test "invalid action: exits 1 with error" {
  run bash "$SCRIPT" context7 toggle
  assert_failure
  assert_output --partial "Action must be 'enable' or 'disable'"
}

# =============================================================================
# Idempotent enable/disable
# =============================================================================

@test "enable already enabled server: reports no changes needed" {
  run bash "$SCRIPT" context7 enable
  assert_success
  assert_output --partial "already enabled"
}

@test "disable already disabled server: reports no changes needed" {
  run bash "$SCRIPT" supabase disable
  assert_success
  assert_output --partial "already disabled"
}

# =============================================================================
# JSON validity after modification
# =============================================================================

@test "enable: .mcp.json remains valid JSON" {
  run bash "$SCRIPT" supabase enable
  assert_success

  jq empty "$ORIGINAL_MCP" 2>/dev/null
  [ $? -eq 0 ]
}

@test "disable: .mcp.json remains valid JSON" {
  run bash "$SCRIPT" context7 disable
  assert_success

  jq empty "$ORIGINAL_MCP" 2>/dev/null
  [ $? -eq 0 ]
}

# =============================================================================
# Missing env vars warning on enable
# =============================================================================

@test "enable server with empty env vars: warns about missing variables" {
  # Unset any potential env vars that could interfere
  unset SUPABASE_URL 2>/dev/null || true
  unset SUPABASE_SERVICE_ROLE_KEY 2>/dev/null || true

  run bash "$SCRIPT" supabase enable
  assert_success
  assert_output --partial "WARNING"
  assert_output --partial "environment variables are not set"
}

@test "enable server without env vars: no warning" {
  # context7 has no env vars, so disable it first then re-enable
  run bash "$SCRIPT" context7 disable
  assert_success

  run bash "$SCRIPT" context7 enable
  assert_success
  refute_output --partial "WARNING"
}

# =============================================================================
# Missing .mcp.json
# =============================================================================

@test "missing .mcp.json: exits 1 with error" {
  rm -f "$ORIGINAL_MCP"
  run bash "$SCRIPT" context7 enable
  assert_failure
  assert_output --partial ".mcp.json not found"
}
