#!/usr/bin/env bats
# tests/expertise-sync-learnings.bats

setup() {
  load 'test_helper/common-setup'
  WRITE_SCRIPT="$SCRIPTS_DIR/expertise-write.sh"
  SCRIPT="$SCRIPTS_DIR/expertise-sync-learnings.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/expertise"
}

teardown() {
  teardown_vibecrew_dir
}

@test "generates Session Learnings from expertise records" {
  # Create CLAUDE.md with empty session learnings
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Session Learnings

- Old rule that should be replaced
EOF

  # Seed expertise records
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type convention --tier foundational --content 'New rule from expertise' --confidence 0.90 --session-id 'session-test'" > /dev/null

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "Synced 1 foundational records"

  # Verify CLAUDE.md now contains the new rule
  grep -q "New rule from expertise" "$TEST_PROJECT_DIR/CLAUDE.md"
  # Verify old rule is gone
  ! grep -q "Old rule that should be replaced" "$TEST_PROJECT_DIR/CLAUDE.md"
}

@test "limits to 15 records" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Session Learnings

EOF

  # Seed 20 foundational records
  for i in $(seq 1 20); do
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type convention --tier foundational --content 'Rule number $i' --confidence 0.$(printf '%02d' $((90 - i))) --session-id 'session-test'" > /dev/null
  done

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "Synced 15 foundational records"

  # Count rules in CLAUDE.md
  local rule_count
  rule_count=$(grep -c "^- " "$TEST_PROJECT_DIR/CLAUDE.md")
  [ "$rule_count" -eq 15 ]
}

@test "creates Session Learnings section if missing" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Tech Stack

Content here.
EOF

  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type convention --tier foundational --content 'Auto-generated rule' --confidence 0.90 --session-id 'session-test'" > /dev/null

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  grep -q "## Session Learnings" "$TEST_PROJECT_DIR/CLAUDE.md"
  grep -q "Auto-generated rule" "$TEST_PROJECT_DIR/CLAUDE.md"
}

@test "skips when no foundational records exist" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type convention --tier observational --content 'Observational only' --confidence 0.50 --session-id 'session-test'" > /dev/null
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "No foundational records"
}

@test "handles missing CLAUDE.md" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "No CLAUDE.md found"
}
