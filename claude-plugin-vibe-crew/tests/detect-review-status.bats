#!/usr/bin/env bats
# tests/detect-review-status.bats
# Tests for scripts/detect-review-status.sh — code review status detection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "no reviews directory returns not completed" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-review-status.sh" "$TEST_PROJECT_DIR"
  assert_success

  local completed
  completed=$(echo "$output" | jq '.review_completed')
  [[ "$completed" == "false" ]]
}

@test "no active feature returns not completed" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/reviews"

  run bash "$SCRIPTS_DIR/detect-review-status.sh" "$TEST_PROJECT_DIR"
  assert_success

  local completed
  completed=$(echo "$output" | jq '.review_completed')
  [[ "$completed" == "false" ]]
}

@test "review found for active feature" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/reviews"
  set_active_feature "feat-001" "Test Feature" "review"

  cat > "$VIBECREW_DIR/reviews/review-feat-001-001.json" <<'EOF'
{"findings":[{"type":"bug","message":"null check missing"}],"verdict":"approve-with-findings"}
EOF

  run bash "$SCRIPTS_DIR/detect-review-status.sh" "$TEST_PROJECT_DIR"
  assert_success

  local completed
  completed=$(echo "$output" | jq '.review_completed')
  [[ "$completed" == "true" ]]

  local findings
  findings=$(echo "$output" | jq '.findings_count')
  [[ "$findings" == "1" ]]

  local verdict
  verdict=$(echo "$output" | jq -r '.verdict')
  [[ "$verdict" == "approve-with-findings" ]]
}

@test "no matching review for active feature" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$VIBECREW_DIR/reviews"
  set_active_feature "feat-001" "Test Feature" "review"
  # Review for a different feature
  echo '{"findings":[],"verdict":"approved"}' > "$VIBECREW_DIR/reviews/review-feat-999-001.json"

  run bash "$SCRIPTS_DIR/detect-review-status.sh" "$TEST_PROJECT_DIR"
  assert_success

  local completed
  completed=$(echo "$output" | jq '.review_completed')
  [[ "$completed" == "false" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-review-status.sh" "$TEST_PROJECT_DIR"
  assert_success
  echo "$output" | jq empty
}

@test "default verdict is none" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-review-status.sh" "$TEST_PROJECT_DIR"
  assert_success

  local verdict
  verdict=$(echo "$output" | jq -r '.verdict')
  [[ "$verdict" == "none" ]]
}
