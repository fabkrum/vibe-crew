#!/usr/bin/env bash
# scripts/import-issue-to-backlog.sh
# Import a GitHub issue into the VibeCrew backlog.
# Reads issue JSON from stdin (output of fetch-github-issue.sh).
# Flags: --full (use 6-phase feature cycle instead of hotfix)
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
BACKLOG_FILE="$VIBECREW_DIR/backlog.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Parse flags
FULL_MODE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --full) FULL_MODE=true; shift ;;
    *) shift ;;
  esac
done

# Read issue JSON from stdin
ISSUE_JSON=$(cat)

# Validate input is valid JSON
if ! echo "$ISSUE_JSON" | jq empty 2>/dev/null; then
  jq -n '{
    status: "error",
    message: "Invalid JSON input. Pipe the output of fetch-github-issue.sh."
  }'
  exit 0
fi

# Extract issue fields
ISSUE_STATUS=$(echo "$ISSUE_JSON" | jq -r '.status // "unknown"')
if [[ "$ISSUE_STATUS" != "fetched" ]]; then
  jq -n --arg status "$ISSUE_STATUS" '{
    status: "error",
    message: ("Expected issue status \"fetched\", got \"" + $status + "\". Pipe the output of fetch-github-issue.sh.")
  }'
  exit 0
fi

ISSUE_NUMBER=$(echo "$ISSUE_JSON" | jq -r '.issue_number')
ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title')
ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.body // ""')
ISSUE_URL=$(echo "$ISSUE_JSON" | jq -r '.url')
ISSUE_LABELS=$(echo "$ISSUE_JSON" | jq -c '.labels // []')

# Check if backlog exists
if [[ ! -f "$BACKLOG_FILE" ]]; then
  jq -n '{
    status: "error",
    message: "backlog.json not found. Run /setup first."
  }'
  exit 0
fi

# Deduplication: check if issue is already in the backlog
EXISTING=$(jq --argjson num "$ISSUE_NUMBER" \
  '[.features[] | select(.github_issue_number == $num)] | length' \
  "$BACKLOG_FILE" 2>/dev/null || echo "0")

if [[ "$EXISTING" -gt 0 ]]; then
  EXISTING_ID=$(jq -r --argjson num "$ISSUE_NUMBER" \
    '[.features[] | select(.github_issue_number == $num)][0].id' \
    "$BACKLOG_FILE" 2>/dev/null || echo "unknown")
  jq -n --arg id "$EXISTING_ID" --argjson num "$ISSUE_NUMBER" '{
    status: "duplicate",
    message: ("Issue #" + ($num | tostring) + " already exists in backlog as " + $id),
    feature_id: $id,
    issue_number: $num
  }'
  exit 0
fi

# Determine mode: check for enhancement/feature-request labels or --full flag
IS_ENHANCEMENT=false
if [[ "$FULL_MODE" == "true" ]]; then
  IS_ENHANCEMENT=true
else
  if echo "$ISSUE_LABELS" | jq -e 'map(ascii_downcase) | any(. == "enhancement" or . == "feature-request" or . == "feature")' >/dev/null 2>&1; then
    IS_ENHANCEMENT=true
  fi
fi

if [[ "$IS_ENHANCEMENT" == "true" ]]; then
  COLUMN="idea"
  TYPE="feature"
else
  COLUMN="planned"
  TYPE="hotfix"
fi

# Generate next feature ID
LAST_ID=$(jq -r '[.features[].id] | map(ltrimstr("feat-") | tonumber) | max // 0' "$BACKLOG_FILE" 2>/dev/null || echo "0")
NEXT_NUM=$((LAST_ID + 1))
FEATURE_ID=$(printf "feat-%03d" "$NEXT_NUM")

# Extract acceptance criteria from checkbox items in the issue body (best-effort)
ACCEPTANCE_CRITERIA=$(echo "$ISSUE_BODY" | { grep -E '^\s*-\s*\[[ x]\]' || true; } | sed 's/^\s*-\s*\[[ x]\]\s*//' | jq -R -s 'split("\n") | map(select(length > 0))' 2>/dev/null || echo '[]')
# If no checkboxes found, use empty array
if [[ "$ACCEPTANCE_CRITERIA" == "[]" ]] || [[ -z "$ACCEPTANCE_CRITERIA" ]]; then
  ACCEPTANCE_CRITERIA='[]'
fi

# Build the backlog entry as a jq expression
bash "$SCRIPT_DIR/update-backlog-raw.sh" \
  '.features += [$entry]' \
  --argjson entry "$(jq -n \
    --arg id "$FEATURE_ID" \
    --arg name "$ISSUE_TITLE" \
    --arg desc "$ISSUE_BODY" \
    --arg column "$COLUMN" \
    --arg type "$TYPE" \
    --argjson issue_num "$ISSUE_NUMBER" \
    --arg issue_url "$ISSUE_URL" \
    --argjson criteria "$ACCEPTANCE_CRITERIA" \
    --arg ts "$TIMESTAMP" \
    '{
      id: $id,
      name: $name,
      description: $desc,
      column: $column,
      priority: 1,
      labels: ["github-issue"],
      spec: {
        problem_statement: $desc,
        acceptance_criteria: $criteria,
        ui_description: null,
        business_logic: [],
        technical_notes: null
      },
      source: "github-issue",
      type: $type,
      github_issue_number: $issue_num,
      github_issue_url: $issue_url,
      worktree: null,
      phases_completed: [],
      sessions: [],
      created_at: $ts,
      updated_at: $ts,
      completed_at: null
    }')" 2>&1

if [[ $? -ne 0 ]]; then
  jq -n --argjson num "$ISSUE_NUMBER" '{
    status: "error",
    message: ("Failed to add issue #" + ($num | tostring) + " to backlog.")
  }'
  exit 0
fi

# Output success
jq -n \
  --arg id "$FEATURE_ID" \
  --argjson num "$ISSUE_NUMBER" \
  --arg title "$ISSUE_TITLE" \
  --arg column "$COLUMN" \
  --arg type "$TYPE" \
  '{
    status: "imported",
    feature_id: $id,
    issue_number: $num,
    title: $title,
    column: $column,
    type: $type,
    message: ("Issue #" + ($num | tostring) + " imported as " + $id + " (" + $type + " → " + $column + ")")
  }'

exit 0
