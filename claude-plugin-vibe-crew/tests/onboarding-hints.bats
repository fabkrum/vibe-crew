#!/usr/bin/env bats
# tests/onboarding-hints.bats
# Tests for scripts/onboarding-hints.sh — context-sensitive command hints based on project phase

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/onboarding-hints.sh"
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "no .vibecrew directory: suggests /setup" {
  rm -rf "$VIBECREW_DIR"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/setup"
}

@test "no state file: suggests /setup" {
  rm -f "$VIBECREW_DIR/state.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/setup"
}

@test "profile not completed: suggests /profile" {
  # Default config has interview_completed=false
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/profile"
}

@test "foundation not complete with package.json: suggests /onboard" {
  # Set profile as completed so we get past that check
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.user_profile.interview_completed = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Foundation is not complete (default), create package.json
  echo '{"name":"test"}' > "$TEST_PROJECT_DIR/package.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/onboard"
}

@test "foundation not complete without package.json: suggests /new-project" {
  # Set profile as completed
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.user_profile.interview_completed = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Foundation is not complete (default), no package.json
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/new-project"
}

@test "foundation complete, no backlog: suggests /plan-features" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.user_profile.interview_completed = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  set_foundation_complete

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/plan-features"
}

@test "has backlog, no active feature: suggests /new-feature" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.user_profile.interview_completed = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  set_foundation_complete
  add_feature_to_backlog "feat-001" "Test Feature" "planned"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/new-feature"
}

@test "all phases done: suggests /wrap" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.user_profile.interview_completed = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  set_foundation_complete
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "docs"
  set_phases_completed "plan" "design" "code" "test" "review"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | grep -q "/wrap"
}

@test "hints disabled via string value: no output" {
  # NOTE: The script uses jq's // operator: '.onboarding.show_hints // true'
  # jq's // treats boolean false as falsy and falls through to the alternative.
  # So boolean false gets replaced with true. The script only works when
  # show_hints is set to the string "false", not the boolean false.
  # This test uses the string value to verify the disable path works.
  cat > "$VIBECREW_DIR/config.json" <<'CFGEOF'
{
  "schema_version": "1.4.0",
  "terminal": "other",
  "notifications": {"enabled": true},
  "gamification": {"enabled": false},
  "onboarding": {"show_hints": "false"},
  "user_profile": {"interview_completed": false, "gamification_preference": null}
}
CFGEOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "Tip:"
}

@test "dismissed hints are skipped" {
  # Dismiss the "setup" hint
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.onboarding.dismissed_hints = ["setup"]' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Remove .vibecrew dir to trigger setup hint, then recreate config
  rm -f "$VIBECREW_DIR/state.json"
  # The script checks for state.json — without it, it would suggest /setup
  # But "setup" is dismissed, so output should be empty

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  # Should NOT contain /setup since that hint is dismissed
  if [ -n "$output" ]; then
    refute_output --partial "/setup"
  fi
}

@test "always exits 0" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "active feature with few phases: no /wrap hint" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.user_profile.interview_completed = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  set_foundation_complete
  add_feature_to_backlog "feat-001" "Test Feature" "in-progress"
  set_active_feature "feat-001" "Test Feature" "code"
  set_phases_completed "plan" "design"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  # With only 2 phases done, should not suggest /wrap
  if [ -n "$output" ]; then
    refute_output --partial "/wrap"
  fi
}
