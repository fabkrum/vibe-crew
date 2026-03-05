#!/usr/bin/env bash
# scripts/expertise-sync-learnings.sh
# Regenerate CLAUDE.md "Session Learnings" section from top 15 foundational records.
# Source of truth is now the expertise JSONL files.
# Usage: expertise-sync-learnings.sh [project_root]
# Exit 0 on success

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"

if [[ ! -f "$CLAUDE_MD" ]]; then
  echo "No CLAUDE.md found. Skipping sync."
  exit 0
fi

if [[ ! -d "$EXPERTISE_DIR" ]]; then
  echo "No expertise directory found. Skipping sync."
  exit 0
fi

# --- Collect top 15 foundational records across all domains ---
ALL_FOUNDATIONAL=""
for f in "$EXPERTISE_DIR"/*.jsonl; do
  [[ -f "$f" ]] || continue
  RECORDS=$(cat "$f" 2>/dev/null | jq -c 'select(.deprecated != true and .tier == "foundational")' 2>/dev/null || true)
  if [[ -n "$RECORDS" ]]; then
    ALL_FOUNDATIONAL=$(printf '%s\n%s' "$ALL_FOUNDATIONAL" "$RECORDS")
  fi
done

if [[ -z "$ALL_FOUNDATIONAL" ]]; then
  echo "No foundational records found. Skipping sync."
  exit 0
fi

# Sort by confidence desc, access_count desc, take top 15
TOP_15=$(echo "$ALL_FOUNDATIONAL" | jq -c '.' 2>/dev/null | jq -s 'sort_by(-.confidence, -.access_count) | .[:15]' 2>/dev/null || echo "[]")

RECORD_COUNT=$(echo "$TOP_15" | jq 'length' 2>/dev/null || echo "0")

if [[ "$RECORD_COUNT" -eq 0 ]]; then
  echo "No records to sync. Skipping."
  exit 0
fi

# --- Generate new Session Learnings content ---
NEW_LEARNINGS=""
while IFS= read -r content; do
  [[ -z "$content" || "$content" == "null" ]] && continue
  NEW_LEARNINGS="${NEW_LEARNINGS}- ${content}"$'\n'
done < <(echo "$TOP_15" | jq -r '.[].content' 2>/dev/null)

# --- Replace Session Learnings section in CLAUDE.md ---
SECTION_START=$(grep -n "^## Session Learnings" "$CLAUDE_MD" 2>/dev/null | head -1 | cut -d: -f1 || echo "")

if [[ -n "$SECTION_START" ]]; then
  # Find next section or end of file
  NEXT_SEC=$(awk -v start="$((SECTION_START + 1))" 'NR > start && /^## / { print NR; exit }' "$CLAUDE_MD")
  if [[ -z "$NEXT_SEC" ]]; then
    NEXT_SEC=$(($(wc -l < "$CLAUDE_MD" | tr -d ' ') + 1))
  fi

  # Reconstruct file: before section + header + new content + after section
  {
    head -n "$SECTION_START" "$CLAUDE_MD"
    echo ""
    printf '%s' "$NEW_LEARNINGS"
    if [[ "$NEXT_SEC" -le $(wc -l < "$CLAUDE_MD" | tr -d ' ') ]]; then
      echo ""
      tail -n "+$NEXT_SEC" "$CLAUDE_MD"
    fi
  } > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
else
  # Create the section at the end
  {
    cat "$CLAUDE_MD"
    echo ""
    echo "## Session Learnings"
    echo ""
    printf '%s' "$NEW_LEARNINGS"
  } > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
fi

echo "Synced $RECORD_COUNT foundational records to CLAUDE.md Session Learnings"
exit 0
