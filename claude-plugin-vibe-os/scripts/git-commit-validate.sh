#!/usr/bin/env bash
# scripts/git-commit-validate.sh
# Validates and enforces conventional commit format.
# Used as a pre-commit check by the Feature Developer and Quality Check agents.
# Usage: git-commit-validate.sh "commit message"  OR  echo "message" | git-commit-validate.sh
# Output: JSON validation result to stdout
# Exit: 0 if valid, 1 if invalid

set -euo pipefail

# --- Allowed commit types ---
ALLOWED_TYPES="feat|fix|refactor|docs|test|chore|style|perf|build|ci|revert"

# --- Read commit message ---
if [[ $# -ge 1 && -n "${1:-}" ]]; then
  COMMIT_MSG="$1"
else
  # Read from stdin
  COMMIT_MSG=$(cat)
fi

if [[ -z "$COMMIT_MSG" ]]; then
  jq -n '{
    valid: false,
    type: null,
    scope: null,
    description: null,
    issues: ["Commit message is empty"]
  }'
  exit 1
fi

# --- Extract first line (subject) ---
SUBJECT=$(echo "$COMMIT_MSG" | head -1)

# --- Validate ---
ISSUES="[]"
PARSED_TYPE="null"
PARSED_SCOPE="null"
PARSED_DESC="null"

# Check subject line length
SUBJECT_LEN=${#SUBJECT}
if [[ "$SUBJECT_LEN" -gt 72 ]]; then
  ISSUES=$(echo "$ISSUES" | jq --arg msg "Subject line exceeds 72 characters (got $SUBJECT_LEN)" '. + [$msg]')
fi

# Match conventional commit pattern
# Pattern: type(scope): description
# Regex assigned to variables to avoid bash parsing issues with parentheses
CC_FULL_RE='^([a-zA-Z]+)(\(([^)]+)\))?:[[:space:]](.+)$'
CC_PARTIAL_RE='^([a-zA-Z]+)(\(([^)]+)\))?:.*$'
CC_TYPE_RE="^(${ALLOWED_TYPES})$"

if [[ "$SUBJECT" =~ $CC_FULL_RE ]]; then
  RAW_TYPE="${BASH_REMATCH[1]}"
  RAW_SCOPE="${BASH_REMATCH[3]:-}"
  RAW_DESC="${BASH_REMATCH[4]}"

  # Validate type
  if [[ "$RAW_TYPE" =~ $CC_TYPE_RE ]]; then
    PARSED_TYPE="\"$RAW_TYPE\""
  else
    ISSUES=$(echo "$ISSUES" | jq \
      --arg msg "Type '$RAW_TYPE' is not valid. Use: feat, fix, refactor, docs, test, chore, style, perf, build, ci, revert" \
      '. + [$msg]')
  fi

  # Set scope (may be empty)
  if [[ -n "$RAW_SCOPE" ]]; then
    PARSED_SCOPE="\"$RAW_SCOPE\""
  fi

  # Validate description starts with lowercase
  FIRST_CHAR="${RAW_DESC:0:1}"
  if [[ "$FIRST_CHAR" =~ [A-Z] ]]; then
    ISSUES=$(echo "$ISSUES" | jq \
      --arg msg "Description must start with lowercase letter (got '${FIRST_CHAR}')" \
      '. + [$msg]')
  fi

  # Validate description does not end with a period
  LAST_CHAR="${RAW_DESC: -1}"
  if [[ "$LAST_CHAR" == "." ]]; then
    ISSUES=$(echo "$ISSUES" | jq '. + ["Description must not end with a period"]')
  fi

  # Set description if we got this far
  PARSED_DESC=$(jq -n --arg d "$RAW_DESC" '$d')

elif [[ "$SUBJECT" =~ $CC_PARTIAL_RE ]]; then
  # Matched type but missing space after colon or empty description
  RAW_TYPE="${BASH_REMATCH[1]}"
  ISSUES=$(echo "$ISSUES" | jq '. + ["Description is missing or there is no space after the colon. Format: type(scope): description"]')

  if [[ "$RAW_TYPE" =~ $CC_TYPE_RE ]]; then
    PARSED_TYPE="\"$RAW_TYPE\""
  else
    ISSUES=$(echo "$ISSUES" | jq \
      --arg msg "Type '$RAW_TYPE' is not valid. Use: feat, fix, refactor, docs, test, chore, style, perf, build, ci, revert" \
      '. + [$msg]')
  fi
else
  # Does not match conventional commit format at all
  ISSUES=$(echo "$ISSUES" | jq '. + ["Does not match conventional commit format. Expected: type(scope): description"]')
fi

# --- Determine validity ---
ISSUE_COUNT=$(echo "$ISSUES" | jq 'length')

if [[ "$ISSUE_COUNT" -eq 0 ]]; then
  # Valid
  jq -n \
    --argjson type "$PARSED_TYPE" \
    --argjson scope "$PARSED_SCOPE" \
    --argjson description "$PARSED_DESC" \
    '{
      valid: true,
      type: $type,
      scope: $scope,
      description: $description,
      issues: []
    }'
  exit 0
else
  # Invalid
  jq -n \
    --argjson type "$PARSED_TYPE" \
    --argjson scope "$PARSED_SCOPE" \
    --argjson description "$PARSED_DESC" \
    --argjson issues "$ISSUES" \
    '{
      valid: false,
      type: $type,
      scope: $scope,
      description: $description,
      issues: $issues
    }'
  exit 1
fi
