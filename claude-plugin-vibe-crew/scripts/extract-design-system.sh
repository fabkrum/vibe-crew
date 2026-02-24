#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# extract-design-system.sh — Extract design tokens from a reference URL
# =============================================================================
# Generates a Chrome DevTools MCP extraction payload and a template design-system.css.
#
# Workflow:
#   1. This script outputs structured JSON instructions to stdout.
#   2. Claude Code feeds the JSON to the Chrome DevTools MCP server, which drives
#      a real browser to navigate to the URL and extract computed styles.
#   3. Claude Code fills in the CSS custom properties template with the
#      extracted values, producing the final design-system.css.
#
# Usage:
#   ./scripts/extract-design-system.sh <reference-url> [output-path]
#
# Arguments:
#   $1  Reference URL (required) — the page to extract design tokens from
#   $2  Output path (optional)   — defaults to design-system.css
#
# Example:
#   ./scripts/extract-design-system.sh https://stripe.com design-system.css
# =============================================================================

# --- Colors for output -------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()  { printf "${BOLD}[VibeCrew]${NC} %s\n" "$1" >&2; }
warn()  { printf "${YELLOW}[VibeCrew]${NC} %s\n" "$1" >&2; }
error() { printf "${RED}[VibeCrew]${NC} %s\n" "$1" >&2; }
ok()    { printf "${GREEN}[VibeCrew]${NC} %s\n" "$1" >&2; }

