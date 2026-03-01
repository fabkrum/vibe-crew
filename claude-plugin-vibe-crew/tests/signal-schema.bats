#!/usr/bin/env bats

# Tests for R4: Signal Schema Standardization

setup() {
  TEST_DIR="$(mktemp -d)"
  SCHEMA_FILE="$(cd "$(dirname "$BATS_TEST_FILENAME")/../templates" && pwd)/signal-schema.json"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "signal schema is valid JSON" {
  jq . "$SCHEMA_FILE" > /dev/null
}

@test "signal schema has required fields defined" {
  REQUIRED=$(jq -r '.required | join(",")' "$SCHEMA_FILE")
  [[ "$REQUIRED" == *"feature_id"* ]]
  [[ "$REQUIRED" == *"phase"* ]]
  [[ "$REQUIRED" == *"timestamp"* ]]
  [[ "$REQUIRED" == *"agent"* ]]
  [[ "$REQUIRED" == *"status"* ]]
}

@test "builder-complete signal validates against schema required fields" {
  cat > "$TEST_DIR/signal.json" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete",
  "branch": "feat/test",
  "commit": "abc123",
  "changed_files": [
    {"path": "src/index.ts", "type": "modified"}
  ]
}
EOF

  # Verify required fields are present
  for field in feature_id phase timestamp agent status; do
    [ "$(jq -r ".$field" "$TEST_DIR/signal.json")" != "null" ]
  done
}

@test "verifier-test-complete signal has required fields" {
  cat > "$TEST_DIR/signal.json" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "test",
  "timestamp": "2026-03-01T11:00:00Z",
  "agent": "verifier",
  "status": "complete",
  "tests_passed": 10,
  "tests_failed": 0,
  "tests_skipped": 1,
  "coverage_summary": "85%"
}
EOF

  [ "$(jq -r '.agent' "$TEST_DIR/signal.json")" = "verifier" ]
  [ "$(jq -r '.tests_passed' "$TEST_DIR/signal.json")" = "10" ]
}
