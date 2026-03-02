#!/usr/bin/env bats
# tests/diff-review-findings.bats
# Tests for scripts/diff-review-findings.sh — review findings diff

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# Argument validation
# =============================================================================

@test "missing current file argument exits 1" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/diff-review-findings.sh"
  assert_failure
}

@test "current file not found exits 1" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$TEST_PROJECT_DIR/nonexistent.json"
  assert_failure
}

# =============================================================================
# No previous file
# =============================================================================

@test "no previous file: all findings are new" {
  cd "$TEST_PROJECT_DIR"

  local current="$TEST_PROJECT_DIR/current-review.json"
  cat > "$current" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "null check"},
    {"id": "finding-B", "type": "perf", "message": "N+1 query"},
    {"id": "finding-C", "type": "style", "message": "naming"}
  ]
}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current"
  assert_success

  local has_previous
  has_previous=$(echo "$output" | jq '.has_previous')
  [[ "$has_previous" == "false" ]]

  local new_count
  new_count=$(echo "$output" | jq '.new_count')
  [[ "$new_count" == "3" ]]

  local resolved_count
  resolved_count=$(echo "$output" | jq '.resolved_count')
  [[ "$resolved_count" == "0" ]]
}

@test "previous file not found: all findings are new" {
  cd "$TEST_PROJECT_DIR"

  local current="$TEST_PROJECT_DIR/current-review.json"
  cat > "$current" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "null check"}
  ]
}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current" "$TEST_PROJECT_DIR/nonexistent-prev.json"
  assert_success

  local has_previous
  has_previous=$(echo "$output" | jq '.has_previous')
  [[ "$has_previous" == "false" ]]

  local new_count
  new_count=$(echo "$output" | jq '.new_count')
  [[ "$new_count" == "1" ]]
}

# =============================================================================
# Diff computation
# =============================================================================

@test "new findings detected" {
  cd "$TEST_PROJECT_DIR"

  local current="$TEST_PROJECT_DIR/current-review.json"
  local previous="$TEST_PROJECT_DIR/previous-review.json"

  cat > "$current" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "old bug"},
    {"id": "finding-B", "type": "perf", "message": "new perf issue"},
    {"id": "finding-C", "type": "style", "message": "new style issue"}
  ]
}
EOF

  cat > "$previous" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "old bug"}
  ]
}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current" "$previous"
  assert_success

  local new_count
  new_count=$(echo "$output" | jq '.new_count')
  [[ "$new_count" == "2" ]]

  # new array should contain finding-B and finding-C
  local has_b
  has_b=$(echo "$output" | jq '[.new[] | select(. == "finding-B")] | length')
  [[ "$has_b" == "1" ]]

  local has_c
  has_c=$(echo "$output" | jq '[.new[] | select(. == "finding-C")] | length')
  [[ "$has_c" == "1" ]]
}

@test "recurring findings detected" {
  cd "$TEST_PROJECT_DIR"

  local current="$TEST_PROJECT_DIR/current-review.json"
  local previous="$TEST_PROJECT_DIR/previous-review.json"

  cat > "$current" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "still here"},
    {"id": "finding-B", "type": "perf", "message": "still here too"}
  ]
}
EOF

  cat > "$previous" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "was here"},
    {"id": "finding-B", "type": "perf", "message": "was here too"},
    {"id": "finding-C", "type": "style", "message": "gone now"}
  ]
}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current" "$previous"
  assert_success

  local recurring_count
  recurring_count=$(echo "$output" | jq '.recurring_count')
  [[ "$recurring_count" == "2" ]]

  # recurring array should contain finding-A and finding-B
  local has_a
  has_a=$(echo "$output" | jq '[.recurring[] | select(. == "finding-A")] | length')
  [[ "$has_a" == "1" ]]

  local has_b
  has_b=$(echo "$output" | jq '[.recurring[] | select(. == "finding-B")] | length')
  [[ "$has_b" == "1" ]]
}

@test "resolved findings detected" {
  cd "$TEST_PROJECT_DIR"

  local current="$TEST_PROJECT_DIR/current-review.json"
  local previous="$TEST_PROJECT_DIR/previous-review.json"

  cat > "$current" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "still here"}
  ]
}
EOF

  cat > "$previous" <<'EOF'
{
  "findings": [
    {"id": "finding-A", "type": "bug", "message": "still here"},
    {"id": "finding-B", "type": "perf", "message": "fixed"},
    {"id": "finding-C", "type": "style", "message": "fixed too"}
  ]
}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current" "$previous"
  assert_success

  local resolved_count
  resolved_count=$(echo "$output" | jq '.resolved_count')
  [[ "$resolved_count" == "2" ]]

  # resolved array should contain finding-B and finding-C
  local has_b
  has_b=$(echo "$output" | jq '[.resolved[] | select(. == "finding-B")] | length')
  [[ "$has_b" == "1" ]]

  local has_c
  has_c=$(echo "$output" | jq '[.resolved[] | select(. == "finding-C")] | length')
  [[ "$has_c" == "1" ]]
}

@test "empty findings in current" {
  cd "$TEST_PROJECT_DIR"

  local current="$TEST_PROJECT_DIR/current-review.json"
  cat > "$current" <<'EOF'
{
  "findings": []
}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current"
  assert_success

  local current_findings
  current_findings=$(echo "$output" | jq '.current_findings')
  [[ "$current_findings" == "0" ]]
}

# =============================================================================
# Output validation
# =============================================================================

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  # No previous file case
  local current="$TEST_PROJECT_DIR/current-review.json"
  cat > "$current" <<'EOF'
{"findings": [{"id": "finding-A", "type": "bug", "message": "test"}]}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current"
  assert_success
  echo "$output" | jq empty

  # With previous file case
  local previous="$TEST_PROJECT_DIR/previous-review.json"
  cat > "$previous" <<'EOF'
{"findings": [{"id": "finding-A", "type": "bug", "message": "test"}]}
EOF

  run bash "$SCRIPTS_DIR/diff-review-findings.sh" "$current" "$previous"
  assert_success
  echo "$output" | jq empty
}
