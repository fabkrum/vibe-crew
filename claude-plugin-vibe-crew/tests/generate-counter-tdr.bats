#!/usr/bin/env bats
# tests/generate-counter-tdr.bats
# Tests for scripts/generate-counter-tdr.sh — TDR decision extraction for opponent processor

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "missing TDR file returns error JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  local err
  err=$(echo "$output" | jq -r '.error')
  [[ "$err" == *"TDR not found"* ]]
}

@test "empty TDR returns zero decisions" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  touch "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md"

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.decision_count')
  [[ "$count" == "0" ]]
}

@test "extracts framework decision" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md" <<'EOF'
# Technology Decision Record

## Framework

Chosen: Next.js

Next.js provides server-side rendering and great DX.
EOF

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  local category
  category=$(echo "$output" | jq -r '.decisions[0].category')
  [[ "$category" == "framework" ]]

  local chosen
  chosen=$(echo "$output" | jq -r '.decisions[0].chosen_option')
  [[ "$chosen" == *"Next.js"* ]]
}

@test "extracts multiple decisions" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md" <<'EOF'
# Technology Decision Record

## Framework

Chosen: Next.js

## Database

Chosen: PostgreSQL
EOF

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.decision_count')
  [[ "$count" -ge 2 ]]
}

@test "deduplicates by category" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md" <<'EOF'
# Technology Decision Record

## Framework Selection

Chosen: Next.js

## Framework Alternatives

Chosen: Remix
EOF

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  # Should only have one framework decision (first match kept)
  local framework_count
  framework_count=$(echo "$output" | jq '[.decisions[] | select(.category == "framework")] | length')
  [[ "$framework_count" == "1" ]]
}

@test "includes project name from VISION.md" {
  cd "$TEST_PROJECT_DIR"
  echo '# MyApp' > "$TEST_PROJECT_DIR/VISION.md"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  touch "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md"

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  local name
  name=$(echo "$output" | jq -r '.project_name')
  [[ "$name" == *"MyApp"* ]]
}

@test "falls back to directory name for project name" {
  cd "$TEST_PROJECT_DIR"
  # No VISION.md
  mkdir -p "$TEST_PROJECT_DIR/docs"
  touch "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md"

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success

  local name
  name=$(echo "$output" | jq -r '.project_name')
  local expected_name
  expected_name=$(basename "$TEST_PROJECT_DIR")
  [[ "$name" == "$expected_name" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  touch "$TEST_PROJECT_DIR/docs/tdr-001-tech-stack.md"

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success
  echo "$output" | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"
  # No TDR file, no VISION.md — should still exit 0

  run bash "$SCRIPTS_DIR/generate-counter-tdr.sh"
  assert_success
}
