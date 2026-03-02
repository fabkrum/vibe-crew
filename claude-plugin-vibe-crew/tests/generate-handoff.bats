#!/usr/bin/env bats
# tests/generate-handoff.bats
# Tests for scripts/generate-handoff.sh — session handoff document generation
#
# Note: The script uses `set -euo pipefail` with `ls ... | head/wc` pipelines
# for glob matching. When no files match, `ls` returns exit 1 which aborts the
# script via pipefail. Tests pre-seed placeholder files and enough git commits
# to avoid these edge cases so we can test the actual handoff generation logic.
#
# Numbering: the pre-seed file (000.md) counts as 1 existing, so the script's
# NEXT = 002. The first generated handoff is therefore *-002.md.

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  cd "$TEST_PROJECT_DIR"

  # Create enough commits so HEAD~5 doesn't fail
  for i in 1 2 3 4 5 6; do
    echo "file$i" > "file$i.txt"
    git add "file$i.txt"
    git commit -m "chore: commit $i" --quiet
  done

  # Pre-seed a handoff file for today so `ls ... | wc -l` succeeds
  TODAY_DATE=$(date -u +%Y-%m-%d)
  touch "$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-000.md"

  # Pre-seed a score file so `ls -1t ... | head -1` succeeds
  echo '{"score": 85, "rating": "Great"}' > "$VIBECREW_DIR/scores/score-2026-01-01.json"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# File creation
# =============================================================================

@test "creates handoff file with date in name" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success

  # Pre-seed 000 counts as 1 existing, so NEXT=002
  local handoff_file="$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-002.md"
  [[ -f "$handoff_file" ]]
}

@test "sequential numbering increments for same day" {
  cd "$TEST_PROJECT_DIR"

  # First generation: NEXT=002
  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success

  # Second generation: existing now = 2 (000 + 002), NEXT=003
  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success

  [[ -f "$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-002.md" ]]
  [[ -f "$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-003.md" ]]
}

# =============================================================================
# Content
# =============================================================================

@test "contains active feature info when set" {
  cd "$TEST_PROJECT_DIR"
  set_active_feature "feat-100" "Payment Integration" "code"

  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success

  local handoff_file="$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-002.md"
  local content
  content=$(cat "$handoff_file")
  [[ "$content" == *"Payment Integration"* ]]
  [[ "$content" == *"feat-100"* ]]
}

@test "no active feature shows none" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success

  local handoff_file="$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-002.md"
  local content
  content=$(cat "$handoff_file")
  [[ "$content" == *"none"* ]]
}

@test "contains recent commits" {
  cd "$TEST_PROJECT_DIR"
  echo "feature" > feature.txt && git add feature.txt && git commit -m "feat: add feature A" --quiet

  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success

  local handoff_file="$VIBECREW_DIR/handoffs/handoff-${TODAY_DATE}-002.md"
  local content
  content=$(cat "$handoff_file")
  [[ "$content" == *"feat: add feature A"* ]]
}

# =============================================================================
# Exit behavior
# =============================================================================

@test "exits 0 always" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success
}

@test "output mentions word count" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-handoff.sh"
  assert_success
  [[ "$output" == *"words"* ]]
}
