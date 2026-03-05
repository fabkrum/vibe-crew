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
  assert_failure
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.valid')" = "false" ]
  [ "$(echo "$output" | jq '.task_count')" = "0" ]
}

@test "validate-plan: returns error JSON when no argument given" {
  run bash "$SCRIPT"
  assert_failure
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
  assert_failure
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.structured')" = "true" ]
  [ "$(echo "$output" | jq '.task_count')" = "2" ]
  [ "$(echo "$output" | jq '.missing_field_count')" -gt 0 ]
  # Task 1 missing Verify and Done when; Task 2 missing Files and Done when
  MISSING=$(echo "$output" | jq '.missing_fields | length')
  [ "$MISSING" -gt 0 ]
}

@test "validate-plan: exits 1 when tasks have missing fields" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Incomplete task
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_failure
}

# --- EARS format validation ---

@test "validate-plan: detects EARS-format criteria when backlog provided" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Build widget
- **Files**: `src/Widget.tsx` (create)
- **Action**: Create widget
- **Verify**: `npm run build`
- **Done when**: Widget renders
EOF

  # Add feature with EARS criteria
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"
  jq '.features += [{
    "id": "feat-ears",
    "name": "EARS Test",
    "column": "planned",
    "spec": {
      "acceptance_criteria": [
        "WHEN the user clicks Submit THE SYSTEM SHALL validate all fields",
        "IF the API returns 429 THEN THE SYSTEM SHALL retry with backoff"
      ]
    }
  }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md" "$backlog_file" "feat-ears"
  assert_success
  local ears_count non_ears
  ears_count=$(echo "$output" | jq '.ears.ears_count')
  non_ears=$(echo "$output" | jq '.ears.non_ears_count')
  [ "$ears_count" = "2" ]
  [ "$non_ears" = "0" ]
}

@test "validate-plan: detects non-EARS criteria" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Build widget
- **Files**: `src/Widget.tsx` (create)
- **Action**: Create widget
- **Verify**: `npm run build`
- **Done when**: Widget renders
EOF

  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"
  jq '.features += [{
    "id": "feat-noears",
    "name": "No EARS",
    "column": "planned",
    "spec": {
      "acceptance_criteria": [
        "User can filter by status",
        "Page loads in under 2 seconds"
      ]
    }
  }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md" "$backlog_file" "feat-noears"
  assert_success
  local ears_count non_ears
  ears_count=$(echo "$output" | jq '.ears.ears_count')
  non_ears=$(echo "$output" | jq '.ears.non_ears_count')
  [ "$ears_count" = "0" ]
  [ "$non_ears" = "2" ]
}

@test "validate-plan: skips EARS check when no backlog provided" {
  cat > "$TEST_PROJECT_DIR/plan.md" <<'EOF'
### Task 1: Build widget
- **Files**: `src/Widget.tsx` (create)
- **Action**: Create widget
- **Verify**: `npm run build`
- **Done when**: Widget renders
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/plan.md"
  assert_success
  local ears_status
  ears_status=$(echo "$output" | jq -r '.ears.status')
  [ "$ears_status" = "skipped" ]
}
