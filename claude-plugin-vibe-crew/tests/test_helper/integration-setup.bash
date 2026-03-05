#!/usr/bin/env bash
# tests/test_helper/integration-setup.bash
# Extended test helpers for integration tests.
# Loads common-setup.bash and adds multi-script chain runners,
# state assertion helpers, and fixture loaders.

# Load the base helper (provides setup_vibecrew_dir, mock_command, etc.)
INTEGRATION_TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
load "${INTEGRATION_TESTS_DIR}/test_helper/common-setup"

# Path to fixtures directory
FIXTURES_DIR="${INTEGRATION_TESTS_DIR}/fixtures"

# =============================================================================
# Fixture Loaders
# =============================================================================

load_fixture() {
  # Copy a fixture JSON file into the test project's .vibecrew/ directory
  # Usage: load_fixture "realistic-backlog-8-features.json" "backlog.json"
  local fixture_name="$1"
  local target_name="${2:-$fixture_name}"
  local source="$FIXTURES_DIR/$fixture_name"
  local target="$VIBECREW_DIR/$target_name"

  if [[ ! -f "$source" ]]; then
    echo "ERROR: Fixture not found: $source" >&2
    return 1
  fi

  cp "$source" "$target"
}

load_fixture_to() {
  # Copy a fixture JSON file to an arbitrary path in the test project
  # Usage: load_fixture_to "builder-signal-with-visual.json" "$VIBECREW_DIR/signals/builder-complete.signal"
  local fixture_name="$1"
  local target_path="$2"
  local source="$FIXTURES_DIR/$fixture_name"

  if [[ ! -f "$source" ]]; then
    echo "ERROR: Fixture not found: $source" >&2
    return 1
  fi

  mkdir -p "$(dirname "$target_path")"
  cp "$source" "$target_path"
}

# =============================================================================
# Multi-Script Chain Runners
# =============================================================================

run_complete_phase() {
  # Run complete-phase.sh with proper env, capture output
  # Usage: run_complete_phase <feature_id> <phase>
  #   or:  run_complete_phase foundation
  local args="$*"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/complete-phase.sh' $args"
}

run_claim_task() {
  # Run claim-task.sh with proper env
  # Usage: run_claim_task <agent-name> [feature-id]
  local args="$*"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/claim-task.sh' $args"
}

run_session_startup() {
  # Run session-startup.sh with proper env
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/session-startup.sh'"
}

run_migrate_state() {
  # Run migrate-state.sh with proper env
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/migrate-state.sh'"
}

run_sync_state() {
  # Run sync-state.sh with proper env
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/sync-state.sh'"
}

run_phase_gate() {
  # Run phase-gate.sh with hook input on stdin
  # Usage: echo '{"tool_name":"Write",...}' | run_phase_gate
  local input="$1"
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$input' | bash '$SCRIPTS_DIR/phase-gate.sh'"
}

run_protect_data() {
  # Run protect-data.sh with hook input on stdin
  local input="$1"
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$input' | bash '$SCRIPTS_DIR/protect-data.sh'"
}

run_validate_phase_transition() {
  # Run validate-phase-transition.sh with hook input on stdin
  local input="$1"
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$input' | bash '$SCRIPTS_DIR/validate-phase-transition.sh'"
}

run_restrict_paths() {
  # Run restrict-paths.sh with hook input on stdin
  local input="$1"
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$input' | bash '$SCRIPTS_DIR/restrict-paths.sh'"
}

run_validate_signal() {
  # Run validate-signal.sh with hook input on stdin
  local input="$1"
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$input' | bash '$SCRIPTS_DIR/validate-signal.sh'"
}

run_calculate_vibe_score() {
  # Run calculate-vibe-score.sh with project root arg
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/calculate-vibe-score.sh' '$TEST_PROJECT_DIR'"
}

run_generate_feature_docs() {
  # Run generate-feature-docs.sh
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/generate-feature-docs.sh'"
}

run_rebuild_sidebar() {
  # Run rebuild-sidebar.sh
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/rebuild-sidebar.sh'"
}

run_generate_handoff() {
  # Run generate-handoff.sh
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/generate-handoff.sh'"
}

run_format_code() {
  # Run format-code.sh with hook input on stdin
  local input="$1"
  run bash -c "cd '$TEST_PROJECT_DIR' && echo '$input' | bash '$SCRIPTS_DIR/format-code.sh'"
}

# =============================================================================
# Full Lifecycle Runner
# =============================================================================

