#!/usr/bin/env bats
# tests/agent-identity.bats
# Tests for agent identity system (register, deregister, read)

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "register-agent.sh creates identity file" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  set_active_feature "feat-001" "auth" "code"

  run bash "$SCRIPTS_DIR/register-agent.sh" "builder"
  assert_success
  assert_output --partial "Registered agent: builder"

  # Verify identity file exists
  [[ -f "$VIBECREW_DIR/locks/active-agent.json" ]]

  # Verify schema
  local agent
  agent=$(jq -r '.agent' "$VIBECREW_DIR/locks/active-agent.json")
  [[ "$agent" == "builder" ]]

  local phase
  phase=$(jq -r '.phase' "$VIBECREW_DIR/locks/active-agent.json")
  [[ "$phase" == "code" ]]

  local feat
  feat=$(jq -r '.feature_id' "$VIBECREW_DIR/locks/active-agent.json")
  [[ "$feat" == "feat-001" ]]
}

@test "deregister-agent.sh removes identity file" {
  cd "$TEST_PROJECT_DIR"
  # First register
  bash "$SCRIPTS_DIR/register-agent.sh" "builder"
  [[ -f "$VIBECREW_DIR/locks/active-agent.json" ]]

  # Then deregister
  run bash "$SCRIPTS_DIR/deregister-agent.sh"
  assert_success
  assert_output --partial "Agent deregistered"

  # File should be gone
  [[ ! -f "$VIBECREW_DIR/locks/active-agent.json" ]]
}

@test "read_active_agent returns agent name when registered" {
  cd "$TEST_PROJECT_DIR"
  bash "$SCRIPTS_DIR/register-agent.sh" "verifier"

  source "$SCRIPTS_DIR/lib/agent-identity.sh"
  local result
  result=$(read_active_agent)
  [[ "$result" == "verifier" ]]
}

@test "read_active_agent returns unknown when no agent registered" {
  cd "$TEST_PROJECT_DIR"

  source "$SCRIPTS_DIR/lib/agent-identity.sh"
  local result
  result=$(read_active_agent)
  [[ "$result" == "unknown" ]]
}

@test "register-agent.sh requires agent name argument" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/register-agent.sh"
  assert_failure
}

@test "identity file has valid JSON" {
  cd "$TEST_PROJECT_DIR"
  bash "$SCRIPTS_DIR/register-agent.sh" "performance-coach"

  # Should pass jq validation
  run jq empty "$VIBECREW_DIR/locks/active-agent.json"
  assert_success

  # Should have required fields
  local started_at
  started_at=$(jq -r '.started_at' "$VIBECREW_DIR/locks/active-agent.json")
  [[ "$started_at" != "null" ]]

  local pid
  pid=$(jq -r '.pid' "$VIBECREW_DIR/locks/active-agent.json")
  [[ "$pid" =~ ^[0-9]+$ ]]
}

@test "register overwrites previous agent" {
  cd "$TEST_PROJECT_DIR"
  bash "$SCRIPTS_DIR/register-agent.sh" "builder"
  bash "$SCRIPTS_DIR/register-agent.sh" "verifier"

  local agent
  agent=$(jq -r '.agent' "$VIBECREW_DIR/locks/active-agent.json")
  [[ "$agent" == "verifier" ]]
}
