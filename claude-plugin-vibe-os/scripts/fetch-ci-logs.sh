#!/usr/bin/env bash
# scripts/fetch-ci-logs.sh
# Fetch the latest failed CI run logs using gh CLI.
# Outputs JSON with run info and truncated log.
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

# Check if gh CLI is available
if ! command -v gh >/dev/null 2>&1; then
  echo '{"status": "error", "message": "GitHub CLI (gh) not found. Install: https://cli.github.com/"}'
  exit 0
fi

# Check if gh is authenticated
if ! gh auth status >/dev/null 2>&1; then
  echo '{"status": "error", "message": "GitHub CLI not authenticated. Run gh auth login first."}'
  exit 0
fi

# Get the latest failed run
FAILED_RUN=$(gh run list --status=failure --limit=1 --json databaseId,displayTitle,conclusion,headBranch,createdAt 2>/dev/null || echo "[]")

# Check if any failed runs were found
if [ "$FAILED_RUN" = "[]" ] || [ -z "$FAILED_RUN" ]; then
  echo '{"status": "no_failures", "message": "No failed CI runs found."}'
  exit 0
fi

# Parse run details
RUN_ID=$(echo "$FAILED_RUN" | jq -r '.[0].databaseId // empty')
TITLE=$(echo "$FAILED_RUN" | jq -r '.[0].displayTitle // "unknown"')
BRANCH=$(echo "$FAILED_RUN" | jq -r '.[0].headBranch // "unknown"')
CREATED_AT=$(echo "$FAILED_RUN" | jq -r '.[0].createdAt // "unknown"')

# Validate that we got a run ID
if [ -z "$RUN_ID" ]; then
  echo '{"status": "error", "message": "Failed to parse CI run details from gh output."}'
  exit 0
fi

# Fetch the failed run logs (only failed steps)
RAW_LOG=$(gh run view "$RUN_ID" --log-failed 2>/dev/null || echo "")

if [ -z "$RAW_LOG" ]; then
  # Fallback: try fetching full log if --log-failed returns nothing
  RAW_LOG=$(gh run view "$RUN_ID" --log 2>/dev/null || echo "")
fi

if [ -z "$RAW_LOG" ]; then
  echo "{\"status\": \"error\", \"message\": \"Failed to fetch logs for run $RUN_ID.\"}"
  exit 0
fi

# Truncate to last 500 lines (the most relevant part of the log)
TRUNCATED_LOG=$(echo "$RAW_LOG" | tail -n 500)
LOG_LINES=$(echo "$TRUNCATED_LOG" | wc -l | tr -d ' ')
TOTAL_LINES=$(echo "$RAW_LOG" | wc -l | tr -d ' ')

# Escape the log for JSON embedding (handle special characters)
ESCAPED_LOG=$(echo "$TRUNCATED_LOG" | jq -Rs '.')

# Output structured JSON
jq -n \
  --arg status "fetched" \
  --argjson run_id "$RUN_ID" \
  --arg title "$TITLE" \
  --arg branch "$BRANCH" \
  --arg created_at "$CREATED_AT" \
  --argjson log_lines "$LOG_LINES" \
  --argjson total_lines "$TOTAL_LINES" \
  --argjson log "$ESCAPED_LOG" \
  '{
    status: $status,
    run_id: $run_id,
    title: $title,
    branch: $branch,
    created_at: $created_at,
    log_lines: $log_lines,
    total_lines: $total_lines,
    truncated: ($total_lines > 500),
    log: $log
  }'

exit 0
