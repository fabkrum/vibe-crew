#!/usr/bin/env bats
# Tests for scripts/prepare-feature-context.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/prepare-feature-context.sh"

setup() {
  setup_vibecrew_dir
  # Add a feature to the backlog
  add_feature_to_backlog "feat-001" "User Authentication" "planned" 1
  # Add initial commit
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

# --- Error handling ---

@test "prepare-feature-context: fails without feature-id argument" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  [[ "$output" == *"Usage:"* ]]
}

@test "prepare-feature-context: fails when feature not in backlog" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'nonexistent-feature'"
  assert_failure
  [[ "$output" == *"not found"* ]]
}

@test "prepare-feature-context: fails when backlog.json missing" {
  rm "$VIBECREW_DIR/backlog.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_failure
  [[ "$output" == *"backlog.json not found"* ]]
}

# --- Output structure ---

@test "prepare-feature-context: outputs Feature Execution Context header" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"# Feature Execution Context"* ]]
}

@test "prepare-feature-context: includes feature spec from backlog" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"## Feature Spec"* ]]
  [[ "$output" == *"User Authentication"* ]]
}

@test "prepare-feature-context: includes TDR section" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"## TDR"* ]]
}

@test "prepare-feature-context: shows TDR content when file exists" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  echo "# Technology Decision Record" > "$TEST_PROJECT_DIR/docs/tdr.md"
  echo "Framework: Next.js" >> "$TEST_PROJECT_DIR/docs/tdr.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"Framework: Next.js"* ]]
}

@test "prepare-feature-context: includes CLAUDE.md section" {
  echo "# Project Rules" > "$TEST_PROJECT_DIR/CLAUDE.md"
  echo "Use TypeScript strict mode." >> "$TEST_PROJECT_DIR/CLAUDE.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"## Project CLAUDE.md"* ]]
  [[ "$output" == *"Use TypeScript strict mode"* ]]
}

@test "prepare-feature-context: includes git context" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"## Git Context"* ]]
  [[ "$output" == *"Branch:"* ]]
}

@test "prepare-feature-context: includes phase execution instructions" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"## Phase Execution Instructions"* ]]
  [[ "$output" == *"Do NOT run Review or Docs"* ]]
}

@test "prepare-feature-context: includes all required sections" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 'feat-001'"
  assert_success
  [[ "$output" == *"## Feature Spec"* ]]
  [[ "$output" == *"## TDR"* ]]
  [[ "$output" == *"## Architecture Diagrams"* ]]
  [[ "$output" == *"## Design System Tokens"* ]]
  [[ "$output" == *"## Project CLAUDE.md"* ]]
  [[ "$output" == *"## User Profile"* ]]
  [[ "$output" == *"## Codebase Analysis"* ]]
  [[ "$output" == *"## Git Context"* ]]
  [[ "$output" == *"## Phase Execution Instructions"* ]]
}
