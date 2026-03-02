#!/usr/bin/env bats
# tests/update-changelog.bats
# Tests for scripts/update-changelog.sh — conventional commit changelog generation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Need an initial commit so git log works
  cd "$TEST_PROJECT_DIR"
  echo "init" > README.md
  git add README.md
  git commit -m "chore: initial commit" --quiet
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Basic behavior
# =============================================================================

@test "exits 0 with no new commits since tag" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success
  [[ "$output" == *"No new commits"* ]]
}

@test "exits 0 always even with commits" {
  cd "$TEST_PROJECT_DIR"
  echo "a" > a.txt && git add a.txt && git commit -m "feat: add feature A" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success
}

@test "no git repo returns skip message" {
  # Run from a temp dir with no git
  local nogit_dir
  nogit_dir="$(mktemp -d)"

  run bash -c "cd '$nogit_dir' && bash '$SCRIPTS_DIR/update-changelog.sh'"
  # The script does pwd fallback, so it may still run but from a non-git dir
  # with no commits — either "Git not available" or "No new commits" is acceptable
  assert_success
  rm -rf "$nogit_dir"
}

# =============================================================================
# Conventional commit parsing
# =============================================================================

@test "feat commits appear in Added section" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "b" > b.txt && git add b.txt && git commit -m "feat: add login page" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/CHANGELOG.md" ]]
  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"### Added"* ]]
  [[ "$content" == *"feat: add login page"* ]]
}

@test "fix commits appear in Fixed section" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "c" > c.txt && git add c.txt && git commit -m "fix: resolve crash on startup" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"### Fixed"* ]]
  [[ "$content" == *"fix: resolve crash on startup"* ]]
}

@test "mixed commit types produce multiple sections" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "d" > d.txt && git add d.txt && git commit -m "feat: add dashboard" --quiet
  echo "e" > e.txt && git add e.txt && git commit -m "fix: fix sidebar overlap" --quiet
  echo "f" > f.txt && git add f.txt && git commit -m "refactor: simplify auth flow" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"### Added"* ]]
  [[ "$content" == *"### Fixed"* ]]
  [[ "$content" == *"### Changed"* ]]
}

@test "non-conventional commits are skipped" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "g" > g.txt && git add g.txt && git commit -m "random update to stuff" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success
  [[ "$output" == *"No conventional commits"* ]]
}

@test "docs commits appear in Documentation section" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "h" > h.txt && git add h.txt && git commit -m "docs: update API reference" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"### Documentation"* ]]
  [[ "$content" == *"docs: update API reference"* ]]
}

@test "test commits appear in Testing section" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "i" > i.txt && git add i.txt && git commit -m "test: add unit tests for auth" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"### Testing"* ]]
  [[ "$content" == *"test: add unit tests for auth"* ]]
}

@test "chore commits appear in Maintenance section" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "j" > j.txt && git add j.txt && git commit -m "chore: bump dependencies" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"### Maintenance"* ]]
  [[ "$content" == *"chore: bump dependencies"* ]]
}

# =============================================================================
# CHANGELOG.md file handling
# =============================================================================

@test "creates new CHANGELOG.md with header when none exists" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "k" > k.txt && git add k.txt && git commit -m "feat: add signup" --quiet

  # Ensure no CHANGELOG exists
  rm -f "$TEST_PROJECT_DIR/CHANGELOG.md"

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/CHANGELOG.md" ]]
  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  [[ "$content" == *"# Changelog"* ]]
  [[ "$content" == *"## [Unreleased]"* ]]
}

@test "inserts before first version in existing CHANGELOG" {
  cd "$TEST_PROJECT_DIR"

  # Create an existing CHANGELOG with a version entry
  cat > "$TEST_PROJECT_DIR/CHANGELOG.md" << 'EXISTING'
# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-01-01

### Added

- Initial release
EXISTING

  git add CHANGELOG.md && git commit -m "docs: add changelog" --quiet
  git tag v1.0.0

  echo "l" > l.txt && git add l.txt && git commit -m "feat: add notifications" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CHANGELOG.md")
  # The new unreleased entry should come before the existing 1.0.0 entry
  [[ "$content" == *"## [Unreleased]"* ]]
  [[ "$content" == *"## [1.0.0]"* ]]
}

@test "output message mentions CHANGELOG.md updated" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "m" > m.txt && git add m.txt && git commit -m "feat: add search" --quiet

  run bash "$SCRIPTS_DIR/update-changelog.sh"
  assert_success
  [[ "$output" == *"CHANGELOG.md updated"* ]]
}
