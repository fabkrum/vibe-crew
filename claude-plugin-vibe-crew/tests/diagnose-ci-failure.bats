#!/usr/bin/env bats
# tests/diagnose-ci-failure.bats
# Tests for scripts/diagnose-ci-failure.sh — CI error log pattern matching

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# No input / empty input
# =============================================================================

@test "no input returns unknown category" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "unknown" ]]

  local confidence
  confidence=$(echo "$output" | jq -r '.confidence')
  [[ "$confidence" == "low" ]]
}

@test "empty input returns unknown category" {
  cd "$TEST_PROJECT_DIR"

  run bash -c 'echo "" | bash "$1"' -- "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "unknown" ]]
}

# =============================================================================
# Category detection
# =============================================================================

@test "build errors detected" {
  cd "$TEST_PROJECT_DIR"

  local log
  log=$(cat <<'LOGEOF'
src/index.ts(42,5): error TS2345: Argument of type 'string' is not assignable.
Cannot find module '@/utils/helpers'
Build failed with 2 errors.
LOGEOF
  )

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "build" ]]
}

@test "test failures detected" {
  cd "$TEST_PROJECT_DIR"

  local log
  log=$(cat <<'LOGEOF'
FAIL Tests > Login component
  Expected "success" received "failure"
  test failed: should redirect after login
Tests: 2 failed, 8 passed, 10 total
LOGEOF
  )

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "test" ]]
}

@test "lint errors detected" {
  cd "$TEST_PROJECT_DIR"

  local log
  log=$(cat <<'LOGEOF'
/src/app.tsx
  1:1  eslint  error  Missing return type on function
  5:3  eslint  error  Unexpected console statement
  9:1  eslint  warning  Prefer const over let
Lint error: found 2 errors and 1 warning
LOGEOF
  )

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "lint" ]]
}

@test "dependency errors detected" {
  cd "$TEST_PROJECT_DIR"

  local log
  log=$(cat <<'LOGEOF'
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! Could not resolve peer dependency react@^18.0.0
npm ERR! package not found: @types/node@22.0.0
LOGEOF
  )

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "dep" ]]
}

@test "environment errors detected" {
  cd "$TEST_PROJECT_DIR"

  local log
  log=$(cat <<'LOGEOF'
/bin/sh: node: command not found
Permission denied: /usr/local/bin/deploy
env: python3: No such file or directory
LOGEOF
  )

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "env" ]]
}

# =============================================================================
# Confidence levels
# =============================================================================

@test "high confidence with many matches" {
  cd "$TEST_PROJECT_DIR"

  # Generate 15+ build errors
  local log=""
  for i in $(seq 1 16); do
    log+="src/file$i.ts(1,1): error TS2345: type mismatch"$'\n'
  done

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local confidence
  confidence=$(echo "$output" | jq -r '.confidence')
  [[ "$confidence" == "high" ]]

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "build" ]]
}

@test "medium confidence with moderate matches" {
  cd "$TEST_PROJECT_DIR"

  # Generate 5 test errors
  local log=""
  for i in $(seq 1 5); do
    log+="FAIL test $i: Expected true received false"$'\n'
  done

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local confidence
  confidence=$(echo "$output" | jq -r '.confidence')
  [[ "$confidence" == "medium" ]]
}

# =============================================================================
# Relevant lines
# =============================================================================

@test "relevant lines extracted and limited to 20" {
  cd "$TEST_PROJECT_DIR"

  # Generate 35 error lines
  local log=""
  for i in $(seq 1 35); do
    log+="Error: something failed on line $i"$'\n'
  done

  run bash -c 'echo "$1" | bash "$2"' -- "$log" "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success

  local lines_count
  lines_count=$(echo "$output" | jq '.relevant_lines | length')
  [[ "$lines_count" -le 20 ]]
}

# =============================================================================
# File argument
# =============================================================================

@test "file argument reads from file" {
  cd "$TEST_PROJECT_DIR"

  local logfile="$TEST_PROJECT_DIR/ci-log.txt"
  cat > "$logfile" <<'LOGEOF'
error TS2345: Argument mismatch
Cannot find module '@/lib/db'
Build failed with 2 errors
LOGEOF

  run bash "$SCRIPTS_DIR/diagnose-ci-failure.sh" "$logfile"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.category')
  [[ "$category" == "build" ]]
}

# =============================================================================
# Output validation
# =============================================================================

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  # No input case
  run bash "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success
  echo "$output" | jq empty

  # With input case
  run bash -c 'echo "error TS2345: type mismatch" | bash "$1"' -- "$SCRIPTS_DIR/diagnose-ci-failure.sh"
  assert_success
  echo "$output" | jq empty
}
