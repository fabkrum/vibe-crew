#!/usr/bin/env bash
# scripts/check-gh-auth.sh
# Validate GitHub CLI availability, authentication, and remote configuration.
# Outputs JSON with status and details.
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

# Check if gh CLI is available
if ! command -v gh >/dev/null 2>&1; then
  jq -n '{
    status: "error",
    check: "gh_installed",
    message: "GitHub CLI (gh) not found. Install: https://cli.github.com/"
  }'
  exit 0
fi

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
  jq -n '{
    status: "error",
    check: "gh_authenticated",
    message: "GitHub CLI not authenticated. Run `gh auth login` first."
  }'
  exit 0
fi

# Check if the current directory has a git remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [[ -z "$REMOTE_URL" ]]; then
  jq -n '{
    status: "error",
    check: "git_remote",
    message: "No git remote found. Add a GitHub remote: git remote add origin <url>"
  }'
  exit 0
fi

# Extract owner/repo from remote URL
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
if [[ -z "$REPO" ]]; then
  jq -n --arg remote "$REMOTE_URL" '{
    status: "error",
    check: "repo_access",
    message: "Cannot access GitHub repository. Check your remote URL and permissions.",
    remote_url: $remote
  }'
  exit 0
fi

# All checks passed
jq -n --arg repo "$REPO" --arg remote "$REMOTE_URL" '{
  status: "ok",
  repo: $repo,
  remote_url: $remote
}'

exit 0
