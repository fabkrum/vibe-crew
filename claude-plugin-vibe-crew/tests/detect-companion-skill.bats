#!/usr/bin/env bats
# tests/detect-companion-skill.bats
# Tests for scripts/detect-companion-skill.sh — lightweight skill detection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/detect-companion-skill.sh"
  cd "$TEST_PROJECT_DIR"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# No arguments
# =============================================================================

@test "no arguments: exits 1 with usage" {
  run bash "$SCRIPT"
  assert_failure
  assert_output --partial "Usage:"
}

# =============================================================================
# Skill not installed
# =============================================================================

@test "skill not installed: exits 1 with installed=false" {
  run bash "$SCRIPT" "frontend-design"
  assert_failure

  local installed
  installed=$(echo "$output" | jq -r '.installed')
  [ "$installed" = "false" ]
}

@test "skill not installed: JSON contains skill name" {
  run bash "$SCRIPT" "react-best-practices"
  assert_failure

  local skill
  skill=$(echo "$output" | jq -r '.skill')
  [ "$skill" = "react-best-practices" ]
}

# =============================================================================
# Skill installed in project .claude/skills/
# =============================================================================

@test "skill in project .claude/skills/: exits 0 with installed=true" {
  mkdir -p "$TEST_PROJECT_DIR/.claude/skills/frontend-design"

  run bash "$SCRIPT" "frontend-design"
  assert_success

  local installed
  installed=$(echo "$output" | jq -r '.installed')
  [ "$installed" = "true" ]
}

# =============================================================================
# Skill installed in global ~/.claude/skills/
# =============================================================================

@test "skill in global skills dir: exits 0 with installed=true" {
  # Create temp home with skills dir
  local fake_home
  fake_home="$(mktemp -d)"
  mkdir -p "$fake_home/.claude/skills/web-perf"

  HOME="$fake_home" run bash "$SCRIPT" "web-perf"
  assert_success

  local installed
  installed=$(echo "$output" | jq -r '.installed')
  [ "$installed" = "true" ]

  rm -rf "$fake_home"
}

# =============================================================================
# JSON output structure
# =============================================================================

@test "output is valid JSON with required fields" {
  run bash "$SCRIPT" "some-skill"

  echo "$output" | jq empty 2>/dev/null
  [ $? -eq 0 ]

  local has_skill has_installed
  has_skill=$(echo "$output" | jq 'has("skill")')
  has_installed=$(echo "$output" | jq 'has("installed")')
  [ "$has_skill" = "true" ]
  [ "$has_installed" = "true" ]
}
