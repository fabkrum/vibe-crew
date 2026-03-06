#!/usr/bin/env bash
# scripts/save-competitive-analysis.sh
# Save the Market Scout's competitive analysis to the project docs directory.
# Usage: save-competitive-analysis.sh [output-path]
# Reads analysis markdown from stdin.
# Defaults to docs/competitive-analysis.md.
# Exit 0 always — errors are reported as JSON.

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUTPUT_FILE="${1:-${PROJECT_ROOT}/docs/competitive-analysis.md}"
OUTPUT_DIR=$(dirname "${OUTPUT_FILE}")

# Read analysis from stdin
ANALYSIS=$(cat)

if [[ -z "${ANALYSIS}" ]]; then
  jq -n '{"error": "No analysis content provided. Pipe the analysis markdown to stdin."}'
  exit 0
fi

# Create output directory if missing
if [[ ! -d "${OUTPUT_DIR}" ]]; then
  mkdir -p "${OUTPUT_DIR}"
fi

# Write analysis to file
echo "${ANALYSIS}" > "${OUTPUT_FILE}"

jq -n \
  --arg file "${OUTPUT_FILE}" \
  '{
    "status": "saved",
    "file": $file,
    "message": ("Competitive analysis saved to " + $file)
  }'

exit 0
