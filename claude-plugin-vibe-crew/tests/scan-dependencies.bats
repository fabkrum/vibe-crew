#!/usr/bin/env bats
# tests/scan-dependencies.bats
# Tests for scripts/scan-dependencies.sh — multi-language dependency vulnerability audit

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# =============================================================================
# No lockfiles present
# =============================================================================

@test "no lockfiles: all results are no_lockfile" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  local npm_status
  npm_status=$(echo "$output" | jq -r '.results.npm.status')
  [[ "$npm_status" == "no_lockfile" ]]

  local pip_status
  pip_status=$(echo "$output" | jq -r '.results.pip.status')
  [[ "$pip_status" == "no_lockfile" ]]

  local bundle_status
  bundle_status=$(echo "$output" | jq -r '.results.bundle.status')
  [[ "$bundle_status" == "no_lockfile" ]]

  local go_status
  go_status=$(echo "$output" | jq -r '.results.go.status')
  [[ "$go_status" == "no_lockfile" ]]

  local cargo_status
  cargo_status=$(echo "$output" | jq -r '.results.cargo.status')
  [[ "$cargo_status" == "no_lockfile" ]]

  local composer_status
  composer_status=$(echo "$output" | jq -r '.results.composer.status')
  [[ "$composer_status" == "no_lockfile" ]]
}

# =============================================================================
# npm
# =============================================================================

@test "npm lockfile present but npm not available" {
  cd "$TEST_PROJECT_DIR"
  touch "$TEST_PROJECT_DIR/package-lock.json"

  # Strip PATH to exclude real npm
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  # Include git so script can find project root, but exclude npm
  local git_path
  git_path=$(which git)
  local git_dir
  git_dir=$(dirname "$git_path")
  local jq_path
  jq_path=$(which jq)
  local jq_dir
  jq_dir=$(dirname "$jq_path")
  local date_path
  date_path=$(which date)
  local date_dir
  date_dir=$(dirname "$date_path")
  export PATH="$MOCK_BIN_DIR:$git_dir:$jq_dir:$date_dir"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  local npm_status
  npm_status=$(echo "$output" | jq -r '.results.npm.status')
  [[ "$npm_status" == "tool_not_installed" ]]
}

@test "npm lockfile present with mock npm" {
  cd "$TEST_PROJECT_DIR"
  touch "$TEST_PROJECT_DIR/package-lock.json"

  # Mock npm audit --json to return sample data
  local npm_audit_output
  npm_audit_output=$(cat <<'AUDITEOF'
{"metadata":{"vulnerabilities":{"critical":1,"high":2,"moderate":3,"low":4,"info":0},"totalDependencies":50},"vulnerabilities":{"lodash":{},"express":{}}}
AUDITEOF
  )

  mock_command "npm" 0 "$npm_audit_output"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  local npm_status
  npm_status=$(echo "$output" | jq -r '.results.npm.status')
  [[ "$npm_status" == "scanned" ]]

  local critical
  critical=$(echo "$output" | jq '.results.npm.vulnerabilities.critical')
  [[ "$critical" == "1" ]]

  local high
  high=$(echo "$output" | jq '.results.npm.vulnerabilities.high')
  [[ "$high" == "2" ]]
}

# =============================================================================
# Python
# =============================================================================

@test "python requirements.txt present but pip-audit missing" {
  cd "$TEST_PROJECT_DIR"
  touch "$TEST_PROJECT_DIR/requirements.txt"

  # Strip PATH to exclude real pip-audit
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  local git_path
  git_path=$(which git)
  local git_dir
  git_dir=$(dirname "$git_path")
  local jq_path
  jq_path=$(which jq)
  local jq_dir
  jq_dir=$(dirname "$jq_path")
  local date_path
  date_path=$(which date)
  local date_dir
  date_dir=$(dirname "$date_path")
  export PATH="$MOCK_BIN_DIR:$git_dir:$jq_dir:$date_dir"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  local pip_status
  pip_status=$(echo "$output" | jq -r '.results.pip.status')
  [[ "$pip_status" == "tool_not_installed" ]]
}

# =============================================================================
# Go
# =============================================================================

@test "go.mod present but govulncheck missing" {
  cd "$TEST_PROJECT_DIR"
  echo 'module example.com/test' > "$TEST_PROJECT_DIR/go.mod"

  # Strip PATH to exclude real govulncheck
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  local git_path
  git_path=$(which git)
  local git_dir
  git_dir=$(dirname "$git_path")
  local jq_path
  jq_path=$(which jq)
  local jq_dir
  jq_dir=$(dirname "$jq_path")
  local date_path
  date_path=$(which date)
  local date_dir
  date_dir=$(dirname "$date_path")
  export PATH="$MOCK_BIN_DIR:$git_dir:$jq_dir:$date_dir"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  local go_status
  go_status=$(echo "$output" | jq -r '.results.go.status')
  [[ "$go_status" == "tool_not_installed" ]]
}

# =============================================================================
# Timestamp and JSON validation
# =============================================================================

@test "output has scanned_at timestamp" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  local scanned_at
  scanned_at=$(echo "$output" | jq -r '.scanned_at')
  [[ "$scanned_at" != "null" ]]
  [[ "$scanned_at" == *"T"* ]]
  [[ "$scanned_at" == *"Z" ]]
}

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success
  echo "$output" | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"

  # No lockfiles
  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success

  # With lockfile but missing tool
  touch "$TEST_PROJECT_DIR/package-lock.json"
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
  fi
  local git_path
  git_path=$(which git)
  local git_dir
  git_dir=$(dirname "$git_path")
  local jq_path
  jq_path=$(which jq)
  local jq_dir
  jq_dir=$(dirname "$jq_path")
  local date_path
  date_path=$(which date)
  local date_dir
  date_dir=$(dirname "$date_path")
  export PATH="$MOCK_BIN_DIR:$git_dir:$jq_dir:$date_dir"

  run bash "$SCRIPTS_DIR/scan-dependencies.sh"
  assert_success
}
