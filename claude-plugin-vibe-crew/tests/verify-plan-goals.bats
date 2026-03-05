#!/usr/bin/env bats
# tests/verify-plan-goals.bats
# Tests for scripts/verify-plan-goals.sh — pre-execution plan verification

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/verify-plan-goals.sh"
  setup_vibecrew_dir

  # Create a plan file with structured tasks
  PLAN_DIR="$TEST_PROJECT_DIR/docs/features/test-feature"
  mkdir -p "$PLAN_DIR"
  PLAN_FILE="$PLAN_DIR/plan.md"
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: create a plan file with given tasks
create_plan_file() {
  cat > "$PLAN_FILE" <<'EOF'
# Implementation Plan: Test Feature

## Approach
Build a user dashboard with filtering.

## Tasks

### Task 1: Create dashboard component
- **Files**: `src/components/Dashboard.tsx` (create)
- **Action**: Create the dashboard component with user filtering
- **Verify**: `npm run build`
- **Done when**: Dashboard renders with filter controls

### Task 2: Add API endpoint
- **Files**: `src/api/users.ts` (create)
- **Action**: Create GET /api/users endpoint with filter support
- **Verify**: `npm test`
- **Done when**: API returns filtered user list
EOF
}

# Helper: add a feature with acceptance criteria to backlog
add_feature_with_criteria() {
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"
  jq '.features += [{
    "id": "feat-001",
    "name": "Test Feature",
    "column": "planned",
    "priority": 1,
    "spec": {
      "acceptance_criteria": [
        "WHEN the user visits /dashboard THE SYSTEM SHALL display a list of users",
        "WHEN the user applies a filter THE SYSTEM SHALL update the list in real-time",
        "IF the API returns an error THEN THE SYSTEM SHALL show an error message"
      ]
    }
  }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"
}

add_feature_with_uncovered_criteria() {
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"
  jq '.features += [{
    "id": "feat-002",
    "name": "Test Feature",
    "column": "planned",
    "priority": 1,
    "spec": {
      "acceptance_criteria": [
        "WHEN the user visits /dashboard THE SYSTEM SHALL display users",
        "WHEN the user exports data THE SYSTEM SHALL generate a CSV file",
        "THE SYSTEM SHALL send email notifications on state change"
      ]
    }
  }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"
}

add_feature_with_non_ears_criteria() {
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"
  jq '.features += [{
    "id": "feat-003",
    "name": "Test Feature",
    "column": "planned",
    "priority": 1,
    "spec": {
      "acceptance_criteria": [
        "User can filter tasks by status",
        "Dashboard loads in under 2 seconds",
        "Mobile layout is responsive"
      ]
    }
  }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"
}

# =============================================================================
# Error handling
# =============================================================================

@test "exits 1 when plan file not found" {
  run bash "$SCRIPT" "/nonexistent/plan.md" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_failure
  assert_output --partial '"pass": false'
  assert_output --partial '"error": "Plan file not found"'
}

@test "exits 1 when feature ID is missing" {
  create_plan_file
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" ""
  assert_failure
  assert_output --partial '"error": "Feature ID required"'
}

# =============================================================================
# Goal coverage
# =============================================================================

@test "goal coverage passes when plan tasks cover acceptance criteria" {
  create_plan_file
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_success
  local result
  result=$(echo "$output" | jq '.checks.goal_coverage.pass')
  assert_equal "$result" "true"
}

@test "goal coverage fails when criteria are not covered by plan tasks" {
  create_plan_file
  add_feature_with_uncovered_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-002"
  assert_failure
  local result
  result=$(echo "$output" | jq '.checks.goal_coverage.pass')
  assert_equal "$result" "false"
  # The "export CSV" and "email notifications" criteria should be uncovered
  local uncovered_count
  uncovered_count=$(echo "$output" | jq '.checks.goal_coverage.uncovered_criteria | length')
  [ "$uncovered_count" -gt 0 ]
}

@test "goal coverage reports correct criteria and task counts" {
  create_plan_file
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_success
  local criteria_count task_count
  criteria_count=$(echo "$output" | jq '.checks.goal_coverage.criteria_count')
  task_count=$(echo "$output" | jq '.checks.goal_coverage.task_count')
  assert_equal "$criteria_count" "3"
  assert_equal "$task_count" "2"
}

# =============================================================================
# Dependency integrity
# =============================================================================

@test "dependency check passes when no files are marked as modify" {
  cat > "$PLAN_FILE" <<'EOF'
# Plan

### Task 1: Create new file
- **Files**: `src/new.ts` (create)
- **Action**: Create new file
- **Verify**: `npm run build`
- **Done when**: File exists
EOF
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  # Overall may fail (goal coverage) — this test only checks dependency integrity
  local dep_pass
  dep_pass=$(echo "$output" | jq '.checks.dependency_integrity.pass')
  assert_equal "$dep_pass" "true"
}

# =============================================================================
# Context budget
# =============================================================================

@test "context budget passes for small plans" {
  create_plan_file
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_success
  local budget_pass
  budget_pass=$(echo "$output" | jq '.checks.context_budget.pass')
  assert_equal "$budget_pass" "true"
}

@test "context budget includes estimated percentage" {
  create_plan_file
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_success
  local estimated
  estimated=$(echo "$output" | jq '.checks.context_budget.estimated_percent')
  [ "$estimated" -ge 0 ]
}

# =============================================================================
# EARS format validation
# =============================================================================

@test "EARS check passes when all criteria use EARS format" {
  create_plan_file
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_success
  local ears_pass ears_count
  ears_pass=$(echo "$output" | jq '.checks.ears_format.pass')
  ears_count=$(echo "$output" | jq '.checks.ears_format.ears_count')
  assert_equal "$ears_pass" "true"
  assert_equal "$ears_count" "3"
}

@test "EARS check fails when no criteria use EARS format" {
  create_plan_file
  add_feature_with_non_ears_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-003"
  # EARS failure doesn't cause overall failure (it's advisory)
  local ears_pass non_ears
  ears_pass=$(echo "$output" | jq '.checks.ears_format.pass')
  non_ears=$(echo "$output" | jq '.checks.ears_format.non_ears_count')
  assert_equal "$ears_pass" "false"
  assert_equal "$non_ears" "3"
}

# =============================================================================
# Overall pass/fail
# =============================================================================

@test "overall pass is true when all critical checks pass" {
  create_plan_file
  add_feature_with_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-001"
  assert_success
  local overall
  overall=$(echo "$output" | jq '.pass')
  assert_equal "$overall" "true"
}

@test "overall pass is false when goal coverage fails" {
  create_plan_file
  add_feature_with_uncovered_criteria
  run bash "$SCRIPT" "$PLAN_FILE" "$VIBECREW_DIR/backlog.json" "feat-002"
  assert_failure
  local overall
  overall=$(echo "$output" | jq '.pass')
  assert_equal "$overall" "false"
}

@test "handles missing backlog file gracefully" {
  create_plan_file
  run bash "$SCRIPT" "$PLAN_FILE" "/nonexistent/backlog.json" "feat-001"
  # Should still succeed — just can't check criteria
  assert_success
}
