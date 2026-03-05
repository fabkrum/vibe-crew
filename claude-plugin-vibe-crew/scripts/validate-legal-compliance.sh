#!/usr/bin/env bash
# scripts/validate-legal-compliance.sh
# Validates that a project includes required legal compliance pages and elements.
# Scans for impressum, privacy policy, cookie consent, terms, accessibility
# statement, footer links, and third-party script gating.
#
# Usage: validate-legal-compliance.sh [project_root]
# Output: JSON { checks: [{name, status, details}] }

set -uo pipefail

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

checks=()

# --- Helper: add a check result ---
add_check() {
  local name="$1" status="$2" details="$3"
  checks+=("$(jq -n \
    --arg name "$name" \
    --arg status "$status" \
    --arg details "$details" \
    '{ name: $name, status: $status, details: $details }')")
}

# --- Collect existing directories to search ---
SEARCH_DIRS=()
for d in "$PROJECT_ROOT/src" "$PROJECT_ROOT/app" "$PROJECT_ROOT/pages" "$PROJECT_ROOT/components" "$PROJECT_ROOT/public"; do
  [[ -d "$d" ]] && SEARCH_DIRS+=("$d")
done

# If no source directories exist, report all as warnings and exit
if [[ ${#SEARCH_DIRS[@]} -eq 0 ]]; then
  add_check "impressum_page" "warn" "No source directories found to scan."
  add_check "privacy_policy" "warn" "No source directories found to scan."
  add_check "cookie_consent" "warn" "No source directories found to scan."
  add_check "terms_page" "warn" "No source directories found to scan."
  add_check "footer_links" "warn" "No source directories found to scan."
  add_check "third_party_scripts" "pass" "No source directories found to scan."
  add_check "accessibility_statement" "warn" "No source directories found to scan."
  checks_json="["
  for i in "${!checks[@]}"; do
    if [[ $i -gt 0 ]]; then checks_json+=","; fi
    checks_json+="${checks[$i]}"
  done
  checks_json+="]"
  echo "$checks_json" | jq '{ checks: . }'
  exit 0
fi

# --- 1. Impressum page ---
if find "${SEARCH_DIRS[@]}" -type f \
    \( -name "*impressum*" -o -name "*imprint*" -o -name "*legal-notice*" \) \
    2>/dev/null | grep -q .; then
  add_check "impressum_page" "pass" "Impressum/imprint page found"
else
  add_check "impressum_page" "warn" "No impressum/imprint page found. Required for DE/AT/CH (TMG §5)."
fi

# --- 2. Privacy policy page ---
if find "${SEARCH_DIRS[@]}" -type f \
    \( -name "*privacy*" -o -name "*datenschutz*" \) \
    2>/dev/null | grep -q .; then
  add_check "privacy_policy" "pass" "Privacy policy page found"
else
  add_check "privacy_policy" "fail" "No privacy policy page found. Required by GDPR Art. 13/14."
fi

# --- 3. Cookie consent ---
if grep -rql 'cookie\|consent' --include='*.ts' --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.svelte' \
    "${SEARCH_DIRS[@]}" 2>/dev/null | head -1 | grep -q .; then
  add_check "cookie_consent" "pass" "Cookie consent references found in source code"
else
  add_check "cookie_consent" "warn" "No cookie consent implementation detected. Required by GDPR + TTDSG."
fi

# --- 4. Terms page ---
if find "${SEARCH_DIRS[@]}" -type f \
    \( -name "*terms*" -o -name "*agb*" -o -name "*tos*" \) \
    2>/dev/null | grep -q .; then
  add_check "terms_page" "pass" "Terms of service page found"
else
  add_check "terms_page" "warn" "No terms of service page found. Recommended for B2C services."
fi

# --- 5. Footer links (privacy, terms, impressum) ---
footer_links_found=0
if grep -rql 'privacy\|datenschutz' --include='*.ts' --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.svelte' \
    "${SEARCH_DIRS[@]}" 2>/dev/null | xargs grep -l -i 'footer\|layout' 2>/dev/null | head -1 | grep -q .; then
  footer_links_found=$((footer_links_found + 1))
fi
if grep -rql 'impressum\|imprint\|legal.notice' --include='*.ts' --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.svelte' \
    "${SEARCH_DIRS[@]}" 2>/dev/null | xargs grep -l -i 'footer\|layout' 2>/dev/null | head -1 | grep -q .; then
  footer_links_found=$((footer_links_found + 1))
fi

if [[ $footer_links_found -ge 2 ]]; then
  add_check "footer_links" "pass" "Privacy and impressum links found in footer/layout components"
elif [[ $footer_links_found -ge 1 ]]; then
  add_check "footer_links" "warn" "Only partial footer links found. Ensure privacy policy and impressum are linked from every page."
else
  add_check "footer_links" "warn" "No legal links detected in footer/layout. Privacy and impressum must be accessible from every page."
fi

# --- 6. Third-party scripts gated behind consent ---
third_party_scripts=0
ungated_scripts=0
for pattern in "google.*analytics\|gtag\|GA4" "facebook\|fbq\|meta.*pixel" "hubspot" "intercom" "hotjar" "mixpanel"; do
  if grep -rql "$pattern" --include='*.ts' --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.svelte' --include='*.html' \
      "${SEARCH_DIRS[@]}" 2>/dev/null | head -1 | grep -q .; then
    third_party_scripts=$((third_party_scripts + 1))
    # Check if it appears near consent-related code
    if ! grep -rql "$pattern" --include='*.ts' --include='*.tsx' --include='*.jsx' --include='*.vue' --include='*.svelte' \
        "${SEARCH_DIRS[@]}" 2>/dev/null | xargs grep -l -i 'consent\|cookie' 2>/dev/null | head -1 | grep -q .; then
      ungated_scripts=$((ungated_scripts + 1))
    fi
  fi
done

if [[ $third_party_scripts -eq 0 ]]; then
  add_check "third_party_scripts" "pass" "No third-party tracking scripts detected"
elif [[ $ungated_scripts -eq 0 ]]; then
  add_check "third_party_scripts" "pass" "Third-party scripts appear to be consent-gated ($third_party_scripts found)"
else
  add_check "third_party_scripts" "fail" "$ungated_scripts of $third_party_scripts third-party scripts may not be consent-gated. Must block before user consent."
fi

# --- 7. Accessibility statement ---
if find "${SEARCH_DIRS[@]}" -type f \
    \( -name "*accessibility*" -o -name "*barrierefreiheit*" -o -name "*a11y-statement*" \) \
    2>/dev/null | grep -q .; then
  add_check "accessibility_statement" "pass" "Accessibility statement page found"
else
  add_check "accessibility_statement" "warn" "No accessibility statement found. Required by EAA/BFSG from June 2025."
fi

# --- Build output JSON ---
checks_json="["
for i in "${!checks[@]}"; do
  if [[ $i -gt 0 ]]; then checks_json+=","; fi
  checks_json+="${checks[$i]}"
done
checks_json+="]"

echo "$checks_json" | jq '{ checks: . }'
