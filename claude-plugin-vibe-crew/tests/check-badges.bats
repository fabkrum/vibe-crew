#!/usr/bin/env bats
# tests/check-badges.bats
# Tests for scripts/check-badges.sh — badge evaluation after /wrap

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/check-badges.sh"
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

  # Remove empty scores directory to avoid pipefail on ls glob mismatch
  rmdir "$VIBECREW_DIR/scores" 2>/dev/null || true
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "gamification disabled: returns disabled message" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq -e '.message == "Gamification disabled"'
}

@test "always exits 0 when gamification disabled" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "gamification.json not found: exits 1" {
  rm -f "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
}

@test "no badges earned with empty state" {
  # No score files, empty stats — no badge conditions met
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(echo "$output" | jq '.badges_earned | length')
  [ "$count" -eq 0 ]
}

@test "output is valid JSON" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
}

@test "earns first-foundation badge when foundation complete" {
  set_foundation_complete

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq -e '[.badges_earned[] | select(.id == "first-foundation")] | length > 0'
}

@test "earns first-feature badge when features shipped >= 1" {
  local tmp="$VIBECREW_DIR/gamification.json.tmp"
  jq '.stats.total_features_shipped = 1' "$VIBECREW_DIR/gamification.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq -e '[.badges_earned[] | select(.id == "first-feature")] | length > 0'
}

@test "skips already-earned badges" {
  set_foundation_complete

  # Pre-earn the first-foundation badge
  local tmp="$VIBECREW_DIR/gamification.json.tmp"
  jq '.badges = [{"id": "first-foundation", "earned_at": "2026-01-01T00:00:00Z"}]' \
    "$VIBECREW_DIR/gamification.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(echo "$output" | jq '[.badges_earned[] | select(.id == "first-foundation")] | length')
  [ "$count" -eq 0 ]
}

@test "xp_from_badges is 0 when no badges earned" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local xp
  xp=$(echo "$output" | jq '.xp_from_badges')
  [ "$xp" -eq 0 ]
}
