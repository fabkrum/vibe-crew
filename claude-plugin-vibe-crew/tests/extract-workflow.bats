#!/usr/bin/env bats
# tests/extract-workflow.bats
# Tests for scripts/extract-workflow.sh — session log → workflow template extraction

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# Argument validation
# =============================================================================

@test "missing workflow name: outputs error to stderr" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-workflow.sh"
  assert_success

  # Error goes to stderr which BATS captures in output when exit code is 0
  # The script writes error JSON to stderr and exits 0
  # With `run`, stderr is merged into output
  [[ "$output" == *"error"* ]] || [[ "$output" == *"Missing workflow name"* ]]
}

@test "name is kebab-cased" {
  cd "$TEST_PROJECT_DIR"

  # Create eligible score and session files
  echo '{"score": 85, "session_id": "session-001", "deductions": [], "bonuses": [], "metrics": {"phases": {"plan": true, "code": true, "test": true}}}' \
    > "$VIBECREW_DIR/scores/score-2026-01-01-001.json"
  echo '{"session_id": "session-001", "files_modified": [], "tests": {"ran": true}, "commits": []}' \
    > "$VIBECREW_DIR/sessions/session-001.json"

  run bash "$SCRIPTS_DIR/extract-workflow.sh" "My Workflow Name"
  assert_success

  local name
  name=$(echo "$output" | jq -r '.name')
  [[ "$name" == "my-workflow-name" ]]
}

@test "no eligible sessions: error in stderr" {
  cd "$TEST_PROJECT_DIR"

  # No score or session files at all
  rm -rf "$VIBECREW_DIR/scores"/*
  rm -rf "$VIBECREW_DIR/sessions"/*

  run bash "$SCRIPTS_DIR/extract-workflow.sh" "test-workflow"
  assert_success

  # Error about no sessions goes to stderr (merged into output by BATS)
  [[ "$output" == *"error"* ]] || [[ "$output" == *"No sessions found"* ]]
}

# =============================================================================
# Workflow file creation
# =============================================================================

@test "creates workflow file" {
  cd "$TEST_PROJECT_DIR"

  # Create eligible score file (score >= 70) and matching session
  echo '{"score": 85, "session_id": "session-001", "deductions": [], "bonuses": [], "metrics": {"phases": {"plan": true, "code": true, "test": true}}}' \
    > "$VIBECREW_DIR/scores/score-2026-01-01-001.json"
  echo '{"session_id": "session-001", "files_modified": ["app.ts"], "tests": {"ran": true}, "commits": [{"message": "feat: add login"}]}' \
    > "$VIBECREW_DIR/sessions/session-001.json"

  run bash "$SCRIPTS_DIR/extract-workflow.sh" "test-workflow"
  assert_success

  [[ -f "$VIBECREW_DIR/workflows/workflow-test-workflow.json" ]]
}

@test "workflow has required fields" {
  cd "$TEST_PROJECT_DIR"

  echo '{"score": 90, "session_id": "session-002", "deductions": [], "bonuses": [], "metrics": {"phases": {"plan": true, "code": true, "test": true, "review": true}}}' \
    > "$VIBECREW_DIR/scores/score-2026-01-02-001.json"
  echo '{"session_id": "session-002", "files_modified": [], "tests": {"ran": false}, "commits": []}' \
    > "$VIBECREW_DIR/sessions/session-002.json"

  run bash "$SCRIPTS_DIR/extract-workflow.sh" "full-check"
  assert_success

  # Check required top-level fields
  echo "$output" | jq -e '.schema_version'
  echo "$output" | jq -e '.name'
  echo "$output" | jq -e '.phase_order'
  echo "$output" | jq -e '.test_strategy'
  echo "$output" | jq -e '.quality_thresholds'
}

# =============================================================================
# Output format
# =============================================================================

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  echo '{"score": 85, "session_id": "session-003", "deductions": [], "bonuses": [], "metrics": {"phases": {}}}' \
    > "$VIBECREW_DIR/scores/score-2026-01-03-001.json"
  echo '{"session_id": "session-003", "files_modified": [], "tests": {"ran": false}, "commits": []}' \
    > "$VIBECREW_DIR/sessions/session-003.json"

  run bash "$SCRIPTS_DIR/extract-workflow.sh" "json-check"
  assert_success

  echo "$output" | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-workflow.sh" "exit-check"
  assert_success
}
