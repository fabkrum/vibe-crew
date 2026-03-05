#!/usr/bin/env bats
# tests/drift-circuit-breaker.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/drift-circuit-breaker.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/signals"

  # Set an active feature
  local state_json
  state_json=$(jq '.active_feature = {id:"feat-001", name:"test-feature", phase:"code", phases_completed:["plan","design"]}' "$VIBECREW_DIR/state.json")
  echo "$state_json" > "$VIBECREW_DIR/state.json"
}

teardown() {
  teardown_vibecrew_dir
}

@test "exits cleanly when no tracker file" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "CIRCUIT BREAKER"
}

@test "exits cleanly when under hard threshold" {
  cat > "$VIBECREW_DIR/drift-tracker.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "session_started_at": "2026-03-05T00:00:00Z",
  "current_phase": "code",
  "current_feature_id": "feat-001",
  "total_tool_calls": 10,
  "calls_since_progress": 10,
  "last_progress_at": null,
  "last_progress_tool": null,
  "progress_events": 0,
  "exploration_events": 10,
  "warnings": { "soft_count": 0, "last_warned_at": null },
  "escalations": { "hard_count": 0, "last_escalated_at": null, "last_escalated_count": 0 },
  "recent_reads": [],
  "repeated_read_count": 0
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "CIRCUIT BREAKER"
}

@test "triggers at hard threshold" {
  cat > "$VIBECREW_DIR/drift-tracker.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "session_started_at": "2026-03-05T00:00:00Z",
  "current_phase": "code",
  "current_feature_id": "feat-001",
  "total_tool_calls": 35,
  "calls_since_progress": 35,
  "last_progress_at": null,
  "last_progress_tool": null,
  "progress_events": 0,
  "exploration_events": 35,
  "warnings": { "soft_count": 1, "last_warned_at": "2026-03-05T00:00:00Z" },
  "escalations": { "hard_count": 0, "last_escalated_at": null, "last_escalated_count": 0 },
  "recent_reads": [],
  "repeated_read_count": 0
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "DRIFT CIRCUIT BREAKER"
}

@test "writes builder-blocked signal" {
  cat > "$VIBECREW_DIR/drift-tracker.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "session_started_at": "2026-03-05T00:00:00Z",
  "current_phase": "code",
  "current_feature_id": "feat-001",
  "total_tool_calls": 35,
  "calls_since_progress": 35,
  "last_progress_at": null,
  "last_progress_tool": null,
  "progress_events": 0,
  "exploration_events": 35,
  "warnings": { "soft_count": 1, "last_warned_at": "2026-03-05T00:00:00Z" },
  "escalations": { "hard_count": 0, "last_escalated_at": null, "last_escalated_count": 0 },
  "recent_reads": [],
  "repeated_read_count": 0
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  [ -f "$VIBECREW_DIR/signals/builder-blocked.signal" ]
  local status
  status=$(jq -r '.status' "$VIBECREW_DIR/signals/builder-blocked.signal")
  [ "$status" = "blocked" ]
}

@test "increments escalation count" {
  cat > "$VIBECREW_DIR/drift-tracker.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "session_started_at": "2026-03-05T00:00:00Z",
  "current_phase": "code",
  "current_feature_id": "feat-001",
  "total_tool_calls": 35,
  "calls_since_progress": 35,
  "last_progress_at": null,
  "last_progress_tool": null,
  "progress_events": 0,
  "exploration_events": 35,
  "warnings": { "soft_count": 1, "last_warned_at": "2026-03-05T00:00:00Z" },
  "escalations": { "hard_count": 0, "last_escalated_at": null, "last_escalated_count": 0 },
  "recent_reads": [],
  "repeated_read_count": 0
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local hard_count
  hard_count=$(jq -r '.escalations.hard_count' "$VIBECREW_DIR/drift-tracker.json")
  [ "$hard_count" -eq 1 ]
}

@test "skips when drift detection disabled" {
  cat > "$VIBECREW_DIR/drift-tracker.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "current_phase": "code",
  "current_feature_id": "feat-001",
  "calls_since_progress": 100,
  "escalations": { "hard_count": 0, "last_escalated_at": null, "last_escalated_count": 0 }
}
EOF

  # Write config with drift detection disabled directly
  cat > "$VIBECREW_DIR/config.json" <<'CFGEOF'
{
  "schema_version": "1.4.0",
  "terminal": "other",
  "notifications": { "enabled": true },
  "gamification": { "enabled": false },
  "drift_detection": { "enabled": false },
  "user_profile": { "interview_completed": false }
}
CFGEOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "CIRCUIT BREAKER"
}
