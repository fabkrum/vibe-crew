#!/usr/bin/env bats
# tests/expertise-write.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/expertise-write.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/expertise"
}

teardown() {
  teardown_vibecrew_dir
}

@test "writes a record to the correct domain file" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier foundational --content 'Always use semicolons' --session-id 'session-test'"
  assert_success
  [ -f "$VIBECREW_DIR/expertise/conventions.jsonl" ]
  local content
  content=$(cat "$VIBECREW_DIR/expertise/conventions.jsonl")
  echo "$content" | jq -e '.id' >/dev/null
  echo "$content" | jq -e '.type == "convention"' >/dev/null
}

@test "generates unique IDs" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier foundational --content 'Rule 1' --session-id 'session-test'"
  assert_success
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier foundational --content 'Rule 2' --session-id 'session-test'"
  assert_success
  local count
  count=$(wc -l < "$VIBECREW_DIR/expertise/conventions.jsonl" | tr -d ' ')
  [ "$count" -eq 2 ]
  local ids
  ids=$(jq -r '.id' "$VIBECREW_DIR/expertise/conventions.jsonl" | sort -u | wc -l | tr -d ' ')
  [ "$ids" -eq 2 ]
}

@test "rejects invalid domain" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain invalid --type convention --tier foundational --content 'test'"
  assert_failure
  assert_output --partial "Invalid domain"
}

@test "rejects invalid type" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type invalid --tier foundational --content 'test'"
  assert_failure
  assert_output --partial "Invalid type"
}

@test "rejects invalid tier" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier invalid --content 'test'"
  assert_failure
  assert_output --partial "Invalid tier"
}

@test "requires content" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier foundational"
  assert_failure
  assert_output --partial "--content is required"
}

@test "truncates content over 500 chars" {
  local long_content
  long_content=$(printf 'x%.0s' $(seq 1 600))
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier foundational --content '$long_content' --session-id 'session-test'"
  assert_success
  local stored_len
  stored_len=$(jq -r '.content | length' "$VIBECREW_DIR/expertise/conventions.jsonl")
  [ "$stored_len" -le 500 ]
}

@test "writes tags as JSON array" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --domain conventions --type convention --tier foundational --content 'test' --tags 'auth,react' --session-id 'session-test'"
  assert_success
  local tag_count
  tag_count=$(jq '.tags | length' "$VIBECREW_DIR/expertise/conventions.jsonl")
  [ "$tag_count" -eq 2 ]
}
