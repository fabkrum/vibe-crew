#!/usr/bin/env bash
# scripts/claude-md-lint.sh
# Validates CLAUDE.md for size and quality
# Advisory only — always exit 0

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

# If CLAUDE.md doesn't exist, exit silently
if [[ ! -f "$CLAUDE_MD" ]]; then
  exit 0
fi

# ── Line count ──
LINE_COUNT="$(wc -l < "$CLAUDE_MD" | tr -d ' ')"

if [[ "$LINE_COUNT" -ge 600 ]]; then
  SIZE_STATUS="BLOCKED"
  SIZE_MSG="BLOCKED: CLAUDE.md is ${LINE_COUNT} lines (hard limit: 600). No further CLAUDE.md mutations allowed until pruning reduces it below 500."
elif [[ "$LINE_COUNT" -ge 500 ]]; then
  SIZE_STATUS="WARNING"
  SIZE_MSG="WARNING: CLAUDE.md is ${LINE_COUNT} lines (soft limit: 500). Consider pruning stale rules."
else
  SIZE_STATUS="OK"
  SIZE_MSG=""
fi

# ── Pinned section detection ──
# Find lines with <!-- pinned --> marker and map them to their enclosing ## sections
PINNED_COUNT=0
PINNED_RANGES=""

# Track current section start and whether it's pinned
CURRENT_SECTION_START=0
CURRENT_SECTION_PINNED=false
CURRENT_SECTION_NAME=""
PREV_SECTION_END=0

