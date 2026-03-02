#!/usr/bin/env bats
# tests/restrict-paths.bats
# Tests for scripts/restrict-paths.sh + scripts/sandbox.sh — path validation

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/restrict-paths.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: run restrict-paths.sh with a Write tool payload
# Uses GIT_CEILING_DIRECTORIES to prevent git from finding the outer repo
run_restrict() {
  local file_path="$1"
  local tmpfile
  tmpfile="$(mktemp)"
  jq -n --arg fp "$file_path" '{tool_name: "Write", tool_input: {file_path: $fp, content: "test"}}' > "$tmpfile"
  run bash -c "export GIT_CEILING_DIRECTORIES='$(dirname "$TEST_PROJECT_DIR")' && cd '$TEST_PROJECT_DIR' && cat '$tmpfile' | bash '$SCRIPT'"
  rm -f "$tmpfile"
}

@test "allows writes within project root" {
  run_restrict "$TEST_PROJECT_DIR/src/app.ts"
  assert_success
}

@test "blocks writes outside project root" {
  run_restrict "/tmp/evil-file.txt"
  assert_failure 2
  assert_output --partial "SANDBOX VIOLATION"
}

@test "blocks path traversal (sibling dir with same prefix)" {
  # Create a sibling directory whose name starts with the project dir name
  local sibling="${TEST_PROJECT_DIR}-evil"
  mkdir -p "$sibling"
  run_restrict "${sibling}/payload.sh"
  assert_failure 2
  assert_output --partial "SANDBOX VIOLATION"
  rm -rf "$sibling"
}

@test "blocks .env writes" {
  run_restrict "$TEST_PROJECT_DIR/.env"
  assert_failure 2
  assert_output --partial "sensitive"
}

@test "blocks .ssh/ writes" {
  run_restrict "$TEST_PROJECT_DIR/.ssh/id_rsa"
  assert_failure 2
  assert_output --partial "sensitive"
}

@test "blocks .git/ writes" {
  run_restrict "$TEST_PROJECT_DIR/.git/config"
  assert_failure 2
  assert_output --partial "sensitive"
}

@test "non-Write tool is allowed through" {
  local payload='{"tool_name": "Bash", "tool_input": {"command": "echo hello"}}'
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
  assert_success
}
