#!/usr/bin/env bash
# scripts/quality-gate.sh
# Stop hook: runs typecheck/lint/build on modified files after each task completion.
# Detects available check commands from package.json scripts.
# On failure: exits non-zero so Claude sees the error report and can fix.
# On success or no changes: exits 0 silently.
# Respects user profile autonomy setting — only blocks for full_auto/checkpoints.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
CONFIG_FILE="$PROJECT_ROOT/.vibecrew/config.json"
PKG_JSON="$PROJECT_ROOT/package.json"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"

# ── Read configurable timeout ──
QG_TIMEOUT=120
if [[ -f "$CONFIG_FILE" ]]; then
  CONFIGURED_TIMEOUT="$(jq -r '.quality_gate.timeout_seconds // 120' "$CONFIG_FILE" 2>/dev/null || echo "120")"
  if [[ "$CONFIGURED_TIMEOUT" =~ ^[0-9]+$ ]] && [[ "$CONFIGURED_TIMEOUT" -gt 0 ]]; then
    QG_TIMEOUT="$CONFIGURED_TIMEOUT"
  fi
fi

# ── Skip if no VibeCrew state (not a VibeCrew project) ──
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

# ── Skip if foundation not complete (no source code to check) ──
FOUNDATION_COMPLETE="$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")"
if [[ "$FOUNDATION_COMPLETE" != "true" ]]; then
  exit 0
fi

# ── Check user profile autonomy ──
# Only run quality gate for full_auto and checkpoints profiles.
# collaborative and supervised users run checks explicitly via /check.
AUTONOMY="checkpoints"
if [[ -n "$PLUGIN_ROOT" && -x "$PLUGIN_ROOT/scripts/read-profile.sh" ]]; then
  AUTONOMY="$(bash "$PLUGIN_ROOT/scripts/read-profile.sh" autonomy 2>/dev/null || echo "checkpoints")"
elif [[ -f "$CONFIG_FILE" ]]; then
  AUTONOMY="$(jq -r '.user_profile.autonomy // "checkpoints"' "$CONFIG_FILE" 2>/dev/null || echo "checkpoints")"
fi

case "$AUTONOMY" in
  full_auto|checkpoints)
    # Continue — quality gate is active
    ;;
  *)
    # collaborative/supervised — skip automatic checks
    exit 0
    ;;
esac

# ── Detect modified files ──
# Check both staged and unstaged changes against HEAD
CHANGED_FILES="$(git diff --name-only HEAD 2>/dev/null || true)"
STAGED_FILES="$(git diff --cached --name-only 2>/dev/null || true)"
ALL_CHANGED="$(printf "%s\n%s" "$CHANGED_FILES" "$STAGED_FILES" | sort -u | grep -v '^$' || true)"

if [[ -z "$ALL_CHANGED" ]]; then
  exit 0
fi

# ── Check if any source files changed (not just config/docs) ──
SOURCE_CHANGED="$(echo "$ALL_CHANGED" | grep -E '\.(ts|tsx|js|jsx|vue|svelte|py|go|rs|rb|java|kt|swift|css|scss)$' || true)"
if [[ -z "$SOURCE_CHANGED" ]]; then
  exit 0
fi

# ── Detect available check commands from package.json ──
if [[ ! -f "$PKG_JSON" ]]; then
  exit 0
fi

SCRIPTS="$(jq -r '.scripts // {} | keys[]' "$PKG_JSON" 2>/dev/null || true)"

# Build ordered list of check commands to run
CHECKS=()

# Typecheck (highest signal — catches structural errors)
for cmd in "typecheck" "type-check" "tsc" "check:types"; do
  if echo "$SCRIPTS" | grep -qx "$cmd"; then
    CHECKS+=("$cmd")
    break
  fi
done

# Lint (catches style + potential bugs)
for cmd in "lint" "eslint" "check:lint"; do
  if echo "$SCRIPTS" | grep -qx "$cmd"; then
    CHECKS+=("$cmd")
    break
  fi
done

# Build (catches compilation errors the others might miss)
for cmd in "build" "check:build"; do
  if echo "$SCRIPTS" | grep -qx "$cmd"; then
    CHECKS+=("$cmd")
    break
  fi
done

if [[ ${#CHECKS[@]} -eq 0 ]]; then
  exit 0
fi

# ── Run checks sequentially, stop on first failure ──
# Determine the package manager
PKG_MANAGER="npm"
if [[ -f "$PROJECT_ROOT/bun.lockb" || -f "$PROJECT_ROOT/bun.lock" ]]; then
  PKG_MANAGER="bun"
elif [[ -f "$PROJECT_ROOT/pnpm-lock.yaml" ]]; then
  PKG_MANAGER="pnpm"
elif [[ -f "$PROJECT_ROOT/yarn.lock" ]]; then
  PKG_MANAGER="yarn"
fi

ERRORS=""
FAILED_CMD=""

TIMEOUT_CMD=""
TIMEOUT_ARGS=""
if command -v timeout &>/dev/null; then
  TIMEOUT_CMD="timeout"
  TIMEOUT_ARGS="${QG_TIMEOUT}s"
elif command -v gtimeout &>/dev/null; then
  TIMEOUT_CMD="gtimeout"
  TIMEOUT_ARGS="${QG_TIMEOUT}s"
fi

for check in "${CHECKS[@]}"; do
  OUTPUT=""
  if [[ -n "$TIMEOUT_CMD" ]]; then
    CMD_PREFIX=("$TIMEOUT_CMD" "$TIMEOUT_ARGS")
  else
    CMD_PREFIX=()
  fi
  if OUTPUT="$("${CMD_PREFIX[@]}" "$PKG_MANAGER" run "$check" 2>&1)"; then
    # Check passed — continue to next
    continue
  else
    EXIT_CODE=$?
    if [[ "$EXIT_CODE" -eq 124 ]]; then
      ERRORS="Quality gate check '$check' timed out after ${QG_TIMEOUT}s"
      FAILED_CMD="$check (timeout)"
    else
      ERRORS="$OUTPUT"
      FAILED_CMD="$check"
    fi
    break
  fi
done

# ── If all checks passed, exit silently ──
if [[ -z "$FAILED_CMD" ]]; then
  exit 0
fi

# ── A check failed — report the error ──
# Truncate output to avoid flooding context (keep last 80 lines)
TRUNCATED="$(echo "$ERRORS" | tail -80)"
TOTAL_LINES="$(echo "$ERRORS" | wc -l | tr -d ' ')"
SHOWN_LINES="$(echo "$TRUNCATED" | wc -l | tr -d ' ')"

echo "QUALITY GATE FAILED: \`${PKG_MANAGER} run $FAILED_CMD\` exited with errors."
echo ""
if [[ "$TOTAL_LINES" -gt "$SHOWN_LINES" ]]; then
  echo "(showing last $SHOWN_LINES of $TOTAL_LINES lines)"
  echo ""
fi
echo "$TRUNCATED"
echo ""
echo "Files changed in this session:"
echo "$SOURCE_CHANGED" | head -20
echo ""
echo "Fix these errors before proceeding. The quality gate will re-run on your next stop."

# Exit non-zero so Claude Code sees this as a hook failure and acts on it
exit 1
