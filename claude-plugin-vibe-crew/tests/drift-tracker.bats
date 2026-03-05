#!/usr/bin/env bats
# tests/drift-tracker.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/drift-tracker.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/signals"

  # Set an active feature so tracker activates
  local state_json
  state_json=$(jq '.active_feature = {id:"feat-001", name:"test-feature", phase:"code", phases_completed:["plan","design"]}' "$VIBECREW_DIR/state.json")
  echo "$state_json" > "$VIBECREW_DIR/state.json"
}

teardown() {
  teardown_vibecrew_dir
}

@test "creates tracker file on first call" {
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"tool_name\":\"Read\",\"file_path\":\"src/app.ts\"}' | bash '$SCRIPT'"
  assert_success
  [ -f "$VIBECREW_DIR/drift-tracker.json" ]
}

@test "classifies Write to source files as progress" {
  echo '{"tool_name":"Write","file_path":"src/components/Button.tsx"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  local since
  since=$(jq -r '.calls_since_progress' "$VIBECREW_DIR/drift-tracker.json")
  [ "$since" -eq 0 ]
  local prog
  prog=$(jq -r '.progress_events' "$VIBECREW_DIR/drift-tracker.json")
  [ "$prog" -eq 1 ]
}

@test "classifies Read as exploration" {
  echo '{"tool_name":"Read","file_path":"src/app.ts"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  local since
  since=$(jq -r '.calls_since_progress' "$VIBECREW_DIR/drift-tracker.json")
  [ "$since" -eq 1 ]
  local expl
  expl=$(jq -r '.exploration_events' "$VIBECREW_DIR/drift-tracker.json")
  [ "$expl" -eq 1 ]
}

@test "resets counter on progress after exploration" {
  # 3 exploration calls
  for i in 1 2 3; do
    echo '{"tool_name":"Read","file_path":"src/file'$i'.ts"}' | \
      bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  done
  local since_before
  since_before=$(jq -r '.calls_since_progress' "$VIBECREW_DIR/drift-tracker.json")
  [ "$since_before" -eq 3 ]

  # 1 progress call
  echo '{"tool_name":"Write","file_path":"src/new.tsx"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  local since_after
  since_after=$(jq -r '.calls_since_progress' "$VIBECREW_DIR/drift-tracker.json")
  [ "$since_after" -eq 0 ]
}

@test "emits soft warning at threshold" {
  # Set tracker near soft threshold (code phase soft=20)
  cat > "$VIBECREW_DIR/drift-tracker.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "session_started_at": "2026-03-05T00:00:00Z",
  "current_phase": "code",
  "current_feature_id": "feat-001",
  "total_tool_calls": 19,
  "calls_since_progress": 19,
  "last_progress_at": null,
  "last_progress_tool": null,
  "progress_events": 0,
  "exploration_events": 19,
  "warnings": { "soft_count": 0, "last_warned_at": null, "last_warned_count": 0 },
  "escalations": { "hard_count": 0, "last_escalated_at": null },
  "recent_reads": [],
  "repeated_read_count": 0
}
EOF

  # stderr warning captured via 2>&1
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"tool_name\":\"Grep\",\"file_path\":\"\"}' | bash '$SCRIPT' 2>&1"
  assert_success
  assert_output --partial "DRIFT WARNING"
}

@test "skips during foundation (Tier 1)" {
  # Mark foundation as incomplete
  local state_json
  state_json=$(jq '.foundation.complete = false' "$VIBECREW_DIR/state.json")
  echo "$state_json" > "$VIBECREW_DIR/state.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"tool_name\":\"Read\",\"file_path\":\"src/app.ts\"}' | bash '$SCRIPT'"
  assert_success
  [ ! -f "$VIBECREW_DIR/drift-tracker.json" ]
}

@test "skips review phase" {
  # Set phase to review
  local state_json
  state_json=$(jq '.active_feature.phase = "review"' "$VIBECREW_DIR/state.json")
  echo "$state_json" > "$VIBECREW_DIR/state.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"tool_name\":\"Read\",\"file_path\":\"src/app.ts\"}' | bash '$SCRIPT'"
  assert_success
  [ ! -f "$VIBECREW_DIR/drift-tracker.json" ]
}

@test "skips when drift detection disabled" {
  local config_json
  config_json=$(jq '.drift_detection.enabled = false' "$VIBECREW_DIR/config.json")
  echo "$config_json" > "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && echo '{\"tool_name\":\"Read\",\"file_path\":\"src/app.ts\"}' | bash '$SCRIPT'"
  assert_success
  [ ! -f "$VIBECREW_DIR/drift-tracker.json" ]
}

@test "tracks repeated reads" {
  # Read same file twice
  echo '{"tool_name":"Read","file_path":"src/app.ts"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  echo '{"tool_name":"Read","file_path":"src/app.ts"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"

  local rcount
  rcount=$(jq -r '.repeated_read_count' "$VIBECREW_DIR/drift-tracker.json")
  [ "$rcount" -eq 1 ]
}

@test "increments total tool calls" {
  echo '{"tool_name":"Read","file_path":"a.ts"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  echo '{"tool_name":"Write","file_path":"b.tsx"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  echo '{"tool_name":"Bash","file_path":"npm test"}' | \
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"

  local total
  total=$(jq -r '.total_tool_calls' "$VIBECREW_DIR/drift-tracker.json")
  [ "$total" -eq 3 ]
}
