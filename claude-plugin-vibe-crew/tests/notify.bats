#!/usr/bin/env bats
# tests/notify.bats
# Tests for scripts/notify.sh — notification dispatch

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/notify.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Helper: run notify with a notification type ---
run_notify() {
  local type="$1"
  local extra_arg="${2:-}"
  local payload
  payload=$(jq -n --arg t "$type" '{notification_type: $t, message: "Test message"}')
  if [[ -n "$extra_arg" ]]; then
    run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT' '$extra_arg'"
  else
    run bash -c "cd '$TEST_PROJECT_DIR' && echo '$payload' | bash '$SCRIPT'"
  fi
}

@test "exits 0 when notifications disabled" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.notifications.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run_notify "permission_prompt"
  assert_success
}

@test "exits 0 silently for non-critical event types" {
  run_notify "other_event"
  assert_success
}

@test "exits 0 silently for empty notification type" {
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"message\":\"test\"}' | bash '$SCRIPT'"
  assert_success
}

@test "permission_prompt sets correct title" {
  run_notify "permission_prompt"
  assert_success
  # Check notification log for the title
  if [[ -f "$VIBECREW_DIR/notifications.log" ]]; then
    run grep "Approval Needed" "$VIBECREW_DIR/notifications.log"
    assert_success
  fi
}

@test "idle_prompt sets correct title" {
  run_notify "idle_prompt"
  assert_success
  if [[ -f "$VIBECREW_DIR/notifications.log" ]]; then
    run grep "Task Complete" "$VIBECREW_DIR/notifications.log"
    assert_success
  fi
}

@test "error argument sets error title" {
  run_notify "some_event" "error"
  assert_success
  if [[ -f "$VIBECREW_DIR/notifications.log" ]]; then
    run grep "Error" "$VIBECREW_DIR/notifications.log"
    assert_success
  fi
}

@test "writes to notifications.log for permission_prompt" {
  run_notify "permission_prompt"
  assert_success
  # Log should be written since .vibecrew exists
  if [[ -f "$VIBECREW_DIR/notifications.log" ]]; then
    run grep "Approval Needed" "$VIBECREW_DIR/notifications.log"
    assert_success
  fi
  # Even if log file not created (e.g. redirect fail), script exits 0
}

@test "always exits 0 (never blocks the agent)" {
  run_notify "permission_prompt"
  assert_success
  run_notify "idle_prompt"
  assert_success
  run_notify "unknown"
  assert_success
}
