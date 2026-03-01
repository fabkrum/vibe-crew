#!/usr/bin/env bash
# scripts/visual-verify.sh
# Parses design-system.css tokens and generates a Playwright browser_evaluate
# payload for computed style extraction. The agent uses the output to compare
# rendered styles against design tokens programmatically.
#
# Usage: visual-verify.sh [design-system-css-path] [url] [project_root]
# Output: JSON with "tokens" (parsed token map) and "evaluate_script" (JS string)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/error-log.sh"

PROJECT_ROOT="${3:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CSS_PATH="${1:-$PROJECT_ROOT/design-system.css}"
URL="${2:-http://localhost:3000}"

# --- Graceful degradation: exit 0 with error JSON if CSS not found ---
if [[ ! -f "$CSS_PATH" ]]; then
  jq -n \
    --arg error "design-system.css not found at $CSS_PATH" \
    '{ error: $error, tokens: {}, evaluate_script: "" }'
  exit 0
fi

# --- Parse CSS custom properties from :root ---
# Extracts lines like: --color-primary-500: hsl(220, 70%, 50%);
# Produces a JSON object: { "--color-primary-500": "hsl(220, 70%, 50%)", ... }
TOKENS=$(awk '
  /^[[:space:]]*--[a-zA-Z0-9_-]+[[:space:]]*:/ {
    # Strip leading whitespace
    gsub(/^[[:space:]]+/, "")
    # Split on first colon
    split($0, parts, /:[[:space:]]*/)
    prop = parts[1]
    val = parts[2]
    # Strip trailing semicolon and whitespace
    gsub(/[[:space:]]*;[[:space:]]*$/, "", val)
    # Strip inline comments
    gsub(/[[:space:]]*\/\*.*\*\/[[:space:]]*$/, "", val)
    # Skip var() references — we only want raw values
    if (val !~ /^var\(/) {
      printf "%s\t%s\n", prop, val
    }
  }
' "$CSS_PATH" | jq -Rn '
  [inputs | split("\t") | {key: .[0], value: .[1]}]
  | from_entries
')

# --- Map token categories to CSS properties and selectors ---
# The evaluate_script extracts computed styles from rendered elements and
# returns structured JSON the agent can diff against the token map above.
read -r -d '' EVALUATE_SCRIPT << 'EVALJS' || true
(() => {
  const elements = {
    body: 'body',
    h1: 'h1',
    h2: 'h2',
    h3: 'h3',
    h4: 'h4',
    h5: 'h5',
    h6: 'h6',
    button: 'button, [role="button"], input[type="submit"]',
    link: 'a',
    input: 'input[type="text"], input[type="email"], input[type="password"], textarea, select'
  };
  const props = [
    'background-color', 'color', 'font-family', 'font-size',
    'font-weight', 'line-height', 'border-radius', 'padding',
    'margin', 'box-shadow', 'letter-spacing', 'gap'
  ];
  const result = {};
  for (const [name, sel] of Object.entries(elements)) {
    const el = document.querySelector(sel);
    if (el) {
      const cs = getComputedStyle(el);
      result[name] = {};
      for (const p of props) {
        result[name][p] = cs.getPropertyValue(p);
      }
    }
  }
  return JSON.stringify(result, null, 2);
})()
EVALJS

# --- Output combined JSON ---
jq -n \
  --argjson tokens "$TOKENS" \
  --arg evaluate_script "$EVALUATE_SCRIPT" \
  --arg url "$URL" \
  --arg css_path "$CSS_PATH" \
  '{
    css_path: $css_path,
    url: $url,
    tokens: $tokens,
    evaluate_script: $evaluate_script,
    instructions: "Run browser_navigate to the url, then browser_evaluate with the evaluate_script. Compare the returned computed styles against the tokens map to detect design system violations."
  }'
