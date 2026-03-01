#!/usr/bin/env bats

# Tests for the visual verification integration across signal schema,
# score breakdown template, and calculate-vibe-score.sh visual detection.

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir

  SCORE_SCRIPT="$SCRIPTS_DIR/calculate-vibe-score.sh"
  TEMPLATES_DIR="$(cd "$SCRIPTS_DIR/../templates" && pwd)"
  SCHEMA_FILE="$TEMPLATES_DIR/signal-schema.json"
  SCORE_TEMPLATE="$TEMPLATES_DIR/score-breakdown.json.template"
}

teardown() {
  teardown_vibecrew_dir
}

# =============================================================================
# Signal Schema: visual_verification field
# =============================================================================

@test "signal schema defines visual_verification property" {
  local has_field
  has_field=$(jq 'has("properties") and (.properties | has("visual_verification"))' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification is type object" {
  local vv_type
  vv_type=$(jq -r '.properties.visual_verification.type' "$SCHEMA_FILE")
  [ "$vv_type" = "object" ]
}

@test "signal schema visual_verification has screenshots field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("screenshots")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification has console_errors field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("console_errors")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification has token_violations field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("token_violations")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification has viewport field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("viewport")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification has iterations field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("iterations")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification has skipped field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("skipped")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "signal schema visual_verification has reason field" {
  local has_field
  has_field=$(jq '.properties.visual_verification.properties | has("reason")' "$SCHEMA_FILE")
  [ "$has_field" = "true" ]
}

@test "builder-complete signal with visual_verification validates required fields" {
  cat > "$VIBECREW_DIR/test-signal.json" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete",
  "branch": "feat/test",
  "commit": "abc123",
  "changed_files": [
    {"path": "src/components/Hero.tsx", "type": "added"}
  ],
  "visual_verification": {
    "screenshots": 1,
    "console_errors": 0,
    "token_violations": 0,
    "viewport": "1440px",
    "iterations": 1,
    "skipped": false,
    "reason": null
  }
}
EOF

  # Verify all required base fields are present
  for field in feature_id phase timestamp agent status; do
    [ "$(jq -r ".$field" "$VIBECREW_DIR/test-signal.json")" != "null" ]
  done

  # Verify visual_verification fields are present
  [ "$(jq -r '.visual_verification.screenshots' "$VIBECREW_DIR/test-signal.json")" = "1" ]
  [ "$(jq -r '.visual_verification.console_errors' "$VIBECREW_DIR/test-signal.json")" = "0" ]
  [ "$(jq -r '.visual_verification.skipped' "$VIBECREW_DIR/test-signal.json")" = "false" ]
}

@test "builder-complete signal with skipped visual_verification" {
  cat > "$VIBECREW_DIR/test-signal.json" << 'EOF'
{
  "feature_id": "feat-002",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete",
  "visual_verification": {
    "skipped": true,
    "reason": "playwright_unavailable"
  }
}
EOF

  [ "$(jq -r '.visual_verification.skipped' "$VIBECREW_DIR/test-signal.json")" = "true" ]
  [ "$(jq -r '.visual_verification.reason' "$VIBECREW_DIR/test-signal.json")" = "playwright_unavailable" ]
}

# =============================================================================
# Score Breakdown Template: visual_compliance metric
# =============================================================================

@test "score template is valid JSON" {
  jq . "$SCORE_TEMPLATE" > /dev/null
}

@test "score template has visual_compliance metric" {
  local has_field
  has_field=$(jq '.metrics | has("visual_compliance")' "$SCORE_TEMPLATE")
  [ "$has_field" = "true" ]
}

@test "score template visual_compliance has verified field" {
  local val
  val=$(jq -r '.metrics.visual_compliance.verified' "$SCORE_TEMPLATE")
  [ "$val" = "false" ]
}

@test "score template visual_compliance has console_errors field" {
  local val
  val=$(jq -r '.metrics.visual_compliance.console_errors' "$SCORE_TEMPLATE")
  [ "$val" = "0" ]
}

