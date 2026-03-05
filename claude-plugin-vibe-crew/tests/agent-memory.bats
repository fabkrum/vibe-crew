#!/usr/bin/env bats
# Tests for scripts/agent-memory-write.sh and scripts/agent-memory-read.sh

load 'test_helper/common-setup'

WRITE_SCRIPT="$SCRIPTS_DIR/agent-memory-write.sh"
READ_SCRIPT="$SCRIPTS_DIR/agent-memory-read.sh"

setup() {
  setup_vibecrew_dir
  touch "$TEST_PROJECT_DIR/.gitkeep"
  git -C "$TEST_PROJECT_DIR" add .
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1
}

teardown() {
  teardown_vibecrew_dir
}

# --- agent-memory-write.sh ---

@test "write: fails without required args" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT'"
  assert_failure
  echo "$output" | jq -e '.error' >/dev/null
}

@test "write: fails without --agent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --domain test --content hello"
  assert_failure
}

@test "write: fails without --domain" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --content hello"
  assert_failure
}

@test "write: fails without --content" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test"
  assert_failure
}

@test "write: creates memory directory and file" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain api-patterns --content 'REST uses /api/v1 prefix'"
  assert_success
  [ -d "$VIBECREW_DIR/memory/builder" ]
  [ -f "$VIBECREW_DIR/memory/builder/api-patterns.jsonl" ]
}

@test "write: entry has correct JSON structure" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'test entry'"
  assert_success
  # Read the entry
  ENTRY=$(head -1 "$VIBECREW_DIR/memory/builder/test.jsonl")
  echo "$ENTRY" | jq -e '.content == "test entry"'
  echo "$ENTRY" | jq -e '.created_at'
  echo "$ENTRY" | jq -e '.ttl_days == 90'
}

@test "write: custom TTL is respected" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'short lived' --ttl 30"
  assert_success
  ENTRY=$(head -1 "$VIBECREW_DIR/memory/builder/test.jsonl")
  echo "$ENTRY" | jq -e '.ttl_days == 30'
}

@test "write: output confirms success" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'hello'"
  assert_success
  echo "$output" | jq -e '.written == true'
  echo "$output" | jq -e '.agent == "builder"'
  echo "$output" | jq -e '.domain == "test"'
}

@test "write: appends multiple entries" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'entry one'"
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'entry two'"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'entry three'"
  assert_success
  LINE_COUNT=$(wc -l < "$VIBECREW_DIR/memory/builder/test.jsonl" | tr -d ' ')
  [ "$LINE_COUNT" -eq 3 ]
}

@test "write: rejects duplicate content" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'same thing'"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'same thing'"
  assert_success
  echo "$output" | jq -e '.written == false'
  echo "$output" | jq -e '.reason == "duplicate"'
  LINE_COUNT=$(wc -l < "$VIBECREW_DIR/memory/builder/test.jsonl" | tr -d ' ')
  [ "$LINE_COUNT" -eq 1 ]
}

@test "write: prunes when exceeding max entries" {
  # Write 52 entries (max is 50)
  for i in $(seq 1 52); do
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'entry $i'"
  done
  LINE_COUNT=$(wc -l < "$VIBECREW_DIR/memory/builder/test.jsonl" | tr -d ' ')
  [ "$LINE_COUNT" -le 50 ]
}

@test "write: sanitizes agent and domain names" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent 'build..er/../../etc' --domain 'test;rm' --content 'sanitized'"
  assert_success
  # Should create a sanitized directory name
  [ ! -d "$VIBECREW_DIR/memory/build..er" ]
}

@test "write: different agents have separate directories" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'builder memory'"
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent verifier --domain test --content 'verifier memory'"
  [ -f "$VIBECREW_DIR/memory/builder/test.jsonl" ]
  [ -f "$VIBECREW_DIR/memory/verifier/test.jsonl" ]
}

# --- agent-memory-read.sh ---

@test "read: fails without --agent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT'"
  assert_failure
}

@test "read: returns empty for non-existent agent" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent nonexistent --format json"
  assert_success
  echo "$output" | jq -e '.count == 0'
  echo "$output" | jq -e '.entries == []'
}

@test "read: returns entries after write" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain api-patterns --content 'REST prefix /api/v1'"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent builder --format json"
  assert_success
  echo "$output" | jq -e '.count == 1'
  echo "$output" | jq -e '.entries[0].content == "REST prefix /api/v1"'
}

@test "read: filters by domain" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain api-patterns --content 'api stuff'"
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain code-conventions --content 'code stuff'"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent builder --domain api-patterns --format json"
  assert_success
  echo "$output" | jq -e '.count == 1'
  echo "$output" | jq -e '.entries[0].content == "api stuff"'
}

@test "read: respects --limit" {
  for i in $(seq 1 10); do
    bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain test --content 'entry $i'"
  done
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent builder --limit 3 --format json"
  assert_success
  echo "$output" | jq -e '.count == 3'
}

@test "read: summary format produces markdown" {
  bash -c "cd '$TEST_PROJECT_DIR' && bash '$WRITE_SCRIPT' --agent builder --domain api-patterns --content 'use /api/v1 prefix'"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent builder --format summary"
  assert_success
  echo "$output" | grep -q "Agent Memory: builder"
  echo "$output" | grep -q "api-patterns"
}

@test "read: prunes expired entries" {
  # Write an entry with an already-expired date
  mkdir -p "$VIBECREW_DIR/memory/builder"
  echo '{"content":"old entry","created_at":"2020-01-01T00:00:00Z","expires_at":"2020-06-01T00:00:00Z","ttl_days":90}' > "$VIBECREW_DIR/memory/builder/test.jsonl"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent builder --format json"
  assert_success
  echo "$output" | jq -e '.count == 0'
  # File should be removed after pruning
  [ ! -f "$VIBECREW_DIR/memory/builder/test.jsonl" ]
}

@test "read: keeps valid entries while pruning expired" {
  mkdir -p "$VIBECREW_DIR/memory/builder"
  # One expired, one valid (far future)
  {
    echo '{"content":"expired","created_at":"2020-01-01T00:00:00Z","expires_at":"2020-06-01T00:00:00Z","ttl_days":90}'
    echo '{"content":"valid","created_at":"2026-01-01T00:00:00Z","expires_at":"2030-01-01T00:00:00Z","ttl_days":90}'
  } > "$VIBECREW_DIR/memory/builder/test.jsonl"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$READ_SCRIPT' --agent builder --format json"
  assert_success
  echo "$output" | jq -e '.count == 1'
  echo "$output" | jq -e '.entries[0].content == "valid"'
  # File should still exist with just the valid entry
  [ -f "$VIBECREW_DIR/memory/builder/test.jsonl" ]
  LINE_COUNT=$(wc -l < "$VIBECREW_DIR/memory/builder/test.jsonl" | tr -d ' ')
  [ "$LINE_COUNT" -eq 1 ]
}
