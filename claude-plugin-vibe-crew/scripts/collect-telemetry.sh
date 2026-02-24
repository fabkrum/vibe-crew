#!/usr/bin/env bash
# scripts/collect-telemetry.sh
# Reads all registered projects from project-registry.json,
# collects anonymized performance data, and aggregates into telemetry/aggregate.json.
# Exit 0 on success, Exit 1 on failure.

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
REGISTRY="$PLUGIN_ROOT/project-registry.json"
TELEMETRY_DIR="$PLUGIN_ROOT/telemetry"
OUTPUT="$TELEMETRY_DIR/aggregate.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

mkdir -p "$TELEMETRY_DIR"

# --- Check registry ---
if [[ ! -f "$REGISTRY" ]]; then
  cat <<EOF
{
  "schema_version": "1.0.0",
  "collected_at": "$TIMESTAMP",
  "project_count": 0,
  "projects": [],
  "aggregates": {
    "total_sessions": 0,
    "avg_vibe_score_all": 0,
    "most_common_deductions": [],
    "least_used_skills": [],
    "least_used_agents": [],
    "avg_cost_per_session": 0,
    "mcp_adoption": {}
  }
}
EOF
  exit 0
fi

PROJECT_COUNT=$(jq '.projects | length' "$REGISTRY" 2>/dev/null || echo 0)

if [[ "$PROJECT_COUNT" -eq 0 ]]; then
  cat <<EOF
{
  "schema_version": "1.0.0",
  "collected_at": "$TIMESTAMP",
  "project_count": 0,
  "projects": [],
  "aggregates": {
    "total_sessions": 0,
    "avg_vibe_score_all": 0,
    "most_common_deductions": [],
    "least_used_skills": [],
    "least_used_agents": [],
    "avg_cost_per_session": 0,
    "mcp_adoption": {}
  }
}
EOF
  exit 0
fi

# --- Collect data from each project ---
PROJECTS_JSON="[]"
TOTAL_SESSIONS=0
TOTAL_SCORE_SUM=0
TOTAL_SCORE_COUNT=0
TOTAL_COST_SUM=0
ALL_DEDUCTIONS=""
ALL_AGENTS=""
ALL_SKILLS=""
ALL_MCP=""

