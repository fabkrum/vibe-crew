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
echo "Detected terminal: $TERMINAL"

# --- Create directory structure ---
mkdir -p "$VIBECREW_DIR"/{sessions,scores,signals,locks,architecture,releases,handoffs,workflows,expertise,erosion,analysis,agent-logs,.backup}

# --- Write config.json (only if it doesn't exist) ---
if [[ ! -f "$VIBECREW_DIR/config.json" ]]; then
  cat > "$VIBECREW_DIR/config.json" <<EOF
{
  "schema_version": "1.6.0",
  "created_at": "$TIMESTAMP",
  "terminal": "$TERMINAL",
  "claude_command": "${CLAUDE_COMMAND:-claude}",
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
    "figma": false
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
    "warn_at_percent": 45,
    "critical_at_percent": 60
  },
  "cost_limits": {
    "session_warn_usd": 2.00,
    "session_max_usd": 5.00,
    "daily_warn_usd": 20.00
  },
  "pricing": {
    "opus": {
      "input": 15.00,
      "cache_create": 18.75,
      "cache_read": 1.50,
      "output": 75.00
    },
    "sonnet": {
      "input": 3.00,
      "cache_create": 3.75,
      "cache_read": 0.30,
      "output": 15.00
    },
    "haiku": {
      "input": 0.25,
      "cache_create": 0.30,
      "cache_read": 0.03,
      "output": 1.25
    },
    "last_updated": "2026-03-01"
  },
  "locks": {
    "stale_timeout_secs": 60,
    "wait_timeout_secs": 30
  },
  "quality_gate": {
    "timeout_seconds": 120
  },
  "performance_coach": {
    "enabled": true,
    "min_sessions_for_trends": 3,
    "min_sessions_for_mutations": 5
  },
  "doc_generator": {
    "auto_changelog": true,
    "auto_feature_docs": true,
    "auto_sidebar_rebuild": true
  },
  "onboarding": {
    "show_hints": true,
    "dismissed_hints": []
  },
  "git_provider": null,
  "audit": {
    "auto_issues": false,
    "severity_threshold": "high"
  },
  "issues": {
    "enabled": false,
    "autofix_label": "autofix",
    "default_mode": "hotfix",
    "auto_pr": true,
    "sync_limit": 10
  },
  "opponent_processor": {
    "enabled": true,
    "auto_invoke_after_tdr": true
  },
  "simplify": {
    "enabled": true,
    "min_files_for_analysis": 3,
    "auto_revert_on_test_failure": true
  },
  "ci_healing": {
    "enabled": true,
    "max_attempts": 3,
    "auto_checkpoint": true
  },
  "drift_detection": {
    "enabled": true,
    "thresholds": {
      "plan":   { "soft": 40, "hard": 60 },
      "design": { "soft": 30, "hard": 50 },
      "code":   { "soft": 20, "hard": 35 },
      "test":   { "soft": 25, "hard": 40 },
      "review": { "soft": null, "hard": null },
      "docs":   { "soft": 25, "hard": 40 }
    }
  },
  "erosion": {
    "file_max_loc": 300,
    "function_max_loc": 50,
    "complexity_max": 10,
    "hot_file_churn_count": 5,
    "rapid_decline_points": 15,
    "rapid_decline_sessions": 3
  },
  "agent_observability": {
    "enabled": true,
    "log_tool_calls": true,
    "max_log_files": 50,
    "efficiency_thresholds": {
      "write_agents": 0.20,
      "min_sessions": 3
    },
    "self_improvement": true
  },
  "gamification": {
    "enabled": false
  },
  "user_profile": {
    "interview_completed": false,
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
  "schema_version": "1.6.0",
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
        "brief_file": null,
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
  "active_workflow": null,
  "onboarded": false,
  "onboarded_at": null,
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
  "schema_version": "1.6.0",
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

# --- Generate Warp launch configuration (if running in Warp) ---
if [[ "$TERMINAL" == "warp" ]]; then
  WARP_LC_DIR="$HOME/.warp/launch_configurations"
  PROJECT_NAME=$(basename "$PROJECT_ROOT")
  WARP_LC_FILE="$WARP_LC_DIR/$PROJECT_NAME.yaml"
  WARP_CLAUDE_CMD="${CLAUDE_COMMAND:-claude}"

  if [[ ! -f "$WARP_LC_FILE" ]]; then
    mkdir -p "$WARP_LC_DIR"
    cat > "$WARP_LC_FILE" <<WARPEOF
---
name: $PROJECT_NAME
windows:
  - tabs:
      - title: $PROJECT_NAME
        color: blue
        layout:
          split_direction: horizontal
          panes:
            - cwd: $PROJECT_ROOT
              commands:
                - exec: $WARP_CLAUDE_CMD
              is_focused: true
            - split_direction: vertical
              panes:
                - cwd: $PROJECT_ROOT
                  commands:
                    - exec: $WARP_CLAUDE_CMD
                - cwd: $PROJECT_ROOT
WARPEOF
    echo "Created: Warp launch config (~/.warp/launch_configurations/$PROJECT_NAME.yaml)"
  else
    echo "Exists:  Warp launch config (~/.warp/launch_configurations/$PROJECT_NAME.yaml)"
  fi
fi

# --- Add .gitignore entries ---
GITIGNORE="$PROJECT_ROOT/.gitignore"
VIBECREW_IGNORES=(
  ".vibecrew/sessions/"
  ".vibecrew/signals/"
  ".vibecrew/locks/"
  ".vibecrew/notifications.log"
  ".vibecrew/config.json"
  ".vibecrew/scores/"
  ".vibecrew/gamification.json"
  ".vibecrew/.backup/"
  ".vibecrew/session-errors.jsonl"
  ".vibecrew/session-cost.json"
  ".vibecrew/drift-tracker.json"
  ".vibecrew/erosion/"
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
echo "  config.json        -- User preferences (schema v1.6.0)"
echo "  state.json         -- Project state (schema v1.6.0)"
echo "  backlog.json       -- Feature backlog (schema v1.6.0)"
echo "  sessions/          -- Session logs"
echo "  scores/            -- Vibe Score history"
echo "  signals/           -- Inter-agent signals"
echo "  locks/             -- Advisory locks"
echo "  architecture/      -- Mermaid architecture diagrams"
echo "  releases/          -- Release notes"
echo "  handoffs/          -- Cross-session handoffs"
echo "  workflows/         -- Reusable workflow templates"
echo "  expertise/         -- Structured expertise records (JSONL)"
echo "  erosion/           -- Code erosion tracking snapshots"

exit 0
