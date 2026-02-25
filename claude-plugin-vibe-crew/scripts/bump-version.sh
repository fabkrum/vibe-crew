#!/usr/bin/env bash
# scripts/bump-version.sh
# Bumps the VibeCrew version across all 5 locations where it appears.
# Uses jq for JSON files, sed for text files, atomic writes for JSON.
# Usage: bump-version.sh <semver>  (e.g. bump-version.sh 1.6.0)
# Exit 0 on success, Exit 1 on validation failure.

set -euo pipefail

# --- Resolve plugin root ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$PLUGIN_ROOT/.." && pwd)"

# --- Validate arguments ---
if [[ $# -lt 1 ]]; then
  echo "Usage: bump-version.sh <semver>" >&2
  echo "Example: bump-version.sh 1.6.0" >&2
  exit 1
fi

NEW_VERSION="$1"

# Validate semver format (X.Y.Z)
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "Error: Invalid semver format '$NEW_VERSION'. Expected X.Y.Z (e.g. 1.6.0)" >&2
  exit 1
fi

echo "Bumping VibeCrew version to $NEW_VERSION..."

# --- 1. plugin.json (sed to preserve exact formatting) ---
PLUGIN_JSON="$PLUGIN_ROOT/.claude-plugin/plugin.json"
if [[ -f "$PLUGIN_JSON" ]]; then
  sed -i '' "s/\"version\": \"[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\"/\"version\": \"${NEW_VERSION}\"/" "$PLUGIN_JSON"
  echo "  Updated: .claude-plugin/plugin.json"
else
  echo "  Warning: $PLUGIN_JSON not found, skipping" >&2
fi

# --- 2. agents/session-startup.md (banner string) ---
STARTUP_MD="$PLUGIN_ROOT/agents/session-startup.md"
if [[ -f "$STARTUP_MD" ]]; then
  sed -i '' "s/VibeCrew v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/VibeCrew v${NEW_VERSION}/g" "$STARTUP_MD"
  echo "  Updated: agents/session-startup.md"
else
  echo "  Warning: $STARTUP_MD not found, skipping" >&2
fi

# --- 3. docs/index.html (hero badge + release card) ---
INDEX_HTML="$REPO_ROOT/docs/index.html"
if [[ -f "$INDEX_HTML" ]]; then
  # Hero badge: "Claude Code Plugin · v1.5.0"
  sed -i '' "s/Plugin &middot; v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/Plugin \&middot; v${NEW_VERSION}/" "$INDEX_HTML"
  # Release card: "v1.0.0 through v1.5.0"
  sed -i '' "s/through v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/through v${NEW_VERSION}/" "$INDEX_HTML"
  echo "  Updated: docs/index.html"
else
  echo "  Warning: $INDEX_HTML not found, skipping" >&2
fi

# --- 4. CLAUDE.md (root — Current Status line) ---
ROOT_CLAUDE_MD="$REPO_ROOT/CLAUDE.md"
if [[ -f "$ROOT_CLAUDE_MD" ]]; then
  sed -i '' "s/VibeCrew v[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}/VibeCrew v${NEW_VERSION}/g" "$ROOT_CLAUDE_MD"
  echo "  Updated: CLAUDE.md"
else
  echo "  Warning: $ROOT_CLAUDE_MD not found, skipping" >&2
fi

# --- 5. CHANGELOG.md (rename [Unreleased] heading if present, add link ref) ---
CHANGELOG="$PLUGIN_ROOT/CHANGELOG.md"
if [[ -f "$CHANGELOG" ]]; then
  TODAY=$(date +%Y-%m-%d)
  # Replace ## [Unreleased] with ## [X.Y.Z] - YYYY-MM-DD
  if grep -q '## \[Unreleased\]' "$CHANGELOG"; then
    sed -i '' "s/## \[Unreleased\]/## [${NEW_VERSION}] - ${TODAY}/" "$CHANGELOG"
    echo "  Updated: CHANGELOG.md ([Unreleased] -> [${NEW_VERSION}] - ${TODAY})"
  else
    echo "  Skipped: CHANGELOG.md (no [Unreleased] heading found)"
  fi
  # Add link reference at bottom if not already present
  if ! grep -q "^\[${NEW_VERSION}\]:" "$CHANGELOG"; then
    echo "[${NEW_VERSION}]: https://github.com/fabkrum/vibe-crew/releases/tag/v${NEW_VERSION}" >> "$CHANGELOG"
    echo "  Added: CHANGELOG.md link reference for ${NEW_VERSION}"
  fi
else
  echo "  Warning: $CHANGELOG not found, skipping" >&2
fi

echo ""
echo "Version bump complete: v${NEW_VERSION}"
exit 0
