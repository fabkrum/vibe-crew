#!/usr/bin/env bats
# tests/recommend-companion-skills.bats
# Tests for scripts/recommend-companion-skills.sh — two-tier skill discovery

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
  SCRIPT="$SCRIPTS_DIR/recommend-companion-skills.sh"

  # Back up real companion-skills.json
  PLUGIN_ROOT="$(cd "$SCRIPTS_DIR/.." && pwd)"
  ORIGINAL_REGISTRY="$PLUGIN_ROOT/templates/companion-skills.json"
  BACKUP_REGISTRY="$PLUGIN_ROOT/templates/companion-skills.json.bak"
  cp "$ORIGINAL_REGISTRY" "$BACKUP_REGISTRY"

  cd "$TEST_PROJECT_DIR"
}

teardown() {
  if [[ -f "$BACKUP_REGISTRY" ]]; then
    mv "$BACKUP_REGISTRY" "$ORIGINAL_REGISTRY"
  fi
  teardown_vibecrew_dir
}

# =============================================================================
# No TDR file (without --detect-only)
# =============================================================================

@test "no TDR file: exits 1 with error" {
  run bash "$SCRIPT"
  assert_failure
  assert_output --partial "No TDR file found"
}

@test "explicit nonexistent TDR path: exits 1" {
  run bash "$SCRIPT" "/tmp/nonexistent-tdr.md"
  assert_failure
  assert_output --partial "No TDR file found"
}

# =============================================================================
# --detect-only mode
# =============================================================================

@test "detect-only: returns JSON with empty installed when no skills" {
  run bash "$SCRIPT" --detect-only
  assert_success

  echo "$output" | jq empty 2>/dev/null
  [ $? -eq 0 ]

  local installed_count
  installed_count=$(echo "$output" | jq '.installed | length')
  [ "$installed_count" = "0" ]
}

@test "detect-only: detects skill in project .claude/skills/" {
  mkdir -p "$TEST_PROJECT_DIR/.claude/skills/frontend-design"

  run bash "$SCRIPT" --detect-only
  assert_success

  local installed_count skill_name
  installed_count=$(echo "$output" | jq '.installed | length')
  [ "$installed_count" -ge 1 ]

  skill_name=$(echo "$output" | jq -r '.installed[0].name')
  [ "$skill_name" = "frontend-design" ]
}

@test "detect-only: returns empty arrays for other fields" {
  run bash "$SCRIPT" --detect-only
  assert_success

  local rec_count disc_count rej_count unmatched_count
  rec_count=$(echo "$output" | jq '.registry_recommended | length')
  disc_count=$(echo "$output" | jq '.discovered | length')
  rej_count=$(echo "$output" | jq '.rejected | length')
  unmatched_count=$(echo "$output" | jq '.unmatched_technologies | length')
  [ "$rec_count" = "0" ]
  [ "$disc_count" = "0" ]
  [ "$rej_count" = "0" ]
  [ "$unmatched_count" = "0" ]
}

# =============================================================================
# TDR with matching technologies
# =============================================================================

@test "TDR mentions react: recommends frontend-design and react-best-practices" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# Technology Decision Record

## Frontend Framework
We will use React with Next.js for our frontend.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local rec_count
  rec_count=$(echo "$output" | jq '.registry_recommended | length')
  [ "$rec_count" -ge 2 ]

  # Should include frontend-design
  local has_frontend_design
  has_frontend_design=$(echo "$output" | jq '[.registry_recommended[] | select(.key == "frontend-design")] | length')
  [ "$has_frontend_design" -ge 1 ]

  # Should include react-best-practices
  local has_react
  has_react=$(echo "$output" | jq '[.registry_recommended[] | select(.key == "react-best-practices")] | length')
  [ "$has_react" -ge 1 ]
}

