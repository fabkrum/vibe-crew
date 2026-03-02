#!/usr/bin/env bats
# tests/generate-release-notes.bats
# Tests for scripts/generate-release-notes.sh — release notes JSON generation

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
# Basic output
# =============================================================================

@test "no git repo returns empty JSON structure and exits 0" {
  local nogit_dir
  nogit_dir="$(mktemp -d)"

  run bash -c "cd '$nogit_dir' && bash '$SCRIPTS_DIR/generate-release-notes.sh'"
  assert_success

  # Validate it is valid JSON with expected fields
  echo "$output" | jq -e '.version'
  echo "$output" | jq -e '.sections.features'
  echo "$output" | jq -e '.stats.total_commits'

  local total
  total=$(echo "$output" | jq -r '.stats.total_commits')
  [[ "$total" == "0" ]]

  rm -rf "$nogit_dir"
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  echo "$output" | jq empty
}

@test "JSON contains all expected sections" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  echo "$output" | jq -e '.sections.features'
  echo "$output" | jq -e '.sections.fixes'
  echo "$output" | jq -e '.sections.refactors'
  echo "$output" | jq -e '.sections.docs'
  echo "$output" | jq -e '.sections.other'
}

# =============================================================================
# Commit parsing
# =============================================================================

@test "feat commits appear in sections.features array" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "a" > a.txt && git add a.txt && git commit -m "feat: add user profiles" --quiet

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.sections.features | length')
  [[ "$count" -ge 1 ]]

  local msg
  msg=$(echo "$output" | jq -r '.sections.features[0].message')
  [[ "$msg" == "add user profiles" ]]
}

@test "fix commits appear in sections.fixes array" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "b" > b.txt && git add b.txt && git commit -m "fix: resolve memory leak" --quiet

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.sections.fixes | length')
  [[ "$count" -ge 1 ]]

  local msg
  msg=$(echo "$output" | jq -r '.sections.fixes[0].message')
  [[ "$msg" == "resolve memory leak" ]]
}

@test "stats include total_commits count" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0
  echo "c" > c.txt && git add c.txt && git commit -m "feat: add search" --quiet
  echo "d" > d.txt && git add d.txt && git commit -m "fix: fix search index" --quiet

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  local total
  total=$(echo "$output" | jq -r '.stats.total_commits')
  [[ "$total" -ge 2 ]]
}

# =============================================================================
# Output file mode
# =============================================================================

@test "output file mode writes JSON to specified file" {
  cd "$TEST_PROJECT_DIR"
  local outfile="$TEST_PROJECT_DIR/release-notes.json"

  run bash "$SCRIPTS_DIR/generate-release-notes.sh" "" "$outfile"
  assert_success

  [[ -f "$outfile" ]]
  jq empty "$outfile"
}

# =============================================================================
# Version detection
# =============================================================================

@test "version from package.json when present" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test","version":"2.5.0"}' > "$TEST_PROJECT_DIR/package.json"
  git add package.json && git commit -m "chore: add package.json" --quiet

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  local ver
  ver=$(echo "$output" | jq -r '.version')
  [[ "$ver" == "2.5.0" ]]
}

@test "no commits after tag produces empty sections" {
  cd "$TEST_PROJECT_DIR"
  git tag v1.0.0

  run bash "$SCRIPTS_DIR/generate-release-notes.sh"
  assert_success

  local feat_count
  feat_count=$(echo "$output" | jq '.sections.features | length')
  [[ "$feat_count" == "0" ]]

  local fix_count
  fix_count=$(echo "$output" | jq '.sections.fixes | length')
  [[ "$fix_count" == "0" ]]
}
