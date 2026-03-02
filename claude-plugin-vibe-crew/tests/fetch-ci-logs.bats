#!/usr/bin/env bats
# tests/fetch-ci-logs.bats
# Tests for scripts/fetch-ci-logs.sh — CI failure log fetching (GitHub + GitLab)

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# Helper: create a mock gh that returns a failed run and logs
_mock_gh_with_failed_run() {
  local log_content="${1:-Error: test failed on line 42}"
  local log_failed_empty="${2:-false}"

  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<GHEOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
  echo "Logged in to github.com as testuser"
  exit 0
elif [[ "\$1" == "run" && "\$2" == "list" ]]; then
  echo '[{"databaseId":12345,"displayTitle":"CI Build","conclusion":"failure","headBranch":"feature-x","createdAt":"2026-01-15T10:00:00Z"}]'
  exit 0
elif [[ "\$1" == "run" && "\$2" == "view" ]]; then
  # Check if --log-failed or --log flag is present
  for arg in "\$@"; do
    if [[ "\$arg" == "--log-failed" ]]; then
      if [[ "$log_failed_empty" == "true" ]]; then
        echo ""
        exit 0
      else
        echo '$log_content'
        exit 0
      fi
    fi
    if [[ "\$arg" == "--log" ]]; then
      echo '$log_content'
      exit 0
    fi
  done
  exit 0
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

# Helper: mock gh with no failed runs
_mock_gh_no_failures() {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/gh" <<'GHEOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "Logged in to github.com as testuser"
  exit 0
elif [[ "$1" == "run" && "$2" == "list" ]]; then
  echo '[]'
  exit 0
fi
exit 0
GHEOF
  chmod +x "$MOCK_BIN_DIR/gh"
}

# =============================================================================
# gh not available
# =============================================================================

@test "gh not available: returns error JSON" {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  # Strip PATH to exclude real gh
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"not found"* ]]
}

# =============================================================================
# gh not authenticated
# =============================================================================

@test "gh not authenticated: returns error JSON" {
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

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "error" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"not authenticated"* ]]
}

# =============================================================================
# No failed runs
# =============================================================================

@test "no failed runs: returns no_failures status" {
  _mock_gh_no_failures

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "no_failures" ]]

  local msg
  msg=$(echo "$output" | jq -r '.message')
  [[ "$msg" == *"No failed"* ]]
}

# =============================================================================
# Successful log fetch
# =============================================================================

@test "failed run found: returns fetched status with run details" {
  _mock_gh_with_failed_run "FAIL: expected 1 got 2"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "fetched" ]]

  local run_id
  run_id=$(echo "$output" | jq -r '.run_id')
  [[ "$run_id" == "12345" ]]

  local title
  title=$(echo "$output" | jq -r '.title')
  [[ "$title" == "CI Build" ]]

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  [[ "$branch" == "feature-x" ]]

  # Log content should be present
  local log
  log=$(echo "$output" | jq -r '.log')
  [[ "$log" == *"FAIL"* ]]
}

# =============================================================================
# Log truncation at 500 lines
# =============================================================================

@test "log truncation: large logs are truncated to 500 lines" {
  # Generate a log with 800 lines
  local long_log=""
  for i in $(seq 1 800); do
    long_log+="Line $i: some CI output here"$'\n'
  done

  _mock_gh_with_failed_run "$long_log"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local log_lines
  log_lines=$(echo "$output" | jq -r '.log_lines')
  [[ "$log_lines" -le 501 ]]  # tail -n 500 plus possible trailing newline

  local total_lines
  total_lines=$(echo "$output" | jq -r '.total_lines')
  [[ "$total_lines" -ge 800 ]]

  local truncated
  truncated=$(echo "$output" | jq -r '.truncated')
  [[ "$truncated" == "true" ]]
}

# =============================================================================
# Fallback from --log-failed to --log
# =============================================================================

@test "fallback: uses --log when --log-failed returns empty" {
  _mock_gh_with_failed_run "Fallback log output from full log" "true"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "fetched" ]]

  local log
  log=$(echo "$output" | jq -r '.log')
  [[ "$log" == *"Fallback log output"* ]]
}

# =============================================================================
# Output is always valid JSON
# =============================================================================

@test "output is valid JSON in all cases" {
  # Test with no gh available
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  export PATH="$MOCK_BIN_DIR:/usr/bin:/bin"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success
  echo "$output" | jq empty

  # Test with no failures
  cleanup_mocks
  _mock_gh_no_failures

  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success
  echo "$output" | jq empty

  # Test with successful fetch
  cleanup_mocks
  _mock_gh_with_failed_run "some error"

  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success
  echo "$output" | jq empty
}

@test "github success includes provider field" {
  _mock_gh_with_failed_run "error line"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://github.com/testuser/test-repo.git
  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local provider
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$provider" == "github" ]]
}

# =============================================================================
# GitLab provider — glab CI
# =============================================================================

_mock_glab_with_failed_pipeline() {
  local log_content="${1:-Error: test failed on line 42}"

  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/glab" <<GLABEOF
#!/usr/bin/env bash
if [[ "\$1" == "auth" && "\$2" == "status" ]]; then
  echo "Logged in to gitlab.com as testuser"
  exit 0
elif [[ "\$1" == "ci" && "\$2" == "list" ]]; then
  echo '[{"id":99999,"ref":"feature-x","status":"failed","created_at":"2026-01-15T10:00:00Z"}]'
  exit 0
elif [[ "\$1" == "ci" && "\$2" == "view" ]]; then
  echo '{"jobs":[{"id":55555,"status":"failed","name":"test-job"}]}'
  exit 0
elif [[ "\$1" == "ci" && "\$2" == "trace" ]]; then
  echo '$log_content'
  exit 0
fi
exit 0
GLABEOF
  chmod +x "$MOCK_BIN_DIR/glab"
}

@test "gitlab: fetch failed pipeline returns fetched with provider" {
  _mock_glab_with_failed_pipeline "FAIL: assertion error"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "fetched" ]]

  local provider
  provider=$(echo "$output" | jq -r '.provider')
  [[ "$provider" == "gitlab" ]]

  local log
  log=$(echo "$output" | jq -r '.log')
  [[ "$log" == *"FAIL"* ]]
}

@test "gitlab: pipeline-to-job resolution uses trace" {
  _mock_glab_with_failed_pipeline "Job 55555 failed: exit code 1"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local run_id
  run_id=$(echo "$output" | jq -r '.run_id')
  [[ "$run_id" == "99999" ]]

  local branch
  branch=$(echo "$output" | jq -r '.branch')
  [[ "$branch" == "feature-x" ]]
}

@test "gitlab: no failed pipelines returns no_failures" {
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  cat > "$MOCK_BIN_DIR/glab" <<'GLABEOF'
#!/usr/bin/env bash
if [[ "$1" == "auth" && "$2" == "status" ]]; then
  echo "Logged in"
  exit 0
elif [[ "$1" == "ci" && "$2" == "list" ]]; then
  echo '[]'
  exit 0
fi
exit 0
GLABEOF
  chmod +x "$MOCK_BIN_DIR/glab"

  cd "$TEST_PROJECT_DIR"
  git remote add origin https://gitlab.com/testuser/test-repo.git

  run bash "$SCRIPTS_DIR/fetch-ci-logs.sh"
  assert_success

  local status
  status=$(echo "$output" | jq -r '.status')
  [[ "$status" == "no_failures" ]]
}
