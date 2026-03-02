#!/usr/bin/env bats
# tests/import-issue-to-backlog.bats
# Tests for scripts/import-issue-to-backlog.sh — GitHub issue import

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# Helper: write a valid fetched issue JSON to a temp file, return path
_write_issue() {
  local number="${1:-42}"
  local title="${2:-Fix login bug}"
  local labels="${3:-[]}"
  local body="${4:-A bug description}"
  local issue_file="$TEST_PROJECT_DIR/_issue_$number.json"
  jq -n \
    --argjson number "$number" \
    --arg title "$title" \
    --argjson labels "$labels" \
    --arg body "$body" \
    '{
      status: "fetched",
      issue_number: $number,
      title: $title,
      body: $body,
      url: ("https://github.com/test/repo/issues/" + ($number | tostring)),
      labels: $labels
    }' > "$issue_file"
  echo "$issue_file"
}

@test "bug issue imports as hotfix in planned column" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 1 "Fix crash on login" '["bug"]')
  run bash -c "cat '$issue_file' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh'"
  assert_success

  local result
  result=$(echo "$output" | jq -r '.status')
  [[ "$result" == "imported" ]]

  local type
  type=$(echo "$output" | jq -r '.type')
  [[ "$type" == "hotfix" ]]

  local column
  column=$(echo "$output" | jq -r '.column')
  [[ "$column" == "planned" ]]
}

@test "enhancement issue imports as feature in idea column" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 2 "Add dark mode" '["enhancement"]')
  run bash -c "cat '$issue_file' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh'"
  assert_success

  local type
  type=$(echo "$output" | jq -r '.type')
  [[ "$type" == "feature" ]]

  local column
  column=$(echo "$output" | jq -r '.column')
  [[ "$column" == "idea" ]]
}

@test "--full flag forces feature type regardless of labels" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 3 "Urgent fix" '["bug"]')
  run bash -c "cat '$issue_file' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh' --full"
  assert_success

  local type
  type=$(echo "$output" | jq -r '.type')
  [[ "$type" == "feature" ]]

  local column
  column=$(echo "$output" | jq -r '.column')
  [[ "$column" == "idea" ]]
}

@test "duplicate detection prevents re-import" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 10 "First import" '[]')

  # Import once
  cat "$issue_file" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  # Import same issue number again
  run bash -c "cat '$issue_file' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh'"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "duplicate" ]]
}

@test "sequential feat ID generation" {
  cd "$TEST_PROJECT_DIR"
  local issue1 issue2
  issue1=$(_write_issue 20 "First" '[]')
  issue2=$(_write_issue 21 "Second" '[]')

  cat "$issue1" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null
  cat "$issue2" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  # Check IDs are sequential
  local id1 id2
  id1=$(jq -r '.features[0].id' "$VIBECREW_DIR/backlog.json")
  id2=$(jq -r '.features[1].id' "$VIBECREW_DIR/backlog.json")
  [[ "$id1" == "feat-001" ]]
  [[ "$id2" == "feat-002" ]]
}

@test "invalid JSON input is rejected" {
  cd "$TEST_PROJECT_DIR"
  run bash -c "echo 'not json' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh'"
  assert_success  # Exit 0 with error in JSON output

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"Invalid JSON"* ]]
}

@test "non-fetched status is rejected" {
  cd "$TEST_PROJECT_DIR"
  run bash -c "echo '{\"status\":\"error\",\"message\":\"not found\"}' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh'"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]
}
