#!/usr/bin/env bash
# scripts/extract-vision-context.sh
# Extract structured context from VISION.md for the Market Scout agent.
# Usage: extract-vision-context.sh [vision-file-path]
# Defaults to VISION.md in the project root.
# Outputs JSON with product_name, product_type, target_audience, core_features[], keywords[].
# Exit 0 always — errors are reported as JSON.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VISION_FILE="${1:-${PROJECT_ROOT}/VISION.md}"

# --- Verify VISION.md exists ---
if [[ ! -f "${VISION_FILE}" ]]; then
  cat <<EOF
{"error": "VISION.md not found", "vision_file": "${VISION_FILE}"}
EOF
  exit 0
fi

CONTENT=$(cat "${VISION_FILE}")

# --- Extract product name from first heading ---
PRODUCT_NAME=$(echo "${CONTENT}" | grep -m1 '^#' | sed -E 's/^#+[[:space:]]*//' | head -c 100 || echo "")
PRODUCT_NAME="${PRODUCT_NAME:-$(basename "${PROJECT_ROOT}")}"

# --- Extract product type ---
# Look for keywords that indicate product category
PRODUCT_TYPE="unknown"
CONTENT_LOWER=$(echo "${CONTENT}" | tr '[:upper:]' '[:lower:]')

if echo "${CONTENT_LOWER}" | grep -qiE 'saas|software.as.a.service'; then
  PRODUCT_TYPE="saas"
elif echo "${CONTENT_LOWER}" | grep -qiE 'marketplace|two.sided'; then
  PRODUCT_TYPE="marketplace"
elif echo "${CONTENT_LOWER}" | grep -qiE 'mobile app|ios|android|react native|flutter'; then
  PRODUCT_TYPE="mobile-app"
elif echo "${CONTENT_LOWER}" | grep -qiE 'developer tool|cli|sdk|api|library|framework'; then
  PRODUCT_TYPE="developer-tool"
elif echo "${CONTENT_LOWER}" | grep -qiE 'e.?commerce|online store|shop'; then
  PRODUCT_TYPE="ecommerce"
elif echo "${CONTENT_LOWER}" | grep -qiE 'social|community|network'; then
  PRODUCT_TYPE="social"
elif echo "${CONTENT_LOWER}" | grep -qiE 'dashboard|analytics|monitoring'; then
  PRODUCT_TYPE="analytics"
elif echo "${CONTENT_LOWER}" | grep -qiE 'web app|webapp|platform'; then
  PRODUCT_TYPE="web-app"
fi

# --- Detect if market-facing ---
IS_MARKET_FACING=true
if echo "${CONTENT_LOWER}" | grep -qiE 'internal tool|internal use|company.only|intranet|back.?office'; then
  IS_MARKET_FACING=false
fi

# --- Extract target audience ---
# Look for sections containing audience/user/persona keywords
TARGET_AUDIENCE=""
IN_AUDIENCE_SECTION=false
while IFS= read -r line; do
  line_lower=$(echo "${line}" | tr '[:upper:]' '[:lower:]')
  # Detect audience section headings
  if echo "${line_lower}" | grep -qiE '^#{1,3}.*\b(audience|users?|personas?|target|customers?|who)\b'; then
    IN_AUDIENCE_SECTION=true
    continue
  fi
  # Stop at next heading
  if [[ "${IN_AUDIENCE_SECTION}" == "true" ]] && echo "${line}" | grep -qE '^#{1,3}\s'; then
    IN_AUDIENCE_SECTION=false
  fi
  # Collect audience lines (bullet points and paragraphs)
  if [[ "${IN_AUDIENCE_SECTION}" == "true" ]] && [[ -n "${line}" ]]; then
    if [[ -n "${TARGET_AUDIENCE}" ]]; then
      TARGET_AUDIENCE="${TARGET_AUDIENCE} ${line}"
    else
      TARGET_AUDIENCE="${line}"
    fi
  fi
done <<< "${CONTENT}"
# Truncate to reasonable length
TARGET_AUDIENCE=$(echo "${TARGET_AUDIENCE}" | head -c 500)

# --- Extract core features ---
# Look for feature lists (bullet points under feature/functionality headings)
FEATURES="[]"
IN_FEATURE_SECTION=false
while IFS= read -r line; do
  line_lower=$(echo "${line}" | tr '[:upper:]' '[:lower:]')
  # Detect feature section headings
  if echo "${line_lower}" | grep -qiE '^#{1,3}.*\b(features?|functionality|capabilities|what|requirements)\b'; then
    IN_FEATURE_SECTION=true
    continue
  fi
  # Stop at next heading
  if [[ "${IN_FEATURE_SECTION}" == "true" ]] && echo "${line}" | grep -qE '^#{1,3}\s'; then
    IN_FEATURE_SECTION=false
  fi
  # Collect bullet points as features
  if [[ "${IN_FEATURE_SECTION}" == "true" ]]; then
    FEATURE_TEXT=$(echo "${line}" | sed -E 's/^[[:space:]]*[-*][[:space:]]*//' | sed 's/\*\*//g' | sed -E 's/^[[:space:]]+//' | head -c 200)
    if [[ -n "${FEATURE_TEXT}" ]] && echo "${line}" | grep -qE '^\s*[-*]'; then
      FEATURES=$(echo "${FEATURES}" | jq --arg f "${FEATURE_TEXT}" '. + [$f]')
    fi
  fi
done <<< "${CONTENT}"

# --- Extract search keywords ---
# Combine product name words + product type + notable nouns for competitor search
KEYWORDS="[]"
# Add product name words (split on spaces)
for word in ${PRODUCT_NAME}; do
  word_clean=$(echo "${word}" | sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')
  if [[ ${#word_clean} -ge 3 ]]; then
    KEYWORDS=$(echo "${KEYWORDS}" | jq --arg w "${word_clean}" '. + [$w] | unique')
  fi
done
# Add product type
if [[ "${PRODUCT_TYPE}" != "unknown" ]]; then
  KEYWORDS=$(echo "${KEYWORDS}" | jq --arg w "${PRODUCT_TYPE}" '. + [$w] | unique')
fi

# --- Output JSON ---
jq -n \
  --arg vision_file "${VISION_FILE}" \
  --arg product_name "${PRODUCT_NAME}" \
  --arg product_type "${PRODUCT_TYPE}" \
  --argjson is_market_facing "${IS_MARKET_FACING}" \
  --arg target_audience "${TARGET_AUDIENCE}" \
  --argjson core_features "${FEATURES}" \
  --argjson keywords "${KEYWORDS}" \
  '{
    "vision_file": $vision_file,
    "product_name": $product_name,
    "product_type": $product_type,
    "is_market_facing": $is_market_facing,
    "target_audience": $target_audience,
    "core_features": $core_features,
    "keywords": $keywords
  }'

exit 0
