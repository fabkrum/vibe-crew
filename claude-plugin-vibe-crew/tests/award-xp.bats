#!/usr/bin/env bats
# tests/award-xp.bats
# Tests for scripts/award-xp.sh — XP calculation and gamification

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/award-xp.sh"
  setup_vibecrew_dir

  # Create gamification.json
  cat > "$VIBECREW_DIR/gamification.json" <<'EOF'
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
    "current": 0,
    "longest": 0,
    "last_session_date": "none",
    "grace_days_remaining": 2
  }
}
EOF

  # Enable gamification in config
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"
}

teardown() {
  teardown_vibecrew_dir
}

@test "gamification disabled returns 0 XP and exits 0" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local xp
  xp=$(echo "$output" | jq -r '.xp_awarded')
  [ "$xp" -eq 0 ]
}

@test "awards base session XP (10) with score file" {
  # Create a score file
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-03-02.json" <<'EOF'
{
  "score": 75,
  "deductions": [{"category": "test", "points": -5}]
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local xp
  xp=$(echo "$output" | jq -r '.xp_awarded')
  [ "$xp" -ge 10 ]
}

@test "awards vibe score bonus when score > 50" {
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-03-02.json" <<'EOF'
{
  "score": 80,
  "deductions": [{"category": "test", "points": -5}]
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  # Should get 10 (base) + 30 (80-50 bonus) = 40+
  local xp
  xp=$(echo "$output" | jq -r '.xp_awarded')
  [ "$xp" -ge 40 ]
}

@test "XP written to gamification.json" {
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-03-02.json" <<'EOF'
{
  "score": 60,
  "deductions": [{"category": "test", "points": -5}]
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  # Check gamification.json was updated
  local stored_xp
  stored_xp=$(jq -r '.xp' "$VIBECREW_DIR/gamification.json")
  [ "$stored_xp" -gt 0 ]
}

@test "no score file returns 0 XP" {
  # No scores directory or files
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local xp
  xp=$(echo "$output" | jq -r '.xp_awarded')
  [ "$xp" -eq 0 ]
}

@test "clean session bonus when 0 deductions" {
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-03-02.json" <<'EOF'
{
  "score": 100,
  "deductions": []
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  # 10 (base) + 50 (100-50) + 25 (clean) = 85
  local xp
  xp=$(echo "$output" | jq -r '.xp_awarded')
  [ "$xp" -ge 85 ]
}
