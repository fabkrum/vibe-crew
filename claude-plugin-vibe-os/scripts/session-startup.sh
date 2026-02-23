#!/usr/bin/env bash
# scripts/session-startup.sh
# SessionStart hook: environment check, state detection, routing
# Runs on every new session start
# Exit 0 always (never block session startup)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibeos/state.json"
CONFIG_FILE="$PROJECT_ROOT/.vibeos/config.json"

# --- Environment check ---
MISSING_DEPS=()

command -v git &>/dev/null || MISSING_DEPS+=("git")
command -v jq &>/dev/null || MISSING_DEPS+=("jq")
command -v node &>/dev/null || MISSING_DEPS+=("node")
command -v gh &>/dev/null || MISSING_DEPS+=("gh")

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
  echo "VibeOS: Missing dependencies: ${MISSING_DEPS[*]}"
  echo "  Run /setup to install required tools."
  exit 0
fi

# --- Check if VibeOS is initialized ---
if [[ ! -d "$PROJECT_ROOT/.vibeos" ]]; then
  echo "VibeOS: Not initialized in this project."
  echo "  Run /setup to get started."
  exit 0
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "VibeOS: State file missing. Run /setup to reinitialize."
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
BACKLOG_FILE="$PROJECT_ROOT/.vibeos/backlog.json"
TOTAL_FEATURES=0
READY_FEATURES=0
DONE_FEATURES=0
if [[ -f "$BACKLOG_FILE" ]]; then
  TOTAL_FEATURES=$(jq '.features | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  READY_FEATURES=$(jq '[.features[] | select(.column == "ready")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  DONE_FEATURES=$(jq '[.features[] | select(.column == "done")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
fi

# --- Output status summary (3 lines max, under 200 words) ---
echo "---"
if [[ "$FOUNDATION" == "false" ]]; then
  # Count completed artifacts
  COMPLETED=$(jq '[.foundation.artifacts | to_entries[] | select(.value.status == "complete")] | length' "$STATE_FILE" 2>/dev/null || echo "0")
  echo "VibeOS | Foundation: $COMPLETED/5 artifacts complete"
  echo "  Run /new-project to continue building the foundation."
elif [[ -n "$ACTIVE_FEATURE" ]]; then
  echo "VibeOS | Feature: $ACTIVE_FEATURE | Phase: ${ACTIVE_PHASE:-unknown}"
  echo "  Backlog: $TOTAL_FEATURES total, $READY_FEATURES ready, $DONE_FEATURES done"
else
  echo "VibeOS | Foundation: Complete | No active feature"
  echo "  Backlog: $TOTAL_FEATURES total, $READY_FEATURES ready, $DONE_FEATURES done"
  if [[ "$READY_FEATURES" -gt 0 ]]; then
    echo "  Run /new-feature or /run-backlog to start building."
  elif [[ "$TOTAL_FEATURES" -eq 0 ]]; then
    echo "  Run /plan-features or /idea to add features to the backlog."
  fi
fi
echo "---"

exit 0
