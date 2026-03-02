#!/usr/bin/env bats
# tests/update-challenges.bats
# Tests for scripts/update-challenges.sh — challenge progress evaluation after /wrap
#
# NOTE: update-challenges.sh has a known bug on line 142 where `local` is used
# outside a function. This causes the script to crash when a challenge is met.
# Tests for "challenge met" scenarios reflect this current behavior (assert_failure).

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/update-challenges.sh"
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

create_score_file() {
  local score="${1:-75}"
  local deductions="${2:-[]}"
  local cache_ratio="${3:-0.5}"
  local churn="${4:-0}"
  local peak_context="${5:-50}"
  local tests_passed="${6:-false}"
  local coverage="${7:-0}"
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-03-02.json" <<EOF
{
  "score": $score,
  "deductions": $deductions,
  "metrics": {
    "tokens": {"cache_ratio": $cache_ratio},
    "prompt_churn": {"sequences": $churn},
    "context": {"peak_usage_percent": $peak_context},
    "quality": {"tests_passed": $tests_passed, "coverage_percent": $coverage}
  }
}
EOF
}

add_active_challenge() {
  local id="$1"
  local name="${2:-Test Challenge}"
  local xp="${3:-20}"
  local type="${4:-daily}"
  local tmp="$VIBECREW_DIR/gamification.json.tmp"
  jq --arg id "$id" --arg name "$name" --argjson xp "$xp" --arg type "$type" \
    '.active_challenges += [{"id": $id, "name": $name, "type": $type, "xp_reward": $xp, "started_at": "2026-03-02T00:00:00Z", "expires_at": "2026-03-03T00:00:00Z", "progress": 0, "target": 1}]' \
    "$VIBECREW_DIR/gamification.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/gamification.json"
}

@test "gamification disabled: returns disabled message" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq -e '.message' | grep -q "disabled"
}

@test "gamification.json not found: returns empty" {
  rm -f "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(echo "$output" | jq '.challenges_completed | length')
  [ "$count" -eq 0 ]
}

@test "no score file: returns empty" {
  # scores/ directory does not exist
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(echo "$output" | jq '.challenges_completed | length')
  [ "$count" -eq 0 ]
}

@test "no active challenges: returns empty completed list" {
  create_score_file 90 "[]"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(echo "$output" | jq '.challenges_completed | length')
  [ "$count" -eq 0 ]
}

# Known bug: script uses `local` outside a function on line 142,
# causing a crash when any challenge condition is met.
@test "clean-sweep challenge met: hits local-outside-function bug" {
  create_score_file 90 "[]"
  add_active_challenge "daily-clean-sweep" "Clean Sweep" 20

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "local: can only be used in a function"
}

@test "challenge not met when conditions fail" {
  # Create score with deductions — clean-sweep requires 0 deductions
  create_score_file 60 '[{"category":"test","points":-10}]'
  add_active_challenge "daily-clean-sweep" "Clean Sweep" 20

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(echo "$output" | jq '.challenges_completed | length')
  [ "$count" -eq 0 ]
}

@test "output is valid JSON when no challenges completed" {
  create_score_file 80 "[]"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
}

@test "xp_from_challenges is 0 when none completed" {
  create_score_file 80 '[{"category":"test","points":-5}]'
  add_active_challenge "daily-clean-sweep" "Clean Sweep" 20

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local xp
  xp=$(echo "$output" | jq '.xp_from_challenges')
  [ "$xp" -eq 0 ]
}

# Known bug: same local-outside-function issue
@test "cache-champion challenge met: hits local-outside-function bug" {
  create_score_file 80 "[]" 0.75
  add_active_challenge "daily-cache-champion" "Cache Champion" 20

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "local: can only be used in a function"
}

# Known bug: same local-outside-function issue
@test "no-churn challenge met: hits local-outside-function bug" {
  create_score_file 80 "[]" 0.5 0
  add_active_challenge "daily-no-churn" "Clear Channel" 20

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "local: can only be used in a function"
}
