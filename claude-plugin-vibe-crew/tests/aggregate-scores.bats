#!/usr/bin/env bats
# tests/aggregate-scores.bats
# Tests for scripts/aggregate-scores.sh — score trend analysis

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

@test "no scores directory returns unknown direction" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$VIBECREW_DIR/scores"

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local dir
  dir=$(echo "$output" | jq -r '.direction')
  [[ "$dir" == "unknown" ]]
}

@test "insufficient data (<3 files) returns plateau" {
  cd "$TEST_PROJECT_DIR"
  echo '{"score":80,"session_id":"s-1","timestamp":"2026-01-01T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-001.json"
  echo '{"score":85,"session_id":"s-2","timestamp":"2026-01-02T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-002.json"

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local dir
  dir=$(echo "$output" | jq -r '.direction')
  [[ "$dir" == "plateau" ]]
}

@test "improving trend detected" {
  cd "$TEST_PROJECT_DIR"
  # ls -1t sorts newest first. Script: first_half=newest, second_half=oldest
  # "improving" = DIFF (second-first) > 5, so oldest scores must be higher than newest
  # Create files oldest→newest (score-001 created first = oldest in ls -t = last)
  # Decreasing scores so newest (first in ls -t) has low, oldest (last) has high
  local scores=(82 80 78 69 67 65)
  for i in "${!scores[@]}"; do
    local idx=$((i + 1))
    echo '{"score":'"${scores[$i]}"',"session_id":"s-'$idx'","timestamp":"2026-01-0'$idx'T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-00$idx.json"
    sleep 0.1  # ensure different mtime
  done

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local dir
  dir=$(echo "$output" | jq -r '.direction')
  [[ "$dir" == "improving" ]]
}

@test "declining trend detected" {
  cd "$TEST_PROJECT_DIR"
  # Increasing scores: newest (first in ls -t) has high, oldest (last) has low
  local scores=(65 67 69 78 80 82)
  for i in "${!scores[@]}"; do
    local idx=$((i + 1))
    echo '{"score":'"${scores[$i]}"',"session_id":"s-'$idx'","timestamp":"2026-01-0'$idx'T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-00$idx.json"
    sleep 0.1
  done

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local dir
  dir=$(echo "$output" | jq -r '.direction')
  [[ "$dir" == "declining" ]]
}

@test "average score calculation" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4; do
    echo '{"score":80,"session_id":"s-'$i'","timestamp":"2026-01-0'$i'T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-00$i.json"
  done

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local avg
  avg=$(echo "$output" | jq '.average_score')
  [[ "$avg" == "80" ]]
}

@test "recurring patterns detected" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4; do
    echo '{"score":75,"session_id":"s-'$i'","timestamp":"2026-01-0'$i'T00:00:00Z","deductions":[{"category":"no-tests","points":-10}]}' > "$VIBECREW_DIR/scores/score-00$i.json"
  done

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local patterns_len
  patterns_len=$(echo "$output" | jq '.top_recurring_patterns | length')
  [[ "$patterns_len" -ge 1 ]]

  local top_pattern
  top_pattern=$(echo "$output" | jq -r '.top_recurring_patterns[0].category')
  [[ "$top_pattern" == "no-tests" ]]
}

@test "window_size matches file count" {
  cd "$TEST_PROJECT_DIR"
  for i in 1 2 3 4 5; do
    echo '{"score":80,"session_id":"s-'$i'","timestamp":"2026-01-0'$i'T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-00$i.json"
  done

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local ws
  ws=$(echo "$output" | jq '.window_size')
  [[ "$ws" == "5" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success
  echo "$output" | jq empty
}

@test "scores array contains individual scores" {
  cd "$TEST_PROJECT_DIR"
  echo '{"score":85,"session_id":"s-1","timestamp":"2026-01-01T00:00:00Z","deductions":[]}' > "$VIBECREW_DIR/scores/score-001.json"

  run bash "$SCRIPTS_DIR/aggregate-scores.sh"
  assert_success

  local score_val
  score_val=$(echo "$output" | jq '.scores[0].score')
  [[ "$score_val" == "85" ]]
}
