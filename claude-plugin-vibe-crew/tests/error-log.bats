#!/usr/bin/env bats

# Tests for R14: Silent Failure Accounting

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/.vibecrew"
  export PROJECT_ROOT="$TEST_DIR"
  export _ERROR_LOG_PROJECT_ROOT="$TEST_DIR"
  export _ERROR_LOG_FILE="$TEST_DIR/.vibecrew/session-errors.jsonl"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "log_error writes valid JSONL" {
  source "$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts/lib" && pwd)/error-log.sh"

  log_error "test-source" "Test error message"

  [ -f "$_ERROR_LOG_FILE" ]
  jq . "$_ERROR_LOG_FILE" > /dev/null  # Valid JSON per line
  [ "$(jq -r '.source' "$_ERROR_LOG_FILE")" = "test-source" ]
}

@test "log_error appends multiple entries" {
  source "$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts/lib" && pwd)/error-log.sh"

  log_error "source-1" "Error one"
  log_error "source-2" "Error two"

  LINE_COUNT=$(wc -l < "$_ERROR_LOG_FILE" | tr -d ' ')
  [ "$LINE_COUNT" -eq 2 ]
}

@test "log_error handles special characters" {
  source "$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts/lib" && pwd)/error-log.sh"

  log_error "format-code" "Failed: can't parse \"file.ts\" (unexpected token)"

  [ -f "$_ERROR_LOG_FILE" ]
  # Should be parseable JSON despite special chars
  jq -e '.source' "$_ERROR_LOG_FILE" > /dev/null
}
