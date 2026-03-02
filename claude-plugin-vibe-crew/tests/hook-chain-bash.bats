#!/usr/bin/env bats
# tests/hook-chain-bash.bats
# Integration tests for Bash hook chain:
#   protect-data.sh → validate-phase-transition.sh
# Tests the combined behavior of PreToolUse hooks on Bash commands

setup() {
  load 'test_helper/common-setup'
  PROTECT_DATA="$SCRIPTS_DIR/protect-data.sh"
  VALIDATE_PHASE="$SCRIPTS_DIR/validate-phase-transition.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Helper for protect-data ---
run_protect() {
  local cmd="$1"
  local tmpfile
  tmpfile="$(mktemp)"
  jq -n --arg cmd "$cmd" '{tool_name: "Bash", tool_input: {command: $cmd}}' > "$tmpfile"
  run bash -c "cat '$tmpfile' | bash '$PROTECT_DATA'"
  rm -f "$tmpfile"
}

# --- Helper for validate-phase-transition ---
run_phase_transition() {
  local cmd="$1"
  local payload
  payload=$(jq -n --arg cmd "$cmd" '{tool_name: "Bash", tool_input: {command: $cmd}}')
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$VALIDATE_PHASE'"
}

# =============================================================================
# Dangerous commands blocked by protect-data
# =============================================================================

@test "chain: rm -rf / blocked before phase validation" {
  run_protect "rm -rf /"
  assert_failure 2
  assert_output --partial "Destructive"
}

@test "chain: sudo blocked before phase validation" {
  run_protect "sudo rm -f /tmp/test"
  assert_failure 2
  assert_output --partial "Privilege"
}

@test "chain: git push --force blocked before phase validation" {
  run_protect "git push --force"
  assert_failure 2
  assert_output --partial "Git"
}

# =============================================================================
# Safe commands pass protect-data
# =============================================================================

@test "chain: npm test passes protect-data" {
  run_protect "npm test"
  assert_success
}

@test "chain: git status passes protect-data" {
  run_protect "git status"
  assert_success
}

@test "chain: npm run build passes protect-data" {
  run_protect "npm run build"
  assert_success
}

# =============================================================================
# Phase transition validation
# =============================================================================

@test "chain: complete-phase with valid phase passes" {
  set_foundation_complete
  set_active_feature "feat-001" "Test Feature" "plan"

  local cmd="bash $SCRIPTS_DIR/complete-phase.sh feat-001 plan"
  run_phase_transition "$cmd"
  assert_success
}

@test "chain: safe command + valid phase = full chain pass" {
  set_foundation_complete
  set_active_feature "feat-001" "Test Feature" "code"

  # A safe bash command (npm test) should pass protect-data
  run_protect "npm test"
  assert_success

  # A phase transition command should pass validate-phase-transition
  run_phase_transition "bash $SCRIPTS_DIR/complete-phase.sh feat-001 code"
  assert_success
}

# =============================================================================
# Combined scenarios
# =============================================================================

@test "chain: dangerous command rejected even with valid phase state" {
  set_foundation_complete
  set_active_feature "feat-001" "Test Feature" "code"

  # Even with a valid phase, dangerous commands are blocked
  run_protect "rm -rf /"
  assert_failure 2
}

@test "chain: eval blocked even in valid phase" {
  set_foundation_complete
  set_active_feature "feat-001" "Test Feature" "code"

  run_protect 'eval "dangerous command"'
  assert_failure 2
  assert_output --partial "Indirect"
}

@test "chain: source .env blocked" {
  run_protect 'source .env'
  assert_failure 2
  assert_output --partial "Credentials"
}

@test "chain: bash <<< blocked" {
  run_protect 'bash <<< "pwned"'
  assert_failure 2
  assert_output --partial "Indirect"
}
