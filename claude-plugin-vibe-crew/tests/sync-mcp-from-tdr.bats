#!/usr/bin/env bats
# tests/sync-mcp-from-tdr.bats
# Tests for scripts/sync-mcp-from-tdr.sh — auto-enable MCP servers from TDR

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/sync-mcp-from-tdr.sh"

  # Back up real plugin .mcp.json and registry
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_MCP="$PLUGIN_ROOT/.mcp.json"
  BACKUP_MCP="$PLUGIN_ROOT/.mcp.json.bak"
  cp "$ORIGINAL_MCP" "$BACKUP_MCP"

  ORIGINAL_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json"
  BACKUP_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json.bak"
  cp "$ORIGINAL_REGISTRY" "$BACKUP_REGISTRY"

  # Create a minimal .mcp.json with known servers (supabase in mcp, stripe not)
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

# Helper: extract the JSON report block from mixed text+JSON output.
# The sync script calls enable-mcp-server.sh which prints text lines,
# then the sync script outputs a final JSON report via jq -n.
extract_json() {
  echo "$1" | sed -n '/^{/,/^}/p'
}

# =============================================================================
# No TDR file
# =============================================================================

@test "no TDR file: exits 1 with error" {
  run bash "$SCRIPT"
  assert_failure
  assert_output --partial "No TDR file found"
}

@test "explicit nonexistent TDR path: exits 1" {
  run bash "$SCRIPT" "/tmp/nonexistent-tdr.md"
  assert_failure
  assert_output --partial "No TDR file found"
}

# =============================================================================
# TDR with matching technologies
# =============================================================================

@test "TDR mentions supabase: enables supabase in .mcp.json" {
  # Create a TDR that mentions supabase
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# Technology Decision Record

## Database
We will use Supabase for our database and authentication layer.

## Hosting
Static hosting via CDN.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  # supabase was in .mcp.json (disabled), should now be enabled
  local disabled
  disabled=$(jq -r '.mcpServers.supabase.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "false" ]
}

@test "TDR mentions supabase: JSON output reports it as enabled" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# Technology Decision Record
We chose Supabase for the backend.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  local json_out enabled_count
  json_out=$(extract_json "$output")
  enabled_count=$(echo "$json_out" | jq '.total_enabled')
  [ "$enabled_count" -ge 1 ]
}

# =============================================================================
# Pattern matching is case-insensitive
# =============================================================================

@test "case-insensitive: SUPABASE in TDR matches supabase pattern" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Database: SUPABASE
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  local disabled
  disabled=$(jq -r '.mcpServers.supabase.disabled' "$ORIGINAL_MCP")
  [ "$disabled" = "false" ]
}

# =============================================================================
# Server not in .mcp.json: recommend instead of enable
# =============================================================================

@test "TDR mentions stripe (not in .mcp.json): recommends it" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Payments: Stripe for subscription billing.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  local json_out recommended_count
  json_out=$(extract_json "$output")
  recommended_count=$(echo "$json_out" | jq '.total_recommended')
  [ "$recommended_count" -ge 1 ]

  # Stripe should appear in recommended list
  local has_stripe
  has_stripe=$(echo "$json_out" | jq '[.servers_recommended[] | select(.key == "stripe")] | length')
  [ "$has_stripe" = "1" ]
}

@test "recommended server: includes auth_required and env_vars" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We use Stripe for payments.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  local json_out auth env_count
  json_out=$(extract_json "$output")
  auth=$(echo "$json_out" | jq -r '.servers_recommended[] | select(.key == "stripe") | .auth_required')
  [ "$auth" = "true" ]

  env_count=$(echo "$json_out" | jq '.servers_recommended[] | select(.key == "stripe") | .env_vars | length')
  [ "$env_count" -ge 1 ]
}

# =============================================================================
# TDR with no matching technologies
# =============================================================================

@test "TDR with no matches: output has zero enabled and recommended" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We will build a static HTML website with no external services.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  local json_out enabled_count recommended_count
  json_out=$(extract_json "$output")
  enabled_count=$(echo "$json_out" | jq '.total_enabled')
  recommended_count=$(echo "$json_out" | jq '.total_recommended')
  [ "$enabled_count" = "0" ]
  [ "$recommended_count" = "0" ]
}

# =============================================================================
# JSON output is valid
# =============================================================================

@test "output contains valid JSON with required fields" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Database: Supabase. Payments: Stripe. Hosting: Vercel.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  # Extract and validate JSON structure
  local json_out
  json_out=$(extract_json "$output")
  echo "$json_out" | jq empty 2>/dev/null
  [ $? -eq 0 ]

  local has_tdr has_enabled has_recommended has_note
  has_tdr=$(echo "$json_out" | jq 'has("tdr_file")')
  has_enabled=$(echo "$json_out" | jq 'has("servers_enabled")')
  has_recommended=$(echo "$json_out" | jq 'has("servers_recommended")')
  has_note=$(echo "$json_out" | jq 'has("note")')
  [ "$has_tdr" = "true" ]
  [ "$has_enabled" = "true" ]
  [ "$has_recommended" = "true" ]
  [ "$has_note" = "true" ]
}

# =============================================================================
# Auto-detect TDR file location
# =============================================================================

@test "auto-detect: finds TDR in docs/ directory" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-myproject.md" <<'EOF'
# TDR
Stack: Supabase for database.
EOF

  run bash "$SCRIPT"
  assert_success

  local json_out tdr_path
  json_out=$(extract_json "$output")
  tdr_path=$(echo "$json_out" | jq -r '.tdr_file')
  [[ "$tdr_path" == *"TDR-myproject.md" ]]
}

# =============================================================================
# Fallback when registry is missing
# =============================================================================

@test "no registry: falls back to hardcoded mappings with warning" {
  rm -f "$ORIGINAL_REGISTRY"

  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We use supabase for the database.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md"
  assert_success

  local json_out enabled_count
  json_out=$(extract_json "$output")
  enabled_count=$(echo "$json_out" | jq '.total_enabled')
  [ "$enabled_count" -ge 1 ]
}
