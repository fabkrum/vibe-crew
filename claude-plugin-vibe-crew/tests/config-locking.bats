#!/usr/bin/env bats
# tests/config-locking.bats
# Tests verifying config.json concurrency protection via named locks.
# Covers: save-profile.sh, enable-mcp-server.sh, add-mcp-server.sh, refresh-pricing.sh

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_MCP="$PLUGIN_ROOT/.mcp.json"
  BACKUP_MCP="$PLUGIN_ROOT/.mcp.json.bak"
  cp "$ORIGINAL_MCP" "$BACKUP_MCP"

  ORIGINAL_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json"
  BACKUP_REGISTRY="$PLUGIN_ROOT/templates/mcp-registry.json.bak"
  cp "$ORIGINAL_REGISTRY" "$BACKUP_REGISTRY"

  # Minimal .mcp.json for enable/add tests
  cat > "$ORIGINAL_MCP" <<'EOF'
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "disabled": true
    }
  }
}
EOF

  # Minimal registry
  cat > "$ORIGINAL_REGISTRY" <<'EOF'
{
  "schema_version": "1.0.0",
  "servers": {
    "context7": {
      "name": "Context7",
      "description": "Docs",
      "category": "developer-tools",
      "patterns": ["context7"],
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"],
      "env": {},
      "docs_url": "https://example.com"
    },
    "playwright": {
      "name": "Playwright",
      "description": "Testing",
      "category": "testing",
      "patterns": ["playwright"],
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {},
      "docs_url": "https://example.com"
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
# save-profile.sh: single atomic write (profile + gamification in one jq call)
# =============================================================================

@test "save-profile: writes profile and gamification in a single operation" {
  # Write a marker key into config.json that would be lost if two separate
  # read-modify-writes happened and a concurrent writer interleaved.
  jq '.marker_key = "should_survive"' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/save-profile.sh" --role developer --gamification full
  assert_success

  # Both profile and gamification should be present
  run jq -r '.user_profile.role' "$VIBECREW_DIR/config.json"
  assert_output "developer"
  run jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json"
  assert_output "true"
  run jq -r '.gamification.streak_reminders' "$VIBECREW_DIR/config.json"
  assert_output "true"

  # Marker key must survive the single atomic write
  run jq -r '.marker_key' "$VIBECREW_DIR/config.json"
  assert_output "should_survive"
}

@test "save-profile: gamification=disabled sets all flags in single write" {
  run bash "$SCRIPTS_DIR/save-profile.sh" --role learner --gamification disabled
  assert_success

  run jq -r '.user_profile.role' "$VIBECREW_DIR/config.json"
  assert_output "learner"
  run jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json"
  assert_output "false"
  run jq -r '.gamification.show_xp_in_status' "$VIBECREW_DIR/config.json"
  assert_output "false"
  run jq -r '.gamification.streak_reminders' "$VIBECREW_DIR/config.json"
  assert_output "false"
}

@test "save-profile: gamification=score_only sets correct flags in single write" {
  run bash "$SCRIPTS_DIR/save-profile.sh" --gamification score_only
  assert_success

  run jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json"
  assert_output "true"
  run jq -r '.gamification.show_xp_in_status' "$VIBECREW_DIR/config.json"
  assert_output "false"
  run jq -r '.gamification.streak_reminders' "$VIBECREW_DIR/config.json"
  assert_output "false"
}

@test "save-profile: gamification=light sets correct flags in single write" {
  run bash "$SCRIPTS_DIR/save-profile.sh" --gamification light
  assert_success

  run jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json"
  assert_output "true"
  run jq -r '.gamification.show_xp_in_status' "$VIBECREW_DIR/config.json"
  assert_output "true"
  run jq -r '.gamification.streak_reminders' "$VIBECREW_DIR/config.json"
  assert_output "false"
}

# =============================================================================
# Lock acquisition: config lock dir is created and cleaned up
# =============================================================================

@test "save-profile: no config lock remains after successful run" {
  run bash "$SCRIPTS_DIR/save-profile.sh" --role developer
  assert_success

  # Lock dir should be cleaned up by EXIT trap
  [ ! -d "$VIBECREW_DIR/locks/config" ]
}

@test "enable-mcp-server: no config lock remains after successful run" {
  run bash "$SCRIPTS_DIR/enable-mcp-server.sh" context7 enable
  assert_success

  [ ! -d "$VIBECREW_DIR/locks/config" ]
}

@test "add-mcp-server: no config lock remains after successful run" {
  run bash "$SCRIPTS_DIR/add-mcp-server.sh" playwright
  assert_success

  [ ! -d "$VIBECREW_DIR/locks/config" ]
}

@test "refresh-pricing: no config lock remains after successful run" {
  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success

  [ ! -d "$VIBECREW_DIR/locks/config" ]
}

# =============================================================================
# PID-suffixed temp files: no bare .tmp leftovers
# =============================================================================

@test "enable-mcp-server: uses PID-suffixed temp file for config.json" {
  run bash "$SCRIPTS_DIR/enable-mcp-server.sh" context7 enable
  assert_success

  # No bare .tmp file should remain
  [ ! -f "$VIBECREW_DIR/config.json.tmp" ]
}

@test "add-mcp-server: uses PID-suffixed temp file for config.json" {
  run bash "$SCRIPTS_DIR/add-mcp-server.sh" playwright
  assert_success

  [ ! -f "$VIBECREW_DIR/config.json.tmp" ]
}

@test "refresh-pricing: uses PID-suffixed temp file" {
  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success

  [ ! -f "$VIBECREW_DIR/config.json.tmp" ]
}

# =============================================================================
# Concurrent writes: held lock blocks second writer
# =============================================================================

@test "save-profile: blocks when config lock is already held" {
  # Manually acquire the config lock (simulating a concurrent writer)
  mkdir -p "$VIBECREW_DIR/locks/config"
  cat > "$VIBECREW_DIR/locks/config/info.json" <<EOF
{
  "locked_by": "test-concurrent-writer",
  "pid": $$,
  "locked_at": "$(date +%s)000",
  "lock_name": "config",
  "timeout_seconds": 60
}
EOF

  # Run save-profile with a very short lock timeout so it fails fast
  # The lock library reads from config.json locks.wait_timeout_secs
  jq '.locks.wait_timeout_secs = 1' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.setup" \
    && mv "$VIBECREW_DIR/config.json.setup" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/save-profile.sh" --role developer
  assert_failure
  assert_output --partial "Could not acquire"

  # Clean up the lock
  rm -rf "$VIBECREW_DIR/locks/config"
}

@test "enable-mcp-server: blocks when config lock is already held" {
  mkdir -p "$VIBECREW_DIR/locks/config"
  cat > "$VIBECREW_DIR/locks/config/info.json" <<EOF
{
  "locked_by": "test-concurrent-writer",
  "pid": $$,
  "locked_at": "$(date +%s)000",
  "lock_name": "config",
  "timeout_seconds": 60
}
EOF

  jq '.locks.wait_timeout_secs = 1' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.setup" \
    && mv "$VIBECREW_DIR/config.json.setup" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/enable-mcp-server.sh" context7 enable
  assert_failure
  assert_output --partial "Could not acquire"

  rm -rf "$VIBECREW_DIR/locks/config"
}

# =============================================================================
# Stale lock recovery: dead PID lock is broken through
# =============================================================================

@test "save-profile: breaks stale lock from dead process" {
  # Create a lock owned by a PID that definitely doesn't exist
  mkdir -p "$VIBECREW_DIR/locks/config"
  cat > "$VIBECREW_DIR/locks/config/info.json" <<EOF
{
  "locked_by": "dead-process",
  "pid": 99999,
  "locked_at": "1000000000000",
  "lock_name": "config",
  "timeout_seconds": 60
}
EOF

  run bash "$SCRIPTS_DIR/save-profile.sh" --role developer
  assert_success
  assert_output --partial "Profile saved"
}

# =============================================================================
# Data integrity: concurrent-safe writes preserve all fields
# =============================================================================

@test "save-profile: preserves existing config keys during write" {
  # Add custom keys to config.json
  jq '.custom_setting = "important" | .mcp_servers.context7 = true' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/save-profile.sh" --role designer --gamification light
  assert_success

  # Profile and gamification should be set
  run jq -r '.user_profile.role' "$VIBECREW_DIR/config.json"
  assert_output "designer"
  run jq -r '.gamification.show_xp_in_status' "$VIBECREW_DIR/config.json"
  assert_output "true"

  # Existing keys must survive
  run jq -r '.custom_setting' "$VIBECREW_DIR/config.json"
  assert_output "important"
  run jq -r '.mcp_servers.context7' "$VIBECREW_DIR/config.json"
  assert_output "true"
}

@test "enable-mcp-server: preserves existing config keys during write" {
  jq '.custom_setting = "keep_me"' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/enable-mcp-server.sh" context7 enable
  assert_success

  run jq -r '.custom_setting' "$VIBECREW_DIR/config.json"
  assert_output "keep_me"
  run jq -r '.mcp_servers.context7' "$VIBECREW_DIR/config.json"
  assert_output "true"
}

@test "refresh-pricing: preserves existing config keys during write" {
  jq '.custom_setting = "keep_me"' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/refresh-pricing.sh"
  assert_success

  run jq -r '.custom_setting' "$VIBECREW_DIR/config.json"
  assert_output "keep_me"
  run jq -e '.pricing.opus' "$VIBECREW_DIR/config.json"
  assert_success
}
