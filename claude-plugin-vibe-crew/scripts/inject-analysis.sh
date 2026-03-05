#!/usr/bin/env bash
# scripts/inject-analysis.sh
# Outputs analysis docs as a compact context block (~300-500 tokens).
# Called by compact-reinject.sh and Builder Plan phase.
# If analysis docs don't exist (greenfield project), outputs nothing.
# Exit 0 always.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ANALYSIS_DIR="${PROJECT_ROOT}/.vibecrew/analysis"

# Check if analysis docs exist
if [[ ! -d "$ANALYSIS_DIR" ]] || [[ ! -f "$ANALYSIS_DIR/stack.md" ]]; then
  # No analysis docs — greenfield project or /onboard not run
  exit 0
fi

echo "--- Codebase Analysis (from /onboard) ---"

# Inject each doc as a compact section, truncated to key lines
for doc in stack.md architecture.md conventions.md gaps.md; do
  if [[ -f "$ANALYSIS_DIR/$doc" ]]; then
    # Print header and content (skip the "Generated:" line for brevity)
    head -30 "$ANALYSIS_DIR/$doc" | grep -v "^Generated:" | grep -v "^$" | head -25
    echo ""
  fi
done

echo "--- End Codebase Analysis ---"

exit 0
