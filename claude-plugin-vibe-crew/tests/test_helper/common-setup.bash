#!/usr/bin/env bash
# tests/test_helper/common-setup.bash
# Shared test fixtures and helpers for BATS tests

# Load BATS libraries
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
load "${TESTS_DIR}/bats-support/load"
load "${TESTS_DIR}/bats-assert/load"

# Path to scripts under test
SCRIPTS_DIR="$(cd "${TESTS_DIR}/../scripts" && pwd)"

# --- Setup / Teardown ---

setup_vibecrew_dir() {
  # Create a temp project with .vibecrew/ structure
  # Resolve symlinks (macOS /var -> /private/var) so git rev-parse matches
  TEST_PROJECT_DIR="$(cd "$(mktemp -d)" && pwd -P)"
  VIBECREW_DIR="$TEST_PROJECT_DIR/.vibecrew"
  mkdir -p "$VIBECREW_DIR"/{sessions,scores,signals,locks,architecture,releases,handoffs,workflows}

  # Initialize git so scripts can find project root
  git init "$TEST_PROJECT_DIR" --initial-branch=main >/dev/null 2>&1
  git -C "$TEST_PROJECT_DIR" config user.email "test@test.com"
  git -C "$TEST_PROJECT_DIR" config user.name "Test"

  # Write default state.json
  create_state_json > "$VIBECREW_DIR/state.json"

  # Write default backlog.json
  create_backlog_json > "$VIBECREW_DIR/backlog.json"

  # Write default config.json
  create_config_json > "$VIBECREW_DIR/config.json"

  export TEST_PROJECT_DIR VIBECREW_DIR
}

teardown_vibecrew_dir() {
  if [[ -n "${TEST_PROJECT_DIR:-}" ]] && [[ -d "$TEST_PROJECT_DIR" ]]; then
    rm -rf "$TEST_PROJECT_DIR"
  fi
}

# --- Hook Input Builder ---

create_hook_input() {
  local tool_name="${1:-Bash}"
  local command="${2:-echo hello}"
  local file_path="${3:-}"

  if [[ -n "$file_path" ]]; then
    cat <<EOF
{
  "tool_name": "$tool_name",
  "tool_input": {
    "command": "$command",
    "file_path": "$file_path"
  }
}
EOF
  else
    cat <<EOF
{
  "tool_name": "$tool_name",
  "tool_input": {
    "command": "$command"
  }
}
EOF
  fi
}

create_write_hook_input() {
  local file_path="$1"
  cat <<EOF
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "$file_path",
    "content": "test content"
  }
}
EOF
}

create_edit_hook_input() {
  local file_path="$1"
  cat <<EOF
{
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "$file_path",
    "old_string": "old",
    "new_string": "new"
  }
}
EOF
}

# --- State/Backlog Fixture Builders ---

create_state_json() {
  local foundation_complete="${1:-false}"
  local active_feature_id="${2:-null}"
  local active_feature_name="${3:-null}"
  local active_phase="${4:-null}"
  local schema_version="${5:-1.4.0}"

  # Quote strings, leave null unquoted
  local id_val name_val phase_val
  if [[ "$active_feature_id" == "null" ]]; then id_val="null"; else id_val="\"$active_feature_id\""; fi
  if [[ "$active_feature_name" == "null" ]]; then name_val="null"; else name_val="\"$active_feature_name\""; fi
  if [[ "$active_phase" == "null" ]]; then phase_val="null"; else phase_val="\"$active_phase\""; fi

  cat <<EOF
{
  "schema_version": "$schema_version",
  "foundation": {
    "complete": $foundation_complete,
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
    "id": $id_val,
    "name": $name_val,
    "worktree": null,
    "phase": $phase_val,
    "phases_completed": []
  },
  "git": { "default_branch": "main", "initialized": false },
  "updated_at": "2026-01-01T00:00:00Z"
}
EOF
}

