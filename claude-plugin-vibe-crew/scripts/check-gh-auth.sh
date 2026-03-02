#!/usr/bin/env bash
# scripts/check-gh-auth.sh
# Validate provider CLI availability, authentication, and remote configuration.
# Supports GitHub (gh) and GitLab (glab) — auto-detected from git remote.
# Outputs JSON with status and details.
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/git-provider.sh"

PROVIDER=$(_provider_detect)
CLI=$(_provider_cli)

# --- Unknown provider ---
if [[ "$PROVIDER" == "unknown" ]]; then
  jq -n '{
    status: "error",
    check: "provider_detect",
    message: "Cannot detect git provider from remote URL. Set \"git_provider\" to \"github\" or \"gitlab\" in .vibecrew/config.json."
  }'
  exit 0
fi

# --- GitHub path ---
if [[ "$PROVIDER" == "github" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    jq -n '{
      status: "error",
      check: "gh_installed",
      message: "GitHub CLI (gh) not found. Install: https://cli.github.com/"
    }'
    exit 0
  fi

  if ! gh auth status >/dev/null 2>&1; then
    jq -n '{
      status: "error",
      check: "gh_authenticated",
      message: "GitHub CLI not authenticated. Run `gh auth login` first."
    }'
    exit 0
  fi

  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ -z "$REMOTE_URL" ]]; then
    jq -n '{
      status: "error",
      check: "git_remote",
      message: "No git remote found. Add a GitHub remote: git remote add origin <url>"
    }'
    exit 0
  fi

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

  jq -n --arg repo "$REPO" --arg remote "$REMOTE_URL" --arg provider "github" '{
    status: "ok",
    provider: $provider,
    repo: $repo,
    remote_url: $remote
  }'
  exit 0
fi

# --- GitLab path ---
if [[ "$PROVIDER" == "gitlab" ]]; then
  if ! command -v glab >/dev/null 2>&1; then
    jq -n '{
      status: "error",
      check: "glab_installed",
      message: "GitLab CLI (glab) not found. Install: https://gitlab.com/gitlab-org/cli"
    }'
    exit 0
  fi

  if ! glab auth status >/dev/null 2>&1; then
    jq -n '{
      status: "error",
      check: "glab_authenticated",
      message: "GitLab CLI not authenticated. Run `glab auth login` first."
    }'
    exit 0
  fi

  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ -z "$REMOTE_URL" ]]; then
    jq -n '{
      status: "error",
      check: "git_remote",
      message: "No git remote found. Add a GitLab remote: git remote add origin <url>"
    }'
    exit 0
  fi

  REPO=$(glab repo view --output json 2>/dev/null | jq -r '.full_name // .path_with_namespace // empty' 2>/dev/null || echo "")
  if [[ -z "$REPO" ]]; then
    jq -n --arg remote "$REMOTE_URL" '{
      status: "error",
      check: "repo_access",
      message: "Cannot access GitLab repository. Check your remote URL and permissions.",
      remote_url: $remote
    }'
    exit 0
  fi

  jq -n --arg repo "$REPO" --arg remote "$REMOTE_URL" --arg provider "gitlab" '{
    status: "ok",
    provider: $provider,
    repo: $repo,
    remote_url: $remote
  }'
  exit 0
fi

exit 0
