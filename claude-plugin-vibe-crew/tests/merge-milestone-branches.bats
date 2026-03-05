#!/usr/bin/env bats
# Tests for scripts/merge-milestone-branches.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/merge-milestone-branches.sh"

setup() {
  setup_vibecrew_dir

  # Create initial commit on main
  echo "initial" > "$TEST_PROJECT_DIR/README.md"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  # Create feature branch
  git -C "$TEST_PROJECT_DIR" checkout -b feat/test-feature >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

# --- Error handling ---

@test "merge-milestone-branches: fails without feature branch arg" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
}

@test "merge-milestone-branches: fails with no milestone branches" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat/test-feature"
  assert_failure
}

# --- Successful merge ---

@test "merge-milestone-branches: merges a single milestone branch" {
  # Create milestone branch with a change
  git -C "$TEST_PROJECT_DIR" checkout -b milestone-backend >/dev/null 2>&1
  echo "backend code" > "$TEST_PROJECT_DIR/backend.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add backend" >/dev/null 2>&1

  # Go back to feature branch
  git -C "$TEST_PROJECT_DIR" checkout feat/test-feature >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat/test-feature milestone-backend"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.merged')" = "1" ]
  [ "$(echo "$output" | jq '.conflicts')" = "0" ]
  [ "$(echo "$output" | jq -r '.results[0].status')" = "merged" ]
  # Verify file exists on feature branch
  [ -f "$TEST_PROJECT_DIR/backend.ts" ]
}

@test "merge-milestone-branches: merges multiple non-conflicting branches" {
  # Create first milestone branch
  git -C "$TEST_PROJECT_DIR" checkout -b milestone-backend >/dev/null 2>&1
  echo "backend code" > "$TEST_PROJECT_DIR/backend.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add backend" >/dev/null 2>&1

  # Create second milestone branch from feature branch
  git -C "$TEST_PROJECT_DIR" checkout feat/test-feature >/dev/null 2>&1
  git -C "$TEST_PROJECT_DIR" checkout -b milestone-frontend >/dev/null 2>&1
  echo "frontend code" > "$TEST_PROJECT_DIR/frontend.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add frontend" >/dev/null 2>&1

  # Go back to feature branch
  git -C "$TEST_PROJECT_DIR" checkout feat/test-feature >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat/test-feature milestone-backend milestone-frontend"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.merged')" = "2" ]
  [ "$(echo "$output" | jq '.conflicts')" = "0" ]
}

# --- Nonexistent branch ---

@test "merge-milestone-branches: reports not_found for missing branch" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat/test-feature nonexistent-branch"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.results[0].status')" = "not_found" ]
  [ "$(echo "$output" | jq '.merged')" = "0" ]
}

# --- Conflict handling ---

@test "merge-milestone-branches: detects and aborts on merge conflict" {
  # Create milestone branch that modifies README
  git -C "$TEST_PROJECT_DIR" checkout -b milestone-a >/dev/null 2>&1
  echo "version A" > "$TEST_PROJECT_DIR/README.md"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "milestone a change" >/dev/null 2>&1

  # Create conflicting change on feature branch
  git -C "$TEST_PROJECT_DIR" checkout feat/test-feature >/dev/null 2>&1
  echo "version B" > "$TEST_PROJECT_DIR/README.md"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "feature change" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat/test-feature milestone-a"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq '.conflicts')" = "1" ]
  [ "$(echo "$output" | jq -r '.results[0].status')" = "conflict" ]

  # Verify merge was aborted cleanly (no conflict markers)
  ! grep -q "<<<<<<" "$TEST_PROJECT_DIR/README.md" 2>/dev/null
}

# --- JSON output structure ---

@test "merge-milestone-branches: returns complete JSON structure" {
  git -C "$TEST_PROJECT_DIR" checkout -b milestone-test >/dev/null 2>&1
  echo "test" > "$TEST_PROJECT_DIR/test.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "test" >/dev/null 2>&1
  git -C "$TEST_PROJECT_DIR" checkout feat/test-feature >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' feat/test-feature milestone-test"
  assert_success
  echo "$output" | jq empty
  echo "$output" | jq -e '.feature_branch' >/dev/null
  echo "$output" | jq -e '.merged' >/dev/null
  echo "$output" | jq -e '.conflicts' >/dev/null
  echo "$output" | jq -e '.results' >/dev/null
  [ "$(echo "$output" | jq -r '.feature_branch')" = "feat/test-feature" ]
}
