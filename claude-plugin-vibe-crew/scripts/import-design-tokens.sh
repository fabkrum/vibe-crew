#!/usr/bin/env bash
# scripts/import-design-tokens.sh
# Import design tokens from CSS, Tailwind config, or JSON token files.
# Maps external token naming conventions to VibeCrew's canonical token names
# used in design-system.css.template placeholders.
#
# Usage:
#   import-design-tokens.sh --format <css|tailwind|json> --input <file-path> [--shadcn]
#
# Output: JSON to stdout with mapped tokens, overrides, defaults, unmapped, confidence.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/error-log.sh"

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

# --- Argument parsing ---------------------------------------------------------
FORMAT=""
INPUT_FILE=""
SHADCN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)  FORMAT="$2"; shift 2 ;;
    --input)   INPUT_FILE="$2"; shift 2 ;;
    --shadcn)  SHADCN=true; shift ;;
    -h|--help)
      echo "Usage: import-design-tokens.sh --format <css|tailwind|json> --input <file-path> [--shadcn]" >&2
      exit 0 ;;
    *) error "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "$FORMAT" ]]; then
  error "Missing required argument: --format <css|tailwind|json>"
  exit 1
fi

if [[ -z "$INPUT_FILE" ]]; then
  error "Missing required argument: --input <file-path>"
  exit 1
fi

if [[ ! "$FORMAT" =~ ^(css|tailwind|json)$ ]]; then
  error "Invalid format: $FORMAT (must be css, tailwind, or json)"
  exit 1
fi

if [[ ! -f "$INPUT_FILE" ]]; then
  error "File not found: $INPUT_FILE"
  exit 1
fi

# --- Color conversion utilities -----------------------------------------------

# Convert hex color to HSL hue (0-360)
hex_to_hue() {
  local hex="$1"
  hex="${hex#\#}"
  # Expand 3-char hex to 6-char
  if [[ ${#hex} -eq 3 ]]; then
    hex="${hex:0:1}${hex:0:1}${hex:1:1}${hex:1:1}${hex:2:1}${hex:2:1}"
  fi
  # Use printf for hex-to-decimal (portable, no strtonum needed)
  local r_dec g_dec b_dec
  r_dec=$(printf '%d' "0x${hex:0:2}" 2>/dev/null || echo 0)
  g_dec=$(printf '%d' "0x${hex:2:2}" 2>/dev/null || echo 0)
  b_dec=$(printf '%d' "0x${hex:4:2}" 2>/dev/null || echo 0)
  awk -v r="$r_dec" -v g="$g_dec" -v b="$b_dec" 'BEGIN {
    r = r / 255; g = g / 255; b = b / 255
    max = r; if (g > max) max = g; if (b > max) max = b
    min = r; if (g < min) min = g; if (b < min) min = b
    delta = max - min
    if (delta == 0) { h = 0 }
    else if (max == r) { h = 60 * (((g - b) / delta) % 6) }
    else if (max == g) { h = 60 * (((b - r) / delta) + 2) }
    else               { h = 60 * (((r - g) / delta) + 4) }
    if (h < 0) h += 360
    printf "%d\n", h + 0.5
  }'
}

# Convert rgb(r, g, b) to HSL hue
rgb_to_hue() {
  local rgb_str="$1"
  # Extract numbers from rgb(r, g, b) or rgb(r g b)
  local nums
  nums=$(echo "$rgb_str" | grep -oE '[0-9]+' | head -3)
  local r g b
  r=$(echo "$nums" | sed -n '1p')
  g=$(echo "$nums" | sed -n '2p')
  b=$(echo "$nums" | sed -n '3p')
  [[ -z "$r" || -z "$g" || -z "$b" ]] && echo "0" && return
  awk -v r="$r" -v g="$g" -v b="$b" 'BEGIN {
    r = r / 255; g = g / 255; b = b / 255
    max = r; if (g > max) max = g; if (b > max) max = b
    min = r; if (g < min) min = g; if (b < min) min = b
    delta = max - min
    if (delta == 0) { h = 0 }
    else if (max == r) { h = 60 * (((g - b) / delta) % 6) }
    else if (max == g) { h = 60 * (((b - r) / delta) + 2) }
    else               { h = 60 * (((r - g) / delta) + 4) }
    if (h < 0) h += 360
    printf "%d\n", h + 0.5
  }'
}

# Extract hue from HSL string: hsl(h, s%, l%) or hsl(h s% l%)
hsl_to_hue() {
  local hsl_str="$1"
  echo "$hsl_str" | grep -oE '[0-9]+(\.[0-9]+)?' | head -1
}

# Convert any color format to HSL hue
color_to_hue() {
  local color="$1"
  color="$(echo "$color" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  case "$color" in
    \#*)      hex_to_hue "$color" ;;
    rgb\(*)   rgb_to_hue "$color" ;;
    hsl\(*)   hsl_to_hue "$color" ;;
    oklch\(*) # Approximate: extract the hue component (3rd number)
              echo "$color" | grep -oE '[0-9]+(\.[0-9]+)?' | sed -n '3p' | awk '{printf "%d\n", $1 + 0.5}' ;;
    *)        echo "" ;;
  esac
}

