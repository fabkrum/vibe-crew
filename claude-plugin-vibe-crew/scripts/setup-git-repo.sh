#!/usr/bin/env bash
# scripts/setup-git-repo.sh
# Initialize git repository and optionally create a remote on GitHub/GitLab.
# Called by /setup skill (Step 7: Git Repository Setup).
# Interface: setup-git-repo.sh --provider <github|gitlab|local> [--visibility <public|private>] [--repo-name <name>]
# Output: JSON to stdout
# Exit: 0 on success, 1 on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/git-provider.sh"

# --- Parse arguments ---
PROVIDER=""
VISIBILITY="private"
REPO_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider)   PROVIDER="$2"; shift 2 ;;
    --visibility) VISIBILITY="$2"; shift 2 ;;
    --repo-name)  REPO_NAME="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$PROVIDER" ]]; then
  jq -n '{status: "error", message: "Missing required --provider argument. Usage: setup-git-repo.sh --provider <github|gitlab|local>"}'
  exit 1
fi

if [[ "$PROVIDER" != "github" && "$PROVIDER" != "gitlab" && "$PROVIDER" != "local" ]]; then
  jq -n --arg p "$PROVIDER" '{status: "error", message: ("Invalid provider: " + $p + ". Must be github, gitlab, or local.")}'
  exit 1
fi

# --- Resolve project root ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"

# Default repo name to directory name
if [[ -z "$REPO_NAME" ]]; then
  REPO_NAME="$(basename "$PROJECT_ROOT")"
fi

# --- Helper: update config.json git_provider ---
_update_config_provider() {
  local provider="$1"
  local config_file="$VIBECREW_DIR/config.json"
  if [[ -f "$config_file" ]]; then
    local tmp="${config_file}.tmp"
    jq --arg p "$provider" '.git_provider = $p' "$config_file" > "$tmp" && mv "$tmp" "$config_file"
  fi
}

# --- Helper: update state.json git.initialized ---
_update_state_git_initialized() {
  local state_file="$VIBECREW_DIR/state.json"
  if [[ -f "$state_file" ]]; then
    local tmp="${state_file}.tmp"
    jq '.git.initialized = true' "$state_file" > "$tmp" && mv "$tmp" "$state_file"
  fi
}

# --- Check for existing repo with remote ---
HAS_GIT=false
HAS_REMOTE=false
REMOTE_URL=""

if git rev-parse --is-inside-work-tree &>/dev/null; then
  HAS_GIT=true
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ -n "$REMOTE_URL" ]]; then
    HAS_REMOTE=true
  fi
fi

# --- Case 1: Existing repo WITH remote → auto-detect, store, done ---
if [[ "$HAS_GIT" == true && "$HAS_REMOTE" == true ]]; then
  DETECTED=$(_provider_detect)
  _update_config_provider "$DETECTED"
  _update_state_git_initialized

  REPO_INFO=""
  if [[ "$DETECTED" == "github" ]] && command -v gh &>/dev/null; then
    REPO_INFO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "")
  elif [[ "$DETECTED" == "gitlab" ]] && command -v glab &>/dev/null; then
    REPO_INFO=$(glab repo view --output json 2>/dev/null | jq -r '.full_name // .path_with_namespace // empty' 2>/dev/null || echo "")
  fi

  jq -n \
    --arg action "detected_existing" \
    --arg provider "$DETECTED" \
    --arg remote "$REMOTE_URL" \
    --arg repo "$REPO_INFO" \
    '{status: "ok", action: $action, provider: $provider, remote_url: $remote, repo: $repo}'
  exit 0
fi

# --- Case 2: No remote (or no repo) → initialize ---

# Initialize git if needed
if [[ "$HAS_GIT" == false ]]; then
  git init --initial-branch=main "$PROJECT_ROOT" >/dev/null 2>&1
fi

