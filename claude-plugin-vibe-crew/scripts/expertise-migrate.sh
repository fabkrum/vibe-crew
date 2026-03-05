#!/usr/bin/env bash
# scripts/expertise-migrate.sh
# One-time import of existing Session Learnings from CLAUDE.md as foundational conventions.
# Idempotent: skips rules already present in expertise JSONL.
# Usage: expertise-migrate.sh [project_root]
# Exit 0 on success

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
EXPERTISE_DIR="$PROJECT_ROOT/.vibecrew/expertise"

if [[ ! -f "$CLAUDE_MD" ]]; then
  echo "No CLAUDE.md found. Nothing to migrate."
  exit 0
fi

# --- Extract Session Learnings ---
SECTION_START=$(grep -n "^## Session Learnings" "$CLAUDE_MD" 2>/dev/null | head -1 | cut -d: -f1 || echo "")

if [[ -z "$SECTION_START" ]]; then
  echo "No Session Learnings section found. Nothing to migrate."
  exit 0
fi

# Find next section or end of file
NEXT_SEC=$(awk -v start="$((SECTION_START + 1))" 'NR > start && /^## / { print NR; exit }' "$CLAUDE_MD")
if [[ -z "$NEXT_SEC" ]]; then
  NEXT_SEC=$(($(wc -l < "$CLAUDE_MD" | tr -d ' ') + 1))
fi

# Extract rule lines (starting with "- ")
RULES=$(awk -v s="$((SECTION_START + 1))" -v e="$((NEXT_SEC - 1))" 'NR >= s && NR <= e && /^- /' "$CLAUDE_MD" | sed 's/^- //')

if [[ -z "$RULES" ]]; then
  echo "No rules found in Session Learnings. Nothing to migrate."
  exit 0
fi

# --- Check existing expertise for dedup ---
mkdir -p "$EXPERTISE_DIR"
EXISTING_CONTENTS=""
if [[ -f "$EXPERTISE_DIR/conventions.jsonl" ]]; then
  EXISTING_CONTENTS=$(jq -r '.content' "$EXPERTISE_DIR/conventions.jsonl" 2>/dev/null || true)
fi

MIGRATED=0
SKIPPED=0

while IFS= read -r rule; do
  [[ -z "$rule" ]] && continue

  # Check if already migrated (exact match)
  if [[ -n "$EXISTING_CONTENTS" ]] && echo "$EXISTING_CONTENTS" | grep -qF "$rule"; then
    SKIPPED=$((SKIPPED + 1))
    continue
  fi

  # Write as foundational convention
  bash "$SCRIPT_DIR/expertise-write.sh" \
    --domain "conventions" \
    --type "convention" \
    --tier "foundational" \
    --content "$rule" \
    --context "Migrated from CLAUDE.md Session Learnings" \
    --outcome "success" \
    --confidence "0.80" \
    --source-agent "migration" \
    --session-id "migration-$(date -u +%Y%m%d)" > /dev/null

  MIGRATED=$((MIGRATED + 1))
done <<< "$RULES"

echo "Migration complete: migrated=$MIGRATED skipped=$SKIPPED"
exit 0
