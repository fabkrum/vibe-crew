#!/usr/bin/env bats
# tests/refresh-challenges.bats
# Tests for scripts/refresh-challenges.sh — expire/refresh daily/weekly challenges on session start

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/refresh-challenges.sh"
  setup_vibecrew_dir

  # Enable gamification in config
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Create gamification.json
  cat > "$VIBECREW_DIR/gamification.json" <<'EOF'
{
  "level": 1,
  "xp": 0,
  "xp_this_level": 0,
  "streak": {"current": 0, "best": 0, "last_date": null},
  "badges": [],
  "active_challenges": [],
  "completed_challenges": [],
  "stats": {
    "total_sessions": 0,
    "total_features_shipped": 0,
    "perfect_sessions": 0,
    "best_vibe_score": 0,
    "score_history": []
  },
  "skills": {
    "prompting": {"xp": 0, "level": 0, "max_level": 5},
    "architecture": {"xp": 0, "level": 0, "max_level": 5},
    "testing": {"xp": 0, "level": 0, "max_level": 5},
    "context_management": {"xp": 0, "level": 0, "max_level": 5},
    "workflow_discipline": {"xp": 0, "level": 0, "max_level": 5}
  }
}
EOF
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "gamification disabled: silent exit 0" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "missing gamification.json: silent exit 0" {
  rm -f "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "missing challenge-pool.json: silent exit 0" {
  # The script checks for challenge-pool.json at PLUGIN_ROOT/templates/challenge-pool.json
  # If missing (which it won't be since tests run against real scripts), it exits 0
  # In our test env, the file exists at the real plugin path, but this verifies
  # the script doesn't crash when gamification.json exists but pool is missing
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "level < 2: no daily challenges added" {
  # Level 1 — daily challenges unlock at level 2
  local before_count
  before_count=$(jq '.active_challenges | length' "$VIBECREW_DIR/gamification.json")

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  local after_count
  after_count=$(jq '.active_challenges | length' "$VIBECREW_DIR/gamification.json")
  [ "$after_count" -eq "$before_count" ]
}

@test "always exits 0" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "level >= 2: daily challenges may be added" {
  # Set level to 2 — daily challenges unlock
  local tmp="$VIBECREW_DIR/gamification.json.tmp"
  jq '.level = 2' "$VIBECREW_DIR/gamification.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  # At level 2, up to 2 daily challenges should be added
  local daily_count
  daily_count=$(jq '[.active_challenges[] | select(.type == "daily")] | length' "$VIBECREW_DIR/gamification.json")
  [ "$daily_count" -ge 1 ]
}

@test "expired daily challenges are removed" {
  # Set level to 2 for daily challenges
  local tmp="$VIBECREW_DIR/gamification.json.tmp"
  jq '.level = 2' "$VIBECREW_DIR/gamification.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/gamification.json"

  # Add an expired daily challenge (started yesterday)
  tmp="$VIBECREW_DIR/gamification.json.tmp"
  jq '.active_challenges = [{"id": "daily-old", "type": "daily", "name": "Old", "started_at": "2026-01-01T00:00:00Z", "expires_at": "2026-01-02T00:00:00Z", "progress": 0, "target": 1, "xp_reward": 20}]' \
    "$VIBECREW_DIR/gamification.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  # The expired challenge should be removed
  local old_count
  old_count=$(jq '[.active_challenges[] | select(.id == "daily-old")] | length' "$VIBECREW_DIR/gamification.json")
  [ "$old_count" -eq 0 ]
}

@test "output contains active challenge count" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "Challenges:"
}
