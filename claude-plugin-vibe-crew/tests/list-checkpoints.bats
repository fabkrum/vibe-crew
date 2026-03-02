#!/usr/bin/env bats
# tests/list-checkpoints.bats
# Tests for scripts/list-checkpoints.sh — checkpoint and commit listing

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  echo "init" > "$TEST_PROJECT_DIR/init.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: init" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

@test "no checkpoints returns empty array" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  local cp_len
  cp_len=$(echo "$output" | jq '.checkpoints | length')
  [[ "$cp_len" == "0" ]]
}

@test "recent commits are listed" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  local commits_len
  commits_len=$(echo "$output" | jq '.recent_commits | length')
  [[ "$commits_len" -ge 1 ]]

  local first_subject
  first_subject=$(echo "$output" | jq -r '.recent_commits[0].subject')
  [[ "$first_subject" == "feat: init" ]]
}

@test "lists checkpoint tags" {
  cd "$TEST_PROJECT_DIR"
  git tag -a "vibecrew-checkpoint-2026-01-01T00-00-00Z" -m "test checkpoint" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  local cp_len
  cp_len=$(echo "$output" | jq '.checkpoints | length')
  [[ "$cp_len" == "1" ]]

  local tag
  tag=$(echo "$output" | jq -r '.checkpoints[0].tag')
  [[ "$tag" == "vibecrew-checkpoint-2026-01-01T00-00-00Z" ]]
}

@test "multiple checkpoints sorted by date" {
  cd "$TEST_PROJECT_DIR"
  git tag -a "vibecrew-checkpoint-2026-01-01T00-00-00Z" -m "first" >/dev/null 2>&1

  echo "v2" > "$TEST_PROJECT_DIR/v2.txt"
  git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: v2" >/dev/null 2>&1
  git tag -a "vibecrew-checkpoint-2026-01-02T00-00-00Z" -m "second" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  local cp_len
  cp_len=$(echo "$output" | jq '.checkpoints | length')
  [[ "$cp_len" == "2" ]]
}

@test "checkpoints include hash and subject" {
  cd "$TEST_PROJECT_DIR"
  git tag -a "vibecrew-checkpoint-2026-03-01T00-00-00Z" -m "check" >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  echo "$output" | jq -e '.checkpoints[0].hash' >/dev/null
  echo "$output" | jq -e '.checkpoints[0].full_hash' >/dev/null
  echo "$output" | jq -e '.checkpoints[0].subject' >/dev/null
}

@test "recent commits include hash and date" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  echo "$output" | jq -e '.recent_commits[0].hash' >/dev/null
  echo "$output" | jq -e '.recent_commits[0].date' >/dev/null
}

@test "limits to 10 recent commits" {
  cd "$TEST_PROJECT_DIR"
  for i in $(seq 1 15); do
    echo "file$i" > "$TEST_PROJECT_DIR/f$i.txt"
    git -C "$TEST_PROJECT_DIR" add . && git -C "$TEST_PROJECT_DIR" commit -m "feat: commit $i" >/dev/null 2>&1
  done

  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success

  local commits_len
  commits_len=$(echo "$output" | jq '.recent_commits | length')
  [[ "$commits_len" == "10" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/list-checkpoints.sh"
  assert_success
  echo "$output" | jq empty
}
