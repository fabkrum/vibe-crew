#!/usr/bin/env bats
# tests/validate-signal.bats
# Tests for scripts/validate-signal.sh — signal file validation hook

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/validate-signal.sh"
  setup_vibecrew_dir
  set_foundation_complete
  set_active_feature "feat-001" "Test Feature" "code"
}

teardown() {
  teardown_vibecrew_dir
}

VALID_SIGNAL='{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete"
}'

# =============================================================================
# Passthrough tests
# =============================================================================

@test "passthrough: non-signal file is allowed" {
  INPUT=$(create_write_hook_input "$TEST_PROJECT_DIR/src/index.ts")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "passthrough: Edit tool is allowed (skip validation)" {
  INPUT=$(create_edit_hook_input "$TEST_PROJECT_DIR/.vibecrew/signals/builder-complete.json")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "passthrough: non-JSON signal path is allowed" {
  INPUT=$(create_write_hook_input "$TEST_PROJECT_DIR/.vibecrew/signals/README.md")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "passthrough: Bash tool is allowed" {
  INPUT=$(create_hook_input "Bash" "echo hello")
  run bash -c "echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

# =============================================================================
# Valid signal
# =============================================================================

@test "valid signal: allows well-formed signal file" {
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/builder-complete.json" "$VALID_SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

# =============================================================================
# Required fields
# =============================================================================

@test "required: rejects signal missing feature_id" {
  SIGNAL='{"phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "missing required field: feature_id"
}

@test "required: rejects signal missing phase" {
  SIGNAL='{"feature_id":"feat-001","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "missing required field: phase"
}

@test "required: rejects signal missing timestamp" {
  SIGNAL='{"feature_id":"feat-001","phase":"code","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "missing required field: timestamp"
}

@test "required: rejects signal missing agent" {
  SIGNAL='{"feature_id":"feat-001","phase":"code","timestamp":"2026-03-01T10:00:00Z","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "missing required field: agent"
}

@test "required: rejects signal missing status" {
  SIGNAL='{"feature_id":"feat-001","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "missing required field: status"
}

# =============================================================================
# Enum validation
# =============================================================================

@test "enum: rejects invalid phase" {
  SIGNAL='{"feature_id":"feat-001","phase":"invalid","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "invalid phase"
}

@test "enum: rejects invalid agent" {
  SIGNAL='{"feature_id":"feat-001","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"invalid-agent","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "invalid agent"
}

@test "enum: rejects invalid status" {
  SIGNAL='{"feature_id":"feat-001","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"pending"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "invalid status"
}

# =============================================================================
# Invalid JSON
# =============================================================================

@test "rejects invalid JSON content" {
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "not valid json {{{")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "invalid JSON"
}

# =============================================================================
# Cross-validation: feature_id vs active feature
# =============================================================================

@test "cross-validation: rejects mismatched feature_id" {
  SIGNAL='{"feature_id":"feat-999","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_failure
  assert_output --partial "does not match active feature"
}

@test "cross-validation: allows matching feature_id" {
  SIGNAL='{"feature_id":"feat-001","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "cross-validation: allows any feature_id when no active feature" {
  # Reset active feature to null
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.active_feature.id = null' "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  SIGNAL='{"feature_id":"feat-999","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}

@test "cross-validation: allows signal when state.json missing" {
  rm -f "$VIBECREW_DIR/state.json"

  SIGNAL='{"feature_id":"feat-001","phase":"code","timestamp":"2026-03-01T10:00:00Z","agent":"builder","status":"complete"}'
  INPUT=$(create_signal_write_input "$TEST_PROJECT_DIR/.vibecrew/signals/test.json" "$SIGNAL")
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$INPUT' | bash '$SCRIPT'"
  assert_success
}
