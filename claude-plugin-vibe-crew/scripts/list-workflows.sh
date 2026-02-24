#!/usr/bin/env bash
# scripts/list-workflows.sh
# List .vibecrew/workflows/workflow-*.json with summaries
# Outputs JSON array of workflow summaries
# Exit 0 always

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
WORKFLOWS_DIR="$PROJECT_ROOT/.vibecrew/workflows"

# --- Check if workflows directory exists ---
if [[ ! -d "$WORKFLOWS_DIR" ]]; then
  echo "[]"
  exit 0
fi

# --- Find workflow files ---
WORKFLOW_FILES=$(ls -1t "$WORKFLOWS_DIR"/workflow-*.json 2>/dev/null || true)

if [[ -z "$WORKFLOW_FILES" ]]; then
  echo "[]"
  exit 0
fi

# --- Build summary array ---
SUMMARIES="[]"

while IFS= read -r file; do
  [[ -z "$file" ]] && continue
  [[ ! -f "$file" ]] && continue

  name=$(jq -r '.name // "unknown"' "$file" 2>/dev/null || echo "unknown")
  description=$(jq -r '.description // ""' "$file" 2>/dev/null || echo "")
  created_at=$(jq -r '.created_at // ""' "$file" 2>/dev/null || echo "")
  phase_count=$(jq -r '.phase_order | length // 0' "$file" 2>/dev/null || echo "0")
  min_score=$(jq -r '.quality_thresholds.min_vibe_score // 70' "$file" 2>/dev/null || echo "70")

  SUMMARIES=$(echo "$SUMMARIES" | jq \
    --arg name "$name" \
    --arg desc "$description" \
    --arg created "$created_at" \
    --argjson phases "$phase_count" \
    --argjson min_score "$min_score" \
    '. + [{
      name: $name,
      description: $desc,
      created_at: $created,
      phase_count: $phases,
      min_score: $min_score
    }]')

done <<< "$WORKFLOW_FILES"

# --- Output ---
echo "$SUMMARIES"

exit 0
