#!/usr/bin/env bats
# Tests for scripts/extract-plan-tasks.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/extract-plan-tasks.sh"

setup() {
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Missing / empty ---

@test "extract-plan-tasks: returns structured false when file missing" {
  run bash "$SCRIPT" "$TEST_PROJECT_DIR/nonexistent.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "false" ]
  [ "$(echo "$output" | jq '.tasks | length')" = "0" ]
}

@test "extract-plan-tasks: returns structured false for legacy plan" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
## Approach
Just build it.

## Files to Create
- src/app.ts
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "false" ]
}

# --- Structured extraction ---

@test "extract-plan-tasks: extracts tasks with all fields" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
## Tasks

### Task 1: Create database schema
- **Files**: `prisma/schema.prisma` (modify)
- **Action**: Add User and Session models with email field
- **Verify**: `npx prisma validate`
- **Done when**: Schema validates without errors

### Task 2: Implement endpoints
- **Files**: `src/api/auth.ts` (create), `src/api/index.ts` (modify)
- **Action**: Create login and register endpoints
- **Verify**: `npm test -- auth`
- **Done when**: All auth tests pass
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "true" ]
  [ "$(echo "$output" | jq '.tasks | length')" = "2" ]

  # Check first task
  [ "$(echo "$output" | jq -r '.tasks[0].name')" = "Create database schema" ]
  [ "$(echo "$output" | jq '.tasks[0].index')" = "1" ]
  [ "$(echo "$output" | jq -r '.tasks[0].verify')" = "npx prisma validate" ]
  [ "$(echo "$output" | jq -r '.tasks[0].files[0].path')" = "prisma/schema.prisma" ]
  [ "$(echo "$output" | jq -r '.tasks[0].files[0].action')" = "modify" ]

  # Check second task has multiple files
  [ "$(echo "$output" | jq '.tasks[1].files | length')" = "2" ]
  [ "$(echo "$output" | jq -r '.tasks[1].files[0].action')" = "create" ]
}

@test "extract-plan-tasks: handles milestone filter flag" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Setup DB
- **Files**: `schema.prisma` (modify)
- **Action**: Add models
- **Verify**: `npx prisma validate`
- **Done when**: Validates
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md" --milestone "Backend API"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "true" ]
  [ "$(echo "$output" | jq -r '.milestone_filter')" = "Backend API" ]
}

@test "extract-plan-tasks: stops at non-task heading" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Only task
- **Files**: `src/app.ts` (create)
- **Action**: Create app entry point
- **Verify**: `npm run build`
- **Done when**: Build succeeds

## Testing Approach
This section is not a task.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  [ "$(echo "$output" | jq '.tasks | length')" = "1" ]
}
