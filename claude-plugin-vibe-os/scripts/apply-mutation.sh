#!/usr/bin/env bash
# scripts/apply-mutation.sh
# Appends an approved rule to CLAUDE.md "Session Learnings" section.
# Updates mutation-log.json with the applied mutation.
# Usage: apply-mutation.sh --rule "rule text" --section "## Session Learnings" --session-id "session-xxx" --pattern "category"
# Exit 0 on success, Exit 1 on failure.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
MUTATION_LOG="$PROJECT_ROOT/.vibeos/mutation-log.json"

# --- Parse arguments ---
RULE=""
SECTION="## Session Learnings"
SESSION_ID=""
PATTERN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --rule) RULE="$2"; shift 2 ;;
    --section) SECTION="$2"; shift 2 ;;
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --pattern) PATTERN="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$RULE" ]]; then
  echo "ERROR: --rule is required" >&2
  exit 1
fi

if [[ -z "$SESSION_ID" ]]; then
  SESSION_ID="session-$(date -u +%Y-%m-%d)-unknown"
fi

# --- Ensure CLAUDE.md exists ---
if [[ ! -f "$CLAUDE_MD" ]]; then
  echo "ERROR: CLAUDE.md not found at $CLAUDE_MD" >&2
  exit 1
fi

# --- Check for duplicate ---
if grep -qF "$RULE" "$CLAUDE_MD" 2>/dev/null; then
  echo "SKIP: Rule already exists in CLAUDE.md" >&2
  exit 0
fi

# --- Find or create Session Learnings section ---
if grep -q "^## Session Learnings" "$CLAUDE_MD" 2>/dev/null; then
  # Append rule after the section header
  # Find the line number of the section header
  SECTION_LINE=$(grep -n "^## Session Learnings" "$CLAUDE_MD" | head -1 | cut -d: -f1)

  # Find the next section header or end of file
  TOTAL_LINES=$(wc -l < "$CLAUDE_MD" | tr -d ' ')
  NEXT_SECTION_LINE=$(awk -v start="$((SECTION_LINE + 1))" 'NR > start && /^## / { print NR; exit }' "$CLAUDE_MD")

  if [[ -z "$NEXT_SECTION_LINE" ]]; then
    # No next section, append at end of file
    echo "" >> "$CLAUDE_MD"
    echo "- $RULE" >> "$CLAUDE_MD"
  else
    # Insert before the next section
    INSERT_LINE=$((NEXT_SECTION_LINE - 1))
    {
      head -n "$INSERT_LINE" "$CLAUDE_MD"
      echo "- $RULE"
      tail -n "+$((INSERT_LINE + 1))" "$CLAUDE_MD"
    } > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
  fi
else
  # Create the section at the end of CLAUDE.md
  echo "" >> "$CLAUDE_MD"
  echo "## Session Learnings" >> "$CLAUDE_MD"
  echo "" >> "$CLAUDE_MD"
  echo "- $RULE" >> "$CLAUDE_MD"
fi

echo "Applied mutation to CLAUDE.md: $RULE"

# --- Update mutation-log.json ---
if [[ -f "$MUTATION_LOG" ]]; then
  MUTATION_ID="mut-$(date -u +%Y%m%d%H%M%S)"
  TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  jq --arg id "$MUTATION_ID" \
     --arg ts "$TIMESTAMP" \
     --arg sid "$SESSION_ID" \
     --arg rule "$RULE" \
     --arg section "$SECTION" \
     --arg pattern "$PATTERN" \
     '(.mutations // []) |= . + [{
       id: $id,
       timestamp: $ts,
       session_id: $sid,
       type: "add",
       proposed_rule: $rule,
       section: $section,
       reasoning: $pattern,
       source: "performance-coach",
       status: "applied",
       applied_at: $ts,
       rejected_reason: null,
       rejection_count: 0,
       cooldown_until: null,
       confidence: "medium"
     }]' "$MUTATION_LOG" > "$MUTATION_LOG.tmp" && mv "$MUTATION_LOG.tmp" "$MUTATION_LOG"

  echo "Updated mutation-log.json: $MUTATION_ID"
fi

exit 0
