#!/usr/bin/env bats
# tests/form-error-patterns-template.bats
# Tests for form-patterns.md and error-handling-patterns.md agent templates

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  TEMPLATES_DIR="$REPO_ROOT/claude-plugin-vibe-crew/templates"
}

# =============================================================================
# Template existence
# =============================================================================

@test "form-patterns.md template exists" {
  [ -f "$TEMPLATES_DIR/form-patterns.md" ]
}

@test "error-handling-patterns.md template exists" {
  [ -f "$TEMPLATES_DIR/error-handling-patterns.md" ]
}

# =============================================================================
# Form patterns template content
# =============================================================================

@test "form-patterns.md has 8 main sections" {
  local section_count
  section_count=$(grep -c '^## [0-9]' "$TEMPLATES_DIR/form-patterns.md")
  [ "$section_count" -ge 8 ]
}

@test "form-patterns.md covers inline validation" {
  grep -qi 'inline.validation\|validate.*blur' "$TEMPLATES_DIR/form-patterns.md"
}

@test "form-patterns.md covers autocomplete" {
  grep -qi 'autocomplete' "$TEMPLATES_DIR/form-patterns.md"
}

@test "form-patterns.md covers accessibility" {
  grep -qi 'aria-invalid\|aria-describedby\|aria-live' "$TEMPLATES_DIR/form-patterns.md"
}

# =============================================================================
# Error handling patterns template content
# =============================================================================

@test "error-handling-patterns.md has 5 main sections" {
  local section_count
  section_count=$(grep -c '^## [0-9]' "$TEMPLATES_DIR/error-handling-patterns.md")
  [ "$section_count" -ge 5 ]
}

@test "error-handling-patterns.md covers error boundaries" {
  grep -qi 'error.boundar' "$TEMPLATES_DIR/error-handling-patterns.md"
}

@test "error-handling-patterns.md covers empty states" {
  grep -qi 'empty.state' "$TEMPLATES_DIR/error-handling-patterns.md"
}

@test "error-handling-patterns.md covers offline handling" {
  grep -qi 'offline\|service.worker' "$TEMPLATES_DIR/error-handling-patterns.md"
}
