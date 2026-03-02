#!/usr/bin/env bats
# tests/session-startup.bats
# Tests for scripts/session-startup.sh — SessionStart hook for environment check,
# state detection, and routing

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/session-startup.sh"

  # Upgrade schema versions to 1.5.0 so migrate-state.sh is a no-op.
  # This isolates session-startup logic from migration side effects.
  for f in "$VIBECREW_DIR/state.json" "$VIBECREW_DIR/backlog.json" "$VIBECREW_DIR/config.json"; do
    if [[ -f "$f" ]]; then
      local tmp="${f}.tmp"
      jq '.schema_version = "1.5.0"' "$f" > "$tmp" && mv "$tmp" "$f"
    fi
  done

  # Create a placeholder handoff file so the ls glob in session-startup.sh
  # does not fail under set -eo pipefail (ls exits non-zero when no files match).
  echo "## Next Steps" > "$VIBECREW_DIR/handoffs/handoff-placeholder.md"
}

teardown() {
  teardown_vibecrew_dir
}

# Helper to run session-startup.sh inside the test project directory
run_startup() {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
}

# =============================================================================
# 1. No .vibecrew dir: exits 0 with setup prompt
# =============================================================================

@test "no .vibecrew dir: exits 0 with setup message" {
  rm -rf "$VIBECREW_DIR"
  run_startup
  assert_success
  assert_output --partial "Not initialized"
  assert_output --partial "/setup"
}

# =============================================================================
# 2. Fresh project: no state.json
# =============================================================================

@test "fresh project without state.json: exits 0 with reinitialize message" {
  rm -f "$VIBECREW_DIR/state.json"
  run_startup
  assert_success
  assert_output --partial "State file missing"
  assert_output --partial "/setup"
}

# =============================================================================
# 3. Foundation incomplete state
# =============================================================================

@test "foundation incomplete: shows artifact progress and next step" {
  # Default state has foundation.complete = false, all artifacts pending (0/6)
  run_startup
  assert_success
  assert_output --partial "Foundation:"
  assert_output --partial "/6 artifacts complete"
  assert_output --partial "/new-project"
}

@test "foundation incomplete with some artifacts done: shows partial count" {
  # Mark 3 of 6 artifacts as complete
  jq '.foundation.artifacts.vision.status = "complete" |
      .foundation.artifacts.design_system.status = "complete" |
      .foundation.artifacts.tdr.status = "complete"' \
    "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"

  run_startup
  assert_success
  assert_output --partial "3/6 artifacts complete"
}

# =============================================================================
# 4. Foundation complete state
# =============================================================================

@test "foundation complete with no active feature: shows complete status" {
  set_foundation_complete
  run_startup
  assert_success
  assert_output --partial "Foundation: Complete"
  assert_output --partial "No active feature"
}

@test "foundation complete with backlog features: shows backlog counts" {
  set_foundation_complete
  add_feature_to_backlog "feat-001" "Auth System" "planned"
  add_feature_to_backlog "feat-002" "Dashboard" "planned"
  add_feature_to_backlog "feat-003" "Profile Page" "done"

  run_startup
  assert_success
  assert_output --partial "3 total"
  assert_output --partial "2 ready"
  assert_output --partial "1 done"
}

# =============================================================================
# 5. Active feature in progress
# =============================================================================

@test "active feature: shows feature name and phase" {
  set_foundation_complete
  add_feature_to_backlog "feat-001" "User Authentication" "in-progress"
  set_active_feature "feat-001" "User Authentication" "code"

  run_startup
  assert_success
  assert_output --partial "Feature: User Authentication"
  assert_output --partial "Phase: code"
}

# =============================================================================
# 6. Output is framed with --- delimiters (valid structured output)
# =============================================================================

@test "output is framed with --- delimiters" {
  set_foundation_complete
  run_startup
  assert_success

  # The script outputs lines starting and ending with ---
  local first_line last_line
  first_line=$(echo "$output" | head -1)
  last_line=$(echo "$output" | tail -1)
  [ "$first_line" = "---" ]
  [ "$last_line" = "---" ]
}

@test "output contains VibeCrew marker after opening delimiter" {
  set_foundation_complete
  run_startup
  assert_success

  # Second line should start with "VibeCrew"
  local second_line
  second_line=$(echo "$output" | sed -n '2p')
  [[ "$second_line" == VibeCrew* ]]
}

# =============================================================================
# 7. Missing config.json handled gracefully
# =============================================================================

@test "missing config.json: script still exits 0 and produces output" {
  rm -f "$VIBECREW_DIR/config.json"
  run_startup
  assert_success
  assert_output --partial "VibeCrew"
}

# =============================================================================
# 8. Corrupted state.json
# =============================================================================

@test "corrupted state.json (invalid JSON): exits 0 gracefully" {
  echo "this is not json{{{" > "$VIBECREW_DIR/state.json"
  run_startup
  assert_success
  # jq will fail to parse, defaults kick in (foundation=false, etc.)
  # Script should still produce output without crashing
  assert_output --partial "VibeCrew"
}

# =============================================================================
# 9. Error state: session-errors.jsonl with prior logged errors
# =============================================================================

@test "prior errors in session-errors.jsonl: script runs normally and exits 0" {
  # Simulate prior errors logged by other hooks
  cat > "$VIBECREW_DIR/session-errors.jsonl" <<'EOF'
{"timestamp":"2026-01-01T00:00:00Z","source":"phase-gate","message":"unexpected failure"}
{"timestamp":"2026-01-01T00:01:00Z","source":"sync-state","message":"lock contention"}
EOF

  run_startup
  assert_success
  # session-startup.sh always exits 0 (never blocks session startup)
  assert_output --partial "VibeCrew"
  assert_output --partial "---"
}