# --- Provider-specific remote creation ---
if [[ "$PROVIDER" == "github" ]]; then
  # Validate gh CLI
  if ! command -v gh &>/dev/null; then
    jq -n '{status: "error", check: "gh_installed", message: "GitHub CLI (gh) not found. Install: https://cli.github.com/"}'
    exit 1
  fi

  if ! gh auth status &>/dev/null 2>&1; then
    jq -n '{status: "error", check: "gh_authenticated", message: "GitHub CLI not authenticated. Run `gh auth login` first."}'
    exit 1
  fi

  # Build visibility flag
  VIS_FLAG="--private"
  if [[ "$VISIBILITY" == "public" ]]; then
    VIS_FLAG="--public"
  fi

  # Create repo
  if ! gh repo create "$REPO_NAME" $VIS_FLAG --source=. --remote=origin --push &>/dev/null; then
    jq -n --arg name "$REPO_NAME" '{status: "error", check: "repo_create", message: ("Failed to create GitHub repository: " + $name + ". It may already exist.")}'
    exit 1
  fi

  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  REPO_INFO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null || echo "$REPO_NAME")

  _update_config_provider "github"
  _update_state_git_initialized

  jq -n \
    --arg action "created" \
    --arg provider "github" \
    --arg remote "$REMOTE_URL" \
    --arg repo "$REPO_INFO" \
    --arg visibility "$VISIBILITY" \
    '{status: "ok", action: $action, provider: $provider, remote_url: $remote, repo: $repo, visibility: $visibility}'
  exit 0

elif [[ "$PROVIDER" == "gitlab" ]]; then
  # Validate glab CLI
  if ! command -v glab &>/dev/null; then
    jq -n '{status: "error", check: "glab_installed", message: "GitLab CLI (glab) not found. Install: https://gitlab.com/gitlab-org/cli"}'
    exit 1
  fi

  if ! glab auth status &>/dev/null 2>&1; then
    jq -n '{status: "error", check: "glab_authenticated", message: "GitLab CLI not authenticated. Run `glab auth login` first."}'
    exit 1
  fi

  # Build visibility flag
  VIS_FLAG="--private"
  if [[ "$VISIBILITY" == "public" ]]; then
    VIS_FLAG="--public"
  fi

  # Create repo — glab repo create works differently from gh
  if ! glab repo create "$REPO_NAME" $VIS_FLAG &>/dev/null; then
    jq -n --arg name "$REPO_NAME" '{status: "error", check: "repo_create", message: ("Failed to create GitLab repository: " + $name + ". It may already exist.")}'
    exit 1
  fi

  # glab repo create may not set up the remote automatically — check and add
  REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
  if [[ -z "$REMOTE_URL" ]]; then
    # Try to determine the URL from glab
    REPO_INFO=$(glab repo view --output json 2>/dev/null | jq -r '.web_url // empty' 2>/dev/null || echo "")
    if [[ -n "$REPO_INFO" ]]; then
      git remote add origin "${REPO_INFO}.git" 2>/dev/null || true
      REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    fi
  fi

  # Make initial commit and push
  git add -A &>/dev/null || true
  git commit -m "chore: initialize project" --allow-empty &>/dev/null || true
  git push -u origin main &>/dev/null || true

  REPO_INFO=$(glab repo view --output json 2>/dev/null | jq -r '.full_name // .path_with_namespace // empty' 2>/dev/null || echo "$REPO_NAME")

  _update_config_provider "gitlab"
  _update_state_git_initialized

  jq -n \
    --arg action "created" \
    --arg provider "gitlab" \
    --arg remote "$REMOTE_URL" \
    --arg repo "$REPO_INFO" \
    --arg visibility "$VISIBILITY" \
    '{status: "ok", action: $action, provider: $provider, remote_url: $remote, repo: $repo, visibility: $visibility}'
  exit 0

elif [[ "$PROVIDER" == "local" ]]; then
  # Local only — make initial commit
  git add -A &>/dev/null || true
  git commit -m "chore: initialize project" --allow-empty &>/dev/null || true

  _update_config_provider "local"
  _update_state_git_initialized

  jq -n '{status: "ok", action: "created", provider: "local", remote_url: "", repo: ""}'
  exit 0
fi
