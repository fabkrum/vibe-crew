#!/usr/bin/env bats
# Tests for scripts/load-agent-with-overrides.sh

load 'test_helper/common-setup'

OVERRIDE_SCRIPT="$SCRIPTS_DIR/load-agent-with-overrides.sh"

setup() {
  setup_vibecrew_dir
  touch "$TEST_PROJECT_DIR/.gitkeep"
  git -C "$TEST_PROJECT_DIR" add .
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1

  # Create a minimal test agent file in the plugin directory
  PLUGIN_DIR="$(mktemp -d)"
  mkdir -p "$PLUGIN_DIR/agents"
  cat > "$PLUGIN_DIR/agents/test-agent.md" <<'AGENT'
---
name: test-agent
model: opus
---

# Test Agent

Intro paragraph.

## First Section

First section content.
More first section content.

## Second Section

Second section content.

## Third Section

Third section content.
AGENT

  export CLAUDE_PLUGIN_ROOT="$PLUGIN_DIR"
}

teardown() {
  teardown_vibecrew_dir
  [[ -n "${PLUGIN_DIR:-}" ]] && rm -rf "$PLUGIN_DIR"
}

# --- Basic behavior ---

@test "override: fails without agent name" {
  run bash "$OVERRIDE_SCRIPT"
  assert_failure
}

@test "override: fails for nonexistent agent" {
  run bash "$OVERRIDE_SCRIPT" "nonexistent-agent"
  assert_failure
}

@test "override: outputs base agent when no override exists" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$OVERRIDE_SCRIPT' test-agent"
  assert_success
  echo "$output" | grep -q "# Test Agent"
  echo "$output" | grep -q "First section content"
  echo "$output" | grep -q "Second section content"
  echo "$output" | grep -q "Third section content"
}

@test "override: outputs base agent when override file is empty" {
  mkdir -p "$VIBECREW_DIR/agent-overrides"
  touch "$VIBECREW_DIR/agent-overrides/test-agent.md"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$OVERRIDE_SCRIPT' test-agent"
  assert_success
  echo "$output" | grep -q "# Test Agent"
  echo "$output" | grep -q "First section content"
}

# --- Section replacement ---

@test "override: replaces matching section" {
  mkdir -p "$VIBECREW_DIR/agent-overrides"
  cat > "$VIBECREW_DIR/agent-overrides/test-agent.md" <<'OVERRIDE'
## Second Section

Custom second section content.
This replaces the original.
OVERRIDE

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$OVERRIDE_SCRIPT' test-agent"
  assert_success
  echo "$output" | grep -q "First section content"
  echo "$output" | grep -q "Custom second section content"
  echo "$output" | grep -q "Third section content"
  # Original second section should be gone
  ! echo "$output" | grep -q "Second section content\." || [[ "$output" == *"Custom second section content"* ]]
}

# --- Section append ---

@test "override: appends new sections" {
  mkdir -p "$VIBECREW_DIR/agent-overrides"
  cat > "$VIBECREW_DIR/agent-overrides/test-agent.md" <<'OVERRIDE'
## Custom New Section

Brand new content that doesn't exist in base.
OVERRIDE

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$OVERRIDE_SCRIPT' test-agent"
  assert_success
  echo "$output" | grep -q "First section content"
  echo "$output" | grep -q "Second section content"
  echo "$output" | grep -q "Third section content"
  echo "$output" | grep -q "Custom New Section"
  echo "$output" | grep -q "Brand new content"
}

# --- Frontmatter preservation ---

@test "override: preserves YAML frontmatter from base" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$OVERRIDE_SCRIPT' test-agent"
  assert_success
  echo "$output" | grep -q "name: test-agent"
  echo "$output" | grep -q "model: opus"
}

# --- Mixed replace + append ---

@test "override: handles both replace and append in one override" {
  mkdir -p "$VIBECREW_DIR/agent-overrides"
  cat > "$VIBECREW_DIR/agent-overrides/test-agent.md" <<'OVERRIDE'
## First Section

Replaced first section.

## Brand New Section

Appended new section.
OVERRIDE

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$OVERRIDE_SCRIPT' test-agent"
  assert_success
  echo "$output" | grep -q "Replaced first section"
  echo "$output" | grep -q "Second section content"
  echo "$output" | grep -q "Third section content"
  echo "$output" | grep -q "Brand New Section"
  echo "$output" | grep -q "Appended new section"
}
