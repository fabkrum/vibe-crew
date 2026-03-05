#!/usr/bin/env bash
# scripts/capture-erosion-baseline.sh
# Captures initial baseline after first feature ships.
# Usage: capture-erosion-baseline.sh [--force] [project_root]
# Exit 0 on success

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    *) break ;;
  esac
done

PROJECT_ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
EROSION_DIR="$PROJECT_ROOT/.vibecrew/erosion"
BASELINE_FILE="$EROSION_DIR/baseline.json"

mkdir -p "$EROSION_DIR"

# Check if baseline already exists
if [[ -f "$BASELINE_FILE" && "$FORCE" != "true" ]]; then
  echo "Baseline already exists. Use --force to rebaseline."
  exit 0
fi

# Collect current metrics
METRICS=$(bash "$SCRIPT_DIR/collect-erosion-metrics.sh" "$PROJECT_ROOT" 2>/dev/null || echo '{}')

if [[ -z "$METRICS" || "$METRICS" == "{}" ]]; then
  echo "ERROR: Failed to collect metrics for baseline." >&2
  exit 1
fi

TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build baseline
jq -n \
  --arg ts "$TIMESTAMP" \
  --argjson metrics "$METRICS" \
  '{
    schema_version: "1.0.0",
    captured_at: $ts,
    total_project_loc: $metrics.total_project_loc,
    total_dependencies: $metrics.total_dependencies,
    total_dev_dependencies: $metrics.total_dev_dependencies,
    files_analyzed: $metrics.files_analyzed,
    file_metrics: $metrics.file_metrics
  }' > "$BASELINE_FILE"

echo "Erosion baseline captured: $BASELINE_FILE"
echo "  LOC: $(jq -r '.total_project_loc' "$BASELINE_FILE")"
echo "  Dependencies: $(jq -r '.total_dependencies' "$BASELINE_FILE")"