create_backlog_json() {
  cat <<EOF
{
  "schema_version": "1.4.0",
  "columns": [
    { "id": "idea", "title": "Ideas", "wip_limit": null },
    { "id": "planning", "title": "Planning", "wip_limit": 2 },
    { "id": "planned", "title": "Planned", "wip_limit": 5 },
    { "id": "in-progress", "title": "In Development", "wip_limit": 1 },
    { "id": "testing", "title": "Testing", "wip_limit": 1 },
    { "id": "review", "title": "Review", "wip_limit": 2 },
    { "id": "done", "title": "Done", "wip_limit": null }
  ],
  "features": []
}
EOF
}

create_config_json() {
  cat <<EOF
{
  "schema_version": "1.4.0",
  "terminal": "other",
  "notifications": { "enabled": true },
  "gamification": { "enabled": false },
  "user_profile": {
    "interview_completed": false,
    "gamification_preference": null
  }
}
EOF
}

add_feature_to_backlog() {
  local id="$1"
  local name="$2"
  local column="${3:-planned}"
  local priority="${4:-1}"
  local depends_on="${5:-[]}"

  local backlog_file="$VIBECREW_DIR/backlog.json"
  local tmp="${backlog_file}.tmp"

  jq --arg id "$id" \
     --arg name "$name" \
     --arg col "$column" \
     --argjson pri "$priority" \
     --argjson deps "$depends_on" \
     '.features += [{
       id: $id,
       name: $name,
       column: $col,
       priority: $pri,
       depends_on: $deps,
       labels: [],
       spec: { problem_statement: null, acceptance_criteria: [] },
       phases_completed: [],
       created_at: "2026-01-01T00:00:00Z",
       updated_at: "2026-01-01T00:00:00Z"
     }]' "$backlog_file" > "$tmp" && mv "$tmp" "$backlog_file"
}

set_active_feature() {
  local id="$1"
  local name="$2"
  local phase="${3:-plan}"

  local state_file="$VIBECREW_DIR/state.json"
  local tmp="${state_file}.tmp"

  jq --arg id "$id" --arg name "$name" --arg phase "$phase" \
    '.active_feature.id = $id | .active_feature.name = $name | .active_feature.phase = $phase' \
    "$state_file" > "$tmp" && mv "$tmp" "$state_file"
}

set_foundation_complete() {
  local state_file="$VIBECREW_DIR/state.json"
  local tmp="${state_file}.tmp"

  jq '.foundation.complete = true |
      .foundation.completed_at = "2026-01-01T00:00:00Z" |
      .foundation.artifacts.vision.status = "complete" |
      .foundation.artifacts.design_system.status = "complete" |
      .foundation.artifacts.tdr.status = "complete" |
      .foundation.artifacts.roadmap.status = "complete" |
      .foundation.artifacts.architecture_diagrams.status = "complete" |
      .foundation.artifacts.claude_md.status = "complete"' \
    "$state_file" > "$tmp" && mv "$tmp" "$state_file"
}

set_phases_completed() {
  # Usage: set_phases_completed "plan" "design" "code"
  # Sets active_feature.phases_completed to the given array
  local state_file="$VIBECREW_DIR/state.json"
  local tmp="${state_file}.tmp"

  # Build JSON array from arguments
  local json_array="[]"
  for phase in "$@"; do
    json_array=$(echo "$json_array" | jq --arg p "$phase" '. + [$p]')
  done

  jq --argjson phases "$json_array" \
    '.active_feature.phases_completed = $phases' \
    "$state_file" > "$tmp" && mv "$tmp" "$state_file"
}

create_signal_write_input() {
  # Usage: create_signal_write_input "/path/to/signal.json" '{"feature_id":"feat-001",...}'
  # Builds a Write hook JSON payload with custom file content
  local file_path="$1"
  local content="$2"

  # Escape the content for embedding in JSON
  local escaped_content
  escaped_content=$(printf '%s' "$content" | jq -Rs '.')

  cat <<EOF
{
  "tool_name": "Write",
  "tool_input": {
    "file_path": "$file_path",
    "content": $escaped_content
  }
}
EOF
}
