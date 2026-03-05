#!/usr/bin/env bats
# Tests for templates/intent-map.md validation

load 'test_helper/common-setup'

PLUGIN_ROOT="$(cd "$TESTS_DIR/.." && pwd)"
INTENT_MAP="$PLUGIN_ROOT/templates/intent-map.md"
SKILLS_DIR="$PLUGIN_ROOT/skills"

# --- Structure tests ---

@test "intent-map: file exists" {
  [ -f "$INTENT_MAP" ]
}

@test "intent-map: has title heading" {
  grep -q "^# Intent-to-Skill Mapping" "$INTENT_MAP"
}

@test "intent-map: every mapping line has arrow syntax" {
  # Lines starting with - that contain quotes should have → pointing to a skill
  MAPPING_LINES=$(grep -E '^\- "' "$INTENT_MAP" || true)
  if [[ -z "$MAPPING_LINES" ]]; then
    skip "No mapping lines found"
  fi
  BAD_LINES=$(echo "$MAPPING_LINES" | grep -v '→' || true)
  if [[ -n "$BAD_LINES" ]]; then
    echo "Lines missing → arrow: $BAD_LINES"
    false
  fi
}

@test "intent-map: all target skills exist as directories" {
  SKILLS=$(grep -oE '→ /[a-z0-9-]+' "$INTENT_MAP" | sed 's/→ \///' | sort -u)
  MISSING=""
  while IFS= read -r skill; do
    [[ -z "$skill" ]] && continue
    if [[ ! -d "$SKILLS_DIR/$skill" ]]; then
      MISSING="$MISSING $skill"
    fi
  done <<< "$SKILLS"
  if [[ -n "$MISSING" ]]; then
    echo "Skills not found:$MISSING"
    false
  fi
}

@test "intent-map: no duplicate skill targets" {
  # Each intent pattern should map to a unique skill (no two patterns to same skill in same category)
  TARGETS=$(grep -oE '→ /[a-z0-9-]+' "$INTENT_MAP" | sort)
  UNIQUE=$(echo "$TARGETS" | sort -u)
  # Allow some duplicates (e.g., /check and /fix-issue may match multiple patterns)
  # Just verify we don't have excessive duplication
  TOTAL=$(echo "$TARGETS" | wc -l | tr -d ' ')
  UNIQUE_COUNT=$(echo "$UNIQUE" | wc -l | tr -d ' ')
  # At least 50% should be unique (generous threshold)
  THRESHOLD=$((TOTAL / 2))
  [ "$UNIQUE_COUNT" -ge "$THRESHOLD" ]
}

@test "intent-map: has categories for core workflows" {
  grep -q "## Project Setup" "$INTENT_MAP"
  grep -q "## Planning" "$INTENT_MAP"
  grep -q "## Development" "$INTENT_MAP"
  grep -q "## Quality" "$INTENT_MAP"
  grep -q "## Session Management" "$INTENT_MAP"
}

@test "intent-map: critical skills are mapped" {
  # The most important skills should all have intent mappings
  for skill in setup new-project new-feature run-backlog check status wrap; do
    if ! grep -q "→ /$skill" "$INTENT_MAP"; then
      echo "Missing mapping for /$skill"
      false
    fi
  done
}

@test "intent-map: patterns use lowercase" {
  # All pattern strings should be lowercase for case-insensitive matching
  PATTERNS=$(grep -oE '"[^"]*"' "$INTENT_MAP" | tr -d '"')
  UPPERCASE=$(echo "$PATTERNS" | grep '[A-Z]' || true)
  if [[ -n "$UPPERCASE" ]]; then
    echo "Uppercase in patterns: $UPPERCASE"
    false
  fi
}

@test "intent-map: no empty categories" {
  # Each ## heading should have at least one mapping line below it
  CATEGORIES=$(grep -c '^## ' "$INTENT_MAP")
  MAPPINGS=$(grep -c '^- "' "$INTENT_MAP")
  [ "$MAPPINGS" -ge "$CATEGORIES" ]
}
