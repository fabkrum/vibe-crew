#!/usr/bin/env bats
# tests/setup-git-repo.bats
# Tests for scripts/setup-git-repo.sh — git repository initialization

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# Argument validation
# =============================================================================

@test "missing --provider: returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh"
  assert_failure

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]
  echo "$output" | jq -r '.message' | grep -qi "provider"
}

@test "invalid provider: returns error JSON" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider bitbucket
  assert_failure

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]
  echo "$output" | jq -r '.message' | grep -qi "invalid"
}

# =============================================================================
# Local provider — fresh directory
# =============================================================================

@test "local provider: git init, initial commit, config updated" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider local
  assert_success

  # Output is valid JSON
  echo "$output" | jq empty

  local status action provider
  status=$(echo "$output" | jq -r '.status')
  action=$(echo "$output" | jq -r '.action')
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$status" == "ok" ]]
  [[ "$action" == "created" ]]
  [[ "$provider" == "local" ]]

  # config.json updated
  local config_provider
  config_provider=$(jq -r '.git_provider' "$VIBECREW_DIR/config.json")
  [[ "$config_provider" == "local" ]]

  # state.json updated
  local git_init
  git_init=$(jq -r '.git.initialized' "$VIBECREW_DIR/state.json")
  [[ "$git_init" == "true" ]]

  # Git repo exists with at least one commit
  git -C "$TEST_PROJECT_DIR" log --oneline -1
}

# =============================================================================
# Existing repo WITHOUT remote + local provider
# =============================================================================

@test "existing repo without remote + local: marks as initialized" {
  cd "$TEST_PROJECT_DIR"
  # The test setup already initialized git, so just run with local
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider local
  assert_success

  local status action
  status=$(echo "$output" | jq -r '.status')
  action=$(echo "$output" | jq -r '.action')
  [[ "$status" == "ok" ]]
  [[ "$action" == "created" ]]

  local git_init
  git_init=$(jq -r '.git.initialized' "$VIBECREW_DIR/state.json")
  [[ "$git_init" == "true" ]]
}

# =============================================================================
# Existing repo WITH remote — auto-detect
# =============================================================================

@test "existing repo with github remote: detects existing, no repo creation" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git

  # Mock gh for repo info
  _mock_gh_for_detect

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider github
  assert_success

  local status action provider
  status=$(echo "$output" | jq -r '.status')
  action=$(echo "$output" | jq -r '.action')
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$status" == "ok" ]]
  [[ "$action" == "detected_existing" ]]
  [[ "$provider" == "github" ]]

  local config_provider
  config_provider=$(jq -r '.git_provider' "$VIBECREW_DIR/config.json")
  [[ "$config_provider" == "github" ]]
}

@test "existing repo with gitlab remote: detects existing" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  # Mock glab for repo info
  _mock_glab_for_detect

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider gitlab
  assert_success

  local status action provider
  status=$(echo "$output" | jq -r '.status')
  action=$(echo "$output" | jq -r '.action')
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$status" == "ok" ]]
  [[ "$action" == "detected_existing" ]]
  [[ "$provider" == "gitlab" ]]
}

# =============================================================================
# GitHub provider — fresh directory (mocked)
# =============================================================================

@test "github provider: gh repo create called, config set" {
  cd "$TEST_PROJECT_DIR"
  _mock_gh_create

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider github --repo-name test-repo
  assert_success

  local status action provider
  status=$(echo "$output" | jq -r '.status')
  action=$(echo "$output" | jq -r '.action')
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$status" == "ok" ]]
  [[ "$action" == "created" ]]
  [[ "$provider" == "github" ]]

  local config_provider
  config_provider=$(jq -r '.git_provider' "$VIBECREW_DIR/config.json")
  [[ "$config_provider" == "github" ]]
}

# =============================================================================
# GitLab provider — fresh directory (mocked)
# =============================================================================

@test "gitlab provider: glab repo create called, config set" {
  cd "$TEST_PROJECT_DIR"
  _mock_glab_create

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider gitlab --repo-name test-repo
  assert_success

  local status action provider
  status=$(echo "$output" | jq -r '.status')
  action=$(echo "$output" | jq -r '.action')
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$status" == "ok" ]]
  [[ "$action" == "created" ]]
  [[ "$provider" == "gitlab" ]]

  local config_provider
  config_provider=$(jq -r '.git_provider' "$VIBECREW_DIR/config.json")
  [[ "$config_provider" == "gitlab" ]]
}

# =============================================================================
# gh not installed when github chosen
# =============================================================================

@test "github chosen but gh not installed: error JSON, exit 1" {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  # Override PATH to exclude real gh
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider github
  assert_failure

  local status check
  status=$(echo "$output" | jq -r '.status')
  check=$(echo "$output" | jq -r '.check')
  [[ "$status" == "error" ]]
  [[ "$check" == "gh_installed" ]]
}

# =============================================================================
# gh not authenticated
# =============================================================================

