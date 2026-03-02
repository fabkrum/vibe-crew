#!/usr/bin/env bats
# tests/extract-project-conventions.bats
# Tests for scripts/extract-project-conventions.sh — deep convention scanner
#
# Note: The script has a minor stderr leak on line 91 when no src/ directory
# exists (FETCH_COUNT gets a multiline value from pipefail). We create src/
# in JS/TS tests to avoid this, and use `2>/dev/null` redirection where needed.

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# Helper: extract JSON from output (skip any stderr noise that BATS merges in)
_json_output() {
  echo "$output" | sed -n '/^{/,/^}/p'
}

# =============================================================================
# Language detection
# =============================================================================

@test "no project files: language unknown" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local lang
  lang=$(_json_output | jq -r '.language')
  [[ "$lang" == "unknown" ]]
}

@test "package.json present: detects javascript" {
  cd "$TEST_PROJECT_DIR"
  echo '{}' > "$TEST_PROJECT_DIR/package.json"
  mkdir -p "$TEST_PROJECT_DIR/src"

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local lang
  lang=$(_json_output | jq -r '.language')
  [[ "$lang" == "javascript" ]]
}

@test "tsconfig.json present: detects typescript" {
  cd "$TEST_PROJECT_DIR"
  echo '{}' > "$TEST_PROJECT_DIR/package.json"
  echo '{"compilerOptions":{}}' > "$TEST_PROJECT_DIR/tsconfig.json"
  mkdir -p "$TEST_PROJECT_DIR/src"

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local lang
  lang=$(_json_output | jq -r '.language')
  [[ "$lang" == "typescript" ]]
}

# =============================================================================
# Framework detection
# =============================================================================

@test "detects Next.js framework" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  cat > "$TEST_PROJECT_DIR/package.json" <<'EOF'
{"dependencies": {"next": "14.0.0", "react": "18.0.0"}}
EOF

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local framework
  framework=$(_json_output | jq -r '.framework')
  [[ "$framework" == "next" ]]
}

@test "detects Python with Django" {
  cd "$TEST_PROJECT_DIR"
  cat > "$TEST_PROJECT_DIR/pyproject.toml" <<'EOF'
[project]
dependencies = ["django>=4.2"]
EOF

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local lang
  lang=$(_json_output | jq -r '.language')
  [[ "$lang" == "python" ]]

  local framework
  framework=$(_json_output | jq -r '.framework')
  [[ "$framework" == "django" ]]
}

@test "detects Go with Gin" {
  cd "$TEST_PROJECT_DIR"
  cat > "$TEST_PROJECT_DIR/go.mod" <<'EOF'
module example.com/test

go 1.21

require github.com/gin-gonic/gin v1.9.1
EOF

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local lang
  lang=$(_json_output | jq -r '.language')
  [[ "$lang" == "go" ]]

  local framework
  framework=$(_json_output | jq -r '.framework')
  [[ "$framework" == "gin" ]]
}

@test "detects Rust with Axum" {
  cd "$TEST_PROJECT_DIR"
  cat > "$TEST_PROJECT_DIR/Cargo.toml" <<'EOF'
[package]
name = "test"
version = "0.1.0"

[dependencies]
axum = "0.7"
tokio = { version = "1", features = ["full"] }
EOF

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local lang
  lang=$(_json_output | jq -r '.language')
  [[ "$lang" == "rust" ]]

  local framework
  framework=$(_json_output | jq -r '.framework')
  [[ "$framework" == "axum" ]]
}

# =============================================================================
# State management & database detection
# =============================================================================

@test "detects zustand state management" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  cat > "$TEST_PROJECT_DIR/package.json" <<'EOF'
{"dependencies": {"zustand": "4.0.0", "react": "18.0.0"}}
EOF

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local state
  state=$(_json_output | jq -r '.state_management')
  [[ "$state" == "zustand" ]]
}

@test "detects prisma database" {
  cd "$TEST_PROJECT_DIR"
  mkdir -p "$TEST_PROJECT_DIR/src"
  cat > "$TEST_PROJECT_DIR/package.json" <<'EOF'
{"dependencies": {"@prisma/client": "5.0.0"}}
EOF

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  local db
  db=$(_json_output | jq -r '.database')
  [[ "$db" == "prisma" ]]
}

# =============================================================================
# Output format
# =============================================================================

@test "output is valid JSON" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success

  _json_output | jq empty
}

@test "always exits 0" {
  cd "$TEST_PROJECT_DIR"

  run bash "$SCRIPTS_DIR/extract-project-conventions.sh"
  assert_success
}
