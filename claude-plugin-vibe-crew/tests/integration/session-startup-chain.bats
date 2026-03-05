#!/usr/bin/env bats
# tests/integration/session-startup-chain.bats
# Integration tests for session-startup.sh → migrate-state.sh → sync-state.sh
#
# Critical scripts exercised: session-startup.sh, migrate-state.sh,
# sync-state.sh, lib/error-log.sh

setup() {
  load '../test_helper/integration-setup'
  setup_vibecrew_dir
  mock_session_startup_externals
}

teardown() {
  cleanup_mocks
  teardown_vibecrew_dir
}

# =============================================================================
# Schema Migration Chain
# =============================================================================

@test "integration: cold start with old schema 1.0.0 migrates to current" {
  # Write a 1.0.0-era state.json (minimal, no onboarded, no active_workflow)
  cat > "$VIBECREW_DIR/state.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "foundation": {
    "complete": false,
    "completed_at": null,
    "artifacts": {
      "vision": { "status": "pending", "file": null, "approved_at": null },
      "design_system": { "status": "pending", "file": null, "approved_at": null },
      "tdr": { "status": "pending", "file": null, "approved_at": null },
      "roadmap": { "status": "pending", "file": null, "approved_at": null },
      "claude_md": { "status": "pending", "file": null, "approved_at": null }
    }
  },
  "active_feature": {
    "id": null,
    "name": null,
    "worktree": null,
    "phase": null,
    "phases_completed": []
  },
  "git": { "default_branch": "main", "initialized": false },
  "updated_at": "2026-01-01T00:00:00Z"
}
EOF

  # Write a 1.0.0 config.json
  cat > "$VIBECREW_DIR/config.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "terminal": "other",
  "notifications": { "enabled": true },
  "gamification": { "enabled": false }
}
EOF

  # Run migration
  run_migrate_state
  assert_success

  # Verify schema bumped to current
  local state_ver config_ver
  state_ver=$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")
  config_ver=$(jq -r '.schema_version' "$VIBECREW_DIR/config.json")

  [ "$state_ver" = "1.6.0" ]
  [ "$config_ver" = "1.6.0" ]

  # Verify 1.1.0 migration: onboarded field exists (value is false, so use has())
  [ "$(jq 'has("onboarded")' "$VIBECREW_DIR/state.json")" = "true" ]

  # Verify 1.3.0 migration: active_workflow exists (value is null, so use has())
  [ "$(jq 'has("active_workflow")' "$VIBECREW_DIR/state.json")" = "true" ]

  # Verify 1.4.0 migration: user_profile exists in config
  [ "$(jq 'has("user_profile")' "$VIBECREW_DIR/config.json")" = "true" ]

  # Verify 1.5.0 migration: quality_gate, pricing, locks exist
  [ "$(jq 'has("quality_gate")' "$VIBECREW_DIR/config.json")" = "true" ]

  # Verify 1.6.0 migration: git_provider exists (value is null, so use has())
  [ "$(jq 'has("git_provider")' "$VIBECREW_DIR/config.json")" = "true" ]
}

