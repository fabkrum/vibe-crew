#!/usr/bin/env bash
# scripts/detect-secrets.sh
# Regex scan for sensitive patterns (API keys, secrets, tokens, etc.).
# Scans project files excluding node_modules, .git, dist, .vibecrew, vendor.
# REDACTS actual secret values in output (first 4 + last 4 chars).
# Outputs JSON with findings.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCANNED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Directories to exclude from scanning
EXCLUDES="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=.vibecrew --exclude-dir=vendor --exclude-dir=build --exclude-dir=.next --exclude-dir=coverage --exclude-dir=__pycache__"

# Temp file for collecting findings
FINDINGS_TMP=$(mktemp)
trap 'rm -f "$FINDINGS_TMP"' EXIT
echo '[]' > "$FINDINGS_TMP"

# --- Helper: redact a secret value (show first 4 + last 4 chars) ---
redact_value() {
  local val="$1"
  local len=${#val}
  if [[ $len -le 8 ]]; then
    echo "${val:0:2}...${val: -2}"
  else
    echo "${val:0:4}...${val: -4}"
  fi
}

# --- Helper: scan for a pattern and add findings ---
# Usage: scan_pattern "type" "pattern" "description"
scan_pattern() {
  local secret_type="$1"
  local pattern="$2"

  # Run grep and process matches
  while IFS= read -r match_line; do
    [[ -z "$match_line" ]] && continue

    # Parse grep -rn output: file:line:content
    local file line content
    file=$(echo "$match_line" | cut -d: -f1)
    line=$(echo "$match_line" | cut -d: -f2)
    content=$(echo "$match_line" | cut -d: -f3-)

    # Skip binary files, lock files, and test fixtures
    case "$file" in
      *.lock|*.min.js|*.min.css|*.map|*.svg|*.png|*.jpg|*.gif|*.ico|*.woff*|*.ttf|*.eot) continue ;;
      *test*fixture*|*test*mock*|*__snapshots__*) continue ;;
    esac

    # Extract the matched secret value for redaction
    local matched_value
    matched_value=$(echo "$content" | grep -oE "$pattern" 2>/dev/null | head -1 || echo "")
    local redacted
    if [[ -n "$matched_value" ]]; then
      redacted=$(redact_value "$matched_value")
    else
      redacted="[detected]"
    fi

    # Make file path relative to project root
    local rel_file="${file#$PROJECT_ROOT/}"

    # Append finding to temp file
    FINDINGS_TMP_CONTENT=$(cat "$FINDINGS_TMP")
    echo "$FINDINGS_TMP_CONTENT" | jq \
      --arg type "$secret_type" \
      --arg f "$rel_file" \
      --argjson l "$line" \
      --arg rv "$redacted" \
      '. + [{"type": $type, "file": $f, "line": $l, "redacted_value": $rv}]' \
      > "$FINDINGS_TMP" 2>/dev/null || true

  done < <(grep -rn $EXCLUDES -E "$pattern" "$PROJECT_ROOT" 2>/dev/null || true)
}

# =============================================================================
# Pattern 1: AWS Access Keys
# =============================================================================
scan_pattern "aws_access_key" "AKIA[0-9A-Z]{16}"

# =============================================================================
# Pattern 2: AWS Secret Keys (40-char base64 near aws/secret context)
# =============================================================================
scan_pattern "aws_secret_key" "(aws_secret_access_key|AWS_SECRET)[[:space:]]*[=:][[:space:]]*['\"]?[A-Za-z0-9/+=]{40}"

# =============================================================================
# Pattern 3: Generic API Keys
# =============================================================================
scan_pattern "generic_api_key" "(api[_-]?key|apikey)[[:space:]]*[:=][[:space:]]*['\"][A-Za-z0-9]{20,}"

# =============================================================================
# Pattern 4: Private Keys
# =============================================================================
scan_pattern "private_key" "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"

# =============================================================================
# Pattern 5: Passwords in Config
# =============================================================================
scan_pattern "password_in_config" "(password|passwd|pwd)[[:space:]]*[:=][[:space:]]*['\"][^'\"]{8,}"

# =============================================================================
# Pattern 6: JWTs
# =============================================================================
scan_pattern "jwt_token" "eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}"

# =============================================================================
# Pattern 7: Connection Strings
# =============================================================================
scan_pattern "connection_string" "(mongodb|postgres|mysql|redis)://[^[:space:]'\"]+"

# =============================================================================
# Pattern 8: Stripe Keys
# =============================================================================
scan_pattern "stripe_key" "(sk|pk)_(test|live)_[A-Za-z0-9]{20,}"

# =============================================================================
# Pattern 9: GitHub Tokens
# =============================================================================
scan_pattern "github_token" "(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36,}"

# =============================================================================
# Output JSON
# =============================================================================
SECRETS_FOUND=$(cat "$FINDINGS_TMP")
TOTAL_COUNT=$(echo "$SECRETS_FOUND" | jq 'length' 2>/dev/null || echo "0")

jq -n \
  --arg scanned_at "$SCANNED_AT" \
  --argjson secrets_found "$SECRETS_FOUND" \
  --argjson total_count "$TOTAL_COUNT" \
  '{
    "scanned_at": $scanned_at,
    "secrets_found": $secrets_found,
    "total_count": $total_count
  }'

exit 0
