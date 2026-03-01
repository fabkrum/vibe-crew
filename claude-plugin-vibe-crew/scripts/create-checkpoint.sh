#!/usr/bin/env bash
# scripts/create-checkpoint.sh
# Creates a lightweight VibeCrew checkpoint tag on the current commit.
# Used by /new-feature and /run-backlog to mark safe rollback points.
# Usage: create-checkpoint.sh ["optional description"]
# Output: The tag name that was created

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source error logging
source "$SCRIPT_DIR/lib/error-log.sh"

TIMESTAMP="$(date -u +"%Y-%m-%dT%H-%M-%SZ")"
TAG_NAME="vibecrew-checkpoint-${TIMESTAMP}"
DESCRIPTION="${1:-VibeCrew checkpoint}"

git tag -a "$TAG_NAME" -m "$DESCRIPTION" 2>/dev/null || log_error "create-checkpoint" "Failed to create tag $TAG_NAME"
echo "$TAG_NAME"
exit 0
