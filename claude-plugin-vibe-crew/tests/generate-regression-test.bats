#!/usr/bin/env bats
# tests/generate-regression-test.bats
# Unit tests for scripts/generate-regression-test.sh

load 'test_helper/common-setup'

setup() {
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/generate-regression-test.sh"

  # Create git history
  cd "$TEST_PROJECT_DIR"

  mkdir -p scripts
  echo '#!/usr/bin/env bash' > scripts/broken-script.sh
  echo 'echo "fixed"' >> scripts/broken-script.sh
  git add scripts/broken-script.sh
  git commit -m "fix(auth): handle special characters in login" 2>/dev/null
  BASH_FIX_HASH=$(git rev-parse HEAD)

  mkdir -p src/lib
  echo 'export function calculate() { return 42; }' > src/lib/math.ts
  git add src/lib/math.ts
  git commit -m "fix(billing): calculate tax correctly, fixes #123" 2>/dev/null
  TS_FIX_HASH=$(git rev-parse HEAD)

  export BASH_FIX_HASH TS_FIX_HASH
}

teardown() {
  teardown_vibecrew_dir
}

run_generate() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' $*"
}

# =============================================================================
# BATS Skeleton Generation
# =============================================================================

@test "generates BATS skeleton for .sh script fixes" {
  run_generate "$BASH_FIX_HASH" bats
  assert_success

  # Output should contain the test file path
  assert_output --partial ".bats"

  # Verify the file was created
  local test_file
  test_file=$(echo "$output" | tr -d '[:space:]')
  [ -f "$test_file" ]

  # Verify content structure
  run cat "$test_file"
  assert_output --partial "regression"
  assert_output --partial "handle special characters in login"
  assert_output --partial "skip"
  assert_output --partial "common-setup"
}

# =============================================================================
# Vitest Skeleton Generation
# =============================================================================

@test "generates Vitest skeleton for .ts file fixes" {
  run_generate "$TS_FIX_HASH" vitest
  assert_success

  local test_file
  test_file=$(echo "$output" | tr -d '[:space:]')
  [ -f "$test_file" ]

  run cat "$test_file"
  assert_output --partial "regression"
  assert_output --partial "calculate tax correctly"
  assert_output --partial "vitest"
  assert_output --partial "expect(true).toBe(false)"
}

@test "generates Jest skeleton for .ts file fixes" {
  run_generate "$TS_FIX_HASH" jest
  assert_success

  local test_file
  test_file=$(echo "$output" | tr -d '[:space:]')
  [ -f "$test_file" ]

  run cat "$test_file"
  assert_output --partial "regression"
  assert_output --partial "calculate tax correctly"
}

# =============================================================================
# Error Handling
# =============================================================================

@test "rejects invalid framework" {
  run_generate "$BASH_FIX_HASH" invalid
  assert_failure
  assert_output --partial "Invalid framework"
}

@test "rejects missing commit hash" {
  run_generate "nonexistent123456" bats
  assert_failure
  assert_output --partial "Could not find commit"
}

@test "requires both arguments" {
  run_generate
  assert_failure
  assert_output --partial "Usage"
}

# =============================================================================
# Test Directory Pattern
# =============================================================================

@test "uses __tests__ directory when it exists" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p src/lib/__tests__

  run_generate "$TS_FIX_HASH" vitest
  assert_success

  assert_output --partial "__tests__"
}
