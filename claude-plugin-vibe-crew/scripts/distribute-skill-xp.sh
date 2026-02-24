#!/usr/bin/env bash
# scripts/distribute-skill-xp.sh
# Allocate XP to the 5 skill domains based on session metrics
# Skills: prompting, architecture, testing, context_management, workflow_discipline
# Skill levels: Novice(0) > Apprentice(50) > Practitioner(200) > Expert(600) > Master(1400)
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
GAMIFICATION_FILE="$VIBECREW_DIR/gamification.json"
STATE_FILE="$VIBECREW_DIR/state.json"

# --- Check gamification is enabled ---
ENABLED=$(jq -r '.gamification.enabled // true' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "true")
if [[ "$ENABLED" == "false" ]]; then
  echo '{"skills_updated":false,"message":"Gamification disabled"}'
  exit 0
fi

if [[ ! -f "$GAMIFICATION_FILE" ]]; then
  echo "Error: gamification.json not found." >&2
  exit 1
fi

# --- Find latest score file ---
LATEST_SCORE=""
if [[ -d "$VIBECREW_DIR/scores" ]]; then
  LATEST_SCORE=$(ls -1t "$VIBECREW_DIR/scores"/score-*.json 2>/dev/null | head -1)
fi

if [[ -z "$LATEST_SCORE" ]]; then
  echo '{"skills_updated":false,"message":"No score file found"}'
  exit 0
fi

# --- Read metrics from score file ---
VIBE_SCORE=$(jq -r '.score // 0' "$LATEST_SCORE")
CACHE_RATIO=$(jq -r '.metrics.tokens.cache_ratio // 0' "$LATEST_SCORE")
CHURN_SEQUENCES=$(jq -r '.metrics.prompt_churn.sequences // 0' "$LATEST_SCORE")
PEAK_CONTEXT=$(jq -r '.metrics.context.peak_usage_percent // 50' "$LATEST_SCORE")
TESTS_PASSED=$(jq -r '.metrics.quality.tests_passed // false' "$LATEST_SCORE")
COVERAGE=$(jq -r '.metrics.quality.coverage_percent // 0' "$LATEST_SCORE")
TOTAL_DEDUCTIONS=$(jq '[.deductions[].points] | map(. * -1) | add // 0' "$LATEST_SCORE")

# Read phase info
PHASES_COMPLETED=$(jq -r '.active_feature.phases_completed // []' "$STATE_FILE" 2>/dev/null || echo "[]")
HAS_PLAN=$(echo "$PHASES_COMPLETED" | jq 'map(select(. == "plan")) | length > 0')
HAS_TEST=$(echo "$PHASES_COMPLETED" | jq 'map(select(. == "test")) | length > 0')
HAS_DOCS=$(echo "$PHASES_COMPLETED" | jq 'map(select(. == "docs")) | length > 0')
FOUNDATION_COMPLETE=$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")
TDR_STATUS=$(jq -r '.foundation.artifacts.tdr.status // "pending"' "$STATE_FILE" 2>/dev/null || echo "pending")

# --- Calculate skill XP ---
XP_PROMPTING=0
XP_ARCHITECTURE=0
XP_TESTING=0
XP_CONTEXT=0
XP_WORKFLOW=0

# Prompting: Rewarded for low churn and high scores
if [[ "$CHURN_SEQUENCES" -eq 0 ]]; then
  XP_PROMPTING=$((XP_PROMPTING + 10))
fi
if [[ "$VIBE_SCORE" -ge 80 ]]; then
  XP_PROMPTING=$((XP_PROMPTING + 5))
fi
if [[ "$VIBE_SCORE" -ge 90 ]]; then
  XP_PROMPTING=$((XP_PROMPTING + 5))
fi

# Architecture: Rewarded for TDRs, foundation, specs, plan phases
if [[ "$TDR_STATUS" == "complete" ]]; then
  XP_ARCHITECTURE=$((XP_ARCHITECTURE + 5))
fi
if [[ "$FOUNDATION_COMPLETE" == "true" ]]; then
  XP_ARCHITECTURE=$((XP_ARCHITECTURE + 5))
fi
if [[ "$HAS_PLAN" == "true" ]]; then
  XP_ARCHITECTURE=$((XP_ARCHITECTURE + 10))
fi

# Testing: Rewarded for test coverage, TDD, first-pass tests
if [[ "$TESTS_PASSED" == "true" ]]; then
  XP_TESTING=$((XP_TESTING + 10))
fi
if [[ "$HAS_TEST" == "true" ]]; then
  XP_TESTING=$((XP_TESTING + 5))
fi
# Coverage bonus (awk for float comparison)
if awk "BEGIN{exit !($COVERAGE > 80)}"; then
  XP_TESTING=$((XP_TESTING + 10))
elif awk "BEGIN{exit !($COVERAGE > 50)}"; then
  XP_TESTING=$((XP_TESTING + 5))
