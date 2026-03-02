#!/usr/bin/env bats
# tests/add-mcp-server.bats
# Tests for scripts/add-mcp-server.sh — add MCP servers from registry

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/add-mcp-server.sh"

  # Back up real plugin .mcp.json and registry
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_MCP="$PLUGIN_ROOT/.mcp.json"
  BACKUP_MCP="$PLUGIN_ROOT/.mcp.json.bak"
  cp "$ORIGINAL_MCP" "$BACKUP_MCP"

  ORIGINAL_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json"
  BACKUP_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json.bak"
  cp "$ORIGINAL_REGISTRY" "$BACKUP_REGISTRY"

  # Create a minimal .mcp.json with one existing server
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "disabled": false
    }
  }
}
EOF

  # Create a minimal registry for deterministic testing
  cat > "$ORIGINAL_REGISTRY" <<'EOF'
{
  "schema_version": "1.0.0",
  "servers": {
    "context7": {
      "name": "Context7",
      "description": "Up-to-date documentation for libraries and frameworks",
      "category": "developer-tools",
      "patterns": ["context7"],
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "docs_url": "https://github.com/nichochar/context7"
    },
    "supabase": {
      "name": "Supabase",
      "description": "PostgreSQL database, auth, storage, and real-time subscriptions",
      "category": "database",
      "patterns": ["supabase"],
      "command": "npx",
      "args": ["-y", "supabase-mcp-server@latest"],
      "env": {
        "SUPABASE_URL": "Supabase project URL",
        "SUPABASE_SERVICE_ROLE_KEY": "Service role key from project settings"
      },
      "docs_url": "https://supabase.com/docs/guides/getting-started/mcp"
    },
    "playwright": {
      "name": "Playwright",
      "description": "End-to-end browser testing and automation",
      "category": "testing",
      "patterns": ["playwright"],
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {},
      "docs_url": "https://playwright.dev/docs/mcp"
    },
    "stripe": {
      "name": "Stripe",
      "description": "Payment processing, subscriptions, and billing",
      "category": "payments",
      "patterns": ["stripe"],
      "command": "npx",
      "args": ["-y", "@stripe/mcp@latest"],
      "env": {
        "STRIPE_SECRET_KEY": "Secret key from Stripe dashboard"
      },
      "docs_url": "https://docs.stripe.com/mcp"
    }
  }
}
EOF

  cd "$TEST_PROJECT_DIR"
}

teardown() {
  # Restore original files
  if [[ -f "$BACKUP_MCP" ]]; then
    mv "$BACKUP_MCP" "$ORIGINAL_MCP"
  fi
  if [[ -f "$BACKUP_REGISTRY" ]]; then
    mv "$BACKUP_REGISTRY" "$ORIGINAL_REGISTRY"
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
# --list mode
# =============================================================================

@test "--list: shows registry servers with header" {
  run bash "$SCRIPT" --list
  assert_success
  assert_output --partial "MCP Server Registry"
  assert_output --partial "Key"
  assert_output --partial "Category"
  assert_output --partial "Status"
}

@test "--list: shows active status for servers in .mcp.json" {
  run bash "$SCRIPT" --list
  assert_success
  # context7 is in .mcp.json and not disabled
  assert_output --partial "active"
}

@test "--list: shows -- status for servers not in .mcp.json" {
  run bash "$SCRIPT" --list
  assert_success
  # supabase is in registry but not in .mcp.json
  assert_output --partial "--"
}

# =============================================================================
# Add a single server
# =============================================================================

@test "add new server: exits 0 and adds to .mcp.json" {
  run bash "$SCRIPT" supabase
  assert_success
  assert_output --partial "Server 'supabase' added"

  # Verify it's in .mcp.json
  local exists
  exists=$(jq -r '.mcpServers | has("supabase")' "$ORIGINAL_MCP")
  [ "$exists" = "true" ]
}

@test "add new server: defaults to disabled" {
  run bash "$SCRIPT" playwright
  assert_success

  local disabled
  disabled=$(jq -r '.mcpServers.playwright.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "true" ]
}

@test "add new server: .mcp.json remains valid JSON" {
  run bash "$SCRIPT" supabase
  assert_success

  # Validate the resulting .mcp.json
  jq empty "$ORIGINAL_MCP" 2>/dev/null
  [ $? -eq 0 ]
}

@test "add new server: JSON output includes action and auth_required" {
  run bash "$SCRIPT" supabase
  assert_success

  # Script outputs text then a jq-formatted JSON object; extract JSON block
  local action auth
  action=$(echo "$output" | sed -n '/{/,/}/p' | jq -r '.action')
  auth=$(echo "$output" | sed -n '/{/,/}/p' | jq -r '.auth_required')
  [ "$action" = "added" ]
  [ "$auth" = "true" ]
}

@test "add server without env vars: auth_required is false" {
  run bash "$SCRIPT" playwright
  assert_success

  local auth
  auth=$(echo "$output" | sed -n '/{/,/}/p' | jq -r '.auth_required')
  [ "$auth" = "false" ]
}

# =============================================================================
# Duplicate detection
# =============================================================================

@test "add existing server: reports already exists" {
  run bash "$SCRIPT" context7
  assert_success
  assert_output --partial "already exists"
}

@test "add existing server: JSON output has action=exists" {
  run bash "$SCRIPT" context7
  assert_success

  local action
  action=$(echo "$output" | sed -n '/{/,/}/p' | jq -r '.action')
  [ "$action" = "exists" ]
}

# =============================================================================
# --enable flag
# =============================================================================

@test "add with --enable: server is not disabled" {
  run bash "$SCRIPT" supabase --enable
  assert_success

  local disabled
  disabled=$(jq -r '.mcpServers.supabase.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "false" ]
}

# =============================================================================
# Server not in registry
# =============================================================================

@test "add unknown server: exits 1 with error" {
  run bash "$SCRIPT" nonexistent-server
  assert_failure
  assert_output --partial "not found in registry"
}

# =============================================================================
# Missing registry file
# =============================================================================

@test "missing registry: exits 1 with error" {
  rm -f "$ORIGINAL_REGISTRY"
  run bash "$SCRIPT" supabase
  assert_failure
  assert_output --partial "MCP registry not found"
}

# =============================================================================
# Missing .mcp.json
# =============================================================================

@test "missing .mcp.json: exits 1 with error" {
  rm -f "$ORIGINAL_MCP"
  run bash "$SCRIPT" supabase
  assert_failure
  assert_output --partial ".mcp.json not found"
}
