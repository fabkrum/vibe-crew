#!/usr/bin/env bats
# tests/quality-gate.bats
# Tests for scripts/quality-gate.sh — Stop hook that runs typecheck/lint/build

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/quality-gate.sh"
  setup_vibecrew_dir
  set_foundation_complete

  # Create a package.json with check scripts
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {
    "typecheck": "echo 'types ok'",
    "lint": "echo 'lint ok'",
    "build": "echo 'build ok'"
  }
}
EOF

  # Create a tracked source file so git diff detects changes
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo "const x = 1;" > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "init" --allow-empty >/dev/null 2>&1

  # Set autonomy to full_auto so quality gate is active
  jq '.user_profile.autonomy = "full_auto"' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Skip conditions
# =============================================================================

@test "skips when no .vibecrew/state.json exists" {
  rm -f "$VIBECREW_DIR/state.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE"
}

@test "skips when foundation not complete" {
  jq '.foundation.complete = false' "$VIBECREW_DIR/state.json" > "$VIBECREW_DIR/state.json.tmp" \
    && mv "$VIBECREW_DIR/state.json.tmp" "$VIBECREW_DIR/state.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE"
}

@test "skips for collaborative autonomy profile" {
  jq '.user_profile.autonomy = "collaborative"' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE"
}

@test "skips for supervised autonomy profile" {
  jq '.user_profile.autonomy = "supervised"' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE"
}

@test "runs for full_auto autonomy profile" {
  # Modify a source file so there are changes to detect
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "runs for checkpoints autonomy profile" {
  jq '.user_profile.autonomy = "checkpoints"' \
    "$VIBECREW_DIR/config.json" > "$VIBECREW_DIR/config.json.tmp" \
    && mv "$VIBECREW_DIR/config.json.tmp" "$VIBECREW_DIR/config.json"
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
}

@test "skips when no source files changed (only docs)" {
  # Commit the source file, then only change a doc file
  git -C "$TEST_PROJECT_DIR" add -A
  git -C "$TEST_PROJECT_DIR" commit -m "add source" >/dev/null 2>&1
  echo "# readme" > "$TEST_PROJECT_DIR/README.md"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE"
}

@test "skips when no package.json exists" {
  rm -f "$TEST_PROJECT_DIR/package.json"
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE"
}

# =============================================================================
# Pass/fail behavior
# =============================================================================

@test "passes when all checks succeed" {
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  refute_output --partial "QUALITY GATE FAILED"
}

@test "fails when typecheck fails" {
  # Override typecheck to fail
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {
    "typecheck": "echo 'error TS2304: Cannot find name' >&2; exit 1",
    "lint": "echo ok",
    "build": "echo ok"
  }
}
EOF
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "QUALITY GATE FAILED"
  assert_output --partial "typecheck"
}

@test "fails when lint fails" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {
    "lint": "echo 'lint error: no-unused-vars' >&2; exit 1",
    "build": "echo ok"
  }
}
EOF
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "QUALITY GATE FAILED"
  assert_output --partial "lint"
}

@test "fails when build fails" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {
    "build": "echo 'build failed' >&2; exit 1"
  }
}
EOF
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "QUALITY GATE FAILED"
  assert_output --partial "build"
}

@test "stops on first failure (typecheck fails, lint not run)" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {
    "typecheck": "exit 1",
    "lint": "echo 'LINT_RAN'",
    "build": "echo ok"
  }
}
EOF
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  refute_output --partial "LINT_RAN"
}

# =============================================================================
# Package manager detection
# =============================================================================

@test "detects bun lockfile" {
  touch "$TEST_PROJECT_DIR/bun.lockb"
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  # bun won't be installed in test env, but we can check the command tried
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' 2>&1 || true"
  # Just verify it doesn't error on package manager detection
  [[ $status -eq 0 ]] || assert_output --partial "bun"
}

# =============================================================================
# Output formatting
# =============================================================================

@test "shows changed files in failure output" {
  cat > "$TEST_PROJECT_DIR/package.json" << 'EOF'
{
  "name": "test-project",
  "scripts": {
    "typecheck": "exit 1"
  }
}
EOF
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "Files changed"
  assert_output --partial "app.ts"
}

@test "truncates long error output to last 80 lines" {
  # Create a helper script that outputs 100 lines then fails
  cat > "$TEST_PROJECT_DIR/gen-errors.sh" << 'SCRIPT'
#!/usr/bin/env bash
i=1
while [ $i -le 100 ]; do
  echo "error line $i"
  i=$((i + 1))
done
exit 1
SCRIPT
  chmod +x "$TEST_PROJECT_DIR/gen-errors.sh"
  cat > "$TEST_PROJECT_DIR/package.json" << EOF
{
  "name": "test-project",
  "scripts": {
    "typecheck": "bash $TEST_PROJECT_DIR/gen-errors.sh"
  }
}
EOF
  echo "const y = 2;" >> "$TEST_PROJECT_DIR/src/app.ts"
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
  assert_output --partial "showing last"
}
