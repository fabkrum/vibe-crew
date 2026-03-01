#!/usr/bin/env bats

# Tests for R1: Review → Builder Feedback Loop

setup() {
  TEST_DIR="$(mktemp -d)"
  mkdir -p "$TEST_DIR/.vibecrew/signals"
  mkdir -p "$TEST_DIR/.vibecrew/reviews"
  export PROJECT_ROOT="$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "feedback file is valid JSON with required fields" {
  cat > "$TEST_DIR/.vibecrew/reviews/review-feat-001-20260301.json" << 'EOF'
{
  "schema_version": "1.0.0",
  "feature_id": "feat-001",
  "feature_name": "Test Feature",
  "reviewed_at": "2026-03-01T10:00:00Z",
  "files_reviewed": 5,
  "verdict": "request-changes",
  "summary": "Critical issues found.",
  "findings": [
    {
      "severity": "critical",
      "category": "correctness",
      "file": "src/components/Example.tsx",
      "line": 42,
      "title": "Missing null check",
      "description": "Props can be undefined.",
      "suggestion": "Add optional chaining."
    }
  ],
  "acceptance_criteria_coverage": {"total": 5, "covered": 4, "uncovered": ["criterion 5"]},
  "stats": {"critical": 1, "warning": 0, "info": 0}
}
EOF

  LATEST_REVIEW="$TEST_DIR/.vibecrew/reviews/review-feat-001-20260301.json"

  # Generate the feedback file the same way the orchestrator would
  jq -n --arg fid "feat-001" --arg rf "$LATEST_REVIEW" --argjson cycle 1 \
    --argjson findings "$(jq '[.findings[] | select(.severity == "critical") | {file, line, title, description, suggestion}]' "$LATEST_REVIEW")" \
    --arg ts "2026-03-01T10:00:00Z" \
    '{feature_id: $fid, review_file: $rf, cycle: $cycle, critical_findings: $findings, timestamp: $ts}' \
    > "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json"

  # Validate the file is valid JSON
  jq . "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json" > /dev/null

  # Validate required fields
  [ "$(jq -r '.feature_id' "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json")" = "feat-001" ]
  [ "$(jq -r '.cycle' "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json")" = "1" ]
  [ "$(jq '.critical_findings | length' "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json")" = "1" ]
}

@test "feedback file contains correct finding structure" {
  cat > "$TEST_DIR/.vibecrew/reviews/review-feat-002-20260301.json" << 'EOF'
{
  "schema_version": "1.0.0",
  "feature_id": "feat-002",
  "feature_name": "Another Feature",
  "reviewed_at": "2026-03-01T11:00:00Z",
  "files_reviewed": 3,
  "verdict": "request-changes",
  "summary": "Multiple critical issues.",
  "findings": [
    {
      "severity": "critical",
      "category": "security",
      "file": "src/api/handler.ts",
      "line": 15,
      "title": "XSS vulnerability",
      "description": "User input not sanitized.",
      "suggestion": "Use DOMPurify."
    },
    {
      "severity": "warning",
      "category": "convention",
      "file": "src/utils/format.ts",
      "line": 8,
      "title": "Naming convention",
      "description": "Function uses camelCase instead of snake_case.",
      "suggestion": "Rename to format_date."
    }
  ],
  "acceptance_criteria_coverage": {"total": 3, "covered": 3, "uncovered": []},
  "stats": {"critical": 1, "warning": 1, "info": 0}
}
EOF

  LATEST_REVIEW="$TEST_DIR/.vibecrew/reviews/review-feat-002-20260301.json"

  jq -n --arg fid "feat-002" --arg rf "$LATEST_REVIEW" --argjson cycle 1 \
    --argjson findings "$(jq '[.findings[] | select(.severity == "critical") | {file, line, title, description, suggestion}]' "$LATEST_REVIEW")" \
    --arg ts "2026-03-01T11:00:00Z" \
    '{feature_id: $fid, review_file: $rf, cycle: $cycle, critical_findings: $findings, timestamp: $ts}' \
    > "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json"

  # Only critical findings should be in the feedback (not warnings)
  [ "$(jq '.critical_findings | length' "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json")" = "1" ]
  [ "$(jq -r '.critical_findings[0].title' "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json")" = "XSS vulnerability" ]
}

@test "approve verdict produces no feedback file" {
  cat > "$TEST_DIR/.vibecrew/reviews/review-feat-003-20260301.json" << 'EOF'
{
  "schema_version": "1.0.0",
  "feature_id": "feat-003",
  "feature_name": "Clean Feature",
  "reviewed_at": "2026-03-01T12:00:00Z",
  "files_reviewed": 4,
  "verdict": "approve",
  "summary": "Looks good.",
  "findings": [],
  "acceptance_criteria_coverage": {"total": 3, "covered": 3, "uncovered": []},
  "stats": {"critical": 0, "warning": 0, "info": 0}
}
EOF

  LATEST_REVIEW="$TEST_DIR/.vibecrew/reviews/review-feat-003-20260301.json"
  VERDICT=$(jq -r '.verdict' "$LATEST_REVIEW")

  # Only create feedback file on request-changes
  if [ "$VERDICT" = "request-changes" ]; then
    jq -n --arg fid "feat-003" '{feature_id: $fid}' > "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json"
  fi

  # Feedback file should NOT exist for approve verdict
  [ ! -f "$TEST_DIR/.vibecrew/signals/builder-review-feedback.json" ]
}
