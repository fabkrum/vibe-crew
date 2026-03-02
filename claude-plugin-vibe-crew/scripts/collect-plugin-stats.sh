#!/usr/bin/env bash
# scripts/collect-plugin-stats.sh
# Counts agents, skills, scripts, hooks, and MCP servers in the VibeCrew plugin.
# Outputs a JSON summary to stdout.
# Exit 0 on success, Exit 1 on failure.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# --- Count agents ---
AGENT_COUNT=0
if [[ -d "$PLUGIN_ROOT/agents" ]]; then
  AGENT_COUNT=$(find "$PLUGIN_ROOT/agents" -name "*.md" -type f | wc -l | tr -d ' ')
fi

# --- Count skills ---
SKILL_COUNT=0
if [[ -d "$PLUGIN_ROOT/skills" ]]; then
  SKILL_COUNT=$(find "$PLUGIN_ROOT/skills" -name "SKILL.md" -type f | wc -l | tr -d ' ')
fi

# --- Count scripts ---
SCRIPT_COUNT=0
if [[ -d "$PLUGIN_ROOT/scripts" ]]; then
  SCRIPT_COUNT=$(find "$PLUGIN_ROOT/scripts" -name "*.sh" -type f | wc -l | tr -d ' ')
fi

# --- Count hooks ---
HOOK_COUNT=0
if [[ -f "$PLUGIN_ROOT/hooks/hooks.json" ]]; then
  HOOK_COUNT=$(jq '[.[] | length] | add // 0' "$PLUGIN_ROOT/hooks/hooks.json" 2>/dev/null || echo 0)
fi

# --- Count MCP servers (from .mcp.json) ---
MCP_COUNT=0
if [[ -f "$PLUGIN_ROOT/.mcp.json" ]]; then
  MCP_COUNT=$(jq '.mcpServers | length // 0' "$PLUGIN_ROOT/.mcp.json" 2>/dev/null || echo 0)
  MCP_COUNT=${MCP_COUNT:-0}
fi

# --- Count MCP registry entries ---
MCP_REGISTRY_COUNT=0
if [[ -f "$PLUGIN_ROOT/templates/mcp-registry.json" ]]; then
  MCP_REGISTRY_COUNT=$(jq '.servers | length // 0' "$PLUGIN_ROOT/templates/mcp-registry.json" 2>/dev/null || echo 0)
fi

# --- Count templates ---
TEMPLATE_COUNT=0
if [[ -d "$PLUGIN_ROOT/templates" ]]; then
  TEMPLATE_COUNT=$(find "$PLUGIN_ROOT/templates" -type f | wc -l | tr -d ' ')
fi

# --- Read plugin version ---
PLUGIN_VERSION="unknown"
if [[ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]]; then
  PLUGIN_VERSION=$(jq -r '.version // "unknown"' "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || echo "unknown")
fi

# --- Count registered projects ---
PROJECT_COUNT=0
if [[ -f "$PLUGIN_ROOT/project-registry.json" ]]; then
  PROJECT_COUNT=$(jq '.projects | length // 0' "$PLUGIN_ROOT/project-registry.json" 2>/dev/null || echo 0)
fi

# --- Count review reports ---
REVIEW_COUNT=0
if [[ -d "$PLUGIN_ROOT/reviews" ]]; then
  REVIEW_COUNT=$(find "$PLUGIN_ROOT/reviews" -name "system-review-*.json" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# --- Output JSON ---
cat <<EOF
{
  "plugin_version": "$PLUGIN_VERSION",
  "agents": $AGENT_COUNT,
  "skills": $SKILL_COUNT,
  "scripts": $SCRIPT_COUNT,
  "hooks": $HOOK_COUNT,
  "mcp_servers_bundled": $MCP_COUNT,
  "mcp_servers_registry": $MCP_REGISTRY_COUNT,
  "templates": $TEMPLATE_COUNT,
  "registered_projects": $PROJECT_COUNT,
  "previous_reviews": $REVIEW_COUNT
}
EOF

exit 0
