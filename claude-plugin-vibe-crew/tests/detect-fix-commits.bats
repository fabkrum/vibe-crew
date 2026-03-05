#!/usr/bin/env bats
# tests/detect-fix-commits.bats
# Unit tests for scripts/detect-fix-commits.sh

load 'test_helper/common-setup'

setup() {
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/detect-fix-commits.sh"

  # Create a git history with various commit types
  cd "$TEST_PROJECT_DIR"
  echo "initial" > file.txt
  git add file.txt
  git commit -m "feat: initial setup" 2>/dev/null
}

teardown() {
  teardown_vibecrew_dir
}

run_detect() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' $*"
}

# =============================================================================
# Detection
# =============================================================================

@test "detects fix: commits in git log" {
  cd "$TEST_PROJECT_DIR"
  echo "fix1" > fix1.txt
  git add fix1.txt
  git commit -m "fix: handle null pointer in auth" 2>/dev/null

  run_detect
  assert_success

  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 1 ]

  local desc
  desc=$(echo "$output" | jq -r '.[0].description')
  [ "$desc" = "handle null pointer in auth" ]
}

@test "ignores non-fix commits" {
  cd "$TEST_PROJECT_DIR"
  echo "feat1" > feat1.txt
  git add feat1.txt
  git commit -m "feat: add new feature" 2>/dev/null

  echo "refactor1" > refactor1.txt
  git add refactor1.txt
  git commit -m "refactor: clean up code" 2>/dev/null

  echo "docs1" > docs1.txt
  git add docs1.txt
  git commit -m "docs: update README" 2>/dev/null

  run_detect
  assert_success

  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 0 ]
}

@test "flags fix commits without test file changes" {
  cd "$TEST_PROJECT_DIR"
  echo "bugfix" > src-file.ts
  git add src-file.ts
  git commit -m "fix(auth): handle special characters in password" 2>/dev/null

  run_detect
  assert_success

  local has_tests
  has_tests=$(echo "$output" | jq -r '.[0].has_test_changes')
  [ "$has_tests" = "false" ]
}

@test "skips fix commits that already have test changes" {
  cd "$TEST_PROJECT_DIR"
  echo "bugfix" > src-file.ts
  echo "test" > src-file.test.ts
  git add src-file.ts src-file.test.ts
  git commit -m "fix: handle edge case with tests" 2>/dev/null

  run_detect
  assert_success

  # Should be empty — commit has test changes
  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 0 ]
}

@test "parses issue numbers from fixes #N pattern" {
  cd "$TEST_PROJECT_DIR"
  echo "fix" > issue-fix.ts
  git add issue-fix.ts
  git commit -m "fix(auth): validate email format, fixes #42" 2>/dev/null

  run_detect
  assert_success

  local issue
  issue=$(echo "$output" | jq -r '.[0].issue_number')
  [ "$issue" = "42" ]
}

@test "parses scope from fix(scope): pattern" {
  cd "$TEST_PROJECT_DIR"
  echo "fix" > scoped.ts
  git add scoped.ts
  git commit -m "fix(billing): calculate tax correctly" 2>/dev/null

  run_detect
  assert_success

  local scope
  scope=$(echo "$output" | jq -r '.[0].scope')
  [ "$scope" = "billing" ]
}

@test "outputs empty array when no fix commits exist" {
  run_detect
  assert_success

  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" -eq 0 ]
}

@test "includes files_changed in output" {
  cd "$TEST_PROJECT_DIR"
  echo "a" > changed-a.ts
  echo "b" > changed-b.ts
  git add changed-a.ts changed-b.ts
  git commit -m "fix: correct calculation" 2>/dev/null

  run_detect
  assert_success

  local files_count
  files_count=$(echo "$output" | jq '.[0].files_changed | length')
  [ "$files_count" -eq 2 ]
}
