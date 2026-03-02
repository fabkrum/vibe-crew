#!/usr/bin/env bats
# tests/generate-onboard-claude-md.bats
# Tests for scripts/generate-onboard-claude-md.sh — CLAUDE.md generation from onboard findings

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: create a full findings JSON file
_create_findings() {
  local findings_file="${1:-$VIBECREW_DIR/onboard-findings.json}"
  local api_style="${2:-rest}"
  local state_mgmt="${3:-zustand}"

  cat > "$findings_file" << FINDINGS_EOF
{
  "project_name": "TestApp",
  "dependencies": {
    "framework": "next.js",
    "language": "typescript",
    "package_manager": "pnpm",
    "node_version": "20",
    "key_dependencies": ["react", "tailwindcss", "prisma"]
  },
  "conventions": {
    "semicolons": true,
    "quotes": "single",
    "indent": "2-space",
    "trailing_commas": "true",
    "formatter": "prettier",
    "linter": "eslint",
    "import_style": "absolute",
    "path_alias": "@/",
    "component_naming": "PascalCase",
    "commit_format": "conventional"
  },
  "architecture": {
    "api_style": "$api_style",
    "state_management": "$state_mgmt"
  },
  "test_gaps": {
    "test_framework": "vitest",
    "e2e_framework": "playwright"
  },
  "design_system": {
    "type": "tailwind",
    "component_library": "shadcn/ui"
  },
  "structure": {
    "source_dirs": ["src/app", "src/components", "src/lib"]
  }
}
FINDINGS_EOF
}

# =============================================================================
# Error handling
# =============================================================================

@test "missing findings file exits 1" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/nonexistent.json"
  assert_failure
  [[ "$output" == *"Findings file not found"* ]]
}

# =============================================================================
# Full generation
# =============================================================================

@test "full findings generates CLAUDE.md with all sections" {
  cd "$TEST_PROJECT_DIR"
  _create_findings

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/onboard-findings.json"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/CLAUDE.md" ]]
  local content
  content=$(cat "$TEST_PROJECT_DIR/CLAUDE.md")
  [[ "$content" == *"## Project Overview"* ]]
  [[ "$content" == *"## Tech Stack"* ]]
  [[ "$content" == *"## Architecture Rules"* ]]
  [[ "$content" == *"## Code Conventions"* ]]
  [[ "$content" == *"## Testing Requirements"* ]]
  [[ "$content" == *"## Common Commands"* ]]
}

@test "contains framework and language" {
  cd "$TEST_PROJECT_DIR"
  _create_findings

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/onboard-findings.json"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CLAUDE.md")
  [[ "$content" == *"next.js"* ]]
  [[ "$content" == *"typescript"* ]]
}

@test "contains conventions — semicolons, quotes, indent" {
  cd "$TEST_PROJECT_DIR"
  _create_findings

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/onboard-findings.json"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CLAUDE.md")
  [[ "$content" == *"Semicolons"* ]]
  [[ "$content" == *"single"* ]]
  [[ "$content" == *"2-space"* ]]
}

# =============================================================================
# Conditional sections
# =============================================================================

@test "API style section included when not unknown" {
  cd "$TEST_PROJECT_DIR"
  _create_findings "$VIBECREW_DIR/onboard-findings.json" "rest" "zustand"

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/onboard-findings.json"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CLAUDE.md")
  [[ "$content" == *"API style: rest"* ]]
}

@test "API style section omitted when unknown" {
  cd "$TEST_PROJECT_DIR"
  _create_findings "$VIBECREW_DIR/onboard-findings.json" "unknown" "zustand"

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/onboard-findings.json"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CLAUDE.md")
  # Should NOT contain the API style line
  [[ "$content" != *"API style: unknown"* ]]
}

@test "state management section included when not none" {
  cd "$TEST_PROJECT_DIR"
  _create_findings "$VIBECREW_DIR/onboard-findings.json" "rest" "redux"

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" --findings "$VIBECREW_DIR/onboard-findings.json"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/CLAUDE.md")
  [[ "$content" == *"State management: redux"* ]]
}

# =============================================================================
# Output flag
# =============================================================================

@test "output file specified via --output flag" {
  cd "$TEST_PROJECT_DIR"
  _create_findings

  local custom_output="$TEST_PROJECT_DIR/custom-claude.md"

  run bash "$SCRIPTS_DIR/generate-onboard-claude-md.sh" \
    --findings "$VIBECREW_DIR/onboard-findings.json" \
    --output "$custom_output"
  assert_success

  [[ -f "$custom_output" ]]
  local content
  content=$(cat "$custom_output")
  [[ "$content" == *"## Project Overview"* ]]
}