@test "integration: migration from 1.2.0 adds intermediate versions" {
  cat > "$VIBECREW_DIR/state.json" <<'EOF'
{
  "schema_version": "1.2.0",
  "foundation": {
    "complete": false,
    "completed_at": null,
    "artifacts": {
      "vision": { "status": "pending", "file": null, "approved_at": null },
      "design_system": { "status": "pending", "file": null, "approved_at": null },
      "tdr": { "status": "pending", "file": null, "approved_at": null },
      "roadmap": { "status": "pending", "file": null, "approved_at": null },
      "architecture_diagrams": { "status": "pending", "file": null, "approved_at": null },
      "claude_md": { "status": "pending", "file": null, "approved_at": null }
    }
  },
  "active_feature": { "id": null, "name": null, "worktree": null, "phase": null, "phases_completed": [] },
  "onboarded": false,
  "onboarded_at": null,
  "git": { "default_branch": "main", "initialized": false },
  "updated_at": "2026-01-01T00:00:00Z"
}
EOF

  cat > "$VIBECREW_DIR/config.json" <<'EOF'
{
  "schema_version": "1.2.0",
  "terminal": "other",
  "notifications": { "enabled": true },
  "gamification": { "enabled": false },
  "performance_coach": { "auto_mutate": false },
  "doc_generator": { "auto_changelog": true },
  "onboarding": { "show_hints": true },
  "audit": { "auto_github_issues": false, "severity_threshold": "high" }
}
EOF

  run_migrate_state
  assert_success

  local state_ver
  state_ver=$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")
  [ "$state_ver" = "1.6.0" ]

  # 1.3.0 additions: active_workflow exists (value is null, so use has())
  [ "$(jq 'has("active_workflow")' "$VIBECREW_DIR/state.json")" = "true" ]

  # 1.4.0 additions: user_profile.interview_completed exists (value is false, so use has())
  [ "$(jq '.user_profile | has("interview_completed")' "$VIBECREW_DIR/config.json")" = "true" ]
}

# =============================================================================
# Sync-State Repairs
# =============================================================================

@test "integration: orphaned active feature cleared by sync-state" {
  set_foundation_complete
  set_active_feature "nonexistent-feat" "Ghost Feature" "code"

  run_sync_state
  assert_success
  assert_output --partial "Cleared"

  # Active feature should be cleared
  local id
  id=$(jq -r '.active_feature.id // "null"' "$VIBECREW_DIR/state.json")
  [ "$id" = "null" ]
}

@test "integration: phase/column mismatch repaired by sync-state" {
  set_foundation_complete
  add_feature_to_backlog "fix-me" "Fix Me Feature" "planned" 1
  set_active_feature "fix-me" "Fix Me Feature" "code"
  set_phases_completed "plan" "design"

  run_sync_state
  assert_success

  # sync-state should repair the backlog column to match the phase
  local column
  column=$(jq -r '.features[] | select(.id == "fix-me") | .column' "$VIBECREW_DIR/backlog.json")
  # "code" phase should map to "in-progress" column
  [ "$column" = "in-progress" ]
}

@test "integration: interrupted dual-write journal replayed on sync" {
  set_foundation_complete
  add_feature_to_backlog "journal-feat" "Journal Feature" "planned" 1
  set_active_feature "journal-feat" "Journal Feature" "plan"

  # Create a journal simulating interrupted dual-write
  mkdir -p "$VIBECREW_DIR/locks"

  local updated_backlog updated_state
  updated_backlog=$(jq '.features = [.features[] | if .id == "journal-feat" then .column = "in-progress" else . end]' "$VIBECREW_DIR/backlog.json")
  updated_state=$(jq '.active_feature.phase = "design" | .active_feature.phases_completed = ["plan"]' "$VIBECREW_DIR/state.json")

  echo "$updated_backlog" > "$VIBECREW_DIR/locks/staged-backlog.99999.json"
  echo "$updated_state" > "$VIBECREW_DIR/locks/staged-state.99999.json"

  cat > "$VIBECREW_DIR/locks/dual-write.journal" <<EOF
{
  "file_a": "$VIBECREW_DIR/backlog.json",
  "file_b": "$VIBECREW_DIR/state.json",
  "staged_a": "$VIBECREW_DIR/locks/staged-backlog.99999.json",
  "staged_b": "$VIBECREW_DIR/locks/staged-state.99999.json",
  "timestamp": "2026-01-01T00:00:00Z",
  "pid": 99999
}
EOF

  run_sync_state
  assert_success
  assert_no_journal_files
}

