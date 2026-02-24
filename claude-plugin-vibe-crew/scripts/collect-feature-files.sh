#!/usr/bin/env bash
# scripts/collect-feature-files.sh
# Gather files changed on feature branch via git diff --name-only
# Outputs JSON array of file paths
# Exit 0 always

set -euo pipefail

# --- Detect project root ---
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# --- Read state.json for active feature and default branch ---
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "[]"
  exit 0
fi

ACTIVE_FEATURE=$(jq -r '.active_feature.id // empty' "$STATE_FILE" 2>/dev/null || echo "")
DEFAULT_BRANCH=$(jq -r '.git.default_branch // "main"' "$STATE_FILE" 2>/dev/null || echo "main")

# --- No active feature: output empty array ---
if [[ -z "$ACTIVE_FEATURE" ]]; then
  echo "[]"
  exit 0
fi

# --- Verify we are on a feature branch (not the default branch) ---
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "$DEFAULT_BRANCH" ]]; then
  echo "[]"
  exit 0
fi

# --- Verify the default branch exists locally or as remote ---
MERGE_BASE=""
if git rev-parse --verify "$DEFAULT_BRANCH" >/dev/null 2>&1; then
  MERGE_BASE=$(git merge-base "$DEFAULT_BRANCH" HEAD 2>/dev/null || echo "")
elif git rev-parse --verify "origin/$DEFAULT_BRANCH" >/dev/null 2>&1; then
  MERGE_BASE=$(git merge-base "origin/$DEFAULT_BRANCH" HEAD 2>/dev/null || echo "")
fi

if [[ -z "$MERGE_BASE" ]]; then
  echo "[]"
  exit 0
fi

# --- Get changed files relative to default branch ---
CHANGED_FILES=$(git diff --name-only "$MERGE_BASE"...HEAD 2>/dev/null || echo "")

if [[ -z "$CHANGED_FILES" ]]; then
  echo "[]"
  exit 0
fi

# --- Filter to source code files only ---
# Include: .ts, .tsx, .js, .jsx, .py, .rb, .go, .rs, .java, .kt, .swift, .php
# Include: .css, .scss, .sass ONLY if inside src/ or app/ or lib/ or components/
# Exclude: .json, .md, .yml, .yaml, .lock, .toml (config/docs)
# Exclude: files in node_modules/, dist/, build/, .vibecrew/, coverage/, .next/
is_source_file() {
  local file="$1"

  # Skip common non-source paths
  case "$file" in
    node_modules/*|dist/*|build/*|.vibecrew/*|coverage/*|.next/*|.git/*|vendor/*) return 1 ;;
  esac

  # Skip lockfiles, configs, and docs at any level
  case "$file" in
    *.lock|*.md|*.yml|*.yaml|*.toml|*.json|*.txt|*.log|*.env*) return 1 ;;
    *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.woff|*.woff2|*.ttf|*.eot) return 1 ;;
  esac

  # Allow CSS/SCSS only inside source directories
  case "$file" in
    *.css|*.scss|*.sass)
      case "$file" in
        src/*|app/*|lib/*|components/*|styles/*) return 0 ;;
        *) return 1 ;;
      esac
      ;;
  esac

  # Allow recognized source code extensions
  case "$file" in
    *.ts|*.tsx|*.js|*.jsx|*.py|*.rb|*.go|*.rs|*.java|*.kt|*.kts|*.swift|*.php|*.vue|*.svelte)
      return 0
      ;;
  esac

  return 1
}

FILTERED_FILES=""
while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  if is_source_file "$file"; then
    FILTERED_FILES="${FILTERED_FILES:+${FILTERED_FILES}
}${file}"
  fi
done <<< "$CHANGED_FILES"

# --- Convert to JSON array ---
if [[ -z "$FILTERED_FILES" ]]; then
  echo "[]"
  exit 0
fi

echo "$FILTERED_FILES" | jq -R -s 'split("\n") | map(select(length > 0))'

exit 0
