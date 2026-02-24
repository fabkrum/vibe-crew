#!/usr/bin/env bash
# scripts/diff-review-findings.sh
# Compares current system review vs previous review to identify
# new, recurring, and resolved findings.
# Usage: diff-review-findings.sh <current-review.json> [previous-review.json]
# Outputs a JSON diff summary to stdout.
# Exit 0 on success, Exit 1 on failure.

set -euo pipefail

CURRENT="${1:-}"
PREVIOUS="${2:-}"

if [[ -z "$CURRENT" ]]; then
  echo "Usage: diff-review-findings.sh <current-review.json> [previous-review.json]" >&2
  exit 1
fi

if [[ ! -f "$CURRENT" ]]; then
  echo "Error: Current review file not found: $CURRENT" >&2
  exit 1
fi

# If no previous review, all findings are new
if [[ -z "$PREVIOUS" ]] || [[ ! -f "$PREVIOUS" ]]; then
  CURRENT_IDS=$(jq -r '[.findings[]?.id // empty] | sort | unique' "$CURRENT" 2>/dev/null || echo '[]')
  CURRENT_COUNT=$(echo "$CURRENT_IDS" | jq 'length')
  cat <<EOF
{
  "has_previous": false,
  "current_findings": $CURRENT_COUNT,
  "previous_findings": 0,
  "new": $CURRENT_IDS,
  "recurring": [],
  "resolved": [],
  "new_count": $CURRENT_COUNT,
  "recurring_count": 0,
  "resolved_count": 0
}
EOF
  exit 0
fi

# Extract finding IDs from both reviews
CURRENT_IDS=$(jq -r '[.findings[]?.id // empty] | sort | unique' "$CURRENT" 2>/dev/null || echo '[]')
PREVIOUS_IDS=$(jq -r '[.findings[]?.id // empty] | sort | unique' "$PREVIOUS" 2>/dev/null || echo '[]')

# Compute set differences
NEW_IDS=$(jq -n --argjson c "$CURRENT_IDS" --argjson p "$PREVIOUS_IDS" '$c - $p')
RECURRING_IDS=$(jq -n --argjson c "$CURRENT_IDS" --argjson p "$PREVIOUS_IDS" '[$c[] as $id | select($p | index($id))]')
RESOLVED_IDS=$(jq -n --argjson c "$CURRENT_IDS" --argjson p "$PREVIOUS_IDS" '$p - $c')

NEW_COUNT=$(echo "$NEW_IDS" | jq 'length')
RECURRING_COUNT=$(echo "$RECURRING_IDS" | jq 'length')
RESOLVED_COUNT=$(echo "$RESOLVED_IDS" | jq 'length')
CURRENT_COUNT=$(echo "$CURRENT_IDS" | jq 'length')
PREVIOUS_COUNT=$(echo "$PREVIOUS_IDS" | jq 'length')

cat <<EOF
{
  "has_previous": true,
  "current_findings": $CURRENT_COUNT,
  "previous_findings": $PREVIOUS_COUNT,
  "new": $NEW_IDS,
  "recurring": $RECURRING_IDS,
  "resolved": $RESOLVED_IDS,
  "new_count": $NEW_COUNT,
  "recurring_count": $RECURRING_COUNT,
  "resolved_count": $RESOLVED_COUNT
}
EOF

exit 0
