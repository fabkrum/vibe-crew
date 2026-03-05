#!/usr/bin/env bats
# tests/expertise-compact.bats

setup() {
  load 'test_helper/common-setup'
  WRITE_SCRIPT="$SCRIPTS_DIR/expertise-write.sh"
  SCRIPT="$SCRIPTS_DIR/expertise-compact.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/expertise" "$VIBECREW_DIR/scores"
}

teardown() {
  teardown_vibecrew_dir
}

@test "runs without errors on empty expertise dir" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "Expertise compact"
}

@test "handles missing expertise dir" {
  rm -rf "$VIBECREW_DIR/expertise"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "No expertise directory"
}

@test "deduplicates identical content" {
  # Write same content twice (bypass the script to force dups)
  local jsonl="$VIBECREW_DIR/expertise/conventions.jsonl"
  echo '{"id":"exp-1","type":"convention","tier":"foundational","domain":"conventions","content":"Use semicolons","context":"","outcome_status":"success","confidence":0.90,"tags":[],"created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z","session_id":"s1","feature_id":null,"source_agent":"user","deprecated":false,"deprecation_reason":null,"access_count":0,"last_accessed_at":null,"superseded_by":null}' > "$jsonl"
  echo '{"id":"exp-2","type":"convention","tier":"foundational","domain":"conventions","content":"Use semicolons","context":"","outcome_status":"success","confidence":0.80,"tags":[],"created_at":"2026-01-02T00:00:00Z","updated_at":"2026-01-02T00:00:00Z","session_id":"s2","feature_id":null,"source_agent":"user","deprecated":false,"deprecation_reason":null,"access_count":0,"last_accessed_at":null,"superseded_by":null}' >> "$jsonl"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(wc -l < "$jsonl" | tr -d ' ')
  [ "$count" -eq 1 ]
}

@test "preserves non-duplicate records" {
  local jsonl="$VIBECREW_DIR/expertise/conventions.jsonl"
  echo '{"id":"exp-1","type":"convention","tier":"foundational","domain":"conventions","content":"Rule one","context":"","outcome_status":"success","confidence":0.90,"tags":[],"created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z","session_id":"s1","feature_id":null,"source_agent":"user","deprecated":false,"deprecation_reason":null,"access_count":1,"last_accessed_at":null,"superseded_by":null}' > "$jsonl"
  echo '{"id":"exp-2","type":"convention","tier":"foundational","domain":"conventions","content":"Rule two","context":"","outcome_status":"success","confidence":0.80,"tags":[],"created_at":"2026-01-02T00:00:00Z","updated_at":"2026-01-02T00:00:00Z","session_id":"s2","feature_id":null,"source_agent":"user","deprecated":false,"deprecation_reason":null,"access_count":1,"last_accessed_at":null,"superseded_by":null}' >> "$jsonl"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(wc -l < "$jsonl" | tr -d ' ')
  [ "$count" -eq 2 ]
}

@test "accepts session-count parameter" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --session-count 5"
  assert_success
}

@test "deprecates zero-access records after 20 sessions" {
  local jsonl="$VIBECREW_DIR/expertise/conventions.jsonl"
  echo '{"id":"exp-1","type":"convention","tier":"observational","domain":"conventions","content":"Old rule","context":"","outcome_status":"pending","confidence":0.50,"tags":[],"created_at":"2025-01-01T00:00:00Z","updated_at":"2025-01-01T00:00:00Z","session_id":"s1","feature_id":null,"source_agent":"user","deprecated":false,"deprecation_reason":null,"access_count":0,"last_accessed_at":null,"superseded_by":null}' > "$jsonl"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' --session-count 25"
  assert_success
  local deprecated
  deprecated=$(jq -r '.deprecated' "$jsonl")
  [ "$deprecated" = "true" ]
}

@test "keeps deprecated records in output" {
  local jsonl="$VIBECREW_DIR/expertise/conventions.jsonl"
  echo '{"id":"exp-1","type":"convention","tier":"foundational","domain":"conventions","content":"Active rule","context":"","outcome_status":"success","confidence":0.90,"tags":[],"created_at":"2026-01-01T00:00:00Z","updated_at":"2026-01-01T00:00:00Z","session_id":"s1","feature_id":null,"source_agent":"user","deprecated":false,"deprecation_reason":null,"access_count":5,"last_accessed_at":null,"superseded_by":null}' > "$jsonl"
  echo '{"id":"exp-2","type":"convention","tier":"observational","domain":"conventions","content":"Dead rule","context":"","outcome_status":"pending","confidence":0.30,"tags":[],"created_at":"2025-01-01T00:00:00Z","updated_at":"2025-01-01T00:00:00Z","session_id":"s2","feature_id":null,"source_agent":"user","deprecated":true,"deprecation_reason":"manual","access_count":0,"last_accessed_at":null,"superseded_by":null}' >> "$jsonl"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local count
  count=$(wc -l < "$jsonl" | tr -d ' ')
  [ "$count" -eq 2 ]
}

@test "outputs compact summary" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  assert_output --partial "Expertise compact: deprecated="
}
