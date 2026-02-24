#!/usr/bin/env bash
# scripts/git-branch-create.sh
# Creates feature branches with sanitized names following project conventions.
# Used by /new-feature to set up the working branch.
# Usage: git-branch-create.sh "Feature Name Here"
# Output: JSON object to stdout

set -euo pipefail

# --- Validate arguments ---
if [[ $# -lt 1 || -z "${1:-}" ]]; then
  jq -n '{
    error: true,
    message: "Usage: git-branch-create.sh \"Feature Name Here\""
  }' >&2
  exit 1
fi

FEATURE_NAME="$1"

# --- Verify git repo ---
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  jq -n '{
    error: true,
    message: "Not a git repository. Run git init first."
  }'
  exit 1
fi

# --- Sanitize branch name ---
BRANCH_NAME="$FEATURE_NAME"

# Convert to lowercase
BRANCH_NAME=$(echo "$BRANCH_NAME" | tr '[:upper:]' '[:lower:]')

# Replace spaces and underscores with hyphens
BRANCH_NAME=$(echo "$BRANCH_NAME" | tr ' _' '--')

# Remove all characters that aren't alphanumeric or hyphens
BRANCH_NAME=$(echo "$BRANCH_NAME" | tr -cd 'a-z0-9-')

# Collapse multiple consecutive hyphens into one
BRANCH_NAME=$(echo "$BRANCH_NAME" | sed 's/-\{2,\}/-/g')

# Trim leading/trailing hyphens
BRANCH_NAME=$(echo "$BRANCH_NAME" | sed 's/^-//;s/-$//')

# Truncate to 50 characters
BRANCH_NAME="${BRANCH_NAME:0:50}"

# Trim trailing hyphen again (truncation might expose one)
BRANCH_NAME=$(echo "$BRANCH_NAME" | sed 's/-$//')

# Prefix with feat/
BRANCH_NAME="feat/${BRANCH_NAME}"

# --- Check for uncommitted changes that would be lost ---
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
  # There are staged or unstaged changes
  # Check if checkout would fail (conflicting changes)
  if git stash --dry-run &>/dev/null 2>&1; then
    : # Changes exist but stash would work -- we can still warn
  fi

  # Check if the target branch exists; if switching branches, changes might conflict
  if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
    # Branch exists and there are uncommitted changes -- warn
    jq -n \
      --arg branch "$BRANCH_NAME" \
      '{
        error: true,
        message: "Uncommitted changes detected. Commit or stash your changes before switching branches.",
        branch: $branch
      }'
    exit 1
  fi
fi

# --- Create or checkout branch ---
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME" 2>/dev/null; then
  # Branch already exists -- check it out
  git checkout "$BRANCH_NAME" &>/dev/null

  jq -n \
    --arg branch "$BRANCH_NAME" \
    '{
      branch: $branch,
      action: "checkout",
      existed: true
    }'
else
  # Create new branch from current HEAD and check it out
  git checkout -b "$BRANCH_NAME" &>/dev/null

  jq -n \
    --arg branch "$BRANCH_NAME" \
    '{
      branch: $branch,
      action: "created",
      existed: false
    }'
fi
