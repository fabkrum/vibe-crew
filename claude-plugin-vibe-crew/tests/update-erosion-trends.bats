#!/usr/bin/env bats
# tests/update-erosion-trends.bats

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/update-erosion-trends.sh"
  setup_vibecrew_dir
  set_foundation_complete
  mkdir -p "$VIBECREW_DIR/erosion"
}

teardown() {
  teardown_vibecrew_dir
}

@test "handles no snapshots" {
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  assert_output --partial "No erosion snapshots"
}

@test "creates trends file from snapshots" {
  # Create a few snapshots
  for i in 1 2 3; do
    cat > "$VIBECREW_DIR/erosion/erosion-2026-03-0${i}T000000Z.json" <<EOF
{
  "score": $((90 + i)),
  "metrics": { "file_metrics": [] }
}
EOF
  done

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  [ -f "$VIBECREW_DIR/erosion/trends.json" ]
}

@test "calculates average score" {
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-01T000000Z.json" <<'EOF'
{"score": 80, "metrics": {"file_metrics": []}}
EOF
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-02T000000Z.json" <<'EOF'
{"score": 90, "metrics": {"file_metrics": []}}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local avg
  avg=$(jq -r '.average_score' "$VIBECREW_DIR/erosion/trends.json")
  [ "$avg" -eq 85 ]
}

@test "detects stable trend" {
  for i in 1 2 3 4; do
    cat > "$VIBECREW_DIR/erosion/erosion-2026-03-0${i}T000000Z.json" <<'EOF'
{"score": 90, "metrics": {"file_metrics": []}}
EOF
  done

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local direction
  direction=$(jq -r '.direction' "$VIBECREW_DIR/erosion/trends.json")
  [ "$direction" = "stable" ]
}

@test "detects declining trend" {
  # Older scores high, recent scores low (sort -r makes newest = first half)
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-01T000000Z.json" <<'EOF'
{"score": 90, "metrics": {"file_metrics": []}}
EOF
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-02T000000Z.json" <<'EOF'
{"score": 85, "metrics": {"file_metrics": []}}
EOF
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-03T000000Z.json" <<'EOF'
{"score": 55, "metrics": {"file_metrics": []}}
EOF
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-04T000000Z.json" <<'EOF'
{"score": 60, "metrics": {"file_metrics": []}}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local direction
  direction=$(jq -r '.direction' "$VIBECREW_DIR/erosion/trends.json")
  [ "$direction" = "declining" ]
}

@test "tracks file churn" {
  cat > "$VIBECREW_DIR/erosion/erosion-2026-03-01T000000Z.json" <<'EOF'
{"score": 90, "metrics": {"file_metrics": [{"file": "src/app.ts", "loc": 100}]}}
EOF

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local churn
  churn=$(jq -r '.file_churn["src/app.ts"].count // 0' "$VIBECREW_DIR/erosion/trends.json")
  [ "$churn" -eq 1 ]
}

@test "reports window size" {
  for i in 1 2 3; do
    cat > "$VIBECREW_DIR/erosion/erosion-2026-03-0${i}T000000Z.json" <<'EOF'
{"score": 90, "metrics": {"file_metrics": []}}
EOF
  done

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT' '$TEST_PROJECT_DIR'"
  assert_success
  local ws
  ws=$(jq -r '.window_size' "$VIBECREW_DIR/erosion/trends.json")
  [ "$ws" -eq 3 ]
}
