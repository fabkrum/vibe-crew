#!/usr/bin/env bash
# scripts/lib/agent-identity.sh
# Agent identity management for observability.
# Usage:
#   source "$(dirname "$0")/lib/agent-identity.sh"
#   register_agent <name> [session_id] [feature_id] [phase]
#   deregister_agent
#   read_active_agent  # prints agent name or "unknown"
#
# Identity file: .vibecrew/locks/active-agent.json
# Atomic writes via tmp+mv to prevent partial reads.

_AGENT_ID_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$_AGENT_ID_SCRIPT_DIR/compat.sh"

_resolve_vibecrew_dir() {
  local root
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  echo "$root/.vibecrew"
}

register_agent() {
  local agent_name="$1"
  local session_id="${2:-unknown}"
  local feature_id="${3:-}"
  local phase="${4:-}"
  local vibecrew_dir
  vibecrew_dir="$(_resolve_vibecrew_dir)"
  local identity_file="$vibecrew_dir/locks/active-agent.json"
  local tmp="${identity_file}.tmp.$$"

  mkdir -p "$vibecrew_dir/locks"

  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  jq -n -c \
    --arg agent "$agent_name" \
    --arg started_at "$ts" \
    --argjson pid "$$" \
    --arg session_id "$session_id" \
    --arg feature_id "$feature_id" \
    --arg phase "$phase" \
    '{agent:$agent,started_at:$started_at,pid:$pid,session_id:$session_id,feature_id:$feature_id,phase:$phase}' \
    > "$tmp"

  _compat_fsync "$tmp" 2>/dev/null || true
  mv "$tmp" "$identity_file"
}

deregister_agent() {
  local vibecrew_dir
  vibecrew_dir="$(_resolve_vibecrew_dir)"
  local identity_file="$vibecrew_dir/locks/active-agent.json"
  rm -f "$identity_file"
}

read_active_agent() {
  local vibecrew_dir
  vibecrew_dir="$(_resolve_vibecrew_dir)"
  local identity_file="$vibecrew_dir/locks/active-agent.json"

  if [[ -f "$identity_file" ]]; then
    local agent
    agent=$(jq -r '.agent // "unknown"' "$identity_file" 2>/dev/null)
    echo "${agent:-unknown}"
  else
    echo "unknown"
  fi
}
