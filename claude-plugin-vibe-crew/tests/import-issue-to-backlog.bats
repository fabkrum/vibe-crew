#!/usr/bin/env bats
# tests/import-issue-to-backlog.bats
# Tests for scripts/import-issue-to-backlog.sh — issue import (GitHub + GitLab)

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
  local provider="${5:-github}"
  local issue_file="$TEST_PROJECT_DIR/_issue_$number.json"
  local base_url="https://github.com/test/repo/issues/"
  if [[ "$provider" == "gitlab" ]]; then
    base_url="https://gitlab.com/test/repo/-/issues/"
  fi
  jq -n \
    --argjson number "$number" \
    --arg title "$title" \
    --argjson labels "$labels" \
    --arg body "$body" \
    --arg provider "$provider" \
    --arg base_url "$base_url" \
    '{
      status: "fetched",
      provider: $provider,
      issue_number: $number,
      title: $title,
      body: $body,
      url: ($base_url + ($number | tostring)),
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

# =============================================================================
# Generic issue_number/issue_url/provider fields
# =============================================================================

@test "imported entry uses issue_number and issue_url fields" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 50 "New fields test" '[]')

  cat "$issue_file" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  # Check the backlog entry uses generic field names
  local issue_num
  issue_num=$(jq -r '.features[0].issue_number' "$VIBECREW_DIR/backlog.json")
  [[ "$issue_num" == "50" ]]

  local issue_url
  issue_url=$(jq -r '.features[0].issue_url' "$VIBECREW_DIR/backlog.json")
  [[ "$issue_url" == *"/issues/50"* ]]

  # Should NOT have legacy github_issue_number
  local legacy
  legacy=$(jq -r '.features[0].github_issue_number // "absent"' "$VIBECREW_DIR/backlog.json")
  [[ "$legacy" == "absent" ]]
}

@test "imported entry includes provider field" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 51 "Provider test" '[]' "body" "github")

  cat "$issue_file" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  local provider
  provider=$(jq -r '.features[0].provider' "$VIBECREW_DIR/backlog.json")
  [[ "$provider" == "github" ]]
}

@test "gitlab issue import sets provider to gitlab" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 52 "GitLab test" '[]' "body" "gitlab")

  cat "$issue_file" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  local provider
  provider=$(jq -r '.features[0].provider' "$VIBECREW_DIR/backlog.json")
  [[ "$provider" == "gitlab" ]]

  local url
  url=$(jq -r '.features[0].issue_url' "$VIBECREW_DIR/backlog.json")
  [[ "$url" == *"gitlab.com"* ]]
}

@test "backlog labels use generic 'issue' instead of 'github-issue'" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 53 "Label test" '[]')

  cat "$issue_file" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  local label
  label=$(jq -r '.features[0].labels[0]' "$VIBECREW_DIR/backlog.json")
  [[ "$label" == "issue" ]]
}

@test "backlog source is 'issue' instead of 'github-issue'" {
  cd "$TEST_PROJECT_DIR"
  local issue_file
  issue_file=$(_write_issue 54 "Source test" '[]')

  cat "$issue_file" | bash "$SCRIPTS_DIR/import-issue-to-backlog.sh" >/dev/null

  local source
  source=$(jq -r '.features[0].source' "$VIBECREW_DIR/backlog.json")
  [[ "$source" == "issue" ]]
}

# =============================================================================
# Backward-compatible dedup with legacy github_issue_number
# =============================================================================

@test "dedup detects legacy github_issue_number entries" {
  cd "$TEST_PROJECT_DIR"

  # Manually add a legacy entry with github_issue_number
  local tmp
  tmp=$(jq '.features += [{
    "id": "feat-001",
    "name": "Legacy issue",
    "column": "planned",
    "priority": 1,
    "labels": ["github-issue"],
    "source": "github-issue",
    "github_issue_number": 60,
    "github_issue_url": "https://github.com/test/repo/issues/60",
    "phases_completed": [],
    "created_at": "2026-01-01T00:00:00Z",
    "updated_at": "2026-01-01T00:00:00Z"
  }]' "$VIBECREW_DIR/backlog.json")
  echo "$tmp" > "$VIBECREW_DIR/backlog.json"

  # Try to import issue #60 — should be detected as duplicate
  local issue_file
  issue_file=$(_write_issue 60 "Already exists" '[]')

  run bash -c "cat '$issue_file' | bash '$SCRIPTS_DIR/import-issue-to-backlog.sh'"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "duplicate" ]]

  local feature_id
  feature_id=$(echo "$output" | jq -r '.feature_id')
  [[ "$feature_id" == "feat-001" ]]
}