@test "integration: foundation inconsistency reset by sync-state" {
  # Set foundation.complete=true but leave an artifact pending
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.foundation.complete = true |
      .foundation.completed_at = "2026-01-01T00:00:00Z" |
      .foundation.artifacts.vision.status = "complete" |
      .foundation.artifacts.design_system.status = "complete" |
      .foundation.artifacts.tdr.status = "complete" |
      .foundation.artifacts.roadmap.status = "complete" |
      .foundation.artifacts.architecture_diagrams.status = "pending" |
      .foundation.artifacts.claude_md.status = "complete"' \
    "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  run_sync_state
  assert_success

  # Foundation should be reset to false
  assert_foundation_incomplete
}

# =============================================================================
# Graceful Degradation
# =============================================================================

@test "integration: corrupted state.json handled gracefully" {
  echo "NOT VALID JSON{{{" > "$VIBECREW_DIR/state.json"

  run_session_startup
  # Should not crash — exit 0 always
  assert_success
}

@test "integration: missing backlog.json handled gracefully" {
  set_foundation_complete
  rm -f "$VIBECREW_DIR/backlog.json"

  run_session_startup
  assert_success
}

# =============================================================================
# Handoff Detection
# =============================================================================

@test "integration: handoff file detected on startup" {
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/handoffs"
  cat > "$VIBECREW_DIR/handoffs/handoff-2026-01-15-001.md" <<'EOF'
# Session Handoff — 2026-01-15

## State
- **Active feature**: Test Feature (test-1) — Phase: code

## Next Steps
1. Continue with the code phase for Test Feature
EOF

  run_session_startup
  assert_success
  assert_output --partial "handoff"
}

# =============================================================================
# Gamification
# =============================================================================

@test "integration: gamification enabled shows level and streak" {
  set_foundation_complete

  # Enable gamification in config
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Create gamification.json
  cat > "$VIBECREW_DIR/gamification.json" <<'EOF'
{
  "level": 5,
  "xp": 2500,
  "streak": { "current": 3, "longest": 7 },
  "active_challenges": [{ "name": "Test Master", "progress": 2, "target": 5 }]
}
EOF

  run_session_startup
  assert_success
  assert_output --partial "Level 5"
  assert_output --partial "Streak: 3"
}

# =============================================================================
# Forward Compatibility
# =============================================================================

@test "integration: forward-compatible schema not downgraded" {
  # Set a future schema version
  local tmp="$VIBECREW_DIR/state.json.tmp"
  jq '.schema_version = "2.0.0"' "$VIBECREW_DIR/state.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/state.json"

  run_migrate_state
  assert_success

  # Schema version should remain 2.0.0
  local ver
  ver=$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")
  [ "$ver" = "2.0.0" ]
}

@test "integration: full startup chain completes within 10s" {
  set_foundation_complete
  add_feature_to_backlog "perf-feat" "Performance Feature" "planned" 1

  # Time the full chain
  local start_time end_time elapsed
  start_time=$(date +%s)

  run_session_startup
  assert_success

  end_time=$(date +%s)
  elapsed=$((end_time - start_time))
  [ "$elapsed" -lt 10 ] || {
    echo "Startup chain took ${elapsed}s (> 10s limit)" >&2
    return 1
  }
}

# =============================================================================
# Model-Change Detection
# =============================================================================

@test "integration: model-change detection reports on model switch" {
  set_foundation_complete

  # Create a last-validated-model file
  local plugin_root
  plugin_root="$(cd "$SCRIPTS_DIR/.." && pwd)"
  echo "claude-3-opus-20240229" > "$plugin_root/.last-validated-model.txt"

  # Set current model via env
  export CLAUDE_MODEL="claude-sonnet-4-20250514"
  export CLAUDE_PLUGIN_ROOT="$plugin_root"

  run_session_startup
  assert_success
  assert_output --partial "Model changed"

  # Cleanup
  rm -f "$plugin_root/.last-validated-model.txt"
  unset CLAUDE_MODEL CLAUDE_PLUGIN_ROOT
}
