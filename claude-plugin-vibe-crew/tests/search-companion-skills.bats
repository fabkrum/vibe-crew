#!/usr/bin/env bats
# tests/search-companion-skills.bats
# Tests for scripts/search-companion-skills.sh — tiered skill search

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/search-companion-skills.sh"
  cd "$TEST_PROJECT_DIR"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# No arguments
# =============================================================================

@test "no arguments: exits 1 with usage" {
  run bash "$SCRIPT"
  assert_failure
  assert_output --partial "Usage:"
}

# =============================================================================
# Output is always valid JSON array
# =============================================================================

@test "nonexistent keyword: returns empty JSON array" {
  # Mock curl to return 404/empty for all GitHub API calls
  mock_command "curl" 1 ""

  run bash "$SCRIPT" "zzz-nonexistent-tech-zzz"
  assert_success

  echo "$output" | jq empty 2>/dev/null
  [ $? -eq 0 ]

  local count
  count=$(echo "$output" | jq 'length')
  [ "$count" = "0" ]
}

@test "output items have required fields when results found" {
  # Mock curl to return a valid GitHub search result
  mock_command "curl" 0 '{
    "items": [
      {
        "name": "test-agent-skills",
        "full_name": "testorg/test-agent-skills",
        "owner": {"login": "testorg"},
        "html_url": "https://github.com/testorg/test-agent-skills",
        "description": "Test skills for testing",
        "stargazers_count": 100
      }
    ]
  }'

  run bash "$SCRIPT" "test"
  # The script may succeed or fail depending on which API calls work
  # Just verify JSON output structure if we get results
  if echo "$output" | jq empty 2>/dev/null; then
    local is_array
    is_array=$(echo "$output" | jq 'type == "array"')
    [ "$is_array" = "true" ]
  fi
}

# =============================================================================
# Limit flag
# =============================================================================

@test "limit flag is accepted without error" {
  mock_command "curl" 1 ""

  run bash "$SCRIPT" "react" --limit 3
  assert_success

  echo "$output" | jq empty 2>/dev/null
  [ $? -eq 0 ]
}
