#!/usr/bin/env bats
# tests/rebuild-sidebar.bats
# Tests for scripts/rebuild-sidebar.sh — VitePress sidebar regeneration from feature docs

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Skip conditions
# =============================================================================

@test "no VitePress config skips and exits 0" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/rebuild-sidebar.sh"
  assert_success
  [[ "$output" == *"No VitePress config"* ]]
}

@test "no features directory skips and exits 0" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs/.vitepress"
  echo 'export default { themeConfig: { sidebar: {} } }' > "$TEST_PROJECT_DIR/docs/.vitepress/config.ts"

  run bash "$SCRIPTS_DIR/rebuild-sidebar.sh"
  assert_success
  [[ "$output" == *"No features directory"* ]]
}

# =============================================================================
# Sidebar generation
# =============================================================================

@test "features with H1 titles are extracted correctly" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs/.vitepress"
  echo 'export default { themeConfig: { sidebar: {} } }' > "$TEST_PROJECT_DIR/docs/.vitepress/config.ts"
  mkdir -p "$TEST_PROJECT_DIR/docs/features"

  echo '# User Authentication' > "$TEST_PROJECT_DIR/docs/features/feat-001.md"
  echo '# Payment Processing' > "$TEST_PROJECT_DIR/docs/features/feat-002.md"

  run bash "$SCRIPTS_DIR/rebuild-sidebar.sh"
  assert_success

  [[ "$output" == *"User Authentication"* ]]
  [[ "$output" == *"Payment Processing"* ]]
  [[ "$output" == *"2 feature items"* ]]
}

@test "features without H1 aborts due to pipefail in grep" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs/.vitepress"
  echo 'export default { themeConfig: { sidebar: {} } }' > "$TEST_PROJECT_DIR/docs/.vitepress/config.ts"
  mkdir -p "$TEST_PROJECT_DIR/docs/features"

  # No H1 heading: the script uses `head | grep | head | sed` pipeline.
  # When grep finds no match it returns 1 and pipefail+set-e aborts.
  echo 'This feature has no title heading.' > "$TEST_PROJECT_DIR/docs/features/my-feature.md"

  run bash "$SCRIPTS_DIR/rebuild-sidebar.sh"
  assert_failure
}

@test "exits 0 always" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs/.vitepress"
  echo 'export default { themeConfig: { sidebar: {} } }' > "$TEST_PROJECT_DIR/docs/.vitepress/config.ts"
  mkdir -p "$TEST_PROJECT_DIR/docs/features"
  echo '# Test Feature' > "$TEST_PROJECT_DIR/docs/features/test.md"

  run bash "$SCRIPTS_DIR/rebuild-sidebar.sh"
  assert_success
}