for i in $(seq 0 $((PROJECT_COUNT - 1))); do
  PROJECT_PATH=$(jq -r ".projects[$i].path" "$REGISTRY")
  PROJECT_ALIAS=$(jq -r ".projects[$i].alias" "$REGISTRY")
  VIBECREW_DIR="$PROJECT_PATH/.vibecrew"

  # Skip if project's .vibecrew doesn't exist
  if [[ ! -d "$VIBECREW_DIR" ]]; then
    continue
  fi

  # --- Session count ---
  SESSION_COUNT=0
  if [[ -d "$VIBECREW_DIR/sessions" ]]; then
    SESSION_COUNT=$(find "$VIBECREW_DIR/sessions" -name "session-*.json" -type f 2>/dev/null | wc -l | tr -d ' ')
  fi
  TOTAL_SESSIONS=$((TOTAL_SESSIONS + SESSION_COUNT))

  # --- Vibe Score average ---
  AVG_SCORE=0
  if [[ -d "$VIBECREW_DIR/scores" ]]; then
    SCORE_FILES=$(find "$VIBECREW_DIR/scores" -name "score-*.json" -type f 2>/dev/null)
    if [[ -n "$SCORE_FILES" ]]; then
      SCORE_SUM=0
      SCORE_COUNT=0
      while IFS= read -r sf; do
        SCORE=$(jq -r '.score // 0' "$sf" 2>/dev/null || echo 0)
        SCORE_SUM=$((SCORE_SUM + SCORE))
        SCORE_COUNT=$((SCORE_COUNT + 1))
      done <<< "$SCORE_FILES"
      if [[ "$SCORE_COUNT" -gt 0 ]]; then
        AVG_SCORE=$((SCORE_SUM / SCORE_COUNT))
        TOTAL_SCORE_SUM=$((TOTAL_SCORE_SUM + SCORE_SUM))
        TOTAL_SCORE_COUNT=$((TOTAL_SCORE_COUNT + SCORE_COUNT))
      fi
    fi
  fi

  # --- Top deductions ---
  TOP_DEDUCTIONS="[]"
  if [[ -d "$VIBECREW_DIR/scores" ]]; then
    DEDUCTION_CATS=$(find "$VIBECREW_DIR/scores" -name "score-*.json" -type f -exec jq -r '.deductions[]?.category // empty' {} + 2>/dev/null | sort | uniq -c | sort -rn | head -3 | awk '{print $2}')
    if [[ -n "$DEDUCTION_CATS" ]]; then
      TOP_DEDUCTIONS=$(echo "$DEDUCTION_CATS" | jq -R . | jq -s .)
      ALL_DEDUCTIONS="$ALL_DEDUCTIONS $DEDUCTION_CATS"
    fi
  fi

  # --- Top bonuses ---
  TOP_BONUSES="[]"
  if [[ -d "$VIBECREW_DIR/scores" ]]; then
    BONUS_CATS=$(find "$VIBECREW_DIR/scores" -name "score-*.json" -type f -exec jq -r '.bonuses[]?.category // empty' {} + 2>/dev/null | sort | uniq -c | sort -rn | head -3 | awk '{print $2}')
    if [[ -n "$BONUS_CATS" ]]; then
      TOP_BONUSES=$(echo "$BONUS_CATS" | jq -R . | jq -s .)
    fi
  fi

  # --- Context usage average ---
  AVG_CONTEXT=0
  if [[ -d "$VIBECREW_DIR/sessions" ]]; then
    CTX_DATA=$(find "$VIBECREW_DIR/sessions" -name "session-*.json" -type f -exec jq -r '.context.peak_usage_percent // empty' {} + 2>/dev/null)
    if [[ -n "$CTX_DATA" ]]; then
      CTX_SUM=0
      CTX_COUNT=0
      while IFS= read -r c; do
        CTX_SUM=$((CTX_SUM + c))
        CTX_COUNT=$((CTX_COUNT + 1))
      done <<< "$CTX_DATA"
      if [[ "$CTX_COUNT" -gt 0 ]]; then
        AVG_CONTEXT=$((CTX_SUM / CTX_COUNT))
      fi
    fi
  fi

  # --- Average session cost ---
  AVG_COST="0"
  if [[ -d "$VIBECREW_DIR/sessions" ]]; then
    COST_DATA=$(find "$VIBECREW_DIR/sessions" -name "session-*.json" -type f -exec jq -r '.tokens.estimated_cost_usd // empty' {} + 2>/dev/null)
    if [[ -n "$COST_DATA" ]]; then
      # Use awk for floating point
      AVG_COST=$(echo "$COST_DATA" | awk '{s+=$1; c++} END {if(c>0) printf "%.2f", s/c; else print "0"}')
      COST_TOTAL=$(echo "$COST_DATA" | awk '{s+=$1} END {printf "%.2f", s}')
      TOTAL_COST_SUM=$(echo "$TOTAL_COST_SUM + $COST_TOTAL" | bc 2>/dev/null || echo "$TOTAL_COST_SUM")
    fi
  fi

  # --- Agent usage ---
  AGENT_USAGE="{}"
  if [[ -d "$VIBECREW_DIR/sessions" ]]; then
    AGENT_DATA=$(find "$VIBECREW_DIR/sessions" -name "session-*.json" -type f -exec jq -r '.agents[]?.agent // empty' {} + 2>/dev/null | sort | uniq -c | sort -rn)
    if [[ -n "$AGENT_DATA" ]]; then
      AGENT_USAGE=$(echo "$AGENT_DATA" | awk '{printf "\"%s\": %s,", $2, $1}' | sed 's/,$//' | sed 's/^/{/' | sed 's/$/}/')
      ALL_AGENTS="$ALL_AGENTS $(echo "$AGENT_DATA" | awk '{print $2}')"
    fi
  fi

  # --- MCP servers enabled ---
  MCP_ENABLED="[]"
  if [[ -f "$VIBECREW_DIR/config.json" ]]; then
    MCP_ENABLED=$(jq '[.mcp_servers // {} | to_entries[] | select(.value == true) | .key]' "$VIBECREW_DIR/config.json" 2>/dev/null || echo '[]')
    MCP_LIST=$(echo "$MCP_ENABLED" | jq -r '.[]' 2>/dev/null || true)
    ALL_MCP="$ALL_MCP $MCP_LIST"
  fi

  # --- Mutations ---
  MUTATIONS_PROPOSED=0
  MUTATIONS_APPLIED=0
  if [[ -f "$VIBECREW_DIR/mutation-log.json" ]]; then
    MUTATIONS_PROPOSED=$(jq '[.mutations // []] | length' "$VIBECREW_DIR/mutation-log.json" 2>/dev/null || echo 0)
    MUTATIONS_APPLIED=$(jq '[(.mutations // [])[] | select(.status == "applied")] | length' "$VIBECREW_DIR/mutation-log.json" 2>/dev/null || echo 0)
  fi

  # --- Test pass rate ---
  TEST_PASS_RATE="0"
  AVG_COVERAGE=0
  if [[ -d "$VIBECREW_DIR/sessions" ]]; then
    TEST_DATA=$(find "$VIBECREW_DIR/sessions" -name "session-*.json" -type f -exec jq -r 'select(.tests.ran == true) | "\(.tests.passed) \(.tests.total) \(.tests.coverage_percent // 0)"' {} + 2>/dev/null)
    if [[ -n "$TEST_DATA" ]]; then
      TEST_PASS_RATE=$(echo "$TEST_DATA" | awk '{p+=$1; t+=$2} END {if(t>0) printf "%.2f", p/t; else print "0"}')
      AVG_COVERAGE=$(echo "$TEST_DATA" | awk '{s+=$3; c++} END {if(c>0) printf "%d", s/c; else print "0"}')
    fi
  fi

  # --- Features completed ---
  FEATURES_COMPLETED=0
  if [[ -f "$VIBECREW_DIR/../.vibecrew/backlog.json" ]] || [[ -f "$PROJECT_PATH/.vibecrew/backlog.json" ]]; then
    BACKLOG="$PROJECT_PATH/.vibecrew/backlog.json"
    if [[ -f "$BACKLOG" ]]; then
      FEATURES_COMPLETED=$(jq '[.features[] | select(.column == "done")] | length' "$BACKLOG" 2>/dev/null || echo 0)
    fi
  fi

  # --- Terminal ---
  TERMINAL="unknown"
  if [[ -f "$VIBECREW_DIR/config.json" ]]; then
    TERMINAL=$(jq -r '.terminal // "unknown"' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "unknown")
  fi

  # --- Build project JSON ---
  PROJECT_JSON=$(cat <<PROJ
{
  "alias": "$PROJECT_ALIAS",
  "session_count": $SESSION_COUNT,
  "avg_vibe_score": $AVG_SCORE,
  "top_deductions": $TOP_DEDUCTIONS,
  "top_bonuses": $TOP_BONUSES,
  "avg_context_usage": $AVG_CONTEXT,
  "avg_session_cost_usd": $AVG_COST,
  "agent_usage": $AGENT_USAGE,
  "mcp_servers_enabled": $MCP_ENABLED,
  "mutations_proposed": $MUTATIONS_PROPOSED,
  "mutations_applied": $MUTATIONS_APPLIED,
  "test_pass_rate": $TEST_PASS_RATE,
  "avg_coverage": $AVG_COVERAGE,
  "features_completed": $FEATURES_COMPLETED,
  "terminal": "$TERMINAL"
}
PROJ
)

  PROJECTS_JSON=$(echo "$PROJECTS_JSON" | jq --argjson p "$PROJECT_JSON" '. += [$p]')
