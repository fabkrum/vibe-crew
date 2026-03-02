#!/usr/bin/env bats
# tests/sandbox.bats
# Tests for scripts/sandbox.sh — path sandboxing and sensitive file checks

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Source sandbox within the test project context
  cd "$TEST_PROJECT_DIR"
  source "$SCRIPTS_DIR/sandbox.sh"
}

teardown() {
  teardown_vibecrew_dir
}

# --- sandbox_check_path ---

@test "path within project root is allowed" {
  run sandbox_check_path "$TEST_PROJECT_DIR/src/app.js"
  assert_success
}

@test "path outside project root is blocked" {
  run sandbox_check_path "/tmp/outside-file.txt"
  assert_failure
}

@test "parent traversal (../) is blocked" {
  mkdir -p "$TEST_PROJECT_DIR/src"
  run sandbox_check_path "$TEST_PROJECT_DIR/src/../../etc/passwd"
  assert_failure
}

@test "symlink escape is detected" {
  # Create a symlink inside project that points outside
  ln -s /tmp "$TEST_PROJECT_DIR/escape-link"
  run sandbox_check_path "$TEST_PROJECT_DIR/escape-link/outside.txt"
  assert_failure
}

# --- sandbox_check_sensitive_file ---

@test ".env file is blocked" {
  run sandbox_check_sensitive_file "$TEST_PROJECT_DIR/.env"
  assert_failure
}

@test ".env.local file is blocked" {
  run sandbox_check_sensitive_file "$TEST_PROJECT_DIR/.env.local"
  assert_failure
}

@test ".git directory is blocked" {
  run sandbox_check_sensitive_file "$TEST_PROJECT_DIR/.git/config"
  assert_failure
}

@test ".ssh directory is blocked" {
  run sandbox_check_sensitive_file "$TEST_PROJECT_DIR/.ssh/id_rsa"
  assert_failure
}

@test "credentials.json is blocked" {
  run sandbox_check_sensitive_file "$TEST_PROJECT_DIR/credentials.json"
  assert_failure
}

@test "normal source file is allowed" {
  run sandbox_check_sensitive_file "$TEST_PROJECT_DIR/src/app.js"
  assert_success
}

# --- sandbox_canonicalize ---

@test "canonicalize resolves relative path" {
  run sandbox_canonicalize "src/app.js"
  assert_success
  assert_output "$TEST_PROJECT_DIR/src/app.js"
}

@test "canonicalize resolves tilde path" {
  run sandbox_canonicalize "~/some/file.txt"
  assert_success
  assert_output "$HOME/some/file.txt"
}

# --- sandbox_validate_write (combined check) ---

@test "validate_write passes for normal project file" {
  run sandbox_validate_write "$TEST_PROJECT_DIR/src/index.js"
  assert_success
}

@test "validate_write blocks write outside project" {
  run sandbox_validate_write "/tmp/malicious.sh"
  assert_failure
  assert_output --partial "SANDBOX VIOLATION"
}

@test "validate_write blocks sensitive file write" {
  run sandbox_validate_write "$TEST_PROJECT_DIR/.env"
  assert_failure
  assert_output --partial "SANDBOX VIOLATION"
  assert_output --partial "sensitive"
}