fi

# Context Management: Rewarded for cache ratio, low context usage, Context7
if awk "BEGIN{exit !($CACHE_RATIO > 0.70)}"; then
  XP_CONTEXT=$((XP_CONTEXT + 15))
elif awk "BEGIN{exit !($CACHE_RATIO > 0.50)}"; then
  XP_CONTEXT=$((XP_CONTEXT + 8))
fi
if awk "BEGIN{exit !($PEAK_CONTEXT < 50)}"; then
  XP_CONTEXT=$((XP_CONTEXT + 10))
elif awk "BEGIN{exit !($PEAK_CONTEXT < 60)}"; then
  XP_CONTEXT=$((XP_CONTEXT + 5))
fi

# Workflow Discipline: Rewarded for phase completion, streaks, shipping
PHASE_COUNT=$(echo "$PHASES_COMPLETED" | jq 'length')
XP_WORKFLOW=$((XP_WORKFLOW + PHASE_COUNT * 3))
if [[ "$TOTAL_DEDUCTIONS" -eq 0 ]]; then
  XP_WORKFLOW=$((XP_WORKFLOW + 10))
fi
CURRENT_STREAK=$(jq -r '.streak.current // 0' "$GAMIFICATION_FILE")
if [[ "$CURRENT_STREAK" -ge 3 ]]; then
  XP_WORKFLOW=$((XP_WORKFLOW + 5))
fi

# --- Skill level thresholds ---
# Novice=0, Apprentice=50, Practitioner=200, Expert=600, Master=1400
calc_skill_level() {
  local xp=$1
  if [[ $xp -ge 1400 ]]; then echo 5     # Master (cap at max_level)
  elif [[ $xp -ge 600 ]]; then echo 4     # would be Expert but max is 5
  # Actually: Novice(0)=0, Apprentice(1)=50, Practitioner(2)=200, Expert(3)=600, Master(4)=1400
  # Max level is 5, so level 5 = Master
  else
    if [[ $xp -ge 1400 ]]; then echo 5
    elif [[ $xp -ge 600 ]]; then echo 4
    elif [[ $xp -ge 200 ]]; then echo 3
    elif [[ $xp -ge 50 ]]; then echo 2
    elif [[ $xp -gt 0 ]]; then echo 1
    else echo 0
    fi
  fi
}

# --- Apply skill XP and recalculate levels ---
SKILL_CHANGES="[]"

update_skill() {
  local skill_name="$1"
  local xp_add="$2"

  if [[ "$xp_add" -le 0 ]]; then return; fi

  local old_xp old_level new_xp new_level
  old_xp=$(jq -r ".skills.${skill_name}.xp // 0" "$GAMIFICATION_FILE")
  old_level=$(jq -r ".skills.${skill_name}.level // 0" "$GAMIFICATION_FILE")
  new_xp=$((old_xp + xp_add))
  new_level=$(calc_skill_level "$new_xp")

  # Cap level at max_level (5)
  local max_level
  max_level=$(jq -r ".skills.${skill_name}.max_level // 5" "$GAMIFICATION_FILE")
  if [[ "$new_level" -gt "$max_level" ]]; then
    new_level=$max_level
  fi

  # Update gamification.json
  TMP_FILE="${GAMIFICATION_FILE}.tmp"
  jq --arg skill "$skill_name" \
     --argjson xp "$new_xp" \
     --argjson level "$new_level" \
     '.skills[$skill].xp = $xp | .skills[$skill].level = $level' \
     "$GAMIFICATION_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$GAMIFICATION_FILE"

  # Record change for output
  local leveled_up="false"
  if [[ "$new_level" -gt "$old_level" ]]; then
    leveled_up="true"
  fi

  SKILL_CHANGES=$(echo "$SKILL_CHANGES" | jq \
    --arg name "$skill_name" \
    --argjson xp_added "$xp_add" \
    --argjson old_level "$old_level" \
    --argjson new_level "$new_level" \
    --argjson new_xp "$new_xp" \
    --argjson leveled_up "$leveled_up" \
    '. + [{"skill": $name, "xp_added": $xp_added, "old_level": $old_level, "new_level": $new_level, "total_xp": $new_xp, "leveled_up": $leveled_up}]')
}

update_skill "prompting" "$XP_PROMPTING"
update_skill "architecture" "$XP_ARCHITECTURE"
update_skill "testing" "$XP_TESTING"
update_skill "context_management" "$XP_CONTEXT"
update_skill "workflow_discipline" "$XP_WORKFLOW"

# --- Output result ---
TOTAL_SKILL_XP=$((XP_PROMPTING + XP_ARCHITECTURE + XP_TESTING + XP_CONTEXT + XP_WORKFLOW))
jq -n --argjson changes "$SKILL_CHANGES" --argjson total "$TOTAL_SKILL_XP" \
  '{skills_updated: true, total_skill_xp: $total, changes: $changes}'

exit 0
