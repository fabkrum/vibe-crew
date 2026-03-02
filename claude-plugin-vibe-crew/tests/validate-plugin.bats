#!/usr/bin/env bats
# tests/validate-plugin.bats
# Tests for scripts/validate-plugin.sh — comprehensive plugin self-test

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Create a temp plugin root with valid minimal structure
  FAKE_PLUGIN_ROOT="$(mktemp -d)"
  FAKE_PLUGIN_ROOT="$(cd "$FAKE_PLUGIN_ROOT" && pwd -P)"
  export CLAUDE_PLUGIN_ROOT="$FAKE_PLUGIN_ROOT"
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
  if [[ -n "${FAKE_PLUGIN_ROOT:-}" && -d "$FAKE_PLUGIN_ROOT" ]]; then
    rm -rf "$FAKE_PLUGIN_ROOT"
  fi
  unset CLAUDE_PLUGIN_ROOT
}

# Helper: create a minimal valid plugin structure
_create_valid_plugin() {
  local root="$FAKE_PLUGIN_ROOT"

  # Required files
  mkdir -p "$root/.claude-plugin"
  echo '{"name":"test-plugin","version":"1.0.0"}' > "$root/.claude-plugin/plugin.json"

  mkdir -p "$root/hooks"
  echo '{"hooks":{}}' > "$root/hooks/hooks.json"

  echo '{"permissions":{}}' > "$root/settings.json"
  echo '{"mcpServers":{}}' > "$root/.mcp.json"
  echo 'MIT License' > "$root/LICENSE"

  # Scripts directory with a valid script
  mkdir -p "$root/scripts"
  cat > "$root/scripts/example.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "hello"
SCRIPT
  chmod +x "$root/scripts/example.sh"

  # Agents directory with valid frontmatter
  mkdir -p "$root/agents"
  cat > "$root/agents/test-agent.md" <<'AGENT'
---
name: test-agent
model: opus
---
# Test Agent
AGENT

  # Skills directory with valid frontmatter
  mkdir -p "$root/skills/test-skill"
  cat > "$root/skills/test-skill/SKILL.md" <<'SKILL'
---
name: test-skill
---
# Test Skill
SKILL
}

@test "passes on valid plugin structure" {
  _create_valid_plugin

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_success
}

@test "fails on missing required file" {
  _create_valid_plugin
  # Remove LICENSE (a required file)
  rm "$FAKE_PLUGIN_ROOT/LICENSE"

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_failure
  [[ "$output" == *"File missing: LICENSE"* ]]
}

@test "fails on invalid JSON file" {
  _create_valid_plugin
  # Write invalid JSON to plugin.json
  echo 'NOT VALID JSON {{{' > "$FAKE_PLUGIN_ROOT/.claude-plugin/plugin.json"

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_failure
  [[ "$output" == *"Invalid JSON"* ]]
}

@test "detects non-executable scripts" {
  _create_valid_plugin
  # Create a script without execute permission
  cat > "$FAKE_PLUGIN_ROOT/scripts/broken.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "no exec"
SCRIPT
  chmod -x "$FAKE_PLUGIN_ROOT/scripts/broken.sh"

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_failure
  [[ "$output" == *"Not executable"* ]]
}

@test "detects bad bash syntax" {
  _create_valid_plugin
  # Create a script with syntax errors
  cat > "$FAKE_PLUGIN_ROOT/scripts/bad-syntax.sh" <<'SCRIPT'
#!/usr/bin/env bash
if [[ true ]]; then
  echo "missing fi"
SCRIPT
  chmod +x "$FAKE_PLUGIN_ROOT/scripts/bad-syntax.sh"

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_failure
  [[ "$output" == *"Bash syntax error"* ]]
}

@test "detects missing agent frontmatter" {
  _create_valid_plugin
  # Overwrite agent without frontmatter
  cat > "$FAKE_PLUGIN_ROOT/agents/test-agent.md" <<'AGENT'
# No Frontmatter Agent
This agent has no --- at the start.
AGENT

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_failure
  [[ "$output" == *"Agent missing frontmatter"* ]]
}

@test "reports pass count and fail count" {
  _create_valid_plugin

  run bash "$SCRIPTS_DIR/validate-plugin.sh"
  assert_success
  [[ "$output" == *"Summary:"* ]]
}