@test "score template visual_compliance has token_violations field" {
  local val
  val=$(jq -r '.metrics.visual_compliance.token_violations' "$SCORE_TEMPLATE")
  [ "$val" = "0" ]
}

@test "score template visual_compliance has viewports_checked field" {
  local val
  val=$(jq -r '.metrics.visual_compliance.viewports_checked' "$SCORE_TEMPLATE")
  [ "$val" = "0" ]
}

@test "score template visual_compliance has clean field" {
  local val
  val=$(jq -r '.metrics.visual_compliance.clean' "$SCORE_TEMPLATE")
  [ "$val" = "false" ]
}

# =============================================================================
# calculate-vibe-score.sh: visual verification detection
# =============================================================================

@test "vibe score output includes visual_verified field" {
  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local has_field
  has_field=$(echo "$output" | jq 'has("visual_verified")')
  [ "$has_field" = "true" ]
}

@test "vibe score output includes visual_clean field" {
  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local has_field
  has_field=$(echo "$output" | jq 'has("visual_clean")')
  [ "$has_field" = "true" ]
}

@test "vibe score output includes visual_token_violations field" {
  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local has_field
  has_field=$(echo "$output" | jq 'has("visual_token_violations")')
  [ "$has_field" = "true" ]
}

@test "vibe score output includes visual_console_errors field" {
  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local has_field
  has_field=$(echo "$output" | jq 'has("visual_console_errors")')
  [ "$has_field" = "true" ]
}

@test "vibe score: no signal file — visual_verified is false" {
  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local verified
  verified=$(echo "$output" | jq -r '.visual_verified')
  [ "$verified" = "false" ]
}

@test "vibe score: no signal file — visual_clean is false" {
  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local clean
  clean=$(echo "$output" | jq -r '.visual_clean')
  [ "$clean" = "false" ]
}

@test "vibe score: builder signal with clean visual — visual_verified true, visual_clean true" {
  set_active_feature "feat-001" "Test Feature" "code"

  cat > "$VIBECREW_DIR/signals/builder-complete.signal" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete",
  "visual_verification": {
    "screenshots": 1,
    "console_errors": 0,
    "token_violations": 0,
    "viewport": "1440px",
    "iterations": 1,
    "skipped": false,
    "reason": null
  }
}
EOF

  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local verified
  verified=$(echo "$output" | jq -r '.visual_verified')
  [ "$verified" = "true" ]

  local clean
  clean=$(echo "$output" | jq -r '.visual_clean')
  [ "$clean" = "true" ]

  local violations
  violations=$(echo "$output" | jq -r '.visual_token_violations')
  [ "$violations" = "0" ]

  local errors
  errors=$(echo "$output" | jq -r '.visual_console_errors')
  [ "$errors" = "0" ]
}

@test "vibe score: builder signal with violations — visual_clean false" {
  set_active_feature "feat-001" "Test Feature" "code"

  cat > "$VIBECREW_DIR/signals/builder-complete.signal" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete",
  "visual_verification": {
    "screenshots": 2,
    "console_errors": 1,
    "token_violations": 3,
    "viewport": "1440px",
    "iterations": 2,
    "skipped": false,
    "reason": null
  }
}
EOF

  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local verified
  verified=$(echo "$output" | jq -r '.visual_verified')
  [ "$verified" = "true" ]

  local clean
  clean=$(echo "$output" | jq -r '.visual_clean')
  [ "$clean" = "false" ]

  local violations
  violations=$(echo "$output" | jq -r '.visual_token_violations')
  [ "$violations" = "3" ]

  local errors
  errors=$(echo "$output" | jq -r '.visual_console_errors')
  [ "$errors" = "1" ]
}

