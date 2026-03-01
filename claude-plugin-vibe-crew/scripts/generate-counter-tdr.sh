#!/usr/bin/env bash
# scripts/generate-counter-tdr.sh
# Extract decisions from a TDR file -> structured JSON for opponent processor agent
# Usage: generate-counter-tdr.sh [tdr-file-path]
# Defaults to docs/tdr-001-tech-stack.md
# Exit 0 always — errors are reported as JSON

set -euo pipefail

# --- Project root detection ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TDR_FILE="${1:-${PROJECT_ROOT}/docs/tdr-001-tech-stack.md}"

# --- Resolve project name from VISION.md or directory name ---
VISION_FILE="${PROJECT_ROOT}/VISION.md"
if [[ -f "${VISION_FILE}" ]]; then
  PROJECT_NAME=$(head -5 "${VISION_FILE}" | grep -m1 '^#' | sed 's/^#\+\s*//' | head -c 100 || basename "${PROJECT_ROOT}")
else
  PROJECT_NAME=$(basename "${PROJECT_ROOT}")
fi
# Fallback if PROJECT_NAME is empty
PROJECT_NAME="${PROJECT_NAME:-$(basename "${PROJECT_ROOT}")}"

# --- Verify TDR file exists ---
if [[ ! -f "${TDR_FILE}" ]]; then
  cat <<EOF
{"error": "TDR not found", "tdr_file": "${TDR_FILE}"}
EOF
  exit 0
fi

# --- Parse TDR markdown to extract decisions ---
# Strategy: look for decision patterns in the TDR
#   - H2/H3 headings that match technology categories
#   - Lines containing "Chosen:", "Selected:", "Recommendation:", "Decision:"
#   - Table rows with technology names

DECISIONS="[]"

# Known technology categories to search for
CATEGORIES=("framework" "database" "orm" "auth" "authentication" "hosting" "deployment" "styling" "css" "testing" "language" "runtime" "api" "state-management" "monitoring")

while IFS= read -r line; do
  # Match H2 or H3 headings
  if echo "${line}" | grep -qiE '^#{2,3}\s+'; then
    CURRENT_HEADING=$(echo "${line}" | sed 's/^#\+\s*//')

    # Check if this heading matches a known category
    MATCHED_CATEGORY=""
    for cat in "${CATEGORIES[@]}"; do
      if echo "${CURRENT_HEADING}" | grep -qi "${cat}"; then
        MATCHED_CATEGORY="${cat}"
        break
      fi
    done

    if [[ -n "${MATCHED_CATEGORY}" ]]; then
      CURRENT_CATEGORY="${MATCHED_CATEGORY}"
      CURRENT_SECTION_HEADING="${CURRENT_HEADING}"
    fi
  fi

  # Look for decision indicators within sections
  if [[ -n "${CURRENT_CATEGORY:-}" ]]; then
    CHOSEN=""
    RATIONALE=""

    # Match "Chosen: X", "Selected: X", "**Recommendation:** X", "Decision: X"
    if echo "${line}" | grep -qiE '(chosen|selected|recommendation|decision)\s*[:]\s*'; then
      CHOSEN=$(echo "${line}" | sed -E 's/.*(chosen|selected|recommendation|decision)\s*[:]\s*//i' | sed 's/\*\*//g' | head -c 200)
    fi

    # Match "**X**" as the chosen option in a decision line
    if [[ -z "${CHOSEN}" ]] && echo "${line}" | grep -qiE '(recommend|chose|selected|use)\s+\*\*'; then
      CHOSEN=$(echo "${line}" | grep -oE '\*\*[^*]+\*\*' | head -1 | sed 's/\*\*//g' | head -c 200)
    fi

    if [[ -n "${CHOSEN}" ]]; then
      # Try to grab the rationale from the same line or use the heading
      RATIONALE=$(echo "${line}" | sed -E "s/.*${CHOSEN}//" | sed 's/^[[:space:]]*[-—:.]*//' | head -c 200)
      RATIONALE="${RATIONALE:-See TDR section: ${CURRENT_SECTION_HEADING:-${CURRENT_CATEGORY}}}"

      # Add to decisions array using jq (--arg handles escaping)
      DECISIONS=$(echo "${DECISIONS}" | jq \
        --arg cat "${CURRENT_CATEGORY}" \
        --arg chosen "${CHOSEN}" \
        --arg rationale "${RATIONALE}" \
        '. + [{"category": $cat, "chosen_option": $chosen, "stated_rationale": $rationale}]')

      # Reset category after capturing to avoid duplicate entries
      CURRENT_CATEGORY=""
    fi
  fi
done < "${TDR_FILE}"

# --- Deduplicate decisions by category (keep first match) ---
DECISIONS=$(echo "${DECISIONS}" | jq '[group_by(.category)[] | first]')

# --- Output JSON ---
jq -n \
  --arg tdr_file "${TDR_FILE}" \
  --arg project_name "${PROJECT_NAME}" \
  --argjson decisions "${DECISIONS}" \
  '{
    "tdr_file": $tdr_file,
    "project_name": $project_name,
    "decision_count": ($decisions | length),
    "decisions": $decisions
  }'

exit 0
