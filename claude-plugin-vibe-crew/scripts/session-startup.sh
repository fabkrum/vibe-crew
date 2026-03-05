#!/usr/bin/env bash
# scripts/session-startup.sh
# SessionStart hook: environment check, state detection, routing
# Runs on every new session start
# Exit 0 always (never block session startup)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Source error logging
source "$SCRIPT_DIR/lib/error-log.sh"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

# --- Environment check ---
MISSING_REQUIRED=()
MISSING_OPTIONAL=()

command -v git &>/dev/null || MISSING_REQUIRED+=("git")
command -v jq &>/dev/null || MISSING_REQUIRED+=("jq")
command -v node &>/dev/null || MISSING_REQUIRED+=("node")
command -v gh &>/dev/null || MISSING_OPTIONAL+=("gh")

if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
  echo "VibeCrew: Missing required dependencies: ${MISSING_REQUIRED[*]}"
  echo "  Run /setup to install required tools."
  exit 0
fi

if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
  echo "VibeCrew: Optional tools not found: ${MISSING_OPTIONAL[*]} (PR automation unavailable)"
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

# --- Reset drift tracker for new session ---
rm -f "$PROJECT_ROOT/.vibecrew/drift-tracker.json"

# --- Run state migrations ---
if [[ -f "$SCRIPT_DIR/migrate-state.sh" ]]; then
  bash "$SCRIPT_DIR/migrate-state.sh" 2>/dev/null || log_error "session-startup" "State migration failed"
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
if [[ -f "$GAMIFICATION_FILE" && -f "$CONFIG_FILE" ]]; then
  GAM_ENABLED=$(jq -r 'if .gamification.enabled == false then "false" else "true" end' "$CONFIG_FILE" 2>/dev/null || echo "true")
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

# --- MCP health check (quick, bounded by timeout) ---
if [[ -x "$SCRIPT_DIR/check-mcp-health.sh" ]]; then
  MCP_RESULT=""
  if command -v timeout &>/dev/null; then
    MCP_RESULT=$(timeout 15 bash "$SCRIPT_DIR/check-mcp-health.sh" 2>/dev/null || echo "")
  elif command -v gtimeout &>/dev/null; then
    MCP_RESULT=$(gtimeout 15 bash "$SCRIPT_DIR/check-mcp-health.sh" 2>/dev/null || echo "")
  else
    # No timeout command — run directly (health check has internal per-server timeouts)
    MCP_RESULT=$(bash "$SCRIPT_DIR/check-mcp-health.sh" 2>/dev/null || echo "")
  fi

  if [[ -n "$MCP_RESULT" ]]; then
    MCP_FAILED=$(echo "$MCP_RESULT" | jq -r '.summary.failed // 0' 2>/dev/null || echo "0")
    if [[ "$MCP_FAILED" -gt 0 ]]; then
      MCP_NAMES=$(echo "$MCP_RESULT" | jq -r '[.servers[] | select(.status != "ok") | .server] | join(", ")' 2>/dev/null || echo "unknown")
      echo "  MCP: $MCP_FAILED server(s) unhealthy ($MCP_NAMES)"
    fi
  fi
fi

# --- Ensure dashboard is running ---
if [[ -x "$SCRIPT_DIR/ensure-dashboard.sh" ]]; then
  DASHBOARD_OUTPUT=$(bash "$SCRIPT_DIR/ensure-dashboard.sh" 2>/dev/null || true)
  if [[ -n "$DASHBOARD_OUTPUT" ]]; then
    echo "  $DASHBOARD_OUTPUT"
  fi
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

# --- Model-change detection ---
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MODEL_FILE="$PLUGIN_ROOT/.last-validated-model.txt"
CURRENT_MODEL="${CLAUDE_MODEL:-unknown}"
if [[ -f "$MODEL_FILE" && "$CURRENT_MODEL" != "unknown" ]]; then
  LAST_MODEL=$(cat "$MODEL_FILE" 2>/dev/null || echo "")
  if [[ -n "$LAST_MODEL" && "$LAST_MODEL" != "$CURRENT_MODEL" ]]; then
    echo "  Model changed ($LAST_MODEL → $CURRENT_MODEL). Run /validate-skills to check skill health."
  fi
fi

echo "---"

exit 0
