#!/usr/bin/env bash
# scripts/register-agent.sh
# Registers the active agent for observability tracking.
# Usage: register-agent.sh <agent-name>
# Reads session_id, feature_id, phase from state.json automatically.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/agent-identity.sh"

AGENT_NAME="${1:?Usage: register-agent.sh <agent-name>}"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"

SESSION_ID="unknown"
FEATURE_ID=""
PHASE=""

if [[ -f "$STATE_FILE" ]]; then
  SESSION_ID=$(jq -r '.active_feature.session_id // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  FEATURE_ID=$(jq -r '.active_feature.id // ""' "$STATE_FILE" 2>/dev/null || echo "")
  PHASE=$(jq -r '.active_feature.phase // ""' "$STATE_FILE" 2>/dev/null || echo "")
fi

register_agent "$AGENT_NAME" "$SESSION_ID" "$FEATURE_ID" "$PHASE"
echo "Registered agent: $AGENT_NAME"
