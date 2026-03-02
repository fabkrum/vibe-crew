#!/usr/bin/env bats
# tests/check-level-up.bats
# Tests for scripts/check-level-up.sh — level-up progression

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/check-level-up.sh"
  setup_vibecrew_dir

  # Enable gamification
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"
}

teardown() {
  teardown_vibecrew_dir
}

create_gamification() {
  local level="$1"
  local xp_this="$2"
  local xp_next="$3"
  cat > "$VIBECREW_DIR/gamification.json" <<EOF
{
  "level": $level,
  "xp": 0,
  "xp_this_level": $xp_this,
  "xp_to_next_level": $xp_next,
  "badges": [],
  "unlocked_features": [],
  "stats": {
    "total_sessions": 0,
    "total_features_shipped": 0,
    "best_vibe_score": 0,
    "perfect_sessions": 0,
    "score_history": []
  }
}
EOF
}

@test "gamification disabled returns no level-up" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  create_gamification 1 50 100

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local leveled
  leveled=$(echo "$output" | jq -r '.leveled_up')
  [ "$leveled" = "false" ]
}

@test "below threshold: no level-up" {
  create_gamification 1 50 100

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local leveled
  leveled=$(echo "$output" | jq -r '.leveled_up')
  [ "$leveled" = "false" ]
  local new_level
  new_level=$(echo "$output" | jq -r '.new_level')
  [ "$new_level" -eq 1 ]
}

@test "above threshold: levels up" {
  create_gamification 1 120 100

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local leveled
  leveled=$(echo "$output" | jq -r '.leveled_up')
  [ "$leveled" = "true" ]
  local new_level
  new_level=$(echo "$output" | jq -r '.new_level')
  [ "$new_level" -eq 2 ]
}

@test "multi-level jump" {
  # 500 XP at level 1 should jump multiple levels
  # Level 1->2: 100, 2->3: 115, 3->4: 132, 4->5: 152 = ~499 total
  create_gamification 1 500 100

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local new_level
  new_level=$(echo "$output" | jq -r '.new_level')
  [ "$new_level" -ge 4 ]
  local levels_gained
  levels_gained=$(echo "$output" | jq -r '.levels_gained')
  [ "$levels_gained" -ge 3 ]
}

@test "level up updates gamification.json" {
  create_gamification 1 120 100

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  local stored_level
  stored_level=$(jq -r '.level' "$VIBECREW_DIR/gamification.json")
  [ "$stored_level" -eq 2 ]
}

@test "exactly at threshold: levels up" {
  create_gamification 1 100 100

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local leveled
  leveled=$(echo "$output" | jq -r '.leveled_up')
  [ "$leveled" = "true" ]
}
