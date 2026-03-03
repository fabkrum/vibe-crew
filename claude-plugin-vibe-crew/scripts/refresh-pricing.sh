#!/usr/bin/env bash
# scripts/refresh-pricing.sh
# Updates the pricing section in config.json with current values.
# Usage: refresh-pricing.sh
# Shows before/after comparison.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/lock.sh"

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: config.json not found at $CONFIG_FILE"
  exit 1
fi

# Current pricing (as of March 2026)
NEW_PRICING='{
  "opus": {
    "input": 15.00,
    "cache_create": 18.75,
    "cache_read": 1.50,
    "output": 75.00
  },
  "sonnet": {
    "input": 3.00,
    "cache_create": 3.75,
    "cache_read": 0.30,
    "output": 15.00
  },
  "haiku": {
    "input": 0.25,
    "cache_create": 0.30,
    "cache_read": 0.03,
    "output": 1.25
  },
  "last_updated": "2026-03-01"
}'

# Show current pricing
echo "Current pricing:"
jq '.pricing // "not configured"' "$CONFIG_FILE" 2>/dev/null

echo ""
echo "New pricing:"
echo "$NEW_PRICING" | jq .

# Update config under lock
acquire_named_lock "config" "refresh-pricing"
jq --argjson pricing "$NEW_PRICING" '.pricing = $pricing' "$CONFIG_FILE" > "$CONFIG_FILE.tmp.$$" && mv "$CONFIG_FILE.tmp.$$" "$CONFIG_FILE"
release_named_lock "config"

echo ""
echo "Pricing updated in config.json"
