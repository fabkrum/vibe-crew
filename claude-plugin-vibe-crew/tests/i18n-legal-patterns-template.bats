#!/usr/bin/env bats
# tests/i18n-legal-patterns-template.bats
# Tests for i18n-patterns.md and legal-compliance.md agent templates
# and validate-legal-compliance.sh script

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  TEMPLATES_DIR="$REPO_ROOT/claude-plugin-vibe-crew/templates"
  SCRIPTS_DIR="$REPO_ROOT/claude-plugin-vibe-crew/scripts"
}

# =============================================================================
# Template existence
# =============================================================================

@test "i18n-patterns.md template exists" {
  [ -f "$TEMPLATES_DIR/i18n-patterns.md" ]
}

@test "legal-compliance.md template exists" {
  [ -f "$TEMPLATES_DIR/legal-compliance.md" ]
}

# =============================================================================
# i18n patterns template content
# =============================================================================

@test "i18n-patterns.md has 7 main sections" {
  local section_count
  section_count=$(grep -c '^## [0-9]' "$TEMPLATES_DIR/i18n-patterns.md")
  [ "$section_count" -ge 7 ]
}

@test "i18n-patterns.md covers RTL layout" {
  grep -qi 'rtl\|right.to.left\|dir="rtl"' "$TEMPLATES_DIR/i18n-patterns.md"
}

@test "i18n-patterns.md covers Intl API" {
  grep -qi 'Intl\.NumberFormat\|Intl\.DateTimeFormat' "$TEMPLATES_DIR/i18n-patterns.md"
}

@test "i18n-patterns.md covers logical properties" {
  grep -qi 'logical.propert\|margin-inline\|padding-block' "$TEMPLATES_DIR/i18n-patterns.md"
}

# =============================================================================
# Legal compliance template content
# =============================================================================

@test "legal-compliance.md has 7 main sections" {
  local section_count
  section_count=$(grep -c '^## [0-9]' "$TEMPLATES_DIR/legal-compliance.md")
  [ "$section_count" -ge 7 ]
}

@test "legal-compliance.md covers GDPR" {
  grep -qi 'GDPR' "$TEMPLATES_DIR/legal-compliance.md"
}

@test "legal-compliance.md covers cookie consent" {
  grep -qi 'cookie.consent\|TTDSG\|ePrivacy' "$TEMPLATES_DIR/legal-compliance.md"
}

@test "legal-compliance.md covers impressum" {
  grep -qi 'impressum\|TMG' "$TEMPLATES_DIR/legal-compliance.md"
}

# =============================================================================
# validate-legal-compliance.sh script
# =============================================================================

@test "validate-legal-compliance.sh exists and is executable" {
  [ -x "$SCRIPTS_DIR/validate-legal-compliance.sh" ]
}

@test "validate-legal-compliance.sh produces valid JSON on empty project" {
  local tmpdir
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/src"
  local output
  output=$("$SCRIPTS_DIR/validate-legal-compliance.sh" "$tmpdir" 2>/dev/null || true)
  rm -rf "$tmpdir"
  echo "$output" | jq -e '.checks' >/dev/null 2>&1
}

@test "validate-legal-compliance.sh detects privacy policy page" {
  local tmpdir
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/src/pages"
  echo "Privacy Policy content" > "$tmpdir/src/pages/privacy.tsx"
  local output
  output=$("$SCRIPTS_DIR/validate-legal-compliance.sh" "$tmpdir" 2>/dev/null || true)
  rm -rf "$tmpdir"
  echo "$output" | jq -e '.checks[] | select(.name == "privacy_policy" and .status == "pass")' >/dev/null 2>&1
}
