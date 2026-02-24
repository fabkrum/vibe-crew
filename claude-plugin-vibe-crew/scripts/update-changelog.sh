#!/usr/bin/env bash
# scripts/update-changelog.sh
# Parses conventional commits since last tag, appends to CHANGELOG.md.
# Groups by type: Added (feat), Fixed (fix), Changed (refactor/perf),
# Documentation (docs), Testing (test), Maintenance (chore/ci/build).
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CHANGELOG="$PROJECT_ROOT/CHANGELOG.md"

if ! command -v git &>/dev/null; then
  echo "Git not available. Skipping changelog update."
  exit 0
fi

cd "$PROJECT_ROOT"

# --- Find last tag ---
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [[ -n "$LAST_TAG" ]]; then
  RANGE="${LAST_TAG}..HEAD"
else
  RANGE="HEAD"
fi

# --- Collect commits ---
COMMITS=$(git log "$RANGE" --format='%s' 2>/dev/null || echo "")
if [[ -z "$COMMITS" ]]; then
  echo "No new commits since ${LAST_TAG:-beginning}. Skipping."
  exit 0
fi

# --- Parse conventional commits ---
FEATS=""
FIXES=""
CHANGES=""
DOCS=""
TESTS=""
MAINTENANCE=""

while IFS= read -r msg; do
  [[ -z "$msg" ]] && continue

  # Extract type and scope
  if echo "$msg" | grep -qE '^feat(\(.*\))?:'; then
    FEATS="${FEATS}\n- ${msg}"
  elif echo "$msg" | grep -qE '^fix(\(.*\))?:'; then
    FIXES="${FIXES}\n- ${msg}"
  elif echo "$msg" | grep -qE '^(refactor|perf)(\(.*\))?:'; then
    CHANGES="${CHANGES}\n- ${msg}"
  elif echo "$msg" | grep -qE '^docs(\(.*\))?:'; then
    DOCS="${DOCS}\n- ${msg}"
  elif echo "$msg" | grep -qE '^test(\(.*\))?:'; then
    TESTS="${TESTS}\n- ${msg}"
  elif echo "$msg" | grep -qE '^(chore|ci|build)(\(.*\))?:'; then
    MAINTENANCE="${MAINTENANCE}\n- ${msg}"
  fi
done <<< "$COMMITS"

# --- Check if anything to add ---
if [[ -z "$FEATS" && -z "$FIXES" && -z "$CHANGES" && -z "$DOCS" && -z "$TESTS" && -z "$MAINTENANCE" ]]; then
  echo "No conventional commits found. Skipping."
  exit 0
fi

# --- Build new entry ---
TODAY=$(date -u +%Y-%m-%d)
ENTRY="## [Unreleased] - $TODAY\n"

if [[ -n "$FEATS" ]]; then
  ENTRY="${ENTRY}\n### Added\n${FEATS}\n"
fi
if [[ -n "$FIXES" ]]; then
  ENTRY="${ENTRY}\n### Fixed\n${FIXES}\n"
fi
if [[ -n "$CHANGES" ]]; then
  ENTRY="${ENTRY}\n### Changed\n${CHANGES}\n"
fi
if [[ -n "$DOCS" ]]; then
  ENTRY="${ENTRY}\n### Documentation\n${DOCS}\n"
fi
if [[ -n "$TESTS" ]]; then
  ENTRY="${ENTRY}\n### Testing\n${TESTS}\n"
fi
if [[ -n "$MAINTENANCE" ]]; then
  ENTRY="${ENTRY}\n### Maintenance\n${MAINTENANCE}\n"
fi

# --- Insert after header ---
if [[ -f "$CHANGELOG" ]]; then
  # Find the first ## line (existing version entry) and insert before it
  FIRST_VERSION_LINE=$(grep -n '^## \[' "$CHANGELOG" | head -1 | cut -d: -f1)

  if [[ -n "$FIRST_VERSION_LINE" ]]; then
    {
      head -n "$((FIRST_VERSION_LINE - 1))" "$CHANGELOG"
      echo -e "$ENTRY"
      echo "---"
      echo ""
      tail -n "+$FIRST_VERSION_LINE" "$CHANGELOG"
    } > "$CHANGELOG.tmp" && mv "$CHANGELOG.tmp" "$CHANGELOG"
  else
    # No existing version entries, append to end
    echo "" >> "$CHANGELOG"
    echo -e "$ENTRY" >> "$CHANGELOG"
  fi
else
  # Create new CHANGELOG
  {
    echo "# Changelog"
    echo ""
    echo "All notable changes to this project will be documented in this file."
    echo ""
    echo -e "$ENTRY"
  } > "$CHANGELOG"
fi

echo "CHANGELOG.md updated with entries since ${LAST_TAG:-beginning}"
exit 0
