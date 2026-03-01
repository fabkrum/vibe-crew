#!/usr/bin/env bats

# Tests for scripts/visual-verify.sh
# Verifies CSS token parsing, JS payload generation, and graceful degradation.

setup() {
  load 'test_helper/common-setup'

  SCRIPT="$SCRIPTS_DIR/visual-verify.sh"
  TEST_DIR="$(cd "$(mktemp -d)" && pwd -P)"

  # Create a minimal design-system.css for testing
  cat > "$TEST_DIR/design-system.css" << 'CSS'
:root {
  /* Colors */
  --color-primary-500: hsl(220, 70%, 50%);
  --color-bg-primary: #ffffff;
  --color-text-primary: #1a1a2e;

  /* Typography */
  --font-family-sans: "Inter", sans-serif;
  --font-size-base: 16px;
  --font-weight-bold: 700;

  /* Spacing */
  --space-4: 1rem;
  --space-8: 2rem;

  /* References (should be excluded) */
  --color-surface: var(--color-bg-primary);
  --text-default: var(--color-text-primary);

  /* Borders */
  --radius-md: 0.5rem;
}
CSS
}

teardown() {
  rm -rf "$TEST_DIR"
}

# =============================================================================
# Valid output structure
# =============================================================================

@test "outputs valid JSON" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success
  echo "$output" | jq . > /dev/null
}

@test "output contains tokens object" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local has_tokens
  has_tokens=$(echo "$output" | jq 'has("tokens")')
  [ "$has_tokens" = "true" ]
}

@test "output contains evaluate_script string" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local script_type
  script_type=$(echo "$output" | jq -r '.evaluate_script | type')
  [ "$script_type" = "string" ]

  local script_len
  script_len=$(echo "$output" | jq -r '.evaluate_script | length')
  [ "$script_len" -gt 0 ]
}

@test "output contains url field" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:4000" "$TEST_DIR"
  assert_success

  local url
  url=$(echo "$output" | jq -r '.url')
  [ "$url" = "http://localhost:4000" ]
}

@test "output contains css_path field" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local css_path
  css_path=$(echo "$output" | jq -r '.css_path')
  [ "$css_path" = "$TEST_DIR/design-system.css" ]
}

@test "output contains instructions field" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local has_instructions
  has_instructions=$(echo "$output" | jq 'has("instructions")')
  [ "$has_instructions" = "true" ]
}

# =============================================================================
# Token parsing
# =============================================================================

@test "parses HSL color tokens" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local val
  val=$(echo "$output" | jq -r '.tokens["--color-primary-500"]')
  [ "$val" = "hsl(220, 70%, 50%)" ]
}

@test "parses hex color tokens" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local val
  val=$(echo "$output" | jq -r '.tokens["--color-bg-primary"]')
  [ "$val" = "#ffffff" ]
}

@test "parses typography tokens" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local font_size
  font_size=$(echo "$output" | jq -r '.tokens["--font-size-base"]')
  [ "$font_size" = "16px" ]

  local font_weight
  font_weight=$(echo "$output" | jq -r '.tokens["--font-weight-bold"]')
  [ "$font_weight" = "700" ]
}

@test "parses spacing tokens" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local val
  val=$(echo "$output" | jq -r '.tokens["--space-4"]')
  [ "$val" = "1rem" ]
}

@test "parses border radius tokens" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local val
  val=$(echo "$output" | jq -r '.tokens["--radius-md"]')
  [ "$val" = "0.5rem" ]
}

@test "excludes var() references from tokens" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local surface_val
  surface_val=$(echo "$output" | jq -r '.tokens["--color-surface"] // "missing"')
  [ "$surface_val" = "missing" ]

  local text_val
  text_val=$(echo "$output" | jq -r '.tokens["--text-default"] // "missing"')
  [ "$text_val" = "missing" ]
}

@test "token count matches expected raw values" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  # 9 raw values (3 colors + 3 typography + 2 spacing + 1 border), 2 var() references excluded
  local count
  count=$(echo "$output" | jq '.tokens | length')
  [ "$count" -eq 9 ]
}

# =============================================================================
# Evaluate script content
# =============================================================================

@test "evaluate_script contains element selectors" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local script
  script=$(echo "$output" | jq -r '.evaluate_script')
  [[ "$script" == *"body"* ]]
  [[ "$script" == *"h1"* ]]
  [[ "$script" == *"button"* ]]
  [[ "$script" == *"input"* ]]
}

@test "evaluate_script contains CSS property names" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local script
  script=$(echo "$output" | jq -r '.evaluate_script')
  [[ "$script" == *"background-color"* ]]
  [[ "$script" == *"font-family"* ]]
  [[ "$script" == *"font-size"* ]]
  [[ "$script" == *"border-radius"* ]]
}

@test "evaluate_script uses getComputedStyle" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local script
  script=$(echo "$output" | jq -r '.evaluate_script')
  [[ "$script" == *"getComputedStyle"* ]]
}

@test "evaluate_script returns JSON" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local script
  script=$(echo "$output" | jq -r '.evaluate_script')
  [[ "$script" == *"JSON.stringify"* ]]
}

# =============================================================================
# Graceful degradation
# =============================================================================

@test "missing CSS file: exits 0" {
  run bash "$SCRIPT" "$TEST_DIR/nonexistent.css" "http://localhost:3000" "$TEST_DIR"
  assert_success
}

@test "missing CSS file: returns valid JSON with error" {
  run bash "$SCRIPT" "$TEST_DIR/nonexistent.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  echo "$output" | jq . > /dev/null

  local error
  error=$(echo "$output" | jq -r '.error')
  [[ "$error" == *"not found"* ]]
}

@test "missing CSS file: returns empty tokens" {
  run bash "$SCRIPT" "$TEST_DIR/nonexistent.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local count
  count=$(echo "$output" | jq '.tokens | length')
  [ "$count" -eq 0 ]
}

@test "missing CSS file: returns empty evaluate_script" {
  run bash "$SCRIPT" "$TEST_DIR/nonexistent.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local script
  script=$(echo "$output" | jq -r '.evaluate_script')
  [ "$script" = "" ]
}

# =============================================================================
# Default arguments
# =============================================================================

@test "uses default URL when not specified" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css"
  assert_success

  local url
  url=$(echo "$output" | jq -r '.url')
  [ "$url" = "http://localhost:3000" ]
}

# =============================================================================
# Empty CSS file
# =============================================================================

@test "empty CSS file: outputs zero tokens" {
  echo "" > "$TEST_DIR/empty.css"
  run bash "$SCRIPT" "$TEST_DIR/empty.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local count
  count=$(echo "$output" | jq '.tokens | length')
  [ "$count" -eq 0 ]
}

@test "CSS with only comments: outputs zero tokens" {
  cat > "$TEST_DIR/comments.css" << 'CSS'
/* This is a design system */
/* No tokens defined yet */
:root {
  /* placeholder */
}
CSS
  run bash "$SCRIPT" "$TEST_DIR/comments.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local count
  count=$(echo "$output" | jq '.tokens | length')
  [ "$count" -eq 0 ]
}

# =============================================================================
# Edge cases in token values
# =============================================================================

@test "parses font-family with quotes and commas" {
  run bash "$SCRIPT" "$TEST_DIR/design-system.css" "http://localhost:3000" "$TEST_DIR"
  assert_success

  local val
  val=$(echo "$output" | jq -r '.tokens["--font-family-sans"]')
  [[ "$val" == *"Inter"* ]]
  [[ "$val" == *"sans-serif"* ]]
}
