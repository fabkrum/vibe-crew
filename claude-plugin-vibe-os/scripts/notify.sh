#!/usr/bin/env bash
# scripts/notify.sh
# Terminal-adaptive notification system for VibeOS
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
NOTIFICATIONS_ENABLED=$(jq -r '.notifications.enabled // true' "$PROJECT_ROOT/.vibeos/config.json" 2>/dev/null || echo "true")
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
  TITLE="VibeOS: Error"
  BODY="A critical tool execution failed. Human intervention required."
  SOUND="Basso"
else
  case "$TYPE" in
    "permission_prompt")
      TITLE="VibeOS: Approval Needed"
      BODY="Agent blocked. Needs your Y/N approval to proceed."
      SOUND="Submarine"
      ;;
    "idle_prompt")
      TITLE="VibeOS: Task Complete"
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
        -group "vibeos-${WARP_SESSION_ID}" \
        -execute "open '$DEEP_LINK'" 2>/dev/null && notify_sent=true || true
      ;;
    "iterm2")
      # iTerm2 OSC 9 for tab badge + terminal-notifier for OS notification
      printf '\e]9;%s\a' "$BODY" 2>/dev/null || true
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-iterm" 2>/dev/null && notify_sent=true || true
      ;;
    *)
      terminal-notifier \
        -title "$TITLE" \
        -message "$BODY" \
        -sound "$SOUND" \
        -group "vibeos-generic" 2>/dev/null && notify_sent=true || true
      ;;
  esac
fi

# Priority 3: osascript
if [[ "$notify_sent" == "false" ]] && command -v osascript &> /dev/null; then
  osascript -e "display notification \"$BODY\" with title \"$TITLE\" sound name \"$SOUND\"" 2>/dev/null && notify_sent=true || true
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
LOG_DIR="$PROJECT_ROOT/.vibeos"
if [[ -d "$LOG_DIR" ]]; then
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  echo "{\"timestamp\":\"$TIMESTAMP\",\"title\":\"$TITLE\",\"body\":\"$BODY\",\"terminal\":\"$TERMINAL\"}" >> "$LOG_DIR/notifications.log" 2>/dev/null || true
fi

exit 0