# --- CSS extraction -----------------------------------------------------------

extract_css_tokens() {
  local file="$1"
  # Reuse the AWK pattern from visual-verify.sh to extract --property: value pairs
  awk '
    /^[[:space:]]*--[a-zA-Z0-9_-]+[[:space:]]*:/ {
      gsub(/^[[:space:]]+/, "")
      split($0, parts, /:[[:space:]]*/)
      prop = parts[1]
      val = parts[2]
      gsub(/[[:space:]]*;[[:space:]]*$/, "", val)
      gsub(/[[:space:]]*\/\*.*\*\/[[:space:]]*$/, "", val)
      if (val !~ /^var\(/) {
        printf "%s\t%s\n", prop, val
      }
    }
  ' "$file"
}

# --- Tailwind extraction ------------------------------------------------------

extract_tailwind_tokens() {
  local file="$1"
  # Use node to evaluate the config and extract theme values as JSON
  if ! command -v node &>/dev/null; then
    warn "Node.js not available — cannot parse Tailwind config"
    echo ""
    return
  fi

  # Try to evaluate config with node
  local result
  result=$(node -e "
    try {
      const path = require('path');
      const configPath = path.resolve('$file');
      // Handle both module.exports and export default
      let config;
      try {
        config = require(configPath);
      } catch(e) {
        // Might be ESM or TS — try reading and evaluating
        const fs = require('fs');
        const content = fs.readFileSync(configPath, 'utf-8');
        const cleaned = content
          .replace(/export\s+default\s+/, 'module.exports = ')
          .replace(/import\s+.*from\s+['\"].*['\"]/g, '')
          .replace(/satisfies\s+\w+/g, '');
        const tmpPath = configPath + '.cjs.tmp';
        fs.writeFileSync(tmpPath, cleaned);
        try {
          config = require(tmpPath);
        } finally {
          fs.unlinkSync(tmpPath);
        }
      }
      const theme = config.theme || {};
      const extend = theme.extend || {};
      const merged = { ...theme, ...extend };
      const result = {};
      if (merged.colors) result.colors = merged.colors;
      if (merged.fontFamily) result.fontFamily = merged.fontFamily;
      if (merged.borderRadius) result.borderRadius = merged.borderRadius;
      if (merged.spacing) result.spacing = merged.spacing;
      if (merged.maxWidth) result.maxWidth = merged.maxWidth;
      console.log(JSON.stringify(result));
    } catch(e) {
      console.error('Tailwind parse error: ' + e.message);
      console.log('{}');
    }
  " 2>/dev/null || echo "{}")

  echo "$result"
}

# --- JSON extraction ----------------------------------------------------------

extract_json_tokens() {
  local file="$1"
  # Detect W3C DTCG format ($value/$type keys) vs flat key-value
  local is_dtcg
  is_dtcg=$(jq 'any(.. | objects; has("$value"))' "$file" 2>/dev/null || echo "false")

  if [[ "$is_dtcg" == "true" ]]; then
    # W3C DTCG format: walk the tree and extract $value by $type
    jq '
      [
        paths(objects | has("$value")) as $p |
        { key: ($p | join(".")), value: (getpath($p) | ."$value"), type: (getpath($p) | ."$type" // "unknown") }
      ]
    ' "$file"
  else
    # Flat key-value: treat as direct token map
    jq '
      [
        to_entries[] |
        if (.value | type) == "object" then
          .key as $prefix |
          .value | to_entries[] |
          { key: ($prefix + "." + .key), value: (.value | tostring), type: "unknown" }
        else
          { key: .key, value: (.value | tostring), type: "unknown" }
        end
      ]
    ' "$file"
  fi
}

# --- Token mapping table ------------------------------------------------------
# Maps common source patterns to VibeCrew template placeholders.
# VibeCrew placeholders: PRIMARY_HUE, FONT_FAMILY, BORDER_RADIUS,
#                         DENSITY_FACTOR, CONTENT_WIDTH_MAX, NAV_WIDTH

map_tokens_to_vibecrew() {
  local source_tokens="$1"
  local format="$2"

  local primary_hue=""
  local font_family=""
  local border_radius=""
  local density_factor=""
  local content_width_max=""
  local nav_width=""
  local mapped_count=0
  local unmapped_tokens="[]"
  local token_overrides="{}"
  local shadcn_tokens="{}"

  if [[ "$format" == "css" ]]; then
    # Process CSS tokens line by line (tab-separated prop\tvalue)
    while IFS=$'\t' read -r prop val; do
      [[ -z "$prop" ]] && continue
      local matched=false

      # Primary color mapping
      case "$prop" in
        --color-primary|--primary|--brand-primary|--color-brand|--accent-color|--theme-primary)
          local hue
          hue=$(color_to_hue "$val")
          if [[ -n "$hue" && "$hue" != "0" || "$val" == *"0,"* ]]; then
            primary_hue="$hue"
            matched=true
          fi
          ;;
      esac

      # Font family mapping
      case "$prop" in
        --font-family-body|--font-body|--ff-sans|--font-family-sans|--font-sans|--font-family|--font-family-base)
          # Extract first font name
          font_family="$(echo "$val" | sed "s/['\"]//g" | cut -d',' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
          matched=true
          ;;
      esac

      # Border radius mapping
      case "$prop" in
        --border-radius|--radius|--rounded|--radius-md|--border-radius-md|--radius-default)
          border_radius="$val"
          matched=true
          ;;
      esac

      # Content width mapping
      case "$prop" in
        --content-width|--content-width-max|--max-width|--container-max-width|--max-content-width)
          content_width_max="$val"
          matched=true
          ;;
      esac

      # Nav width mapping
      case "$prop" in
        --nav-width|--sidebar-width|--navigation-width)
          nav_width="$val"
          matched=true
          ;;
      esac

      # Background color (for shadcn token override)
      case "$prop" in
        --color-bg-primary|--background|--bg|--color-background|--bg-color)
          token_overrides=$(echo "$token_overrides" | jq --arg v "$val" '. + {"--color-background": $v}')
          matched=true
          ;;
      esac

      # Foreground/text color
      case "$prop" in
        --color-text-primary|--foreground|--text-color|--color-foreground|--color-text)
          token_overrides=$(echo "$token_overrides" | jq --arg v "$val" '. + {"--color-foreground": $v}')
          matched=true
          ;;
      esac

      if [[ "$matched" == "true" ]]; then
        mapped_count=$((mapped_count + 1))
      else
        unmapped_tokens=$(echo "$unmapped_tokens" | jq --arg p "$prop" --arg v "$val" '. + [{"property": $p, "value": $v}]')
      fi
    done <<< "$source_tokens"

  elif [[ "$format" == "tailwind" ]]; then
    local tw_json="$source_tokens"
    [[ -z "$tw_json" || "$tw_json" == "{}" ]] && tw_json="{}"

    # Extract primary color
    local tw_primary
    tw_primary=$(echo "$tw_json" | jq -r '.colors.primary // .colors.brand // empty' 2>/dev/null || echo "")
    if [[ -n "$tw_primary" && "$tw_primary" != "null" ]]; then
      # Could be a string or an object with shades
      if echo "$tw_primary" | jq -e 'type == "object"' &>/dev/null; then
        tw_primary=$(echo "$tw_primary" | jq -r '.DEFAULT // .["500"] // (to_entries | first | .value)' 2>/dev/null || echo "")
      fi
      if [[ -n "$tw_primary" && "$tw_primary" != "null" ]]; then
        primary_hue=$(color_to_hue "$tw_primary")
        [[ -n "$primary_hue" ]] && mapped_count=$((mapped_count + 1))
      fi
    fi

    # Extract font family
    local tw_font
    tw_font=$(echo "$tw_json" | jq -r '.fontFamily.sans // .fontFamily.body // empty' 2>/dev/null || echo "")
    if [[ -n "$tw_font" && "$tw_font" != "null" ]]; then
      if echo "$tw_font" | jq -e 'type == "array"' &>/dev/null; then
        tw_font=$(echo "$tw_font" | jq -r '.[0]' 2>/dev/null || echo "")
      fi
      font_family="$(echo "$tw_font" | sed "s/['\"]//g")"
      [[ -n "$font_family" ]] && mapped_count=$((mapped_count + 1))
    fi

    # Extract border radius
    local tw_radius
    tw_radius=$(echo "$tw_json" | jq -r '.borderRadius.DEFAULT // .borderRadius.md // empty' 2>/dev/null || echo "")
    if [[ -n "$tw_radius" && "$tw_radius" != "null" ]]; then
      border_radius="$tw_radius"
      mapped_count=$((mapped_count + 1))
    fi

    # Extract spacing / max width
    local tw_maxw
    tw_maxw=$(echo "$tw_json" | jq -r '.maxWidth.content // .maxWidth.screen // empty' 2>/dev/null || echo "")
    if [[ -n "$tw_maxw" && "$tw_maxw" != "null" ]]; then
      content_width_max="$tw_maxw"
      mapped_count=$((mapped_count + 1))
    fi

  elif [[ "$format" == "json" ]]; then
    local json_tokens="$source_tokens"
    [[ -z "$json_tokens" || "$json_tokens" == "[]" ]] && json_tokens="[]"

    # Walk extracted tokens and map by key patterns
    local token_count
    token_count=$(echo "$json_tokens" | jq 'length')
    for i in $(seq 0 $((token_count - 1))); do
      local key val type
      key=$(echo "$json_tokens" | jq -r ".[$i].key")
      val=$(echo "$json_tokens" | jq -r ".[$i].value")
      type=$(echo "$json_tokens" | jq -r ".[$i].type // \"unknown\"")

      local matched=false
      local key_lower
      key_lower=$(echo "$key" | tr '[:upper:]' '[:lower:]')

      # Match by type or key pattern
      if [[ "$type" == "color" || "$key_lower" == *"primary"* || "$key_lower" == *"brand"* ]] && [[ -z "$primary_hue" ]]; then
        local hue
        hue=$(color_to_hue "$val")
        if [[ -n "$hue" ]]; then
          primary_hue="$hue"
          matched=true
        fi
      fi

      if [[ "$type" == "fontFamily" || "$key_lower" == *"font"*"family"* || "$key_lower" == *"font"*"sans"* || "$key_lower" == *"font"*"body"* ]] && [[ -z "$font_family" ]]; then
        font_family="$(echo "$val" | sed "s/['\"]//g" | cut -d',' -f1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        matched=true
      fi

      if [[ "$type" == "borderRadius" || "$key_lower" == *"radius"* || "$key_lower" == *"rounded"* ]] && [[ -z "$border_radius" ]]; then
        border_radius="$val"
        matched=true
      fi

      if [[ "$matched" == "true" ]]; then
        mapped_count=$((mapped_count + 1))
      else
        unmapped_tokens=$(echo "$unmapped_tokens" | jq --arg k "$key" --arg v "$val" '. + [{"property": $k, "value": $v}]')
      fi
    done
  fi

  # --- Gap analysis: apply defaults for unresolved placeholders ---------------
  local defaults_used=0

  if [[ -z "$primary_hue" ]]; then
    primary_hue="220"  # Default: blue
    defaults_used=$((defaults_used + 1))
  fi
  if [[ -z "$font_family" ]]; then
    font_family="Inter"
    defaults_used=$((defaults_used + 1))
  fi
  if [[ -z "$border_radius" ]]; then
    border_radius="0.5rem"
    defaults_used=$((defaults_used + 1))
  fi
  if [[ -z "$density_factor" ]]; then
    density_factor="1.0"
    defaults_used=$((defaults_used + 1))
  fi
  if [[ -z "$content_width_max" ]]; then
    content_width_max="1280px"
    defaults_used=$((defaults_used + 1))
  fi
  if [[ -z "$nav_width" ]]; then
    nav_width="240px"
    defaults_used=$((defaults_used + 1))
  fi

  # --- Confidence scoring -----------------------------------------------------
  local total_placeholders=6
  local resolved=$((total_placeholders - defaults_used))
  local confidence="low"
  if [[ $resolved -ge 6 ]]; then
    confidence="high"
  elif [[ $resolved -ge 4 ]]; then
    confidence="medium"
  fi

  # --- shadcn token extraction ------------------------------------------------
  if [[ "$SHADCN" == "true" && "$format" == "css" ]]; then
    # Extract shadcn-specific tokens from CSS
    local shadcn_pairs
    shadcn_pairs=$(echo "$source_tokens" | grep -E '^\-\-(background|foreground|card|popover|primary|secondary|muted|accent|destructive|border|input|ring|chart-|sidebar-)' || true)
    if [[ -n "$shadcn_pairs" ]]; then
      shadcn_tokens=$(echo "$shadcn_pairs" | while IFS=$'\t' read -r p v; do
        printf '"%s":"%s",' "$p" "$v"
      done | sed 's/,$//' | awk '{print "{"$0"}"}')
      [[ -z "$shadcn_tokens" || "$shadcn_tokens" == "{}" ]] && shadcn_tokens="{}"
    fi
  fi

  # --- Build output JSON ------------------------------------------------------
  local warnings="[]"
  if [[ $defaults_used -gt 3 ]]; then
    warnings=$(echo "$warnings" | jq '. + ["Many tokens could not be mapped — review defaults carefully"]')
  fi

  jq -n \
    --arg primary_hue "$primary_hue" \
    --arg font_family "$font_family" \
    --arg border_radius "$border_radius" \
    --arg density_factor "$density_factor" \
    --arg content_width_max "$content_width_max" \
    --arg nav_width "$nav_width" \
    --argjson mapped_count "$mapped_count" \
    --argjson defaults_used "$defaults_used" \
    --arg confidence "$confidence" \
    --argjson unmapped "$unmapped_tokens" \
    --argjson token_overrides "$token_overrides" \
    --argjson shadcn_tokens "$shadcn_tokens" \
    --argjson warnings "$warnings" \
    --arg format "$FORMAT" \
    --arg source "$INPUT_FILE" \
    '{
      mapped: {
        PRIMARY_HUE: $primary_hue,
        FONT_FAMILY: $font_family,
        BORDER_RADIUS: $border_radius,
        DENSITY_FACTOR: $density_factor,
        CONTENT_WIDTH_MAX: $content_width_max,
        NAV_WIDTH: $nav_width
      },
      token_overrides: $token_overrides,
      defaults_used: $defaults_used,
      mapped_count: $mapped_count,
      unmapped: $unmapped,
      shadcn_tokens: $shadcn_tokens,
      confidence: $confidence,
      warnings: $warnings,
      source: { format: $format, file: $source }
    }'
}

# --- Main execution -----------------------------------------------------------

info "Importing design tokens from $INPUT_FILE (format: $FORMAT)"

case "$FORMAT" in
  css)
    SOURCE_TOKENS=$(extract_css_tokens "$INPUT_FILE")
    map_tokens_to_vibecrew "$SOURCE_TOKENS" "css"
    ;;
  tailwind)
    SOURCE_TOKENS=$(extract_tailwind_tokens "$INPUT_FILE")
    map_tokens_to_vibecrew "$SOURCE_TOKENS" "tailwind"
    ;;
  json)
    SOURCE_TOKENS=$(extract_json_tokens "$INPUT_FILE")
    map_tokens_to_vibecrew "$SOURCE_TOKENS" "json"
    ;;
esac

ok "Token import complete"
