#!/usr/bin/env bash
# scripts/scan-dependencies.sh
# Multi-language dependency vulnerability audit.
# Checks for npm, pip, bundle, govulncheck, cargo, and composer audit tools.
# Falls back gracefully if tools are missing.
# Outputs JSON with results per language.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCANNED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- Helper: build result JSON for a language ---
# Usage: build_result "status" "vulnerabilities_json"
build_result() {
  local status="$1"
  local vulns="${2:-"{}"}"
  jq -n --arg s "$status" --argjson v "$vulns" '{"status": $s, "vulnerabilities": $v}'
}

# =============================================================================
# npm audit
# =============================================================================
npm_result='{}'
if [[ -f "$PROJECT_ROOT/package-lock.json" ]]; then
  if command -v npm &>/dev/null; then
    NPM_OUTPUT=$(cd "$PROJECT_ROOT" && npm audit --json 2>/dev/null || echo '{}')
    # Extract vulnerability summary if available
    NPM_VULNS=$(echo "$NPM_OUTPUT" | jq '{
      total: (.metadata.vulnerabilities // {} | to_entries | map(.value) | add // 0),
      critical: (.metadata.vulnerabilities.critical // 0),
      high: (.metadata.vulnerabilities.high // 0),
      moderate: (.metadata.vulnerabilities.moderate // 0),
      low: (.metadata.vulnerabilities.low // 0),
      info: (.metadata.vulnerabilities.info // 0),
      advisories_count: (.vulnerabilities // {} | length)
    }' 2>/dev/null || echo '{}')
    npm_result=$(build_result "scanned" "$NPM_VULNS")
  else
    npm_result=$(build_result "tool_not_installed" '{}')
  fi
else
  npm_result=$(build_result "no_lockfile" '{}')
fi

# =============================================================================
# pip audit (Python)
# =============================================================================
pip_result='{}'
if [[ -f "$PROJECT_ROOT/requirements.txt" || -f "$PROJECT_ROOT/pyproject.toml" ]]; then
  if command -v pip-audit &>/dev/null; then
    PIP_OUTPUT=$(cd "$PROJECT_ROOT" && pip-audit --format=json 2>/dev/null || echo '[]')
    PIP_VULNS=$(echo "$PIP_OUTPUT" | jq '{
      total: (if type == "array" then length else 0 end),
      critical: (if type == "array" then [.[] | select(.fix_versions != null)] | length else 0 end),
      packages: (if type == "array" then [.[] | .name] | unique else [] end)
    }' 2>/dev/null || echo '{}')
    pip_result=$(build_result "scanned" "$PIP_VULNS")
  else
    pip_result=$(build_result "tool_not_installed" '{}')
  fi
else
  pip_result=$(build_result "no_lockfile" '{}')
fi

# =============================================================================
# bundle audit (Ruby)
# =============================================================================
bundle_result='{}'
if [[ -f "$PROJECT_ROOT/Gemfile.lock" ]]; then
  if command -v bundle-audit &>/dev/null; then
    BUNDLE_OUTPUT=$(cd "$PROJECT_ROOT" && bundle-audit check --format=json 2>/dev/null || echo '{}')
    BUNDLE_VULNS=$(echo "$BUNDLE_OUTPUT" | jq '{
      total: (.results // [] | length),
      advisories: (.results // [] | map(.advisory.id) | unique)
    }' 2>/dev/null || echo '{}')
    bundle_result=$(build_result "scanned" "$BUNDLE_VULNS")
  else
    bundle_result=$(build_result "tool_not_installed" '{}')
  fi
else
  bundle_result=$(build_result "no_lockfile" '{}')
fi

# =============================================================================
# govulncheck (Go)
# =============================================================================
go_result='{}'
if [[ -f "$PROJECT_ROOT/go.mod" ]]; then
  if command -v govulncheck &>/dev/null; then
    GO_OUTPUT=$(cd "$PROJECT_ROOT" && govulncheck -json ./... 2>/dev/null || echo '{}')
    GO_VULNS=$(echo "$GO_OUTPUT" | jq '{
      total: ([.vulnerability?] | map(select(. != null)) | length),
      raw_output: (. | tostring | .[0:500])
    }' 2>/dev/null || echo '{}')
    go_result=$(build_result "scanned" "$GO_VULNS")
  else
    go_result=$(build_result "tool_not_installed" '{}')
  fi
else
  go_result=$(build_result "no_lockfile" '{}')
fi

# =============================================================================
# cargo audit (Rust)
# =============================================================================
cargo_result='{}'
if [[ -f "$PROJECT_ROOT/Cargo.lock" ]]; then
  if command -v cargo-audit &>/dev/null; then
    CARGO_OUTPUT=$(cd "$PROJECT_ROOT" && cargo audit --json 2>/dev/null || echo '{}')
    CARGO_VULNS=$(echo "$CARGO_OUTPUT" | jq '{
      total: (.vulnerabilities.found // 0),
      critical: (.vulnerabilities.list // [] | map(select(.advisory.cvss? // "" | startswith("CVSS:3"))) | length),
      advisories: (.vulnerabilities.list // [] | map(.advisory.id))
    }' 2>/dev/null || echo '{}')
    cargo_result=$(build_result "scanned" "$CARGO_VULNS")
  else
    cargo_result=$(build_result "tool_not_installed" '{}')
  fi
else
  cargo_result=$(build_result "no_lockfile" '{}')
fi

# =============================================================================
# composer audit (PHP)
# =============================================================================
composer_result='{}'
if [[ -f "$PROJECT_ROOT/composer.lock" ]]; then
  if command -v composer &>/dev/null; then
    COMPOSER_OUTPUT=$(cd "$PROJECT_ROOT" && composer audit --format=json 2>/dev/null || echo '{}')
    COMPOSER_VULNS=$(echo "$COMPOSER_OUTPUT" | jq '{
      total: (.advisories // {} | to_entries | map(.value | length) | add // 0),
      packages: (.advisories // {} | keys)
    }' 2>/dev/null || echo '{}')
    composer_result=$(build_result "scanned" "$COMPOSER_VULNS")
  else
    composer_result=$(build_result "tool_not_installed" '{}')
  fi
else
  composer_result=$(build_result "no_lockfile" '{}')
fi

# =============================================================================
# Output combined JSON
# =============================================================================
jq -n \
  --arg scanned_at "$SCANNED_AT" \
  --argjson npm "$npm_result" \
  --argjson pip "$pip_result" \
  --argjson bundle "$bundle_result" \
  --argjson go "$go_result" \
  --argjson cargo "$cargo_result" \
  --argjson composer "$composer_result" \
  '{
    "scanned_at": $scanned_at,
    "results": {
      "npm": $npm,
      "pip": $pip,
      "bundle": $bundle,
      "go": $go,
      "cargo": $cargo,
      "composer": $composer
    }
  }'

exit 0
