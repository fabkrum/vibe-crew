#!/usr/bin/env bats
# tests/aggregate-costs.bats
# Tests for scripts/aggregate-costs.sh — cost aggregation

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "no sessions returns all zeros" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local total
  total=$(echo "$output" | jq '.session_count_total')
  [[ "$total" == "0" ]]

  local alltime
  alltime=$(echo "$output" | jq '.all_time_cost_usd')
  [[ $(echo "$alltime == 0" | bc -l) == "1" ]]
}

@test "single session cost added to all-time" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/sessions"
  local today
  today=$(date +%Y-%m-%d)
  cat > "$VIBECREW_DIR/sessions/session-${today}-001.json" <<EOF
{"started_at":"${today}T10:00:00Z","tokens":{"estimated_cost_usd":1.50}}
EOF

  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local total
  total=$(echo "$output" | jq '.session_count_total')
  [[ "$total" == "1" ]]

  local alltime
  alltime=$(echo "$output" | jq '.all_time_cost_usd')
  # Should be at least 1.50
  [[ $(echo "$alltime >= 1.50" | bc -l) == "1" ]]
}

@test "today's sessions in daily bucket" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/sessions"
  local today
  today=$(date +%Y-%m-%d)
  cat > "$VIBECREW_DIR/sessions/session-${today}-001.json" <<EOF
{"started_at":"${today}T10:00:00Z","tokens":{"estimated_cost_usd":2.00}}
EOF

  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local daily
  daily=$(echo "$output" | jq '.daily_cost_usd')
  [[ $(echo "$daily >= 2.00" | bc -l) == "1" ]]

  local today_count
  today_count=$(echo "$output" | jq '.session_count_today')
  [[ "$today_count" == "1" ]]
}

@test "live session cost added to buckets" {
  cd "$TEST_PROJECT_DIR"
  echo '{"session_cost_usd":0.75}' > "$VIBECREW_DIR/session-cost.json"

  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local live
  live=$(echo "$output" | jq '.live_session_cost_usd')
  [[ $(echo "$live >= 0.75" | bc -l) == "1" ]]
}

@test "multiple sessions summed correctly" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/sessions"
  local today
  today=$(date +%Y-%m-%d)
  for i in 1 2 3; do
    cat > "$VIBECREW_DIR/sessions/session-${today}-00${i}.json" <<EOF
{"started_at":"${today}T10:00:00Z","tokens":{"estimated_cost_usd":1.00}}
EOF
  done

  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local total
  total=$(echo "$output" | jq '.session_count_total')
  [[ "$total" == "3" ]]
}

@test "old sessions not in daily bucket" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/sessions"
  cat > "$VIBECREW_DIR/sessions/session-2025-01-01-001.json" <<'EOF'
{"started_at":"2025-01-01T10:00:00Z","tokens":{"estimated_cost_usd":5.00}}
EOF

  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local daily
  daily=$(echo "$output" | jq '.daily_cost_usd')
  # Should be 0 (only live cost, which is 0)
  [[ $(echo "$daily <= 0.01" | bc -l) == "1" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success
  echo "$output" | jq empty
}

@test "output contains computed_at timestamp" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/aggregate-costs.sh"
  assert_success

  local ts
  ts=$(echo "$output" | jq -r '.computed_at')
  [[ "$ts" != "null" ]]
  [[ "$ts" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T ]]
}
