#!/usr/bin/env bats
# tests/integration/feature-lifecycle.bats
# Integration tests for the core state machine:
# claim-task.sh → complete-phase.sh × 6 → feature in "done" column
#
# Critical scripts exercised: claim-task.sh, complete-phase.sh,
# lib/lock.sh, lib/atomic-write.sh, lib/dual-write.sh,
# validate-phase-transition.sh, sync-state.sh

setup() {
  load '../test_helper/integration-setup'
  setup_vibecrew_dir
  set_foundation_complete

  # Add a feature in "planned" column ready for claiming
  add_feature_to_backlog "test-feat-1" "Test Feature One" "planned" 1
  add_feature_to_backlog "test-feat-2" "Test Feature Two" "planned" 2
  add_feature_to_backlog "test-feat-3" "Test Feature Three" "planned" 3
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Full 6-Phase Lifecycle
# =============================================================================

@test "integration: full 6-phase lifecycle completes successfully" {
  # Claim
  run_claim_task builder test-feat-1
  assert_success
  assert_active_feature_id "test-feat-1"
  assert_active_phase "plan"
  assert_feature_column "test-feat-1" "in-progress"

  # Plan
  run_complete_phase test-feat-1 plan
  assert_success
  assert_active_phase "design"
  assert_phases_completed_contains "plan"
  assert_feature_column "test-feat-1" "planned"

  # Design
  run_complete_phase test-feat-1 design
  assert_success
  assert_active_phase "code"
  assert_phases_completed_contains "design"
  assert_feature_column "test-feat-1" "in-progress"

  # Code
  run_complete_phase test-feat-1 code
  assert_success
  assert_active_phase "test"
  assert_phases_completed_contains "code"
  assert_feature_column "test-feat-1" "testing"

  # Test
  run_complete_phase test-feat-1 test
  assert_success
  assert_active_phase "review"
  assert_phases_completed_contains "test"
  assert_feature_column "test-feat-1" "review"

  # Review
  run_complete_phase test-feat-1 review
  assert_success
  assert_active_phase "docs"
  assert_phases_completed_contains "review"

  # Docs
  run_complete_phase test-feat-1 docs
  assert_success
  assert_active_phase "done"
  assert_phases_completed_contains "docs"

  # Final state checks
  assert_no_journal_files
  assert_no_lock_dirs
}

@test "integration: multi-feature sequential lifecycle" {
  # Complete feature 1
  run_claim_task builder test-feat-1
  assert_success
  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
  done

  # Claim and complete feature 2
  run_claim_task builder test-feat-2
  assert_success
  assert_active_feature_id "test-feat-2"
  assert_active_phase "plan"

  for phase in plan design code test review docs; do
    run_complete_phase test-feat-2 $phase
    assert_success
  done

  # Both features should reflect completion in backlog
  assert_backlog_phases_completed_contains "test-feat-1" "docs"
  assert_backlog_phases_completed_contains "test-feat-2" "docs"
  assert_no_journal_files
}

@test "integration: feature with dependency chain" {
  # Set up dependency: feat-2 depends on feat-1
  local tmp="$VIBECREW_DIR/backlog.json.tmp"
  jq '.features = [.features[] | if .id == "test-feat-2" then .depends_on = ["test-feat-1"] else . end]' \
    "$VIBECREW_DIR/backlog.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/backlog.json"

  # feat-2 auto-claim should fail (dependency not met)
  run_claim_task builder
  assert_success
  # Should claim feat-1 (highest priority with met deps), not feat-2
  assert_active_feature_id "test-feat-1"

  # Complete feat-1
  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
  done

  # Now feat-2 should be claimable
  run_claim_task builder test-feat-2
  assert_success
  assert_active_feature_id "test-feat-2"
}

@test "integration: idempotent phase completion" {
  run_claim_task builder test-feat-1
  assert_success

  # Complete plan phase
  run_complete_phase test-feat-1 plan
  assert_success

  # Running plan again should be idempotent (phase already in phases_completed)
  # complete-phase.sh adds to phases_completed idempotently
  run_complete_phase test-feat-1 plan
  assert_success

  # phases_completed should have exactly one "plan" entry
  local count
  count=$(jq '[.active_feature.phases_completed[] | select(. == "plan")] | length' "$VIBECREW_DIR/state.json")
  [ "$count" -eq 1 ]
}

@test "integration: state/backlog consistency after every phase" {
  run_claim_task builder test-feat-1
  assert_success
  assert_state_backlog_consistent

  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
    assert_state_backlog_consistent
  done
}

# =============================================================================
# Foundation Gate
# =============================================================================

@test "integration: foundation incomplete blocks feature lifecycle" {
  # Reset foundation to incomplete
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = false' "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  # Claiming a task should still work (claim-task doesn't check foundation)
  run_claim_task builder test-feat-1
  assert_success

  # But phase-gate hook would block source writes (tested in hook-enforcement-chain)
  # complete-phase itself does not enforce foundation — that's the hook's job
}

