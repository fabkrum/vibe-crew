#!/usr/bin/env bats
# tests/collect-erosion-metrics.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/collect-erosion-metrics.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/erosion"

  # Create some source files to analyze
  mkdir -p "$TEST_PROJECT_DIR/src"
}

teardown() {
  teardown_vibecrew_dir
}

@test "outputs valid JSON" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  echo "$output" | jq -e '.timestamp' >/dev/null
}

@test "reports total project LOC" {
  echo 'const x = 1;' > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local loc
  loc=$(echo "$output" | jq -r '.total_project_loc')
  [ "$loc" -ge 1 ]
}

@test "reports dependencies from package.json" {
  cat > "$TEST_PROJECT_DIR/package.json" <<'EOF'
{
  "name": "test",
  "dependencies": { "react": "^18", "next": "^14" },
  "devDependencies": { "typescript": "^5" }
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local deps
  deps=$(echo "$output" | jq -r '.total_dependencies')
  [ "$deps" -eq 2 ]
  local dev_deps
  dev_deps=$(echo "$output" | jq -r '.total_dev_dependencies')
  [ "$dev_deps" -eq 1 ]
}

@test "analyzes modified source files" {
  # Create a file and commit on default branch
  echo 'const a = 1;' > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  # Modify on feature branch
  git -C "$TEST_PROJECT_DIR" checkout -b feat-test >/dev/null 2>&1
  cat > "$TEST_PROJECT_DIR/src/app.ts" <<'EOF'
const a = 1;
const b = 2;
if (a > b) {
  console.log("a");
} else {
  console.log("b");
}
function hello() {
  return "world";
}
EOF
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "feat" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local count
  count=$(echo "$output" | jq '.file_metrics | length')
  [ "$count" -ge 1 ]
}

@test "counts complexity keywords" {
  echo 'const a = 1;' > "$TEST_PROJECT_DIR/src/base.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  git -C "$TEST_PROJECT_DIR" checkout -b feat-complex >/dev/null 2>&1
  cat > "$TEST_PROJECT_DIR/src/base.ts" <<'EOF'
if (x) { }
if (y) { } else { }
for (let i = 0; i < 10; i++) { }
while (true) { }
switch(z) { case 1: break; }
EOF
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "complex" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local complexity
  complexity=$(echo "$output" | jq '.file_metrics[0].complexity')
  [ "$complexity" -ge 4 ]
}

@test "counts imports" {
  echo 'const x = 1;' > "$TEST_PROJECT_DIR/src/imports.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  git -C "$TEST_PROJECT_DIR" checkout -b feat-imports >/dev/null 2>&1
  cat > "$TEST_PROJECT_DIR/src/imports.ts" <<'EOF'
import React from 'react';
import { useState } from 'react';
import axios from 'axios';
const x = require('lodash');
EOF
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "imports" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local imports
  imports=$(echo "$output" | jq '.file_metrics[0].imports')
  [ "$imports" -eq 4 ]
}

@test "handles empty project" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local files
  files=$(echo "$output" | jq '.files_analyzed')
  [ "$files" -eq 0 ]
}

@test "reports files over LOC limit" {
  echo 'const x = 1;' > "$TEST_PROJECT_DIR/src/big.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  git -C "$TEST_PROJECT_DIR" checkout -b feat-big >/dev/null 2>&1
  # Generate a 350-line file
  {
    for i in $(seq 1 350); do
      echo "const line_$i = $i;"
    done
  } > "$TEST_PROJECT_DIR/src/big.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "big file" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local over
  over=$(echo "$output" | jq '.files_over_loc_limit')
  [ "$over" -eq 1 ]
}

@test "excludes node_modules" {
  mkdir -p "$TEST_PROJECT_DIR/node_modules/pkg"
  echo 'const x = 1;' > "$TEST_PROJECT_DIR/node_modules/pkg/index.js"
  echo 'const y = 2;' > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  # node_modules should not inflate LOC significantly
  local loc
  loc=$(echo "$output" | jq '.total_project_loc')
  [ "$loc" -lt 10 ]
}

@test "handles no package.json" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local deps
  deps=$(echo "$output" | jq '.total_dependencies')
  [ "$deps" -eq 0 ]
}
