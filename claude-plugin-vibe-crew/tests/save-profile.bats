#!/usr/bin/env bats
# tests/save-profile.bats
# Tests for scripts/save-profile.sh — user profile writing with gamification sync

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "saves all 8 profile dimensions" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" \
    --role developer \
    --code-literacy fluent \
    --autonomy full_auto \
    --pr-review auto_merge \
    --verbosity minimal \
    --gamification full \
    --learning none \
    --risk-tolerance progressive
  assert_success
  assert_output --partial "Profile saved"

  # Verify each dimension
  run jq -r '.user_profile.role' "$VIBECREW_DIR/config.json"
  assert_output "developer"
  run jq -r '.user_profile.code_literacy' "$VIBECREW_DIR/config.json"
  assert_output "fluent"
  run jq -r '.user_profile.autonomy' "$VIBECREW_DIR/config.json"
  assert_output "full_auto"
  run jq -r '.user_profile.pr_review' "$VIBECREW_DIR/config.json"
  assert_output "auto_merge"
  run jq -r '.user_profile.verbosity' "$VIBECREW_DIR/config.json"
  assert_output "minimal"
  run jq -r '.user_profile.gamification_preference' "$VIBECREW_DIR/config.json"
  assert_output "full"
  run jq -r '.user_profile.learning' "$VIBECREW_DIR/config.json"
  assert_output "none"
  run jq -r '.user_profile.risk_tolerance' "$VIBECREW_DIR/config.json"
  assert_output "progressive"
}

@test "applies defaults for unfilled fields" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" --role designer
  assert_success

  # Role should be set
  run jq -r '.user_profile.role' "$VIBECREW_DIR/config.json"
  assert_output "designer"

  # Unfilled fields should get defaults
  run jq -r '.user_profile.code_literacy' "$VIBECREW_DIR/config.json"
  assert_output "conversational"
  run jq -r '.user_profile.autonomy' "$VIBECREW_DIR/config.json"
  assert_output "checkpoints"
}

@test "gamification sync: disabled turns off all gamification" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" --gamification disabled
  assert_success

  run jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json"
  assert_output "false"
  run jq -r '.gamification.show_xp_in_status' "$VIBECREW_DIR/config.json"
  assert_output "false"
  run jq -r '.gamification.streak_reminders' "$VIBECREW_DIR/config.json"
  assert_output "false"
}

@test "gamification sync: full enables everything" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" --gamification full
  assert_success

  run jq -r '.gamification.enabled' "$VIBECREW_DIR/config.json"
  assert_output "true"
  run jq -r '.gamification.show_xp_in_status' "$VIBECREW_DIR/config.json"
  assert_output "true"
  run jq -r '.gamification.streak_reminders' "$VIBECREW_DIR/config.json"
  assert_output "true"
}

@test "fails when config.json is missing" {
  cd "$TEST_PROJECT_DIR"
  rm "$VIBECREW_DIR/config.json"
  run bash "$SCRIPTS_DIR/save-profile.sh" --role developer
  assert_failure
  assert_output --partial "not found"
}

@test "rejects unknown flags" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" --bogus-flag value
  assert_failure
  assert_output --partial "Unknown flag"
}

@test "uses PID-suffixed temp file (no bare .tmp leftover)" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" --role developer
  assert_success
  # No bare .tmp file should remain (PID-suffixed gets renamed atomically)
  run bash -c "ls '$VIBECREW_DIR'/config.json.tmp 2>/dev/null | wc -l | tr -d ' '"
  assert_output "0"
}

@test "interview_completed is set to true" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/save-profile.sh" --role learner
  assert_success
  run jq -r '.user_profile.interview_completed' "$VIBECREW_DIR/config.json"
  assert_output "true"
}
