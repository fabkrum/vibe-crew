#!/usr/bin/env bats
# tests/detect-terminal.bats
# Tests for scripts/detect-terminal.sh — terminal emulator detection

setup() {
  load 'test_helper/common-setup'
  # Save and unset terminal vars
  _SAVED_WARP="${WARP_SESSION_ID:-}"
  _SAVED_TERM_PROG="${TERM_PROGRAM:-}"
  _SAVED_TMUX="${TMUX:-}"
  unset WARP_SESSION_ID TERM_PROGRAM TMUX
}

teardown() {
  # Restore terminal vars
  if [[ -n "$_SAVED_WARP" ]]; then export WARP_SESSION_ID="$_SAVED_WARP"; else unset WARP_SESSION_ID; fi
  if [[ -n "$_SAVED_TERM_PROG" ]]; then export TERM_PROGRAM="$_SAVED_TERM_PROG"; else unset TERM_PROGRAM; fi
  if [[ -n "$_SAVED_TMUX" ]]; then export TMUX="$_SAVED_TMUX"; else unset TMUX; fi
}

@test "detects Warp terminal" {
  export WARP_SESSION_ID="test-session-123"
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "warp" ]]

  local method
  method=$(echo "$output" | jq -r '.notification_method')
  [[ "$method" == "warp-deeplink" ]]

  local warp_id
  warp_id=$(echo "$output" | jq -r '.warp_session_id')
  [[ "$warp_id" == "test-session-123" ]]
}

@test "detects iTerm" {
  export TERM_PROGRAM="iTerm.app"
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "iterm" ]]

  local method
  method=$(echo "$output" | jq -r '.notification_method')
  [[ "$method" == "osc9" ]]

  local osc
  osc=$(echo "$output" | jq '.supports_osc')
  [[ "$osc" == "true" ]]
}

@test "detects VS Code terminal" {
  export TERM_PROGRAM="vscode"
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "vscode" ]]

  local method
  method=$(echo "$output" | jq -r '.notification_method')
  [[ "$method" == "terminal-notifier" ]]
}

@test "detects Apple Terminal" {
  export TERM_PROGRAM="Apple_Terminal"
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "terminal" ]]
}

@test "detects tmux" {
  export TMUX="/tmp/tmux-123/default,123,0"
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "tmux" ]]
}

@test "unknown terminal returns defaults" {
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "unknown" ]]

  local method
  method=$(echo "$output" | jq -r '.notification_method')
  [[ "$method" == "bell" ]]
}

@test "output is valid JSON" {
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success
  echo "$output" | jq empty
}

@test "Warp takes priority over TERM_PROGRAM" {
  export WARP_SESSION_ID="warp-123"
  export TERM_PROGRAM="iTerm.app"
  run bash "$SCRIPTS_DIR/detect-terminal.sh"
  assert_success

  local terminal
  terminal=$(echo "$output" | jq -r '.terminal')
  [[ "$terminal" == "warp" ]]
}
