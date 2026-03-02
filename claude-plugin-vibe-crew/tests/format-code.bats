#!/usr/bin/env bats
# tests/format-code.bats
# Tests for scripts/format-code.sh — PostToolUse auto-formatting hook

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/format-code.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Helper: run format-code.sh with a Write hook payload ---
run_format() {
  local file_path="$1"
  local tool_name="${2:-Write}"
  local payload
  payload=$(jq -n --arg tn "$tool_name" --arg fp "$file_path" \
    '{tool_name: $tn, tool_input: {file_path: $fp}}')
  run bash -c "echo '$payload' | cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
}

@test "exits 0 for non-Write/Edit tool" {
  local payload='{"tool_name":"Bash","tool_input":{"command":"echo hi"}}'
  run bash -c "echo '$payload' | cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "exits 0 when file_path is empty" {
  local payload='{"tool_name":"Write","tool_input":{"file_path":""}}'
  run bash -c "echo '$payload' | cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "exits 0 for non-formattable extension (binary/image)" {
  local test_file="$TEST_PROJECT_DIR/image.png"
  touch "$test_file"
  run_format "$test_file"
  assert_success
}

@test "exits 0 for .py file (not in formattable list)" {
  local test_file="$TEST_PROJECT_DIR/script.py"
  echo "print('hello')" > "$test_file"
  run_format "$test_file"
  assert_success
}

@test "exits 0 for .sh file (not in formattable list)" {
  local test_file="$TEST_PROJECT_DIR/run.sh"
  echo "#!/bin/bash" > "$test_file"
  run_format "$test_file"
  assert_success
}

@test "exits 0 when auto_format is disabled" {
  # Disable formatting in config
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.formatting.auto_format = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  local test_file="$TEST_PROJECT_DIR/app.ts"
  echo "const x = 1" > "$test_file"
  run_format "$test_file"
  assert_success
}

@test "exits 0 for file outside project root" {
  local outside_file="/tmp/test-format-outside-$$.json"
  echo '{"key":"value"}' > "$outside_file"
  run_format "$outside_file"
  assert_success
  rm -f "$outside_file"
}

@test "exits 0 for non-existent file" {
  run_format "$TEST_PROJECT_DIR/does-not-exist.ts"
  assert_success
}

@test "handles Edit tool name correctly" {
  local test_file="$TEST_PROJECT_DIR/style.css"
  echo "body { color: red; }" > "$test_file"
  run_format "$test_file" "Edit"
  assert_success
}

@test "handles formatter=none" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.formatting.formatter = "none"' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  local test_file="$TEST_PROJECT_DIR/app.json"
  echo '{"key":"value"}' > "$test_file"
  run_format "$test_file"
  assert_success
}
