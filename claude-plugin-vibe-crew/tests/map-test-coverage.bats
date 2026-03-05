#!/usr/bin/env bats
# Tests for scripts/map-test-coverage.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/map-test-coverage.sh"

setup() {
  setup_vibecrew_dir
  # Create initial commit
  touch "$TEST_PROJECT_DIR/.gitkeep"
  git -C "$TEST_PROJECT_DIR" add .
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1

  # Create a plan file
  PLAN_FILE="$TEST_PROJECT_DIR/docs/features/test-feature/plan.md"
  mkdir -p "$(dirname "$PLAN_FILE")"
  cat > "$PLAN_FILE" <<'EOF'
# Implementation Plan: Test Feature

## Tasks

### Task 1: Create login form
- **Files**: `src/components/LoginForm.tsx` (create)
- **Action**: Create login form component
- **Verify**: `npm run build`
- **Done when**: Form renders correctly
EOF
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: create backlog with acceptance criteria
create_backlog_with_criteria() {
  local criteria="${1:-[]}"
  cat > "$VIBECREW_DIR/backlog.json" <<EOF
{
  "schema_version": "1.0.0",
  "features": [
    {
      "id": "feat-001",
      "name": "Test Feature",
      "column": "in-progress",
      "spec": {
        "acceptance_criteria": $criteria
      }
    }
  ]
}
EOF
}

# --- Input validation ---

@test "map-test-coverage: returns error when no arguments" {
  run bash "$SCRIPT"
  assert_success
  [ "$(echo "$output" | jq -r '.mapped')" = "false" ]
  assert_output --partial "Usage"
}

@test "map-test-coverage: returns error when backlog missing" {
  run bash "$SCRIPT" "$PLAN_FILE" "/nonexistent/backlog.json" "feat-001"
  assert_success
  [ "$(echo "$output" | jq -r '.mapped')" = "false" ]
}

# --- Test framework detection ---

@test "map-test-coverage: detects vitest framework" {
  create_backlog_with_criteria '["THE SYSTEM SHALL display a login form"]'
  touch "$TEST_PROJECT_DIR/vitest.config.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.framework')" = "vitest" ]
}

@test "map-test-coverage: detects jest framework" {
  create_backlog_with_criteria '["THE SYSTEM SHALL validate email"]'
  touch "$TEST_PROJECT_DIR/jest.config.js"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.framework')" = "jest" ]
}

@test "map-test-coverage: detects bats framework" {
  create_backlog_with_criteria '["THE SYSTEM SHALL validate input"]'
  mkdir -p "$TEST_PROJECT_DIR/tests"
  touch "$TEST_PROJECT_DIR/tests/example.bats"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.framework')" = "bats" ]
}

@test "map-test-coverage: reports unknown when no test framework" {
  create_backlog_with_criteria '["THE SYSTEM SHALL display data"]'
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.framework')" = "unknown" ]
}

# --- Criteria mapping ---

@test "map-test-coverage: reports zero criteria when none in backlog" {
  create_backlog_with_criteria '[]'
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.criteria_count')" = "0" ]
}

@test "map-test-coverage: identifies gaps when no matching tests" {
  create_backlog_with_criteria '["WHEN the user clicks Login THE SYSTEM SHALL authenticate", "THE SYSTEM SHALL display an error on invalid credentials"]'
  touch "$TEST_PROJECT_DIR/vitest.config.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.mapped')" = "true" ]
  [ "$(echo "$output" | jq -r '.gaps')" -ge 1 ]
}

@test "map-test-coverage: generates Wave 0 tasks for gaps" {
  create_backlog_with_criteria '["WHEN the user clicks Submit THE SYSTEM SHALL save data"]'
  touch "$TEST_PROJECT_DIR/vitest.config.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  WAVE_COUNT=$(echo "$output" | jq '.wave_zero_tasks | length')
  [ "$WAVE_COUNT" -ge 1 ]
  assert_output --partial "Wave 0"
}

@test "map-test-coverage: Wave 0 tasks reference the framework" {
  create_backlog_with_criteria '["THE SYSTEM SHALL validate input"]'
  touch "$TEST_PROJECT_DIR/vitest.config.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.wave_zero_tasks[0].framework')" = "vitest" ]
}

# --- Coverage detection ---

@test "map-test-coverage: detects covered criteria when matching test exists" {
  create_backlog_with_criteria '["WHEN the user clicks login THE SYSTEM SHALL authenticate"]'
  touch "$TEST_PROJECT_DIR/vitest.config.ts"
  mkdir -p "$TEST_PROJECT_DIR/src"
  cat > "$TEST_PROJECT_DIR/src/login.test.ts" <<'TESTEOF'
describe('login', () => {
  it('should authenticate user on click login', () => {})
})
TESTEOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq -r '.covered')" -ge 1 ]
}

# --- Output format ---

@test "map-test-coverage: output is valid JSON" {
  create_backlog_with_criteria '["THE SYSTEM SHALL display data"]'
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  echo "$output" | jq empty
}

@test "map-test-coverage: includes coverage_percent field" {
  create_backlog_with_criteria '["THE SYSTEM SHALL render"]'
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
  [ "$(echo "$output" | jq 'has("coverage_percent")')" = "true" ]
}

@test "map-test-coverage: always exits 0 (advisory)" {
  create_backlog_with_criteria '["THE SYSTEM SHALL work"]'
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$PLAN_FILE' '$VIBECREW_DIR/backlog.json' 'feat-001' '$TEST_PROJECT_DIR'"
  assert_success
}
