#!/usr/bin/env bats
# Tests for scripts/inject-analysis.sh

load 'test_helper/common-setup'

SCRIPT="$SCRIPTS_DIR/inject-analysis.sh"

setup() {
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
}

# --- Greenfield (no analysis docs) ---

@test "inject-analysis: exits silently when no analysis dir" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  [ -z "$output" ]
}

@test "inject-analysis: exits silently when analysis dir empty" {
  mkdir -p "$VIBECREW_DIR/analysis"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  [ -z "$output" ]
}

# --- With analysis docs ---

@test "inject-analysis: outputs context block with all 4 docs" {
  mkdir -p "$VIBECREW_DIR/analysis"
  echo -e "# Stack Analysis\n- **Language**: TypeScript\n- **Framework**: Next.js" > "$VIBECREW_DIR/analysis/stack.md"
  echo -e "# Architecture Analysis\n- **API Style**: REST" > "$VIBECREW_DIR/analysis/architecture.md"
  echo -e "# Conventions Analysis\n- **Formatter**: Prettier" > "$VIBECREW_DIR/analysis/conventions.md"
  echo -e "# Gaps Analysis\n- **TODO Count**: 12" > "$VIBECREW_DIR/analysis/gaps.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  [[ "$output" == *"--- Codebase Analysis"* ]]
  [[ "$output" == *"TypeScript"* ]]
  [[ "$output" == *"REST"* ]]
  [[ "$output" == *"Prettier"* ]]
  [[ "$output" == *"TODO Count"* ]]
  [[ "$output" == *"--- End Codebase Analysis ---"* ]]
}

@test "inject-analysis: handles partial docs (only stack.md)" {
  mkdir -p "$VIBECREW_DIR/analysis"
  echo -e "# Stack Analysis\n- **Language**: Python" > "$VIBECREW_DIR/analysis/stack.md"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  [[ "$output" == *"Python"* ]]
  [[ "$output" == *"--- End Codebase Analysis ---"* ]]
}
