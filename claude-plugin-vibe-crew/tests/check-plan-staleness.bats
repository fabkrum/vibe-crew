#!/usr/bin/env bats

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/check-plan-staleness.sh"

setup() {
  setup_vibecrew_dir

  # Create a sample plan with structured tasks
  mkdir -p "$TEST_PROJECT_DIR/docs/features/auth"
  mkdir -p "$TEST_PROJECT_DIR/src/api"
  mkdir -p "$TEST_PROJECT_DIR/src/models"
  mkdir -p "$TEST_PROJECT_DIR/prisma"

  # Create files referenced by the plan
  echo "// auth route" > "$TEST_PROJECT_DIR/src/api/auth.ts"
  echo "// user model" > "$TEST_PROJECT_DIR/src/models/user.ts"
  echo "// prisma schema" > "$TEST_PROJECT_DIR/prisma/schema.prisma"

  # Commit initial state
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "initial" --quiet

  # Write plan with structured task format
  cat > "$TEST_PROJECT_DIR/docs/features/auth/plan.md" <<'PLAN'
# Auth Feature Plan

## Overview
Implement authentication with JWT tokens.

## Tasks

### Task 1: Create auth API route
- **Files**: `src/api/auth.ts` (modify), `src/models/user.ts` (modify)
- **Action**: Add login and register endpoints
- **Verify**: `npm run typecheck`
- **Done when**: Auth endpoints respond to POST requests

### Task 2: Update database schema
- **Files**: `prisma/schema.prisma` (modify)
- **Action**: Add Session model with token field
- **Verify**: `npx prisma validate`
- **Done when**: Schema validates without errors
PLAN

  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add plan" --quiet

  # Record the plan SHA
  PLAN_SHA=$(git -C "$TEST_PROJECT_DIR" rev-parse HEAD)
  PLAN_FILE="$TEST_PROJECT_DIR/docs/features/auth/plan.md"

  export PLAN_SHA PLAN_FILE
}

teardown() {
  teardown_vibecrew_dir
}

# === Error cases ===

@test "missing plan file → stale: false with error" {
  run bash "$SCRIPT" "/nonexistent/plan.md" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty  # valid JSON
  [ "$(echo "$output" | jq -r '.stale')" = "false" ]
  [ "$(echo "$output" | jq -r '.error')" != "null" ]
  echo "$output" | jq -r '.error' | grep -qi "not found"
}

@test "missing/invalid SHA → stale: false with error" {
  run bash "$SCRIPT" "$PLAN_FILE" "invalid_sha_abc123"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "false" ]
  [ "$(echo "$output" | jq -r '.error')" != "null" ]
  echo "$output" | jq -r '.error' | grep -qi "invalid"
}

@test "no args → stale: false with error" {
  run bash "$SCRIPT"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "false" ]
  [ "$(echo "$output" | jq -r '.error')" != "null" ]
}

# === No changes ===

@test "no changes since plan → stale: false, severity: none" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" "$PLAN_FILE" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "false" ]
  [ "$(echo "$output" | jq -r '.severity')" = "none" ]
  [ "$(echo "$output" | jq -r '.recommendation')" = "proceed" ]
}

# === Minor changes ===

@test "single file changed (minor) → stale: true, severity: minor" {
  cd "$TEST_PROJECT_DIR"

  # Modify one plan-referenced file
  echo "// updated auth route" >> "$TEST_PROJECT_DIR/src/api/auth.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "update auth route" --quiet

  run bash "$SCRIPT" "$PLAN_FILE" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "true" ]
  [ "$(echo "$output" | jq -r '.severity')" = "minor" ]
  [ "$(echo "$output" | jq -r '.recommendation')" = "review_changes" ]
  [ "$(echo "$output" | jq '.affected_files | length')" = "1" ]
  [ "$(echo "$output" | jq -r '.affected_files[0].path')" = "src/api/auth.ts" ]
  [ "$(echo "$output" | jq -r '.affected_files[0].change_type')" = "modified" ]
}

