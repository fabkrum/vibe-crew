#!/usr/bin/env bash
# scripts/validate-skill-schema.sh
# PostToolUse hook: validates SKILL.md frontmatter schema on write/edit
# Exit 0 = pass (with optional warnings to stderr)
# Exit 2 = block (critical schema violation)

set -euo pipefail

# Only validate SKILL.md files
FILE_PATH="${TOOL_INPUT_FILE_PATH:-${1:-}}"
if [[ -z "$FILE_PATH" || ! "$FILE_PATH" =~ SKILL\.md$ ]]; then
  exit 0
fi

if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

ERRORS=()
WARNINGS=()

# Extract YAML frontmatter (between --- markers)
FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$FILE_PATH" | sed '1d;$d')

if [[ -z "$FRONTMATTER" ]]; then
  echo "BLOCK: SKILL.md has no YAML frontmatter" >&2
  exit 2
fi

# Check required fields
if ! echo "$FRONTMATTER" | grep -q '^name:'; then
  ERRORS+=("Missing required field: name")
fi

if ! echo "$FRONTMATTER" | grep -q '^description:'; then
  ERRORS+=("Missing required field: description")
fi

# Check recommended fields
if ! echo "$FRONTMATTER" | grep -q '^category:'; then
  WARNINGS+=("Missing recommended field: category")
fi

# If skill body contains $ARGUMENTS or $0, check for argument-hint
BODY=$(sed -n '/^---$/,/^---$/!p' "$FILE_PATH" | tail -n +1)
if echo "$BODY" | grep -qE '\$ARGUMENTS|\$0'; then
  if ! echo "$FRONTMATTER" | grep -q '^argument-hint:'; then
    WARNINGS+=("Skill uses \$ARGUMENTS/\$0 but has no argument-hint")
  fi
fi

# If context: fork is set, validate agent: is also set
if echo "$FRONTMATTER" | grep -q '^context:.*fork'; then
  if ! echo "$FRONTMATTER" | grep -q '^agent:'; then
    ERRORS+=("context: fork requires agent: field")
  fi
fi

# Validate category value if present
CATEGORY=$(echo "$FRONTMATTER" | grep '^category:' | sed 's/^category:\s*//' | tr -d ' "'"'"'')
if [[ -n "$CATEGORY" ]]; then
  case "$CATEGORY" in
    workflow|analysis|action|dashboard|utility) ;;
    *) ERRORS+=("Invalid category: '$CATEGORY'. Must be one of: workflow, analysis, action, dashboard, utility") ;;
  esac
fi

# Output warnings to stderr (non-blocking)
for w in "${WARNINGS[@]:-}"; do
  [[ -n "$w" ]] && echo "WARNING: $w" >&2
done

# Block on critical errors
if [[ ${#ERRORS[@]} -gt 0 ]]; then
  for e in "${ERRORS[@]}"; do
    echo "BLOCK: $e" >&2
  done
  exit 2
fi

exit 0
