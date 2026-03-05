#!/usr/bin/env bats
# tests/calculate-erosion-score.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/calculate-erosion-score.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/erosion"
}

teardown() {
  teardown_vibecrew_dir
}

@test "outputs valid JSON with score" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  echo "$output" | jq -e '.score' >/dev/null
}

@test "returns 100 for clean project" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local score
  score=$(echo "$output" | jq -r '.score')
  [ "$score" -eq 100 ]
}

@test "returns healthy rating for score >= 90" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local rating
  rating=$(echo "$output" | jq -r '.rating')
  [ "$rating" = "healthy" ]
}

@test "deducts for files over LOC limit" {
  # Create a large file
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo 'const x = 1;' > "$TEST_PROJECT_DIR/src/big.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  git -C "$TEST_PROJECT_DIR" checkout -b feat-big >/dev/null 2>&1
  {
    for i in $(seq 1 350); do
      echo "const line_$i = $i;"
    done
  } > "$TEST_PROJECT_DIR/src/big.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "big" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local score
  score=$(echo "$output" | jq -r '.score')
  [ "$score" -lt 100 ]
}

@test "deducts for dependency spike" {
  # Create baseline with 2 deps
  cat > "$VIBECREW_DIR/erosion/baseline.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "captured_at": "2026-01-01T00:00:00Z",
  "total_project_loc": 100,
  "total_dependencies": 2,
  "total_dev_dependencies": 1,
  "files_analyzed": 1,
  "file_metrics": []
}
EOF

  # Create package.json with 7 deps (5 more than baseline)
  cat > "$TEST_PROJECT_DIR/package.json" <<'EOF'
{
  "name": "test",
  "dependencies": { "a": "1", "b": "1", "c": "1", "d": "1", "e": "1", "f": "1", "g": "1" }
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local has_dep_deduction
  has_dep_deduction=$(echo "$output" | jq '[.deductions[] | select(.category == "dependency-spike")] | length')
  [ "$has_dep_deduction" -eq 1 ]
}

@test "awards bonus for LOC decrease" {
  # Baseline with 200 LOC
  cat > "$VIBECREW_DIR/erosion/baseline.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "captured_at": "2026-01-01T00:00:00Z",
  "total_project_loc": 200,
  "total_dependencies": 5,
  "total_dev_dependencies": 1,
  "files_analyzed": 1,
  "file_metrics": []
}
EOF

  # Current project has fewer LOC than baseline
  mkdir -p "$TEST_PROJECT_DIR/src"
  echo 'const x = 1;' > "$TEST_PROJECT_DIR/src/app.ts"
  git -C "$TEST_PROJECT_DIR" add -A && git -C "$TEST_PROJECT_DIR" commit -m "init" >/dev/null 2>&1

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local has_loc_bonus
  has_loc_bonus=$(echo "$output" | jq '[.bonuses[] | select(.category == "loc-decreased")] | length')
  [ "$has_loc_bonus" -eq 1 ]
}

@test "clamps score to 0-100" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local score
  score=$(echo "$output" | jq -r '.score')
  [ "$score" -ge 0 ] && [ "$score" -le 100 ]
}

@test "detects hot files from trends" {
  # Create trends with hot file
  cat > "$VIBECREW_DIR/erosion/trends.json" <<'EOF'
{
  "schema_version": "1.0.0",
  "file_churn": {
    "src/hot.ts": { "count": 7, "last_modified": "2026-03-01T00:00:00Z", "last_simplified": null }
  },
  "hot_files": ["src/hot.ts"]
}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local hot_count
  hot_count=$(echo "$output" | jq '.hot_files | length')
  [ "$hot_count" -eq 1 ]
}

@test "handles missing baseline gracefully" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local score
  score=$(echo "$output" | jq -r '.score')
  [ "$score" -ge 0 ]
}