# We need to find section ranges that contain <!-- pinned -->
# Strategy: find all pinned markers, then for each one determine its section range
PINNED_LINES="$(grep -n '<!-- pinned -->' "$CLAUDE_MD" 2>/dev/null || true)"
if [[ -n "$PINNED_LINES" ]]; then
  # Get all ## heading line numbers
  HEADING_LINES="$(grep -n '^## ' "$CLAUDE_MD" 2>/dev/null | cut -d: -f1 || true)"
  # Add end-of-file as a boundary
  HEADING_ARRAY=()
  while IFS= read -r line; do
    [[ -n "$line" ]] && HEADING_ARRAY+=("$line")
  done <<< "$HEADING_LINES"
  HEADING_ARRAY+=("$((LINE_COUNT + 1))")

  # For each pinned marker, find its containing section
  SEEN_SECTIONS=""
  while IFS= read -r pinned_entry; do
    [[ -z "$pinned_entry" ]] && continue
    PINNED_LINE="$(echo "$pinned_entry" | cut -d: -f1)"

    # Find the section that contains this pinned line
    for (( i=0; i<${#HEADING_ARRAY[@]}-1; i++ )); do
      SEC_START="${HEADING_ARRAY[$i]}"
      SEC_END="$(( ${HEADING_ARRAY[$((i+1))]} - 1 ))"
      if [[ "$PINNED_LINE" -ge "$SEC_START" ]] && [[ "$PINNED_LINE" -le "$SEC_END" ]]; then
        # Avoid counting the same section twice
        SEC_KEY="${SEC_START}-${SEC_END}"
        if [[ "$SEEN_SECTIONS" != *"$SEC_KEY"* ]]; then
          SEEN_SECTIONS="$SEEN_SECTIONS $SEC_KEY"
          PINNED_COUNT=$((PINNED_COUNT + 1))
          if [[ -n "$PINNED_RANGES" ]]; then
            PINNED_RANGES="${PINNED_RANGES}, ${SEC_START}-${SEC_END}"
          else
            PINNED_RANGES="${SEC_START}-${SEC_END}"
          fi
        fi
        break
      fi
    done
  done <<< "$PINNED_LINES"
fi

# ── Duplicate rule detection ──
# Find lines that appear more than once, ignoring blank lines, headings, and list markers
DUPLICATES=""
DUPLICATE_COUNT=0

# Filter out blank lines, heading lines (# ...), and bare list markers (- or * alone)
# Then find duplicates
DUPES="$(grep -nv '^\s*$' "$CLAUDE_MD" 2>/dev/null \
  | grep -v '^[0-9]*:#' \
  | grep -v '^[0-9]*:\s*[-*]\s*$' \
  | sed 's/^[0-9]*://' \
  | sort \
  | uniq -d || true)"

if [[ -n "$DUPES" ]]; then
  while IFS= read -r dup_line; do
    [[ -z "$dup_line" ]] && continue
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + 1))
    # Find line numbers for this duplicate
    # Escape special regex chars for grep
    ESCAPED="$(printf '%s' "$dup_line" | sed 's/[.[\*^$()+?{|\\]/\\&/g')"
    DUP_LINE_NUMS="$(grep -nF "$dup_line" "$CLAUDE_MD" 2>/dev/null | cut -d: -f1 | paste -sd ',' - || true)"
    if [[ -n "$DUPLICATES" ]]; then
      DUPLICATES="${DUPLICATES}; lines ${DUP_LINE_NUMS}"
    else
      DUPLICATES="lines ${DUP_LINE_NUMS}"
    fi
  done <<< "$DUPES"
fi

# ── Inlined content detection ──
# Flag lines > 200 chars and code blocks > 20 lines
LONG_LINES=0
LONG_LINES="$(awk 'length > 200' "$CLAUDE_MD" 2>/dev/null | wc -l | tr -d ' ')"

LONG_CODE_BLOCKS=0
IN_CODE_BLOCK=false
CODE_BLOCK_LENGTH=0
while IFS= read -r line; do
  if [[ "$line" =~ ^\`\`\` ]]; then
    if $IN_CODE_BLOCK; then
      # Closing fence
      if [[ "$CODE_BLOCK_LENGTH" -gt 20 ]]; then
        LONG_CODE_BLOCKS=$((LONG_CODE_BLOCKS + 1))
      fi
      IN_CODE_BLOCK=false
      CODE_BLOCK_LENGTH=0
    else
      # Opening fence
      IN_CODE_BLOCK=true
      CODE_BLOCK_LENGTH=0
    fi
  elif $IN_CODE_BLOCK; then
    CODE_BLOCK_LENGTH=$((CODE_BLOCK_LENGTH + 1))
  fi
done < "$CLAUDE_MD"

INLINED_TOTAL=$((LONG_LINES + LONG_CODE_BLOCKS))

# ── Section size analysis ──
# Count lines per ## Section heading, flag sections > 25% of total
DISPROPORTIONATE=""
DISP_COUNT=0

if [[ "$LINE_COUNT" -gt 0 ]]; then
  SECTION_NAME=""
  SECTION_START=0

  # Collect all section headings with line numbers
  SECTIONS_DATA="$(grep -n '^## ' "$CLAUDE_MD" 2>/dev/null || true)"

  if [[ -n "$SECTIONS_DATA" ]]; then
    PREV_NAME=""
    PREV_START=0

    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      CURR_LINE="$(echo "$entry" | cut -d: -f1)"
      CURR_NAME="$(echo "$entry" | sed 's/^[0-9]*:## //')"

      if [[ -n "$PREV_NAME" ]]; then
        SEC_SIZE=$(( CURR_LINE - PREV_START ))
        SEC_PCT=$(( SEC_SIZE * 100 / LINE_COUNT ))
        if [[ "$SEC_PCT" -gt 25 ]]; then
          DISP_COUNT=$((DISP_COUNT + 1))
          if [[ -n "$DISPROPORTIONATE" ]]; then
            DISPROPORTIONATE="${DISPROPORTIONATE}, \"${PREV_NAME}\" is ${SEC_PCT}% of total"
          else
            DISPROPORTIONATE="\"${PREV_NAME}\" is ${SEC_PCT}% of total"
          fi
        fi
      fi
      PREV_NAME="$CURR_NAME"
      PREV_START="$CURR_LINE"
    done <<< "$SECTIONS_DATA"

    # Check the last section (from last heading to end of file)
    if [[ -n "$PREV_NAME" ]] && [[ "$PREV_START" -gt 0 ]]; then
      SEC_SIZE=$(( LINE_COUNT - PREV_START + 1 ))
      SEC_PCT=$(( SEC_SIZE * 100 / LINE_COUNT ))
      if [[ "$SEC_PCT" -gt 25 ]]; then
        DISP_COUNT=$((DISP_COUNT + 1))
        if [[ -n "$DISPROPORTIONATE" ]]; then
          DISPROPORTIONATE="${DISPROPORTIONATE}, \"${PREV_NAME}\" is ${SEC_PCT}% of total"
        else
          DISPROPORTIONATE="\"${PREV_NAME}\" is ${SEC_PCT}% of total"
        fi
      fi
    fi
  fi
fi

# ── Output report ──
echo "CLAUDE.md Lint Report"
echo "====================="
echo "Size: ${LINE_COUNT} lines (${SIZE_STATUS})"
if [[ -n "$SIZE_MSG" ]]; then
  echo "$SIZE_MSG"
fi

echo "Pinned sections: ${PINNED_COUNT}${PINNED_RANGES:+ (lines ${PINNED_RANGES})}"

if [[ "$DUPLICATE_COUNT" -gt 0 ]]; then
  echo "Duplicate rules: ${DUPLICATE_COUNT} found (${DUPLICATES})"
fi

if [[ "$INLINED_TOTAL" -gt 0 ]]; then
  DETAIL=""
  [[ "$LONG_LINES" -gt 0 ]] && DETAIL="${LONG_LINES} long lines"
  [[ "$LONG_CODE_BLOCKS" -gt 0 ]] && {
    [[ -n "$DETAIL" ]] && DETAIL="${DETAIL}, "
    DETAIL="${DETAIL}${LONG_CODE_BLOCKS} code blocks >20 lines"
  }
  echo "Inlined content: ${INLINED_TOTAL} blocks detected (${DETAIL})"
fi

if [[ "$DISP_COUNT" -gt 0 ]]; then
  echo "Disproportionate sections: ${DISPROPORTIONATE}"
fi

exit 0
