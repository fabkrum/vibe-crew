#!/usr/bin/env bats
# tests/init-vibecrew-state.bats
# Tests for scripts/init-vibecrew-state.sh — .vibecrew/ directory initialization

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/init-vibecrew-state.sh"

  # Create a fresh temp directory with git init (don't use setup_vibecrew_dir
  # since this script creates the .vibecrew dir itself)
  TEST_PROJECT_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  git init "$TEST_PROJECT_DIR" --initial-branch=main >/dev/null 2>&1
  git -C "$TEST_PROJECT_DIR" config user.email "test@test.com"
  git -C "$TEST_PROJECT_DIR" config user.name "Test"

  export TEST_PROJECT_DIR
  export PROJECT_ROOT="$TEST_PROJECT_DIR"
  VIBECREW_DIR="$TEST_PROJECT_DIR/.vibecrew"
}

teardown() {
  if [[ -n "${TEST_PROJECT_DIR:-}" ]] && [[ -d "$TEST_PROJECT_DIR" ]]; then
    rm -rf "$TEST_PROJECT_DIR"
  fi
}

run_init() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
}

# =============================================================================
# Directory structure creation
# =============================================================================

@test "creates .vibecrew/ directory structure" {
  run_init
  assert_success
  [ -d "$VIBECREW_DIR" ]
}

@test "creates all required subdirectories" {
  run_init
  assert_success

  [ -d "$VIBECREW_DIR/sessions" ]
  [ -d "$VIBECREW_DIR/scores" ]
  [ -d "$VIBECREW_DIR/signals" ]
  [ -d "$VIBECREW_DIR/locks" ]
  [ -d "$VIBECREW_DIR/architecture" ]
  [ -d "$VIBECREW_DIR/releases" ]
  [ -d "$VIBECREW_DIR/handoffs" ]
  [ -d "$VIBECREW_DIR/workflows" ]
  [ -d "$VIBECREW_DIR/.backup" ]
}

# =============================================================================
# state.json schema
# =============================================================================

@test "creates state.json with correct schema" {
  run_init
  assert_success
  [ -f "$VIBECREW_DIR/state.json" ]

  # Validate JSON is parseable
  run jq '.' "$VIBECREW_DIR/state.json"
  assert_success

  # Check top-level keys
  local schema_version
  schema_version=$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")
  [ "$schema_version" = "1.5.0" ]

  # Check foundation structure
  local foundation_complete
  foundation_complete=$(jq -r '.foundation.complete' "$VIBECREW_DIR/state.json")
  [ "$foundation_complete" = "false" ]

  # Check all foundation artifacts exist
  local artifact_count
  artifact_count=$(jq '.foundation.artifacts | keys | length' "$VIBECREW_DIR/state.json")
  [ "$artifact_count" = "6" ]

  # Check active_feature fields
  local active_id
  active_id=$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")
  [ "$active_id" = "null" ]

  local phases_type
  phases_type=$(jq -r '.active_feature.phases_completed | type' "$VIBECREW_DIR/state.json")
  [ "$phases_type" = "array" ]

  # Check git section
  local default_branch
  default_branch=$(jq -r '.git.default_branch' "$VIBECREW_DIR/state.json")
  [ "$default_branch" = "main" ]
}

# =============================================================================
# config.json schema
# =============================================================================

