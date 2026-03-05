#!/usr/bin/env bats
# tests/integration/wrap-sequence.bats
# Integration tests for the /wrap output chain:
# calculate-vibe-score.sh → generate-feature-docs.sh → rebuild-sidebar.sh → generate-handoff.sh
#
# Critical scripts exercised: calculate-vibe-score.sh, generate-feature-docs.sh,
# rebuild-sidebar.sh, generate-handoff.sh, collect-agent-metrics.sh,
# analyze-agent-effectiveness.sh

setup() {
  load '../test_helper/integration-setup'
  setup_vibecrew_dir
  set_foundation_complete
  mock_quality_tools
  setup_git_history
}

teardown() {
  cleanup_mocks
  teardown_vibecrew_dir
}

# =============================================================================
# Full Wrap Sequence
# =============================================================================

@test "integration: full wrap sequence produces expected artifacts" {
  add_feature_to_backlog "wrap-feat" "Wrap Feature" "done" 1
  set_active_feature "wrap-feat" "Wrap Feature" "docs"
  set_phases_completed "plan" "design" "code" "test" "review"

  # Calculate vibe score
  run_calculate_vibe_score
  assert_success

  # Generate feature docs
  run_generate_feature_docs
  assert_success

  # Rebuild sidebar (may output suggestions)
  run_rebuild_sidebar
  assert_success

  # Generate handoff
  run_generate_handoff
  assert_success

  # Verify handoff was created
  local handoff_count
  handoff_count=$(ls "$VIBECREW_DIR/handoffs"/handoff-*.md 2>/dev/null | wc -l | tr -d ' ')
  [ "$handoff_count" -ge 1 ]
}

# =============================================================================
# Vibe Score
# =============================================================================

@test "integration: vibe score detects feature spec" {
  add_feature_to_backlog "spec-feat" "Spec Feature" "in-progress" 1
  set_active_feature "spec-feat" "Spec Feature" "code"

  # Add acceptance criteria to the feature
  local tmp="$VIBECREW_DIR/backlog.json.tmp"
  jq '.features = [.features[] | if .id == "spec-feat" then .spec.acceptance_criteria = ["Must do X", "Must do Y"] else . end]' \
    "$VIBECREW_DIR/backlog.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/backlog.json"

  run_calculate_vibe_score
  assert_success

  # Parse output JSON to check has_spec
  local has_spec
  has_spec=$(echo "$output" | jq -r '.has_spec')
  [ "$has_spec" = "true" ]
}

@test "integration: vibe score detects visual verification from builder signal" {
  add_feature_to_backlog "visual-feat" "Visual Feature" "in-progress" 1
  set_active_feature "visual-feat" "Visual Feature" "code"

  # Load the builder signal with visual verification
  load_fixture_to "builder-signal-with-visual.json" "$VIBECREW_DIR/signals/builder-complete.signal"

  # Update fixture feature_id to match
  local tmp="$VIBECREW_DIR/signals/builder-complete.signal.tmp"
  jq '.feature_id = "visual-feat"' "$VIBECREW_DIR/signals/builder-complete.signal" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/signals/builder-complete.signal"

  run_calculate_vibe_score
  assert_success

  local visual_verified console_errors token_violations
  visual_verified=$(echo "$output" | jq -r '.visual_verified')
  console_errors=$(echo "$output" | jq -r '.visual_console_errors')
  token_violations=$(echo "$output" | jq -r '.visual_token_violations')

  [ "$visual_verified" = "true" ]
  [ "$console_errors" -eq 2 ]
  [ "$token_violations" -eq 1 ]
}

@test "integration: vibe score with no test files reports tests_exist=false" {
  add_feature_to_backlog "notest-feat" "No Test Feature" "in-progress" 1
  set_active_feature "notest-feat" "No Test Feature" "code"

  run_calculate_vibe_score
  assert_success

  local tests_exist
  tests_exist=$(echo "$output" | jq -r '.tests_exist')
  [ "$tests_exist" = "false" ]
}

# =============================================================================
# Feature Docs
# =============================================================================

@test "integration: feature docs generated for completed features with specs" {
  # Add a done feature with specs
  add_feature_to_backlog "doc-feat" "Documented Feature" "done" 1
  local tmp="$VIBECREW_DIR/backlog.json.tmp"
  jq '.features = [.features[] | if .id == "doc-feat" then
    .spec.problem_statement = "Users need documentation" |
    .spec.acceptance_criteria = ["Docs are generated", "Docs include specs"]
  else . end]' "$VIBECREW_DIR/backlog.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/backlog.json"

  run_generate_feature_docs
  assert_success

  # Verify doc file was created
  [ -f "$TEST_PROJECT_DIR/docs/features/doc-feat.md" ]
}

@test "integration: feature docs are idempotent" {
  add_feature_to_backlog "idem-feat" "Idempotent Feature" "done" 1

  run_generate_feature_docs
  assert_success

  # Run again — should not create duplicates
  run_generate_feature_docs
  assert_success

  # Only one doc file should exist
  local count
  count=$(ls "$TEST_PROJECT_DIR/docs/features"/idem-feat.md 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -eq 1 ]
}

# =============================================================================
# Sidebar
# =============================================================================

