#!/usr/bin/env bats
# tests/statusline.bats
# Tests for scripts/statusline.sh — status line renderer

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  export SCRIPTS_DIR
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "empty stdin: shows defaults" {
  cd "$TEST_PROJECT_DIR"

  run bash -c 'echo "{}" | bash "$SCRIPTS_DIR/statusline.sh"'
  assert_success
  [[ "$output" == *"Claude"* ]]
}

@test "model name from stdin" {
  cd "$TEST_PROJECT_DIR"
  echo '{"model":{"display_name":"Opus"}}' > "$TEST_PROJECT_DIR/stdin.json"

  run bash -c 'cat "$0" | bash "$SCRIPTS_DIR/statusline.sh"' "$TEST_PROJECT_DIR/stdin.json"
  assert_success
  [[ "$output" == *"Opus"* ]]
}

@test "context percentage shown" {
  cd "$TEST_PROJECT_DIR"
  echo '{"context_window":{"used_percentage":42}}' > "$TEST_PROJECT_DIR/stdin.json"

  run bash -c 'cat "$0" | bash "$SCRIPTS_DIR/statusline.sh"' "$TEST_PROJECT_DIR/stdin.json"
  assert_success
  [[ "$output" == *"42%"* ]]
}

@test "cost formatted" {
  cd "$TEST_PROJECT_DIR"
  echo '{"cost":{"total_cost_usd":1.5}}' > "$TEST_PROJECT_DIR/stdin.json"

  run bash -c 'cat "$0" | bash "$SCRIPTS_DIR/statusline.sh"' "$TEST_PROJECT_DIR/stdin.json"
  assert_success
  [[ "$output" == *'$1.50'* ]]
}

@test "active feature and phase shown" {
  cd "$TEST_PROJECT_DIR"
  set_active_feature "feat-001" "Login Page" "code"

  run bash -c 'echo "{}" | bash "$SCRIPTS_DIR/statusline.sh"'
  assert_success
  [[ "$output" == *"Login Page"* ]]
}

@test "no active feature shows no project" {
  cd "$TEST_PROJECT_DIR"
  # foundation is not complete by default, so it shows "foundation" instead of "no project"
  # Set foundation complete and clear active feature to get "no project"
  set_foundation_complete

  run bash -c 'echo "{}" | bash "$SCRIPTS_DIR/statusline.sh"'
  assert_success
  [[ "$output" == *"no project"* ]]
}

@test "score from score file shown" {
  cd "$TEST_PROJECT_DIR"
  echo '{"score":85,"deductions":[],"bonuses":[]}' > "$VIBECREW_DIR/scores/score-001.json"

  run bash -c 'echo "{}" | bash "$SCRIPTS_DIR/statusline.sh"'
  assert_success
  [[ "$output" == *"85"* ]]
}

@test "jq not available: shows VibeCrew" {
  cd "$TEST_PROJECT_DIR"

  # Create a minimal PATH directory with bash and basic tools but NOT jq
  local fake_bin="$TEST_PROJECT_DIR/fake-bin"
  mkdir -p "$fake_bin"
  ln -s "$(which bash)" "$fake_bin/bash"
  ln -s "$(which cat)" "$fake_bin/cat"
  ln -s "$(which printf)" "$fake_bin/printf" 2>/dev/null || true
  ln -s "$(which git)" "$fake_bin/git" 2>/dev/null || true
  ln -s "$(which ls)" "$fake_bin/ls" 2>/dev/null || true
  ln -s "$(which head)" "$fake_bin/head" 2>/dev/null || true
  ln -s "$(which tr)" "$fake_bin/tr" 2>/dev/null || true
  ln -s "$(which cut)" "$fake_bin/cut" 2>/dev/null || true

  run bash -c 'export PATH="$0"; hash -r 2>/dev/null; echo "{}" | bash "$SCRIPTS_DIR/statusline.sh"' "$fake_bin"
  # The script should still succeed
  assert_success
  [[ "$output" == *"VibeCrew"* ]]
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"

  run bash -c 'echo "{}" | bash "$SCRIPTS_DIR/statusline.sh"'
  assert_success
}
