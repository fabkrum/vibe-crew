#!/usr/bin/env bash
# scripts/generate-handoff.sh
# Reads state.json, backlog.json, recent commits; produces structured handoff.
# Output: .vibecrew/handoffs/handoff-{YYYY-MM-DD}-{NNN}.md
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"
HANDOFFS_DIR="$PROJECT_ROOT/.vibecrew/handoffs"

mkdir -p "$HANDOFFS_DIR"

# --- Determine filename ---
TODAY=$(date -u +%Y-%m-%d)
EXISTING=$(ls "$HANDOFFS_DIR"/handoff-"${TODAY}"-*.md 2>/dev/null | wc -l | tr -d ' ')
NEXT=$(printf "%03d" $((EXISTING + 1)))
HANDOFF_FILE="$HANDOFFS_DIR/handoff-${TODAY}-${NEXT}.md"

# --- Read state ---
FEATURE_NAME="none"
FEATURE_ID="none"
PHASE="idle"
PHASES_COMPLETED=""
BRANCH="unknown"

if [[ -f "$STATE_FILE" ]]; then
  FEATURE_NAME=$(jq -r '.active_feature.name // "none"' "$STATE_FILE" 2>/dev/null || echo "none")
  FEATURE_ID=$(jq -r '.active_feature.id // "none"' "$STATE_FILE" 2>/dev/null || echo "none")
  PHASE=$(jq -r '.active_feature.phase // "idle"' "$STATE_FILE" 2>/dev/null || echo "idle")
  PHASES_COMPLETED=$(jq -r '.active_feature.phases_completed // [] | join(", ")' "$STATE_FILE" 2>/dev/null || echo "")
fi

if command -v git &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
fi

# --- Read latest score ---
SCORE="N/A"
RATING="N/A"
LATEST_SCORE=$(ls -1t "$PROJECT_ROOT/.vibecrew/scores"/score-*.json 2>/dev/null | head -1)
if [[ -n "$LATEST_SCORE" && -f "$LATEST_SCORE" ]]; then
  SCORE=$(jq -r '.score // "N/A"' "$LATEST_SCORE" 2>/dev/null || echo "N/A")
  RATING=$(jq -r '.rating // "N/A"' "$LATEST_SCORE" 2>/dev/null || echo "N/A")
fi

# --- Recent commits ---
COMMITS=""
if command -v git &>/dev/null; then
  COMMITS=$(git log --oneline -5 2>/dev/null || echo "No recent commits")
fi

# --- Files changed ---
FILES_CHANGED=""
if command -v git &>/dev/null; then
  FILES_CHANGED=$(git diff --stat HEAD~5 2>/dev/null | head -10 || echo "Unable to determine changed files")
fi

# --- Check for blockers ---
BLOCKERS="No blockers."
SIGNALS=$(ls "$PROJECT_ROOT/.vibecrew/signals"/*.signal 2>/dev/null || echo "")
if [[ -n "$SIGNALS" ]]; then
  BLOCKERS="Active signals:\n"
  while IFS= read -r sig; do
    [[ -z "$sig" ]] && continue
    BLOCKERS="${BLOCKERS}- $(basename "$sig")\n"
  done <<< "$SIGNALS"
fi

# --- Generate handoff ---
cat > "$HANDOFF_FILE.tmp" << HANDOFF_EOF
# Session Handoff — $TODAY

## State
- **Active feature**: $FEATURE_NAME ($FEATURE_ID) — Phase: $PHASE
- **Phases done**: ${PHASES_COMPLETED:-none}
- **Branch**: $BRANCH
- **Vibe Score**: $SCORE/100 ($RATING)

## What Was Done
$(echo "$COMMITS" | head -5 | sed 's/^/- /')

## Blockers
$(echo -e "$BLOCKERS")

## Next Steps
1. Continue with the $PHASE phase for $FEATURE_NAME
2. Address any failing tests or build issues

## Key Decisions
No new decisions recorded this session.

## Files Changed
\`\`\`
$FILES_CHANGED
\`\`\`
HANDOFF_EOF

mv "$HANDOFF_FILE.tmp" "$HANDOFF_FILE"

# --- Report ---
WORD_COUNT=$(wc -w < "$HANDOFF_FILE" | tr -d ' ')
echo "Handoff generated: $HANDOFF_FILE ($WORD_COUNT words)"

exit 0