run_full_feature_lifecycle() {
  # Chain: claim → plan → design → code → test → review → docs
  # Usage: run_full_feature_lifecycle <feature_id>
  # Returns 0 if all steps succeed, non-zero on first failure
  local feature_id="$1"
  local phases=("plan" "design" "code" "test" "review" "docs")

  # Claim the feature
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/claim-task.sh' builder '$feature_id'" || return 1

  # Complete each phase
  for phase in "${phases[@]}"; do
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/complete-phase.sh' '$feature_id' '$phase'" || return 1
  done

  return 0
}

run_trivial_feature_lifecycle() {
  # Trivial complexity: plan → code → test → docs (skips design + review)
  local feature_id="$1"
  local phases=("plan" "code" "test" "docs")

  bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/claim-task.sh' builder '$feature_id'" || return 1

  for phase in "${phases[@]}"; do
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPTS_DIR/complete-phase.sh' '$feature_id' '$phase'" || return 1
  done

  return 0
}

# =============================================================================
# State Assertion Helpers
# =============================================================================

assert_feature_column() {
  # Verify a feature's column in backlog.json
  # Usage: assert_feature_column <feature_id> <expected_column>
  local id="$1"
  local expected_column="$2"
  local actual
  actual=$(jq -r --arg id "$id" \
    '[.features[] | select(.id == $id) | .column] | .[0] // "NOT_FOUND"' \
    "$VIBECREW_DIR/backlog.json")
  [[ "$actual" == "$expected_column" ]] || {
    echo "Expected feature '$id' column='$expected_column', got='$actual'" >&2
    return 1
  }
}

assert_active_phase() {
  # Verify active_feature.phase in state.json
  # Usage: assert_active_phase <expected_phase>
  local expected="$1"
  local actual
  actual=$(jq -r '.active_feature.phase // "null"' "$VIBECREW_DIR/state.json")
  [[ "$actual" == "$expected" ]] || {
    echo "Expected active phase='$expected', got='$actual'" >&2
    return 1
  }
}

assert_active_feature_id() {
  # Verify active_feature.id in state.json
  local expected="$1"
  local actual
  actual=$(jq -r '.active_feature.id // "null"' "$VIBECREW_DIR/state.json")
  [[ "$actual" == "$expected" ]] || {
    echo "Expected active feature id='$expected', got='$actual'" >&2
    return 1
  }
}

assert_active_feature_cleared() {
  # Verify active feature is cleared (id is null)
  local id
  id=$(jq -r '.active_feature.id // "null"' "$VIBECREW_DIR/state.json")
  [[ "$id" == "null" ]] || {
    echo "Expected active feature cleared, got id='$id'" >&2
    return 1
  }
}

assert_phases_completed_contains() {
  # Check a phase is in phases_completed array (state.json)
  # Usage: assert_phases_completed_contains <phase>
  local phase="$1"
  local found
  found=$(jq --arg p "$phase" \
    '[.active_feature.phases_completed[]? | select(. == $p)] | length' \
    "$VIBECREW_DIR/state.json")
  [[ "$found" -gt 0 ]] || {
    echo "Expected '$phase' in phases_completed, not found" >&2
    return 1
  }
}

assert_phases_completed_count() {
  # Verify the number of completed phases
  local expected="$1"
  local actual
  actual=$(jq '.active_feature.phases_completed | length' "$VIBECREW_DIR/state.json")
  [[ "$actual" -eq "$expected" ]] || {
    echo "Expected $expected phases completed, got $actual" >&2
    return 1
  }
}

assert_backlog_phases_completed_contains() {
  # Check a phase is in phases_completed for a specific feature in backlog.json
  local feature_id="$1"
  local phase="$2"
  local found
  found=$(jq --arg id "$feature_id" --arg p "$phase" \
    '[.features[] | select(.id == $id) | .phases_completed[]? | select(. == $p)] | length' \
    "$VIBECREW_DIR/backlog.json")
  [[ "$found" -gt 0 ]] || {
    echo "Expected '$phase' in backlog phases_completed for '$feature_id', not found" >&2
    return 1
  }
}

assert_state_backlog_consistent() {
  # Cross-validate state.json phase against backlog.json column
  # The active feature's phase should correspond to its backlog column
  local feature_id
  feature_id=$(jq -r '.active_feature.id // "null"' "$VIBECREW_DIR/state.json")

  if [[ "$feature_id" == "null" ]]; then
    return 0  # No active feature, nothing to check
  fi

  local phase column
  phase=$(jq -r '.active_feature.phase // "null"' "$VIBECREW_DIR/state.json")
  column=$(jq -r --arg id "$feature_id" \
    '[.features[] | select(.id == $id) | .column] | .[0] // "NOT_FOUND"' \
    "$VIBECREW_DIR/backlog.json")

  # Phase-to-expected-column mapping (matches complete-phase.sh determine_next_column)
  local expected_column
  case "$phase" in
    plan)      expected_column="planned" ;;    # non-trivial default
    design)    expected_column="in-progress" ;;
    code)      expected_column="testing" ;;
    test)      expected_column="review" ;;
    review)    expected_column="review" ;;
    docs)      expected_column="done" ;;
    done)      expected_column="done" ;;
    *)         expected_column="unknown" ;;
  esac

  return 0
}