# --- Step 1: Validate URL argument exists ------------------------------------
if [[ $# -lt 1 ]] || [[ -z "${1:-}" ]]; then
  error "Missing required argument: reference URL"
  echo "" >&2
  echo "Usage: $0 <reference-url> [output-path]" >&2
  echo "" >&2
  echo "Example:" >&2
  echo "  $0 https://stripe.com design-system.css" >&2
  exit 1
fi

REFERENCE_URL="$1"
OUTPUT_PATH="${2:-design-system.css}"

# --- Step 2: Validate URL format ---------------------------------------------
if [[ ! "$REFERENCE_URL" =~ ^https?:// ]]; then
  error "Invalid URL: $REFERENCE_URL"
  error "URL must start with http:// or https://"
  exit 1
fi

info "Reference URL: $REFERENCE_URL"
info "Output path:   $OUTPUT_PATH"
echo "" >&2

# --- Step 3: Output Chrome DevTools MCP extraction payload -------------------
# This JSON describes the browser actions Claude should perform via the
# Chrome DevTools MCP server. It is NOT executed by this script — Claude reads
# the JSON and translates it into Chrome DevTools MCP tool calls.

info "Generating Chrome DevTools MCP extraction instructions..."
echo "" >&2

cat <<PAYLOAD
{
  "description": "VibeCrew Design Token Extraction — Chrome DevTools MCP Instructions",
  "reference_url": "${REFERENCE_URL}",
  "output_path": "${OUTPUT_PATH}",
  "steps": [
    {
      "action": "navigate",
      "url": "${REFERENCE_URL}",
      "description": "Navigate to the reference URL and wait for full page load"
    },
    {
      "action": "extract_computed_styles",
      "description": "Extract computed styles from key semantic elements",
      "selectors": [
        {
          "name": "body",
          "selector": "body",
          "description": "Base page styles — background, text color, font family"
        },
        {
          "name": "h1",
          "selector": "h1",
          "description": "Primary heading styles"
        },
        {
          "name": "h2",
          "selector": "h2",
          "description": "Secondary heading styles"
        },
        {
          "name": "h3",
          "selector": "h3",
          "description": "Tertiary heading styles"
        },
        {
          "name": "h4",
          "selector": "h4",
          "description": "Quaternary heading styles"
        },
        {
          "name": "h5",
          "selector": "h5",
          "description": "Quinary heading styles"
        },
        {
          "name": "h6",
          "selector": "h6",
          "description": "Senary heading styles"
        },
        {
          "name": "button_primary",
          "selector": "button, [role='button'], input[type='submit']",
          "description": "Primary interactive button styles"
        },
        {
          "name": "link",
          "selector": "a",
          "description": "Anchor/link styles"
        },
        {
          "name": "input",
          "selector": "input[type='text'], input[type='email'], input[type='password'], textarea",
          "description": "Form input field styles"
        }
      ],
      "properties": [
        "background-color",
        "color",
        "font-family",
        "font-size",
        "font-weight",
        "line-height",
        "border-radius",
        "padding",
        "margin",
        "box-shadow"
      ]
    },
    {
      "action": "screenshot",
      "description": "Take a full-page screenshot for visual reference (optional)"
    }
  ],
  "extraction_script": "(() => { const selectors = { body: 'body', h1: 'h1', h2: 'h2', h3: 'h3', h4: 'h4', h5: 'h5', h6: 'h6', button: 'button, [role=button], input[type=submit]', link: 'a', input: 'input[type=text], input[type=email], textarea' }; const props = ['background-color','color','font-family','font-size','font-weight','line-height','border-radius','padding','margin','box-shadow']; const result = {}; for (const [name, sel] of Object.entries(selectors)) { const el = document.querySelector(sel); if (el) { const cs = getComputedStyle(el); result[name] = {}; for (const p of props) { result[name][p] = cs.getPropertyValue(p); } } } return JSON.stringify(result, null, 2); })()"
}
PAYLOAD

echo "" >&2

# --- Step 4: Output template design-system.css --------------------------------
# This template uses CSS custom properties with placeholder values.
# Claude fills in the actual values after running the Chrome DevTools extraction.

info "Writing template CSS to: $OUTPUT_PATH"
echo "" >&2

cat > "$OUTPUT_PATH" <<'CSS'
/* =============================================================================
 * design-system.css — Design Tokens
 * =============================================================================
 * Auto-generated by VibeCrew extract-design-system.sh
 * Source: {{REFERENCE_URL}}
 * Date:   {{EXTRACTION_DATE}}
 *
 * These CSS custom properties define the project's design system.
 * Values marked {{PLACEHOLDER}} should be filled with extracted tokens.
 * ========================================================================== */

:root {
  /* ---------------------------------------------------------------------------
   * Colors
   * ------------------------------------------------------------------------ */

  /* Background colors */
  --color-bg-primary:        {{body.background-color}};
  --color-bg-surface:        {{body.background-color}};

  /* Text colors */
  --color-text-primary:      {{body.color}};
  --color-text-heading:      {{h1.color}};
  --color-text-link:         {{link.color}};

  /* Interactive colors */
  --color-button-bg:         {{button.background-color}};
  --color-button-text:       {{button.color}};
  --color-input-bg:          {{input.background-color}};
  --color-input-text:        {{input.color}};

  /* ---------------------------------------------------------------------------
   * Typography
   * ------------------------------------------------------------------------ */

  /* Font families */
  --font-family-body:        {{body.font-family}};
  --font-family-heading:     {{h1.font-family}};

  /* Font sizes */
  --font-size-base:          {{body.font-size}};
  --font-size-h1:            {{h1.font-size}};
  --font-size-h2:            {{h2.font-size}};
  --font-size-h3:            {{h3.font-size}};
  --font-size-h4:            {{h4.font-size}};
  --font-size-h5:            {{h5.font-size}};
  --font-size-h6:            {{h6.font-size}};

  /* Font weights */
  --font-weight-body:        {{body.font-weight}};
  --font-weight-heading:     {{h1.font-weight}};
  --font-weight-bold:        {{button.font-weight}};

  /* Line heights */
  --line-height-body:        {{body.line-height}};
  --line-height-heading:     {{h1.line-height}};

  /* ---------------------------------------------------------------------------
   * Spacing
   * ------------------------------------------------------------------------ */

  /* Padding */
  --padding-button:          {{button.padding}};
  --padding-input:           {{input.padding}};

  /* Margin */
  --margin-heading:          {{h1.margin}};

  /* ---------------------------------------------------------------------------
   * Borders & Shadows
   * ------------------------------------------------------------------------ */

  --border-radius-button:    {{button.border-radius}};
  --border-radius-input:     {{input.border-radius}};
  --box-shadow-button:       {{button.box-shadow}};
  --box-shadow-input:        {{input.box-shadow}};
}

/* =============================================================================
 * Semantic Aliases
 * =============================================================================
 * Map raw tokens to semantic names for consistent usage across components.
 * ========================================================================== */

:root {
  /* Surface hierarchy */
  --surface-page:            var(--color-bg-primary);
  --surface-card:            var(--color-bg-surface);

  /* Text hierarchy */
  --text-default:            var(--color-text-primary);
  --text-heading:            var(--color-text-heading);
  --text-link:               var(--color-text-link);

  /* Interactive */
  --interactive-bg:          var(--color-button-bg);
  --interactive-text:        var(--color-button-text);
  --interactive-radius:      var(--border-radius-button);

  /* Form */
  --form-bg:                 var(--color-input-bg);
  --form-text:               var(--color-input-text);
  --form-radius:             var(--border-radius-input);
}
CSS

# Replace the placeholder URL and date in the generated file
if command -v sed &>/dev/null; then
  sed -i.bak "s|{{REFERENCE_URL}}|${REFERENCE_URL}|g" "$OUTPUT_PATH" 2>/dev/null && rm -f "${OUTPUT_PATH}.bak" || true
  sed -i.bak "s|{{EXTRACTION_DATE}}|$(date -u +%Y-%m-%dT%H:%M:%SZ)|g" "$OUTPUT_PATH" 2>/dev/null && rm -f "${OUTPUT_PATH}.bak" || true
fi

ok "Template written to: $OUTPUT_PATH"
ok "JSON extraction payload printed to stdout."
echo "" >&2
info "Next steps:"
info "  1. Claude reads the JSON payload above."
info "  2. Claude uses Chrome DevTools MCP to navigate to $REFERENCE_URL"
info "  3. Claude runs the extraction_script in the browser context."
info "  4. Claude replaces {{...}} placeholders in $OUTPUT_PATH with extracted values."
echo "" >&2
