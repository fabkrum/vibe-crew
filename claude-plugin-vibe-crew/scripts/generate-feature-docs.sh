#!/usr/bin/env bash
# scripts/generate-feature-docs.sh
# Reads backlog.json, generates markdown feature docs from specs + acceptance criteria.
# Creates docs/features/{feature-id}.md for each completed feature without existing docs.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"
DOCS_DIR="$PROJECT_ROOT/docs/features"

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "No backlog.json found. Skipping feature doc generation."
  exit 0
fi

# Create docs directory if needed
mkdir -p "$DOCS_DIR"

# Find completed features (done or review column)
COMPLETED=$(jq -r '.features[] | select(.column == "done" or .column == "review") | .id' "$BACKLOG_FILE" 2>/dev/null || echo "")

if [[ -z "$COMPLETED" ]]; then
  echo "No completed features found. Skipping."
  exit 0
fi

GENERATED=0

while IFS= read -r feature_id; do
  [[ -z "$feature_id" ]] && continue

  # Check if doc already exists
  DOC_FILE="$DOCS_DIR/${feature_id}.md"
  if [[ -f "$DOC_FILE" ]]; then
    continue
  fi

  # Extract feature data
  FEATURE_JSON=$(jq --arg id "$feature_id" '.features[] | select(.id == $id)' "$BACKLOG_FILE" 2>/dev/null)
  if [[ -z "$FEATURE_JSON" ]]; then
    continue
  fi

  NAME=$(echo "$FEATURE_JSON" | jq -r '.name // "Unnamed Feature"')
  DESCRIPTION=$(echo "$FEATURE_JSON" | jq -r '.spec.description // "No description provided."')
  PROBLEM=$(echo "$FEATURE_JSON" | jq -r '.spec.problem_statement // ""')
  PRIORITY=$(echo "$FEATURE_JSON" | jq -r '.priority // "medium"')
  LABELS=$(echo "$FEATURE_JSON" | jq -r '.labels // [] | join(", ")')
  CREATED_AT=$(echo "$FEATURE_JSON" | jq -r '.created_at // ""')

  # Extract acceptance criteria
  CRITERIA=$(echo "$FEATURE_JSON" | jq -r '.spec.acceptance_criteria // [] | .[] | "- [ ] \(.)"' 2>/dev/null || echo "")

  # Get related commits
  COMMITS=""
  BRANCH_NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  if command -v git &>/dev/null; then
    COMMITS=$(git log --oneline --all --grep="$feature_id" 2>/dev/null || \
              git log --oneline --all --grep="$BRANCH_NAME" 2>/dev/null || echo "")
  fi

  # Get sessions that worked on this feature
  SESSIONS=$(echo "$FEATURE_JSON" | jq -r '.sessions // [] | .[] // empty' 2>/dev/null || echo "")

  # Generate doc
  cat > "$DOC_FILE.tmp" << DOC_EOF
# $NAME

$DESCRIPTION

## Details

- **Feature ID**: $feature_id
- **Priority**: $PRIORITY
- **Labels**: $LABELS
- **Created**: $CREATED_AT

DOC_EOF

  if [[ -n "$PROBLEM" ]]; then
    cat >> "$DOC_FILE.tmp" << DOC_EOF
## Problem Statement

$PROBLEM

DOC_EOF
  fi

  cat >> "$DOC_FILE.tmp" << DOC_EOF
## Acceptance Criteria

$CRITERIA

DOC_EOF

  if [[ -n "$COMMITS" ]]; then
    cat >> "$DOC_FILE.tmp" << DOC_EOF
## Commits

\`\`\`
$COMMITS
\`\`\`

DOC_EOF
  fi

  if [[ -n "$SESSIONS" ]]; then
    echo "## Sessions" >> "$DOC_FILE.tmp"
    echo "" >> "$DOC_FILE.tmp"
    echo "$SESSIONS" | while IFS= read -r sid; do
      [[ -z "$sid" ]] && continue
      echo "- $sid" >> "$DOC_FILE.tmp"
    done
    echo "" >> "$DOC_FILE.tmp"
  fi

  mv "$DOC_FILE.tmp" "$DOC_FILE"
  ((GENERATED++))
  echo "Generated: $DOC_FILE"
done <<< "$COMPLETED"

echo "Feature docs generated: $GENERATED"
exit 0
