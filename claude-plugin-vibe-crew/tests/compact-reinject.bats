#!/usr/bin/env bats
# tests/compact-reinject.bats
# Tests for scripts/compact-reinject.sh — SessionStart hook (compact matcher)

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/compact-reinject.sh"

  # Create an initial commit so git log works
  git -C "$TEST_PROJECT_DIR" commit --allow-empty -m "initial commit" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

run_reinject() {
  run bash -c "cd '$TEST_PROJECT_DIR' && PROJECT_ROOT='$TEST_PROJECT_DIR' bash '$SCRIPT'"
}

# =============================================================================
# No .vibecrew directory
# =============================================================================

@test "no .vibecrew directory: exits 0 with setup message" {
  rm -rf "$VIBECREW_DIR"
  run_reinject
  assert_success
  assert_output --partial "not initialized"
}

# =============================================================================
# Missing state.json
# =============================================================================

@test "missing state.json: exits 0 with setup message" {
  rm "$VIBECREW_DIR/state.json"
  run_reinject
  assert_success
  assert_output --partial "not initialized"
}

# =============================================================================
# Active feature context
# =============================================================================

@test "active feature: reinjects feature id, name, and phase" {
  set_active_feature "feat-001" "User Auth" "code"
  run_reinject
  assert_success
  assert_output --partial "feat-001"
  assert_output --partial "User Auth"
  assert_output --partial '"phase":"code"'
}

# =============================================================================
# Foundation status
# =============================================================================

@test "foundation incomplete: outputs Tier 1 artifact status" {
  run_reinject
  assert_success
  assert_output --partial "Tier 1 artifacts:"
  assert_output --partial "pending="
}

@test "foundation complete: omits Tier 1 artifact listing" {
  set_foundation_complete
  run_reinject
  assert_success
  refute_output --partial "Tier 1 artifacts:"
}

# =============================================================================
# Structured output format
# =============================================================================

@test "output has structured delimiters and key sections" {
  set_foundation_complete
  set_active_feature "feat-010" "Dashboard" "test"
  add_feature_to_backlog "feat-010" "Dashboard" "in-progress"
  add_feature_to_backlog "feat-011" "Settings" "planned"
  run_reinject
  assert_success
  assert_output --partial "--- VibeCrew Context (re-injected after compaction) ---"
  assert_output --partial "--- End VibeCrew Context ---"
  assert_output --partial "Backlog:"
  assert_output --partial "Branch:"
  assert_output --partial "Recent commits:"
}

# =============================================================================
# Empty / minimal state.json
# =============================================================================

@test "empty state.json: exits 0 gracefully" {
  echo '{}' > "$VIBECREW_DIR/state.json"
  run_reinject
  assert_success
  # Should still produce the context header
  assert_output --partial "--- VibeCrew Context (re-injected after compaction) ---"
  assert_output --partial "--- End VibeCrew Context ---"
}
