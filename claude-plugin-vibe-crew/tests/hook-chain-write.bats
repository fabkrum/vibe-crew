#!/usr/bin/env bats
# tests/hook-chain-write.bats
# Integration tests for Write/Edit hook chain:
#   phase-gate.sh → restrict-paths.sh → validate-signal.sh
# Tests the combined behavior of all three PreToolUse hooks on Write/Edit

setup() {
  load 'test_helper/common-setup'
  PHASE_GATE="$SCRIPTS_DIR/phase-gate.sh"
  RESTRICT_PATHS="$SCRIPTS_DIR/restrict-paths.sh"
  VALIDATE_SIGNAL="$SCRIPTS_DIR/validate-signal.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Helper: run all three hooks in chain order ---
# Returns exit code of the first hook that blocks (exit 2)
run_write_chain() {
  local file_path="$1"
  local content="${2:-test content}"
  local payload
  payload=$(create_write_hook_input "$file_path")

  # Phase gate first
  local gate_result
  gate_result=$(cd "$TEST_PROJECT_DIR" && echo "$payload" | bash "$PHASE_GATE" 2>&1) || {
    echo "$gate_result"
    return 2
  }

  # Restrict paths second
  local restrict_result
  restrict_result=$(cd "$TEST_PROJECT_DIR" && echo "$payload" | bash "$RESTRICT_PATHS" 2>&1) || {
    echo "$restrict_result"
    return 2
  }

  echo "PASSED"
  return 0
}

# =============================================================================
# Phase gate blocks source code before foundation complete
# =============================================================================

@test "chain: foundation incomplete blocks src/ write" {
  local payload
  payload=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$PHASE_GATE'"
  assert_failure 2
  assert_output --partial "Foundation"
}

@test "chain: foundation complete allows src/ write" {
  set_foundation_complete

  local payload
  payload=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$PHASE_GATE'"
  assert_success
}

# =============================================================================
# Restrict paths blocks writes outside project root
# =============================================================================

@test "chain: outside project root blocked by restrict-paths" {
  set_foundation_complete

  local payload
  payload=$(create_write_hook_input "/tmp/evil-file.txt")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$RESTRICT_PATHS'"
  assert_failure 2
  assert_output --partial "outside"
}

@test "chain: inside project root allowed by restrict-paths" {
  set_foundation_complete

  local payload
  payload=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$RESTRICT_PATHS'"
  assert_success
}

# =============================================================================
# Valid signal file passes all hooks
# =============================================================================

@test "chain: valid .vibecrew write passes all hooks" {
  set_foundation_complete

  local signal_path="$VIBECREW_DIR/signals/test.signal"
  local payload
  payload=$(create_write_hook_input "$signal_path")

  # Phase gate: .vibecrew files are exempt
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$PHASE_GATE'"
  assert_success

  # Restrict paths: inside project
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$RESTRICT_PATHS'"
  assert_success
}

# =============================================================================
# Signal validation blocks malformed signals
# =============================================================================

@test "chain: invalid signal blocked by validate-signal" {
  set_foundation_complete
  set_active_feature "feat-001" "Test Feature" "code"

  local signal_path="$VIBECREW_DIR/signals/builder-complete.json"
  # Missing required fields
  local bad_content='{"bad":"data"}'
  local payload
  payload=$(create_signal_write_input "$signal_path" "$bad_content")

  local tmpfile
  tmpfile="$(mktemp)"
  echo "$payload" > "$tmpfile"
  run bash -c "cd '$TEST_PROJECT_DIR' && cat '$tmpfile' | bash '$VALIDATE_SIGNAL'"
  rm -f "$tmpfile"
  assert_failure 2
}

# =============================================================================
# Full chain: foundation complete + inside root + valid file = success
# =============================================================================

@test "chain: all hooks pass for valid in-project write after foundation" {
  set_foundation_complete

  local file_path="$TEST_PROJECT_DIR/CLAUDE.md"
  local payload
  payload=$(create_write_hook_input "$file_path")

  # All three hooks should pass
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$PHASE_GATE'"
  assert_success

  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$RESTRICT_PATHS'"
  assert_success
}
