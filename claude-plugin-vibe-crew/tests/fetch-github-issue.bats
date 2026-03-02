#!/usr/bin/env bats
# tests/fetch-github-issue.bats
# Tests for scripts/fetch-github-issue.sh — GitHub issue fetching

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# Helper: create a mock gh that passes auth and returns issue data
_mock_gh_with_issue() {
  local issue_state="${1:-OPEN}"
  local issue_json
  issue_json=$(cat <<IJEOF
{"number":42,"title":"Fix login bug","body":"The login page crashes","labels":[{"name":"bug"}],"state":"$issue_state","url":"https://github.com/testuser/test-repo/issues/42","author":{"login":"testuser"},"assignees":[{"login":"dev1"}],"createdAt":"2026-01-15T10:00:00Z","updatedAt":"2026-01-16T12:00:00Z"}
IJEOF
  )

  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<GHEOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
  echo "Logged in to github.com as testuser"
  exit 0
elif [[ "\$1" == "repo" && "\$2" == "view" ]]; then
  echo "testuser/test-repo"
  exit 0
elif [[ "\$1" == "issue" && "\$2" == "view" ]]; then
  echo '$issue_json'
  exit 0
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

# Helper: mock gh where issue fetch fails (not found)
_mock_gh_issue_not_found() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<'GHEOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "Logged in to github.com as testuser"
  exit 0
elif [[ "$1" == "repo" && "$2" == "view" ]]; then
  echo "testuser/test-repo"
  exit 0
elif [[ "$1" == "issue" && "$2" == "view" ]]; then
  echo "issue not found"
  exit 1
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

# Helper: mock gh where auth fails
_mock_gh_auth_fail() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<'GHEOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "not logged in"
  exit 1
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

# =============================================================================
# Argument validation
# =============================================================================

@test "no arguments: returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/fetch-github-issue.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"Usage"* ]]
}

@test "non-numeric argument: returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "abc"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"Invalid issue number"* ]]
}

@test "zero as issue number: returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "0"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"Invalid issue number"* ]]
}

# =============================================================================
# Auth failure propagation
# =============================================================================

@test "auth failure: propagates check-gh-auth error" {
  _mock_gh_auth_fail

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "42"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "gh_authenticated" ]]
}

# =============================================================================
# Successful fetch
# =============================================================================

@test "successful fetch: returns restructured issue data" {
  _mock_gh_with_issue "OPEN"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "42"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "fetched" ]]

  local title
  title=$(echo "$output" | jq -r '.title')
  [[ "$title" == "Fix login bug" ]]

  local issue_number
  issue_number=$(echo "$output" | jq -r '.issue_number')
  [[ "$issue_number" == "42" ]]

  local author
  author=$(echo "$output" | jq -r '.author')
  [[ "$author" == "testuser" ]]

  # Labels should be a flat array of strings
  local label
  label=$(echo "$output" | jq -r '.labels[0]')
  [[ "$label" == "bug" ]]
}

# =============================================================================
# Closed issue rejection
# =============================================================================

@test "closed issue: returns error with closed message" {
  _mock_gh_with_issue "CLOSED"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "42"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"closed"* ]]
}

# =============================================================================
# Issue not found
# =============================================================================

@test "issue not found: returns error JSON" {
  _mock_gh_issue_not_found

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "999"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"Failed to fetch"* ]]
}

# =============================================================================
# Output is always valid JSON
# =============================================================================

@test "output is valid JSON in all cases" {
  _mock_gh_with_issue "OPEN"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  # Success case
  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "42"
  assert_success
  echo "$output" | jq empty

  # No-args case
  run bash "$SCRIPTS_DIR/fetch-github-issue.sh"
  assert_success
  echo "$output" | jq empty

  # Invalid arg case
  run bash "$SCRIPTS_DIR/fetch-github-issue.sh" "abc"
  assert_success
  echo "$output" | jq empty
}
