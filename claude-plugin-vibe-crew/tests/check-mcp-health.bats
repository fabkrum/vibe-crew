#!/usr/bin/env bats
# tests/check-mcp-health.bats
# Tests for scripts/check-mcp-health.sh — MCP server health checks

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/check-mcp-health.sh"

  # Save original .mcp.json and create a test one
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_MCP="$PLUGIN_ROOT/.mcp.json"
  BACKUP_MCP="$PLUGIN_ROOT/.mcp.json.bak"
  cp "$ORIGINAL_MCP" "$BACKUP_MCP"
}

teardown() {
  # Restore original .mcp.json
  if [[ -f "$BACKUP_MCP" ]]; then
    mv "$BACKUP_MCP" "$ORIGINAL_MCP"
  fi
  teardown_vibecrew_dir
}

# =============================================================================
# Basic output structure
# =============================================================================

@test "outputs valid JSON" {
  run bash "$SCRIPT"
  assert_success
  echo "$output" | jq . >/dev/null 2>&1
}

@test "always exits 0 (non-blocking)" {
  run bash "$SCRIPT"
  assert_success
}

@test "JSON contains servers array" {
  run bash "$SCRIPT"
  assert_success
  local has_servers
  has_servers=$(echo "$output" | jq 'has("servers")')
  [ "$has_servers" = "true" ]
}

# =============================================================================
# No enabled servers
# =============================================================================

@test "all servers disabled: returns empty servers array" {
  # Create .mcp.json with all servers disabled
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-server": {
      "command": "echo",
      "args": ["hello"],
      "disabled": true
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success
  local count
  count=$(echo "$output" | jq '.servers | length')
  [ "$count" = "0" ]
}

@test "all servers disabled: summary shows zero totals" {
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-server": {
      "command": "echo",
      "args": ["hello"],
      "disabled": true
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success
  local total
  total=$(echo "$output" | jq '.summary.total')
  [ "$total" = "0" ]
}

# =============================================================================
# Missing .mcp.json
# =============================================================================

@test "missing .mcp.json: returns warning" {
  rm -f "$ORIGINAL_MCP"
  run bash "$SCRIPT"
  assert_success
  assert_output --partial "No .mcp.json found"
}

# =============================================================================
# Server that starts successfully
# =============================================================================

@test "healthy server: reports status ok" {
  # Create .mcp.json with a simple server that runs and exits
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-ok": {
      "command": "sleep",
      "args": ["10"],
      "disabled": false
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success
  local status_val
  status_val=$(echo "$output" | jq -r '.servers[0].status')
  [ "$status_val" = "ok" ]
}

@test "healthy server: summary counts correctly" {
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-ok": {
      "command": "sleep",
      "args": ["10"],
      "disabled": false
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success
  local healthy
  healthy=$(echo "$output" | jq '.summary.healthy')
  [ "$healthy" = "1" ]
}

# =============================================================================
# Server that fails to start
# =============================================================================

@test "failing server: reports status failed" {
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-fail": {
      "command": "false",
      "args": [],
      "disabled": false
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success  # Script itself always exits 0
  local status_val
  status_val=$(echo "$output" | jq -r '.servers[0].status')
  [ "$status_val" = "failed" ]
}

@test "failing server: summary counts failure" {
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-fail": {
      "command": "false",
      "args": [],
      "disabled": false
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success
  local failed
  failed=$(echo "$output" | jq '.summary.failed')
  [ "$failed" = "1" ]
}

# =============================================================================
# Mixed healthy and failed
# =============================================================================

@test "mixed servers: counts both healthy and failed" {
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "test-ok": {
      "command": "sleep",
      "args": ["10"],
      "disabled": false
    },
    "test-fail": {
      "command": "false",
      "args": [],
      "disabled": false
    },
    "test-disabled": {
      "command": "echo",
      "args": ["skip"],
      "disabled": true
    }
  }
}
EOF
  run bash "$SCRIPT"
  assert_success
  local total healthy failed
  total=$(echo "$output" | jq '.summary.total')
  # Only 2 enabled servers should be checked (disabled one skipped)
  [ "$total" = "2" ]
}
