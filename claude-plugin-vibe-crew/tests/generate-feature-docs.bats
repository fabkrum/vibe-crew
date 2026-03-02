#!/usr/bin/env bats
# tests/generate-feature-docs.bats
# Tests for scripts/generate-feature-docs.sh — feature doc generation from backlog

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Skip conditions
# =============================================================================

@test "no backlog.json produces skip message and exits 0" {
  cd "$TEST_PROJECT_DIR"
  rm -f "$VIBECREW_DIR/backlog.json"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success
  [[ "$output" == *"No backlog.json found"* ]]
}

@test "no completed features produces skip message and exits 0" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-001" "Login Page" "planned"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success
  [[ "$output" == *"No completed features"* ]]
}

# =============================================================================
# Doc generation for completed features
# =============================================================================

@test "completed feature in done column generates doc file" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-001" "User Authentication" "done"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/docs/features/feat-001.md" ]]
}

@test "generated doc contains feature name and ID" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-002" "Dashboard Widget" "done"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success

  local content
  content=$(cat "$TEST_PROJECT_DIR/docs/features/feat-002.md")
  [[ "$content" == *"Dashboard Widget"* ]]
  [[ "$content" == *"feat-002"* ]]
}

@test "feature already has doc file — skips it" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-003" "Settings Page" "done"

  # Pre-create the doc
  mkdir -p "$TEST_PROJECT_DIR/docs/features"
  echo "# Existing doc" > "$TEST_PROJECT_DIR/docs/features/feat-003.md"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success

  # Doc should still have original content (not overwritten)
  local content
  content=$(cat "$TEST_PROJECT_DIR/docs/features/feat-003.md")
  [[ "$content" == "# Existing doc" ]]
}

@test "creates docs/features/ directory if missing" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-004" "Notifications" "done"

  # Ensure directory does not exist
  rm -rf "$TEST_PROJECT_DIR/docs/features"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success

  [[ -d "$TEST_PROJECT_DIR/docs/features" ]]
}

@test "multiple completed features generate docs for each" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-010" "Feature Alpha" "done"
  add_feature_to_backlog "feat-011" "Feature Beta" "done"
  add_feature_to_backlog "feat-012" "Feature Gamma" "planned"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/docs/features/feat-010.md" ]]
  [[ -f "$TEST_PROJECT_DIR/docs/features/feat-011.md" ]]
  # feat-012 is planned, not done — no doc
  [[ ! -f "$TEST_PROJECT_DIR/docs/features/feat-012.md" ]]
}

@test "feature in review column also generates doc" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-020" "Review Feature" "review"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success

  [[ -f "$TEST_PROJECT_DIR/docs/features/feat-020.md" ]]
}

@test "exits 0 always" {
  cd "$TEST_PROJECT_DIR"
  add_feature_to_backlog "feat-030" "Some Feature" "done"

  run bash "$SCRIPTS_DIR/generate-feature-docs.sh"
  assert_success
}
