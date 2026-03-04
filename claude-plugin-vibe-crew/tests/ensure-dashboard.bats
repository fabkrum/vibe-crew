#!/usr/bin/env bats
# tests/ensure-dashboard.bats
# Tests for scripts/ensure-dashboard.sh — dashboard liveness checker

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "no docs dir: exits 0 silently" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$TEST_PROJECT_DIR/docs"

  run bash "$SCRIPTS_DIR/ensure-dashboard.sh"
  assert_success
  [ -z "$output" ]
}

@test "no .vibecrew dir: exits 0 silently" {
  cd "$TEST_PROJECT_DIR"
  rm -rf "$VIBECREW_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  echo '{}' > "$TEST_PROJECT_DIR/docs/package.json"

  run bash "$SCRIPTS_DIR/ensure-dashboard.sh"
  assert_success
  [ -z "$output" ]
}

@test "stale PID: cleans up PID file" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  echo '{}' > "$TEST_PROJECT_DIR/docs/package.json"

  # Write a PID file pointing to a non-existent process
  echo '{"pid": 99999, "port": 5173, "started_at": "2026-01-01T00:00:00Z"}' \
    > "$VIBECREW_DIR/dashboard.pid"

  # Mock start-dashboard.sh to avoid actually launching
  mkdir -p "$SCRIPTS_DIR"
  local mock_start="$TEST_PROJECT_DIR/mock-start-dashboard.sh"
  cat > "$mock_start" <<'EOF'
#!/usr/bin/env bash
# Mock: just write a PID file and exit
VIBECREW_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)/.vibecrew"
echo "{\"pid\": $$, \"port\": 5173, \"started_at\": \"2026-01-01T00:00:00Z\"}" > "$VIBECREW_DIR/dashboard.pid"
EOF
  chmod +x "$mock_start"

  # Replace start-dashboard.sh path in ensure-dashboard.sh by symlinking
  # Instead, we verify the stale PID file gets removed
  # The ensure-dashboard.sh will try to launch start-dashboard.sh which won't exist in test env
  # but the PID file should be cleaned up before launch attempt

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/ensure-dashboard.sh' 2>/dev/null"
  assert_success
  # Stale PID file should have been removed (even if relaunch fails)
  if [[ -f "$VIBECREW_DIR/dashboard.pid" ]]; then
    local pid
    pid=$(jq -r '.pid // empty' "$VIBECREW_DIR/dashboard.pid" 2>/dev/null || echo "")
    # If PID file exists, it should NOT contain the stale PID 99999
    [ "$pid" != "99999" ]
  fi
}

@test "alive PID with port: reports URL and does not relaunch" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  echo '{}' > "$TEST_PROJECT_DIR/docs/package.json"

  # Use our own PID (guaranteed alive) and a port we can fake
  local my_pid=$$
  echo "{\"pid\": $my_pid, \"port\": 5173, \"started_at\": \"2026-01-01T00:00:00Z\"}" \
    > "$VIBECREW_DIR/dashboard.pid"

  # Mock lsof to report port as listening
  mock_command "lsof" 0 ""

  run bash "$SCRIPTS_DIR/ensure-dashboard.sh"
  assert_success
  [[ "$output" == *"http://localhost:5173"* ]]
}
