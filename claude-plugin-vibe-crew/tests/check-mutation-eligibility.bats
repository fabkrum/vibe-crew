#!/usr/bin/env bats
# tests/check-mutation-eligibility.bats
# Tests for scripts/check-mutation-eligibility.sh — mutation eligibility guardrails

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "ineligible: fewer than 5 sessions" {
  cd "$TEST_PROJECT_DIR"
  # Create only 3 score files
  for i in 1 2 3; do
    echo '{"session_id":"s-'$i'","deductions":[]}' > "$VIBECREW_DIR/scores/score-$i.json"
  done

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
  echo "$output" | jq -r '.reason' | grep -q "Minimum 5 sessions"
}

@test "eligible: 5+ sessions, no pattern" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo '{"session_id":"s-'$i'","deductions":[]}' > "$VIBECREW_DIR/scores/score-$i.json"
  done

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "true" ]]
}

@test "ineligible: pattern seen in fewer than 3 of last 10 sessions" {
  cd "$TEST_PROJECT_DIR"
  # Create 5 score files, only 2 have the pattern
  for i in 1 2 3 4 5; do
    if [[ $i -le 2 ]]; then
      echo '{"session_id":"s-'$i'","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-$i.json"
    else
      echo '{"session_id":"s-'$i'","deductions":[]}' > "$VIBECREW_DIR/scores/score-$i.json"
    fi
  done

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh" --pattern "no-tests"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
  echo "$output" | jq -r '.reason' | grep -q "2/10 sessions"
}

@test "eligible: pattern seen in 3+ of last 10 sessions" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    if [[ $i -le 3 ]]; then
      echo '{"session_id":"s-'$i'","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-$i.json"
    else
      echo '{"session_id":"s-'$i'","deductions":[]}' > "$VIBECREW_DIR/scores/score-$i.json"
    fi
  done

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh" --pattern "no-tests"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "true" ]]
}

@test "ineligible: already applied mutation for this pattern" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo '{"session_id":"s-'$i'","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-$i.json"
  done
  # Create mutation log with already-applied mutation
  cat > "$VIBECREW_DIR/mutation-log.json" <<'EOF'
{"mutations":[{"reasoning":"no-tests","status":"applied","session_id":"s-old"}]}
EOF

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh" --pattern "no-tests"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
  echo "$output" | jq -r '.reason' | grep -q "already applied"
}

@test "ineligible: pattern rejected 3+ times (cooldown)" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo '{"session_id":"s-'$i'","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-$i.json"
  done
  # Create mutation log with 3 rejections
  cat > "$VIBECREW_DIR/mutation-log.json" <<'EOF'
{"mutations":[
  {"reasoning":"no-tests","status":"rejected","session_id":"s-1"},
  {"reasoning":"no-tests","status":"rejected","session_id":"s-2"},
  {"reasoning":"no-tests","status":"rejected","session_id":"s-3"}
]}
EOF

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh" --pattern "no-tests"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
  echo "$output" | jq -r '.reason' | grep -q "rejected 3 times"
}

@test "ineligible: performance coach disabled" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo '{"session_id":"s-'$i'","deductions":[]}' > "$VIBECREW_DIR/scores/score-$i.json"
  done
  # Disable performance coach
  jq '.performance_coach = {"enabled": false}' "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" && \
    mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
  echo "$output" | jq -r '.reason' | grep -q "disabled"
}

@test "ineligible: max 1 mutation per session" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo '{"session_id":"s-'$i'","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-$i.json"
  done
  # Latest score has session_id that matches a mutation log entry
  echo '{"session_id":"current-session","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-latest.json"
  cat > "$VIBECREW_DIR/mutation-log.json" <<'EOF'
{"mutations":[{"reasoning":"other-pattern","status":"proposed","session_id":"current-session"}]}
EOF

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh" --pattern "no-tests"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
  echo "$output" | jq -r '.reason' | grep -q "Max 1 mutation per session"
}

@test "no scores directory: ineligible" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$VIBECREW_DIR/scores"

  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh"
  assert_success

  local eligible
  eligible=$(echo "$output" | jq -r '.eligible')
  [[ "$eligible" == "false" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/check-mutation-eligibility.sh"
  assert_success
  echo "$output" | jq empty
}
