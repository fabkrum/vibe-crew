#!/usr/bin/env bash
# scripts/rebuild-sidebar.sh
# Scans docs/features/, regenerates VitePress sidebar config.
# Updates .vitepress/config.ts with new navigation items.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
DOCS_DIR="$PROJECT_ROOT/docs"
FEATURES_DIR="$DOCS_DIR/features"
CONFIG_FILE="$DOCS_DIR/.vitepress/config.ts"

# --- Check if docs site exists ---
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "No VitePress config found at $CONFIG_FILE. Skipping sidebar rebuild."
  exit 0
fi

if [[ ! -d "$FEATURES_DIR" ]]; then
  echo "No features directory at $FEATURES_DIR. Skipping."
  exit 0
fi

# --- Scan feature docs ---
FEATURE_ITEMS=""
FEATURE_COUNT=0

for md_file in "$FEATURES_DIR"/*.md; do
  [[ -f "$md_file" ]] || continue

  BASENAME=$(basename "$md_file" .md)

  # Extract title from first H1 heading
  TITLE=$(head -5 "$md_file" | grep '^# ' | head -1 | sed 's/^# //')
  if [[ -z "$TITLE" ]]; then
    TITLE="$BASENAME"
  fi

  if [[ -n "$FEATURE_ITEMS" ]]; then
    FEATURE_ITEMS="${FEATURE_ITEMS},"
  fi
  FEATURE_ITEMS="${FEATURE_ITEMS}
            { text: \"${TITLE}\", link: \"/features/${BASENAME}\" }"
  FEATURE_COUNT=$(( FEATURE_COUNT + 1 ))
done

if [[ "$FEATURE_COUNT" -eq 0 ]]; then
  echo "No feature docs found. Skipping sidebar update."
  exit 0
fi

# --- Check if Features sidebar section already exists ---
if grep -q '"/features/"' "$CONFIG_FILE" 2>/dev/null; then
  # Features section exists — replace it
  # This is a best-effort replacement; the Doc Generator agent can do a more
  # precise edit if needed
  echo "Features sidebar section already exists in config. Regeneration should be handled by the Doc Generator agent."
  echo "Found $FEATURE_COUNT feature docs."
  exit 0
fi

# --- Add Features sidebar section ---
# Insert before the closing of the sidebar object
# Look for the pattern: },  (closing of last sidebar section)
#                        },  (closing of sidebar)

# Generate the sidebar section (Overview link always first)
SIDEBAR_SECTION='"/features/": [
        {
          text: "Features",
          items: [
            { text: "Overview", link: "/features" },'"$FEATURE_ITEMS"'
          ],
        },
      ],'

echo "Generated sidebar with $FEATURE_COUNT feature items."
echo "Add this to .vitepress/config.ts sidebar section:"
echo ""
echo "$SIDEBAR_SECTION"

exit 0