@test "TDR mentions supabase: recommends supabase-postgres-best-practices" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Database: Supabase for authentication and data storage.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local has_supabase
  has_supabase=$(echo "$output" | jq '[.registry_recommended[] | select(.key == "supabase-postgres-best-practices")] | length')
  [ "$has_supabase" -ge 1 ]
}

@test "TDR mentions stripe: recommends stripe-best-practices" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Payments: Stripe for subscription billing.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local has_stripe
  has_stripe=$(echo "$output" | jq '[.registry_recommended[] | select(.key == "stripe-best-practices")] | length')
  [ "$has_stripe" -ge 1 ]
}

# =============================================================================
# Case-insensitive matching
# =============================================================================

@test "case-insensitive: REACT in TDR matches react patterns" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Frontend: REACT with NEXT.JS
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local rec_count
  rec_count=$(echo "$output" | jq '.registry_recommended | length')
  [ "$rec_count" -ge 1 ]
}

# =============================================================================
# Already installed skills are excluded from recommendations
# =============================================================================

@test "installed skill not in recommendations" {
  mkdir -p "$TEST_PROJECT_DIR/.claude/skills/frontend-design"
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Frontend: React with Tailwind CSS.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  # frontend-design should NOT be in recommendations (it's installed)
  local has_frontend_design
  has_frontend_design=$(echo "$output" | jq '[.registry_recommended[] | select(.key == "frontend-design")] | length')
  [ "$has_frontend_design" = "0" ]
}

# =============================================================================
# TDR with no matching technologies
# =============================================================================

@test "TDR with no matches: zero recommendations" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
We will build a static HTML website with vanilla JavaScript.
No frameworks, no external services.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local rec_count
  rec_count=$(echo "$output" | jq '.registry_recommended | length')
  [ "$rec_count" = "0" ]
}

# =============================================================================
# --registry-only mode
# =============================================================================

@test "registry-only: discovered array is always empty" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Database: Prisma ORM with PostgreSQL.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local disc_count
  disc_count=$(echo "$output" | jq '.discovered | length')
  [ "$disc_count" = "0" ]
}

# =============================================================================
# JSON output structure
# =============================================================================

@test "output contains valid JSON with all required fields" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Stack: React, Supabase, Stripe.
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  echo "$output" | jq empty 2>/dev/null
  [ $? -eq 0 ]

  local has_installed has_rec has_disc has_rej has_unmatched
  has_installed=$(echo "$output" | jq 'has("installed")')
  has_rec=$(echo "$output" | jq 'has("registry_recommended")')
  has_disc=$(echo "$output" | jq 'has("discovered")')
  has_rej=$(echo "$output" | jq 'has("rejected")')
  has_unmatched=$(echo "$output" | jq 'has("unmatched_technologies")')
  [ "$has_installed" = "true" ]
  [ "$has_rec" = "true" ]
  [ "$has_disc" = "true" ]
  [ "$has_rej" = "true" ]
  [ "$has_unmatched" = "true" ]
}

@test "registry recommendations include install command and source" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-test.md" <<'EOF'
# TDR
Payments: Stripe
EOF

  run bash "$SCRIPT" "$TEST_PROJECT_DIR/docs/TDR-test.md" --registry-only
  assert_success

  local install source
  install=$(echo "$output" | jq -r '.registry_recommended[0].install // empty')
  source=$(echo "$output" | jq -r '.registry_recommended[0].source // empty')
  [ -n "$install" ]
  [ -n "$source" ]
}

# =============================================================================
# Auto-detect TDR file
# =============================================================================

@test "auto-detect: finds TDR in docs/ directory" {
  mkdir -p "$TEST_PROJECT_DIR/docs"
  cat > "$TEST_PROJECT_DIR/docs/TDR-myproject.md" <<'EOF'
# TDR
Frontend: React
EOF

  run bash "$SCRIPT" --registry-only
  assert_success

  local rec_count
  rec_count=$(echo "$output" | jq '.registry_recommended | length')
  [ "$rec_count" -ge 1 ]
}
