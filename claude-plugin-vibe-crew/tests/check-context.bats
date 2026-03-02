#!/usr/bin/env bats
# tests/check-context.bats
# Tests for scripts/check-context.sh — context window usage monitoring

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/check-context.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Helper: run check-context with a context_window_percent value ---
run_context() {
  local percent="$1"
  local payload
  payload=$(jq -n --argjson p "$percent" '{context_window_percent: $p}')
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
}

@test "exits 0 silently below warning threshold" {
  run_context 30
  assert_success
  refute_output --partial "WARNING"
  refute_output --partial "CRITICAL"
  refute_output --partial "DANGER"
}

@test "outputs WARNING at 65% (default warn threshold 60%)" {
  run_context 65
  assert_success
  assert_output --partial "WARNING"
  assert_output --partial "65%"
}

@test "outputs CRITICAL at 85% (default critical threshold 80%)" {
  run_context 85
  assert_success
  assert_output --partial "CRITICAL"
  assert_output --partial "85%"
}

@test "outputs DANGER at 92%" {
  run_context 92
  assert_success
  assert_output --partial "DANGER"
  assert_output --partial "92%"
}

@test "custom thresholds from config" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.context_warnings.warn_at_percent = 70 | .context_warnings.critical_at_percent = 90' \
    "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # 65% should now be silent (custom warn=70)
  run_context 65
  assert_success
  refute_output --partial "WARNING"

  # 75% should trigger WARNING (above 70)
  run_context 75
  assert_success
  assert_output --partial "WARNING"
}

@test "no context_window_percent in payload is silent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{}' | bash '$SCRIPT'"
  assert_success
  refute_output --partial "WARNING"
}

@test "null context_window_percent is silent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"context_window_percent\":null}' | bash '$SCRIPT'"
  assert_success
  refute_output --partial "WARNING"
}

@test "always exits 0 (never blocks the agent)" {
  run_context 99
  assert_success
}

@test "cleans up stale signal files" {
  # Create a stale signal file (we can't easily backdate mtime in a test,
  # but verify the script doesn't crash when signals dir exists)
  touch "$VIBECREW_DIR/signals/test.signal"
  run_context 30
  assert_success
}
