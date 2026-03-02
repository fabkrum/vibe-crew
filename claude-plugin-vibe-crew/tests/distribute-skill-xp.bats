#!/usr/bin/env bats
# tests/distribute-skill-xp.bats
# Tests for scripts/distribute-skill-xp.sh — skill XP allocation across 5 domains

setup() {
  load 'test_helper/common-setup'
  SCRIPT="$SCRIPTS_DIR/distribute-skill-xp.sh"
  setup_vibecrew_dir

  # Enable gamification in config
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = true' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  # Create gamification.json
  cat > "$VIBECREW_DIR/gamification.json" <<'EOF'
{
  "level": 1,
  "xp": 0,
  "xp_this_level": 0,
  "streak": {"current": 0, "best": 0, "last_date": null},
  "badges": [],
  "active_challenges": [],
  "completed_challenges": [],
  "stats": {
    "total_sessions": 0,
    "total_features_shipped": 0,
    "perfect_sessions": 0,
    "best_vibe_score": 0,
    "score_history": []
  },
  "skills": {
    "prompting": {"xp": 0, "level": 0, "max_level": 5},
    "architecture": {"xp": 0, "level": 0, "max_level": 5},
    "testing": {"xp": 0, "level": 0, "max_level": 5},
    "context_management": {"xp": 0, "level": 0, "max_level": 5},
    "workflow_discipline": {"xp": 0, "level": 0, "max_level": 5}
  }
}
EOF

  # Remove empty scores directory to avoid pipefail on ls glob mismatch
  rmdir "$VIBECREW_DIR/scores" 2>/dev/null || true
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

create_score_file() {
  local score="${1:-75}"
  local churn="${2:-0}"
  local cache_ratio="${3:-0.5}"
  local tests_passed="${4:-false}"
  local coverage="${5:-0}"
  local peak_context="${6:-50}"
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-03-02.json" <<EOF
{
  "score": $score,
  "deductions": [],
  "metrics": {
    "tokens": {"cache_ratio": $cache_ratio},
    "prompt_churn": {"sequences": $churn},
    "context": {"peak_usage_percent": $peak_context},
    "quality": {"tests_passed": $tests_passed, "coverage_percent": $coverage}
  }
}
EOF
}

@test "gamification disabled: returns disabled message" {
  local tmp="$VIBECREW_DIR/config.json.tmp"
  jq '.gamification.enabled = false' "$VIBECREW_DIR/config.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/config.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq -e '.message' | grep -q "disabled"
}

@test "gamification.json not found: exits 1" {
  rm -f "$VIBECREW_DIR/gamification.json"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_failure
}

@test "no score file: returns no update" {
  # scores/ directory does not exist
  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local updated
  updated=$(echo "$output" | jq -r '.skills_updated')
  [ "$updated" = "false" ]
}

@test "distributes prompting XP for zero churn" {
  create_score_file 90 0 0.5 false 0 50

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local updated
  updated=$(echo "$output" | jq -r '.skills_updated')
  [ "$updated" = "true" ]
  # Zero churn = +10, score>=80 = +5, score>=90 = +5 = 20 total prompting XP
  local prompting_xp
  prompting_xp=$(echo "$output" | jq '[.changes[] | select(.skill == "prompting") | .xp_added] | .[0]')
  [ "$prompting_xp" -ge 10 ]
}

@test "distributes testing XP when tests pass" {
  create_score_file 75 1 0.5 true 85 50

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local testing_xp
  testing_xp=$(echo "$output" | jq '[.changes[] | select(.skill == "testing") | .xp_added] | .[0]')
  [ "$testing_xp" -ge 10 ]
}

@test "distributes context XP for high cache ratio" {
  create_score_file 75 1 0.75 false 0 40

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local context_xp
  context_xp=$(echo "$output" | jq '[.changes[] | select(.skill == "context_management") | .xp_added] | .[0]')
  # cache_ratio > 0.70 = +15, peak_context < 50 = +10 = 25 total
  [ "$context_xp" -ge 15 ]
}

@test "output is valid JSON" {
  create_score_file 80 0 0.6 true 60 45

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  echo "$output" | jq empty
}

@test "skill XP written to gamification.json" {
  create_score_file 90 0 0.5 false 0 50

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success

  local stored_prompting_xp
  stored_prompting_xp=$(jq -r '.skills.prompting.xp' "$VIBECREW_DIR/gamification.json")
  [ "$stored_prompting_xp" -gt 0 ]
}

@test "architecture XP awarded for completed plan phase" {
  create_score_file 80 1 0.5 false 0 50
  set_active_feature "feat-001" "Test Feature" "code"
  set_phases_completed "plan"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local arch_xp
  arch_xp=$(echo "$output" | jq '[.changes[] | select(.skill == "architecture") | .xp_added] | .[0]')
  [ "$arch_xp" -ge 10 ]
}

@test "workflow discipline XP includes phase count bonus" {
  create_score_file 80 1 0.5 false 0 50
  set_active_feature "feat-001" "Test Feature" "review"
  set_phases_completed "plan" "design" "code" "test"

  run bash -c "cd '$TEST_PROJECT_DIR' && bash '$SCRIPT'"
  assert_success
  local workflow_xp
  workflow_xp=$(echo "$output" | jq '[.changes[] | select(.skill == "workflow_discipline") | .xp_added] | .[0]')
  # 4 phases * 3 = 12 XP minimum
  [ "$workflow_xp" -ge 12 ]
}