# === Major changes ===

@test "multiple files changed (major) → stale: true, severity: major" {
  cd "$TEST_PROJECT_DIR"

  # Modify 3+ plan-referenced files
  echo "// updated" >> "$TEST_PROJECT_DIR/src/api/auth.ts"
  echo "// updated" >> "$TEST_PROJECT_DIR/src/models/user.ts"
  echo "// updated" >> "$TEST_PROJECT_DIR/prisma/schema.prisma"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "update multiple files" --quiet

  run bash "$SCRIPT" "$PLAN_FILE" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "true" ]
  [ "$(echo "$output" | jq -r '.severity')" = "major" ]
  [ "$(echo "$output" | jq -r '.recommendation')" = "refresh_plan" ]
  [ "$(echo "$output" | jq '.affected_files | length')" = "3" ]
}

# === Critical changes ===

@test "deleted plan file (critical) → stale: true, severity: critical" {
  cd "$TEST_PROJECT_DIR"

  # Delete a plan-referenced file
  git -C "$TEST_PROJECT_DIR" rm "$TEST_PROJECT_DIR/src/api/auth.ts" --quiet
  git -C "$TEST_PROJECT_DIR" commit -m "delete auth route" --quiet

  run bash "$SCRIPT" "$PLAN_FILE" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "true" ]
  [ "$(echo "$output" | jq -r '.severity')" = "critical" ]
  [ "$(echo "$output" | jq -r '.recommendation')" = "refresh_plan" ]
  echo "$output" | jq -r '.affected_files[] | select(.change_type == "deleted") | .path' | grep -q "src/api/auth.ts"
}

# === Filtering ===

@test "changed files NOT in plan → stale: false" {
  cd "$TEST_PROJECT_DIR"

  # Modify a file NOT referenced in the plan
  echo "// new file" > "$TEST_PROJECT_DIR/src/api/other.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add unrelated file" --quiet

  run bash "$SCRIPT" "$PLAN_FILE" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "false" ]
  [ "$(echo "$output" | jq -r '.severity')" = "none" ]
}

# === Format parsing ===

@test "structured task format parsing → extracts files from Task blocks" {
  cd "$TEST_PROJECT_DIR"

  # Modify a file referenced only via structured tasks
  echo "// session model" >> "$TEST_PROJECT_DIR/prisma/schema.prisma"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "update schema" --quiet

  run bash "$SCRIPT" "$PLAN_FILE" "$PLAN_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "true" ]
  echo "$output" | jq -r '.affected_files[].path' | grep -q "prisma/schema.prisma"
}

@test "legacy plan format parsing → extracts files from Files to Create/Modify tables" {
  cd "$TEST_PROJECT_DIR"

  # Write a plan with legacy table format
  cat > "$TEST_PROJECT_DIR/docs/features/auth/plan.md" <<'PLAN'
# Legacy Plan

## Files to Create

| File | Purpose |
|------|---------|
| `src/api/auth.ts` | Auth endpoints |

## Files to Modify

| File | Change |
|------|--------|
| `src/models/user.ts` | Add password field |

## Implementation Details
...
PLAN

  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "update plan format" --quiet

  # Modify a file from the legacy table
  echo "// updated" >> "$TEST_PROJECT_DIR/src/models/user.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "update user model" --quiet

  LEGACY_SHA=$(git -C "$TEST_PROJECT_DIR" rev-parse HEAD~1)
  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/features/auth/plan.md" "$LEGACY_SHA"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.stale')" = "true" ]
  echo "$output" | jq -r '.affected_files[].path' | grep -q "src/models/user.ts"
}

# === Exit code ===

@test "always exits 0 (informational) → even with invalid inputs" {
  # Missing args
  run bash "$SCRIPT"
  assert_success

  # Invalid file
  run bash "$SCRIPT" "/nonexistent" "abc123"
  assert_success

  # Invalid SHA
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPT" "$PLAN_FILE" "not_a_real_sha"
  assert_success
}
