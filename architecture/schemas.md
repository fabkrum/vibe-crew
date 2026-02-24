# VibeOS Canonical Schemas

> **This is the single source of truth for all `.vibeos/` JSON file schemas.**
> All other architecture documents MUST reference this file rather than defining schemas inline.
> Schema version: `1.0.0`

---

## Table of Contents

1. [Conventions](#1-conventions)
2. [config.json](#2-configjson)
3. [state.json](#3-statejson)
4. [backlog.json](#4-backlogjson)
5. [Session Logs](#5-session-logs)
6. [Score Files](#6-score-files)
7. [Signal Files](#7-signal-files)
8. [Lock Files](#8-lock-files)
9. [Migration Strategy](#9-migration-strategy)
10. [Gamification State](#10-gamification-state)

---

## 1. Conventions

### Field Naming

- **snake_case** for all JSON keys (consistent with Claude Code internals)
- **ISO 8601** for all timestamps (`2026-02-23T10:00:00Z`)
- **Semantic versioning** for `schema_version` fields (`"1.0.0"`)
- **Kebab-case** for feature IDs (`feat-001`), session IDs (`session-2026-02-23-001`), and file names
- **Enum values** use kebab-case (`in-progress`, not `inProgress` or `IN_PROGRESS`)

### Schema Version Contract

Every `.vibeos/` JSON file includes a top-level `schema_version` field. When VibeOS reads a file:

1. If `schema_version` matches the current version → use as-is
2. If `schema_version` is older → run migration (see [Section 9](#9-migration-strategy))
3. If `schema_version` is missing → treat as `"0.0.0"` and migrate
4. If `schema_version` is newer → warn user and refuse to modify (forward-compatibility guard)

### File Locations

```
.vibeos/
├── config.json                          # User preferences (per-project)
├── state.json                           # Project state + active feature
├── backlog.json                         # Feature backlog with specs
├── gamification.json                    # Gamification state (XP, badges, streaks)
├── sessions/
│   └── session-<ISO-date>-<NNN>.json    # Per-session logs
├── scores/
│   └── score-<ISO-date>-<NNN>.json      # Per-session Vibe Score breakdowns
├── signals/
│   └── <agent>-<event>.signal           # Ephemeral inter-agent signals (JSON)
└── locks/
    └── <resource>/                      # mkdir-based atomic locks
        └── info.json                    # Lock metadata
```

---

## 2. config.json

User preferences. Created by `/setup` or `/new-project`. Editable by user.

```jsonc
{
  "schema_version": "1.0.0",

  // Terminal integration
  "terminal": "warp",                    // "warp" | "iterm" | "terminal" | "other"

  // Notification preferences (Interrupt Protocol)
  "notifications": {
    "enabled": true,
    "sound": "Submarine",               // macOS sound name
    "on_permission_prompt": true,        // Fires when agent needs approval
    "on_task_complete": true,            // Fires when agent finishes work
    "on_failure": true                   // Fires on PostToolUseFailure
  },

  // Agent concurrency
  "concurrency": {
    "max_parallel_agents": 3             // Max simultaneous Agent Teams members
  },

  // Model preferences (overridable per-agent in agents.md)
  "models": {
    "lightweight": "haiku",              // Session Startup, quick checks
    "standard": "sonnet"                 // Orchestrator, Builder, Verifier, Stack Scout
  },

  // MCP server toggles
  "mcp_servers": {
    "context7": true,                    // Documentation lookup
    "puppeteer": true                    // Browser automation for testing
  },

  // Code formatting
  "formatting": {
    "auto_format": true,                 // Run formatter on Write/Edit via hook
    "formatter": "prettier"              // "prettier" | "biome" | "none"
  },

  // Context window guardrails
  "context_warnings": {
    "warn_at_percent": 60,               // First warning threshold
    "critical_at_percent": 80            // Force /clear or subagent delegation
  },

  // Cost guardrails
  "cost_limits": {
    "session_warn_usd": 2.00,            // Warn when session cost exceeds this
    "session_max_usd": 5.00,             // Hard stop (agent must pause and ask user)
    "daily_warn_usd": 20.00              // Daily spend warning
  }
}
```

### Field Reference

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `schema_version` | string | yes | `"1.0.0"` | Schema version for migration |
| `terminal` | enum | yes | `"warp"` | Terminal emulator in use |
| `notifications.enabled` | boolean | yes | `true` | Master notification toggle |
| `notifications.sound` | string | no | `"Submarine"` | macOS notification sound |
| `notifications.on_permission_prompt` | boolean | yes | `true` | Notify on permission stalls |
| `notifications.on_task_complete` | boolean | yes | `true` | Notify on agent completion |
| `notifications.on_failure` | boolean | yes | `true` | Notify on tool failures |
| `concurrency.max_parallel_agents` | integer | yes | `3` | Max Agent Teams members |
| `models.lightweight` | string | yes | `"haiku"` | Model for lightweight agents |
| `models.standard` | string | yes | `"sonnet"` | Model for standard agents |
| `mcp_servers.context7` | boolean | yes | `true` | Context7 MCP enabled |
| `mcp_servers.puppeteer` | boolean | yes | `true` | Puppeteer MCP enabled |
| `formatting.auto_format` | boolean | yes | `true` | Auto-format on file writes |
| `formatting.formatter` | enum | yes | `"prettier"` | Formatter to use |
| `context_warnings.warn_at_percent` | integer | yes | `60` | Warning threshold (%) |
| `context_warnings.critical_at_percent` | integer | yes | `80` | Critical threshold (%) |
| `cost_limits.session_warn_usd` | number | yes | `2.00` | Session cost warning |
| `cost_limits.session_max_usd` | number | yes | `5.00` | Session cost hard limit |
| `cost_limits.daily_warn_usd` | number | yes | `20.00` | Daily cost warning |

---

## 3. state.json

Project state tracking. Created by `/new-project` (Tier 1) or `/setup` (existing project). Modified by agents during workflow progression.

```jsonc
{
  "schema_version": "1.0.0",

  // Tier 1: Project Foundation
  "foundation": {
    "complete": false,                   // true when ALL 5 artifacts approved
    "completed_at": null,                // ISO 8601 timestamp | null
    "artifacts": {
      "vision": {
        "status": "pending",             // "pending" | "in-progress" | "complete"
        "file": null,                    // Relative path once created | null
        "approved_at": null              // ISO 8601 timestamp | null
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

  // Tier 2: Active feature tracking
  "active_feature": {
    "id": null,                          // Feature ID from backlog.json | null
    "name": null,                        // Human-readable name | null
    "worktree": null,                    // Git worktree path | null
    "phase": null,                       // Current phase | null
    "phases_completed": []               // Completed phases for this feature
  },

  // Git state
  "git": {
    "default_branch": "main",
    "initialized": false
  },

  // Metadata
  "updated_at": "2026-02-23T10:00:00Z"
}
```

### Foundation Artifact Status Flow

```
pending → in-progress → complete
```

An artifact's `status` moves to `"in-progress"` when an agent begins work on it, and to `"complete"` when the user approves it. The `file` path is set when the artifact is first created. The `approved_at` timestamp is set on approval.

`foundation.complete` flips to `true` only when ALL five artifacts have `status: "complete"`. This is the gate that the phase-gate hook checks.

### Active Feature Phase Values

The `active_feature.phase` field uses these values:

```
"plan" | "design" | "code" | "test" | "docs" | null
```

Phases are **sequential by default** but can be re-entered if issues are found during verification:

```
plan → design → code → test → docs → (done)
              ↖─── verify-fix loops ───↙
```

The `phases_completed` array tracks which phases have been completed at least once. A phase can be re-entered (e.g., going back from `test` to `code` to fix a bug) — the phase stays in `phases_completed` and the agent records the re-entry in the session log.

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `foundation.complete` | boolean | yes | All 5 artifacts approved |
| `foundation.completed_at` | string\|null | yes | When foundation was completed |
| `foundation.artifacts.<name>.status` | enum | yes | `pending`\|`in-progress`\|`complete` |
| `foundation.artifacts.<name>.file` | string\|null | yes | Relative file path |
| `foundation.artifacts.<name>.approved_at` | string\|null | yes | Approval timestamp |
| `active_feature.id` | string\|null | yes | Feature ID from backlog |
| `active_feature.name` | string\|null | yes | Human-readable name |
| `active_feature.worktree` | string\|null | yes | Git worktree path |
| `active_feature.phase` | enum\|null | yes | Current workflow phase |
| `active_feature.phases_completed` | string[] | yes | Completed phase names |
| `git.default_branch` | string | yes | Default git branch |
| `git.initialized` | boolean | yes | Whether git repo exists |
| `updated_at` | string | yes | Last modification timestamp |

---

## 4. backlog.json

Feature backlog. Created by `/plan-features`. Modified by `/new-feature`, `/idea`, `/run-backlog`, and agent workflow progression.

```jsonc
{
  "schema_version": "1.0.0",

  // Kanban column definitions (used by docs site and /status)
  "columns": [
    { "id": "idea",        "title": "Ideas",          "wip_limit": null },
    { "id": "planned",     "title": "Planned",        "wip_limit": 5 },
    { "id": "ready",       "title": "Ready",          "wip_limit": 3 },
    { "id": "in-progress", "title": "In Development", "wip_limit": 1 },
    { "id": "testing",     "title": "Testing",        "wip_limit": 1 },
    { "id": "review",      "title": "Review",         "wip_limit": 2 },
    { "id": "done",        "title": "Done",           "wip_limit": null }
  ],

  // Feature list
  "features": [
    {
      "id": "feat-001",
      "name": "User Authentication",
      "description": "OAuth2 + email/password login with session management",
      "column": "idea",                  // Current Kanban column
      "priority": 1,                     // Lower = higher priority
      "labels": ["auth", "security"],

      // Spec (populated during "plan" phase)
      "spec": {
        "acceptance_criteria": [],       // String array of requirements
        "ui_description": null,          // Brief UI description | null
        "business_logic": [],            // String array of logic requirements
        "technical_notes": null          // Free-text technical considerations | null
      },

      // Tracking
      "worktree": null,                  // Git worktree path when active | null
      "phases_completed": [],            // Phases completed for this feature
      "sessions": [],                    // Session IDs that worked on this feature

      // History
      "created_at": "2026-02-23T10:00:00Z",
      "updated_at": "2026-02-23T10:00:00Z",
      "completed_at": null               // ISO 8601 when moved to "done" | null
    }
  ]
}
```

### Feature Column Flow (Kanban State Machine)

```
idea → planned → ready → in-progress → testing → review → done
```

| Transition | Trigger |
|-----------|---------|
| `idea → planned` | `/plan-features` or user moves manually |
| `planned → ready` | Spec populated (acceptance criteria defined) |
| `ready → in-progress` | `/new-feature` or `/run-backlog` picks it up |
| `in-progress → testing` | Builder agent completes code phase |
| `testing → review` | Verifier agent passes all tests |
| `review → done` | User approves via `/wrap` |

WIP limits are enforced: if `in-progress` has `wip_limit: 1`, a new feature cannot enter `in-progress` until the current one moves forward.

### Feature Object Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique feature ID (`feat-NNN`) |
| `name` | string | yes | Human-readable name |
| `description` | string | yes | Brief description |
| `column` | enum | yes | Current Kanban column |
| `priority` | integer | yes | Priority (1 = highest) |
| `labels` | string[] | yes | Categorization labels |
| `spec.acceptance_criteria` | string[] | yes | List of requirements |
| `spec.ui_description` | string\|null | yes | UI description |
| `spec.business_logic` | string[] | yes | Business logic requirements |
| `spec.technical_notes` | string\|null | no | Technical considerations |
| `worktree` | string\|null | yes | Active worktree path |
| `phases_completed` | string[] | yes | Completed phases |
| `sessions` | string[] | yes | Related session IDs |
| `created_at` | string | yes | Creation timestamp |
| `updated_at` | string | yes | Last modification timestamp |
| `completed_at` | string\|null | yes | Completion timestamp |

---

## 5. Session Logs

Per-session activity records. Created by Session Startup agent at session start, updated by `/wrap` command at session end.

**File pattern:** `.vibeos/sessions/session-<YYYY-MM-DD>-<NNN>.json`

```jsonc
{
  "schema_version": "1.0.0",

  // Identity
  "session_id": "session-2026-02-23-001",
  "started_at": "2026-02-23T10:00:00Z",
  "ended_at": null,                      // Set by /wrap | null if active

  // What was worked on
  "feature_id": "feat-001",             // Feature ID from backlog | null (Tier 1)
  "task_summary": null,                  // Brief description set by /wrap | null

  // Agents used
  "agents": [
    {
      "agent": "builder",                // Agent name
      "started_at": "2026-02-23T10:05:00Z",
      "ended_at": "2026-02-23T11:30:00Z",
      "worktree": ".claude/worktrees/builder-feat-001"
    }
  ],

  // Git activity
  "commits": [
    {
      "hash": "abc1234",
      "message": "feat(auth): add login form component",
      "files_changed": 3
    }
  ],

  // Token usage
  "tokens": {
    "input": 45200,
    "cache_creation": 8500,
    "cache_read": 32100,
    "output": 12800,
    "cache_hit_rate": 0.71,
    "estimated_cost_usd": 0.42
  },

  // Quality metrics
  "tests": {
    "ran": true,
    "total": 12,
    "passed": 10,
    "failed": 2,
    "coverage_percent": 78.5
  },

  // Context window usage
  "context": {
    "peak_usage_percent": 47,
    "average_usage_percent": 32,
    "compactions": 0                     // Number of times context was compacted
  },

  // Files modified (summary)
  "files_modified": [
    {
      "path": "src/auth/login.ts",
      "lines_added": 120,
      "lines_removed": 15,
      "operation": "modified"            // "created" | "modified" | "deleted"
    }
  ],

  // Duration
  "duration_seconds": 6300,

  // Vibe Score (set by /wrap)
  "vibe_score": null                     // Integer 0-100 | null
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `session_id` | string | yes | Unique session identifier |
| `started_at` | string | yes | Session start timestamp |
| `ended_at` | string\|null | yes | Session end timestamp |
| `feature_id` | string\|null | yes | Active feature ID |
| `task_summary` | string\|null | no | Summary set by /wrap |
| `agents` | array | yes | Agents used in session |
| `commits` | array | yes | Git commits made |
| `tokens` | object | yes | Token usage breakdown |
| `tests` | object | yes | Test results summary |
| `context` | object | yes | Context window metrics |
| `files_modified` | array | yes | Files changed summary |
| `duration_seconds` | integer | yes | Session duration |
| `vibe_score` | integer\|null | yes | Vibe Score (set by /wrap) |

---

## 6. Score Files

Per-session Vibe Score breakdown. Created by `/wrap` command (Verifier agent calculates score).

**File pattern:** `.vibeos/scores/score-<YYYY-MM-DD>-<NNN>.json`

```jsonc
{
  "schema_version": "1.0.0",

  // Identity
  "session_id": "session-2026-02-23-001",
  "timestamp": "2026-02-23T11:45:00Z",
  "feature_id": "feat-001",

  // Final score
  "score": 82,                           // 0-100 (clamped)
  "rating": "good",                      // "excellent" (90+) | "good" (70-89) | "needs-improvement" (50-69) | "review-session" (<50)

  // Metrics used for calculation
  "metrics": {
    "tokens": {
      "total_input": 45200,
      "total_cache_read": 32100,
      "total_output": 12800,
      "cache_ratio": 0.71                // cache_read / total_input
    },
    "context": {
      "peak_usage_percent": 47,
      "warnings_triggered": 0
    },
    "prompt_churn": {
      "detected": false,
      "sequences": 0                     // Consecutive similar prompts without progress
    },
    "tool_loops": {
      "detected": false,
      "count": 0                         // Same tool called 3+ times with same args
    },
    "phases": {
      "plan": true,
      "design": true,
      "code": true,
      "test": true,
      "docs": false
    },
    "quality": {
      "tests_passed": true,
      "coverage_percent": 78.5,
      "lint_clean": true,
      "build_passes": true
    }
  },

  // Score breakdown
  "deductions": [
    {
      "category": "missing-docs",        // Category identifier
      "points": -5,                       // Always negative
      "reason": "Docs phase not completed",
      "evidence": "phases.docs = false"
    }
  ],
  "bonuses": [
    {
      "category": "high-cache",
      "points": 5,                        // Always positive
      "reason": "Cache hit rate above 70%"
    }
  ],

  // Coaching output (v1.0: generated by Verifier as part of /wrap)
  "coaching": {
    "suggestions": [
      "Complete the docs phase to earn the full phase completion bonus."
    ],
    "celebration": "Great cache utilization! Your context management was efficient.",
    "claude_md_mutation": null            // Proposed CLAUDE.md addition | null
  }
}
```

### Score Calculation

```
base_score = 100
final_score = clamp(base_score + sum(deductions) + sum(bonuses), 0, 100)
```

**Deduction rules** (each applied at most once per session):

| Category | Points | Trigger |
|----------|--------|---------|
| `prompt-churn` | -5 per sequence | 3+ consecutive similar prompts without meaningful progress |
| `tool-loop` | -10 per loop | Same tool called 3+ times with identical arguments |
| `low-cache` | -15 | Cache hit rate below 30% |
| `context-violation` | -20 | Context usage exceeded 80% |
| `no-tests` | -10 | No tests ran during session |
| `no-spec` | -5 | Feature started without acceptance criteria |
| `missing-phase` | -3 per phase | Any Tier 2 phase skipped |

**Maximum total deductions:** -68 (all rules fire simultaneously). Minimum possible score: 32.

**Bonus rules:**

| Category | Points | Trigger |
|----------|--------|---------|
| `all-phases` | +5 | All 5 phases completed |
| `high-cache` | +5 | Cache hit rate above 70% |
| `full-coverage` | +3 | Test coverage above 80% |
| `clean-session` | +2 | Zero warnings triggered |

**Maximum total bonuses:** +15. Maximum possible score: 100 (clamped).

### Rating Thresholds

| Rating | Range | Meaning |
|--------|-------|---------|
| `excellent` | 90-100 | Exemplary session |
| `good` | 70-89 | Solid session |
| `needs-improvement` | 50-69 | Several issues detected |
| `review-session` | 0-49 | Significant problems — review workflow |

---

## 7. Signal Files

Ephemeral inter-agent communication. Created by one agent, consumed (read + deleted) by another. Used within Agent Teams coordination.

**File pattern:** `.vibeos/signals/<source-agent>-<event>.signal`

Signal files are JSON but use the `.signal` extension to distinguish them from persistent state.

### Signal Types

#### 7.1 Agent Completion Signal

Created when an agent finishes its task. Consumed by the Orchestrator.

```jsonc
{
  "schema_version": "1.0.0",
  "source": "builder",                  // Agent that created the signal
  "event": "complete",                   // "complete" | "failed" | "blocked"
  "timestamp": "2026-02-23T14:30:00Z",
  "feature_id": "feat-001",
  "summary": "Implemented login form and OAuth flow",

  // Event-specific payload
  "payload": {
    "files_created": ["src/auth/login.ts", "src/auth/oauth.ts"],
    "files_modified": ["src/routes.ts"],
    "worktree": ".claude/worktrees/builder-feat-001"
  }
}
```

#### 7.2 Test Results Signal

Created by Verifier after running tests. Consumed by Orchestrator.

```jsonc
{
  "schema_version": "1.0.0",
  "source": "verifier",
  "event": "test-results",
  "timestamp": "2026-02-23T15:00:00Z",
  "feature_id": "feat-001",
  "summary": "All tests passing",

  "payload": {
    "unit_tests": { "pass": 12, "fail": 0, "skip": 0 },
    "component_tests": { "pass": 8, "fail": 0, "skip": 0 },
    "a11y_tests": { "pass": 5, "fail": 0, "skip": 0 },
    "coverage": {
      "statements": 87,
      "branches": 82,
      "functions": 85,
      "lines": 87
    },
    "lint_clean": true,
    "build_passes": true
  }
}
```

#### 7.3 Research Complete Signal

Created by Stack Scout after completing a TDR. Consumed by Orchestrator.

```jsonc
{
  "schema_version": "1.0.0",
  "source": "stack-scout",
  "event": "research-complete",
  "timestamp": "2026-02-23T09:30:00Z",
  "feature_id": null,                    // null for Tier 1 TDR
  "summary": "Technology Decision Record complete",

  "payload": {
    "tdr_path": "tdr/technology-decision-record.md",
    "worktree": ".claude/worktrees/scout-tdr-001",
    "recommendations": ["Next.js 15", "Supabase", "Drizzle ORM"]
  }
}
```

### Signal Lifecycle

1. **Create:** Source agent writes the `.signal` file atomically (write to `.tmp`, rename)
2. **Consume:** Consumer agent reads the file, processes it, then deletes it
3. **Timeout:** Signals older than 1 hour are deleted by the cleanup mechanism in `check-context.sh`
4. **No polling:** Agent Teams `SendMessage` primitive notifies the consumer; signal file is the payload

---

## 8. Lock Files

Atomic locks to prevent concurrent writes to the same resource. Uses `mkdir`-based locking (atomic on all filesystems).

**Directory pattern:** `.vibeos/locks/<resource-name>/`

### Lock Structure

```
.vibeos/locks/state-json/
└── info.json
```

```jsonc
// info.json
{
  "locked_by": "builder",               // Agent name
  "pid": 12345,                          // Process ID of locking agent
  "locked_at": "2026-02-23T14:30:00Z",
  "target_file": ".vibeos/state.json",   // File being protected
  "timeout_seconds": 30                  // Auto-release after this duration
}
```

### Lock Protocol

1. **Acquire:** `mkdir .vibeos/locks/<name>` — succeeds atomically or fails if exists
2. **Write metadata:** Create `info.json` inside the lock directory
3. **Do work:** Read/modify the protected file
4. **Release:** `rm -rf .vibeos/locks/<name>`
5. **Stale detection:** If `locked_at + timeout_seconds` has passed, any agent may break the lock

### Lockable Resources

| Lock Name | Protects | Typical Holder |
|-----------|----------|----------------|
| `state-json` | `.vibeos/state.json` | Orchestrator, Builder |
| `backlog-json` | `.vibeos/backlog.json` | Orchestrator |
| `session-active` | Active session log | Session Startup |

---

## 9. Migration Strategy

### Version History

| Version | Changes | Migration |
|---------|---------|-----------|
| `1.0.0` | Initial release | N/A |

### Migration Mechanism

State file migrations are handled by the Session Startup agent on every session start:

1. Read `schema_version` from each `.vibeos/*.json` file
2. If version < current, apply migrations sequentially (1.0.0 → 1.1.0 → 1.2.0)
3. Write migrated file with updated `schema_version`
4. Log migration in session log

Migration functions are defined in `scripts/migrate-state.sh`:

```bash
#!/usr/bin/env bash
# migrate-state.sh — Run state file migrations
# Called by Session Startup agent on every session start

CURRENT_VERSION="1.0.0"

migrate_file() {
  local file="$1"
  local version
  version=$(jq -r '.schema_version // "0.0.0"' "$file" 2>/dev/null)

  if [ "$version" = "$CURRENT_VERSION" ]; then
    return 0  # Up to date
  fi

  # Future migrations go here:
  # if version_lt "$version" "1.1.0"; then
  #   migrate_1_0_to_1_1 "$file"
  # fi

  # Update schema_version
  local tmp="${file}.tmp"
  jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$file" > "$tmp" && mv "$tmp" "$file"
}

# Run on all state files
for f in .vibeos/config.json .vibeos/state.json .vibeos/backlog.json; do
  [ -f "$f" ] && migrate_file "$f"
done
```

### Backward Compatibility Rules

1. **Additive changes** (new optional fields) → minor version bump (1.0.0 → 1.1.0), auto-migrated by adding defaults
2. **Breaking changes** (field renames, structural changes) → major version bump (1.0.0 → 2.0.0), requires explicit migration function
3. **Signal files** are ephemeral and never migrated — old signals are simply deleted
4. **Lock files** are ephemeral and never migrated

---

## 10. Gamification State

Persistent progression state for the gamification system. Created by `/setup` (via `init-vibeos-state.sh`). Updated by gamification scripts during `/wrap`.

**File location:** `.vibeos/gamification.json`

```jsonc
{
  "schema_version": "1.0.0",

  // Player progression
  "level": 1,                                    // Current level (1-50)
  "xp": 0,                                       // Total lifetime XP
  "xp_this_level": 0,                            // XP earned toward current level
  "xp_to_next_level": 100,                       // XP needed to reach next level

  // Streak tracking
  "streak": {
    "current": 0,                                // Current consecutive-day streak
    "longest": 0,                                // All-time longest streak
    "last_session_date": null,                   // ISO date (YYYY-MM-DD) | null
    "grace_days_remaining": 2,                   // Grace days left this month (max 2)
    "frozen_today": false                        // Whether a grace day was used today
  },

  // Earned badges (array of badge event objects)
  "badges": [
    // {
    //   "id": "first-setup",                    // Badge ID from badge-catalog.json
    //   "earned_at": "2026-02-24T10:00:00Z"     // ISO 8601 timestamp
    // }
  ],

  // Skill tree (5 domains)
  "skills": {
    "prompting":            { "level": 0, "xp": 0, "max_level": 5 },
    "architecture":         { "level": 0, "xp": 0, "max_level": 5 },
    "testing":              { "level": 0, "xp": 0, "max_level": 5 },
    "context_management":   { "level": 0, "xp": 0, "max_level": 5 },
    "workflow_discipline":  { "level": 0, "xp": 0, "max_level": 5 }
  },

  // Challenges
  "active_challenges": [
    // {
    //   "id": "daily-clean-sweep",              // Challenge ID from challenge-pool.json
    //   "type": "daily",                        // "daily" | "weekly" | "onetime"
    //   "started_at": "2026-02-24T00:00:00Z",   // When the challenge became active
    //   "expires_at": "2026-02-25T00:00:00Z",   // When the challenge expires
    //   "progress": 0,                           // Current progress toward goal
    //   "target": 1                              // Target value for completion
    // }
  ],
  "completed_challenges": [
    // {
    //   "id": "daily-clean-sweep",
    //   "completed_at": "2026-02-24T15:00:00Z",
    //   "xp_awarded": 20
    // }
  ],

  // Quiz tracking
  "quizzes": {
    "completed": [],                             // Array of completed quiz IDs
    "correct_answers": 0,                        // Lifetime correct answers
    "total_questions": 0                         // Lifetime total questions attempted
  },

  // Level-gated feature unlocks
  "unlocked_features": [],                       // Array of feature IDs unlocked

  // Aggregate stats
  "stats": {
    "total_sessions": 0,
    "total_features_shipped": 0,
    "perfect_sessions": 0,                       // Sessions with score 90+ and 0 deductions
    "best_vibe_score": 0,
    "score_history": []                          // Array of {date, score} for sparkline
  }
}
```

### Leveling Curve

```
XP_needed = floor(100 * 1.15^(level - 1))
```

| Level | XP to Next | Cumulative XP | Title |
|-------|-----------|---------------|-------|
| 1 | 100 | 0 | Newcomer |
| 2-3 | 115-132 | 100-215 | Apprentice |
| 4-5 | 152-175 | 347-499 | Focused Builder |
| 6-8 | 201-266 | 674-1140 | Efficient Coder |
| 9-12 | 306-404 | 1406-2572 | Seasoned Viber |
| 13-18 | 465-808 | 2976-6546 | Workflow Master |
| 19-25 | 929-2113 | 7354-16620 | Context Architect |
| 26-35 | 2430-6621 | 18733-55416 | Vibe Sensei |
| 36-45 | 7614-17531 | 62037-144000 | Grand Master |
| 46-50 | 20161-28832 | 161531-282000 | Vibe Legend |

### Skill Tree Thresholds

5 levels per skill domain:

| Skill Level | Name | XP Required |
|-------------|------|-------------|
| 0 | Novice | 0 |
| 1 | Apprentice | 50 |
| 2 | Practitioner | 200 |
| 3 | Expert | 600 |
| 4 | Master | 1400 |

### Streak Rules

- Increment on calendar days where `/wrap` completes successfully
- Saturdays and Sundays do not break streaks and do not consume grace credits
- 2 grace days per month: missing one weekday preserves the streak
- Grace days reset on the 1st of each month
- Broken streaks reset to 0 with no XP penalty

### Unlockable Features

| Level | Feature Unlocked |
|-------|-----------------|
| 1 | Base VibeOS |
| 2 | Daily challenges |
| 3 | `/quiz` command |
| 5 | Weekly challenges, skill tree in `/achievements` |
| 8 | One-time challenges |
| 10 | Custom title in status line |
| 15 | Advanced quizzes |
| 20 | Detailed session analytics in `/status` |

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `level` | integer | yes | Current player level (1-50) |
| `xp` | integer | yes | Total lifetime XP |
| `xp_this_level` | integer | yes | XP earned toward current level |
| `xp_to_next_level` | integer | yes | XP needed for next level |
| `streak.current` | integer | yes | Current consecutive-day streak |
| `streak.longest` | integer | yes | All-time longest streak |
| `streak.last_session_date` | string\|null | yes | Last session date (YYYY-MM-DD) |
| `streak.grace_days_remaining` | integer | yes | Grace days left this month |
| `streak.frozen_today` | boolean | yes | Whether grace was used today |
| `badges` | array | yes | Earned badge objects |
| `skills.<domain>.level` | integer | yes | Skill domain level (0-5) |
| `skills.<domain>.xp` | integer | yes | Skill domain XP |
| `skills.<domain>.max_level` | integer | yes | Maximum skill level |
| `active_challenges` | array | yes | Currently active challenges |
| `completed_challenges` | array | yes | Completed challenge history |
| `quizzes.completed` | string[] | yes | Completed quiz IDs |
| `quizzes.correct_answers` | integer | yes | Lifetime correct answers |
| `quizzes.total_questions` | integer | yes | Lifetime total questions |
| `unlocked_features` | string[] | yes | Unlocked feature IDs |
| `stats.total_sessions` | integer | yes | Lifetime session count |
| `stats.total_features_shipped` | integer | yes | Lifetime features shipped |
| `stats.perfect_sessions` | integer | yes | Sessions with 90+ and 0 deductions |
| `stats.best_vibe_score` | integer | yes | All-time best score |
| `stats.score_history` | array | yes | Score data for sparkline |

---

## Appendix: Schema Decision Log

This section records why specific schema decisions were made, resolving conflicts from the original architecture documents.

### state.json — Resolution

Three competing definitions existed:

| Source | Top-Level Key | Artifact Format |
|--------|--------------|-----------------|
| installation.md | `project_foundation.status` | Boolean flags |
| safety.md | `foundation.complete` | Objects with `file`, `status`, `approved_at` |
| tech-stack.md | `foundation_complete` | Boolean flags + `tier` + `git` |

**Resolution:** Adopted `foundation.complete` pattern from safety.md (richest information) with the following adjustments:
- Kept `foundation.complete` (boolean) as the quick-check field (used by phase-gate hook)
- Kept per-artifact objects with `status`, `file`, `approved_at` (needed for `/status` display and audit trail)
- Added `git` object from tech-stack.md (needed by agents for branch operations)
- Added `active_feature` from installation.md (needed for Tier 2 tracking)
- Dropped `tier` field — derivable from `foundation.complete` (false = Tier 1, true = Tier 2)
- Dropped `current_phase` from top level — tracked in `active_feature.phase`

### backlog.json — Resolution

Three competing definitions existed:

| Source | Array Name | State Tracking | Spec Support |
|--------|-----------|---------------|--------------|
| installation.md | `features[]` | None shown | No |
| docs-site.md | `cards[]` | `column` (Kanban) | No |
| tech-stack.md | `features[]` | `status` field | `spec` object |

**Resolution:** Merged all three into a unified schema:
- Used `features[]` as the array name (not `cards[]` — "features" is the domain concept)
- Used `column` for Kanban state tracking (from docs-site.md — maps directly to Kanban board UI)
- Added `spec` object (from tech-stack.md — needed for feature planning)
- Added `columns` definition at top level (from docs-site.md — needed for WIP limits and Kanban rendering)
- Added `worktree`, `phases_completed`, `sessions` tracking (from state.json cross-reference needs)
- Dropped `history` array from docs-site.md — derivable from session logs, reduces write amplification
