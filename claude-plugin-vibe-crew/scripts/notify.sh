#!/usr/bin/env bash
# scripts/notify.sh
# Terminal-adaptive notification system for VibeCrew
# Fires on: permission_prompt, idle_prompt, PostToolUseFailure
# Silent on: everything else (preserves Deep Work)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Ensure jq is available
if ! command -v jq &> /dev/null; then
  printf '\a'  # Terminal bell as absolute fallback
  exit 0  # Never block the agent due to notification failure
fi

# Check if notifications are enabled in config
NOTIFICATIONS_ENABLED=$(jq -r '.notifications.enabled // true' "$PROJECT_ROOT/.vibecrew/config.json" 2>/dev/null || echo "true")
if [[ "$NOTIFICATIONS_ENABLED" == "false" ]]; then
  exit 0
fi

# Read JSON payload from stdin
INPUT=$(cat)
TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Attention required."')

# Check if called with "error" argument (PostToolUseFailure)
IS_ERROR=false
if [[ "${1:-}" == "error" ]]; then
  IS_ERROR=true
fi

# --- Determine notification content ---
if [[ "$IS_ERROR" == "true" ]]; then
  TITLE="VibeCrew: Error"
  BODY="A critical tool execution failed. Human intervention required."
  SOUND="Basso"
else
  case "$TYPE" in
    "permission_prompt")
      TITLE="VibeCrew: Approval Needed"
      BODY="Agent blocked. Needs your Y/N approval to proceed."
      SOUND="Submarine"
      ;;
    "idle_prompt")
      TITLE="VibeCrew: Task Complete"
      BODY="Agent finished its task. Awaiting new instructions."
      SOUND="Glass"
      ;;
    *)
      # Non-critical event -- exit silently to preserve Deep Work
      exit 0
      ;;
  esac
fi

# --- Detect terminal ---
detect_terminal() {
  if [[ -n "${WARP_SESSION_ID:-}" ]]; then echo "warp"
  elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then echo "iterm2"
  elif [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then echo "vscode"
  elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then echo "terminal_app"
  else echo "generic"
  fi
}

TERMINAL=$(detect_terminal)

# --- Dispatch notification via fallback chain ---

notify_sent=false

# Priority 1-2: terminal-notifier (with or without Warp deep-link)
if command -v terminal-notifier &> /dev/null; then
  case "$TERMINAL" in
    "warp")
      DEEP_LINK="warp://session/${WARP_SESSION_ID}"
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibecrew-${WARP_SESSION_ID}" \
        -execute "open '$DEEP_LINK'" 2>/dev/null && notify_sent=true || true
      ;;
    "iterm2")
      # iTerm2 OSC 9 for tab badge + terminal-notifier for OS notification
      printf '\e]9;%s\a' "$BODY" 2>/dev/null || true
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibecrew-iterm" 2>/dev/null && notify_sent=true || true
      ;;
    *)
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibecrew-generic" 2>/dev/null && notify_sent=true || true
      ;;
  esac
fi

# Priority 3: osascript
if [[ "$notify_sent" == "false" ]] && command -v osascript &> /dev/null; then
  osascript \
    -e 'on run {notifBody, notifTitle, notifSound}' \
    -e '  display notification notifBody with title notifTitle sound name notifSound' \
    -e 'end run' \
    -- "$BODY" "$TITLE" "$SOUND" 2>/dev/null && notify_sent=true || true
fi

# Priority 4: OSC 777 escape sequence
if [[ "$notify_sent" == "false" ]]; then
  printf '\e]777;notify;%s;%s\a' "$TITLE" "$BODY" 2>/dev/null || true
fi

# Priority 5: Terminal bell
if [[ "$notify_sent" == "false" ]]; then
  printf '\a' 2>/dev/null || true
fi

# Priority 6: Silent log (always write, regardless of other methods)
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
if [[ -d "$VIBECREW_DIR" ]]; then
  # ── Log rotation ──
  NOTIFICATION_LOG="$VIBECREW_DIR/notifications.log"
  if [[ -f "$NOTIFICATION_LOG" ]]; then
    # Check file size (cross-platform)
    LOG_SIZE=0
    if stat -f "%z" "$NOTIFICATION_LOG" &>/dev/null; then
      LOG_SIZE=$(stat -f "%z" "$NOTIFICATION_LOG" 2>/dev/null || echo "0")
    else
      LOG_SIZE=$(stat -c "%s" "$NOTIFICATION_LOG" 2>/dev/null || echo "0")
    fi

    # Rotate if >1MB (1048576 bytes)
    if [[ "$LOG_SIZE" -gt 1048576 ]]; then
      mv "$NOTIFICATION_LOG" "${NOTIFICATION_LOG}.1"
    fi

    # Delete old rotated logs (>7 days)
    find "$(dirname "$NOTIFICATION_LOG")" -name "notifications.log.*" -mtime +7 -delete 2>/dev/null || true
  fi

  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  echo "{\"timestamp\":\"$TIMESTAMP\",\"title\":\"$TITLE\",\"body\":\"$BODY\",\"terminal\":\"$TERMINAL\"}" >> "$VIBECREW_DIR/notifications.log" 2>/dev/null || true
fi

exit 0
