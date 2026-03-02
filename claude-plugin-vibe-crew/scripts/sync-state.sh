#!/usr/bin/env bash
# scripts/sync-state.sh
# Reconciles state.json and backlog.json when inconsistencies are detected.
# Fixes: orphaned active features, phase/column mismatches, foundation flags.
# Reports: orphaned in-progress features.
# Uses advisory locking and atomic writes for safety.
# Exit 0 always (fail open -- sync issues should not block sessions)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Source error logging
source "$SCRIPT_DIR/lib/error-log.sh"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
STATE_FILE="$VIBECREW_DIR/state.json"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

ISSUES=0
FIXES=()
WARNINGS=()

# =============================================================================
# Shared locking (fail-open for sync-state)
# =============================================================================

LOCK_FAIL_OPEN=true
source "$(dirname "$0")/lib/lock.sh"

# =============================================================================
# Atomic write with validation (shared library — no-backup for sync-state)
# =============================================================================

source "$(dirname "$0")/lib/atomic-write.sh"

# Wrap atomic_write for sync-state: pass --no-backup, capture warnings
_sync_atomic_write() {
  local target="$1"
  local content="$2"
  if ! atomic_write "$target" "$content" --no-backup; then
    WARNINGS+=("JSON validation failed writing $(basename "$target"), skipped")
    return 1
  fi
  return 0
}

# =============================================================================
# Phase-to-column mapping
# =============================================================================

phase_to_column() {
  local phase="$1"
  case "$phase" in
    plan)   echo "planned" ;;
    design) echo "in-progress" ;;
    code)   echo "in-progress" ;;
    test)   echo "testing" ;;
    docs)   echo "review" ;;
    *)      echo "" ;;
  esac
}

# =============================================================================
# Pre-flight: check files exist
# =============================================================================

if [[ ! -f "$STATE_FILE" ]]; then
  echo "State sync: skipped (state.json not found)"
  exit 0
fi

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "State sync: skipped (backlog.json not found)"
  exit 0
fi

# =============================================================================
# Acquire lock
# =============================================================================

if ! acquire_state_lock "sync-state"; then
  echo "State sync: skipped (could not acquire lock)"
  exit 0
fi

# =============================================================================
# Create backup before modifications
# =============================================================================

BACKUP_DIR="$VIBECREW_DIR/.backup"
mkdir -p "$BACKUP_DIR"

BACKUP_TS=$(date -u +%Y-%m-%dT%H-%M-%SZ)

# Backup current files
cp "$STATE_FILE" "$BACKUP_DIR/state.json.$BACKUP_TS" 2>/dev/null || log_error "sync-state" "Failed to backup state.json"
cp "$BACKLOG_FILE" "$BACKUP_DIR/backlog.json.$BACKUP_TS" 2>/dev/null || log_error "sync-state" "Failed to backup backlog.json"

# Rotate: keep only last 5 backups per file
for prefix in state.json backlog.json; do
  ls -1t "$BACKUP_DIR/${prefix}."* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
done

# =============================================================================
# Read current state
# =============================================================================

STATE=$(cat "$STATE_FILE")
BACKLOG=$(cat "$BACKLOG_FILE")
STATE_MODIFIED=false

# =============================================================================
# Schema migration: v1.1.0 -> v1.2.0
# Add architecture_diagrams artifact if missing (for existing projects)
# =============================================================================

HAS_ARCH_DIAGRAMS=$(echo "$STATE" | jq -r '.foundation.artifacts.architecture_diagrams // empty')

