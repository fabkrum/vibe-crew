#!/usr/bin/env bash
# scripts/read-profile.sh
# Universal profile reader — outputs user_profile as JSON to stdout.
# Falls back to balanced defaults if no profile exists or fields are missing.
# Called by all profile-aware agents (single bash call, ~500 tokens).
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"

DEFAULTS='{
  "interview_completed": false,
  "role": null,
  "code_literacy": "conversational",
  "autonomy": "checkpoints",
  "pr_review": "review",
  "verbosity": "standard",
  "gamification_preference": "full",
  "learning": "reference_docs",
  "risk_tolerance": "balanced",
  "updated_at": null
}'

if [[ -f "$CONFIG_FILE" ]]; then
  PROFILE=$(jq -r '.user_profile // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
  if [[ -n "$PROFILE" && "$PROFILE" != "null" ]]; then
    # Merge stored profile over defaults so missing fields get filled
    echo "$DEFAULTS" | jq --argjson stored "$PROFILE" '. * $stored'
    exit 0
  fi
fi

# No config or no profile — return defaults
echo "$DEFAULTS"
exit 0