assert_no_journal_files() {
  # Verify no dual-write journals remain
  local journals
  journals=$(find "$VIBECREW_DIR/locks" -name "dual-write.journal" 2>/dev/null | wc -l | tr -d ' ')
  [[ "$journals" -eq 0 ]] || {
    echo "Found $journals stale journal file(s) in $VIBECREW_DIR/locks" >&2
    return 1
  }
}

assert_no_lock_dirs() {
  # Verify no stale lock directories remain
  local locks
  locks=$(find "$VIBECREW_DIR/locks" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  [[ "$locks" -eq 0 ]] || {
    echo "Found $locks stale lock dir(s) in $VIBECREW_DIR/locks" >&2
    return 1
  }
}

assert_foundation_complete() {
  local val
  val=$(jq -r '.foundation.complete // false' "$VIBECREW_DIR/state.json")
  [[ "$val" == "true" ]] || {
    echo "Expected foundation.complete=true, got='$val'" >&2
    return 1
  }
}

assert_foundation_incomplete() {
  local val
  val=$(jq -r '.foundation.complete // false' "$VIBECREW_DIR/state.json")
  [[ "$val" == "false" ]] || {
    echo "Expected foundation.complete=false, got='$val'" >&2
    return 1
  }
}

# =============================================================================
# Realistic State Builders
# =============================================================================

create_realistic_backlog() {
  # Build a backlog with 5+ features across multiple columns
  add_feature_to_backlog "feat-1" "Feature One" "done" 1
  add_feature_to_backlog "feat-2" "Feature Two" "done" 2
  add_feature_to_backlog "feat-3" "Feature Three" "in-progress" 3
  add_feature_to_backlog "feat-4" "Feature Four" "planned" 4
  add_feature_to_backlog "feat-5" "Feature Five" "planned" 5
  add_feature_to_backlog "feat-6" "Feature Six" "idea" 6
}

setup_git_history() {
  # Create some git commits so git-dependent scripts work
  local project_dir="${1:-$TEST_PROJECT_DIR}"

  # Create an initial commit
  touch "$project_dir/.gitkeep"
  git -C "$project_dir" add .gitkeep
  git -C "$project_dir" commit -m "feat: initial project setup" --allow-empty 2>/dev/null || \
    git -C "$project_dir" commit -m "feat: initial project setup" 2>/dev/null || true

  # Create a couple more commits
  echo "# Project" > "$project_dir/README.md"
  git -C "$project_dir" add README.md
  git -C "$project_dir" commit -m "docs: add README" 2>/dev/null || true

  echo '{"name":"test-project"}' > "$project_dir/package.json"
  git -C "$project_dir" add package.json
  git -C "$project_dir" commit -m "feat: add package.json" 2>/dev/null || true
}

mock_quality_tools() {
  # Mock npm/node/npx to prevent real package manager calls
  mock_command "npm" 0 ""
  mock_command "npx" 0 ""
  mock_command "node" 0 ""
  mock_command "bun" 0 ""
  mock_command "pnpm" 0 ""
  mock_command "yarn" 0 ""
}

mock_session_startup_externals() {
  # Mock all external tools that session-startup.sh calls
  mock_quality_tools
  mock_command "gh" 0 ""
  mock_command "terminal-notifier" 0 ""

  # Mock check-mcp-health.sh by creating a stub
  if [[ -z "${MOCK_BIN_DIR:-}" ]]; then
    MOCK_BIN_DIR="$(mktemp -d)"
    export PATH="$MOCK_BIN_DIR:$PATH"
  fi

  # Mock timeout/gtimeout
  mock_command "timeout" 0 ""
  mock_command "gtimeout" 0 ""
}

set_feature_complexity() {
  # Set the complexity field for a feature in backlog.json
  # Usage: set_feature_complexity <feature_id> <complexity>
  local feature_id="$1"
  local complexity="$2"
  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"

  jq --arg id "$feature_id" --arg c "$complexity" \
    '.features = [.features[] | if .id == $id then .complexity = $c else . end]' \
    "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"
}
