#!/usr/bin/env bash
# scripts/deregister-agent.sh
# Removes the active agent identity file.
# Usage: deregister-agent.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/agent-identity.sh"

deregister_agent
echo "Agent deregistered"
