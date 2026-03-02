#!/usr/bin/env bash
# scripts/fetch-ci-logs.sh
# Fetch the latest failed CI run logs using the provider CLI (gh or glab).
# Outputs JSON with run info and truncated log.
# Exit 0 always — errors are reported in the JSON output.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/git-provider.sh"

PROVIDER=$(_provider_detect)
CLI=$(_provider_cli)

# Check if provider CLI is available
if [[ -z "$CLI" ]]; then
  echo '{"status": "error", "message": "Cannot detect git provider. Set \"git_provider\" in .vibecrew/config.json."}'
  exit 0
fi

if ! command -v "$CLI" >/dev/null 2>&1; then
  echo "{\"status\": \"error\", \"message\": \"Provider CLI ($CLI) not found. Install it first.\"}"
  exit 0
fi

# Check if CLI is authenticated
if [[ "$PROVIDER" == "github" ]]; then
  if ! gh auth status >/dev/null 2>&1; then
    echo '{"status": "error", "message": "GitHub CLI not authenticated. Run gh auth login first."}'
    exit 0
  fi
elif [[ "$PROVIDER" == "gitlab" ]]; then
  if ! glab auth status >/dev/null 2>&1; then
    echo '{"status": "error", "message": "GitLab CLI not authenticated. Run glab auth login first."}'
    exit 0
  fi
fi

# --- GitHub path ---
if [[ "$PROVIDER" == "github" ]]; then
  FAILED_RUN=$(gh run list --status=failure --limit=1 --json databaseId,displayTitle,conclusion,headBranch,createdAt 2>/dev/null || echo "[]")

  if [ "$FAILED_RUN" = "[]" ] || [ -z "$FAILED_RUN" ]; then
    echo '{"status": "no_failures", "message": "No failed CI runs found."}'
    exit 0
  fi

  RUN_ID=$(echo "$FAILED_RUN" | jq -r '.[0].databaseId // empty')
  TITLE=$(echo "$FAILED_RUN" | jq -r '.[0].displayTitle // "unknown"')
  BRANCH=$(echo "$FAILED_RUN" | jq -r '.[0].headBranch // "unknown"')
  CREATED_AT=$(echo "$FAILED_RUN" | jq -r '.[0].createdAt // "unknown"')

  if [ -z "$RUN_ID" ]; then
    echo '{"status": "error", "message": "Failed to parse CI run details from gh output."}'
    exit 0
  fi

  RAW_LOG=$(gh run view "$RUN_ID" --log-failed 2>/dev/null || echo "")
  if [ -z "$RAW_LOG" ]; then
    RAW_LOG=$(gh run view "$RUN_ID" --log 2>/dev/null || echo "")
  fi

  if [ -z "$RAW_LOG" ]; then
    echo "{\"status\": \"error\", \"message\": \"Failed to fetch logs for run $RUN_ID.\"}"
    exit 0
  fi

  TRUNCATED_LOG=$(echo "$RAW_LOG" | tail -n 500)
  LOG_LINES=$(echo "$TRUNCATED_LOG" | wc -l | tr -d ' ')
  TOTAL_LINES=$(echo "$RAW_LOG" | wc -l | tr -d ' ')
  ESCAPED_LOG=$(echo "$TRUNCATED_LOG" | jq -Rs '.')

  jq -n \
    --arg status "fetched" \
    --arg provider "github" \
    --argjson run_id "$RUN_ID" \
    --arg title "$TITLE" \
    --arg branch "$BRANCH" \
    --arg created_at "$CREATED_AT" \
    --argjson log_lines "$LOG_LINES" \
    --argjson total_lines "$TOTAL_LINES" \
    --argjson log "$ESCAPED_LOG" \
    '{
      status: $status,
      provider: $provider,
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
fi

# --- GitLab path ---
if [[ "$PROVIDER" == "gitlab" ]]; then
  # Get the latest failed pipeline
  FAILED_PIPELINES=$(glab ci list --status failed --per-page 1 --output json 2>/dev/null || echo "[]")

  if [ "$FAILED_PIPELINES" = "[]" ] || [ -z "$FAILED_PIPELINES" ]; then
    echo '{"status": "no_failures", "message": "No failed CI pipelines found."}'
    exit 0
  fi

  PIPELINE_ID=$(echo "$FAILED_PIPELINES" | jq -r '.[0].id // empty')
  TITLE=$(echo "$FAILED_PIPELINES" | jq -r '.[0].ref // "unknown"')
  BRANCH=$(echo "$FAILED_PIPELINES" | jq -r '.[0].ref // "unknown"')
  CREATED_AT=$(echo "$FAILED_PIPELINES" | jq -r '.[0].created_at // "unknown"')

  if [ -z "$PIPELINE_ID" ]; then
    echo '{"status": "error", "message": "Failed to parse CI pipeline details from glab output."}'
    exit 0
  fi

  # Get pipeline details and find the failed job
  PIPELINE_JOBS=$(glab ci view "$PIPELINE_ID" --output json 2>/dev/null || echo "")
  FAILED_JOB_ID=""
  if [[ -n "$PIPELINE_JOBS" ]] && echo "$PIPELINE_JOBS" | jq empty 2>/dev/null; then
    FAILED_JOB_ID=$(echo "$PIPELINE_JOBS" | jq -r '[.jobs[]? | select(.status == "failed")] | .[0].id // empty' 2>/dev/null || echo "")
  fi

  RAW_LOG=""
  if [[ -n "$FAILED_JOB_ID" ]]; then
    RAW_LOG=$(glab ci trace "$FAILED_JOB_ID" 2>/dev/null || echo "")
  fi

  if [ -z "$RAW_LOG" ]; then
    echo "{\"status\": \"error\", \"message\": \"Failed to fetch logs for pipeline $PIPELINE_ID.\"}"
    exit 0
  fi

  TRUNCATED_LOG=$(echo "$RAW_LOG" | tail -n 500)
  LOG_LINES=$(echo "$TRUNCATED_LOG" | wc -l | tr -d ' ')
  TOTAL_LINES=$(echo "$RAW_LOG" | wc -l | tr -d ' ')
  ESCAPED_LOG=$(echo "$TRUNCATED_LOG" | jq -Rs '.')

  jq -n \
    --arg status "fetched" \
    --arg provider "gitlab" \
    --argjson run_id "$PIPELINE_ID" \
    --arg title "Pipeline on $TITLE" \
    --arg branch "$BRANCH" \
    --arg created_at "$CREATED_AT" \
    --argjson log_lines "$LOG_LINES" \
    --argjson total_lines "$TOTAL_LINES" \
    --argjson log "$ESCAPED_LOG" \
    '{
      status: $status,
      provider: $provider,
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
fi

echo '{"status": "error", "message": "Unknown git provider. Cannot fetch CI logs."}'
exit 0
