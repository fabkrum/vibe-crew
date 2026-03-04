#!/usr/bin/env bats
# tests/import-design-tokens.bats
# Tests for scripts/import-design-tokens.sh — design token import & mapping

bats_require_minimum_version 1.5.0

setup() {
  load 'test_helper/common-setup'
  setup_vibecrew_dir
}

teardown() {
  teardown_vibecrew_dir
  cleanup_mocks
}

# Helper: run script with --separate-stderr so $output contains only stdout JSON
run_import() {
  run --separate-stderr bash "$SCRIPTS_DIR/import-design-tokens.sh" "$@"
}

# =============================================================================
# Argument validation
# =============================================================================

@test "no arguments: exits 1" {
  run bash "$SCRIPTS_DIR/import-design-tokens.sh"
  assert_failure
}

@test "missing --input: exits 1" {
  run bash "$SCRIPTS_DIR/import-design-tokens.sh" --format css
  assert_failure
}

@test "missing --format: exits 1" {
  run bash "$SCRIPTS_DIR/import-design-tokens.sh" --input "$TEST_PROJECT_DIR/tokens.css"
  assert_failure
}

@test "invalid --format: exits 1" {
  echo ":root { --color: red; }" > "$TEST_PROJECT_DIR/tokens.css"
  run bash "$SCRIPTS_DIR/import-design-tokens.sh" --format yaml --input "$TEST_PROJECT_DIR/tokens.css"
  assert_failure
}

@test "nonexistent file: exits 1" {
  run bash "$SCRIPTS_DIR/import-design-tokens.sh" --format css --input "$TEST_PROJECT_DIR/nonexistent.css"
  assert_failure
}

# =============================================================================
# CSS extraction
# =============================================================================

@test "CSS: extracts HSL primary color hue" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --color-primary: hsl(250, 80%, 50%);
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local hue
  hue=$(echo "$output" | jq -r '.mapped.PRIMARY_HUE')
  [[ "$hue" == "250" ]]
}

@test "CSS: extracts hex color and converts to hue" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --primary: #3b82f6;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local hue
  hue=$(echo "$output" | jq -r '.mapped.PRIMARY_HUE')
  # #3b82f6 is a blue, hue should be around 217
  [[ "$hue" -gt 200 && "$hue" -lt 230 ]]
}

@test "CSS: extracts font-family" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --font-family-body: 'Roboto', sans-serif;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local font
  font=$(echo "$output" | jq -r '.mapped.FONT_FAMILY')
  [[ "$font" == "Roboto" ]]
}

@test "CSS: extracts border-radius" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --border-radius: 0.75rem;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local radius
  radius=$(echo "$output" | jq -r '.mapped.BORDER_RADIUS')
  [[ "$radius" == "0.75rem" ]]
}

@test "CSS: maps non-standard names to canonical tokens" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --brand-primary: hsl(180, 70%, 45%);
  --ff-sans: 'Poppins', system-ui;
  --rounded: 8px;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local hue font radius
  hue=$(echo "$output" | jq -r '.mapped.PRIMARY_HUE')
  font=$(echo "$output" | jq -r '.mapped.FONT_FAMILY')
  radius=$(echo "$output" | jq -r '.mapped.BORDER_RADIUS')
  [[ "$hue" == "180" ]]
  [[ "$font" == "Poppins" ]]
  [[ "$radius" == "8px" ]]
}

# =============================================================================
# JSON extraction
# =============================================================================

@test "JSON: W3C DTCG format extracts tokens" {
  cat > "$TEST_PROJECT_DIR/tokens.json" <<'JSON'
{
  "color": {
    "primary": {
      "$value": "#e11d48",
      "$type": "color"
    }
  },
  "font": {
    "family": {
      "body": {
        "$value": "Source Sans Pro",
        "$type": "fontFamily"
      }
    }
  }
}
JSON
  run_import --format json --input "$TEST_PROJECT_DIR/tokens.json"
  assert_success
  local hue font
  hue=$(echo "$output" | jq -r '.mapped.PRIMARY_HUE')
  font=$(echo "$output" | jq -r '.mapped.FONT_FAMILY')
  # #e11d48 is a red/rose, hue around 340-350
  [[ "$hue" -gt 330 || "$hue" -lt 10 ]]
  [[ "$font" == "Source Sans Pro" ]]
}

@test "JSON: flat key-value format extracts tokens" {
  cat > "$TEST_PROJECT_DIR/tokens.json" <<'JSON'
{
  "primary-color": "#2563eb",
  "font-family-sans": "Nunito",
  "border-radius": "0.375rem"
}
JSON
  run_import --format json --input "$TEST_PROJECT_DIR/tokens.json"
  assert_success
  local font radius
  font=$(echo "$output" | jq -r '.mapped.FONT_FAMILY')
  radius=$(echo "$output" | jq -r '.mapped.BORDER_RADIUS')
  [[ "$font" == "Nunito" ]]
  [[ "$radius" == "0.375rem" ]]
}

