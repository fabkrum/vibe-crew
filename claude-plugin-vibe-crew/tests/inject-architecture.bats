#!/usr/bin/env bats
# tests/inject-architecture.bats
# Tests for scripts/inject-architecture.sh — architecture diagram context injection

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

@test "no state file: silent exit 0" {
  cd "$TEST_PROJECT_DIR"
  rm -f "$VIBECREW_DIR/state.json"

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ -z "$output" ]]
}

@test "foundation not complete: silent exit 0" {
  cd "$TEST_PROJECT_DIR"
  # Default state has foundation.complete=false

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ -z "$output" ]]
}

@test "no architecture directory: silent exit 0" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  rm -rf "$VIBECREW_DIR/architecture"

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ -z "$output" ]]
}

@test "no .mmd files: silent exit 0" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  # architecture/ dir exists (created by setup_vibecrew_dir) but no .mmd files

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ -z "$output" ]]
}

@test "single diagram: outputs header and content" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  cat > "$VIBECREW_DIR/architecture/system.mmd" <<'EOF'
flowchart TD
  A[Client] --> B[Server]
  B --> C[Database]
EOF

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ "$output" == *"Architecture Context"* ]]
  [[ "$output" == *"system"* ]]
  [[ "$output" == *"flowchart TD"* ]]
}

@test "multiple diagrams: outputs all" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  echo 'flowchart TD' > "$VIBECREW_DIR/architecture/system.mmd"
  echo 'erDiagram' > "$VIBECREW_DIR/architecture/schema.mmd"

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ "$output" == *"system"* ]]
  [[ "$output" == *"schema"* ]]
}

@test "shows diagram line count" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  cat > "$VIBECREW_DIR/architecture/system.mmd" <<'EOF'
flowchart TD
  A --> B
  B --> C
  C --> D
  D --> E
EOF

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ "$output" == *"5 lines"* ]]
}

@test "shows diagram count in header" {
  cd "$TEST_PROJECT_DIR"
  set_foundation_complete
  echo 'flowchart TD' > "$VIBECREW_DIR/architecture/system.mmd"
  echo 'erDiagram' > "$VIBECREW_DIR/architecture/schema.mmd"
  echo 'stateDiagram-v2' > "$VIBECREW_DIR/architecture/state-flows.mmd"

  run bash "$SCRIPTS_DIR/inject-architecture.sh"
  assert_success
  [[ "$output" == *"3 diagrams"* ]]
}
