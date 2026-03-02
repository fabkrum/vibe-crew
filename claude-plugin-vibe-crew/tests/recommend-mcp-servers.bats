#!/usr/bin/env bats
# tests/recommend-mcp-servers.bats
# Tests for scripts/recommend-mcp-servers.sh — recommend MCP servers from TDR

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/recommend-mcp-servers.sh"

  # Back up real plugin .mcp.json and registry
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_MCP="$PLUGIN_ROOT/.mcp.json"
  BACKUP_MCP="$PLUGIN_ROOT/.mcp.json.bak"
  cp "$ORIGINAL_MCP" "$BACKUP_MCP"

  ORIGINAL_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json"
  BACKUP_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json.bak"
  cp "$ORIGINAL_REGISTRY" "$BACKUP_REGISTRY"

  # Create a test .mcp.json: context7 active, supabase added but disabled
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
    }
  }
}
EOF

  # Create a minimal registry
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
    },
    "vercel": {
      "name": "Vercel",
      "description": "Deployment, serverless functions, and edge network",
      "category": "hosting",
      "patterns": ["vercel"],
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.vercel.com"],
      "env": {
        "VERCEL_TOKEN": "Token from Vercel account settings"
      },
      "docs_url": "https://vercel.com/docs"
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
  if [[ -f "$BACKUP_REGISTRY" ]]; then
    mv "$BACKUP_REGISTRY" "$ORIGINAL_REGISTRY"
  fi
  teardown_vibecrew_dir
}

# =============================================================================
# No TDR file
# =============================================================================

@test "no TDR file: exits 1 with error" {
  run bash "$SCRIPT"
  assert_failure
  assert_output --partial "No TDR file found"
}

@test "--json with no TDR: exits 1 with error" {
  run bash "$SCRIPT" --json
  assert_failure
  assert_output --partial "No TDR file found"
}

# =============================================================================
# --json mode output structure
# =============================================================================

@test "--json: outputs valid JSON" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Database: Supabase. Payments: Stripe. Hosting: Vercel.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  echo "$output" | jq empty 2>/dev/null
  [ $? -eq 0 ]
}

@test "--json: contains required fields" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Stripe for payments.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  local has_tdr has_active has_added has_recommended
  has_tdr=$(echo "$output" | jq 'has("tdr_file")')
  has_active=$(echo "$output" | jq 'has("servers_active")')
  has_added=$(echo "$output" | jq 'has("servers_added_disabled")')
  has_recommended=$(echo "$output" | jq 'has("servers_recommended")')
  [ "$has_tdr" = "true" ]
  [ "$has_active" = "true" ]
  [ "$has_added" = "true" ]
  [ "$has_recommended" = "true" ]
}

# =============================================================================
# Categorization: active vs added-disabled vs recommended
# =============================================================================

@test "--json: active servers are in servers_active" {
  # context7 is in .mcp.json and enabled; the TDR must mention context7 for it to appear
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We use context7 for documentation lookup.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  local active_count
  active_count=$(echo "$output" | jq '.servers_active | length')
  [ "$active_count" -ge 1 ]

  local has_context7
  has_context7=$(echo "$output" | jq '[.servers_active[] | select(. == "context7")] | length')
  [ "$has_context7" = "1" ]
}

@test "--json: disabled servers in .mcp.json appear in servers_added_disabled" {
  # supabase is in .mcp.json but disabled; TDR must mention supabase
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Database: Supabase for our backend.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  local added_count
  added_count=$(echo "$output" | jq '.servers_added_disabled | length')
  [ "$added_count" -ge 1 ]

  local has_supabase
  has_supabase=$(echo "$output" | jq '[.servers_added_disabled[] | select(. == "supabase")] | length')
  [ "$has_supabase" = "1" ]
}

@test "--json: servers not in .mcp.json appear in servers_recommended" {
  # stripe is NOT in .mcp.json; TDR mentions it
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Payments via Stripe.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  local rec_count
  rec_count=$(echo "$output" | jq '.servers_recommended | length')
  [ "$rec_count" -ge 1 ]

  local has_stripe
  has_stripe=$(echo "$output" | jq '[.servers_recommended[] | select(.key == "stripe")] | length')
  [ "$has_stripe" = "1" ]
}

# =============================================================================
# Human-readable mode (default)
# =============================================================================

@test "human mode: prints header" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We use Supabase and Stripe.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success
  assert_output --partial "MCP Server Recommendations"
}

@test "human mode: shows active servers section" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We rely on context7 for docs.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success
  assert_output --partial "Active servers"
  assert_output --partial "context7"
}

@test "human mode: shows recommended servers with add instructions" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Payments: Stripe integration.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success
  assert_output --partial "stripe"
  assert_output --partial "add-mcp-server.sh"
}

@test "human mode: no matches shows no-recommendation message" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Plain HTML and CSS. No external services.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success
  assert_output --partial "No new servers to recommend"
}

# =============================================================================
# Recommended server detail fields
# =============================================================================

@test "--json: recommended entries include auth and env_vars" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Stripe for billing.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  local auth
  auth=$(echo "$output" | jq -r '.servers_recommended[] | select(.key == "stripe") | .auth_required')
  [ "$auth" = "true" ]

  local env_var
  env_var=$(echo "$output" | jq -r '.servers_recommended[] | select(.key == "stripe") | .env_vars[0]')
  [ "$env_var" = "STRIPE_SECRET_KEY" ]
}

@test "--json: recommended entry without env vars has auth_required false" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Testing: Playwright for E2E.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --json
  assert_success

  local auth
  auth=$(echo "$output" | jq -r '.servers_recommended[] | select(.key == "playwright") | .auth_required')
  [ "$auth" = "false" ]
}

# =============================================================================
# Missing registry
# =============================================================================

@test "missing registry: exits 1 with error" {
  rm -f "$ORIGINAL_REGISTRY"

  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Supabase
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_failure
  assert_output --partial "MCP registry not found"
}
