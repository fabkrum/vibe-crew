#!/usr/bin/env bats
# Tests for scripts/pause-feature.sh and scripts/resume-feature.sh

load 'test_helper/common-setup'

PAUSE_SCRIPT="$SCRIPTS_DIR/pause-feature.sh"
RESUME_SCRIPT="$SCRIPTS_DIR/resume-feature.sh"

setup() {
  setup_vibecrew_dir
  # Create an initial commit so git operations work
  touch "$TEST_PROJECT_DIR/.gitkeep"
  git -C "$TEST_PROJECT_DIR" add .
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1

  # Create feature branch
  git -C "$TEST_PROJECT_DIR" checkout -b feat/test-feature >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: set up active feature in state.json
set_active_feature() {
  local fid="${1:-feat-001}"
  local fname="${2:-test-feature}"
  local phase="${3:-code}"
  jq --arg fid "$fid" --arg fname "$fname" --arg phase "$phase" \
    '.active_feature = {id: $fid, name: $fname, worktree: null, phase: $phase, phases_completed: ["plan"], plan_revision_count: 0, plan_commit_sha: null}' \
    "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"
}

# --- pause-feature.sh ---

@test "pause: fails when no state.json" {
  rm "$VIBECREW_DIR/state.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$PAUSE_SCRIPT'"
  assert_failure
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.paused')" = "false" ]
}

@test "pause: fails when no active feature" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$PAUSE_SCRIPT'"
  assert_failure
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.error')" = "No active feature to pause" ]
}

@test "pause: successfully pauses active feature" {
  set_active_feature
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$PAUSE_SCRIPT'"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.paused')" = "true" ]
  [ "$(echo "$output" | jq -r '.feature_id')" = "feat-001" ]
  [ "$(echo "$output" | jq -r '.phase')" = "code" ]
}

@test "pause: creates handoff file" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  [ -f "$VIBECREW_DIR/handoffs/pause-feat-001.md" ]
  grep -q "test-feature" "$VIBECREW_DIR/handoffs/pause-feat-001.md"
}

@test "pause: clears active_feature in state.json" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  ACTIVE_ID=$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")
  [ "$ACTIVE_ID" = "null" ]
}

@test "pause: stores paused_feature in state.json" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  PAUSED_ID=$(jq -r '.paused_feature.id' "$VIBECREW_DIR/state.json")
  [ "$PAUSED_ID" = "feat-001" ]
  PAUSED_PHASE=$(jq -r '.paused_feature.phase' "$VIBECREW_DIR/state.json")
  [ "$PAUSED_PHASE" = "code" ]
}

@test "pause: commits user's dirty working tree files" {
  set_active_feature
  echo "wip content" > "$TEST_PROJECT_DIR/wip-file.txt"
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null 2>&1
  # Verify the user's WIP file was committed (it's in git log)
  run git -C "$TEST_PROJECT_DIR" log --oneline --all --name-only -1
  assert_output --partial "wip-file.txt"
}

@test "pause: preserves phases_completed in paused state" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  PHASES=$(jq -c '.paused_feature.phases_completed' "$VIBECREW_DIR/state.json")
  [ "$PHASES" = '["plan"]' ]
}

# --- resume-feature.sh ---

@test "resume: fails when no state.json" {
  rm "$VIBECREW_DIR/state.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$RESUME_SCRIPT'"
  assert_failure
  [ "$(echo "$output" | jq -r '.resumed')" = "false" ]
}

@test "resume: fails when no paused feature" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$RESUME_SCRIPT'"
  assert_failure
  [ "$(echo "$output" | jq -r '.error')" = "No paused feature found in state.json" ]
}

@test "resume: fails when another feature is already active" {
  set_active_feature
  # Also add a paused feature manually
  jq '.paused_feature = {id: "feat-002", name: "other", phase: "plan"}' \
    "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$RESUME_SCRIPT'"
  assert_failure
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.resumed')" = "false" ]
  [[ "$(echo "$output" | jq -r '.error')" == *"already active"* ]]
}

@test "resume: successfully resumes paused feature" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$RESUME_SCRIPT'"
  assert_success
  echo "$output" | jq empty
  [ "$(echo "$output" | jq -r '.resumed')" = "true" ]
  [ "$(echo "$output" | jq -r '.feature_id')" = "feat-001" ]
}

@test "resume: restores active_feature in state.json" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  cd "$TEST_PROJECT_DIR" && bash "$RESUME_SCRIPT" > /dev/null
  ACTIVE_ID=$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")
  [ "$ACTIVE_ID" = "feat-001" ]
  ACTIVE_PHASE=$(jq -r '.active_feature.phase' "$VIBECREW_DIR/state.json")
  [ "$ACTIVE_PHASE" = "code" ]
}

@test "resume: removes paused_feature from state.json" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  cd "$TEST_PROJECT_DIR" && bash "$RESUME_SCRIPT" > /dev/null
  PAUSED=$(jq -r '.paused_feature // empty' "$VIBECREW_DIR/state.json")
  [ -z "$PAUSED" ]
}

@test "resume: renames handoff file to .resumed.md" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  [ -f "$VIBECREW_DIR/handoffs/pause-feat-001.md" ]
  cd "$TEST_PROJECT_DIR" && bash "$RESUME_SCRIPT" > /dev/null
  [ -f "$VIBECREW_DIR/handoffs/pause-feat-001.resumed.md" ]
  [ ! -f "$VIBECREW_DIR/handoffs/pause-feat-001.md" ]
}

@test "resume: restores phases_completed" {
  set_active_feature
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null
  cd "$TEST_PROJECT_DIR" && bash "$RESUME_SCRIPT" > /dev/null
  PHASES=$(jq -c '.active_feature.phases_completed' "$VIBECREW_DIR/state.json")
  [ "$PHASES" = '["plan"]' ]
}

# --- Round-trip ---

@test "pause+resume: full round-trip preserves feature state" {
  set_active_feature "feat-042" "billing-flow" "design"
  cd "$TEST_PROJECT_DIR" && bash "$PAUSE_SCRIPT" > /dev/null

  # Verify paused
  [ "$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")" = "null" ]
  [ "$(jq -r '.paused_feature.id' "$VIBECREW_DIR/state.json")" = "feat-042" ]

  cd "$TEST_PROJECT_DIR" && bash "$RESUME_SCRIPT" > /dev/null

  # Verify resumed with original values
  [ "$(jq -r '.active_feature.id' "$VIBECREW_DIR/state.json")" = "feat-042" ]
  [ "$(jq -r '.active_feature.name' "$VIBECREW_DIR/state.json")" = "billing-flow" ]
  [ "$(jq -r '.active_feature.phase' "$VIBECREW_DIR/state.json")" = "design" ]
}
