#!/usr/bin/env bats
# tests/calculate-vibe-score.bats
# Tests for scripts/calculate-vibe-score.sh — Vibe Score metric gathering

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/calculate-vibe-score.sh"
  setup_vibecrew_dir
  set_foundation_complete

  # Create minimal package.json (no test/build/lint scripts by default)
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {}
}
EOF
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Basic output structure
# =============================================================================

@test "outputs valid JSON" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  echo "$output" | jq empty
}

@test "output contains all required fields" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success

  echo "$output" | jq -e '.tests_exist != null'
  echo "$output" | jq -e '.tests_passed != null'
  echo "$output" | jq -e '.test_count != null'
  echo "$output" | jq -e '.build_passes != null'
  echo "$output" | jq -e '.lint_clean != null'
  echo "$output" | jq -e '.has_spec != null'
  echo "$output" | jq -e '.all_phases_complete != null'
  echo "$output" | jq -e '.tdd_detected != null'
  echo "$output" | jq -e '.e2e_exists != null'
  echo "$output" | jq -e '.a11y_exists != null'
  echo "$output" | jq -e '.visual_verified != null'
  echo "$output" | jq -e '.review_completed != null'
  echo "$output" | jq -e '.perf_baselines_exist != null'
}

# =============================================================================
# Test detection
# =============================================================================

@test "tests_exist: false when no test files" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.tests_exist')
  [ "$val" = "false" ]
}

@test "tests_exist: true when test files present" {
  mkdir -p "$TEST_PROJECT_DIR/src/__tests__"
  echo "test('placeholder', () => {})" > "$TEST_PROJECT_DIR/src/__tests__/app.test.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.tests_exist')
  [ "$val" = "true" ]
}

# =============================================================================
# Build detection
# =============================================================================

@test "build_passes: true when no build script exists" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.build_passes')
  [ "$val" = "true" ]
}

@test "build_passes: true when build succeeds" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": { "build": "echo ok" }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.build_passes')
  [ "$val" = "true" ]
}

@test "build_passes: false when build fails" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": { "build": "exit 1" }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.build_passes')
  [ "$val" = "false" ]
}

# =============================================================================
# Lint detection
# =============================================================================

@test "lint_clean: true when no lint script exists" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.lint_clean')
  [ "$val" = "true" ]
}

@test "lint_clean: true when lint succeeds" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": { "lint": "echo ok" }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.lint_clean')
  [ "$val" = "true" ]
}

@test "lint_clean: false when lint fails" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": { "lint": "exit 1" }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.lint_clean')
  [ "$val" = "false" ]
}

# =============================================================================
# Feature spec detection
# =============================================================================

@test "has_spec: false when no active feature" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.has_spec')
  [ "$val" = "false" ]
}

@test "has_spec: true when active feature has acceptance criteria" {
  set_active_feature "feat-001" "Test Feature" "code"
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  # Add acceptance criteria to the feature
  jq '.features[0].spec.acceptance_criteria = ["User can log in", "User sees dashboard"]' \
    "$VIBECREW_DIR/backlog.json" > "$VIBECREW_DIR/backlog.json.tmp" \
    && mv "$VIBECREW_DIR/backlog.json.tmp" "$VIBECREW_DIR/backlog.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.has_spec')
  [ "$val" = "true" ]
}

# =============================================================================
# Foundation phase tracking
# =============================================================================

@test "all_phases_complete: true when foundation is complete" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.all_phases_complete')
  [ "$val" = "true" ]
}

@test "all_phases_complete: false when foundation is incomplete" {
  jq '.foundation.complete = false' "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.all_phases_complete')
  [ "$val" = "false" ]
}

# =============================================================================
# E2E detection
# =============================================================================

@test "e2e_exists: false when no e2e files" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.e2e_exists')
  [ "$val" = "false" ]
}

@test "e2e_exists: true when e2e spec files present" {
  mkdir -p "$TEST_PROJECT_DIR/e2e"
  echo "test('placeholder')" > "$TEST_PROJECT_DIR/e2e/login.spec.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.e2e_exists')
  [ "$val" = "true" ]
}

# =============================================================================
# A11y detection
# =============================================================================

@test "a11y_exists: false when no a11y reports" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.a11y_exists')
  [ "$val" = "false" ]
}

@test "a11y_clean: true when a11y report has zero violations" {
  mkdir -p "$VIBECREW_DIR/a11y"
  cat > "$VIBECREW_DIR/a11y/audit-2026-01-01.json" << 'EOF'
{
  "summary": { "critical": 0, "serious": 0, "moderate": 1, "minor": 0 }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local exists clean
  exists=$(echo "$output" | jq '.a11y_exists')
  clean=$(echo "$output" | jq '.a11y_clean')
  [ "$exists" = "true" ]
  [ "$clean" = "true" ]
}

@test "a11y_clean: false when a11y report has critical violations" {
  mkdir -p "$VIBECREW_DIR/a11y"
  cat > "$VIBECREW_DIR/a11y/audit-2026-01-01.json" << 'EOF'
{
  "summary": { "critical": 2, "serious": 0, "moderate": 0, "minor": 0 }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local clean
  clean=$(echo "$output" | jq '.a11y_clean')
  [ "$clean" = "false" ]
}

# =============================================================================
# Visual verification detection
# =============================================================================

@test "visual_verified: false when no builder signal" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local val
  val=$(echo "$output" | jq '.visual_verified')
  [ "$val" = "false" ]
}

@test "visual_verified: true with clean visual verification" {
  cat > "$VIBECREW_DIR/signals/builder-complete.signal" << 'EOF'
{
  "feature_id": "feat-001",
  "visual_verification": {
    "skipped": false,
    "console_errors": 0,
    "token_violations": 0
  }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local verified clean
  verified=$(echo "$output" | jq '.visual_verified')
  clean=$(echo "$output" | jq '.visual_clean')
  [ "$verified" = "true" ]
  [ "$clean" = "true" ]
}

@test "visual_clean: false when console errors detected" {
  cat > "$VIBECREW_DIR/signals/builder-complete.signal" << 'EOF'
{
  "feature_id": "feat-001",
  "visual_verification": {
    "skipped": false,
    "console_errors": 3,
    "token_violations": 0
  }
}
EOF
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local clean errors
  clean=$(echo "$output" | jq '.visual_clean')
  errors=$(echo "$output" | jq '.visual_console_errors')
  [ "$clean" = "false" ]
  [ "$errors" = "3" ]
}

# =============================================================================
# No package.json (non-Node project)
# =============================================================================

@test "handles missing package.json gracefully" {
  rm -f "$TEST_PROJECT_DIR/package.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  echo "$output" | jq empty
  local build lint
  build=$(echo "$output" | jq '.build_passes')
  lint=$(echo "$output" | jq '.lint_clean')
  [ "$build" = "true" ]
  [ "$lint" = "true" ]
}
