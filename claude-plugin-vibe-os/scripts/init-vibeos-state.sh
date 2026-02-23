#!/usr/bin/env bash
# scripts/init-vibeos-state.sh
# Creates .vibeos/ directory with initial state files
# Idempotent: safe to run multiple times (does not overwrite existing files)
# Called by /setup skill
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBEOS_DIR="$PROJECT_ROOT/.vibeos"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Detect terminal ---
detect_terminal() {
  if [[ -n "${WARP_SESSION_ID:-}" ]]; then echo "warp"
  elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then echo "iterm"
  elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then echo "terminal"
  else echo "other"
  fi
}

TERMINAL=$(detect_terminal)

# --- Create directory structure ---
mkdir -p "$VIBEOS_DIR"/{sessions,scores,signals,locks}

# --- Write config.json (only if it doesn't exist) ---
if [[ ! -f "$VIBEOS_DIR/config.json" ]]; then
  cat > "$VIBEOS_DIR/config.json" <<EOF
{
  "schema_version": "1.0.0",
  "terminal": "$TERMINAL",
  "notifications": {
    "enabled": true,
    "sound": "Submarine",
    "on_permission_prompt": true,
    "on_task_complete": true,
    "on_failure": true
  },
  "concurrency": {
    "max_parallel_agents": 3
  },
  "models": {
    "lightweight": "haiku",
    "standard": "sonnet"
  },
  "mcp_servers": {
    "context7": true,
    "puppeteer": true
  },
  "formatting": {
    "auto_format": true,
    "formatter": "prettier"
  },
  "context_warnings": {
    "warn_at_percent": 60,
    "critical_at_percent": 80
  },
  "cost_limits": {
    "session_warn_usd": 2.00,
    "session_max_usd": 5.00,
    "daily_warn_usd": 20.00
  }
}
EOF
  echo "Created: .vibeos/config.json"
else
  echo "Exists:  .vibeos/config.json (preserved)"
fi

# --- Write state.json (only if it doesn't exist) ---
if [[ ! -f "$VIBEOS_DIR/state.json" ]]; then
  cat > "$VIBEOS_DIR/state.json" <<EOF
{
  "schema_version": "1.0.0",
  "foundation": {
    "complete": false,
    "completed_at": null,
    "artifacts": {
      "vision": {
        "status": "pending",
        "file": null,
        "approved_at": null
      },
      "design_system": {
        "status": "pending",
        "file": null,
        "approved_at": null
      },
      "tdr": {
        "status": "pending",
        "file": null,
        "approved_at": null
      },
      "roadmap": {
        "status": "pending",
        "file": null,
        "approved_at": null
      },
      "claude_md": {
        "status": "pending",
        "file": null,
        "approved_at": null
      }
    }
  },
  "active_feature": {
    "id": null,
    "name": null,
    "worktree": null,
    "phase": null,
    "phases_completed": []
  },
  "git": {
    "default_branch": "main",
    "initialized": false
  },
  "updated_at": "$TIMESTAMP"
}
EOF
  echo "Created: .vibeos/state.json"
else
  echo "Exists:  .vibeos/state.json (preserved)"
fi

# --- Write backlog.json (only if it doesn't exist) ---
if [[ ! -f "$VIBEOS_DIR/backlog.json" ]]; then
  cat > "$VIBEOS_DIR/backlog.json" <<EOF
{
  "schema_version": "1.0.0",
  "columns": [
    { "id": "idea",        "title": "Ideas",          "wip_limit": null },
    { "id": "planned",     "title": "Planned",        "wip_limit": 5 },
    { "id": "ready",       "title": "Ready",          "wip_limit": 3 },
    { "id": "in-progress", "title": "In Development", "wip_limit": 1 },
    { "id": "testing",     "title": "Testing",        "wip_limit": 1 },
    { "id": "review",      "title": "Review",         "wip_limit": 2 },
    { "id": "done",        "title": "Done",           "wip_limit": null }
  ],
  "features": []
}
EOF
  echo "Created: .vibeos/backlog.json"
else
  echo "Exists:  .vibeos/backlog.json (preserved)"
fi

# --- Add .gitignore entries ---
GITIGNORE="$PROJECT_ROOT/.gitignore"
VIBEOS_IGNORES=(
  ".vibeos/sessions/"
  ".vibeos/signals/"
  ".vibeos/locks/"
  ".vibeos/notifications.log"
  ".vibeos/config.json"
)

if [[ -f "$GITIGNORE" ]]; then
  for entry in "${VIBEOS_IGNORES[@]}"; do
    if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
      echo "$entry" >> "$GITIGNORE"
    fi
  done
  echo "Updated: .gitignore with VibeOS entries"
else
  printf '%s\n' "${VIBEOS_IGNORES[@]}" > "$GITIGNORE"
  echo "Created: .gitignore with VibeOS entries"
fi

echo ""
echo "VibeOS state initialized in $VIBEOS_DIR"
echo "  config.json   -- User preferences (schema v1.0.0)"
echo "  state.json    -- Project state (schema v1.0.0)"
echo "  backlog.json  -- Feature backlog (schema v1.0.0)"
echo "  sessions/     -- Session logs"
echo "  scores/       -- Vibe Score history"
echo "  signals/      -- Inter-agent signals"
echo "  locks/        -- Advisory locks"

exit 0