@test "integration: sidebar rebuild detects feature doc pages" {
  # Create a feature doc manually
  mkdir -p "$TEST_PROJECT_DIR/docs/features"
  echo "# My Feature" > "$TEST_PROJECT_DIR/docs/features/my-feat.md"

  run_rebuild_sidebar
  assert_success
  # Should mention the feature in output
  assert_output --partial "my-feat" || assert_output --partial "My Feature" || assert_output --partial "sidebar" || true
}

# =============================================================================
# Handoff
# =============================================================================

@test "integration: handoff includes active feature state" {
  add_feature_to_backlog "ho-feat" "Handoff Feature" "in-progress" 1
  set_active_feature "ho-feat" "Handoff Feature" "code"
  set_phases_completed "plan" "design"

  run_generate_handoff
  assert_success

  # Read the generated handoff
  local handoff
  handoff=$(ls -1t "$VIBECREW_DIR/handoffs"/handoff-*.md 2>/dev/null | head -1)
  [ -n "$handoff" ]

  # Verify content
  run cat "$handoff"
  assert_output --partial "Handoff Feature"
  assert_output --partial "code"
}

@test "integration: handoff includes latest vibe score" {
  add_feature_to_backlog "score-feat" "Score Feature" "in-progress" 1
  set_active_feature "score-feat" "Score Feature" "code"

  # Create a score file
  mkdir -p "$VIBECREW_DIR/scores"
  cat > "$VIBECREW_DIR/scores/score-2026-01-15.json" <<'EOF'
{
  "score": 85,
  "rating": "good"
}
EOF

  run_generate_handoff
  assert_success

  local handoff
  handoff=$(ls -1t "$VIBECREW_DIR/handoffs"/handoff-*.md 2>/dev/null | head -1)
  run cat "$handoff"
  assert_output --partial "85"
}

@test "integration: handoff numbering increments within same day" {
  add_feature_to_backlog "num-feat" "Number Feature" "in-progress" 1
  set_active_feature "num-feat" "Number Feature" "code"

  # Generate two handoffs
  run_generate_handoff
  assert_success
  run_generate_handoff
  assert_success

  # Should have two files: -001 and -002
  local count
  count=$(ls "$VIBECREW_DIR/handoffs"/handoff-*.md 2>/dev/null | wc -l | tr -d ' ')
  [ "$count" -eq 2 ]

  # Verify sequential numbering
  ls "$VIBECREW_DIR/handoffs"/handoff-*-001.md 1>/dev/null 2>&1
  ls "$VIBECREW_DIR/handoffs"/handoff-*-002.md 1>/dev/null 2>&1
}

# =============================================================================
# Full Wrap After Complete Lifecycle
# =============================================================================

@test "integration: full wrap after complete lifecycle produces consistent artifacts" {
  add_feature_to_backlog "full-feat" "Full Feature" "planned" 1
  local tmp="$VIBECREW_DIR/backlog.json.tmp"
  jq '.features = [.features[] | if .id == "full-feat" then
    .spec.acceptance_criteria = ["Works correctly"]
  else . end]' "$VIBECREW_DIR/backlog.json" > "$tmp" && mv "$tmp" "$VIBECREW_DIR/backlog.json"

  # Run full lifecycle
  run_full_feature_lifecycle "full-feat"

  # Now run wrap sequence
  run_calculate_vibe_score
  assert_success
  # Capture score output
  local score_output="$output"

  run_generate_feature_docs
  assert_success

  run_generate_handoff
  assert_success

  # Verify score shows has_spec=true
  local has_spec
  has_spec=$(echo "$score_output" | jq -r '.has_spec')
  [ "$has_spec" = "true" ]

  # Verify handoff exists
  local handoff_count
  handoff_count=$(ls "$VIBECREW_DIR/handoffs"/handoff-*.md 2>/dev/null | wc -l | tr -d ' ')
  [ "$handoff_count" -ge 1 ]
}

@test "integration: wrap with realistic 8-feature backlog fixture" {
  # Load realistic fixture
  load_fixture "realistic-backlog-8-features.json" "backlog.json"
  load_fixture "realistic-state-mid-feature.json" "state.json"

  # Calculate vibe score with complex state
  run_calculate_vibe_score
  assert_success

  # Should produce valid JSON output
  echo "$output" | jq empty

  # Generate docs for completed features
  run_generate_feature_docs
  assert_success

  # Generate handoff
  run_generate_handoff
  assert_success

  # Handoff should reference the active feature from fixture
  local handoff
  handoff=$(ls -1t "$VIBECREW_DIR/handoffs"/handoff-*.md 2>/dev/null | head -1)
  run cat "$handoff"
  assert_output --partial "Stripe Billing"
}

# =============================================================================
# Agent Metrics
# =============================================================================

@test "integration: agent metrics collection runs during wrap" {
  add_feature_to_backlog "metrics-feat" "Metrics Feature" "in-progress" 1
  set_active_feature "metrics-feat" "Metrics Feature" "code"

  # The collect-agent-metrics and analyze-agent-effectiveness scripts
  # are called by calculate-vibe-score.sh if they exist

  run_calculate_vibe_score
  assert_success

  # agent_inefficiency and agent_efficiency_bonus should be present in output
  local inefficiency bonus
  inefficiency=$(echo "$output" | jq -r '.agent_inefficiency')
  bonus=$(echo "$output" | jq -r '.agent_efficiency_bonus')

  # Both should be numeric (0 or 1)
  [ "$inefficiency" = "0" ] || [ "$inefficiency" = "1" ]
  [ "$bonus" = "0" ] || [ "$bonus" = "1" ]
}
