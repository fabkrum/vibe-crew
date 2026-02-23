#!/usr/bin/env bash
# scripts/extract-workflow.sh
# Parse session logs → extract phase order, commit patterns, quality thresholds
# Usage: extract-workflow.sh <workflow-name> [session-file...]
# If no session files specified, uses the most recent session with score >= 70
# Exit 0 always

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SESSIONS_DIR="$PROJECT_ROOT/.vibeos/sessions"
SCORES_DIR="$PROJECT_ROOT/.vibeos/scores"
WORKFLOWS_DIR="$PROJECT_ROOT/.vibeos/workflows"

# --- Validate arguments ---
WORKFLOW_NAME="${1:-}"

if [[ -z "$WORKFLOW_NAME" ]]; then
  echo '{"error": "Missing workflow name. Usage: extract-workflow.sh <name> [session-file...]"}' >&2
  exit 0
fi

# Normalize name to kebab-case: lowercase, replace spaces/underscores with hyphens
WORKFLOW_NAME=$(echo "$WORKFLOW_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[_ ]/-/g' | sed 's/[^a-z0-9-]//g')

shift
SESSION_FILES=("$@")

# --- Helper: safe jq with fallback ---
safe_jq() {
  local file="$1" query="$2" default="$3"
  if [[ -f "$file" ]]; then
    jq -r "$query" "$file" 2>/dev/null || echo "$default"
  else
    echo "$default"
  fi
}

# --- Find eligible sessions if none specified ---
if [[ ${#SESSION_FILES[@]} -eq 0 ]]; then
  # Find the most recent score file with score >= 70
  ELIGIBLE_SCORE_FILE=""
  ELIGIBLE_SESSION_ID=""

  for score_file in $(ls -1t "$SCORES_DIR"/score-*.json 2>/dev/null | head -20); do
    [[ ! -f "$score_file" ]] && continue
    score=$(safe_jq "$score_file" '.score // 0' "0")
    if [[ "$score" -ge 70 ]]; then
      ELIGIBLE_SCORE_FILE="$score_file"
      ELIGIBLE_SESSION_ID=$(safe_jq "$score_file" '.session_id // "unknown"' "unknown")
      break
    fi
  done

  if [[ -z "$ELIGIBLE_SCORE_FILE" ]]; then
    echo '{"error": "No sessions found with Vibe Score >= 70"}' >&2
    exit 0
  fi

  # Find the matching session log
  if [[ -d "$SESSIONS_DIR" && -n "$ELIGIBLE_SESSION_ID" ]]; then
    MATCHING_SESSION="$SESSIONS_DIR/${ELIGIBLE_SESSION_ID}.json"
    if [[ -f "$MATCHING_SESSION" ]]; then
      SESSION_FILES=("$MATCHING_SESSION")
    fi
  fi
fi

# --- Extract data from session(s) and score(s) ---
PHASES_FOUND="[]"
FILES_MODIFIED_COUNT=0
TEST_STRATEGY="unknown"
COMMIT_PREFIXES="[]"
SOURCE_SESSIONS="[]"
FINAL_SCORE=0
DEDUCTIONS="[]"
BONUSES="[]"
DESCRIPTION=""

for session_file in "${SESSION_FILES[@]}"; do
  [[ ! -f "$session_file" ]] && continue

  session_id=$(safe_jq "$session_file" '.session_id // "unknown"' "unknown")
  SOURCE_SESSIONS=$(echo "$SOURCE_SESSIONS" | jq --arg sid "$session_id" '. + [$sid]')

  # Extract files modified count
  file_count=$(safe_jq "$session_file" '.files_modified | length // 0' "0")
  FILES_MODIFIED_COUNT=$(( FILES_MODIFIED_COUNT + file_count ))

  # Extract test strategy from session data
  tests_ran=$(safe_jq "$session_file" '.tests.ran // false' "false")
  if [[ "$tests_ran" == "true" ]]; then
    TEST_STRATEGY="active"
  fi

  # Extract commit message prefixes (conventional commit types)
  commits=$(jq -c '.commits // []' "$session_file" 2>/dev/null || echo "[]")
  prefixes=$(echo "$commits" | jq -r '[.[].message // "" | capture("^(?<type>[a-z]+)") | .type] | unique' 2>/dev/null || echo "[]")
  COMMIT_PREFIXES=$(echo "$COMMIT_PREFIXES $prefixes" | jq -s 'add | unique' 2>/dev/null || echo "[]")

  # Find the matching score file for this session
  score_file=""
  if [[ -d "$SCORES_DIR" ]]; then
    for sf in "$SCORES_DIR"/score-*.json; do
      [[ ! -f "$sf" ]] && continue
      sf_session=$(safe_jq "$sf" '.session_id // ""' "")
      if [[ "$sf_session" == "$session_id" ]]; then
        score_file="$sf"
        break
      fi
    done
  fi

  # If no exact match, try using the most recent score file
  if [[ -z "$score_file" && -n "$ELIGIBLE_SCORE_FILE" ]]; then
    score_file="$ELIGIBLE_SCORE_FILE"
  fi

  if [[ -n "$score_file" && -f "$score_file" ]]; then
    FINAL_SCORE=$(safe_jq "$score_file" '.score // 0' "0")
    DEDUCTIONS=$(jq -c '.deductions // []' "$score_file" 2>/dev/null || echo "[]")
    BONUSES=$(jq -c '.bonuses // []' "$score_file" 2>/dev/null || echo "[]")

    # Extract phases from score file metrics
    PHASES_FOUND=$(jq -c '[.metrics.phases // {} | to_entries[] | select(.value == true) | .key]' "$score_file" 2>/dev/null || echo "[]")
  fi
done

# --- Determine phase order ---
# Default to the standard 5-phase order, filtered to phases actually completed
DEFAULT_ORDER='["plan","design","code","test","docs"]'
PHASE_COUNT=$(echo "$PHASES_FOUND" | jq 'length' 2>/dev/null || echo "0")

if [[ "$PHASE_COUNT" -eq 0 ]]; then
  # No phase data available; use the default full order
  PHASE_ORDER="$DEFAULT_ORDER"
else
  # Preserve the canonical order for phases that were completed
  PHASE_ORDER=$(jq -n --argjson found "$PHASES_FOUND" --argjson order "$DEFAULT_ORDER" \
    '[$order[] | select(. as $p | $found | index($p))]')
fi

# --- Determine test strategy details ---
UNIT_FRAMEWORK="vitest"
E2E_FRAMEWORK="playwright"
MIN_COVERAGE=80

# Check project package.json for actual test frameworks
if [[ -f "$PROJECT_ROOT/package.json" ]]; then
  has_vitest=$(jq -r '.devDependencies.vitest // .dependencies.vitest // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
  has_jest=$(jq -r '.devDependencies.jest // .dependencies.jest // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
  has_playwright=$(jq -r '.devDependencies["@playwright/test"] // .dependencies["@playwright/test"] // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")
  has_cypress=$(jq -r '.devDependencies.cypress // .dependencies.cypress // empty' "$PROJECT_ROOT/package.json" 2>/dev/null || echo "")

  if [[ -n "$has_jest" && -z "$has_vitest" ]]; then
    UNIT_FRAMEWORK="jest"
  fi
  if [[ -n "$has_cypress" && -z "$has_playwright" ]]; then
    E2E_FRAMEWORK="cypress"
  fi
fi

# --- Determine commit convention ---
COMMIT_CONVENTION="conventional"
prefix_count=$(echo "$COMMIT_PREFIXES" | jq 'length' 2>/dev/null || echo "0")
if [[ "$prefix_count" -eq 0 ]]; then
  COMMIT_CONVENTION="conventional"
fi

# --- Determine required phases from score deductions ---
# If a session scored well, its completed phases are the required ones
REQUIRED_PHASES='["plan","code","test"]'
if [[ "$PHASE_COUNT" -ge 3 ]]; then
  REQUIRED_PHASES="$PHASES_FOUND"
fi

# --- Build description ---
DESCRIPTION="Workflow extracted from ${#SESSION_FILES[@]} session(s) with Vibe Score $FINAL_SCORE"

# --- Compose workflow JSON ---
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

WORKFLOW_JSON=$(jq -n \
  --arg schema "1.3.0" \
  --arg name "$WORKFLOW_NAME" \
  --arg desc "$DESCRIPTION" \
  --arg ts "$TIMESTAMP" \
  --argjson sources "$SOURCE_SESSIONS" \
  --argjson phase_order "$PHASE_ORDER" \
  --arg branch "feat/{{feature-name}}" \
  --arg unit "$UNIT_FRAMEWORK" \
  --arg e2e "$E2E_FRAMEWORK" \
  --argjson min_cov "$MIN_COVERAGE" \
  --argjson min_score 70 \
  --argjson required "$REQUIRED_PHASES" \
  --argjson max_churn 3 \
  --arg commit_conv "$COMMIT_CONVENTION" \
  --argjson final_score "$FINAL_SCORE" \
  --argjson files_count "$FILES_MODIFIED_COUNT" \
  '{
    schema_version: $schema,
    name: $name,
    description: $desc,
    created_at: $ts,
    source_sessions: $sources,
    phase_order: $phase_order,
    branch_convention: $branch,
    test_strategy: {
      unit_framework: $unit,
      e2e_framework: $e2e,
      min_coverage: $min_cov
    },
    quality_thresholds: {
      min_vibe_score: $min_score,
      required_phases: $required,
      max_prompt_churn: $max_churn
    },
    commit_convention: $commit_conv,
    extraction_metadata: {
      source_score: $final_score,
      files_modified_count: $files_count
    }
  }')

# --- Write workflow file atomically ---
mkdir -p "$WORKFLOWS_DIR"

WORKFLOW_FILE="$WORKFLOWS_DIR/workflow-${WORKFLOW_NAME}.json"
TEMP_FILE="${WORKFLOW_FILE}.tmp"

echo "$WORKFLOW_JSON" > "$TEMP_FILE"
mv "$TEMP_FILE" "$WORKFLOW_FILE"

# --- Output the JSON to stdout ---
echo "$WORKFLOW_JSON"

exit 0
