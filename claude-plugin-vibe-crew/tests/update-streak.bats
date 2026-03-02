#!/usr/bin/env bats
# tests/update-streak.bats
# Tests for scripts/update-streak.sh — streak tracking

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/update-streak.sh"
  setup_vibecrew_dir

  # Enable gamification
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"
}

teardown() {
  teardown_vibecrew_dir
}

create_gamification_streak() {
  local streak="$1"
  local longest="$2"
  local last_date="$3"
  local grace="${4:-2}"
  cat > "$VIBECREW_DIR/gamification.json" <<EOF
{
  "level": 1,
  "xp": 0,
  "xp_this_level": 0,
  "xp_to_next_level": 100,
  "badges": [],
  "unlocked_features": [],
  "stats": {
    "total_sessions": 0,
    "total_features_shipped": 0,
    "best_vibe_score": 0,
    "perfect_sessions": 0,
    "score_history": []
  },
  "streak": {
    "current": $streak,
    "longest": $longest,
    "last_session_date": "$last_date",
    "grace_days_remaining": $grace,
    "frozen_today": false
  }
}
EOF
}

@test "gamification disabled returns no update" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  create_gamification_streak 0 0 "none"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local updated
  updated=$(echo "$output" | jq -r '.streak_updated')
  [ "$updated" = "false" ]
}

@test "first session: streak starts at 1" {
  create_gamification_streak 0 0 "none"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local streak
  streak=$(echo "$output" | jq -r '.current')
  [ "$streak" -eq 1 ]
}

@test "same day: streak maintained (no increment)" {
  local today
  today=$(date -u +%Y-%m-%d)
  create_gamification_streak 5 5 "$today"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local updated
  updated=$(echo "$output" | jq -r '.streak_updated')
  [ "$updated" = "false" ]
  local streak
  streak=$(echo "$output" | jq -r '.current')
  [ "$streak" -eq 5 ]
}

@test "consecutive day: streak increments" {
  # Set last session to yesterday
  local yesterday
  if [[ "$(uname)" == "Darwin" ]]; then
    yesterday=$(date -j -v-1d -u +%Y-%m-%d)
  else
    yesterday=$(date -d "yesterday" -u +%Y-%m-%d)
  fi

  create_gamification_streak 3 5 "$yesterday"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local streak
  streak=$(echo "$output" | jq -r '.current')
  [ "$streak" -eq 4 ]
}

@test "gap resets streak" {
  # Set last session to 5 days ago (weekdays)
  local five_days_ago
  if [[ "$(uname)" == "Darwin" ]]; then
    five_days_ago=$(date -j -v-5d -u +%Y-%m-%d)
  else
    five_days_ago=$(date -d "5 days ago" -u +%Y-%m-%d)
  fi

  # With only 2 grace days, 3+ missed weekdays resets
  create_gamification_streak 10 10 "$five_days_ago" 0

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local broken
  broken=$(echo "$output" | jq -r '.streak_broken')
  [ "$broken" = "true" ]
  local streak
  streak=$(echo "$output" | jq -r '.current')
  [ "$streak" -eq 1 ]
}

@test "updates longest streak" {
  local yesterday
  if [[ "$(uname)" == "Darwin" ]]; then
    yesterday=$(date -j -v-1d -u +%Y-%m-%d)
  else
    yesterday=$(date -d "yesterday" -u +%Y-%m-%d)
  fi

  create_gamification_streak 5 5 "$yesterday"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local longest
  longest=$(echo "$output" | jq -r '.longest')
  [ "$longest" -eq 6 ]
}