@test "vibe score: builder signal with skipped visual — visual_verified false" {
  set_active_feature "feat-001" "Test Feature" "code"

  cat > "$VIBECREW_DIR/signals/builder-complete.signal" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete",
  "visual_verification": {
    "skipped": true,
    "reason": "no_frontend_changes"
  }
}
EOF

  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local verified
  verified=$(echo "$output" | jq -r '.visual_verified')
  [ "$verified" = "false" ]
}

@test "vibe score: review with visual-compliance findings — visual_verified true" {
  set_active_feature "feat-001" "Test Feature" "review"
  mkdir -p "$VIBECREW_DIR/reviews"

  cat > "$VIBECREW_DIR/reviews/review-feat-001-2026-03-01.json" << 'EOF'
{
  "schema_version": "1.0.0",
  "feature_id": "feat-001",
  "feature_name": "Test Feature",
  "reviewed_at": "2026-03-01T12:00:00Z",
  "files_reviewed": 5,
  "verdict": "comment-only",
  "summary": "Visual compliance issues found.",
  "findings": [
    {
      "severity": "warning",
      "category": "visual-compliance",
      "file": "src/components/Hero.tsx",
      "line": 15,
      "title": "Font size mismatch",
      "description": "Computed font-size 18px differs from --font-size-base 16px.",
      "suggestion": "Use var(--font-size-base) for body text."
    },
    {
      "severity": "critical",
      "category": "visual-compliance",
      "file": "src/app/page.tsx",
      "line": 1,
      "title": "Console error on homepage",
      "description": "Uncaught TypeError in useEffect.",
      "suggestion": "Fix the null reference in the data fetch."
    }
  ],
  "acceptance_criteria_coverage": { "total": 3, "covered": 3, "uncovered": [] },
  "stats": { "critical": 1, "warning": 1, "info": 0 }
}
EOF

  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local verified
  verified=$(echo "$output" | jq -r '.visual_verified')
  [ "$verified" = "true" ]

  local clean
  clean=$(echo "$output" | jq -r '.visual_clean')
  [ "$clean" = "false" ]

  local violations
  violations=$(echo "$output" | jq -r '.visual_token_violations')
  [ "$violations" -ge 1 ]

  local errors
  errors=$(echo "$output" | jq -r '.visual_console_errors')
  [ "$errors" -ge 1 ]
}

@test "vibe score: builder signal without visual_verification field — visual_verified false" {
  set_active_feature "feat-001" "Test Feature" "code"

  cat > "$VIBECREW_DIR/signals/builder-complete.signal" << 'EOF'
{
  "feature_id": "feat-001",
  "phase": "code",
  "timestamp": "2026-03-01T10:00:00Z",
  "agent": "builder",
  "status": "complete"
}
EOF

  run bash "$SCORE_SCRIPT" "$TEST_PROJECT_DIR"
  assert_success

  local verified
  verified=$(echo "$output" | jq -r '.visual_verified')
  [ "$verified" = "false" ]
}

# =============================================================================
# CLAUDE.md template: Visual Development section
# =============================================================================

@test "CLAUDE.md template contains Visual Development section" {
  local template="$TEMPLATES_DIR/CLAUDE.md.template"
  grep -q "## Visual Development" "$template"
}

@test "CLAUDE.md template Visual Development mentions Playwright" {
  local template="$TEMPLATES_DIR/CLAUDE.md.template"
  grep -q "Playwright" "$template"
}

@test "CLAUDE.md template Visual Development mentions design-brief.md" {
  local template="$TEMPLATES_DIR/CLAUDE.md.template"
  grep -q "design-brief.md" "$template"
}

@test "CLAUDE.md template Visual Development section is before Session Learnings" {
  local template="$TEMPLATES_DIR/CLAUDE.md.template"
  local visual_line
  visual_line=$(grep -n "## Visual Development" "$template" | head -1 | cut -d: -f1)
  local session_line
  session_line=$(grep -n "## Session Learnings" "$template" | head -1 | cut -d: -f1)
  [ "$visual_line" -lt "$session_line" ]
}
