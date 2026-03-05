#!/usr/bin/env bash
# scripts/prepare-feature-context.sh
# Assembles feature spec + TDR + architecture + design system + CLAUDE.md + profile
# into stdout (~500-800 lines) for the Agent prompt during /run-backlog fresh-session execution.
# Usage: prepare-feature-context.sh <feature-id>
# Exit 0 on success, Exit 1 on missing feature

set -euo pipefail

FEATURE_ID="${1:-}"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"

if [[ -z "$FEATURE_ID" ]]; then
  echo "Usage: prepare-feature-context.sh <feature-id>" >&2
  exit 1
fi

if [[ ! -f "$BACKLOG_FILE" ]]; then
  echo "Error: backlog.json not found" >&2
  exit 1
fi

# Verify feature exists
FEATURE_EXISTS=$(jq --arg id "$FEATURE_ID" '[.features[] | select(.id == $id)] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
if [[ "$FEATURE_EXISTS" -eq 0 ]]; then
  echo "Error: Feature $FEATURE_ID not found in backlog" >&2
  exit 1
fi

# --- Output structured context ---
cat <<'HEADER'
# Feature Execution Context

> This is a fresh-session execution context for the Builder agent.
> Run Plan → Design → Code → Test phases autonomously.
> Call `complete-phase.sh` after each phase.
> Do NOT run Review or Docs — the orchestrator handles those.
HEADER

echo ""
echo "## Feature Spec"
echo ""
jq --arg id "$FEATURE_ID" '.features[] | select(.id == $id)' "$BACKLOG_FILE" 2>/dev/null

echo ""
echo "## TDR (Technology Decision Record)"
echo ""
# Find TDR file
TDR_FILE=""
for candidate in "$PROJECT_ROOT/docs/tdr.md" "$PROJECT_ROOT/TDR.md" "$PROJECT_ROOT/docs/TDR.md"; do
  if [[ -f "$candidate" ]]; then
    TDR_FILE="$candidate"
    break
  fi
done
if [[ -n "$TDR_FILE" ]]; then
  head -200 "$TDR_FILE"
else
  echo "(TDR not found)"
fi

echo ""
echo "## Architecture Diagrams"
echo ""
if [[ -x "$SCRIPT_DIR/inject-architecture.sh" ]]; then
  bash "$SCRIPT_DIR/inject-architecture.sh" 2>/dev/null || echo "(architecture injection failed)"
fi

echo ""
echo "## Design System Tokens"
echo ""
DS_FILE=""
for candidate in "$PROJECT_ROOT/design-system.css" "$PROJECT_ROOT/src/styles/design-system.css"; do
  if [[ -f "$candidate" ]]; then
    DS_FILE="$candidate"
    break
  fi
done
if [[ -n "$DS_FILE" ]]; then
  head -50 "$DS_FILE"
  echo "... (truncated)"
else
  echo "(design-system.css not found)"
fi

echo ""
echo "## Project CLAUDE.md"
echo ""
if [[ -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
  head -200 "$PROJECT_ROOT/CLAUDE.md"
else
  echo "(CLAUDE.md not found)"
fi

echo ""
echo "## User Profile"
echo ""
if [[ -x "$SCRIPT_DIR/read-profile.sh" ]]; then
  bash "$SCRIPT_DIR/read-profile.sh" 2>/dev/null || echo "(profile not found)"
fi

echo ""
echo "## Agent Memory"
echo ""
if [[ -x "$SCRIPT_DIR/agent-memory-read.sh" ]]; then
  bash "$SCRIPT_DIR/agent-memory-read.sh" --agent "builder" --limit 10 2>/dev/null || echo "(no agent memory)"
fi

echo ""
echo "## Codebase Analysis"
echo ""
if [[ -x "$SCRIPT_DIR/inject-analysis.sh" ]]; then
  bash "$SCRIPT_DIR/inject-analysis.sh" 2>/dev/null || true
fi

# Plan staleness context (for Agent delegation)
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
PLAN_SHA=$(jq -r '.active_feature.plan_commit_sha // empty' "$STATE_FILE" 2>/dev/null)
if [[ -n "$PLAN_SHA" ]]; then
  echo ""
  echo "## Plan Commit SHA"
  echo "$PLAN_SHA"
  echo ""
  # Find plan file for this feature
  FEATURE_NAME=$(jq -r --arg id "$FEATURE_ID" '.features[] | select(.id == $id) | .name // empty' "$BACKLOG_FILE" 2>/dev/null)
  PLAN_DIR_NAME=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
  PLAN_FILE=""
  for candidate in "$PROJECT_ROOT/docs/features/$PLAN_DIR_NAME/plan.md" "$PROJECT_ROOT/docs/features/$FEATURE_ID/plan.md"; do
    if [[ -f "$candidate" ]]; then
      PLAN_FILE="$candidate"
      break
    fi
  done
  if [[ -n "$PLAN_FILE" ]]; then
    STALENESS=$(bash "$SCRIPT_DIR/check-plan-staleness.sh" "$PLAN_FILE" "$PLAN_SHA" 2>/dev/null || echo '{"stale": false}')
    STALE=$(echo "$STALENESS" | jq -r '.stale')
    if [[ "$STALE" == "true" ]]; then
      echo "## Plan Staleness Report"
      echo '```json'
      echo "$STALENESS" | jq '.'
      echo '```'
      echo ""
    fi
  fi
fi

echo ""
echo "## Git Context"
echo ""
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
echo "Branch: $GIT_BRANCH"
echo "Recent commits:"
git log --format="%h %s" -3 2>/dev/null || echo "  (no git history)"

echo ""
echo "## Phase Execution Instructions"
echo ""
cat <<'INSTRUCTIONS'
Execute these phases in order for the feature above:

1. **Plan**: Generate implementation plan with structured tasks. Write to `docs/features/{feature-name}/plan.md`. Run Clarify sub-step for standard/complex. Commit plan. Call `complete-phase.sh <feature-id> plan`.

2. **Design** (skip for trivial): Generate component design spec with ASCII wireframes. Write to `docs/features/{feature-name}/design.md`. Call `complete-phase.sh <feature-id> design`.

3. **Code**: Implement the feature following the plan's structured tasks. Use TDR-approved technologies only. Make atomic conventional commits. Run visual verification if frontend. Call `complete-phase.sh <feature-id> code`.

4. **Test**: Write tests for acceptance criteria. Run full test suite. Fix failures (max 3 retries). Call `complete-phase.sh <feature-id> test`.

If blocked: write `builder-blocked.signal`, commit WIP, stop.
Do NOT run Review or Docs — the orchestrator handles those.
INSTRUCTIONS

exit 0
