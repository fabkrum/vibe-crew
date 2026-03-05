#!/usr/bin/env bats
# tests/expertise-prime.bats

setup() {
  load 'test_helper/common-setup'
  WRITE_SCRIPT="$SCRIPTS_DIR/expertise-write.sh"
  SCRIPT="$SCRIPTS_DIR/expertise-prime.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/expertise"

  # Seed test records across domains
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain conventions --type convention --tier foundational --content 'Use semicolons in all TypeScript files' --confidence 0.90 --session-id 'session-test'" > /dev/null
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain patterns --type pattern --tier tactical --content 'Use barrel exports for component directories' --confidence 0.70 --session-id 'session-test'" > /dev/null
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain failures --type failure --tier observational --content 'Build fails with stale cache' --confidence 0.50 --session-id 'session-test'" > /dev/null
}

teardown() {
  teardown_vibecrew_dir
}

@test "generates markdown for builder agent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --agent builder"
  assert_success
  assert_output --partial "Expertise Context (builder)"
  assert_output --partial "Use semicolons"
}

@test "generates markdown for performance-coach agent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --agent performance-coach"
  assert_success
  assert_output --partial "Expertise Context (performance-coach)"
  assert_output --partial "Build fails with stale cache"
}

@test "outputs nothing when no expertise dir" {
  rm -rf "$VIBECREW_DIR/expertise"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --agent builder"
  assert_success
  [ -z "$output" ]
}

@test "requires agent parameter" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "--agent is required"
}

@test "includes tier markers" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --agent builder"
  assert_success
  assert_output --partial "[F]"
}
