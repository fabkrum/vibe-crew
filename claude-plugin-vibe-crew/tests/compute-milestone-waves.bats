#!/usr/bin/env bats
# Tests for scripts/compute-milestone-waves.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/compute-milestone-waves.sh"

setup() {
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

add_feature_with_milestones() {
  local id="$1"
  local milestones_json="$2"
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"

  jq --arg id "$id" --argjson ms "$milestones_json" '
    .features += [{
      id: $id,
      name: "Test Feature",
      column: "planned",
      priority: 1,
      depends_on: [],
      labels: [],
      spec: { problem_statement: null, acceptance_criteria: [], milestones: $ms },
      phases_completed: [],
      created_at: "2026-01-01T00:00:00Z",
      updated_at: "2026-01-01T00:00:00Z"
    }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"
}

# --- Error handling ---

@test "compute-milestone-waves: fails without feature-id" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
}

@test "compute-milestone-waves: fails when backlog missing" {
  rm "$VIBECREW_DIR/backlog.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_failure
}

# --- No milestones ---

@test "compute-milestone-waves: returns sequential for feature without milestones" {
  add_feature_to_backlog "feat-001" "No milestones feature"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.sequential')" = "true" ]
  [ "$(echo "$output" | jq '.waves | length')" = "0" ]
}

# --- Independent milestones (all wave 1) ---

@test "compute-milestone-waves: groups independent milestones into one wave" {
  local ms='[
    {"name": "Backend API", "depends_on": [], "status": "pending"},
    {"name": "Frontend UI", "depends_on": [], "status": "pending"},
    {"name": "Database", "depends_on": [], "status": "pending"}
  ]'
  add_feature_with_milestones "feat-001" "$ms"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_success
  echo "$output" | jq empty
  # 3 milestones with empty depends_on = exactly 3, which is the limit
  [ "$(echo "$output" | jq '.waves | length')" = "1" ]
  [ "$(echo "$output" | jq '.waves[0] | length')" = "3" ]
}

# --- Safety fallback: too many without depends_on ---

@test "compute-milestone-waves: falls back to sequential when >3 milestones lack depends_on" {
  local ms='[
    {"name": "A", "depends_on": [], "status": "pending"},
    {"name": "B", "depends_on": [], "status": "pending"},
    {"name": "C", "depends_on": [], "status": "pending"},
    {"name": "D", "depends_on": [], "status": "pending"}
  ]'
  add_feature_with_milestones "feat-001" "$ms"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.sequential')" = "true" ]
  [[ "$(echo "$output" | jq -r '.reason')" == *"falling back to sequential"* ]]
}

# --- Linear dependencies ---

@test "compute-milestone-waves: produces one milestone per wave for linear deps" {
  local ms='[
    {"name": "Schema", "depends_on": [], "status": "pending"},
    {"name": "API", "depends_on": ["Schema"], "status": "pending"},
    {"name": "UI", "depends_on": ["API"], "status": "pending"}
  ]'
  add_feature_with_milestones "feat-001" "$ms"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.waves | length')" = "3" ]
  [ "$(echo "$output" | jq '.waves[0] | length')" = "1" ]
  [ "$(echo "$output" | jq -r '.waves[0][0]')" = "Schema" ]
  [ "$(echo "$output" | jq -r '.waves[1][0]')" = "API" ]
  [ "$(echo "$output" | jq -r '.waves[2][0]')" = "UI" ]
  [ "$(echo "$output" | jq '.sequential')" = "true" ]
}

# --- Diamond dependency ---

@test "compute-milestone-waves: handles diamond dependency pattern" {
  local ms='[
    {"name": "Foundation", "depends_on": [], "status": "pending"},
    {"name": "Backend", "depends_on": ["Foundation"], "status": "pending"},
    {"name": "Frontend", "depends_on": ["Foundation"], "status": "pending"},
    {"name": "Integration", "depends_on": ["Backend", "Frontend"], "status": "pending"}
  ]'
  add_feature_with_milestones "feat-001" "$ms"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.waves | length')" = "3" ]
  # Wave 1: Foundation
  [ "$(echo "$output" | jq '.waves[0] | length')" = "1" ]
  # Wave 2: Backend + Frontend (parallel)
  [ "$(echo "$output" | jq '.waves[1] | length')" = "2" ]
  # Wave 3: Integration
  [ "$(echo "$output" | jq '.waves[2] | length')" = "1" ]
  [ "$(echo "$output" | jq '.sequential')" = "false" ]
}

# --- Cycle detection ---

@test "compute-milestone-waves: detects dependency cycles" {
  local ms='[
    {"name": "A", "depends_on": ["B"], "status": "pending"},
    {"name": "B", "depends_on": ["A"], "status": "pending"}
  ]'
  add_feature_with_milestones "feat-001" "$ms"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat-001"
  assert_failure
}
