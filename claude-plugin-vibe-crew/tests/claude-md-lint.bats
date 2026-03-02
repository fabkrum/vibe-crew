#!/usr/bin/env bats
# tests/claude-md-lint.bats
# Tests for scripts/claude-md-lint.sh — CLAUDE.md size and quality validation

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/claude-md-lint.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "exits 0 silently when CLAUDE.md does not exist" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "Lint Report"
}

@test "valid small CLAUDE.md passes with OK status" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# CLAUDE.md

## Project Overview

This is a test project.

## Session Learnings

- Use bun for testing
- Always run lint before commit
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "Lint Report"
  assert_output --partial "(OK)"
}

@test "oversized CLAUDE.md (>400 lines) shows BLOCKED" {
  # Generate a CLAUDE.md with 410 lines
  {
    echo "# CLAUDE.md"
    echo ""
    echo "## Rules"
    for i in $(seq 1 407); do
      echo "- Rule $i: do something"
    done
  } > "$TEST_PROJECT_DIR/CLAUDE.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "BLOCKED"
}

@test "medium CLAUDE.md (200-400 lines) shows WARNING" {
  {
    echo "# CLAUDE.md"
    echo ""
    echo "## Rules"
    for i in $(seq 1 210); do
      echo "- Rule $i: do something"
    done
  } > "$TEST_PROJECT_DIR/CLAUDE.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "WARNING"
}

@test "detects Session Learnings over max (15)" {
  {
    echo "# CLAUDE.md"
    echo ""
    echo "## Session Learnings"
    for i in $(seq 1 20); do
      echo "- Learning $i: always do X"
    done
  } > "$TEST_PROJECT_DIR/CLAUDE.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "Session Learnings has 20 rules"
  assert_output --partial "max: 15"
}

@test "detects redundant rules that restate hook enforcement" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# CLAUDE.md

## Rules

- Never write source code before foundation is complete
- Never force push to remote
- Always run build before shipping
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "Redundant rules"
}

@test "detects duplicate rules" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# CLAUDE.md

## Rules

- Always use TypeScript strict mode for all new files
- Write tests before code
- Always use TypeScript strict mode for all new files
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "Duplicate rules"
}

@test "always exits 0 (advisory only)" {
  # Even oversized files should exit 0
  {
    echo "# CLAUDE.md"
    for i in $(seq 1 500); do
      echo "- Rule $i"
    done
  } > "$TEST_PROJECT_DIR/CLAUDE.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}
