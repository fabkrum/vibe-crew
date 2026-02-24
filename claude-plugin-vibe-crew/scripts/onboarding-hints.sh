#!/usr/bin/env bash
# scripts/onboarding-hints.sh
# Reads state.json, outputs contextual command hints based on project phase.
# Max 1 hint per session. Respects dismissed hints in config.json.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"

# --- Check if hints are enabled ---
if [[ -f "$CONFIG_FILE" ]]; then
  HINTS_ENABLED=$(jq -r '.onboarding.show_hints // true' "$CONFIG_FILE" 2>/dev/null || echo "true")
  if [[ "$HINTS_ENABLED" == "false" ]]; then
    exit 0
  fi
fi

# --- Load dismissed hints ---
DISMISSED=""
if [[ -f "$CONFIG_FILE" ]]; then
  DISMISSED=$(jq -r '.onboarding.dismissed_hints // [] | join(",")' "$CONFIG_FILE" 2>/dev/null || echo "")
fi

is_dismissed() {
  local hint="$1"
  echo "$DISMISSED" | grep -q "$hint" 2>/dev/null
}

# --- Determine current state ---
HINT=""

# No .vibecrew/ directory at all
if [[ ! -d "$PROJECT_ROOT/.vibecrew" ]]; then
  if ! is_dismissed "setup"; then
    HINT="Tip: Run /setup to initialize VibeCrew for this project."
  fi
  echo "$HINT"
  exit 0
fi

# No state file
if [[ ! -f "$STATE_FILE" ]]; then
  if ! is_dismissed "setup"; then
    HINT="Tip: Run /setup to initialize VibeCrew state."
  fi
  echo "$HINT"
  exit 0
fi

# Profile not completed (check before foundation, after state exists)
PROFILE_DONE="true"
if [[ -f "$CONFIG_FILE" ]]; then
  PROFILE_DONE=$(jq -r '.user_profile.interview_completed // false' "$CONFIG_FILE" 2>/dev/null || echo "false")
fi

if [[ "$PROFILE_DONE" == "false" ]]; then
  if ! is_dismissed "profile"; then
    HINT="Tip: Run /profile to personalize VibeCrew to your workflow."
    echo "$HINT"
    exit 0
  fi
fi

# Foundation not complete
FOUNDATION=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
if [[ "$FOUNDATION" == "false" ]]; then
  # Check if this is an existing project that could use /onboard
  if [[ -f "$PROJECT_ROOT/package.json" ]]; then
    if ! is_dismissed "onboard"; then
      HINT="Tip: Existing project detected. Run /onboard to skip foundation setup, or /new-project for a fresh start."
    fi
  else
    if ! is_dismissed "new-project"; then
      HINT="Tip: Run /new-project to create your project foundation (VISION.md, design system, tech stack)."
    fi
  fi
  echo "$HINT"
  exit 0
fi

# Foundation complete, no backlog
BACKLOG_COUNT=0
if [[ -f "$BACKLOG_FILE" ]]; then
  BACKLOG_COUNT=$(jq '.features | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
fi

if [[ "$BACKLOG_COUNT" -eq 0 ]]; then
  if ! is_dismissed "plan-features"; then
    HINT="Tip: Foundation complete! Run /plan-features to define your feature backlog."
  fi
  echo "$HINT"
  exit 0
fi

# Has backlog, no active feature
ACTIVE_FEATURE=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
if [[ -z "$ACTIVE_FEATURE" ]]; then
  READY_COUNT=$(jq '[.features[] | select(.column == "ready")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  if [[ "$READY_COUNT" -gt 0 ]]; then
    if ! is_dismissed "new-feature"; then
      HINT="Tip: $READY_COUNT features ready. Run /new-feature \"name\" or /run-backlog to start building."
    fi
  else
    if ! is_dismissed "plan-features-refine"; then
      HINT="Tip: No features ready. Run /plan-features to refine and prioritize your backlog."
    fi
  fi
  echo "$HINT"
  exit 0
fi

# Active feature with all phases done
PHASES_DONE=$(jq -r '.active_feature.phases_completed | length' "$STATE_FILE" 2>/dev/null || echo "0")
if [[ "$PHASES_DONE" -ge 5 ]]; then
  if ! is_dismissed "wrap"; then
    HINT="Tip: All phases complete! Run /wrap to finalize this session and calculate your Vibe Score."
  fi
  echo "$HINT"
  exit 0
fi

# Default: no hint
echo ""
exit 0
