#!/usr/bin/env bats
# tests/apply-mutation.bats
# Tests for scripts/apply-mutation.sh — CLAUDE.md mutation application

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/apply-mutation.sh"
}

teardown() {
  teardown_vibecrew_dir
}

run_apply() {
  run bash -c "cd '$TEST_PROJECT_DIR' && export PROJECT_ROOT='$TEST_PROJECT_DIR' && bash '$SCRIPT' $*"
}

# =============================================================================
# Error cases
# =============================================================================

@test "exits with error when no --rule provided" {
  # Create CLAUDE.md so the script doesn't fail for a different reason
  echo "# Project" > "$TEST_PROJECT_DIR/CLAUDE.md"

  run_apply ""
  assert_failure
  assert_output --partial "ERROR: --rule is required"
}

@test "exits with error when CLAUDE.md does not exist" {
  # Ensure CLAUDE.md does not exist
  rm -f "$TEST_PROJECT_DIR/CLAUDE.md"

  run_apply "--rule 'Always run tests before committing' --session-id 'session-test-001'"
  assert_failure
  assert_output --partial "ERROR: CLAUDE.md not found"
}

@test "exits with error when only unrecognized arguments provided" {
  echo "# Project" > "$TEST_PROJECT_DIR/CLAUDE.md"

  # Passing a bare argument (no --rule) means RULE stays empty
  run_apply "mut-nonexistent-id"
  assert_failure
  assert_output --partial "ERROR: --rule is required"
}

# =============================================================================
# Successful application
# =============================================================================

@test "successfully applies a rule to CLAUDE.md" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Guidelines

- Follow conventions.
EOF

  # Create mutation-log.json so the script can record the mutation
  echo '{"mutations":[]}' > "$VIBECREW_DIR/mutation-log.json"

  run_apply "--rule 'Always run tests before committing' --session-id 'session-test-001' --pattern 'testing'"
  assert_success
  assert_output --partial "Applied mutation to CLAUDE.md"

  # Verify the rule was appended
  run grep -F "Always run tests before committing" "$TEST_PROJECT_DIR/CLAUDE.md"
  assert_success
}

@test "creates Session Learnings section when it does not exist" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Guidelines

- Follow conventions.
EOF

  run_apply "--rule 'Use TypeScript strict mode' --session-id 'session-test-002'"
  assert_success

  # Verify the section was created
  run grep -F -- "## Session Learnings" "$TEST_PROJECT_DIR/CLAUDE.md"
  assert_success

  # Verify the rule is listed under it
  run grep -F -- "- Use TypeScript strict mode" "$TEST_PROJECT_DIR/CLAUDE.md"
  assert_success
}

# =============================================================================
# Duplicate / skip handling
# =============================================================================

@test "skips rule that already exists in CLAUDE.md" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Session Learnings

- Always run tests before committing
EOF

  run_apply "--rule 'Always run tests before committing' --session-id 'session-test-003'"
  assert_success
  assert_output --partial "SKIP: Rule already exists"

  # Verify the rule was NOT duplicated
  local count
  count=$(grep -c "Always run tests before committing" "$TEST_PROJECT_DIR/CLAUDE.md")
  [ "$count" -eq 1 ]
}

# =============================================================================
# Mutation log updates
# =============================================================================

@test "updates mutation-log.json with applied entry" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Guidelines

- Follow conventions.
EOF

  echo '{"mutations":[]}' > "$VIBECREW_DIR/mutation-log.json"

  run_apply "--rule 'Prefer composition over inheritance' --session-id 'session-test-004' --pattern 'architecture'"
  assert_success
  assert_output --partial "Updated mutation-log.json"

  # Verify the mutation was recorded
  local status
  status=$(jq -r '.mutations[-1].status' "$VIBECREW_DIR/mutation-log.json")
  [ "$status" = "applied" ]

  local rule
  rule=$(jq -r '.mutations[-1].proposed_rule' "$VIBECREW_DIR/mutation-log.json")
  [ "$rule" = "Prefer composition over inheritance" ]

  local session
  session=$(jq -r '.mutations[-1].session_id' "$VIBECREW_DIR/mutation-log.json")
  [ "$session" = "session-test-004" ]

  local source
  source=$(jq -r '.mutations[-1].source' "$VIBECREW_DIR/mutation-log.json")
  [ "$source" = "performance-coach" ]
}

@test "applies rule without mutation-log.json (log update skipped)" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Guidelines

- Follow conventions.
EOF

  # Do NOT create mutation-log.json
  rm -f "$VIBECREW_DIR/mutation-log.json"

  run_apply "--rule 'Keep functions under 30 lines' --session-id 'session-test-005'"
  assert_success
  assert_output --partial "Applied mutation to CLAUDE.md"

  # Verify the rule was still appended to CLAUDE.md
  run grep -F "Keep functions under 30 lines" "$TEST_PROJECT_DIR/CLAUDE.md"
  assert_success

  # Verify no mutation-log.json was created
  [ ! -f "$VIBECREW_DIR/mutation-log.json" ]
}
