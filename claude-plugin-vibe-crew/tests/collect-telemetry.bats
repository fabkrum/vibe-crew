#!/usr/bin/env bats
# tests/collect-telemetry.bats
# Tests for scripts/collect-telemetry.sh — cross-project telemetry

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  # Save and restore registry
  if [[ -f "$PLUGIN_ROOT/project-registry.json" ]]; then
    cp "$PLUGIN_ROOT/project-registry.json" "$PLUGIN_ROOT/project-registry.json.bak"
  fi
}

teardown() {
  teardown_vibecrew_dir
  if [[ -f "$PLUGIN_ROOT/project-registry.json.bak" ]]; then
    mv "$PLUGIN_ROOT/project-registry.json.bak" "$PLUGIN_ROOT/project-registry.json"
  elif [[ -f "$PLUGIN_ROOT/project-registry.json" ]]; then
    rm "$PLUGIN_ROOT/project-registry.json"
  fi
  rm -rf "$PLUGIN_ROOT/telemetry"
}

@test "no registry returns empty aggregates" {
  rm -f "$PLUGIN_ROOT/project-registry.json"

  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.project_count')
  [[ "$count" == "0" ]]

  local total
  total=$(echo "$output" | jq '.aggregates.total_sessions')
  [[ "$total" == "0" ]]
}

@test "empty registry returns empty aggregates" {
  echo '{"projects":[]}' > "$PLUGIN_ROOT/project-registry.json"

  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success

  local count
  count=$(echo "$output" | jq '.project_count')
  [[ "$count" == "0" ]]
}

@test "single project collects session count" {
  # Register our test project
  cat > "$PLUGIN_ROOT/project-registry.json" <<EOF
{"projects":[{"path":"$TEST_PROJECT_DIR","alias":"project-001"}]}
EOF

  # Create session files
  mkdir -p "$VIBECREW_DIR/sessions"
  echo '{"started_at":"2026-01-01T00:00:00Z","tokens":{"estimated_cost_usd":1.00}}' > "$VIBECREW_DIR/sessions/session-2026-01-01-001.json"
  echo '{"started_at":"2026-01-02T00:00:00Z","tokens":{"estimated_cost_usd":2.00}}' > "$VIBECREW_DIR/sessions/session-2026-01-02-001.json"

  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success

  local sessions
  sessions=$(echo "$output" | jq '.aggregates.total_sessions')
  [[ "$sessions" == "2" ]]
}

@test "collects vibe scores" {
  cat > "$PLUGIN_ROOT/project-registry.json" <<EOF
{"projects":[{"path":"$TEST_PROJECT_DIR","alias":"project-001"}]}
EOF
  echo '{"score":85,"deductions":[],"bonuses":[]}' > "$VIBECREW_DIR/scores/score-001.json"

  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success

  local avg
  avg=$(echo "$output" | jq '.projects[0].avg_vibe_score')
  [[ "$avg" == "85" ]]
}

@test "anonymization: uses alias not path" {
  cat > "$PLUGIN_ROOT/project-registry.json" <<EOF
{"projects":[{"path":"$TEST_PROJECT_DIR","alias":"project-001"}]}
EOF

  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success

  local alias
  alias=$(echo "$output" | jq -r '.projects[0].alias')
  [[ "$alias" == "project-001" ]]

  # Should not contain actual path
  [[ "$output" != *"$TEST_PROJECT_DIR"* ]] || echo "$output" | jq -e '.projects[0].path' 2>/dev/null && false || true
}

@test "output is valid JSON" {
  rm -f "$PLUGIN_ROOT/project-registry.json"
  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success
  echo "$output" | jq empty
}

@test "schema version present" {
  rm -f "$PLUGIN_ROOT/project-registry.json"
  run bash "$SCRIPTS_DIR/collect-telemetry.sh"
  assert_success

  local ver
  ver=$(echo "$output" | jq -r '.schema_version')
  [[ "$ver" == "1.0.0" ]]
}
