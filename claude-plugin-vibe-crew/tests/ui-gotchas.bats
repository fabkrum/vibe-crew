#!/usr/bin/env bats
# tests/ui-gotchas.bats
# Tests for ui-gotchas.md condensed pattern reference

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  PLUGIN_DIR="$REPO_ROOT/claude-plugin-vibe-crew"
}

# =============================================================================
# Template: ui-gotchas.md exists and has required sections
# =============================================================================

@test "templates/ui-gotchas.md exists" {
  [ -f "$PLUGIN_DIR/templates/ui-gotchas.md" ]
}

@test "ui-gotchas.md is under 100 lines" {
  local lines
  lines=$(wc -l < "$PLUGIN_DIR/templates/ui-gotchas.md")
  [ "$lines" -le 100 ]
}

@test "ui-gotchas.md contains all required sections" {
  local template="$PLUGIN_DIR/templates/ui-gotchas.md"
  grep -q "## HTML & Head" "$template"
  grep -q "## Forms" "$template"
  grep -q "## Media & Fonts" "$template"
  grep -q "## Mobile & Touch" "$template"
  grep -q "## Animation" "$template"
  grep -q "## Legal" "$template"
  grep -q "## Auth" "$template"
  grep -q "## SEO & Caching" "$template"
  grep -q "## Business & Conversion" "$template"
  grep -q "## Dark Patterns" "$template"
  grep -q "## i18n" "$template"
  grep -q "## Collaboration" "$template"
  grep -q "## Settings" "$template"
  grep -q "## Notifications" "$template"
  grep -q "## Filter & Search" "$template"
  grep -q "## Data Visualization" "$template"
  grep -q "## Onboarding" "$template"
  grep -q "## Social" "$template"
}

@test "ui-gotchas.md contains dark pattern detection checklist" {
  local template="$PLUGIN_DIR/templates/ui-gotchas.md"
  grep -q "Equal weight test" "$template"
  grep -q "Transparency test" "$template"
  grep -q "Reversibility test" "$template"
  grep -q "Neutral language test" "$template"
}

@test "ui-gotchas.md contains key non-obvious rules" {
  local template="$PLUGIN_DIR/templates/ui-gotchas.md"
  grep -q "charset" "$template"
  grep -q "100dvh" "$template"
  grep -q "font-size: 16px" "$template"
  grep -q "ease-out.*enter" "$template"
  grep -q "grid-template-rows" "$template"
  grep -q "llms.txt" "$template"
}

# =============================================================================
# Agent references: builder.md and code-reviewer.md use ui-gotchas.md
# =============================================================================

@test "builder.md references ui-gotchas.md" {
  grep -q "ui-gotchas.md" "$PLUGIN_DIR/agents/builder.md"
}

@test "builder.md does not reference individual pattern files in design phase" {
  # Should not have direct reads of individual pattern files (except components.md)
  local count
  count=$(grep -c 'templates/.*-patterns\.md' "$PLUGIN_DIR/agents/builder.md" || true)
  [ "$count" -eq 0 ]
}

@test "code-reviewer.md references ui-gotchas.md" {
  grep -q "ui-gotchas.md" "$PLUGIN_DIR/agents/code-reviewer.md"
}

@test "code-reviewer.md does not reference individual pattern files in compliance steps" {
  # Should not have direct reads of individual pattern files
  local count
  count=$(grep -c 'templates/.*-patterns\.md' "$PLUGIN_DIR/agents/code-reviewer.md" || true)
  [ "$count" -eq 0 ]
}
