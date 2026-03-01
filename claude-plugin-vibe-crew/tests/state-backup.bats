#!/usr/bin/env bats

# Tests for R8: State Backup + Recovery

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/.vibecrew/.backup"

  # Create sample state and backlog
  echo '{"schema_version":"1.4.0","foundation":{"complete":true}}' > "$TEST_DIR/.vibecrew/state.json"
  echo '{"schema_version":"1.4.0","features":[]}' > "$TEST_DIR/.vibecrew/backlog.json"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "backup creates timestamped copies" {
  BACKUP_DIR="$TEST_DIR/.vibecrew/.backup"
  BACKUP_TS="2026-03-01T10-00-00Z"

  cp "$TEST_DIR/.vibecrew/state.json" "$BACKUP_DIR/state.json.$BACKUP_TS"
  cp "$TEST_DIR/.vibecrew/backlog.json" "$BACKUP_DIR/backlog.json.$BACKUP_TS"

  [ -f "$BACKUP_DIR/state.json.$BACKUP_TS" ]
  [ -f "$BACKUP_DIR/backlog.json.$BACKUP_TS" ]
}

@test "rotation keeps only last 5 backups" {
  BACKUP_DIR="$TEST_DIR/.vibecrew/.backup"

  # Create 7 state backups
  for i in $(seq 1 7); do
    echo "{\"v\": $i}" > "$BACKUP_DIR/state.json.2026-03-0${i}T10-00-00Z"
    sleep 0.1  # Ensure different mtimes
  done

  # Rotate: keep last 5
  ls -1t "$BACKUP_DIR/state.json."* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true

  COUNT=$(ls -1 "$BACKUP_DIR/state.json."* 2>/dev/null | wc -l | tr -d ' ')
  [ "$COUNT" -eq 5 ]
}

@test "restore copies backup to target" {
  BACKUP_DIR="$TEST_DIR/.vibecrew/.backup"
  BACKUP_TS="2026-03-01T10-00-00Z"

  # Create a backup with different content
  echo '{"schema_version":"1.4.0","foundation":{"complete":false}}' > "$BACKUP_DIR/state.json.$BACKUP_TS"

  # Restore
  cp "$BACKUP_DIR/state.json.$BACKUP_TS" "$TEST_DIR/.vibecrew/state.json"

  # Verify restored content
  RESULT=$(jq -r '.foundation.complete' "$TEST_DIR/.vibecrew/state.json")
  [ "$RESULT" = "false" ]
}
