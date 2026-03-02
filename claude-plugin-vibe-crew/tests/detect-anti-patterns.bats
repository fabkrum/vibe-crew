#!/usr/bin/env bats
# tests/detect-anti-patterns.bats
# Tests for scripts/detect-anti-patterns.sh — recurring deduction scanner

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "no scores directory returns empty patterns" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$VIBECREW_DIR/scores"

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success
  echo "$output" | jq empty

  local count
  count=$(echo "$output" | jq '.total_sessions')
  [[ "$count" == "0" ]]

  local patterns_len
  patterns_len=$(echo "$output" | jq '.patterns | length')
  [[ "$patterns_len" == "0" ]]
}

@test "empty scores directory returns empty patterns" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success

  local patterns_len
  patterns_len=$(echo "$output" | jq '.patterns | length')
  [[ "$patterns_len" == "0" ]]
}

@test "single score file with no deductions" {
  cd "$TEST_PROJECT_DIR"
  echo '{"session_id":"s-1","deductions":[]}' > "$VIBECREW_DIR/scores/score-001.json"

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success

  local total
  total=$(echo "$output" | jq '.total_sessions')
  [[ "$total" == "1" ]]

  local patterns_len
  patterns_len=$(echo "$output" | jq '.patterns | length')
  [[ "$patterns_len" == "0" ]]
}

@test "single score file with deductions" {
  cd "$TEST_PROJECT_DIR"
  cat > "$VIBECREW_DIR/scores/score-001.json" <<'EOF'
{"session_id":"s-1","deductions":[{"category":"no-tests","points":-10},{"category":"prompt-churn","points":-5}]}
EOF

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success

  local patterns_len
  patterns_len=$(echo "$output" | jq '.patterns | length')
  [[ "$patterns_len" == "2" ]]
}

@test "multiple files with recurring deductions aggregated correctly" {
  cd "$TEST_PROJECT_DIR"
  cat > "$VIBECREW_DIR/scores/score-001.json" <<'EOF'
{"session_id":"s-1","deductions":[{"category":"no-tests","points":-10}]}
EOF
  cat > "$VIBECREW_DIR/scores/score-002.json" <<'EOF'
{"session_id":"s-2","deductions":[{"category":"no-tests","points":-10},{"category":"prompt-churn","points":-5}]}
EOF
  cat > "$VIBECREW_DIR/scores/score-003.json" <<'EOF'
{"session_id":"s-3","deductions":[{"category":"no-tests","points":-10}]}
EOF

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success

  # no-tests appears in 3 sessions — should be first (sorted by session_count)
  local top_category
  top_category=$(echo "$output" | jq -r '.patterns[0].category')
  [[ "$top_category" == "no-tests" ]]

  local top_session_count
  top_session_count=$(echo "$output" | jq '.patterns[0].session_count')
  [[ "$top_session_count" == "3" ]]

  local top_count
  top_count=$(echo "$output" | jq '.patterns[0].count')
  [[ "$top_count" == "3" ]]
}

@test "total_sessions matches file count" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4; do
    echo '{"session_id":"s-'$i'","deductions":[]}' > "$VIBECREW_DIR/scores/score-00$i.json"
  done

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success

  local total
  total=$(echo "$output" | jq '.total_sessions')
  [[ "$total" == "4" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  echo '{"session_id":"s-1","deductions":[{"category":"x","points":-5}]}' > "$VIBECREW_DIR/scores/score-001.json"

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success
  echo "$output" | jq empty
}

@test "caps at 10 most recent score files" {
  cd "$TEST_PROJECT_DIR"
  for i in $(seq 1 15); do
    printf -v padded "%03d" "$i"
    echo '{"session_id":"s-'$i'","deductions":[{"category":"x","points":-5}]}' > "$VIBECREW_DIR/scores/score-$padded.json"
  done

  run bash "$SCRIPTS_DIR/detect-anti-patterns.sh"
  assert_success

  local total
  total=$(echo "$output" | jq '.total_sessions')
  [[ "$total" == "10" ]]
}
