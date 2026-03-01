#!/usr/bin/env bash
# scripts/inject-architecture.sh
# Concatenates architecture diagrams from .vibecrew/architecture/ into context.
# Called by the Workflow Orchestrator after routing to give all downstream agents
# an instant architectural map without each loading diagrams independently.
# Only outputs when foundation is complete and diagrams exist.
# Exit 0 always (fail open)

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE_FILE="$PROJECT_ROOT/.vibecrew/state.json"
ARCH_DIR="$PROJECT_ROOT/.vibecrew/architecture"

# ── Skip if foundation not complete ──
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

FOUNDATION_COMPLETE="$(jq -r '.foundation.complete // false' "$STATE_FILE" 2>/dev/null || echo "false")"
if [[ "$FOUNDATION_COMPLETE" != "true" ]]; then
  exit 0
fi

# ── Skip if no architecture directory ──
if [[ ! -d "$ARCH_DIR" ]]; then
  exit 0
fi

# ── Collect .mmd files ──
DIAGRAMS=()
for mmd in "$ARCH_DIR"/*.mmd; do
  [[ -f "$mmd" ]] || continue
  DIAGRAMS+=("$mmd")
done

if [[ ${#DIAGRAMS[@]} -eq 0 ]]; then
  exit 0
fi

# ── Output compact architecture context block ──
echo "--- Architecture Context (${#DIAGRAMS[@]} diagrams) ---"

for mmd in "${DIAGRAMS[@]}"; do
  BASENAME="$(basename "$mmd" .mmd)"
  LINE_COUNT="$(wc -l < "$mmd" | tr -d ' ')"
  echo ""
  echo "## ${BASENAME} (${LINE_COUNT} lines)"
  cat "$mmd"
done

echo ""
echo "--- End Architecture Context ---"

exit 0
