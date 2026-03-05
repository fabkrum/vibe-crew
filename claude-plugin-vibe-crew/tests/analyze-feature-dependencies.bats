#!/usr/bin/env bats
# Tests for scripts/analyze-feature-dependencies.sh

load 'test_helper/common-setup'

ANALYZE_SCRIPT="$SCRIPTS_DIR/analyze-feature-dependencies.sh"

setup() {
  setup_vibecrew_dir
  touch "$TEST_PROJECT_DIR/.gitkeep"
  git -C "$TEST_PROJECT_DIR" add .
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

# --- Basic behavior ---

@test "analyze: fails when backlog missing" {
  rm "$VIBECREW_DIR/backlog.json"
  run bash "$ANALYZE_SCRIPT" "$VIBECREW_DIR/backlog.json"
  assert_failure
}

@test "analyze: returns empty waves for empty backlog" {
  run bash "$ANALYZE_SCRIPT" "$VIBECREW_DIR/backlog.json"
  assert_success
  echo "$output" | jq -e '.waves | length == 0'
  echo "$output" | jq -e '.total_features == 0'
  echo "$output" | jq -e '.parallel_possible == false'
}

# --- Independent features ---

@test "analyze: groups independent features into one wave" {
  add_feature_to_backlog "feat-001" "Auth" "planned" 1
  add_feature_to_backlog "feat-002" "Dashboard" "planned" 2
  add_feature_to_backlog "feat-003" "Settings" "planned" 3

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq -e '.total_features == 3'
  echo "$output" | jq -e '.parallel_possible == true'
  echo "$output" | jq -e '.waves | length == 1'
  echo "$output" | jq -e '.waves[0] | length == 3'
}

# --- Dependent features ---

@test "analyze: separates dependent features into waves" {
  # feat-002 depends on feat-001
  add_feature_to_backlog "feat-001" "Auth" "planned" 1
  add_feature_to_backlog "feat-002" "Dashboard" "planned" 2 '["feat-001"]'
  add_feature_to_backlog "feat-003" "Settings" "planned" 3

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq -e '.total_waves == 2'
  # Wave 1: feat-001, feat-003 (independent)
  echo "$output" | jq -e '.waves[0] | length == 2'
  # Wave 2: feat-002 (depends on feat-001)
  echo "$output" | jq -e '.waves[1] | length == 1'
}

# --- Chain dependencies ---

@test "analyze: handles chain dependencies (A -> B -> C)" {
  add_feature_to_backlog "feat-001" "Auth" "planned" 1
  add_feature_to_backlog "feat-002" "Roles" "planned" 2 '["feat-001"]'
  add_feature_to_backlog "feat-003" "Permissions" "planned" 3 '["feat-002"]'

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq -e '.total_waves == 3'
  echo "$output" | jq -e '.parallel_possible == false'
  echo "$output" | jq -e '.max_parallelism == 1'
}

# --- Dependencies on done features ---

@test "analyze: treats done features as satisfied dependencies" {
  # Add a done feature
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"
  jq '.features += [{
    id: "feat-000", name: "Base", column: "done", priority: 0,
    depends_on: [], labels: [],
    spec: {problem_statement: null, acceptance_criteria: []},
    phases_completed: ["plan","design","code","test","review","docs"],
    created_at: "2026-01-01T00:00:00Z", updated_at: "2026-01-01T00:00:00Z"
  }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"

  # feat-001 depends on done feat-000
  add_feature_to_backlog "feat-001" "Feature" "planned" 1 '["feat-000"]'

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq -e '.total_waves == 1'
  echo "$output" | jq -e '.waves[0] | length == 1'
}

# --- Single feature ---

@test "analyze: single feature produces one wave" {
  add_feature_to_backlog "feat-001" "Solo Feature" "planned" 1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq -e '.total_features == 1'
  echo "$output" | jq -e '.total_waves == 1'
  echo "$output" | jq -e '.parallel_possible == false'
}

# --- Max parallelism ---

@test "analyze: reports correct max_parallelism" {
  add_feature_to_backlog "feat-001" "A" "planned" 1
  add_feature_to_backlog "feat-002" "B" "planned" 2
  add_feature_to_backlog "feat-003" "C" "planned" 3
  add_feature_to_backlog "feat-004" "D" "planned" 4 '["feat-001"]'

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq -e '.max_parallelism == 3'
}

# --- Output is valid JSON ---

@test "analyze: output is valid JSON" {
  add_feature_to_backlog "feat-001" "Test" "planned" 1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$ANALYZE_SCRIPT' '$VIBECREW_DIR/backlog.json'"
  assert_success
  echo "$output" | jq empty
}
