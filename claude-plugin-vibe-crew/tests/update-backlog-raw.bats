#!/usr/bin/env bats

# Tests for update-backlog-raw.sh

SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../scripts" && pwd)"

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/.vibecrew/locks"
  export PROJECT_ROOT="$TEST_DIR"

  # Create a minimal backlog.json
  cat > "$TEST_DIR/.vibecrew/backlog.json" << 'EOF'
{
  "features": [
    {
      "id": "feat-001",
      "name": "Test Feature",
      "column": "planned",
      "priority": 1,
      "phases_completed": [],
      "updated_at": "2026-01-01T00:00:00Z"
    }
  ]
}
EOF

  # Stub git to return our test dir
  export GIT_CEILING_DIRECTORIES="$(dirname "$TEST_DIR")"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "rejects disallowed function calls" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" '.features | env("HOME")'
  [ "$status" -ne 0 ]
  [[ "$output" == *"disallowed"* ]]
}

@test "rejects expression not starting with dot or paren" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" 'def foo: .; foo'
  [ "$status" -ne 0 ]
  [[ "$output" == *"must start with"* ]]
}

@test "applies valid dot-path expression" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" '.features[0].column = "in-progress"'
  [ "$status" -eq 0 ]

  RESULT=$(jq -r '.features[0].column' "$TEST_DIR/.vibecrew/backlog.json")
  [ "$RESULT" = "in-progress" ]
}

@test "applies valid parenthesized select expression" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" '(.features[] | select(.id == "feat-001")) |= (.column = "blocked")'
  [ "$status" -eq 0 ]

  RESULT=$(jq -r '.features[0].column' "$TEST_DIR/.vibecrew/backlog.json")
  [ "$RESULT" = "blocked" ]
}

@test "validates JSON output" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" '.features[0].column = "testing"'
  [ "$status" -eq 0 ]

  # Output file must be valid JSON
  jq empty "$TEST_DIR/.vibecrew/backlog.json"
}

@test "dry-run does not modify file" {
  cd "$TEST_DIR"
  BEFORE=$(cat "$TEST_DIR/.vibecrew/backlog.json")

  run bash "$SCRIPT_DIR/update-backlog-raw.sh" --dry-run '.features[0].column = "done"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY RUN"* ]]

  AFTER=$(cat "$TEST_DIR/.vibecrew/backlog.json")
  [ "$BEFORE" = "$AFTER" ]
}

@test "--arg passthrough works" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" \
    '(.features[] | select(.id == $fid)) |= (.column = "blocked" | .blocked_reason = $reason)' \
    --arg fid "feat-001" \
    --arg reason "Tests failed after 3 retries"
  [ "$status" -eq 0 ]

  RESULT=$(jq -r '.features[0].blocked_reason' "$TEST_DIR/.vibecrew/backlog.json")
  [ "$RESULT" = "Tests failed after 3 retries" ]
}

@test "--argjson passthrough works" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh" \
    '.features += [$new]' \
    --argjson new '{"id":"feat-002","name":"Second","column":"idea"}'
  [ "$status" -eq 0 ]

  COUNT=$(jq '.features | length' "$TEST_DIR/.vibecrew/backlog.json")
  [ "$COUNT" -eq 2 ]
}

@test "fails gracefully on missing backlog.json" {
  cd "$TEST_DIR"
  rm "$TEST_DIR/.vibecrew/backlog.json"

  run bash "$SCRIPT_DIR/update-backlog-raw.sh" '.features[0].column = "done"'
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]]
}

@test "shows usage on no arguments" {
  cd "$TEST_DIR"
  run bash "$SCRIPT_DIR/update-backlog-raw.sh"
  [ "$status" -ne 0 ]
  [[ "$output" == *"Usage"* ]]
}
