#!/usr/bin/env bats
# tests/git-provider.bats
# Tests for scripts/lib/git-provider.sh — provider detection and helpers

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  # Source the library under test
  source "$SCRIPTS_DIR/lib/git-provider.sh"
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# _provider_detect — GitHub remote
# =============================================================================

@test "detect: github.com remote returns github" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "github" ]]
}

@test "detect: github.com SSH remote returns github" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin git@github.com:user/repo.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "github" ]]
}

# =============================================================================
# _provider_detect — GitLab remote
# =============================================================================

@test "detect: gitlab.com remote returns gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/user/repo.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "gitlab" ]]
}

@test "detect: gitlab.com SSH remote returns gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin git@gitlab.com:user/repo.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "gitlab" ]]
}

@test "detect: self-hosted gitlab.example.com returns gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.example.com/team/project.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "gitlab" ]]
}

@test "detect: self-hosted gitlab.corp.io returns gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin git@gitlab.corp.io:team/project.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "gitlab" ]]
}

# =============================================================================
# _provider_detect — config override
# =============================================================================

@test "detect: config override github takes precedence" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/user/repo.git

  # Override via config
  local tmp
  tmp=$(jq '. + {git_provider: "github"}' "$VIBECREW_DIR/config.json")
  echo "$tmp" > "$VIBECREW_DIR/config.json"

  local result
  result=$(_provider_detect)
  [[ "$result" == "github" ]]
}

@test "detect: config override gitlab takes precedence" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git

  local tmp
  tmp=$(jq '. + {git_provider: "gitlab"}' "$VIBECREW_DIR/config.json")
  echo "$tmp" > "$VIBECREW_DIR/config.json"

  local result
  result=$(_provider_detect)
  [[ "$result" == "gitlab" ]]
}

@test "detect: config override null falls through to remote" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git

  local tmp
  tmp=$(jq '. + {git_provider: null}' "$VIBECREW_DIR/config.json")
  echo "$tmp" > "$VIBECREW_DIR/config.json"

  local result
  result=$(_provider_detect)
  [[ "$result" == "github" ]]
}

# =============================================================================
# _provider_detect — unknown/no remote
# =============================================================================

@test "detect: unknown remote returns unknown" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://bitbucket.org/user/repo.git

  local result
  result=$(_provider_detect)
  [[ "$result" == "unknown" ]]
}

@test "detect: no remote returns unknown" {
  cd "$TEST_PROJECT_DIR"
  # No remote added

  local result
  result=$(_provider_detect)
  [[ "$result" == "unknown" ]]
}

# =============================================================================
# _provider_cli
# =============================================================================

@test "cli: returns gh for github" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git

  local result
  result=$(_provider_cli)
  [[ "$result" == "gh" ]]
}

@test "cli: returns glab for gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/user/repo.git

  local result
  result=$(_provider_cli)
  [[ "$result" == "glab" ]]
}

@test "cli: returns empty for unknown" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://bitbucket.org/user/repo.git

  local result
  result=$(_provider_cli)
  [[ -z "$result" ]]
}

# =============================================================================
# _provider_mr_term
# =============================================================================

@test "mr_term: returns PR for github" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git

  local result
  result=$(_provider_mr_term)
  [[ "$result" == "PR" ]]
}

@test "mr_term: returns MR for gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/user/repo.git

  local result
  result=$(_provider_mr_term)
  [[ "$result" == "MR" ]]
}

# =============================================================================
# _provider_close_keyword
# =============================================================================

@test "close_keyword: returns Fixes for github" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git

  local result
  result=$(_provider_close_keyword)
  [[ "$result" == "Fixes" ]]
}

@test "close_keyword: returns Closes for gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/user/repo.git

  local result
  result=$(_provider_close_keyword)
  [[ "$result" == "Closes" ]]
}

# =============================================================================
# _provider_cli_installed
# =============================================================================

@test "cli_installed: returns true when gh exists for github" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/user/repo.git
  mock_command "gh" 0

  _provider_cli_installed
}

@test "cli_installed: returns false when glab missing for gitlab" {
  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/user/repo.git

  # Ensure glab is not in PATH
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  ! _provider_cli_installed
}