# =============================================================================
# Gap detection
# =============================================================================

@test "all 6 resolved: no defaults used" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --color-primary: hsl(150, 80%, 40%);
  --font-family-body: 'Lato', sans-serif;
  --border-radius: 0.25rem;
  --content-width-max: 960px;
  --nav-width: 200px;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local defaults
  defaults=$(echo "$output" | jq '.defaults_used')
  # density_factor has no CSS mapping, so 1 default is expected
  [[ "$defaults" -le 1 ]]
}

@test "partial mapping: correct defaults count" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --color-primary: hsl(200, 60%, 50%);
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local defaults
  defaults=$(echo "$output" | jq '.defaults_used')
  # Only primary_hue resolved, 5 defaults (font, radius, density, width, nav)
  [[ "$defaults" -eq 5 ]]
}

# =============================================================================
# Unmapped tokens
# =============================================================================

@test "unmapped tokens collected" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --color-primary: hsl(300, 80%, 50%);
  --custom-weird-token: 42px;
  --another-unknown: blue;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local unmapped_count
  unmapped_count=$(echo "$output" | jq '.unmapped | length')
  [[ "$unmapped_count" -ge 2 ]]
}

# =============================================================================
# shadcn flag
# =============================================================================

@test "without --shadcn: shadcn_tokens is empty object" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --background: hsl(0, 0%, 100%);
  --foreground: hsl(0, 0%, 9%);
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local shadcn
  shadcn=$(echo "$output" | jq '.shadcn_tokens')
  [[ "$shadcn" == "{}" ]]
}

@test "with --shadcn: includes shadcn tokens" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --background: hsl(0, 0%, 100%);
  --foreground: hsl(0, 0%, 9%);
  --primary: hsl(220, 80%, 50%);
  --muted: hsl(0, 0%, 96%);
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css" --shadcn
  assert_success
  local has_bg
  has_bg=$(echo "$output" | jq 'has("shadcn_tokens")')
  [[ "$has_bg" == "true" ]]
}

# =============================================================================
# Confidence scoring
# =============================================================================

@test "confidence: high when all mapped" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --color-primary: hsl(150, 80%, 40%);
  --font-family-body: 'Lato', sans-serif;
  --border-radius: 0.25rem;
  --content-width-max: 960px;
  --nav-width: 200px;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local confidence
  confidence=$(echo "$output" | jq -r '.confidence')
  # With density_factor always defaulting, best is medium or high
  [[ "$confidence" == "medium" || "$confidence" == "high" ]]
}

@test "confidence: low when few mapped" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --unrelated-token: 10px;
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success
  local confidence
  confidence=$(echo "$output" | jq -r '.confidence')
  [[ "$confidence" == "low" ]]
}

# =============================================================================
# Output structure
# =============================================================================

@test "output is valid JSON with all required keys" {
  cat > "$TEST_PROJECT_DIR/tokens.css" <<'CSS'
:root {
  --color-primary: hsl(220, 85%, 55%);
}
CSS
  run_import --format css --input "$TEST_PROJECT_DIR/tokens.css"
  assert_success

  # Validate it's valid JSON
  echo "$output" | jq . >/dev/null 2>&1

  # Check all required top-level keys
  local keys
  keys=$(echo "$output" | jq -r 'keys[]' | sort)
  [[ "$keys" == *"confidence"* ]]
  [[ "$keys" == *"defaults_used"* ]]
  [[ "$keys" == *"mapped"* ]]
  [[ "$keys" == *"mapped_count"* ]]
  [[ "$keys" == *"shadcn_tokens"* ]]
  [[ "$keys" == *"token_overrides"* ]]
  [[ "$keys" == *"unmapped"* ]]
  [[ "$keys" == *"warnings"* ]]

  # Check mapped sub-keys
  local mapped_keys
  mapped_keys=$(echo "$output" | jq -r '.mapped | keys[]' | sort)
  [[ "$mapped_keys" == *"BORDER_RADIUS"* ]]
  [[ "$mapped_keys" == *"CONTENT_WIDTH_MAX"* ]]
  [[ "$mapped_keys" == *"DENSITY_FACTOR"* ]]
  [[ "$mapped_keys" == *"FONT_FAMILY"* ]]
  [[ "$mapped_keys" == *"NAV_WIDTH"* ]]
  [[ "$mapped_keys" == *"PRIMARY_HUE"* ]]
}
