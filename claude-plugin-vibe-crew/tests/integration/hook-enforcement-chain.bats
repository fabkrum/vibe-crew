#!/usr/bin/env bats
# tests/integration/hook-enforcement-chain.bats
# Integration tests for the full hook pipeline:
# Write chain: phase-gate → validate-signal → restrict-paths → format-code
# Bash chain:  protect-data → validate-phase-transition
#
# Critical scripts exercised: phase-gate.sh, validate-signal.sh,
# restrict-paths.sh, protect-data.sh, validate-phase-transition.sh, format-code.sh

setup() {
  load '../test_helper/integration-setup'
  setup_vibecrew_dir
  mock_quality_tools
}

teardown() {
  cleanup_mocks
  teardown_vibecrew_dir
}

# =============================================================================
# Write Chain: Phase Gate
# =============================================================================

@test "integration: foundation incomplete + src file → blocked by phase-gate" {
  # Foundation is incomplete by default
  assert_foundation_incomplete

  local input
  input=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")

  run_phase_gate "$input"
  assert_failure
  assert_output --partial "deny"
}

@test "integration: foundation complete + src file → phase-gate passes" {
  set_foundation_complete

  local input
  input=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")

  run_phase_gate "$input"
  assert_success
}

@test "integration: foundation complete + file outside root → blocked by restrict-paths" {
  set_foundation_complete

  local input
  input=$(create_write_hook_input "/tmp/outside-project/hack.sh")

  run_restrict_paths "$input"
  assert_failure
  assert_output --partial "deny"
}

@test "integration: foundation incomplete + .vibecrew file → exempt from phase-gate" {
  assert_foundation_incomplete

  local input
  input=$(create_write_hook_input "$TEST_PROJECT_DIR/.vibecrew/config.json")

  run_phase_gate "$input"
  assert_success
}

# =============================================================================
# Write Chain: Signal Validation
# =============================================================================

@test "integration: signal file with invalid schema → blocked by validate-signal" {
  set_foundation_complete
  add_feature_to_backlog "sig-feat" "Signal Feature" "in-progress" 1
  set_active_feature "sig-feat" "Signal Feature" "code"

  # Signal missing required 'phase' field
  local content='{"feature_id":"sig-feat","agent":"builder","status":"complete","timestamp":"2026-01-01T00:00:00Z"}'
  local input
  input=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.signal.json" "$content")

  run_validate_signal "$input"
  assert_failure
  assert_output --partial "deny"
  assert_output --partial "phase"
}

@test "integration: signal file with valid schema → passes validate-signal" {
  set_foundation_complete
  add_feature_to_backlog "sig-feat" "Signal Feature" "in-progress" 1
  set_active_feature "sig-feat" "Signal Feature" "code"

  local content='{"feature_id":"sig-feat","phase":"code","agent":"builder","status":"complete","timestamp":"2026-01-01T00:00:00Z"}'
  local input
  input=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/builder-complete.signal.json" "$content")

  run_validate_signal "$input"
  assert_success
}

@test "integration: signal with mismatched feature_id → blocked by validate-signal" {
  set_foundation_complete
  add_feature_to_backlog "real-feat" "Real Feature" "in-progress" 1
  set_active_feature "real-feat" "Real Feature" "code"

  local content='{"feature_id":"wrong-feat","phase":"code","agent":"builder","status":"complete","timestamp":"2026-01-01T00:00:00Z"}'
  local input
  input=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.signal.json" "$content")

  run_validate_signal "$input"
  assert_failure
  assert_output --partial "deny"
  assert_output --partial "does not match"
}

@test "integration: format-code runs after successful write" {
  set_foundation_complete

  # Mock prettier/npx to verify it would be invoked
  mock_command "npx" 0 "formatted"

  # Create a file that format-code would process
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo "const x=1" > "$TEST_PROJECT_DIR/src/app.ts"

  local input
  input=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")

  run_format_code "$input"
  # format-code always exits 0 (never blocks)
  assert_success
}

# =============================================================================
# Bash Chain: Protect Data
# =============================================================================

@test "integration: dangerous commands blocked by protect-data" {
  local dangerous_cmds=(
    "rm -rf /"
    "git push --force origin main"
    "sudo rm -rf /etc"
    "DROP TABLE users;"
  )

  for cmd in "${dangerous_cmds[@]}"; do
    local input
    input=$(create_hook_input "Bash" "$cmd")
    run_protect_data "$input"
    assert_failure
    assert_output --partial "deny"
  done
}

