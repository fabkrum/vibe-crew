#!/usr/bin/env bash
# scripts/validate-plugin.sh
# Comprehensive plugin self-test for VibeOS.
# Validates file structure, JSON validity, script permissions, hook references,
# agent definitions, skill definitions, and bash syntax.
# Exit 0 if all checks pass, Exit 1 if any check fails.
# This is the ONE script that can exit non-zero -- it is a self-test, not a hook.

set -euo pipefail

# =============================================================================
# Determine PLUGIN_ROOT
# =============================================================================

if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
  PLUGIN_ROOT="$CLAUDE_PLUGIN_ROOT"
else
  PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

# =============================================================================
# Tracking
# =============================================================================

PASS_COUNT=0
FAIL_COUNT=0
RESULTS=()

pass() {
  local description="$1"
  ((PASS_COUNT++))
  RESULTS+=("[PASS] $description")
}

fail() {
  local description="$1"
  ((FAIL_COUNT++))
  RESULTS+=("[FAIL] $description")
}

# =============================================================================
# Check 1: Required files exist
# =============================================================================

REQUIRED_FILES=(
  ".claude-plugin/plugin.json"
  "hooks/hooks.json"
  "settings.json"
  ".mcp.json"
  "LICENSE"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ -f "$PLUGIN_ROOT/$file" ]]; then
    pass "File exists: $file"
  else
    fail "File missing: $file"
  fi
done

# =============================================================================
# Check 2: Scripts are executable
# =============================================================================

for script in "$PLUGIN_ROOT"/scripts/*.sh; do
  # Skip if glob did not match
  [[ -f "$script" ]] || continue

  local_name="scripts/$(basename "$script")"
  if [[ -x "$script" ]]; then
    pass "Executable: $local_name"
  else
    fail "Not executable: $local_name"
  fi
done

# =============================================================================
# Check 3: JSON validity
# =============================================================================

JSON_FILES=(
  ".claude-plugin/plugin.json"
  "hooks/hooks.json"
  "settings.json"
  ".mcp.json"
)

for json_file in "${JSON_FILES[@]}"; do
  local_path="$PLUGIN_ROOT/$json_file"
  if [[ ! -f "$local_path" ]]; then
    # Already reported in Check 1, skip JSON validation
    continue
  fi
  if jq empty "$local_path" 2>/dev/null; then
    pass "Valid JSON: $json_file"
  else
    fail "Invalid JSON: $json_file"
  fi
done

# Check template JSON files
for template_file in "$PLUGIN_ROOT"/templates/*.json.template; do
  [[ -f "$template_file" ]] || continue

  local_name="templates/$(basename "$template_file")"
  if jq empty "$template_file" 2>/dev/null; then
    pass "Valid JSON: $local_name"
  else
    fail "Invalid JSON: $local_name"
  fi
done

# =============================================================================
# Check 4: hooks.json script references
# Parse hooks.json, extract all command fields, verify scripts exist and are
# executable. Resolves ${CLAUDE_PLUGIN_ROOT} to PLUGIN_ROOT.
# =============================================================================

HOOKS_FILE="$PLUGIN_ROOT/hooks/hooks.json"

if [[ -f "$HOOKS_FILE" ]] && jq empty "$HOOKS_FILE" 2>/dev/null; then
  # Extract all command fields from the nested hook structure
  # hooks.json has: .hooks.<event>[].hooks[].command
  COMMANDS=$(jq -r '
    .hooks // {} |
    to_entries[] |
    .value[] |
    .hooks // [] |
    .[] |
    .command // empty
  ' "$HOOKS_FILE" 2>/dev/null || true)

  if [[ -n "$COMMANDS" ]]; then
    while IFS= read -r cmd; do
      [[ -z "$cmd" ]] && continue

      # Extract the script path (first token, before any arguments)
      script_path=$(echo "$cmd" | awk '{print $1}')

      # Resolve ${CLAUDE_PLUGIN_ROOT} placeholder
      resolved_path="${script_path//\$\{CLAUDE_PLUGIN_ROOT\}/$PLUGIN_ROOT}"

      local_display="${script_path//\$\{CLAUDE_PLUGIN_ROOT\}\//}"

      if [[ -f "$resolved_path" ]]; then
        if [[ -x "$resolved_path" ]]; then
          pass "Hook script exists and executable: $local_display"
        else
          fail "Hook script not executable: $local_display"
        fi
      else
        fail "Hook script missing: $local_display"
      fi
    done <<< "$COMMANDS"
  fi
fi

# =============================================================================
# Check 5: Agent definitions
# Each .md file in agents/ should start with --- (YAML frontmatter)
# =============================================================================

for agent_file in "$PLUGIN_ROOT"/agents/*.md; do
  [[ -f "$agent_file" ]] || continue

  local_name="agents/$(basename "$agent_file")"
  first_line=$(head -1 "$agent_file" 2>/dev/null || echo "")

  if [[ "$first_line" == "---" ]]; then
    pass "Agent frontmatter: $local_name"
  else
    fail "Agent missing frontmatter: $local_name"
  fi
done

# =============================================================================
# Check 6: Skill definitions
# Each skills/*/SKILL.md should start with --- (YAML frontmatter)
# =============================================================================

for skill_file in "$PLUGIN_ROOT"/skills/*/SKILL.md; do
  [[ -f "$skill_file" ]] || continue

  # Extract skill name from path: skills/<name>/SKILL.md
  skill_dir=$(dirname "$skill_file")
  skill_name=$(basename "$skill_dir")
  local_name="skills/$skill_name/SKILL.md"

  first_line=$(head -1 "$skill_file" 2>/dev/null || echo "")

  if [[ "$first_line" == "---" ]]; then
    pass "Skill frontmatter: $local_name"
  else
    fail "Skill missing frontmatter: $local_name"
  fi
done

# =============================================================================
# Check 7: Bash syntax
# Run bash -n on all .sh files in scripts/
# =============================================================================

for script in "$PLUGIN_ROOT"/scripts/*.sh; do
  [[ -f "$script" ]] || continue

  local_name="scripts/$(basename "$script")"
  if bash -n "$script" 2>/dev/null; then
    pass "Bash syntax: $local_name"
  else
    fail "Bash syntax error: $local_name"
  fi
done

# =============================================================================
# Output report
# =============================================================================

echo "VibeOS Plugin Validation"
echo "========================"

for result in "${RESULTS[@]}"; do
  echo "$result"
done

TOTAL=$(( PASS_COUNT + FAIL_COUNT ))
echo ""
echo "Summary: $PASS_COUNT/$TOTAL checks passed"

# Exit 1 if any failures (this is a self-test, not a hook)
if [[ "$FAIL_COUNT" -gt 0 ]]; then
  exit 1
fi

exit 0
