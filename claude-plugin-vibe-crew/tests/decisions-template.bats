#!/usr/bin/env bats
# Tests for the Locked/Deferred/Discretion decision taxonomy in plan templates

load 'test_helper/common-setup'

TEMPLATES_DIR="$(cd "${TESTS_DIR}/../templates" && pwd)"

setup() {
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Clarify checklist has decision categories ---

@test "clarify-checklist: contains Decision Categories section" {
  run grep -c "## Decision Categories" "$TEMPLATES_DIR/clarify-checklist.md"
  assert_success
  [ "$output" -ge 1 ]
}

@test "clarify-checklist: defines Locked category" {
  run grep "Locked" "$TEMPLATES_DIR/clarify-checklist.md"
  assert_success
}

@test "clarify-checklist: defines Deferred category" {
  run grep "Deferred" "$TEMPLATES_DIR/clarify-checklist.md"
  assert_success
}

@test "clarify-checklist: defines Discretion category" {
  run grep "Discretion" "$TEMPLATES_DIR/clarify-checklist.md"
  assert_success
}

@test "clarify-checklist: contains classification rules" {
  run grep "Classification rules" "$TEMPLATES_DIR/clarify-checklist.md"
  assert_success
}

# --- Decisions template structure ---

@test "decisions-template: file exists" {
  [ -f "$TEMPLATES_DIR/decisions.md.template" ]
}

@test "decisions-template: contains Category column header" {
  run grep "| Category |" "$TEMPLATES_DIR/decisions.md.template"
  assert_success
}

@test "decisions-template: contains Rationale column header" {
  run grep "| Rationale |" "$TEMPLATES_DIR/decisions.md.template"
  assert_success
}

@test "decisions-template: contains all three category examples" {
  run grep -c "| Locked \|| Deferred \|| Discretion " "$TEMPLATES_DIR/decisions.md.template"
  assert_success
  [ "$output" -ge 3 ]
}

@test "decisions-template: contains Summary section" {
  run grep "## Summary" "$TEMPLATES_DIR/decisions.md.template"
  assert_success
}

# --- Plan template has updated Decisions table ---

@test "plan-template: Decisions table has Category column" {
  run grep "| Category |" "$TEMPLATES_DIR/plan.md.template"
  assert_success
}

@test "plan-template: Decisions table has Rationale column" {
  run grep "| Rationale |" "$TEMPLATES_DIR/plan.md.template"
  assert_success
}

@test "plan-template: Decisions table includes Locked example" {
  run grep "| Locked |" "$TEMPLATES_DIR/plan.md.template"
  assert_success
}

@test "plan-template: Decisions table includes Discretion example" {
  run grep "| Discretion |" "$TEMPLATES_DIR/plan.md.template"
  assert_success
}

# --- Builder agent references decision taxonomy ---

@test "builder-agent: references Locked/Deferred/Discretion in Clarify sub-step" {
  AGENT_FILE="$(cd "${TESTS_DIR}/../agents" && pwd)/builder.md"
  run grep "Locked/Deferred/Discretion" "$AGENT_FILE"
  assert_success
}

@test "builder-agent: has Decision Category Enforcement in Code phase" {
  AGENT_FILE="$(cd "${TESTS_DIR}/../agents" && pwd)/builder.md"
  run grep "Decision Category Enforcement" "$AGENT_FILE"
  assert_success
}

@test "builder-agent: Code phase references TODO(deferred) for Deferred decisions" {
  AGENT_FILE="$(cd "${TESTS_DIR}/../agents" && pwd)/builder.md"
  run grep "TODO(deferred)" "$AGENT_FILE"
  assert_success
}
