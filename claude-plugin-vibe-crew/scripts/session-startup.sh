#!/usr/bin/env bash
# scripts/session-startup.sh
# SessionStart hook: environment check, state detection, routing
# Runs on every new session start
# Exit 0 always (never block session startup)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

# --- Environment check ---
MISSING_DEPS=()

command -v git &>/dev/null || MISSING_DEPS+=("git")
command -v jq &>/dev/null || MISSING_DEPS+=("jq")
command -v node &>/dev/null || MISSING_DEPS+=("node")
command -v gh &>/dev/null || MISSING_DEPS+=("gh")

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  echo "VibeCrew: Missing dependencies: ${MISSING_DEPS[*]}"
  echo "  Run /setup to install required tools."
  exit 0
fi

# --- Check if VibeCrew is initialized ---
if [[ ! -d "$PROJECT_ROOT/.vibecrew" ]]; then
  echo "VibeCrew: Not initialized in this project."
  echo "  Run /setup to get started."
  exit 0
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "VibeCrew: State file missing. Run /setup to reinitialize."
  exit 0
fi

# --- Run state migrations ---
if [[ -f "$SCRIPT_DIR/migrate-state.sh" ]]; then
  bash "$SCRIPT_DIR/migrate-state.sh" 2>/dev/null || true
fi

# --- Read state and route ---
FOUNDATION=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
ACTIVE_FEATURE=$(jq -r '.active_feature.name // empty' "$STATE_FILE" 2>/dev/null || echo "")
ACTIVE_PHASE=$(jq -r '.active_feature.phase // empty' "$STATE_FILE" 2>/dev/null || echo "")
UPDATED_AT=$(jq -r '.updated_at // empty' "$STATE_FILE" 2>/dev/null || echo "")

# Count backlog features
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"
TOTAL_FEATURES=0
READY_FEATURES=0
DONE_FEATURES=0
if [[ -f "$BACKLOG_FILE" ]]; then
  TOTAL_FEATURES=$(jq '.features | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  READY_FEATURES=$(jq '[.features[] | select(.column == "planned")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  DONE_FEATURES=$(jq '[.features[] | select(.column == "done")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
fi

# --- Check for handoff from previous session ---
HANDOFF_FILE=""
HANDOFF_DIR="$PROJECT_ROOT/.vibecrew/handoffs"
if [[ -d "$HANDOFF_DIR" ]]; then
  HANDOFF_FILE=$(ls -1t "$HANDOFF_DIR"/handoff-*.md 2>/dev/null | head -1)
fi

# --- Read gamification state ---
GAMIFICATION_FILE="$PROJECT_ROOT/.vibecrew/gamification.json"
GAMIFICATION_LINE=""
if [[ -f "$GAMIFICATION_FILE" ]]; then
  GAM_ENABLED=$(jq -r '.gamification.enabled // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
  if [[ "$GAM_ENABLED" != "false" ]]; then
    GAM_LEVEL=$(jq -r '.level // 1' "$GAMIFICATION_FILE" 2>/dev/null || echo "1")
    GAM_STREAK=$(jq -r '.streak.current // 0' "$GAMIFICATION_FILE" 2>/dev/null || echo "0")
    GAM_CHALLENGE=$(jq -r '.active_challenges[0].name // "none"' "$GAMIFICATION_FILE" 2>/dev/null || echo "none")
    GAMIFICATION_LINE="Level $GAM_LEVEL | Streak: ${GAM_STREAK} days | Challenge: $GAM_CHALLENGE"
  fi
fi

# --- Output status summary (3 lines max, under 200 words) ---
echo "---"
if [[ "$FOUNDATION" == "false" ]]; then
  # Count completed artifacts
  COMPLETED=$(jq '[.foundation.artifacts | to_entries[] | select(.value.status == "complete")] | length' "$STATE_FILE" 2>/dev/null || echo "0")
  echo "VibeCrew | Foundation: $COMPLETED/6 artifacts complete"
  echo "  Run /new-project to continue building the foundation."
elif [[ -n "$ACTIVE_FEATURE" ]]; then
  echo "VibeCrew | Feature: $ACTIVE_FEATURE | Phase: ${ACTIVE_PHASE:-unknown}"
  echo "  Backlog: $TOTAL_FEATURES total, $READY_FEATURES ready, $DONE_FEATURES done"
else
  echo "VibeCrew | Foundation: Complete | No active feature"
  echo "  Backlog: $TOTAL_FEATURES total, $READY_FEATURES ready, $DONE_FEATURES done"
  if [[ "$READY_FEATURES" -gt 0 ]]; then
    echo "  Run /new-feature or /run-backlog to start building."
  elif [[ "$TOTAL_FEATURES" -eq 0 ]]; then
    echo "  Run /plan-features or /idea to add features to the backlog."
  fi
fi
# Third line: gamification summary
if [[ -n "$GAMIFICATION_LINE" ]]; then
  echo "  $GAMIFICATION_LINE"
fi

# --- Show handoff summary if available ---
if [[ -n "$HANDOFF_FILE" && -f "$HANDOFF_FILE" ]]; then
  echo "---"
  echo "Previous session handoff available: $(basename "$HANDOFF_FILE")"
  # Extract first next step
  NEXT_STEP=$(grep -A1 "^## Next Steps" "$HANDOFF_FILE" 2>/dev/null | tail -1 | sed 's/^[0-9]*\. //' || echo "")
  if [[ -n "$NEXT_STEP" ]]; then
    echo "  Next: $NEXT_STEP"
  fi
fi

echo "---"

exit 0
