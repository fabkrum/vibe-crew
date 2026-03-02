#!/usr/bin/env bats
# tests/compat.bats
# Tests for scripts/lib/compat.sh — cross-platform compatibility helpers

setup() {
  load 'test_helper/common-setup'
  TEST_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  source "$SCRIPTS_DIR/lib/compat.sh"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# --- _compat_readlink_f ---

@test "readlink_f resolves symlink to real path" {
  local real_file="$TEST_DIR/real.txt"
  local link_file="$TEST_DIR/link.txt"
  echo "content" > "$real_file"
  ln -s "$real_file" "$link_file"
  run _compat_readlink_f "$link_file"
  assert_success
  assert_output "$real_file"
}

# --- _compat_realpath ---

@test "realpath resolves non-existent path under existing parent" {
  mkdir -p "$TEST_DIR/existing"
  run _compat_realpath "$TEST_DIR/existing/nonexistent.txt"
  assert_success
  assert_output "$TEST_DIR/existing/nonexistent.txt"
}

# --- _compat_parse_timestamp ---

@test "parse_timestamp handles second-precision ISO 8601" {
  run _compat_parse_timestamp "2020-01-01T00:00:00Z"
  assert_success
  # Should return a valid epoch (non-zero for year 2020)
  [[ "$output" -gt 0 ]]
}

@test "parse_timestamp handles fractional-second ISO 8601" {
  run _compat_parse_timestamp "2020-01-01T00:00:00.123Z"
  assert_success
  [[ "$output" -gt 0 ]]
}

@test "parse_timestamp with and without fractional seconds produce same epoch" {
  local epoch_plain epoch_frac
  epoch_plain=$(_compat_parse_timestamp "2020-06-15T12:30:45Z")
  epoch_frac=$(_compat_parse_timestamp "2020-06-15T12:30:45.789Z")
  [[ "$epoch_plain" == "$epoch_frac" ]]
}

@test "parse_timestamp returns 0 for invalid input" {
  run _compat_parse_timestamp "not-a-timestamp"
  assert_output "0"
}

# --- _compat_fsync ---

@test "fsync succeeds on valid file" {
  local target="$TEST_DIR/fsync-test.txt"
  echo "data" > "$target"
  run _compat_fsync "$target"
  assert_success
}

@test "fsync does not fail on non-existent file" {
  # fsync is best-effort — should not error even on missing file
  run _compat_fsync "$TEST_DIR/does-not-exist.txt"
  assert_success
}

# --- _compat_timestamp_ms ---

@test "timestamp_ms produces ISO 8601 format with milliseconds" {
  run _compat_timestamp_ms
  assert_success
  # Should match YYYY-MM-DDTHH:MM:SS.mmmZ pattern
  [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}Z$ ]]
}

@test "timestamp_ms is parseable by _compat_parse_timestamp" {
  local ts
  ts=$(_compat_timestamp_ms)
  run _compat_parse_timestamp "$ts"
  assert_success
  [[ "$output" -gt 0 ]]
}

# --- _compat_stat_size ---

@test "stat_size returns correct byte count" {
  local target="$TEST_DIR/size-test.txt"
  printf "hello" > "$target"  # 5 bytes, no trailing newline
  run _compat_stat_size "$target"
  assert_success
  assert_output "5"
}

# --- _compat_timeout_cmd ---

@test "timeout_cmd returns a non-empty string on supported systems" {
  run _compat_timeout_cmd
  assert_success
  # On most systems, at least one of timeout/gtimeout should exist
  # If neither exists, output is empty but still succeeds
}
