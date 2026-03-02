#!/usr/bin/env bash
# scripts/fetch-github-issue.sh
# Fetch a single GitHub issue by number using gh CLI.
# Outputs structured JSON with issue details.
# Exit 0 always — errors are reported in the JSON output.
# Usage: fetch-github-issue.sh <issue-number>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Validate arguments
if [[ $# -lt 1 ]] || [[ -z "$1" ]]; then
  jq -n '{
    status: "error",
    message: "Usage: fetch-github-issue.sh <issue-number>"
  }'
  exit 0
fi

ISSUE_NUMBER="$1"

# Validate issue number is a positive integer
if ! [[ "$ISSUE_NUMBER" =~ ^[1-9][0-9]*$ ]]; then
  jq -n --arg num "$ISSUE_NUMBER" '{
    status: "error",
    message: ("Invalid issue number: " + $num + ". Must be a positive integer.")
  }'
  exit 0
fi

# Run pre-flight checks via check-gh-auth.sh
AUTH_RESULT=$(bash "$SCRIPT_DIR/check-gh-auth.sh")
AUTH_STATUS=$(echo "$AUTH_RESULT" | jq -r '.status')

if [[ "$AUTH_STATUS" != "ok" ]]; then
  echo "$AUTH_RESULT"
  exit 0
fi

# Fetch the issue
ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --json number,title,body,labels,state,url,author,assignees,createdAt,updatedAt 2>&1) || {
  jq -n --arg num "$ISSUE_NUMBER" --arg err "$ISSUE_JSON" '{
    status: "error",
    message: ("Failed to fetch issue #" + $num + ": " + $err)
  }'
  exit 0
}

# Validate we got JSON back
if ! echo "$ISSUE_JSON" | jq empty 2>/dev/null; then
  jq -n --arg num "$ISSUE_NUMBER" '{
    status: "error",
    message: ("Failed to parse issue #" + $num + " response as JSON.")
  }'
  exit 0
fi

# Check if issue is closed
ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state')
if [[ "$ISSUE_STATE" == "CLOSED" ]]; then
  jq -n --arg num "$ISSUE_NUMBER" '{
    status: "error",
    message: ("Issue #" + $num + " is closed. Only open issues can be fixed.")
  }'
  exit 0
fi

# Extract and restructure the issue data
echo "$ISSUE_JSON" | jq '{
  status: "fetched",
  issue_number: .number,
  title: .title,
  body: .body,
  labels: [.labels[].name],
  state: .state,
  url: .url,
  author: .author.login,
  assignees: [.assignees[].login],
  created_at: .createdAt,
  updated_at: .updatedAt
}'

exit 0
