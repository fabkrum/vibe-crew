#!/usr/bin/env bats
# tests/phase-gate.bats
# Tests for scripts/phase-gate.sh — PreToolUse hook for Write|Edit

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/phase-gate.sh"
}

teardown() {
  teardown_vibecrew_dir
}

# --- Helper ---
run_gate() {
  local tool="$1"
  local file_path="$2"
  if [[ "$tool" == "Write" ]]; then
    run bash -c "cd '$TEST_PROJECT_DIR' && echo '$(create_write_hook_input "$file_path")' | bash '$SCRIPT'"
  elif [[ "$tool" == "Edit" ]]; then
    run bash -c "cd '$TEST_PROJECT_DIR' && echo '$(create_edit_hook_input "$file_path")' | bash '$SCRIPT'"
  else
    run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"tool_name\":\"$tool\",\"tool_input\":{}}' | bash '$SCRIPT'"
  fi
}

# =============================================================================
# Non-Write/Edit tools pass through
# =============================================================================

@test "non-Write/Edit tool: always allows" {
  run_gate "Bash" ""
  assert_success
}

@test "Read tool: always allows" {
  run_gate "Read" ""
  assert_success
}

# =============================================================================
# Foundation complete: all writes allowed
# =============================================================================

@test "foundation complete: allows source code writes" {
  set_foundation_complete
  run_gate "Write" "$TEST_PROJECT_DIR/src/app.tsx"
  assert_success
}

@test "foundation complete: allows any file" {
  set_foundation_complete
  run_gate "Write" "$TEST_PROJECT_DIR/anything.js"
  assert_success
}

# =============================================================================
# Foundation incomplete: blocks source code
# =============================================================================

@test "foundation incomplete: blocks src/ writes" {
  run_gate "Write" "$TEST_PROJECT_DIR/src/app.tsx"
  assert_failure 2
  assert_output --partial "Cannot write source code"
}

@test "foundation incomplete: blocks lib/ writes" {
  run_gate "Write" "$TEST_PROJECT_DIR/lib/utils.ts"
  assert_failure 2
}

@test "foundation incomplete: blocks Edit to source" {
  run_gate "Edit" "$TEST_PROJECT_DIR/src/component.tsx"
  assert_failure 2
}

# =============================================================================
# Foundation incomplete: allows Tier 1 artifacts
# =============================================================================

@test "allows VISION.md during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/VISION.md"
  assert_success
}

@test "allows CLAUDE.md during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/CLAUDE.md"
  assert_success
}

@test "allows design-system.css during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/design-system.css"
  assert_success
}

@test "allows design-brief.md during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/design-brief.md"
  assert_success
}

@test "allows .vibecrew/ writes during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/.vibecrew/state.json"
  assert_success
}

@test "allows docs/ writes during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/docs/tdr-001.md"
  assert_success
}

@test "allows .mmd files during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/.vibecrew/architecture/system.mmd"
  assert_success
}

@test "allows package.json during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/package.json"
  assert_success
}

@test "allows .gitignore during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/.gitignore"
  assert_success
}

@test "allows TDR files during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.tdr.md"
  assert_success
}

@test "allows roadmap.md during Tier 1" {
  run_gate "Write" "$TEST_PROJECT_DIR/roadmap.md"
  assert_success
}

# =============================================================================
# No state file: bootstrap mode
# =============================================================================

@test "no state.json: allows .vibecrew/ writes (bootstrap)" {
  rm "$VIBECREW_DIR/state.json"
  run_gate "Write" "$TEST_PROJECT_DIR/.vibecrew/config.json"
  assert_success
}

@test "no state.json: blocks source code writes" {
  rm "$VIBECREW_DIR/state.json"
  run_gate "Write" "$TEST_PROJECT_DIR/src/app.tsx"
  assert_failure 2
}
