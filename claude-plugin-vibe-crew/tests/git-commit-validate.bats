#!/usr/bin/env bats
# tests/git-commit-validate.bats
# Tests for scripts/git-commit-validate.sh — conventional commit validation

setup() {
  load 'test_helper/common-setup'
}

@test "valid feat commit" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feat: add login page"
  assert_success

  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]

  local type
  type=$(echo "$output" | jq -r '.type')
  [[ "$type" == "feat" ]]
}

@test "valid feat with scope" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feat(auth): add login page"
  assert_success

  local scope
  scope=$(echo "$output" | jq -r '.scope')
  [[ "$scope" == "auth" ]]
}

@test "valid fix commit" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "fix: resolve null pointer"
  assert_success
  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]
}

@test "valid docs commit" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "docs: update README"
  assert_success
  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]
}

@test "valid refactor commit" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "refactor: extract helper function"
  assert_success
  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]
}

@test "valid test commit" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "test: add unit tests for auth"
  assert_success
  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]
}

@test "valid chore commit" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "chore: update dependencies"
  assert_success
  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]
}

@test "invalid: subject too long" {
  local long_msg="feat: $(printf 'a%.0s' {1..80})"
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "$long_msg"
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "exceeds 72 characters"
}

@test "invalid: unknown type" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feature: add login"
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "not valid"
}

@test "invalid: description starts uppercase" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feat: Add login page"
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "lowercase"
}

@test "invalid: description ends with period" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feat: add login page."
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "period"
}

@test "invalid: not conventional format" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "added new feature"
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "conventional commit"
}

@test "invalid: empty message" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" ""
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "empty"
}

@test "reads from stdin" {
  run bash -c "echo 'feat: add feature' | bash '$SCRIPTS_DIR/git-commit-validate.sh'"
  assert_success

  local valid
  valid=$(echo "$output" | jq '.valid')
  [[ "$valid" == "true" ]]
}

@test "output is valid JSON" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feat: test"
  assert_success
  echo "$output" | jq empty
}

@test "invalid: missing space after colon" {
  run bash "$SCRIPTS_DIR/git-commit-validate.sh" "feat:no space"
  assert_failure

  echo "$output" | jq -r '.issues[]' | grep -q "missing"
}