@test "creates config.json with correct schema" {
  run_init
  assert_success
  [ -f "$VIBECREW_DIR/config.json" ]

  # Validate JSON is parseable
  run jq '.' "$VIBECREW_DIR/config.json"
  assert_success

  # Check schema version
  local schema_version
  schema_version=$(jq -r '.schema_version' "$VIBECREW_DIR/config.json")
  [ "$schema_version" = "1.5.0" ]

  # Check notifications section
  local notif_enabled
  notif_enabled=$(jq -r '.notifications.enabled' "$VIBECREW_DIR/config.json")
  [ "$notif_enabled" = "true" ]

  # Check gamification defaults to disabled
  local gam_enabled
  gam_enabled=$(jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json")
  [ "$gam_enabled" = "false" ]

  # Check user_profile section exists with interview_completed = false
  local interview
  interview=$(jq -r '.user_profile.interview_completed' "$VIBECREW_DIR/config.json")
  [ "$interview" = "false" ]

  # Check mcp_servers section
  local context7
  context7=$(jq -r '.mcp_servers.context7' "$VIBECREW_DIR/config.json")
  [ "$context7" = "true" ]

  # Check cost_limits section exists
  local has_cost_limits
  has_cost_limits=$(jq 'has("cost_limits")' "$VIBECREW_DIR/config.json")
  [ "$has_cost_limits" = "true" ]

  local session_max
  session_max=$(jq '.cost_limits.session_max_usd' "$VIBECREW_DIR/config.json")
  [ "$(echo "$session_max == 5" | bc)" = "1" ]
}

# =============================================================================
# backlog.json schema
# =============================================================================

@test "creates backlog.json with correct schema" {
  run_init
  assert_success
  [ -f "$VIBECREW_DIR/backlog.json" ]

  # Validate JSON is parseable
  run jq '.' "$VIBECREW_DIR/backlog.json"
  assert_success

  # Check schema version
  local schema_version
  schema_version=$(jq -r '.schema_version' "$VIBECREW_DIR/backlog.json")
  [ "$schema_version" = "1.5.0" ]

  # Check columns array exists with 7 columns
  local column_count
  column_count=$(jq '.columns | length' "$VIBECREW_DIR/backlog.json")
  [ "$column_count" = "7" ]

  # Check features array is empty
  local features_count
  features_count=$(jq '.features | length' "$VIBECREW_DIR/backlog.json")
  [ "$features_count" = "0" ]

  # Check first and last column IDs
  local first_col
  first_col=$(jq -r '.columns[0].id' "$VIBECREW_DIR/backlog.json")
  [ "$first_col" = "idea" ]

  local last_col
  last_col=$(jq -r '.columns[-1].id' "$VIBECREW_DIR/backlog.json")
  [ "$last_col" = "done" ]
}

# =============================================================================
# Gamification (opt-in)
# =============================================================================

@test "creates gamification.json when enabled in config" {
  run_init
  assert_success

  # By default gamification is disabled — no gamification.json
  [ ! -f "$VIBECREW_DIR/gamification.json" ]

  # Enable gamification in config
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Run init again — should now create gamification.json
  run_init
  assert_success
  [ -f "$VIBECREW_DIR/gamification.json" ]

  # Validate schema
  local schema_version
  schema_version=$(jq -r '.schema_version' "$VIBECREW_DIR/gamification.json")
  [ "$schema_version" = "1.0.0" ]

  local level
  level=$(jq -r '.level' "$VIBECREW_DIR/gamification.json")
  [ "$level" = "1" ]

  local xp
  xp=$(jq -r '.xp' "$VIBECREW_DIR/gamification.json")
  [ "$xp" = "0" ]

  local badges_type
  badges_type=$(jq -r '.badges | type' "$VIBECREW_DIR/gamification.json")
  [ "$badges_type" = "array" ]
}

# =============================================================================
# Idempotency
# =============================================================================

@test "idempotent: does not overwrite existing files" {
  # First run — creates everything
  run_init
  assert_success

  # Modify state.json with a marker value
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = true' "$VIBECREW_DIR/state.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/state.json"

  # Modify config.json with a marker value
  tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.terminal = "custom-marker"' "$VIBECREW_DIR/config.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Modify backlog.json with a marker feature
  tmp="$VIBECREW_DIR/backlog.json.tmp"
  jq '.features += [{"id":"marker"}]' "$VIBECREW_DIR/backlog.json" > "$tmp" \
    && mv "$tmp" "$VIBECREW_DIR/backlog.json"

  # Second run — should preserve all marker values
  run_init
  assert_success
  assert_output --partial "preserved"

  # Verify markers survived
  local foundation_complete
  foundation_complete=$(jq -r '.foundation.complete' "$VIBECREW_DIR/state.json")
  [ "$foundation_complete" = "true" ]

  local terminal
  terminal=$(jq -r '.terminal' "$VIBECREW_DIR/config.json")
  [ "$terminal" = "custom-marker" ]

  local features_count
  features_count=$(jq '.features | length' "$VIBECREW_DIR/backlog.json")
  [ "$features_count" = "1" ]
}
