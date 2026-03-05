#!/usr/bin/env bats
# tests/collect-agent-metrics.bats
# Tests for scripts/collect-agent-metrics.sh — JSONL aggregation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  mkdir -p "$VIBECREW_DIR/agent-logs"
}

teardown() {
  teardown_vibecrew_dir
}

create_jsonl_entry() {
  local agent="$1"
  local tool="$2"
  local class="$3"
  local exit_code="${4:-0}"
  local target="${5:-src/file.ts}"

  echo "{\"ts\":\"2026-03-05T14:00:00Z\",\"agent\":\"$agent\",\"tool\":\"$tool\",\"target\":\"$target\",\"exit\":$exit_code,\"class\":\"$class\",\"phase\":\"code\",\"feat\":\"feat-001\"}"
}

@test "no log file exits cleanly" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/collect-agent-metrics.sh" "nonexistent-session"
  assert_success
  assert_output --partial "No agent log found"
}

@test "aggregates single agent metrics" {
  cd "$TEST_PROJECT_DIR"
  local log_file="$VIBECREW_DIR/agent-logs/session-test-001.jsonl"

  # Create JSONL entries for builder
  create_jsonl_entry "builder" "Write" "progress" > "$log_file"
  create_jsonl_entry "builder" "Read" "exploration" >> "$log_file"
  create_jsonl_entry "builder" "Read" "exploration" >> "$log_file"
  create_jsonl_entry "builder" "Bash" "neutral" >> "$log_file"
  create_jsonl_entry "builder" "Edit" "progress" >> "$log_file"

  run bash "$SCRIPTS_DIR/collect-agent-metrics.sh" "test-001"
  assert_success

  # Verify metrics file was created
  [[ -f "$VIBECREW_DIR/agent-logs/metrics-test-001.json" ]]

  # Verify aggregation
  local total
  total=$(jq -r '.agents.builder.total_tool_calls' "$VIBECREW_DIR/agent-logs/metrics-test-001.json")
  [[ "$total" -eq 5 ]]

  local progress
  progress=$(jq -r '.agents.builder.progress_calls' "$VIBECREW_DIR/agent-logs/metrics-test-001.json")
  [[ "$progress" -eq 2 ]]

  local exploration
  exploration=$(jq -r '.agents.builder.exploration_calls' "$VIBECREW_DIR/agent-logs/metrics-test-001.json")
  [[ "$exploration" -eq 2 ]]
}

@test "aggregates multiple agents" {
  cd "$TEST_PROJECT_DIR"
  local log_file="$VIBECREW_DIR/agent-logs/session-test-002.jsonl"

  create_jsonl_entry "builder" "Write" "progress" > "$log_file"
  create_jsonl_entry "builder" "Read" "exploration" >> "$log_file"
  create_jsonl_entry "verifier" "Bash" "progress" >> "$log_file"
  create_jsonl_entry "verifier" "Read" "exploration" >> "$log_file"
  create_jsonl_entry "verifier" "Bash" "neutral" >> "$log_file"

  run bash "$SCRIPTS_DIR/collect-agent-metrics.sh" "test-002"
  assert_success

  # Builder: 2 calls
  local builder_total
  builder_total=$(jq -r '.agents.builder.total_tool_calls' "$VIBECREW_DIR/agent-logs/metrics-test-002.json")
  [[ "$builder_total" -eq 2 ]]

  # Verifier: 3 calls
  local verifier_total
  verifier_total=$(jq -r '.agents.verifier.total_tool_calls' "$VIBECREW_DIR/agent-logs/metrics-test-002.json")
  [[ "$verifier_total" -eq 3 ]]
}

@test "efficiency ratio calculated correctly" {
  cd "$TEST_PROJECT_DIR"
  local log_file="$VIBECREW_DIR/agent-logs/session-test-003.jsonl"

  # 2 progress, 2 exploration, 1 neutral = 5 total, ratio = 0.40
  create_jsonl_entry "builder" "Write" "progress" > "$log_file"
  create_jsonl_entry "builder" "Edit" "progress" >> "$log_file"
  create_jsonl_entry "builder" "Read" "exploration" >> "$log_file"
  create_jsonl_entry "builder" "Grep" "exploration" >> "$log_file"
  create_jsonl_entry "builder" "Bash" "neutral" >> "$log_file"

  run bash "$SCRIPTS_DIR/collect-agent-metrics.sh" "test-003"
  assert_success

  local ratio
  ratio=$(jq -r '.agents.builder.efficiency_ratio' "$VIBECREW_DIR/agent-logs/metrics-test-003.json")
  [[ "$ratio" == "0.4" ]]
}

@test "failed calls tracked" {
  cd "$TEST_PROJECT_DIR"
  local log_file="$VIBECREW_DIR/agent-logs/session-test-004.jsonl"

  create_jsonl_entry "builder" "Bash" "neutral" "1" > "$log_file"
  create_jsonl_entry "builder" "Bash" "neutral" "0" >> "$log_file"

  run bash "$SCRIPTS_DIR/collect-agent-metrics.sh" "test-004"
  assert_success

  local failed
  failed=$(jq -r '.agents.builder.failed_calls' "$VIBECREW_DIR/agent-logs/metrics-test-004.json")
  [[ "$failed" -eq 1 ]]
}

@test "observability disabled skips collection" {
  cd "$TEST_PROJECT_DIR"

  # Disable observability
  jq '.agent_observability.enabled = false' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  local log_file="$VIBECREW_DIR/agent-logs/session-test-005.jsonl"
  create_jsonl_entry "builder" "Write" "progress" > "$log_file"

  run bash "$SCRIPTS_DIR/collect-agent-metrics.sh" "test-005"
  assert_success
  assert_output --partial "disabled"

  # No metrics file should be created
  [[ ! -f "$VIBECREW_DIR/agent-logs/metrics-test-005.json" ]]
}
