#!/usr/bin/env bats
# Tests for scripts/check-analysis-staleness.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/check-analysis-staleness.sh"

setup() {
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- No analysis docs ---

@test "check-analysis-staleness: reports not exists when no analysis docs" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.exists')" = "false" ]
  [ "$(echo "$output" | jq '.stale')" = "false" ]
}

# --- Fresh analysis docs ---

@test "check-analysis-staleness: reports not stale for fresh docs" {
  mkdir -p "$VIBECREW_DIR/analysis"
  echo "# Stack Analysis" > "$VIBECREW_DIR/analysis/stack.md"

  # Make an initial commit so git log works
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.exists')" = "true" ]
  [ "$(echo "$output" | jq '.stale')" = "false" ]
  [ "$(echo "$output" | jq '.age_days')" = "0" ]
}

# --- Package.json staleness ---

@test "check-analysis-staleness: detects stale when package.json is newer" {
  mkdir -p "$VIBECREW_DIR/analysis"
  echo "# Stack Analysis" > "$VIBECREW_DIR/analysis/stack.md"

  # Make an initial commit
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  # Backdate the analysis file
  touch -t 202501010000 "$VIBECREW_DIR/analysis/stack.md"

  # Create a newer package.json
  echo '{"name": "test"}' > "$TEST_PROJECT_DIR/package.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.exists')" = "true" ]
  [ "$(echo "$output" | jq '.stale')" = "true" ]
  [ "$(echo "$output" | jq '.package_stale')" = "true" ]
  [ "$(echo "$output" | jq '.reasons | length')" -gt 0 ]
}

# --- Valid JSON output ---

@test "check-analysis-staleness: always returns valid JSON" {
  mkdir -p "$VIBECREW_DIR/analysis"
  echo "# Stack" > "$VIBECREW_DIR/analysis/stack.md"

  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
  # Verify all expected fields exist
  echo "$output" | jq 'has("exists")' | grep -q true
  echo "$output" | jq 'has("stale")' | grep -q true
  echo "$output" | jq 'has("age_days")' | grep -q true
  echo "$output" | jq 'has("commits_since")' | grep -q true
  echo "$output" | jq 'has("package_stale")' | grep -q true
  echo "$output" | jq 'has("reasons")' | grep -q true
}