# =============================================================================
# Bash Chain: Phase Transition Validation
# =============================================================================

@test "integration: complete-phase with wrong phase order → blocked" {
  set_foundation_complete
  add_feature_to_backlog "vpt-feat" "VPT Feature" "in-progress" 1
  set_active_feature "vpt-feat" "VPT Feature" "plan"

  # Try to complete "code" when active phase is "plan"
  local input
  input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh vpt-feat code")

  run_validate_phase_transition "$input"
  assert_failure
  assert_output --partial "deny"
}

@test "integration: complete-phase with correct phase → passes" {
  set_foundation_complete
  add_feature_to_backlog "vpt-feat" "VPT Feature" "in-progress" 1
  set_active_feature "vpt-feat" "VPT Feature" "plan"

  local input
  input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh vpt-feat plan")

  run_validate_phase_transition "$input"
  assert_success
}

@test "integration: complete-phase for already-completed phase → blocked" {
  set_foundation_complete
  add_feature_to_backlog "vpt-feat" "VPT Feature" "in-progress" 1
  # Set phase to "plan" so the phase-match check passes, then the already-completed check fires
  set_active_feature "vpt-feat" "VPT Feature" "plan"
  set_phases_completed "plan"

  # Try to re-complete "plan" — should be blocked because plan is already in phases_completed
  local input
  input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh vpt-feat plan")

  run_validate_phase_transition "$input"
  assert_failure
  assert_output --partial "deny"
  assert_output --partial "already been completed"
}

@test "integration: foundation completion with incomplete artifacts → blocked" {
  # Leave one artifact incomplete
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.artifacts.vision.status = "complete" |
      .foundation.artifacts.design_system.status = "complete" |
      .foundation.artifacts.tdr.status = "complete" |
      .foundation.artifacts.roadmap.status = "complete" |
      .foundation.artifacts.architecture_diagrams.status = "pending" |
      .foundation.artifacts.claude_md.status = "complete"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  local input
  input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh foundation")

  run_validate_phase_transition "$input"
  assert_failure
  assert_output --partial "deny"
  assert_output --partial "architecture_diagrams"
}

@test "integration: foundation completion with all artifacts complete → passes" {
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.artifacts.vision.status = "complete" |
      .foundation.artifacts.design_system.status = "complete" |
      .foundation.artifacts.tdr.status = "complete" |
      .foundation.artifacts.roadmap.status = "complete" |
      .foundation.artifacts.architecture_diagrams.status = "complete" |
      .foundation.artifacts.claude_md.status = "complete"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  local input
  input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh foundation")

  run_validate_phase_transition "$input"
  assert_success
}

@test "integration: empty state.json → hooks degrade gracefully" {
  # Minimal valid JSON but missing expected fields
  echo '{}' > "$VIBECREW_DIR/state.json"

  # Phase gate should handle gracefully
  local write_input
  write_input=$(create_write_hook_input "$TEST_PROJECT_DIR/src/app.ts")
  run_phase_gate "$write_input"
  # Should block (no foundation.complete field defaults to incomplete)
  assert_failure

  # Validate-phase-transition should handle gracefully
  local bash_input
  bash_input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh feat-1 plan")
  run_validate_phase_transition "$bash_input"
  # Should allow (can't parse active phase = let complete-phase.sh handle it)
  assert_success
}

# =============================================================================
# Combined Write Chain (Full Pipeline)
# =============================================================================

@test "integration: full write chain passes for valid src file with complete foundation" {
  set_foundation_complete

  local file_path="$TEST_PROJECT_DIR/src/components/Button.tsx"
  local input
  input=$(create_write_hook_input "$file_path")

  # Phase gate passes (foundation complete)
  run_phase_gate "$input"
  assert_success

  # Restrict paths passes (inside project root)
  run_restrict_paths "$input"
  assert_success
}

@test "integration: full write chain blocks src file with incomplete foundation" {
  assert_foundation_incomplete

  local file_path="$TEST_PROJECT_DIR/src/components/Button.tsx"
  local input
  input=$(create_write_hook_input "$file_path")

  # Phase gate blocks
  run_phase_gate "$input"
  assert_failure
  assert_output --partial "deny"
}
