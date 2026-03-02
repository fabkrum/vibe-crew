#!/usr/bin/env bats
# tests/bump-version.bats
# Tests for scripts/bump-version.sh — multi-file version bumping

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Create an isolated plugin directory structure in the temp dir
  # bump-version.sh resolves PLUGIN_ROOT from its own location (script_dir/..)
  # and REPO_ROOT from PLUGIN_ROOT/..
  TEMP_PLUGIN_DIR="$TEST_PROJECT_DIR/claude-plugin-vibe-crew"
  TEMP_REPO_DIR="$TEST_PROJECT_DIR"
  mkdir -p "$TEMP_PLUGIN_DIR/scripts"
  mkdir -p "$TEMP_PLUGIN_DIR/.claude-plugin"
  mkdir -p "$TEMP_PLUGIN_DIR/agents"

  # Copy the real bump-version.sh into the temp plugin structure
  cp "$SCRIPTS_DIR/bump-version.sh" "$TEMP_PLUGIN_DIR/scripts/bump-version.sh"
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "no argument: exits 1" {
  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh"
  assert_failure
}

@test "invalid semver: exits 1" {
  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "abc"
  assert_failure
}

@test "invalid semver format: exits 1" {
  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "1.2"
  assert_failure
}

@test "valid semver updates plugin.json" {
  cat > "$TEMP_PLUGIN_DIR/.claude-plugin/plugin.json" <<'EOF'
{
  "name": "vibe-crew",
  "version": "1.0.0",
  "description": "Test plugin"
}
EOF

  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "2.0.0"
  assert_success

  local version
  version=$(jq -r '.version' "$TEMP_PLUGIN_DIR/.claude-plugin/plugin.json")
  [[ "$version" == "2.0.0" ]]
}

@test "valid semver updates session-startup.md" {
  mkdir -p "$TEMP_PLUGIN_DIR/agents"
  echo 'Welcome to VibeCrew v1.0.0 session' > "$TEMP_PLUGIN_DIR/agents/session-startup.md"

  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "2.0.0"
  assert_success

  grep -q "VibeCrew v2.0.0" "$TEMP_PLUGIN_DIR/agents/session-startup.md"
}

@test "valid semver updates CLAUDE.md" {
  echo 'VibeCrew v1.0.0 — the plugin is feature-complete.' > "$TEMP_REPO_DIR/CLAUDE.md"

  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "2.0.0"
  assert_success

  grep -q "VibeCrew v2.0.0" "$TEMP_REPO_DIR/CLAUDE.md"
}

@test "CHANGELOG [Unreleased] renamed" {
  cat > "$TEMP_PLUGIN_DIR/CHANGELOG.md" <<'EOF'
# Changelog

## [Unreleased]

### Added
- New feature
EOF

  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "2.0.0"
  assert_success

  # [Unreleased] should be replaced with [2.0.0]
  grep -q '\[2\.0\.0\]' "$TEMP_PLUGIN_DIR/CHANGELOG.md"
  ! grep -q '\[Unreleased\]' "$TEMP_PLUGIN_DIR/CHANGELOG.md"
}

@test "exit 0 on success" {
  # Create minimal files so no warnings block
  cat > "$TEMP_PLUGIN_DIR/.claude-plugin/plugin.json" <<'EOF'
{"name": "vibe-crew", "version": "1.0.0"}
EOF

  run bash "$TEMP_PLUGIN_DIR/scripts/bump-version.sh" "3.0.0"
  assert_success
}
