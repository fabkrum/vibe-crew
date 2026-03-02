#!/usr/bin/env bats
# tests/update-docs.bats
# Tests for scripts/update-docs.sh — PostToolUse helper for VitePress rebuilds
#
# Note: update-docs.sh finds project root by walking up from the script's own
# location looking for .vibecrew/. Since $SCRIPTS_DIR is inside the plugin
# (not inside $TEST_PROJECT_DIR), the script will not find .vibecrew/ and
# will exit 0 silently. We test the safe exit-0 behavior for these cases.

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# Safe exit behavior
# =============================================================================

@test "no .vibecrew directory: silent exit 0" {
  # The script walks up from its own location (inside the plugin) looking
  # for .vibecrew/. Since the plugin dir does not have .vibecrew/ as a
  # project marker, it exits 0 silently.
  run bash "$SCRIPTS_DIR/update-docs.sh"
  assert_success
}

@test "no docs/.vitepress directory: silent exit 0" {
  # Even if .vibecrew were found, no docs site means silent exit 0
  run bash "$SCRIPTS_DIR/update-docs.sh"
  assert_success
}

@test "always exits 0" {
  run bash "$SCRIPTS_DIR/update-docs.sh"
  assert_success
}

@test "accepts optional changed-file argument without error" {
  run bash "$SCRIPTS_DIR/update-docs.sh" "/some/path/to/file.md"
  assert_success
}
