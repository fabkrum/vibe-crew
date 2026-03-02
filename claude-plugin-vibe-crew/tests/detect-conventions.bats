#!/usr/bin/env bats
# tests/detect-conventions.bats
# Tests for scripts/detect-conventions.sh — coding convention detection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "detects JavaScript project with package.json" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local lang
  lang=$(echo "$output" | jq -r '.language')
  [[ "$lang" == "javascript" ]]
}

@test "detects TypeScript when tsconfig.json exists" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"
  echo '{"compilerOptions":{}}' > "$TEST_PROJECT_DIR/tsconfig.json"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local lang
  lang=$(echo "$output" | jq -r '.language')
  [[ "$lang" == "typescript" ]]
}

@test "detects npm package manager with package-lock.json" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"
  touch "$TEST_PROJECT_DIR/package-lock.json"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local pkg
  pkg=$(echo "$output" | jq -r '.package_manager')
  [[ "$pkg" == "npm" ]]
}

@test "detects yarn package manager" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"
  touch "$TEST_PROJECT_DIR/yarn.lock"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local pkg
  pkg=$(echo "$output" | jq -r '.package_manager')
  [[ "$pkg" == "yarn" ]]
}

@test "detects Python project" {
  cd "$TEST_PROJECT_DIR"
  touch "$TEST_PROJECT_DIR/requirements.txt"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local lang
  lang=$(echo "$output" | jq -r '.language')
  [[ "$lang" == "python" ]]
}

@test "detects Go project" {
  cd "$TEST_PROJECT_DIR"
  echo 'module example.com/test' > "$TEST_PROJECT_DIR/go.mod"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local lang
  lang=$(echo "$output" | jq -r '.language')
  [[ "$lang" == "go" ]]

  local indent
  indent=$(echo "$output" | jq -r '.indent')
  [[ "$indent" == "tabs" ]]

  local formatter
  formatter=$(echo "$output" | jq -r '.formatter')
  [[ "$formatter" == "gofmt" ]]
}

@test "detects Rust project" {
  cd "$TEST_PROJECT_DIR"
  echo '[package]' > "$TEST_PROJECT_DIR/Cargo.toml"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local lang
  lang=$(echo "$output" | jq -r '.language')
  [[ "$lang" == "rust" ]]

  local linter
  linter=$(echo "$output" | jq -r '.linter')
  [[ "$linter" == "clippy" ]]
}

@test "detects prettier formatter" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"
  echo '{}' > "$TEST_PROJECT_DIR/.prettierrc"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local formatter
  formatter=$(echo "$output" | jq -r '.formatter')
  [[ "$formatter" == "prettier" ]]
}

@test "detects eslint linter" {
  cd "$TEST_PROJECT_DIR"
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"
  echo '{}' > "$TEST_PROJECT_DIR/.eslintrc.json"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local linter
  linter=$(echo "$output" | jq -r '.linter')
  [[ "$linter" == "eslint" ]]
}

@test "detects conventional commit format" {
  cd "$TEST_PROJECT_DIR"
  # Create multiple conventional commits
  for i in 1 2 3 4 5 6 7 8 9 10; do
    echo "file$i" > "$TEST_PROJECT_DIR/file$i.txt"
    git -C "$TEST_PROJECT_DIR" add "file$i.txt"
    git -C "$TEST_PROJECT_DIR" commit -m "feat(scope): add feature $i" --allow-empty >/dev/null 2>&1
  done

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local commit_fmt
  commit_fmt=$(echo "$output" | jq -r '.commit_format')
  [[ "$commit_fmt" == "conventional" ]]
}

@test "detects freeform commit format" {
  cd "$TEST_PROJECT_DIR"
  # Create non-conventional commits
  for i in 1 2 3 4 5; do
    echo "file$i" > "$TEST_PROJECT_DIR/file$i.txt"
    git -C "$TEST_PROJECT_DIR" add "file$i.txt"
    git -C "$TEST_PROJECT_DIR" commit -m "added feature $i" --allow-empty >/dev/null 2>&1
  done

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local commit_fmt
  commit_fmt=$(echo "$output" | jq -r '.commit_format')
  [[ "$commit_fmt" == "freeform" ]]
}

@test "detects CI when .github/workflows exists" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/.github/workflows"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local ci
  ci=$(echo "$output" | jq '.ci')
  [[ "$ci" == "true" ]]
}

@test "no project files returns unknown language" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success

  local lang
  lang=$(echo "$output" | jq -r '.language')
  [[ "$lang" == "unknown" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/detect-conventions.sh"
  assert_success
  echo "$output" | jq empty
}
