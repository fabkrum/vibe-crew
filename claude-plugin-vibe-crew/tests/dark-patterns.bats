#!/usr/bin/env bats
# tests/dark-patterns.bats
# Tests for dark patterns prevention system — template, agent references, and docs site data

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  PLUGIN_DIR="$REPO_ROOT/claude-plugin-vibe-crew"
  DOCS_NEXT_DIR="$REPO_ROOT/docs-next"
}

# =============================================================================
# Template: dark-patterns.md exists and has required content
# =============================================================================

@test "templates/dark-patterns.md exists" {
  [ -f "$PLUGIN_DIR/templates/dark-patterns.md" ]
}

@test "dark-patterns.md contains all 5 categories" {
  local template="$PLUGIN_DIR/templates/dark-patterns.md"
  grep -q "Pressure & Urgency" "$template"
  grep -q "Deception & Misdirection" "$template"
  grep -q "Hidden Information" "$template"
  grep -q "Obstruction" "$template"
  grep -q "Preselection" "$template"
}

@test "dark-patterns.md contains all 16 pattern names" {
  local template="$PLUGIN_DIR/templates/dark-patterns.md"
  grep -q "Fake Scarcity" "$template"
  grep -q "Fake Urgency" "$template"
  grep -q "Confirmshaming" "$template"
  grep -q "Nagging" "$template"
  grep -q "Trick Wording" "$template"
  grep -q "Disguised Ads" "$template"
  grep -q "Fake Social Proof" "$template"
  grep -q "Visual Interference" "$template"
  grep -q "Hidden Costs" "$template"
  grep -q "Hidden Subscription" "$template"
  grep -q "Comparison Prevention" "$template"
  grep -q "Hard to Cancel" "$template"
  grep -q "Forced Action" "$template"
  grep -q "Sneaking" "$template"
  grep -q "### Preselection" "$template"
  grep -q "Consent Asymmetry" "$template"
}

@test "dark-patterns.md contains detection checklist" {
  local template="$PLUGIN_DIR/templates/dark-patterns.md"
  grep -q "Detection Checklist" "$template"
  grep -q "Equal weight test" "$template"
  grep -q "Transparency test" "$template"
}

@test "dark-patterns.md contains legal context summary" {
  local template="$PLUGIN_DIR/templates/dark-patterns.md"
  grep -q "Legal Context Summary" "$template"
  grep -q "GDPR" "$template"
  grep -q "FTC" "$template"
  grep -q "CCPA" "$template"
}

# =============================================================================
# Builder agent: references dark pattern prevention via ui-gotchas.md
# =============================================================================

@test "builder.md references ui-gotchas.md for dark pattern checklist" {
  grep -q "ui-gotchas.md" "$PLUGIN_DIR/agents/builder.md"
}

@test "builder.md has mandatory rule against dark patterns" {
  grep -q "NEVER implement dark patterns" "$PLUGIN_DIR/agents/builder.md"
}

# =============================================================================
# Code Reviewer agent: checks dark patterns via ui-gotchas compliance
# =============================================================================

@test "code-reviewer.md references ui-gotchas.md" {
  grep -q "ui-gotchas.md" "$PLUGIN_DIR/agents/code-reviewer.md"
}

@test "code-reviewer.md has dark pattern severity defaults" {
  local reviewer="$PLUGIN_DIR/agents/code-reviewer.md"
  grep -q "Dark patterns" "$reviewer"
  grep -q "Consent asymmetry" "$reviewer"
  grep -q "Confirmshaming" "$reviewer"
}

# =============================================================================
# Legal patterns: dark-patterns category added
# =============================================================================

@test "legal-patterns.ts has dark-patterns category" {
  grep -q "'dark-patterns'" "$DOCS_NEXT_DIR/src/data/legal-patterns.ts"
}

@test "legal-patterns.ts has 4 dark pattern legal entries" {
  local data="$DOCS_NEXT_DIR/src/data/legal-patterns.ts"
  grep -q "Consent Asymmetry" "$data"
  grep -q "Pre-checked Options" "$data"
  grep -q "Hidden Subscription" "$data"
  grep -q "Cancellation Obstruction" "$data"
}

