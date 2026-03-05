#!/usr/bin/env bats
# Tests for scripts/context-monitor-posttool.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/context-monitor-posttool.sh"

setup() {
  setup_vibecrew_dir
  # Reset debounce counter
  rm -f "$VIBECREW_DIR/.context-monitor-counter"
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: run the script in the test project directory
run_monitor() {
  local context_pct="${1:-30}"
  cd "$TEST_PROJECT_DIR" && echo "{\"context_window_percent\": $context_pct}" | bash "$SCRIPT"
}

# Helper: run the script N times to reach the debounce interval (5th call checks)
prime_debounce() {
  local context_pct="${1:-30}"
  for i in 1 2 3 4; do
    cd "$TEST_PROJECT_DIR" && echo "{\"context_window_percent\": $context_pct}" | bash "$SCRIPT" > /dev/null 2>&1 || true
  done
}

# --- Debounce logic ---

@test "context-monitor: skips check on first invocation (debounce)" {
  run run_monitor 90
  assert_success
  assert_output ""
}

@test "context-monitor: triggers check on 5th invocation" {
  # First 4 calls produce no output (debounced)
  prime_debounce 50
  # 5th call should produce a warning (50% > 45% threshold)
  run run_monitor 50
  assert_success
  assert_output --partial "additionalContext"
}

@test "context-monitor: counter file increments correctly" {
  run_monitor 30 > /dev/null 2>&1
  [ -f "$VIBECREW_DIR/.context-monitor-counter" ]
  [ "$(cat "$VIBECREW_DIR/.context-monitor-counter")" = "1" ]

  run_monitor 30 > /dev/null 2>&1
  [ "$(cat "$VIBECREW_DIR/.context-monitor-counter")" = "2" ]
}

# --- Threshold detection ---

@test "context-monitor: no warning below 45%" {
  prime_debounce 30
  run run_monitor 30
  assert_success
  assert_output ""
}

@test "context-monitor: INFO warning at 45%" {
  prime_debounce 45
  run run_monitor 45
  assert_success
  assert_output --partial "INFO"
  assert_output --partial "additionalContext"
  assert_output --partial "45%"
}

@test "context-monitor: WARNING at 60%" {
  prime_debounce 60
  run run_monitor 60
  assert_success
  assert_output --partial "WARNING"
  assert_output --partial "additionalContext"
}

@test "context-monitor: CRITICAL at 80%" {
  prime_debounce 80
  run run_monitor 80
  assert_success
  assert_output --partial "CRITICAL"
  assert_output --partial "additionalContext"
}

@test "context-monitor: CRITICAL at 95%" {
  prime_debounce 95
  run run_monitor 95
  assert_success
  assert_output --partial "CRITICAL"
  assert_output --partial "fresh session"
}

# --- additionalContext format ---

@test "context-monitor: output is valid JSON with additionalContext key" {
  prime_debounce 65
  run run_monitor 65
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.additionalContext')" != "null" ]
}

# --- Edge cases ---

@test "context-monitor: handles missing context_window_percent gracefully" {
  prime_debounce 30
  run bash -c 'cd "'"$TEST_PROJECT_DIR"'" && echo "{}" | bash "'"$SCRIPT"'"'
  assert_success
  assert_output ""
}

@test "context-monitor: respects config thresholds" {
  # Set custom thresholds
  cat > "$VIBECREW_DIR/config.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "context_warnings": {
    "warn_at_percent": 50,
    "critical_at_percent": 70
  }
}
EOF
  # 48% should not trigger with threshold at 50
  prime_debounce 48
  run run_monitor 48
  assert_success
  assert_output ""
}

@test "context-monitor: always exits 0" {
  prime_debounce 99
  run run_monitor 99
  assert_success
}
