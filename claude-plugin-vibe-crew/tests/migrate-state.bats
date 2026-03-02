#!/usr/bin/env bats
# tests/migrate-state.bats
# Tests for scripts/migrate-state.sh — state file migration

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/migrate-state.sh"
}

teardown() {
  teardown_vibecrew_dir
}

run_migrate() {
  run bash -c "cd '$TEST_PROJECT_DIR' && export PROJECT_ROOT='$TEST_PROJECT_DIR' && bash '$SCRIPT'"
}

# Helper: write a JSON file with a specific schema_version
write_versioned_state() {
  local version="$1"
  cat > "$VIBECREW_DIR/state.json" <<EOF
{
  "schema_version": "$version",
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
}

write_versioned_config() {
  local version="$1"
  cat > "$VIBECREW_DIR/config.json" <<EOF
{
  "schema_version": "$version",
  "terminal": "other",
  "notifications": { "enabled": true },
  "gamification": { "enabled": false }
}
EOF
}

write_versioned_backlog() {
  local version="$1"
  cat > "$VIBECREW_DIR/backlog.json" <<EOF
{
  "schema_version": "$version",
  "columns": [],
  "features": []
}
EOF
}

write_versioned_score() {
  local version="$1"
  local file="$2"
  cat > "$file" <<EOF
{
  "schema_version": "$version",
  "session_id": "test-session",
  "score": 85,
  "deductions": [],
  "bonuses": []
}
EOF
}

# =============================================================================
# 1. No-op when files are already at current version (1.6.0)
# =============================================================================

@test "no-op when all files are already at current version 1.6.0" {
  # Default fixtures from common-setup are at 1.4.0; write 1.6.0 versions
  write_versioned_state "1.6.0"
  write_versioned_config "1.6.0"
  write_versioned_backlog "1.6.0"

  # Capture file checksums before
  local state_before config_before backlog_before
  state_before=$(md5 -q "$VIBECREW_DIR/state.json")
  config_before=$(md5 -q "$VIBECREW_DIR/config.json")
  backlog_before=$(md5 -q "$VIBECREW_DIR/backlog.json")

  run_migrate
  assert_success

  # Files should not have been modified (no "Migrated" output)
  refute_output --partial "Migrated"

  # Verify checksums unchanged
  local state_after config_after backlog_after
  state_after=$(md5 -q "$VIBECREW_DIR/state.json")
  config_after=$(md5 -q "$VIBECREW_DIR/config.json")
  backlog_after=$(md5 -q "$VIBECREW_DIR/backlog.json")

  [ "$state_before" = "$state_after" ]
  [ "$config_before" = "$config_after" ]
  [ "$backlog_before" = "$backlog_after" ]
}

# =============================================================================
# 2. Migrates state.json from 1.0.0 to 1.6.0
# =============================================================================

@test "migrates state.json from 1.0.0 to 1.6.0" {
  write_versioned_state "1.0.0"
  write_versioned_config "1.6.0"
  write_versioned_backlog "1.6.0"

  run_migrate
  assert_success
  assert_output --partial "Migrated state.json from 1.0.0 to 1.6.0"

  # Verify onboarded field added (1.0.0 -> 1.1.0 migration)
  local onboarded
  onboarded=$(jq -r '.onboarded' "$VIBECREW_DIR/state.json")
  [ "$onboarded" = "false" ]

  # Verify active_workflow field added (1.2.0 -> 1.3.0 migration)
  local active_workflow
  active_workflow=$(jq -r '.active_workflow' "$VIBECREW_DIR/state.json")
  [ "$active_workflow" = "null" ]

  # Verify schema_version updated
  local version
  version=$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")
  [ "$version" = "1.6.0" ]
}

# =============================================================================
# 3. Migrates config.json adding all new sections
# =============================================================================

@test "migrates config.json from 1.0.0 adding all new sections" {
  write_versioned_state "1.6.0"
  write_versioned_config "1.0.0"
  write_versioned_backlog "1.6.0"

  run_migrate
  assert_success
  assert_output --partial "Migrated config.json from 1.0.0 to 1.6.0"

  # 1.0.0 -> 1.1.0: performance_coach, doc_generator, onboarding
  [ "$(jq -r '.performance_coach.enabled' "$VIBECREW_DIR/config.json")" = "true" ]
  [ "$(jq -r '.doc_generator.auto_changelog' "$VIBECREW_DIR/config.json")" = "true" ]
  [ "$(jq -r '.onboarding.show_hints' "$VIBECREW_DIR/config.json")" = "true" ]

  # 1.1.0 -> 1.2.0: audit (auto_github_issues gets renamed to auto_issues in 1.5.0 -> 1.6.0)
  [ "$(jq -r '.audit.severity_threshold' "$VIBECREW_DIR/config.json")" = "high" ]

  # 1.2.0 -> 1.3.0: opponent_processor, simplify, ci_healing
  [ "$(jq -r '.opponent_processor.enabled' "$VIBECREW_DIR/config.json")" = "true" ]
  [ "$(jq -r '.simplify.enabled' "$VIBECREW_DIR/config.json")" = "true" ]
  [ "$(jq -r '.ci_healing.max_attempts' "$VIBECREW_DIR/config.json")" = "3" ]

  # 1.3.0 -> 1.4.0: user_profile
  [ "$(jq -r '.user_profile.interview_completed' "$VIBECREW_DIR/config.json")" = "false" ]

  # 1.4.0 -> 1.5.0: quality_gate, pricing, locks
  [ "$(jq -r '.quality_gate.timeout_seconds' "$VIBECREW_DIR/config.json")" = "120" ]
  [ "$(jq -r '.pricing.opus.input' "$VIBECREW_DIR/config.json")" = "15.00" ]
  [ "$(jq -r '.locks.stale_timeout_secs' "$VIBECREW_DIR/config.json")" = "60" ]

  # 1.5.0 -> 1.6.0: git_provider, issues, audit rename
  [ "$(jq -r '.git_provider' "$VIBECREW_DIR/config.json")" = "null" ]
  [ "$(jq -r '.audit.auto_issues' "$VIBECREW_DIR/config.json")" = "false" ]
  [ "$(jq '.audit | has("auto_github_issues")' "$VIBECREW_DIR/config.json")" = "false" ]
  [ "$(jq '.issues.enabled' "$VIBECREW_DIR/config.json")" = "false" ]
}

# =============================================================================
# 4. Forward-compatibility: skips files with newer schema_version
# =============================================================================

@test "forward-compatibility: skips files with newer schema_version" {
  write_versioned_state "2.0.0"
  write_versioned_config "1.6.0"
  write_versioned_backlog "1.6.0"

  run_migrate
  assert_success
  assert_output --partial "newer than 1.6.0"

  # state.json should remain at 2.0.0 (untouched)
  local version
  version=$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")
  [ "$version" = "2.0.0" ]
}

# =============================================================================
# 5. Creates .backup/ directory before migration
# =============================================================================

@test "creates .backup/ directory and backs up files before migration" {
  write_versioned_state "1.0.0"
  write_versioned_config "1.0.0"
  write_versioned_backlog "1.0.0"

  # Remove .backup/ if it exists to prove the script creates it
  rm -rf "$VIBECREW_DIR/.backup"

  run_migrate
  assert_success

  # .backup/ directory should exist
  [ -d "$VIBECREW_DIR/.backup" ]

  # Pre-migration backups should exist
  [ -f "$VIBECREW_DIR/.backup/state.json.pre-migration" ]
  [ -f "$VIBECREW_DIR/.backup/config.json.pre-migration" ]
  [ -f "$VIBECREW_DIR/.backup/backlog.json.pre-migration" ]

  # Backup should contain original 1.0.0 version
  local backup_version
  backup_version=$(jq -r '.schema_version' "$VIBECREW_DIR/.backup/state.json.pre-migration")
  [ "$backup_version" = "1.0.0" ]
}

# =============================================================================
# 6. Handles missing files gracefully (exits 0)
# =============================================================================

@test "handles missing files gracefully and exits 0" {
  # Remove all state files
  rm -f "$VIBECREW_DIR/state.json"
  rm -f "$VIBECREW_DIR/config.json"
  rm -f "$VIBECREW_DIR/backlog.json"

  run_migrate
  assert_success

  # Should not output any migration messages
  refute_output --partial "Migrated"
}

# =============================================================================
# 7. Migrates score files from 1.0.0
# =============================================================================

@test "migrates score files from 1.0.0" {
  # Set main files to current version so they are a no-op
  write_versioned_state "1.6.0"
  write_versioned_config "1.6.0"
  write_versioned_backlog "1.6.0"

  # Create a score file at version 1.0.0
  local score_file="$VIBECREW_DIR/scores/score-test-session.json"
  write_versioned_score "1.0.0" "$score_file"

  run_migrate
  assert_success

  # Verify user_feedback added (1.0.0 -> 1.1.0 score migration)
  [ "$(jq -r '.user_feedback.rating' "$score_file")" = "null" ]
  [ "$(jq -r '.user_feedback.comment' "$score_file")" = "null" ]

  # Verify trend added
  [ "$(jq -r '.trend.direction' "$score_file")" = "unknown" ]
  [ "$(jq -r '.trend.window_size' "$score_file")" = "0" ]

  # Verify schema_version updated
  [ "$(jq -r '.schema_version' "$score_file")" = "1.6.0" ]
}

# =============================================================================
# 8. Updates schema_version after migration
# =============================================================================

@test "updates schema_version to 1.6.0 after migration on all files" {
  write_versioned_state "1.0.0"
  write_versioned_config "1.0.0"
  write_versioned_backlog "1.0.0"

  run_migrate
  assert_success

  # All three files should be at 1.6.0
  [ "$(jq -r '.schema_version' "$VIBECREW_DIR/state.json")" = "1.6.0" ]
  [ "$(jq -r '.schema_version' "$VIBECREW_DIR/config.json")" = "1.6.0" ]
  [ "$(jq -r '.schema_version' "$VIBECREW_DIR/backlog.json")" = "1.6.0" ]
}