@test "legal-pattern-svgs.ts has SVGs for new legal patterns" {
  local svgs="$DOCS_NEXT_DIR/src/components/patterns/legal-pattern-svgs.ts"
  grep -q "'Consent Asymmetry'" "$svgs"
  grep -q "'Pre-checked Options'" "$svgs"
  grep -q "'Hidden Subscription'" "$svgs"
  grep -q "'Cancellation Obstruction'" "$svgs"
}

# =============================================================================
# Docs site: dark-patterns data file
# =============================================================================

@test "dark-patterns.ts data file exists" {
  [ -f "$DOCS_NEXT_DIR/src/data/dark-patterns.ts" ]
}

@test "dark-patterns.ts exports DarkPattern interface" {
  grep -q "export interface DarkPattern" "$DOCS_NEXT_DIR/src/data/dark-patterns.ts"
}

@test "dark-patterns.ts has all 16 patterns" {
  local count
  count=$(grep -c "name:" "$DOCS_NEXT_DIR/src/data/dark-patterns.ts")
  [ "$count" -ge 16 ]
}

@test "dark-patterns.ts has 5 category labels" {
  local data="$DOCS_NEXT_DIR/src/data/dark-patterns.ts"
  grep -q "pressure:" "$data"
  grep -q "deception:" "$data"
  grep -q "hidden:" "$data"
  grep -q "obstruction:" "$data"
  grep -q "preselection:" "$data"
}

# =============================================================================
# Docs site: SVG illustrations and component
# =============================================================================

@test "dark-pattern-svgs.ts exists" {
  [ -f "$DOCS_NEXT_DIR/src/components/patterns/dark-pattern-svgs.ts" ]
}

@test "DarkPatternIllustration.astro exists" {
  [ -f "$DOCS_NEXT_DIR/src/components/patterns/DarkPatternIllustration.astro" ]
}

@test "DarkPatternIllustration.astro imports from dark-pattern-svgs" {
  grep -q "dark-pattern-svgs" "$DOCS_NEXT_DIR/src/components/patterns/DarkPatternIllustration.astro"
}

# =============================================================================
# Docs site: dark-patterns page
# =============================================================================

@test "dark-patterns.astro page exists" {
  [ -f "$DOCS_NEXT_DIR/src/pages/dark-patterns.astro" ]
}

@test "dark-patterns.astro imports DarkPatternIllustration" {
  grep -q "DarkPatternIllustration" "$DOCS_NEXT_DIR/src/pages/dark-patterns.astro"
}

@test "dark-patterns.astro has ethical design checklist" {
  grep -q "Ethical Design Checklist" "$DOCS_NEXT_DIR/src/pages/dark-patterns.astro"
}

@test "dark-patterns.astro has sources section" {
  grep -q "deceptive.design" "$DOCS_NEXT_DIR/src/pages/dark-patterns.astro"
}

# =============================================================================
# Navigation: dark-patterns in nav
# =============================================================================

@test "navigation.ts includes dark-patterns page" {
  grep -q "dark-patterns" "$DOCS_NEXT_DIR/src/data/navigation.ts"
}

@test "navigation.ts places dark-patterns after legal-compliance" {
  local nav="$DOCS_NEXT_DIR/src/data/navigation.ts"
  local legal_line
  local dark_line
  legal_line=$(grep -n "legal-compliance" "$nav" | head -1 | cut -d: -f1)
  dark_line=$(grep -n "dark-patterns" "$nav" | head -1 | cut -d: -f1)
  [ "$dark_line" -gt "$legal_line" ]
}

# =============================================================================
# Cross-references: legal-compliance links to dark-patterns
# =============================================================================

@test "legal-compliance.astro has related link to dark-patterns" {
  grep -q "/dark-patterns" "$DOCS_NEXT_DIR/src/pages/legal-compliance.astro"
}

@test "legal-compliance.astro has dark-patterns category description" {
  grep -q "dark-patterns" "$DOCS_NEXT_DIR/src/pages/legal-compliance.astro"
}
