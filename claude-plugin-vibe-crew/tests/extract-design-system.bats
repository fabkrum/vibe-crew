#!/usr/bin/env bats
# tests/extract-design-system.bats
# Tests for scripts/extract-design-system.sh — Chrome DevTools MCP extraction payload & template CSS

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# Argument validation
# =============================================================================

@test "no URL argument: exits 1" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh"
  assert_failure
}

@test "invalid URL format: exits 1" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh" "not-a-url"
  assert_failure
}

# =============================================================================
# JSON payload output
# =============================================================================

@test "valid URL: outputs JSON payload to stdout" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh" "https://example.com"
  assert_success

  # stdout should contain the extraction action
  [[ "$output" == *"extract_computed_styles"* ]]
}

# =============================================================================
# Template CSS creation
# =============================================================================

@test "creates template CSS file at specified output path" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh" "https://example.com" "$TEST_PROJECT_DIR/output.css"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/output.css" ]]
}

@test "template CSS contains custom properties" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh" "https://example.com" "$TEST_PROJECT_DIR/output.css"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/output.css")
  [[ "$content" == *"--color-bg-primary"* ]]
}

@test "default output path is design-system.css" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh" "https://example.com"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/design-system.css" ]]
}

@test "always exits 0 with valid URL" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-design-system.sh" "https://example.com" "$TEST_PROJECT_DIR/out.css"
  assert_success
}
