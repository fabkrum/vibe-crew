#!/usr/bin/env bash
# scripts/detect-companion-skill.sh
# Lightweight single-skill installed check for agents to call inline.
# Usage:   detect-companion-skill.sh <skill-name>
# Exit 0 if installed, Exit 1 if not.
# Output:  JSON { "skill": "<name>", "installed": true/false }

set -euo pipefail

SKILL_NAME="${1:-}"

if [[ -z "$SKILL_NAME" ]]; then
  echo "Usage: detect-companion-skill.sh <skill-name>" >&2
  exit 1
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

INSTALLED=false

# Check global skills directory
if [[ -d "$HOME/.claude/skills/$SKILL_NAME" ]]; then
  INSTALLED=true
fi

# Check project-level skills directory
if [[ -d "$PROJECT_ROOT/.claude/skills/$SKILL_NAME" ]]; then
  INSTALLED=true
fi

jq -n --arg skill "$SKILL_NAME" --argjson installed "$INSTALLED" \
  '{ skill: $skill, installed: $installed }'

if [[ "$INSTALLED" == "true" ]]; then
  exit 0
else
  exit 1
fi
