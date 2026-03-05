#!/usr/bin/env bats
# Tests for scripts/validate-plan.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/validate-plan.sh"

setup() {
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Missing file ---

@test "validate-plan: returns error JSON when plan file is missing" {
  run bash "$SCRIPT" "$TEST_PROJECT_DIR/nonexistent.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.valid')" = "false" ]
  [ "$(echo "$output" | jq '.task_count')" = "0" ]
}

@test "validate-plan: returns error JSON when no argument given" {
  run bash "$SCRIPT"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.valid')" = "false" ]
}

# --- Legacy plan (no structured tasks) ---

@test "validate-plan: detects legacy plan without structured tasks" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
## Approach
Build the widget using React.

## Files to Create
- src/Widget.tsx

## Testing Approach
Unit tests with Vitest.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "false" ]
  [ "$(echo "$output" | jq '.task_count')" = "0" ]
}

# --- Structured plan ---

@test "validate-plan: counts structured tasks correctly" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
## Approach
Build the widget.

## Tasks

### Task 1: Create database schema
- **Files**: `prisma/schema.prisma` (modify)
- **Action**: Add User and Session models
- **Verify**: `npx prisma validate`
- **Done when**: Schema validates without errors

### Task 2: Implement auth endpoints
- **Files**: `src/api/auth.ts` (create), `src/api/index.ts` (modify)
- **Action**: Create login and register endpoints
- **Verify**: `npm run build && npm test -- auth`
- **Done when**: All auth tests pass

### Task 3: Add middleware
- **Files**: `src/middleware.ts` (create)
- **Action**: Create auth middleware
- **Verify**: `npm run build`
- **Done when**: Middleware correctly protects routes
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "true" ]
  [ "$(echo "$output" | jq '.task_count')" = "3" ]
  [ "$(echo "$output" | jq '.missing_field_count')" = "0" ]
}

@test "validate-plan: detects missing required fields" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
## Tasks

### Task 1: Create schema
- **Files**: `schema.prisma` (modify)
- **Action**: Add models

### Task 2: Implement endpoints
- **Action**: Create endpoints
- **Verify**: `npm test`
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "true" ]
  [ "$(echo "$output" | jq '.task_count')" = "2" ]
  [ "$(echo "$output" | jq '.missing_field_count')" -gt 0 ]
  # Task 1 missing Verify and Done when; Task 2 missing Files and Done when
  MISSING=$(echo "$output" | jq '.missing_fields | length')
  [ "$MISSING" -gt 0 ]
}

@test "validate-plan: always exits 0 even with missing fields" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Incomplete task
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
}
