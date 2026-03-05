#!/usr/bin/env bash
# scripts/compact-reinject.sh
# SessionStart hook (compact matcher): re-injects state after context compaction
# Outputs a concise summary for the agent to resume work (<300 tokens)
# Exit 0 always (fail open)

set -euo pipefail

SCRIPT_DIR_CR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Source error logging
source "$SCRIPT_DIR_CR/lib/error-log.sh"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
BACKLOG_FILE="$PROJECT_ROOT/.vibecrew/backlog.json"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

# If state file doesn't exist, output minimal info and exit
if [[ ! -f "$STATE_FILE" ]]; then
  echo "VibeCrew state not initialized. Run /setup."
  exit 0
fi

echo "--- VibeCrew Context (re-injected after compaction) ---"

# ── Core state JSON (compact) with git branch ──
GIT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
jq -c --arg branch "$GIT_BRANCH" '{
  foundation_complete: .foundation.complete,
  active_feature: {id: .active_feature.id, name: .active_feature.name, phase: .active_feature.phase, worktree: .active_feature.worktree, phases_completed: .active_feature.phases_completed, plan_revision_count: (.active_feature.plan_revision_count // 0)},
  git_branch: $branch
}' "$STATE_FILE" 2>/dev/null || echo '{"error":"state.json unreadable"}'

# ── Foundation artifact status (only if foundation incomplete) ──
FOUNDATION_COMPLETE="$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")"
if [[ "$FOUNDATION_COMPLETE" != "true" ]]; then
  ARTIFACTS=("VISION.md" "design-system.css" "TDR.md" "architecture" "roadmap.md" "CLAUDE.md")
  complete=()
  pending=()
  for artifact in "${ARTIFACTS[@]}"; do
    if [[ "$artifact" == "architecture" ]]; then
      # Check for .mmd files in the architecture directory
      if ls "$PROJECT_ROOT/.vibecrew/architecture/"*.mmd &>/dev/null; then
        complete+=("Architecture Diagrams")
      else
        pending+=("Architecture Diagrams")
      fi
    elif [[ -f "$PROJECT_ROOT/$artifact" ]] || [[ -f "$PROJECT_ROOT/docs/$artifact" ]]; then
      complete+=("$artifact")
    else
      pending+=("$artifact")
    fi
  done
  echo "Tier 1 artifacts: done=[${complete[*]:-none}] pending=[${pending[*]:-none}]"
fi

# ── Backlog summary (human-readable instead of raw JSON) ──
if [[ -f "$BACKLOG_FILE" ]]; then
  TOTAL=$(jq '.features | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  PLANNED=$(jq '[.features[] | select(.column == "planned")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  IN_PROGRESS=$(jq '[.features[] | select(.column == "in-progress")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  TESTING=$(jq '[.features[] | select(.column == "testing")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  DONE=$(jq '[.features[] | select(.column == "done")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")
  BLOCKED=$(jq '[.features[] | select(.column == "blocked")] | length' "$BACKLOG_FILE" 2>/dev/null || echo "0")

  BY_COLUMN=""
  [[ "$PLANNED" -gt 0 ]] && BY_COLUMN="${BY_COLUMN}${PLANNED} planned, "
  [[ "$IN_PROGRESS" -gt 0 ]] && BY_COLUMN="${BY_COLUMN}${IN_PROGRESS} in-progress, "
  [[ "$TESTING" -gt 0 ]] && BY_COLUMN="${BY_COLUMN}${TESTING} testing, "
  [[ "$DONE" -gt 0 ]] && BY_COLUMN="${BY_COLUMN}${DONE} done, "
  [[ "$BLOCKED" -gt 0 ]] && BY_COLUMN="${BY_COLUMN}${BLOCKED} blocked, "
  BY_COLUMN="${BY_COLUMN%, }"

  echo "Backlog: $TOTAL total ($BY_COLUMN)"
fi

# ── Worktree status ──
WORKTREE_PATH="$(jq -r '.active_feature.worktree // empty' "$STATE_FILE" 2>/dev/null || true)"
if [[ -n "$WORKTREE_PATH" ]]; then
  if [[ -d "$WORKTREE_PATH" ]]; then
    WT_BRANCH="$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
    WT_DIRTY="$(git -C "$WORKTREE_PATH" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
    echo "Worktree: $WORKTREE_PATH (branch: $WT_BRANCH, dirty files: $WT_DIRTY)"
  else
    echo "Worktree: $WORKTREE_PATH (NOT FOUND - may need cleanup)"
  fi
fi

# ── CLAUDE.md summary ──
if [[ -f "$CLAUDE_MD" ]]; then
  LINE_COUNT="$(wc -l < "$CLAUDE_MD" | tr -d ' ')"
  SECTIONS="$(grep -E '^## ' "$CLAUDE_MD" 2>/dev/null | sed 's/^## //' | paste -sd ', ' - || echo "none")"
  echo "CLAUDE.md: ${LINE_COUNT} lines, sections: ${SECTIONS}"
fi

# ── Architecture diagrams (compact injection) ──
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INJECT_ARCH="$SCRIPT_DIR/inject-architecture.sh"
if [[ -x "$INJECT_ARCH" ]]; then
  bash "$INJECT_ARCH" 2>/dev/null || log_error "compact-reinject" "Architecture injection failed"
fi

# ── Expertise context (agent-agnostic top records) ──
EXPERTISE_PRIME="$SCRIPT_DIR_CR/expertise-prime.sh"
if [[ -x "$EXPERTISE_PRIME" ]]; then
  bash "$EXPERTISE_PRIME" --agent builder --max-tokens 500 2>/dev/null || true
fi

# ── Drift tracker summary (if warnings emitted) ──
DRIFT_FILE="$PROJECT_ROOT/.vibecrew/drift-tracker.json"
if [[ -f "$DRIFT_FILE" ]]; then
  DRIFT_WARNINGS=$(jq -r '.warnings.soft_count // 0' "$DRIFT_FILE" 2>/dev/null || echo "0")
  if [[ "$DRIFT_WARNINGS" -gt 0 ]]; then
    DRIFT_SINCE=$(jq -r '.calls_since_progress // 0' "$DRIFT_FILE" 2>/dev/null || echo "0")
    DRIFT_PHASE=$(jq -r '.current_phase // "unknown"' "$DRIFT_FILE" 2>/dev/null || echo "unknown")
    echo "Drift: $DRIFT_SINCE calls since progress in $DRIFT_PHASE phase ($DRIFT_WARNINGS warnings)"
  fi
fi

# ── Current branch + last 5 commits ──
echo "Branch: $GIT_BRANCH"
echo "Recent commits:"
git log --format="%h %s" -5 2>/dev/null || echo "  (no git history)"

echo "--- End VibeCrew Context ---"

exit 0
