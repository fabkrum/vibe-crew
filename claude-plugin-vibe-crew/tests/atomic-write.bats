#!/usr/bin/env bats
# tests/atomic-write.bats
# Tests for scripts/lib/atomic-write.sh — shared atomic write library

setup() {
  load 'test_helper/common-setup'
  TEST_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  source "$SCRIPTS_DIR/lib/atomic-write.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "valid JSON write succeeds" {
  local target="$TEST_DIR/test.json"
  echo '{"old": true}' > "$target"
  run atomic_write "$target" '{"new": true}'
  assert_success
  run jq -r '.new' "$target"
  assert_output "true"
}

@test "PID-suffixed temp file is used (no leftover .tmp)" {
  local target="$TEST_DIR/test.json"
  echo '{"old": true}' > "$target"
  atomic_write "$target" '{"new": true}'
  # No .tmp or .tmp.$$ files should remain
  run bash -c "ls '$TEST_DIR'/test.json.tmp* 2>/dev/null | wc -l | tr -d ' '"
  assert_output "0"
}

@test "invalid JSON write restores from backup" {
  local target="$TEST_DIR/test.json"
  echo '{"original": true}' > "$target"
  run atomic_write "$target" 'NOT VALID JSON {'
  assert_failure
  # Original content should be restored
  run jq -r '.original' "$target"
  assert_output "true"
}

@test "backup file preserved for caller rollback" {
  local target="$TEST_DIR/test.json"
  echo '{"v1": true}' > "$target"
  atomic_write "$target" '{"v2": true}'
  # .bak should still exist (caller manages cleanup)
  [ -f "${target}.bak" ]
  run jq -r '.v1' "${target}.bak"
  assert_output "true"
}

@test "--no-backup flag skips backup creation" {
  local target="$TEST_DIR/test.json"
  echo '{"v1": true}' > "$target"
  atomic_write "$target" '{"v2": true}' --no-backup
  # .bak should NOT exist
  [ ! -f "${target}.bak" ]
}

@test "write to new file (no existing target) succeeds" {
  local target="$TEST_DIR/new-file.json"
  run atomic_write "$target" '{"created": true}'
  assert_success
  [ -f "$target" ]
  run jq -r '.created' "$target"
  assert_output "true"
}