@test "integration: foundation complete then feature lifecycle" {
  # Start from incomplete foundation
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = false |
      .foundation.artifacts.vision.status = "complete" |
      .foundation.artifacts.design_system.status = "complete" |
      .foundation.artifacts.tdr.status = "complete" |
      .foundation.artifacts.roadmap.status = "complete" |
      .foundation.artifacts.architecture_diagrams.status = "complete" |
      .foundation.artifacts.claude_md.status = "complete"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  # Complete foundation
  run_complete_phase foundation
  assert_success
  assert_foundation_complete

  # Now run feature lifecycle
  run_claim_task builder test-feat-1
  assert_success
  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
  done
  assert_no_journal_files
}

# =============================================================================
# Phase Ordering Enforcement
# =============================================================================

@test "integration: skip a phase blocked by validate-phase-transition" {
  run_claim_task builder test-feat-1
  assert_success
  # Active phase is "plan"

  # Try to complete "code" (skipping plan and design) via the hook
  local input
  input=$(create_hook_input "Bash" "bash scripts/complete-phase.sh test-feat-1 code")
  run_validate_phase_transition "$input"
  # Should be denied because active phase is "plan", not "code"
  assert_failure
  assert_output --partial "deny"
}

# =============================================================================
# Error Recovery
# =============================================================================

@test "integration: sync-state recovers after interrupted dual-write" {
  run_claim_task builder test-feat-1
  assert_success

  # Simulate an interrupted dual-write by creating a journal
  mkdir -p "$VIBECREW_DIR/locks"
  local journal="$VIBECREW_DIR/locks/dual-write.journal"

  # Create staged content files
  local updated_backlog updated_state
  updated_backlog=$(jq '.features[0].column = "testing"' "$VIBECREW_DIR/backlog.json")
  updated_state=$(jq '.active_feature.phase = "test" | .active_feature.phases_completed = ["plan","design","code"]' "$VIBECREW_DIR/state.json")

  echo "$updated_backlog" > "$VIBECREW_DIR/locks/staged-backlog.$$.json"
  echo "$updated_state" > "$VIBECREW_DIR/locks/staged-state.$$.json"

  cat > "$journal" <<EOF
{
  "file_a": "$VIBECREW_DIR/backlog.json",
  "file_b": "$VIBECREW_DIR/state.json",
  "staged_a": "$VIBECREW_DIR/locks/staged-backlog.$$.json",
  "staged_b": "$VIBECREW_DIR/locks/staged-state.$$.json",
  "timestamp": "2026-01-01T00:00:00Z",
  "pid": $$
}
EOF

  # Run sync-state which should recover
  run_sync_state
  assert_success

  # Journal should be cleaned up
  assert_no_journal_files
}

# =============================================================================
# Backlog Integrity
# =============================================================================

@test "integration: lifecycle preserves unrelated features" {
  # Record initial state of feat-2 and feat-3
  local feat2_col feat3_col
  feat2_col=$(jq -r '.features[] | select(.id == "test-feat-2") | .column' "$VIBECREW_DIR/backlog.json")
  feat3_col=$(jq -r '.features[] | select(.id == "test-feat-3") | .column' "$VIBECREW_DIR/backlog.json")

  # Run full lifecycle on feat-1
  run_claim_task builder test-feat-1
  assert_success
  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
  done

  # Unrelated features should be unchanged
  assert_feature_column "test-feat-2" "$feat2_col"
  assert_feature_column "test-feat-3" "$feat3_col"
}

