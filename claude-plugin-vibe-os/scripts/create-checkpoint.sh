#!/usr/bin/env bash
# scripts/create-checkpoint.sh
# Creates a lightweight VibeOS checkpoint tag on the current commit.
# Used by /new-feature and /run-backlog to mark safe rollback points.
# Usage: create-checkpoint.sh ["optional description"]
# Output: The tag name that was created

set -euo pipefail

TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
TAG_NAME="vibeos-checkpoint-${TIMESTAMP}"
DESCRIPTION="${1:-VibeOS checkpoint}"

git tag -a "$TAG_NAME" -m "$DESCRIPTION" 2>/dev/null || true
echo "$TAG_NAME"
exit 0