done

# --- Compute aggregates ---
AVG_SCORE_ALL=0
if [[ "$TOTAL_SCORE_COUNT" -gt 0 ]]; then
  AVG_SCORE_ALL=$((TOTAL_SCORE_SUM / TOTAL_SCORE_COUNT))
fi

AVG_COST_ALL="0"
if [[ "$TOTAL_SESSIONS" -gt 0 ]]; then
  AVG_COST_ALL=$(echo "$TOTAL_COST_SUM / $TOTAL_SESSIONS" | bc -l 2>/dev/null | xargs printf "%.2f" 2>/dev/null || echo "0")
fi

# --- Most common deductions ---
COMMON_DEDUCTIONS="[]"
if [[ -n "$ALL_DEDUCTIONS" ]]; then
  COMMON_DEDUCTIONS=$(echo "$ALL_DEDUCTIONS" | tr ' ' '\n' | grep -v '^$' | sort | uniq -c | sort -rn | head -5 | awk '{printf "{\"category\": \"%s\", \"count\": %s},", $2, $1}' | sed 's/,$//' | sed 's/^/[/' | sed 's/$/]/')
fi

# --- MCP adoption ---
MCP_ADOPTION="{}"
if [[ -n "$ALL_MCP" ]]; then
  MCP_ADOPTION=$(echo "$ALL_MCP" | tr ' ' '\n' | grep -v '^$' | sort | uniq -c | sort -rn | awk '{printf "\"%s\": %s,", $2, $1}' | sed 's/,$//' | sed 's/^/{/' | sed 's/$/}/')
fi

# --- Build aggregate JSON ---
ACTUAL_PROJECT_COUNT=$(echo "$PROJECTS_JSON" | jq 'length')

RESULT=$(cat <<AGG
{
  "schema_version": "1.0.0",
  "collected_at": "$TIMESTAMP",
  "project_count": $ACTUAL_PROJECT_COUNT,
  "projects": $PROJECTS_JSON,
  "aggregates": {
    "total_sessions": $TOTAL_SESSIONS,
    "avg_vibe_score_all": $AVG_SCORE_ALL,
    "most_common_deductions": $COMMON_DEDUCTIONS,
    "least_used_skills": [],
    "least_used_agents": [],
    "avg_cost_per_session": $AVG_COST_ALL,
    "mcp_adoption": $MCP_ADOPTION
  }
}
AGG
)

# Write to file and stdout
echo "$RESULT" | jq . > "$OUTPUT.tmp" && mv "$OUTPUT.tmp" "$OUTPUT"
echo "$RESULT" | jq .

exit 0