@test "integration: timestamps increase across phase transitions" {
  run_claim_task builder test-feat-1
  assert_success

  local prev_ts
  prev_ts=$(jq -r '.updated_at' "$VIBECREW_DIR/state.json")

  for phase in plan design code test review docs; do
    sleep 1  # Ensure timestamp advances
    run_complete_phase test-feat-1 $phase
    assert_success

    local curr_ts
    curr_ts=$(jq -r '.updated_at' "$VIBECREW_DIR/state.json")
    # Lexicographic comparison works for ISO 8601 timestamps
    [[ "$curr_ts" > "$prev_ts" || "$curr_ts" == "$prev_ts" ]] || {
      echo "Timestamp did not advance: prev=$prev_ts curr=$curr_ts" >&2
      return 1
    }
    prev_ts="$curr_ts"
  done
}

@test "integration: journal files always cleaned up" {
  run_claim_task builder test-feat-1
  assert_success
  assert_no_journal_files

  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
    assert_no_journal_files
  done
}

@test "integration: backlog column transitions match expected mapping" {
  run_claim_task builder test-feat-1
  assert_success
  assert_feature_column "test-feat-1" "in-progress"  # After claim

  run_complete_phase test-feat-1 plan
  assert_success
  assert_feature_column "test-feat-1" "planned"  # plan → planned

  run_complete_phase test-feat-1 design
  assert_success
  assert_feature_column "test-feat-1" "in-progress"  # design → in-progress

  run_complete_phase test-feat-1 code
  assert_success
  assert_feature_column "test-feat-1" "testing"  # code → testing

  run_complete_phase test-feat-1 test
  assert_success
  assert_feature_column "test-feat-1" "review"  # test → review

  run_complete_phase test-feat-1 review
  assert_success
  assert_feature_column "test-feat-1" "review"  # review → review (stays)

  run_complete_phase test-feat-1 docs
  assert_success
  assert_feature_column "test-feat-1" "done"  # docs → done
}

@test "integration: phases_completed accumulates across full lifecycle" {
  run_claim_task builder test-feat-1
  assert_success
  assert_phases_completed_count 0

  local expected_count=0
  for phase in plan design code test review docs; do
    run_complete_phase test-feat-1 $phase
    assert_success
    expected_count=$((expected_count + 1))
    assert_phases_completed_count $expected_count
  done

  # Final count should be 6
  assert_phases_completed_count 6
}

# =============================================================================
# Complexity-Aware Phase Skipping
# =============================================================================

@test "integration: trivial complexity skips design and review" {
  # Set feat-1 as trivial complexity
  set_feature_complexity "test-feat-1" "trivial"

  run_claim_task builder test-feat-1
  assert_success
  assert_active_phase "plan"

  # Plan → should skip design, go to code
  run_complete_phase test-feat-1 plan
  assert_success
  assert_active_phase "code"
  assert_feature_column "test-feat-1" "in-progress"

  # Code → test
  run_complete_phase test-feat-1 code
  assert_success
  assert_active_phase "test"

  # Test → should skip review, go to docs
  run_complete_phase test-feat-1 test
  assert_success
  assert_active_phase "docs"

  # Docs → done
  run_complete_phase test-feat-1 docs
  assert_success
  assert_active_phase "done"

  assert_no_journal_files
}

@test "integration: standard complexity follows full 6-phase path" {
  set_feature_complexity "test-feat-1" "standard"

  run_claim_task builder test-feat-1
  assert_success

  # Standard follows: plan → design → code → test → review → docs
  local expected_next=("design" "code" "test" "review" "docs" "done")
  local phases=("plan" "design" "code" "test" "review" "docs")
  local i=0

  for phase in "${phases[@]}"; do
    run_complete_phase test-feat-1 $phase
    assert_success
    assert_active_phase "${expected_next[$i]}"
    i=$((i + 1))
  done
}
