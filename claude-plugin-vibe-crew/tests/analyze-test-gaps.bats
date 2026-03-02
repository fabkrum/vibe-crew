#!/usr/bin/env bats
# tests/analyze-test-gaps.bats
# Tests for scripts/analyze-test-gaps.sh — source vs test file gap analysis

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "empty project: zero source files" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.source_file_count')
  [[ "$count" == "0" ]]
}

@test "source file without test: listed as untested" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo 'export const x = 1;' > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add app" --allow-empty >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local untested_count
  untested_count=$(echo "$output" | jq '.untested_count')
  [[ "$untested_count" -ge 1 ]]

  # app.ts should appear in untested modules
  echo "$output" | jq -e '.untested_modules[] | select(test("app\\.ts"))' >/dev/null
}

@test "test files counted separately from source files" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo 'export const x = 1;' > "$TEST_PROJECT_DIR/src/utils.ts"
  echo 'test("x", () => {});' > "$TEST_PROJECT_DIR/src/utils.test.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add utils" --allow-empty >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  # Source count should be 1 (utils.ts, NOT utils.test.ts)
  local src_count
  src_count=$(echo "$output" | jq '.source_file_count')
  [[ "$src_count" == "1" ]]

  # Test count should be 1 (utils.test.ts)
  local test_count
  test_count=$(echo "$output" | jq '.test_file_count')
  [[ "$test_count" == "1" ]]
}

@test "detects vitest framework from config file" {
  cd "$TEST_PROJECT_DIR"
  echo 'export default {};' > "$TEST_PROJECT_DIR/vitest.config.ts"

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local fw
  fw=$(echo "$output" | jq -r '.test_framework')
  [[ "$fw" == "vitest" ]]
}

@test "detects jest framework from package.json" {
  cd "$TEST_PROJECT_DIR"
  cat > "$TEST_PROJECT_DIR/package.json" <<'EOF'
{"name":"test","devDependencies":{"jest":"^29.0.0"}}
EOF

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local fw
  fw=$(echo "$output" | jq -r '.test_framework')
  [[ "$fw" == "jest" ]]
}

@test "detects playwright e2e framework" {
  cd "$TEST_PROJECT_DIR"
  echo 'export default {};' > "$TEST_PROJECT_DIR/playwright.config.ts"

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local e2e
  e2e=$(echo "$output" | jq -r '.e2e_framework')
  [[ "$e2e" == "playwright" ]]
}

@test "untested list capped at 20" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  for i in $(seq 1 25); do
    printf -v padded "%03d" "$i"
    echo "export const x$i = $i;" > "$TEST_PROJECT_DIR/src/mod$padded.ts"
  done
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add modules" --allow-empty >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local len
  len=$(echo "$output" | jq '.untested_modules | length')
  [[ "$len" -le 20 ]]
}

@test "calculates coverage estimate" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  # 5 source files, 3 with matching tests
  for i in 1 2 3 4 5; do
    echo "export const x$i = $i;" > "$TEST_PROJECT_DIR/src/mod$i.ts"
  done
  for i in 1 2 3; do
    echo "test('x', () => {});" > "$TEST_PROJECT_DIR/src/mod$i.test.ts"
  done
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add modules" --allow-empty >/dev/null 2>&1

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success

  local cov
  cov=$(echo "$output" | jq '.coverage_estimate_percent')
  # Should be a number (not null since there are source files)
  [[ "$cov" != "null" ]]
  echo "$cov" | grep -qE '^[0-9]+(\.[0-9]+)?$'
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success
  echo "$output" | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/analyze-test-gaps.sh"
  assert_success
}
