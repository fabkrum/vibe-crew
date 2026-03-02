#!/usr/bin/env bats
# tests/cost-guardrails.bats
# Tests for scripts/cost-guardrails.sh — session cost monitoring with hard limits

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/cost-guardrails.sh"
  setup_vibecrew_dir

  # Remove any pre-existing session cost file
  rm -f "$VIBECREW_DIR/session-cost.json"

  # Add pricing to config so costs calculate correctly (jq on empty pricing returns empty)
  jq '. + {pricing: {sonnet: {input: 3.00, cache_create: 3.75, cache_read: 0.30, output: 15.00}}}' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: build a token usage payload
make_payload() {
  local input_tokens="${1:-0}"
  local output_tokens="${2:-0}"
  local model="${3:-claude-sonnet-4-20250514}"
  jq -n \
    --argjson it "$input_tokens" \
    --argjson ot "$output_tokens" \
    --arg model "$model" \
    '{model: $model, usage: {input_tokens: $it, cache_creation_input_tokens: 0, cache_read_input_tokens: 0, output_tokens: $ot}}'
}

@test "exit 0 when below thresholds" {
  local payload
  payload=$(make_payload 100 50)
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
  assert_success
}

@test "warning message when exceeding session_warn_usd" {
  # Set a very low warning threshold; pricing ensures nonzero cost
  jq '.cost_limits = {"session_warn_usd": 0.0001, "session_max_usd": 100, "daily_warn_usd": 100}' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  local payload
  payload=$(make_payload 10000 5000)
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
  assert_success
  assert_output --partial "COST WARNING"
}

@test "exit 2 when exceeding session_max_usd (default hard_stop: true)" {
  # Set very low max threshold
  jq '.cost_limits = {"session_warn_usd": 0.0001, "session_max_usd": 0.0001, "daily_warn_usd": 100}' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  local payload
  payload=$(make_payload 10000 5000)
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
  assert_failure 2
  assert_output --partial "COST LIMIT"
}

@test "exit 0 when hard_stop: false with warning message" {
  # Set very low max but hard_stop false
  jq '.cost_limits = {"session_warn_usd": 0.0001, "session_max_usd": 0.0001, "daily_warn_usd": 100, "hard_stop": false}' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  local payload
  payload=$(make_payload 10000 5000)
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
  assert_success
  assert_output --partial "COST LIMIT"
}

@test "empty stdin handled gracefully" {
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '' | bash '$SCRIPT'"
  assert_success
}
