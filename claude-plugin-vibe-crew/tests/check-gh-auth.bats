#!/usr/bin/env bats
# tests/check-gh-auth.bats
# Tests for scripts/check-gh-auth.sh — provider auth validation (GitHub + GitLab)

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# Helper: create a smart gh mock that responds based on subcommand
_mock_gh_full() {
  # All checks pass by default
  local auth_exit="${1:-0}"
  local auth_msg="${2:-Logged in to github.com as testuser}"
  local repo_exit="${3:-0}"
  local repo_output="${4:-testuser/test-repo}"

  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<GHEOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
  echo '$auth_msg'
  exit $auth_exit
elif [[ "\$1" == "repo" && "\$2" == "view" ]]; then
  echo '$repo_output'
  exit $repo_exit
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

# =============================================================================
# gh not installed
# =============================================================================

@test "gh not installed: status is error with not found message" {
  # Remove any gh from PATH by pointing to an empty dir
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  # Override PATH to exclude real gh
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "gh_installed" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"not found"* ]]
}

# =============================================================================
# gh not authenticated
# =============================================================================

@test "gh not authenticated: status is error" {
  _mock_gh_full 1 "not logged in"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "gh_authenticated" ]]
}

# =============================================================================
# No git remote
# =============================================================================

@test "no git remote: status is error with provider_detect check" {
  _mock_gh_full 0 "Logged in"

  cd "$TEST_PROJECT_DIR"
  # No remote added — provider detection returns "unknown"

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "provider_detect" ]]
}

# =============================================================================
# Repo not accessible
# =============================================================================

@test "repo not accessible: status is error with repo_access check" {
  # gh auth passes but gh repo view fails (empty output)
  _mock_gh_full 0 "Logged in" 1 ""

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "repo_access" ]]

  # Should include remote_url in error output
  local remote
  remote=$(echo "$output" | jq -r '.remote_url')
  [[ "$remote" == *"test-repo"* ]]
}

# =============================================================================
# All checks pass
# =============================================================================

@test "all checks pass: status is ok with repo info" {
  _mock_gh_full 0 "Logged in to github.com as testuser" 0 "testuser/test-repo"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "ok" ]]

  local repo
  repo=$(echo "$output" | jq -r '.repo')
  [[ "$repo" == "testuser/test-repo" ]]

  local remote
  remote=$(echo "$output" | jq -r '.remote_url')
  [[ "$remote" == *"test-repo"* ]]
}

# =============================================================================
# Output is always valid JSON
# =============================================================================

@test "output is valid JSON on success" {
  _mock_gh_full 0 "Logged in" 0 "testuser/test-repo"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success
  echo "$output" | jq empty
}

@test "output is valid JSON on auth failure" {
  _mock_gh_full 1 "not logged in"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success
  echo "$output" | jq empty
}

# =============================================================================
# Always exits 0
# =============================================================================

@test "always exits 0 regardless of failure type" {
  # No gh installed at all
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success
}

@test "github success includes provider field" {
  _mock_gh_full 0 "Logged in" 0 "testuser/test-repo"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local provider
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$provider" == "github" ]]
}

# =============================================================================
# GitLab provider — glab CLI
# =============================================================================

# Helper: create a smart glab mock
_mock_glab_full() {
  local auth_exit="${1:-0}"
  local auth_msg="${2:-Logged in to gitlab.com as testuser}"
  local repo_exit="${3:-0}"
  local repo_output="${4-{\"full_name\":\"testuser/test-repo\"}}"

  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/glab" <<GLABEOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
  echo '$auth_msg'
  exit $auth_exit
elif [[ "\$1" == "repo" && "\$2" == "view" ]]; then
  echo '$repo_output'
  exit $repo_exit
fi
exit 0
GLABEOF
  chmod +x "$MOCK_BIN_DIR/glab"
}

@test "gitlab: glab not installed returns error" {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "glab_installed" ]]
}

@test "gitlab: glab not authenticated returns error" {
  _mock_glab_full 1 "not logged in"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "glab_authenticated" ]]
}

@test "gitlab: repo not accessible returns error" {
  _mock_glab_full 0 "Logged in" 1 ""

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "repo_access" ]]
}

@test "gitlab: all checks pass with provider gitlab" {
  _mock_glab_full 0 "Logged in" 0 '{"full_name":"testuser/test-repo"}'

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "ok" ]]

  local provider
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$provider" == "gitlab" ]]

  local repo
  repo=$(echo "$output" | jq -r '.repo')
  [[ "$repo" == "testuser/test-repo" ]]
}

# =============================================================================
# Unknown provider
# =============================================================================

@test "unknown provider: returns error with config suggestion" {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://bitbucket.org/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/check-gh-auth.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local check
  check=$(echo "$output" | jq -r '.check')
  [[ "$check" == "provider_detect" ]]
}