@test "github chosen but gh not authenticated: error JSON, exit 1" {
  _mock_gh_unauthed

  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider github
  assert_failure

  local status check
  status=$(echo "$output" | jq -r '.status')
  check=$(echo "$output" | jq -r '.check')
  [[ "$status" == "error" ]]
  [[ "$check" == "gh_authenticated" ]]
}

# =============================================================================
# glab not installed when gitlab chosen
# =============================================================================

@test "gitlab chosen but glab not installed: error JSON, exit 1" {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider gitlab
  assert_failure

  local status check
  status=$(echo "$output" | jq -r '.status')
  check=$(echo "$output" | jq -r '.check')
  [[ "$status" == "error" ]]
  [[ "$check" == "glab_installed" ]]
}

# =============================================================================
# Visibility flag
# =============================================================================

@test "visibility flag: --public passed to gh" {
  cd "$TEST_PROJECT_DIR"
  _mock_gh_create_capture_args

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider github --visibility public --repo-name test-repo
  assert_success

  # Check that --public was passed (captured in mock args file)
  local args
  args=$(cat "$TEST_PROJECT_DIR/.gh-args" 2>/dev/null || echo "")
  echo "$args" | grep -q "\-\-public"
}

@test "visibility flag: --private is default" {
  cd "$TEST_PROJECT_DIR"
  _mock_gh_create_capture_args

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider github --repo-name test-repo
  assert_success

  local args
  args=$(cat "$TEST_PROJECT_DIR/.gh-args" 2>/dev/null || echo "")
  echo "$args" | grep -q "\-\-private"
}

# =============================================================================
# Output is always valid JSON
# =============================================================================

@test "output is valid JSON on local success" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider local
  assert_success
  echo "$output" | jq empty
}

@test "output is valid JSON on error" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider bitbucket
  echo "$output" | jq empty
}

# =============================================================================
# Idempotent: running twice does not fail
# =============================================================================

@test "idempotent: running local twice succeeds" {
  cd "$TEST_PROJECT_DIR"
  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider local
  assert_success

  run bash "$SCRIPTS_DIR/setup-git-repo.sh" --provider local
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "ok" ]]
}

# =============================================================================
# Helpers — gh/glab mocks for setup-git-repo tests
# =============================================================================

_mock_gh_for_detect() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<'GHEOF'
#!/usr/bin/env bash
if [[ "$1" == "repo" && "$2" == "view" ]]; then
  echo "testuser/test-repo"
  exit 0
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

_mock_glab_for_detect() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/glab" <<'GLABEOF'
#!/usr/bin/env bash
if [[ "$1" == "repo" && "$2" == "view" ]]; then
  echo '{"full_name":"testuser/test-repo"}'
  exit 0
fi
exit 0
GLABEOF
  chmod +x "$MOCK_BIN_DIR/glab"
}

_mock_gh_create() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<'GHEOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "Logged in to github.com as testuser"
  exit 0
elif [[ "$1" == "repo" && "$2" == "create" ]]; then
  # Simulate repo creation — add a remote
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  git -C "$PROJECT_ROOT" remote add origin "https://github.com/testuser/test-repo.git" 2>/dev/null || true
  git -C "$PROJECT_ROOT" add -A 2>/dev/null || true
  git -C "$PROJECT_ROOT" commit -m "chore: initialize project" --allow-empty 2>/dev/null || true
  echo "Created repository testuser/test-repo on GitHub"
  exit 0
elif [[ "$1" == "repo" && "$2" == "view" ]]; then
  echo "testuser/test-repo"
  exit 0
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

_mock_glab_create() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/glab" <<'GLABEOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "Logged in to gitlab.com as testuser"
  exit 0
elif [[ "$1" == "repo" && "$2" == "create" ]]; then
  # Simulate repo creation — add a remote
  PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  git -C "$PROJECT_ROOT" remote add origin "https://gitlab.com/testuser/test-repo.git" 2>/dev/null || true
  echo "Created repository testuser/test-repo on GitLab"
  exit 0
elif [[ "$1" == "repo" && "$2" == "view" ]]; then
  echo '{"full_name":"testuser/test-repo","web_url":"https://gitlab.com/testuser/test-repo"}'
  exit 0
fi
exit 0
GLABEOF
  chmod +x "$MOCK_BIN_DIR/glab"
}

_mock_gh_unauthed() {
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

_mock_gh_create_capture_args() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<GHEOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
  echo "Logged in to github.com as testuser"
  exit 0
elif [[ "\$1" == "repo" && "\$2" == "create" ]]; then
  # Capture all args to a file for test assertions
  echo "\$@" > "$TEST_PROJECT_DIR/.gh-args"
  PROJECT_ROOT="\$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  git -C "\$PROJECT_ROOT" remote add origin "https://github.com/testuser/test-repo.git" 2>/dev/null || true
  git -C "\$PROJECT_ROOT" add -A 2>/dev/null || true
  git -C "\$PROJECT_ROOT" commit -m "chore: initialize project" --allow-empty 2>/dev/null || true
  echo "Created repository testuser/test-repo on GitHub"
  exit 0
elif [[ "\$1" == "repo" && "\$2" == "view" ]]; then
  echo "testuser/test-repo"
  exit 0
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}