if [[ -z "$HAS_ARCH_DIAGRAMS" ]]; then
  FOUNDATION_COMPLETE=$(echo "$STATE" | jq -r '.foundation.complete // false')

  if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
    # Foundation already complete -- add architecture_diagrams as "skipped" so phase gate stays open
    STATE=$(echo "$STATE" | jq --arg ts "$TIMESTAMP" '
      .schema_version = "1.2.0" |
      .foundation.artifacts.architecture_diagrams = {
        "status": "skipped",
        "file": null,
        "approved_at": null
      } |
      .updated_at = $ts
    ')
  else
    # Foundation not yet complete -- add as "pending"
    STATE=$(echo "$STATE" | jq --arg ts "$TIMESTAMP" '
      .schema_version = "1.2.0" |
      .foundation.artifacts.architecture_diagrams = {
        "status": "pending",
        "file": null,
        "approved_at": null
      } |
      .updated_at = $ts
    ')
  fi
  STATE_MODIFIED=true
  FIXES+=("Migrated state.json schema to v1.2.0 (added architecture_diagrams artifact)")
fi
BACKLOG_MODIFIED=false

# =============================================================================
# Check 1: Active feature consistency
# If state.json has an active_feature.id, verify it exists in backlog.json
# =============================================================================

ACTIVE_ID=$(echo "$STATE" | jq -r '.active_feature.id // empty')

if [[ -n "$ACTIVE_ID" ]]; then
  FEATURE_EXISTS=$(echo "$BACKLOG" | jq --arg id "$ACTIVE_ID" \
    '[.features[] | select(.id == $id)] | length')

  if [[ "$FEATURE_EXISTS" -eq 0 ]]; then
    # Feature not found in backlog -- clear active_feature in state.json
    STATE=$(echo "$STATE" | jq --arg ts "$TIMESTAMP" '
      .active_feature.id = null |
      .active_feature.name = null |
      .active_feature.worktree = null |
      .active_feature.phase = null |
      .active_feature.phases_completed = [] |
      .updated_at = $ts
    ')
    STATE_MODIFIED=true
    ((ISSUES++))
    FIXES+=("Cleared active_feature '$ACTIVE_ID' (not found in backlog)")
    ACTIVE_ID=""
  fi
fi

# =============================================================================
# Check 2: Phase consistency
# If state.json has active_feature.phase, verify backlog column matches
# =============================================================================

ACTIVE_PHASE=$(echo "$STATE" | jq -r '.active_feature.phase // empty')

if [[ -n "$ACTIVE_ID" ]] && [[ -n "$ACTIVE_PHASE" ]]; then
  EXPECTED_COLUMN=$(phase_to_column "$ACTIVE_PHASE")

  if [[ -n "$EXPECTED_COLUMN" ]]; then
    CURRENT_COLUMN=$(echo "$BACKLOG" | jq -r --arg id "$ACTIVE_ID" \
      '[.features[] | select(.id == $id) | .column] | .[0] // "unknown"')

    if [[ "$CURRENT_COLUMN" != "$EXPECTED_COLUMN" ]]; then
      # Mismatch -- update backlog column to match state phase
      BACKLOG=$(echo "$BACKLOG" | jq --arg id "$ACTIVE_ID" --arg col "$EXPECTED_COLUMN" --arg ts "$TIMESTAMP" '
        .features = [
          .features[] |
          if .id == $id then
            .column = $col |
            .updated_at = $ts
          else
            .
          end
        ]
      ')
      BACKLOG_MODIFIED=true
      ((ISSUES++))
      FIXES+=("Updated backlog column for '$ACTIVE_ID': '$CURRENT_COLUMN' -> '$EXPECTED_COLUMN' (to match phase '$ACTIVE_PHASE')")
    fi
  fi
fi

# =============================================================================
# Check 3: Orphaned in-progress features
# Features in backlog with column "in-progress" that are NOT the active feature
# =============================================================================

ORPHANED_FEATURES=$(echo "$BACKLOG" | jq -r --arg active "${ACTIVE_ID:-__none__}" \
  '[.features[] | select(.column == "in-progress" and .id != $active)] | .[] | "\(.id) (\(.name // "unnamed"))"')

if [[ -n "$ORPHANED_FEATURES" ]]; then
  while IFS= read -r orphan; do
    ((ISSUES++))
    WARNINGS+=("Orphaned in-progress feature: $orphan")
  done <<< "$ORPHANED_FEATURES"
fi

# =============================================================================
# Check 4: Foundation consistency
# If foundation.complete is true, verify all 6 artifacts are "complete"
# =============================================================================

FOUNDATION_COMPLETE=$(echo "$STATE" | jq -r '.foundation.complete // false')

if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
  INCOMPLETE_ARTIFACTS=$(echo "$STATE" | jq -r '
    .foundation.artifacts // {} |
    to_entries[] |
    select(.value.status != "complete") |
    .key
  ')

  if [[ -n "$INCOMPLETE_ARTIFACTS" ]]; then
    # Some artifacts are not complete -- set foundation.complete back to false
    STATE=$(echo "$STATE" | jq --arg ts "$TIMESTAMP" '
      .foundation.complete = false |
      .foundation.completed_at = null |
      .updated_at = $ts
    ')
    STATE_MODIFIED=true
    ((ISSUES++))

    INCOMPLETE_LIST=""
    while IFS= read -r artifact; do
      ARTIFACT_STATUS=$(echo "$STATE" | jq -r --arg a "$artifact" \
        '.foundation.artifacts[$a].status // "unknown"')
      INCOMPLETE_LIST="${INCOMPLETE_LIST}${artifact} (${ARTIFACT_STATUS}), "
    done <<< "$INCOMPLETE_ARTIFACTS"
    INCOMPLETE_LIST="${INCOMPLETE_LIST%, }"

    FIXES+=("Reset foundation.complete to false (incomplete artifacts: $INCOMPLETE_LIST)")
  fi
fi

# =============================================================================
# Write modified files atomically
# =============================================================================

if [[ "$STATE_MODIFIED" == "true" ]]; then
  if ! _sync_atomic_write "$STATE_FILE" "$STATE"; then
    WARNINGS+=("Failed to write state.json fixes")
  fi
fi

if [[ "$BACKLOG_MODIFIED" == "true" ]]; then
  if ! _sync_atomic_write "$BACKLOG_FILE" "$BACKLOG"; then
    WARNINGS+=("Failed to write backlog.json fixes")
  fi
fi

# =============================================================================
# Release lock
# =============================================================================

release_state_lock

# =============================================================================
# Output report
# =============================================================================

if [[ "$ISSUES" -eq 0 ]]; then
  echo "State sync: consistent"
else
  echo "State sync: $ISSUES issues found"
fi

for fix in "${FIXES[@]+"${FIXES[@]}"}"; do
  echo "  - Fixed: $fix"
done

for warn in "${WARNINGS[@]+"${WARNINGS[@]}"}"; do
  echo "  - Warning: $warn"
done

exit 0
