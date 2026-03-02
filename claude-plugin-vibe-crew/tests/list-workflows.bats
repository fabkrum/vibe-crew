#!/usr/bin/env bats
# tests/list-workflows.bats
# Tests for scripts/list-workflows.sh — workflow file listing with summaries

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# Empty / missing directory
# =============================================================================

@test "no workflows directory: returns empty array" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$VIBECREW_DIR/workflows"

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success

  [[ "$output" == "[]" ]]
}

@test "no workflow files: returns empty array" {
  cd "$TEST_PROJECT_DIR"
  # workflows dir exists (from setup) but is empty

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success

  [[ "$output" == "[]" ]]
}

# =============================================================================
# Workflow listing
# =============================================================================

@test "single workflow: returns array with one entry" {
  cd "$TEST_PROJECT_DIR"

  cat > "$VIBECREW_DIR/workflows/workflow-test.json" <<'EOF'
{
  "schema_version": "1.3.0",
  "name": "test",
  "description": "A test workflow",
  "created_at": "2026-01-01T00:00:00Z",
  "phase_order": ["plan", "code", "test"],
  "quality_thresholds": { "min_vibe_score": 70 }
}
EOF

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success

  local count
  count=$(echo "$output" | jq 'length')
  [[ "$count" == "1" ]]
}

@test "multiple workflows: returns all" {
  cd "$TEST_PROJECT_DIR"

  cat > "$VIBECREW_DIR/workflows/workflow-alpha.json" <<'EOF'
{
  "name": "alpha",
  "description": "First workflow",
  "created_at": "2026-01-01T00:00:00Z",
  "phase_order": ["plan", "code"],
  "quality_thresholds": { "min_vibe_score": 70 }
}
EOF

  cat > "$VIBECREW_DIR/workflows/workflow-beta.json" <<'EOF'
{
  "name": "beta",
  "description": "Second workflow",
  "created_at": "2026-01-02T00:00:00Z",
  "phase_order": ["plan", "code", "test", "review"],
  "quality_thresholds": { "min_vibe_score": 80 }
}
EOF

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success

  local count
  count=$(echo "$output" | jq 'length')
  [[ "$count" == "2" ]]
}

@test "extracts workflow name and description" {
  cd "$TEST_PROJECT_DIR"

  cat > "$VIBECREW_DIR/workflows/workflow-detail.json" <<'EOF'
{
  "name": "detail",
  "description": "Detailed workflow for testing",
  "created_at": "2026-01-15T12:00:00Z",
  "phase_order": ["plan", "code", "test"],
  "quality_thresholds": { "min_vibe_score": 75 }
}
EOF

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success

  local name
  name=$(echo "$output" | jq -r '.[0].name')
  [[ "$name" == "detail" ]]

  local desc
  desc=$(echo "$output" | jq -r '.[0].description')
  [[ "$desc" == "Detailed workflow for testing" ]]
}

# =============================================================================
# Output format
# =============================================================================

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success

  echo "$output" | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/list-workflows.sh"
  assert_success
}
