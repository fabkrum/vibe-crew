#!/usr/bin/env bash
# scripts/fetch-github-issue.sh
# Fetch a single issue by number using the provider CLI (gh or glab).
# Outputs structured JSON with issue details.
# Exit 0 always — errors are reported in the JSON output.
# Usage: fetch-github-issue.sh <issue-number>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/git-provider.sh"

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

PROVIDER=$(echo "$AUTH_RESULT" | jq -r '.provider // "github"')

# --- GitHub path ---
if [[ "$PROVIDER" == "github" ]]; then
  ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --json number,title,body,labels,state,url,author,assignees,createdAt,updatedAt 2>&1) || {
    jq -n --arg num "$ISSUE_NUMBER" --arg err "$ISSUE_JSON" '{
      status: "error",
      message: ("Failed to fetch issue #" + $num + ": " + $err)
    }'
    exit 0
  }

  if ! echo "$ISSUE_JSON" | jq empty 2>/dev/null; then
    jq -n --arg num "$ISSUE_NUMBER" '{
      status: "error",
      message: ("Failed to parse issue #" + $num + " response as JSON.")
    }'
    exit 0
  fi

  ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state')
  if [[ "$ISSUE_STATE" == "CLOSED" ]]; then
    jq -n --arg num "$ISSUE_NUMBER" '{
      status: "error",
      message: ("Issue #" + $num + " is closed. Only open issues can be fixed.")
    }'
    exit 0
  fi

  echo "$ISSUE_JSON" | jq --arg provider "github" '{
    status: "fetched",
    provider: $provider,
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
fi

# --- GitLab path ---
if [[ "$PROVIDER" == "gitlab" ]]; then
  ISSUE_JSON=$(glab issue view "$ISSUE_NUMBER" --output json 2>&1) || {
    jq -n --arg num "$ISSUE_NUMBER" --arg err "$ISSUE_JSON" '{
      status: "error",
      message: ("Failed to fetch issue #" + $num + ": " + $err)
    }'
    exit 0
  }

  if ! echo "$ISSUE_JSON" | jq empty 2>/dev/null; then
    jq -n --arg num "$ISSUE_NUMBER" '{
      status: "error",
      message: ("Failed to parse issue #" + $num + " response as JSON.")
    }'
    exit 0
  fi

  # Normalize GitLab state: "opened" → "OPEN", "closed" → "CLOSED"
  ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state')
  NORMALIZED_STATE="OPEN"
  if [[ "$ISSUE_STATE" == "closed" ]]; then
    NORMALIZED_STATE="CLOSED"
  fi

  if [[ "$NORMALIZED_STATE" == "CLOSED" ]]; then
    jq -n --arg num "$ISSUE_NUMBER" '{
      status: "error",
      message: ("Issue #" + $num + " is closed. Only open issues can be fixed.")
    }'
    exit 0
  fi

  echo "$ISSUE_JSON" | jq --arg provider "gitlab" --arg norm_state "$NORMALIZED_STATE" '{
    status: "fetched",
    provider: $provider,
    issue_number: .iid,
    title: .title,
    body: .description,
    labels: [.labels[]],
    state: $norm_state,
    url: .web_url,
    author: .author.username,
    assignees: [(.assignees // [])[] | .username],
    created_at: .created_at,
    updated_at: .updated_at
  }'
  exit 0
fi

# Unknown provider — shouldn't reach here if check-gh-auth.sh ran first
jq -n '{
  status: "error",
  message: "Unknown git provider. Cannot fetch issues."
}'
exit 0
