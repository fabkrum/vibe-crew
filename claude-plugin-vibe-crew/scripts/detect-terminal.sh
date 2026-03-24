#!/usr/bin/env bash
# scripts/detect-terminal.sh
# Detects the current terminal emulator and outputs capabilities as JSON.
# Used by notify.sh and session-startup to configure notification routing.
# Usage: detect-terminal.sh
# Output: JSON object to stdout
# Designed to be fast -- no external commands beyond jq for JSON output.

set -euo pipefail

# --- Detect terminal ---
TERMINAL="unknown"
NOTIFICATION_METHOD="bell"
SUPPORTS_OSC=false
WARP_ID=""

if [[ -n "${WARP_SESSION_ID:-}" || "${TERM_PROGRAM:-}" == "WarpTerminal" ]]; then
  TERMINAL="warp"
  NOTIFICATION_METHOD="warp-deeplink"
  SUPPORTS_OSC=true
  WARP_ID="$WARP_SESSION_ID"
elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
  TERMINAL="iterm"
  NOTIFICATION_METHOD="osc9"
  SUPPORTS_OSC=true
elif [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
  TERMINAL="vscode"
  NOTIFICATION_METHOD="terminal-notifier"
  SUPPORTS_OSC=false
elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then
  TERMINAL="terminal"
  NOTIFICATION_METHOD="terminal-notifier"
  SUPPORTS_OSC=false
elif [[ "${TERM_PROGRAM:-}" == "WezTerm" ]]; then
  TERMINAL="wezterm"
  NOTIFICATION_METHOD="terminal-notifier"
  SUPPORTS_OSC=true
elif [[ "${TERM_PROGRAM:-}" == "Alacritty" ]]; then
  TERMINAL="alacritty"
  NOTIFICATION_METHOD="terminal-notifier"
  SUPPORTS_OSC=false
elif [[ "${TERM_PROGRAM:-}" == "kitty" ]]; then
  TERMINAL="kitty"
  NOTIFICATION_METHOD="terminal-notifier"
  SUPPORTS_OSC=true
elif [[ -n "${TMUX:-}" ]]; then
  TERMINAL="tmux"
  NOTIFICATION_METHOD="terminal-notifier"
  SUPPORTS_OSC=false
fi

# --- Output JSON ---
# Use jq if available for proper escaping; fall back to printf
if command -v jq &>/dev/null; then
  jq -n \
    --arg terminal "$TERMINAL" \
    --arg notification_method "$NOTIFICATION_METHOD" \
    --argjson supports_osc "$SUPPORTS_OSC" \
    --arg warp_session_id "$WARP_ID" \
    '{
      terminal: $terminal,
      notification_method: $notification_method,
      supports_osc: $supports_osc,
      warp_session_id: $warp_session_id
    }'
else
  # Fallback: manual JSON (all values are safe ASCII, no escaping needed)
  printf '{\n'
  printf '  "terminal": "%s",\n' "$TERMINAL"
  printf '  "notification_method": "%s",\n' "$NOTIFICATION_METHOD"
  printf '  "supports_osc": %s,\n' "$SUPPORTS_OSC"
  printf '  "warp_session_id": "%s"\n' "$WARP_ID"
  printf '}\n'
fi
