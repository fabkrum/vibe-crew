#!/usr/bin/env bats
# tests/generate-releases-html.bats
# Tests for scripts/generate-releases-html.sh — CHANGELOG.md to HTML conversion
#
# Note: This script resolves paths relative to its own location:
#   SCRIPT_DIR -> PLUGIN_ROOT (SCRIPT_DIR/..) -> REPO_ROOT (PLUGIN_ROOT/..)
# It reads PLUGIN_ROOT/CHANGELOG.md and writes REPO_ROOT/docs/releases.html.
# Tests create a CHANGELOG.md in the plugin dir and check output in repo docs/.

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # The script resolves paths from its own filesystem location:
  #   PLUGIN_ROOT = $SCRIPTS_DIR/..
  #   REPO_ROOT = $SCRIPTS_DIR/../..
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  REPO_ROOT="$(cd "$PLUGIN_ROOT/.." && pwd)"

  # Backup existing CHANGELOG.md and releases.html if they exist
  if [[ -f "$PLUGIN_ROOT/CHANGELOG.md" ]]; then
    cp "$PLUGIN_ROOT/CHANGELOG.md" "$PLUGIN_ROOT/CHANGELOG.md.bak"
  fi
  if [[ -f "$REPO_ROOT/docs/releases.html" ]]; then
    cp "$REPO_ROOT/docs/releases.html" "$REPO_ROOT/docs/releases.html.bak"
  fi
}

teardown() {
  teardown_vibecrew_dir

  # Restore originals
  if [[ -f "$PLUGIN_ROOT/CHANGELOG.md.bak" ]]; then
    mv "$PLUGIN_ROOT/CHANGELOG.md.bak" "$PLUGIN_ROOT/CHANGELOG.md"
  fi
  if [[ -f "$REPO_ROOT/docs/releases.html.bak" ]]; then
    mv "$REPO_ROOT/docs/releases.html.bak" "$REPO_ROOT/docs/releases.html"
  fi
}

# =============================================================================
# Skip / empty conditions
# =============================================================================

@test "no CHANGELOG.md exits 1 with error message" {
  # Remove CHANGELOG.md from the plugin root
  rm -f "$PLUGIN_ROOT/CHANGELOG.md"

  run bash "$SCRIPTS_DIR/generate-releases-html.sh"
  assert_failure
  [[ "$output" == *"not found"* ]]
}

@test "empty CHANGELOG.md with no versions fails on unbound VERSIONS array" {
  # The script uses `set -u` and references ${VERSIONS[@]} which is unbound
  # when no version entries exist (bash empty array + nounset limitation).
  echo "" > "$PLUGIN_ROOT/CHANGELOG.md"

  run bash "$SCRIPTS_DIR/generate-releases-html.sh"
  assert_failure
  [[ "$output" == *"unbound variable"* ]]
}

# =============================================================================
# HTML generation
# =============================================================================

@test "CHANGELOG with version entries generates HTML file" {
  cat > "$PLUGIN_ROOT/CHANGELOG.md" << 'CHANGELOG'
# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2026-02-15

### Added

- `auth.sh` -- New authentication module

## [1.1.0] - 2026-01-10

### Fixed

- `router.sh` -- Fix redirect loop
CHANGELOG

  run bash "$SCRIPTS_DIR/generate-releases-html.sh"
  assert_success

  [[ -f "$REPO_ROOT/docs/releases.html" ]]
}

@test "HTML output contains version headers" {
  cat > "$PLUGIN_ROOT/CHANGELOG.md" << 'CHANGELOG'
# Changelog

## [2.0.0] - 2026-03-01

### Added

- `feature.sh` -- Major new feature
CHANGELOG

  run bash "$SCRIPTS_DIR/generate-releases-html.sh"
  assert_success

  local content
  content=$(cat "$REPO_ROOT/docs/releases.html")
  [[ "$content" == *"v2.0.0"* ]]
}

@test "exits 0 on successful generation" {
  cat > "$PLUGIN_ROOT/CHANGELOG.md" << 'CHANGELOG'
# Changelog

## [1.0.0] - 2026-01-01

### Added

- `init.sh` -- Initial release
CHANGELOG

  run bash "$SCRIPTS_DIR/generate-releases-html.sh"
  assert_success
}
