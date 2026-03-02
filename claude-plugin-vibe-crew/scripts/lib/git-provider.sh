#!/usr/bin/env bash
# scripts/lib/git-provider.sh
# Git hosting provider detection and helpers for GitHub/GitLab.
# Source from other scripts: source "$(dirname "$0")/lib/git-provider.sh"

# --- Detect git hosting provider ---
# Priority: (1) config.json override, (2) git remote URL, (3) "unknown"
# Usage: provider=$(_provider_detect)
_provider_detect() {
  # 1. Check config.json override
  local project_root
  project_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  local config_file="$project_root/.vibecrew/config.json"
  if [[ -f "$config_file" ]]; then
    local override
    override=$(jq -r '.git_provider // empty' "$config_file" 2>/dev/null)
    if [[ "$override" == "github" || "$override" == "gitlab" ]]; then
      echo "$override"
      return 0
    fi
  fi

  # 2. Detect from git remote URL
  local remote_url
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  case "$remote_url" in
    *github.com*)  echo "github"; return 0 ;;
    *gitlab.com*)  echo "gitlab"; return 0 ;;
    *gitlab.*)     echo "gitlab"; return 0 ;;  # self-hosted GitLab
  esac

  # 3. Fallback
  echo "unknown"
}

# --- Get provider CLI command ---
# Usage: cli=$(_provider_cli)
_provider_cli() {
  local provider
  provider=$(_provider_detect)
  case "$provider" in
    github) echo "gh" ;;
    gitlab) echo "glab" ;;
    *)      echo "" ;;
  esac
}

# --- Check if provider CLI is installed ---
# Usage: if _provider_cli_installed; then ...
_provider_cli_installed() {
  local cli
  cli=$(_provider_cli)
  [[ -n "$cli" ]] && command -v "$cli" &>/dev/null
}

# --- Get merge request terminology ---
# Usage: term=$(_provider_mr_term)
_provider_mr_term() {
  local provider
  provider=$(_provider_detect)
  case "$provider" in
    github) echo "PR" ;;
    gitlab) echo "MR" ;;
    *)      echo "PR" ;;
  esac
}

# --- Get close keyword for commit messages ---
# Usage: keyword=$(_provider_close_keyword)
_provider_close_keyword() {
  local provider
  provider=$(_provider_detect)
  case "$provider" in
    github) echo "Fixes" ;;
    gitlab) echo "Closes" ;;
    *)      echo "Fixes" ;;
  esac
}
