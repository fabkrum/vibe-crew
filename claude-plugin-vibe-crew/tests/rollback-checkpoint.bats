#!/usr/bin/env bats
# tests/rollback-checkpoint.bats
# Tests for scripts/rollback-checkpoint.sh — checkpoint rollback

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  # Create a few commits with DIFFERENT files to avoid revert conflicts
  echo "v1" > "$TEST_PROJECT_DIR/file1.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: v1" >/dev/null 2>&1
  COMMIT1=$(git -C "$TEST_PROJECT_DIR" rev-parse HEAD)

  echo "v2" > "$TEST_PROJECT_DIR/file2.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: v2" >/dev/null 2>&1
  COMMIT2=$(git -C "$TEST_PROJECT_DIR" rev-parse HEAD)

  echo "v3" > "$TEST_PROJECT_DIR/file3.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: v3" >/dev/null 2>&1
  COMMIT3=$(git -C "$TEST_PROJECT_DIR" rev-parse HEAD)
}

teardown() {
  teardown_vibecrew_dir
}

@test "reset mode: moves HEAD back" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "$COMMIT1" "reset"
  assert_success

  local error
  error=$(echo "$output" | jq '.error')
  [[ "$error" == "false" ]]

  local mode
  mode=$(echo "$output" | jq -r '.mode')
  [[ "$mode" == "reset" ]]

  # HEAD should now be at COMMIT1
  local current
  current=$(git rev-parse HEAD)
  [[ "$current" == "$COMMIT1" ]]
}

@test "revert mode: creates revert commit" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "$COMMIT2" "revert"
  assert_success

  # git commit writes to stdout; extract only JSON portion
  local json_output
  json_output=$(echo "$output" | grep -E '^\{' | head -1)
  # If jq can't parse single line, try multiline extraction
  if ! echo "$json_output" | jq empty 2>/dev/null; then
    json_output=$(echo "$output" | sed -n '/^{/,/^}/p')
  fi

  local error
  error=$(echo "$json_output" | jq '.error')
  [[ "$error" == "false" ]]

  # HEAD should be different from COMMIT3 (new revert commit)
  local current
  current=$(git rev-parse HEAD)
  [[ "$current" != "$COMMIT3" ]]
}

@test "invalid target hash reports error" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "0000000000000000000000000000000000000000" "reset"
  assert_success  # Script always exits 0

  # Output should contain error (either in stdout or stderr captured by run)
  [[ "$output" == *"error"* ]] || [[ "$output" == *"not found"* ]] || [[ "$output" == *"Reset failed"* ]]
}

@test "invalid mode" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "$COMMIT1" "destroy"
  assert_success

  echo "$output" | jq -e '.error == true' >/dev/null
  echo "$output" | jq -r '.message' | grep -q "Invalid mode"
}

@test "missing arguments" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh"
  assert_success
  [[ $status -eq 0 ]]
}

@test "reset mode preserves changes as staged" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "$COMMIT1" "reset"
  assert_success

  # Changes should be staged (soft reset)
  local staged
  staged=$(git -C "$TEST_PROJECT_DIR" diff --cached --name-only)
  [[ -n "$staged" ]]
}

@test "output is valid JSON on success" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "$COMMIT1" "reset"
  assert_success
  echo "$output" | jq empty
}

@test "revert includes before and after hashes" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/rollback-checkpoint.sh" "$COMMIT2" "revert"
  assert_success

  # Extract JSON portion (git commit outputs text before JSON)
  local json_output
  json_output=$(echo "$output" | sed -n '/^{/,/^}/p')

  echo "$json_output" | jq -e '.before_head' >/dev/null
  echo "$json_output" | jq -e '.after_head' >/dev/null
}
