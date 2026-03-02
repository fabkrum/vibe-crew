#!/usr/bin/env bats
# tests/detect-tdd-discipline.bats
# Tests for scripts/detect-tdd-discipline.sh — TDD cycle detection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "no TDD cycles detected returns false" {
  cd "$TEST_PROJECT_DIR"
  echo "file1" > "$TEST_PROJECT_DIR/file1.txt"
  git -C "$TEST_PROJECT_DIR" add .
  git -C "$TEST_PROJECT_DIR" commit -m "feat: add file1" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/detect-tdd-discipline.sh" "$TEST_PROJECT_DIR"
  assert_success

  local detected
  detected=$(echo "$output" | jq '.discipline_detected')
  [[ "$detected" == "false" ]]

  local count
  count=$(echo "$output" | jq '.cycle_count')
  [[ "$count" == "0" ]]
}

@test "detects TDD cycle trailers in commits" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo "file$i" > "$TEST_PROJECT_DIR/file$i.txt"
    git -C "$TEST_PROJECT_DIR" add .
    git -C "$TEST_PROJECT_DIR" commit -m "$(printf 'test: add test %d\n\nTDD cycle: red-green-refactor' $i)" >/dev/null 2>&1
  done

  run bash "$SCRIPTS_DIR/detect-tdd-discipline.sh" "$TEST_PROJECT_DIR"
  assert_success

  local detected
  detected=$(echo "$output" | jq '.discipline_detected')
  [[ "$detected" == "true" ]]

  local count
  count=$(echo "$output" | jq '.cycle_count')
  [[ "$count" == "5" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-tdd-discipline.sh" "$TEST_PROJECT_DIR"
  assert_success
  echo "$output" | jq empty
}

@test "accepts project root argument" {
  echo "f" > "$TEST_PROJECT_DIR/f.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: init" >/dev/null 2>&1
  cd /tmp
  run bash "$SCRIPTS_DIR/detect-tdd-discipline.sh" "$TEST_PROJECT_DIR"
  assert_success
  echo "$output" | jq empty
}

@test "mixed commits count only TDD ones" {
  cd "$TEST_PROJECT_DIR"
  echo "f1" > "$TEST_PROJECT_DIR/f1.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: add feature" >/dev/null 2>&1
  echo "f2" > "$TEST_PROJECT_DIR/f2.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "$(printf 'test: add tests\n\nTDD cycle: red-green')" >/dev/null 2>&1
  echo "f3" > "$TEST_PROJECT_DIR/f3.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "fix: bug fix" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/detect-tdd-discipline.sh" "$TEST_PROJECT_DIR"
  assert_success

  local count
  count=$(echo "$output" | jq '.cycle_count')
  [[ "$count" == "1" ]]
}
