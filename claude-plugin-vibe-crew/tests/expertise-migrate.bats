#!/usr/bin/env bats
# tests/expertise-migrate.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/expertise-migrate.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/expertise"
}

teardown() {
  teardown_vibecrew_dir
}

@test "migrates Session Learnings to expertise" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Session Learnings

- Use Context7 for library docs
- Always run tests before committing
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "migrated=2"
  [ -f "$VIBECREW_DIR/expertise/conventions.jsonl" ]
  local count
  count=$(wc -l < "$VIBECREW_DIR/expertise/conventions.jsonl" | tr -d ' ')
  [ "$count" -eq 2 ]
}

@test "skips already migrated rules (idempotent)" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Session Learnings

- Use Context7 for library docs
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "migrated=1"

  # Run again
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "migrated=0"
  assert_output --partial "skipped=1"
}

@test "handles missing CLAUDE.md" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "No CLAUDE.md found"
}

@test "handles CLAUDE.md without Session Learnings" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Tech Stack

Some content here.
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "No Session Learnings section"
}

@test "sets migrated records as foundational conventions" {
  cat > "$TEST_PROJECT_DIR/CLAUDE.md" <<'EOF'
# Project CLAUDE.md

## Session Learnings

- Always use semicolons
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local tier
  tier=$(jq -r '.tier' "$VIBECREW_DIR/expertise/conventions.jsonl" | head -1)
  [ "$tier" = "foundational" ]
  local source
  source=$(jq -r '.source_agent' "$VIBECREW_DIR/expertise/conventions.jsonl" | head -1)
  [ "$source" = "migration" ]
}
