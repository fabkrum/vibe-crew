#!/usr/bin/env bats
# tests/animation-patterns-template.bats
# Tests for animation-patterns.md and responsive-patterns.md agent templates
# and design-system.css.template motion tokens

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  TEMPLATES_DIR="$REPO_ROOT/claude-plugin-vibe-crew/templates"
  DESIGN_SYSTEM="$TEMPLATES_DIR/design-system.css.template"
}

# =============================================================================
# Template existence
# =============================================================================

@test "animation-patterns.md template exists" {
  [ -f "$TEMPLATES_DIR/animation-patterns.md" ]
}

@test "responsive-patterns.md template exists" {
  [ -f "$TEMPLATES_DIR/responsive-patterns.md" ]
}

# =============================================================================
# Animation patterns template content
# =============================================================================

@test "animation-patterns.md has 6 main sections" {
  local section_count
  section_count=$(grep -c '^## [0-9]' "$TEMPLATES_DIR/animation-patterns.md")
  [ "$section_count" -ge 6 ]
}

@test "animation-patterns.md covers reduced motion" {
  grep -qi 'reduced.motion\|prefers-reduced-motion' "$TEMPLATES_DIR/animation-patterns.md"
}

@test "animation-patterns.md covers GPU-safe animation" {
  grep -qi 'gpu.safe\|transform.*opacity' "$TEMPLATES_DIR/animation-patterns.md"
}

# =============================================================================
# Responsive patterns template content
# =============================================================================

@test "responsive-patterns.md has 6 main sections" {
  local section_count
  section_count=$(grep -c '^## [0-9]' "$TEMPLATES_DIR/responsive-patterns.md")
  [ "$section_count" -ge 6 ]
}

@test "responsive-patterns.md covers mobile-first" {
  grep -qi 'mobile.first' "$TEMPLATES_DIR/responsive-patterns.md"
}

@test "responsive-patterns.md covers touch targets" {
  grep -qi 'touch.target\|44.*44' "$TEMPLATES_DIR/responsive-patterns.md"
}

# =============================================================================
# Design system motion tokens
# =============================================================================

@test "design-system.css.template contains easing curves" {
  grep -q '\-\-ease-default' "$DESIGN_SYSTEM"
  grep -q '\-\-ease-in:' "$DESIGN_SYSTEM"
  grep -q '\-\-ease-out:' "$DESIGN_SYSTEM"
  grep -q '\-\-ease-in-out:' "$DESIGN_SYSTEM"
  grep -q '\-\-ease-spring:' "$DESIGN_SYSTEM"
}

@test "design-system.css.template contains duration scale" {
  grep -q '\-\-duration-instant' "$DESIGN_SYSTEM"
  grep -q '\-\-duration-fast' "$DESIGN_SYSTEM"
  grep -q '\-\-duration-normal' "$DESIGN_SYSTEM"
  grep -q '\-\-duration-slow' "$DESIGN_SYSTEM"
  grep -q '\-\-duration-slower' "$DESIGN_SYSTEM"
}

@test "design-system.css.template contains reduced-motion media query" {
  grep -q 'prefers-reduced-motion' "$DESIGN_SYSTEM"
}
