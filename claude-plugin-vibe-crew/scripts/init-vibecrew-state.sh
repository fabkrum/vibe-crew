#!/usr/bin/env bash
# scripts/init-vibecrew-state.sh
# Creates .vibecrew/ directory with initial state files
# Idempotent: safe to run multiple times (does not overwrite existing files)
# Called by /setup skill
# Exit 0 on success, Exit 1 on failure

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VIBECREW_DIR="$PROJECT_ROOT/.vibecrew"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# --- Detect terminal ---
detect_terminal() {
  if [[ -n "${WARP_SESSION_ID:-}" ]]; then echo "warp"
  elif [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then echo "iterm"
  elif [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then echo "vscode"
  elif [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then echo "terminal"
  else echo "other"
  fi
}

TERMINAL=$(detect_terminal)

# --- Create directory structure ---
mkdir -p "$VIBECREW_DIR"/{sessions,scores,signals,locks,architecture,releases,handoffs,workflows}

# --- Write config.json (only if it doesn't exist) ---
if [[ ! -f "$VIBECREW_DIR/config.json" ]]; then
  cat > "$VIBECREW_DIR/config.json" <<EOF
{
  "schema_version": "1.4.0",
  "created_at": "$TIMESTAMP",
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
    "chrome_devtools": true,
    "playwright": true,
    "semgrep": false,
    "sentry": false,
    "supabase": false,
    "stripe": false,
    "vercel": false,
    "figma": false,
    "stitch": false
  },
  "mcp_discovery": {
    "auto_recommend": true,
    "auto_add": false
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
  },
  "gamification": {
    "enabled": false
  },
  "user_profile": {
    "interview_completed": false,
    "role": null,
    "code_literacy": null,
    "autonomy": null,
    "pr_review": null,
    "verbosity": null,
    "gamification_preference": null,
    "learning": null,
    "risk_tolerance": null,
    "updated_at": null
  }
}
EOF
  echo "Created: .vibecrew/config.json"
else
  echo "Exists:  .vibecrew/config.json (preserved)"
fi

# --- Write state.json (only if it doesn't exist) ---
if [[ ! -f "$VIBECREW_DIR/state.json" ]]; then
  cat > "$VIBECREW_DIR/state.json" <<EOF
{
  "schema_version": "1.4.0",
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
      "architecture_diagrams": {
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
  echo "Created: .vibecrew/state.json"
else
  echo "Exists:  .vibecrew/state.json (preserved)"
fi

# --- Write backlog.json (only if it doesn't exist) ---
if [[ ! -f "$VIBECREW_DIR/backlog.json" ]]; then
  cat > "$VIBECREW_DIR/backlog.json" <<EOF
{
  "schema_version": "1.4.0",
  "columns": [
    { "id": "idea",        "title": "Ideas",          "wip_limit": null },
    { "id": "planning",    "title": "Planning",       "wip_limit": 2 },
    { "id": "planned",     "title": "Planned",        "wip_limit": 5 },
    { "id": "in-progress", "title": "In Development", "wip_limit": 1 },
    { "id": "testing",     "title": "Testing",        "wip_limit": 1 },
    { "id": "review",      "title": "Review",         "wip_limit": 2 },
    { "id": "done",        "title": "Done",           "wip_limit": null }
  ],
  "features": []
}
EOF
  echo "Created: .vibecrew/backlog.json"
else
  echo "Exists:  .vibecrew/backlog.json (preserved)"
fi

# --- Write gamification.json (only if gamification is enabled and file doesn't exist) ---
# Gamification is opt-in. The file is created lazily when the user enables it via /profile.
GAMIFICATION_ENABLED=$(jq -r '.gamification.enabled // false' "$VIBECREW_DIR/config.json" 2>/dev/null || echo "false")
if [[ "$GAMIFICATION_ENABLED" == "true" ]] && [[ ! -f "$VIBECREW_DIR/gamification.json" ]]; then
  cat > "$VIBECREW_DIR/gamification.json" <<EOF
{
  "schema_version": "1.0.0",
  "level": 1,
  "xp": 0,
  "xp_this_level": 0,
  "xp_to_next_level": 100,
  "streak": {
    "current": 0,
    "longest": 0,
    "last_session_date": null,
    "grace_days_remaining": 2,
    "frozen_today": false
  },
  "badges": [],
  "skills": {
    "prompting": { "level": 0, "xp": 0, "max_level": 5 },
    "architecture": { "level": 0, "xp": 0, "max_level": 5 },
    "testing": { "level": 0, "xp": 0, "max_level": 5 },
    "context_management": { "level": 0, "xp": 0, "max_level": 5 },
    "workflow_discipline": { "level": 0, "xp": 0, "max_level": 5 }
  },
  "active_challenges": [],
  "completed_challenges": [],
  "quizzes": {
    "completed": [],
    "correct_answers": 0,
    "total_questions": 0
  },
  "unlocked_features": [],
  "stats": {
    "total_sessions": 0,
    "total_features_shipped": 0,
    "perfect_sessions": 0,
    "best_vibe_score": 0,
    "score_history": []
  }
}
EOF
  echo "Created: .vibecrew/gamification.json"
elif [[ -f "$VIBECREW_DIR/gamification.json" ]]; then
  echo "Exists:  .vibecrew/gamification.json (preserved)"
fi

# --- Add .gitignore entries ---
GITIGNORE="$PROJECT_ROOT/.gitignore"
VIBECREW_IGNORES=(
  ".vibecrew/sessions/"
  ".vibecrew/signals/"
  ".vibecrew/locks/"
  ".vibecrew/notifications.log"
  ".vibecrew/config.json"
)

if [[ -f "$GITIGNORE" ]]; then
  for entry in "${VIBECREW_IGNORES[@]}"; do
    if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
      echo "$entry" >> "$GITIGNORE"
    fi
  done
  echo "Updated: .gitignore with VibeCrew entries"
else
  printf '%s\n' "${VIBECREW_IGNORES[@]}" > "$GITIGNORE"
  echo "Created: .gitignore with VibeCrew entries"
fi

# --- Register with central VibeCrew telemetry ---
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
if [[ -n "$PLUGIN_ROOT" ]] && [[ -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]]; then
  REGISTRY="$PLUGIN_ROOT/project-registry.json"
  if [[ ! -f "$REGISTRY" ]]; then
    echo '{"schema_version":"1.0.0","projects":[]}' > "$REGISTRY"
  fi
  # Only register if this project path isn't already registered
  if ! jq -e --arg p "$PROJECT_ROOT" '.projects[] | select(.path == $p)' "$REGISTRY" >/dev/null 2>&1; then
    NEXT_ID=$(jq '.projects | length + 1' "$REGISTRY")
    ALIAS="project-$(printf '%03d' "$NEXT_ID")"
    jq --arg p "$PROJECT_ROOT" --arg t "$TIMESTAMP" --arg a "$ALIAS" \
      '.projects += [{"path": $p, "registered_at": $t, "alias": $a}]' \
      "$REGISTRY" > "$REGISTRY.tmp" && mv "$REGISTRY.tmp" "$REGISTRY"
    echo "Registered with VibeCrew telemetry as $ALIAS"
  fi
fi

echo ""
echo "VibeCrew state initialized in $VIBECREW_DIR"
echo "  config.json        -- User preferences (schema v1.4.0)"
echo "  state.json         -- Project state (schema v1.4.0)"
echo "  backlog.json       -- Feature backlog (schema v1.4.0)"
echo "  sessions/          -- Session logs"
echo "  scores/            -- Vibe Score history"
echo "  signals/           -- Inter-agent signals"
echo "  locks/             -- Advisory locks"
echo "  architecture/      -- Mermaid architecture diagrams"
echo "  releases/          -- Release notes"
echo "  handoffs/          -- Cross-session handoffs"
echo "  workflows/         -- Reusable workflow templates"

exit 0
