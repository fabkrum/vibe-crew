#!/usr/bin/env bash
# scripts/save-profile.sh
# Writes user profile into .vibecrew/config.json under user_profile key.
# Syncs dependent gamification config based on gamification_preference.
# Uses atomic temp-file-then-mv pattern.
# Exit 0 on success, Exit 1 on failure.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Parse flags ---
ROLE=""
CODE_LITERACY=""
AUTONOMY=""
PR_REVIEW=""
VERBOSITY=""
GAMIFICATION=""
LEARNING=""
RISK_TOLERANCE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --role) ROLE="$2"; shift 2 ;;
    --code-literacy) CODE_LITERACY="$2"; shift 2 ;;
    --autonomy) AUTONOMY="$2"; shift 2 ;;
    --pr-review) PR_REVIEW="$2"; shift 2 ;;
    --verbosity) VERBOSITY="$2"; shift 2 ;;
    --gamification) GAMIFICATION="$2"; shift 2 ;;
    --learning) LEARNING="$2"; shift 2 ;;
    --risk-tolerance) RISK_TOLERANCE="$2"; shift 2 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done

# --- Validate config exists ---
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Error: $CONFIG_FILE not found. Run /setup first." >&2
  exit 1
fi

# --- Build profile JSON ---
PROFILE=$(jq -n \
  --arg role "$ROLE" \
  --arg code_literacy "$CODE_LITERACY" \
  --arg autonomy "$AUTONOMY" \
  --arg pr_review "$PR_REVIEW" \
  --arg verbosity "$VERBOSITY" \
  --arg gamification "$GAMIFICATION" \
  --arg learning "$LEARNING" \
  --arg risk_tolerance "$RISK_TOLERANCE" \
  --arg updated_at "$TIMESTAMP" \
  '{
    interview_completed: true,
    role: (if $role == "" then null else $role end),
    code_literacy: (if $code_literacy == "" then "conversational" else $code_literacy end),
    autonomy: (if $autonomy == "" then "checkpoints" else $autonomy end),
    pr_review: (if $pr_review == "" then "review" else $pr_review end),
    verbosity: (if $verbosity == "" then "standard" else $verbosity end),
    gamification_preference: (if $gamification == "" then "full" else $gamification end),
    learning: (if $learning == "" then "reference_docs" else $learning end),
    risk_tolerance: (if $risk_tolerance == "" then "balanced" else $risk_tolerance end),
    updated_at: $updated_at
  }')

# --- Write profile to config.json ---
TMP="${CONFIG_FILE}.tmp.$$"
jq --argjson profile "$PROFILE" '.user_profile = $profile' "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"

# --- Sync gamification config based on preference ---
case "$GAMIFICATION" in
  disabled)
    jq '.gamification.enabled = false | .gamification.show_xp_in_status = false | .gamification.streak_reminders = false' \
      "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    ;;
  score_only)
    jq '.gamification.enabled = true | .gamification.show_xp_in_status = false | .gamification.streak_reminders = false' \
      "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    ;;
  light)
    jq '.gamification.enabled = true | .gamification.show_xp_in_status = true | .gamification.streak_reminders = false' \
      "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    ;;
  full|"")
    jq '.gamification.enabled = true | .gamification.show_xp_in_status = true | .gamification.streak_reminders = true' \
      "$CONFIG_FILE" > "$TMP" && mv "$TMP" "$CONFIG_FILE"
    ;;
esac

echo "Profile saved to $CONFIG_FILE"
echo "  Role:              ${ROLE:-not set}"
echo "  Code literacy:     ${CODE_LITERACY:-conversational}"
echo "  Autonomy:          ${AUTONOMY:-checkpoints}"
echo "  PR review:         ${PR_REVIEW:-review}"
echo "  Verbosity:         ${VERBOSITY:-standard}"
echo "  Gamification:      ${GAMIFICATION:-full}"
echo "  Learning:          ${LEARNING:-reference_docs}"
echo "  Risk tolerance:    ${RISK_TOLERANCE:-balanced}"

exit 0
