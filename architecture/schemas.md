# VibeCrew Canonical Schemas

> **This is the single source of truth for all `.vibecrew/` JSON file schemas.**
> All other architecture documents MUST reference this file rather than defining schemas inline.
> Schema version: `1.5.0`

---

## Table of Contents

1. [Conventions](#1-conventions)
2. [config.json](#2-configjson)
3. [state.json](#3-statejson)
4. [backlog.json](#4-backlogjson)
5. [Session Logs](#5-session-logs)
6. [Score Files](#6-score-files)
7. [Signal Files](#7-signal-files)
8. [Issue Fix Reports](#8-issue-fix-reports)
9. [Lock Files](#9-lock-files)
10. [Migration Strategy](#10-migration-strategy)
11. [Gamification State](#11-gamification-state)
12. [Project Registry](#12-project-registry)
13. [Telemetry Aggregate](#13-telemetry-aggregate)
14. [System Review Report](#14-system-review-report)
15. [Expertise Records](#15-expertise-records)
16. [Drift Tracker](#16-drift-tracker)
17. [Erosion Schemas](#17-erosion-schemas)
18. [Structured Plan Tasks](#18-structured-plan-tasks)
19. [Codebase Analysis Documents](#19-codebase-analysis-documents)
20. [EARS (Easy Approach to Requirements Syntax)](#20-ears-easy-approach-to-requirements-syntax)
21. [Decision Categories (Locked/Deferred/Discretion)](#21-decision-categories-lockeddeferreddiscretion)
22. [Agent Memory Records](#22-agent-memory-records)

---

## 1. Conventions

### Field Naming

- **snake_case** for all JSON keys (consistent with Claude Code internals)
- **ISO 8601** for all timestamps (`2026-02-23T10:00:00Z`)
- **Semantic versioning** for `schema_version` fields (`"1.0.0"`)
- **Kebab-case** for feature IDs (`feat-001`), session IDs (`session-2026-02-23-001`), and file names
- **Enum values** use kebab-case (`in-progress`, not `inProgress` or `IN_PROGRESS`)

### Schema Version Contract

Every `.vibecrew/` JSON file includes a top-level `schema_version` field. When VibeCrew reads a file:

1. If `schema_version` matches the current version → use as-is
2. If `schema_version` is older → run migration (see [Section 9](#9-migration-strategy))
3. If `schema_version` is missing → treat as `"0.0.0"` and migrate
4. If `schema_version` is newer → warn user and refuse to modify (forward-compatibility guard)

### File Locations

```
.vibecrew/
├── config.json                          # User preferences (per-project)
├── state.json                           # Project state + active feature
├── backlog.json                         # Feature backlog with specs
├── gamification.json                    # Gamification state (XP, badges, streaks)
├── sessions/
│   └── session-<ISO-date>-<NNN>.json    # Per-session logs
├── scores/
│   └── score-<ISO-date>-<NNN>.json      # Per-session Vibe Score breakdowns
├── architecture/
│   ├── system.mmd                       # Infrastructure topology (flowchart TD)
│   ├── schema.mmd                       # Entity-relationship diagram (erDiagram)
│   ├── state-flows.mmd                  # Auth states and user flows (stateDiagram-v2)
│   ├── api-sequences.mmd               # Request/response patterns (sequenceDiagram)
│   └── component-tree.mmd              # Component hierarchy with data flow (flowchart TD)
├── signals/
│   └── <agent>-<event>.signal           # Ephemeral inter-agent signals (JSON)
├── locks/
│   └── <resource>/                      # mkdir-based atomic locks
│       └── info.json                    # Lock metadata
├── expertise/
│   └── <domain>.jsonl                   # JSONL expertise records (one per domain)
├── erosion/
│   ├── baseline.json                    # Project baseline (captured after first feature)
│   ├── erosion-<TIMESTAMP>.json         # Per-session erosion snapshots
│   └── trends.json                      # Rolling 20-session trend summary
└── drift-tracker.json                   # Ephemeral drift tracking (reset per session)
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

  // MCP server toggles (synced by enable-mcp-server.sh and add-mcp-server.sh)
  "mcp_servers": {
    "context7": true,                    // Documentation lookup
    "chrome_devtools": true,             // Browser debugging and automation
    "playwright": true,                  // E2E browser debugging
    "semgrep": false,                    // Static security analysis
    "sentry": false,                     // Production error context
    "supabase": false,                   // Database schema inspection
    "stripe": false,                     // Payment product management
    "vercel": false,                     // Deployment management
    "figma": false                       // Design spec extraction
    // Additional servers added from registry (e.g. firebase, clerk, mongodb)
  },

  // MCP discovery preferences (controls TDR-based server recommendations)
  "mcp_discovery": {
    "auto_recommend": true,              // Show recommendations after TDR sync
    "auto_add": false                    // Add all recommended servers without asking
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
| `mcp_servers.chrome_devtools` | boolean | yes | `true` | Chrome DevTools MCP enabled |
| `mcp_servers.playwright` | boolean | yes | `true` | Playwright MCP enabled |
| `mcp_servers.semgrep` | boolean | yes | `false` | Semgrep MCP enabled |
| `mcp_servers.sentry` | boolean | yes | `false` | Sentry MCP enabled |
| `mcp_servers.supabase` | boolean | yes | `false` | Supabase MCP enabled |
| `mcp_servers.stripe` | boolean | yes | `false` | Stripe MCP enabled |
| `mcp_servers.vercel` | boolean | yes | `false` | Vercel MCP enabled |
| `mcp_servers.figma` | boolean | yes | `false` | Figma MCP enabled |
| `formatting.auto_format` | boolean | yes | `true` | Auto-format on file writes |
| `formatting.formatter` | enum | yes | `"prettier"` | Formatter to use |
| `context_warnings.warn_at_percent` | integer | yes | `60` | Warning threshold (%) |
| `context_warnings.critical_at_percent` | integer | yes | `80` | Critical threshold (%) |
| `cost_limits.session_warn_usd` | number | yes | `2.00` | Session cost warning |
| `cost_limits.session_max_usd` | number | yes | `5.00` | Session cost hard limit |
| `cost_limits.daily_warn_usd` | number | yes | `20.00` | Daily cost warning |
| `git_provider` | enum\|null | no | `null` | `"github"\|"gitlab"\|null` (null = auto-detect from remote) |
| `issues.enabled` | boolean | yes | `false` | Issue tracking integration enabled (migrated from `github_issues`) |
| `issues.autofix_label` | string | yes | `"autofix"` | Label that triggers auto-fix |
| `issues.default_mode` | enum | yes | `"hotfix"` | `hotfix\|feature` — default fix mode |
| `issues.auto_pr` | boolean | yes | `true` | Auto-create PR/MR after fix |
| `issues.sync_limit` | integer | yes | `10` | Max issues to import per sync |
| `user_profile.interview_completed` | boolean | yes | `false` | Profile interview done |
| `user_profile.code_literacy` | enum | yes | `"conversational"` | `fluent\|conversational\|basic\|none` |
| `user_profile.autonomy` | enum | yes | `"checkpoints"` | `full_auto\|checkpoints\|collaborative\|supervised` |
| `user_profile.pr_review` | enum | yes | `"review"` | `auto_merge\|summary\|review\|walkthrough` |
| `user_profile.verbosity` | enum | yes | `"standard"` | `minimal\|standard\|detailed\|educational` |
| `user_profile.gamification_preference` | enum | yes | `"full"` | `full\|light\|score_only\|disabled` |
| `user_profile.learning` | enum | yes | `"reference_docs"` | `none\|reference_docs\|inline\|teach` |
| `user_profile.risk_tolerance` | enum | yes | `"balanced"` | `conservative\|balanced\|progressive\|experimental` |
| `user_profile.updated_at` | string\|null | yes | `null` | ISO 8601 timestamp of last profile update |

---

## 3. state.json

Project state tracking. Created by `/new-project` (Tier 1) or `/setup` (existing project). Modified by agents during workflow progression.

```jsonc
{
  "schema_version": "1.2.0",

  // Tier 1: Project Foundation
  "foundation": {
    "complete": false,                   // true when ALL 6 artifacts approved
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
      "architecture_diagrams": {
        "status": "pending",
        "file": null,                    // ".vibecrew/architecture/" once created
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
    "phases_completed": [],              // Completed phases for this feature
    "plan_revision_count": 0,             // Times plan/spec revised mid-feature (reset on claim)
    "plan_commit_sha": null               // Git SHA at plan phase completion (reset on claim)
  },

  // Paused feature (set by /pause, cleared by /resume)
  "paused_feature": {
    "id": null,                          // Feature ID | null (no paused feature)
    "name": null,                        // Human-readable name
    "phase": null,                       // Phase at time of pause
    "branch": null,                      // Git branch name (preserved, never deleted)
    "commit": null,                      // HEAD commit at pause time
    "paused_at": null,                   // ISO 8601 timestamp
    "worktree": null,                    // Original worktree path (for recreation)
    "phases_completed": [],              // Preserved from active_feature
    "plan_revision_count": 0,            // Preserved from active_feature
    "plan_commit_sha": null              // Preserved from active_feature
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

`foundation.complete` flips to `true` only when ALL six artifacts have `status: "complete"`. This is the gate that the phase-gate hook checks.

### Active Feature Phase Values

The `active_feature.phase` field uses these values:

```
"plan" | "design" | "code" | "test" | "review" | "docs" | null
```

Phases are **sequential by default** but can be re-entered if issues are found during verification:

```
plan → design → code → test → review → docs → (done)
              ↖─── verify-fix loops ───↙
```

The `phases_completed` array tracks which phases have been completed at least once. A phase can be re-entered (e.g., going back from `test` to `code` to fix a bug) — the phase stays in `phases_completed` and the agent records the re-entry in the session log.

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `foundation.complete` | boolean | yes | All 6 artifacts approved |
| `foundation.completed_at` | string\|null | yes | When foundation was completed |
| `foundation.artifacts.<name>.status` | enum | yes | `pending`\|`in-progress`\|`complete` |
| `foundation.artifacts.<name>.file` | string\|null | yes | Relative file path |
| `foundation.artifacts.<name>.approved_at` | string\|null | yes | Approval timestamp |
| `active_feature.id` | string\|null | yes | Feature ID from backlog |
| `active_feature.name` | string\|null | yes | Human-readable name |
| `active_feature.worktree` | string\|null | yes | Git worktree path |
| `active_feature.phase` | enum\|null | yes | Current workflow phase |
| `active_feature.phases_completed` | string[] | yes | Completed phase names |
| `active_feature.plan_revision_count` | number | yes | Times plan/spec revised mid-feature (reset on claim) |
| `active_feature.plan_commit_sha` | string\|null | yes | Git SHA at plan phase completion. Used by check-plan-staleness.sh to detect codebase drift before Code phase. Reset to null on claim-task. |
| `paused_feature.id` | string\|null | no | ID of paused feature (set by `/pause`, cleared by `/resume`) |
| `paused_feature.name` | string\|null | no | Name of paused feature |
| `paused_feature.phase` | enum\|null | no | Phase at time of pause |
| `paused_feature.branch` | string\|null | no | Git branch (preserved, never deleted) |
| `paused_feature.commit` | string\|null | no | HEAD commit SHA at pause |
| `paused_feature.paused_at` | string\|null | no | ISO 8601 timestamp of pause |
| `git.default_branch` | string | yes | Default git branch |
| `git.initialized` | boolean | yes | Whether git repo exists |
| `updated_at` | string | yes | Last modification timestamp |

### Plan Staleness Report (`check-plan-staleness.sh` output)

| Field | Type | Description |
|-------|------|-------------|
| `stale` | boolean | Whether any plan-referenced files changed |
| `plan_sha` | string | SHA recorded at plan completion |
| `current_sha` | string | Current HEAD SHA |
| `commits_since_plan` | number | Count of commits between SHAs |
| `affected_files` | array | Files changed that are referenced in the plan |
| `affected_files[].path` | string | File path |
| `affected_files[].change_type` | string | `modified` \| `deleted` \| `renamed` |
| `affected_files[].insertions` | number | Lines added |
| `affected_files[].deletions` | number | Lines removed |
| `unaffected_plan_files` | string[] | Plan-referenced files with no changes |
| `severity` | string | `none` \| `minor` \| `major` \| `critical` |
| `recommendation` | string | `proceed` \| `review_changes` \| `refresh_plan` |

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
    { "id": "planning",    "title": "Planning",       "wip_limit": 2 },
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
      "complexity": "standard",          // "trivial" | "standard" | "complex" (default: "standard")
      "labels": ["auth", "security"],

      // Spec (populated during "plan" phase)
      "spec": {
        "problem_statement": null,       // What problem this feature solves | null
        "acceptance_criteria": [],       // String array of requirements
        "ui_description": null,          // Brief UI description | null
        "business_logic": [],            // String array of logic requirements
        "technical_notes": null,         // Free-text technical considerations | null
        "milestones": []                 // Optional: [{name, description, criteria_indices, estimated_files, status, depends_on}]
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
idea → planning → planned → in-progress → testing → review → done
```

| Transition | Trigger |
|-----------|---------|
| `idea → planning` | `/plan-features` or user drags in dashboard |
| `planning → planned` | Spec populated (acceptance criteria defined) |
| `planned → in-progress` | `/new-feature` or `/run-backlog` picks it up |
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
| `complexity` | enum | no | `"trivial"` \| `"standard"` \| `"complex"`. Default: `"standard"`. Controls which phases run |
| `labels` | string[] | yes | Categorization labels |
| `spec.problem_statement` | string\|null | yes | What problem this feature solves |
| `spec.expected_action` | string\|null | no | Expected user action (e.g., "click Subscribe", "complete setup wizard") |
| `spec.acceptance_criteria` | string[] | yes | List of requirements |
| `spec.ui_description` | string\|null | yes | UI description |
| `spec.business_logic` | string[] | yes | Business logic requirements |
| `spec.technical_notes` | string\|null | no | Technical considerations |
| `spec.milestones` | object[] | no | Optional milestone array: `[{name, description, criteria_indices, estimated_files, status, depends_on}]`. Status: `"pending"` \| `"complete"`. `depends_on`: optional string[] of milestone names that must complete first. Milestones without `depends_on` default to Wave 1 (but >3 without explicit deps falls back to sequential). |
| `worktree` | string\|null | yes | Active worktree path |
| `phases_completed` | string[] | yes | Completed phases |
| `sessions` | string[] | yes | Related session IDs |
| `created_at` | string | yes | Creation timestamp |
| `updated_at` | string | yes | Last modification timestamp |
| `completed_at` | string\|null | yes | Completion timestamp |
| `source` | string\|null | no | Origin: `"issue"`, `"competitive-analysis"`, or null |
| `type` | string\|null | no | `"hotfix"` or `"feature"` or null |
| `provider` | string\|null | no | `"github"`, `"gitlab"`, or null |
| `issue_number` | integer\|null | no | Issue number (migrated from `github_issue_number`) |
| `issue_url` | string\|null | no | Issue URL (migrated from `github_issue_url`) |

---

## 5. Session Logs

Per-session activity records. Created by Session Startup agent at session start, updated by `/wrap` command at session end.

**File patterns:**
- `.vibecrew/sessions/session-<YYYY-MM-DD>-<NNN>.json` — standard session logs
- `.vibecrew/sessions/quick-fix-<timestamp>.json` — quick fix logs (type: `"quick_fix"`)
- `.vibecrew/sessions/backlog-run-<timestamp>.json` — backlog run logs (type: `"backlog_run"`, includes `wave_log` in `feature_results[]`)

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

**File pattern:** `.vibecrew/scores/score-<YYYY-MM-DD>-<NNN>.json`

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
    },
    "visual_compliance": {
      "verified": false,                   // Whether visual verification ran
      "console_errors": 0,                 // Console error-level messages found
      "token_violations": 0,               // Computed style vs design-system.css mismatches
      "viewports_checked": 0,              // Number of viewports tested (Builder: 1, Code Reviewer: 3)
      "clean": false                       // true when verified && zero errors && zero violations
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
| `context-violation` | -20 | Context usage exceeded 60% |
| `no-tests` | -10 | No tests ran during session |
| `no-spec` | -5 | Feature started without acceptance criteria |
| `missing-phase` | -3 per phase | Any Tier 2 phase skipped |

**Maximum total deductions:** -68 (all rules fire simultaneously). Minimum possible score: 32.

**Bonus rules:**

| Category | Points | Trigger |
|----------|--------|---------|
| `all-phases` | +5 | All 6 phases completed |
| `high-cache` | +5 | Cache hit rate above 70% |
| `full-coverage` | +3 | Test coverage above 80% |
| `clean-session` | +2 | Zero warnings triggered |
| `tdd-discipline` | +3 | Commits with `TDD cycle:` trailer detected |
| `e2e-passing` | +3 | Playwright spec files exist and tests pass |
| `a11y-clean` | +2 | axe-core report with zero critical/serious violations |
| `code-review` | +2 | Review report exists in `.vibecrew/reviews/` |
| `perf-baselines` | +2 | k6 results exist in `.vibecrew/perf-tests/` |

**Maximum total bonuses:** +27. Maximum possible score: 100 (clamped).

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

**File pattern:** `.vibecrew/signals/<source-agent>-<event>.signal`

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

#### 7.4 Builder Complete Signal (with changed_files)

Created by Builder when the code phase finishes. Includes a `changed_files` list so the Verifier can optimize test targeting.

```jsonc
{
  "schema_version": "1.0.0",
  "source": "builder",
  "event": "complete",
  "timestamp": "2026-03-01T14:30:00Z",
  "feature_id": "feat-001",
  "summary": "Implemented login form and OAuth flow",

  "payload": {
    "files_created": ["src/auth/login.ts", "src/auth/oauth.ts"],
    "files_modified": ["src/routes.ts"],
    "worktree": ".claude/worktrees/builder-feat-001",
    "changed_files": [
      {"path": "src/auth/login.ts", "type": "added"},
      {"path": "src/auth/oauth.ts", "type": "added"},
      {"path": "src/routes.ts", "type": "modified"}
    ],
    "business_patterns_applied": [          // Optional — names of business patterns from business-patterns.md
      "Inline Validation",
      "CTA Hierarchy",
      "Empty State Onboarding"
    ],
    "visual_verification": {               // Optional — included when frontend files changed
      "screenshots": 1,                    // Number of screenshots taken
      "console_errors": 0,                 // Console error-level messages found
      "token_violations": 0,               // Computed style vs design-system.css mismatches
      "viewport": "1440px",                // Viewport width used
      "iterations": 1,                     // Visual-fix iterations (max 2)
      "skipped": false,                    // true if visual verification was skipped
      "reason": null                       // Reason for skipping: "playwright_unavailable" | "no_frontend_changes" | "no_dev_server" | null
    }
  }
}
```

The `visual_verification` field is included when the Builder's changed files contain frontend extensions (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`). If Playwright MCP is unavailable or no dev server can be started, `skipped` is `true` with a `reason`. The Verifier reads this field during Vibe Score calculation to apply visual compliance deductions and bonuses.

The `changed_files` array is populated by running:

```bash
git diff --name-status HEAD~$(git rev-list --count origin/main..HEAD) -- | awk '{print "{\"path\":\"" $2 "\",\"type\":\"" ($1=="A"?"added":($1=="M"?"modified":"deleted")) "\"}"}' | jq -s '.'
```

If the git command fails, the `changed_files` field may be omitted. The Verifier falls back to `git diff` for change detection.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `payload.changed_files` | array | no | Files changed during code phase |
| `payload.changed_files[].path` | string | yes (if array present) | Relative file path |
| `payload.changed_files[].type` | enum | yes (if array present) | `"added"` \| `"modified"` \| `"deleted"` |
| `payload.visual_verification` | object | no | Visual verification results (frontend changes only) |
| `payload.visual_verification.screenshots` | integer | no | Number of screenshots taken |
| `payload.visual_verification.console_errors` | integer | no | Console error-level messages found |
| `payload.visual_verification.token_violations` | integer | no | Computed style vs design-system.css mismatches |
| `payload.visual_verification.viewport` | string | no | Viewport width (e.g., `"1440px"`) |
| `payload.visual_verification.iterations` | integer | no | Visual-fix iterations performed (max 2) |
| `payload.visual_verification.skipped` | boolean | no | Whether visual verification was skipped |
| `payload.visual_verification.reason` | string\|null | no | Skip reason: `"playwright_unavailable"` \| `"no_frontend_changes"` \| `"no_dev_server"` |

#### 7.5 Builder Review Feedback Signal

Created by the Orchestrator when a Code Reviewer verdict is `request-changes`. Consumed by the Builder to address critical findings in a structured fix cycle.

**File path:** `.vibecrew/signals/builder-review-feedback.json`

```jsonc
{
  "feature_id": "feat-001",
  "review_file": ".vibecrew/reviews/review-feat-001-20260301.json",
  "cycle": 1,                              // Current review-fix cycle (1 or 2)
  "critical_findings": [
    {
      "file": "src/components/Example.tsx",
      "line": 42,
      "title": "Missing null check",
      "description": "Props can be undefined when component mounts before data loads.",
      "suggestion": "Add optional chaining: props?.value instead of props.value"
    }
  ],
  "timestamp": "2026-03-01T10:00:00Z"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `feature_id` | string | yes | Feature ID from backlog |
| `review_file` | string | yes | Path to the review JSON that triggered the feedback |
| `cycle` | integer | yes | Current review-fix cycle number (1 or 2) |
| `critical_findings` | array | yes | Critical findings extracted from the review |
| `critical_findings[].file` | string | yes | Source file containing the issue |
| `critical_findings[].line` | integer | yes | Line number of the issue |
| `critical_findings[].title` | string | yes | Short title of the finding |
| `critical_findings[].description` | string | yes | Detailed description of the problem |
| `critical_findings[].suggestion` | string | yes | Suggested fix |
| `timestamp` | string | yes | ISO 8601 timestamp when feedback was created |

**Lifecycle:** Maximum 2 review-fix cycles. After 2 cycles without resolution, the feature is marked as `blocked` with reason "Review findings unresolved after 2 cycles".

### Signal Lifecycle

1. **Create:** Source agent writes the `.signal` file atomically (write to `.tmp`, rename)
2. **Consume:** Consumer agent reads the file, processes it, then deletes it
3. **Timeout:** Signals older than 1 hour are deleted by the cleanup mechanism in `check-context.sh`
4. **No polling:** Agent Teams `SendMessage` primitive notifies the consumer; signal file is the payload

---

## 8. Issue Fix Reports

Per-issue fix reports. Created by `/fix-issue` on completion. Used by Performance Coach for trend analysis and by `/status` for issue fix history.

**File pattern:** `.vibecrew/issue-fixes/fix-<number>-<YYYYMMDDTHHMMSSZ>.json`

```jsonc
{
  "schema_version": "1.8.0",

  // Issue identity
  "issue_number": 42,                    // Issue number (GitHub or GitLab)
  "provider": "github",                  // "github" | "gitlab"
  "title": "Login button unresponsive",  // Issue title
  "url": "https://github.com/user/repo/issues/42",

  // Backlog mapping
  "feature_id": "feat-007",             // VibeCrew backlog feature ID

  // Fix details
  "branch": "fix/issue-42",             // Git branch used for the fix
  "mode": "hotfix",                      // "hotfix" | "feature"
  "outcome": "fixed",                    // "fixed" | "failed" | "skipped"
  "pr_url": "https://github.com/user/repo/pull/43",  // PR (GitHub) or MR (GitLab) URL
  "pr_number": 43,                       // PR/MR number | null
  "commit_sha": "abc1234",              // Fix commit SHA | null

  // Files changed
  "files_modified": [
    "src/components/LoginButton.tsx",
    "src/components/__tests__/LoginButton.test.tsx"
  ],

  // Quality gate results
  "quality_gate": {
    "tests": "pass",                     // "pass" | "fail" | null
    "build": "pass",
    "lint": "pass",
    "typecheck": "pass"
  },

  // Execution metadata
  "attempts": 1,                         // Number of quality gate attempts (1-3)
  "started_at": "2026-03-01T10:00:00Z",
  "completed_at": "2026-03-01T10:15:00Z"
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `issue_number` | integer | yes | Issue number (GitHub or GitLab) |
| `provider` | enum | yes | `"github"` or `"gitlab"` |
| `title` | string | yes | Issue title |
| `url` | string | yes | Issue URL (GitHub or GitLab) |
| `feature_id` | string | yes | Backlog feature ID |
| `branch` | string | yes | Git branch for the fix |
| `mode` | enum | yes | `"hotfix"` or `"feature"` |
| `outcome` | enum | yes | `"fixed"`, `"failed"`, or `"skipped"` |
| `pr_url` | string\|null | yes | PR/MR URL or null |
| `pr_number` | integer\|null | yes | PR/MR number or null |
| `commit_sha` | string\|null | yes | Commit SHA or null |
| `files_modified` | string[] | yes | Paths of modified files |
| `quality_gate.tests` | enum\|null | yes | `"pass"`, `"fail"`, or null |
| `quality_gate.build` | enum\|null | yes | `"pass"`, `"fail"`, or null |
| `quality_gate.lint` | enum\|null | yes | `"pass"`, `"fail"`, or null |
| `quality_gate.typecheck` | enum\|null | yes | `"pass"`, `"fail"`, or null |
| `attempts` | integer | yes | Number of quality gate attempts |
| `started_at` | string | yes | ISO 8601 start timestamp |
| `completed_at` | string | yes | ISO 8601 completion timestamp |

---

## 9. Lock Files

Atomic locks to prevent concurrent writes to the same resource. Uses `mkdir`-based locking (atomic on all filesystems).

**Directory pattern:** `.vibecrew/locks/<resource-name>/`

### Lock Structure

```
.vibecrew/locks/state-json/
└── info.json
```

```jsonc
// info.json
{
  "locked_by": "builder",               // Agent name
  "pid": 12345,                          // Process ID of locking agent
  "locked_at": "2026-02-23T14:30:00Z",
  "target_file": ".vibecrew/state.json",   // File being protected
  "timeout_seconds": 30                  // Auto-release after this duration
}
```

### Lock Protocol

1. **Acquire:** `mkdir .vibecrew/locks/<name>` — succeeds atomically or fails if exists
2. **Write metadata:** Create `info.json` inside the lock directory
3. **Do work:** Read/modify the protected file
4. **Release:** `rm -rf .vibecrew/locks/<name>`
5. **Stale detection:** If `locked_at + timeout_seconds` has passed, any agent may break the lock

### Lockable Resources

| Lock Name | Protects | Typical Holder |
|-----------|----------|----------------|
| `state-json` | `.vibecrew/state.json` | Orchestrator, Builder |
| `backlog-json` | `.vibecrew/backlog.json` | Orchestrator |
| `session-active` | Active session log | Session Startup |

---

## 10. Migration Strategy

### Version History

| Version | Changes | Migration |
|---------|---------|-----------|
| `1.0.0` | Initial release | N/A |
| `1.4.0` | Added `user_profile` section to `config.json` | `migrate_1_3_to_1_4()` — injects `user_profile` with balanced defaults |

### Migration Mechanism

State file migrations are handled by the Session Startup agent on every session start:

1. Read `schema_version` from each `.vibecrew/*.json` file
2. If version < current, apply migrations sequentially (1.0.0 → … → 1.4.0)
3. Write migrated file with updated `schema_version`
4. Log migration in session log

Migration functions are defined in `scripts/migrate-state.sh`:

```bash
#!/usr/bin/env bash
# migrate-state.sh — Run state file migrations
# Called by Session Startup agent on every session start

CURRENT_VERSION="1.4.0"

migrate_file() {
  local file="$1"
  local version
  version=$(jq -r '.schema_version // "0.0.0"' "$file" 2>/dev/null)

  if [ "$version" = "$CURRENT_VERSION" ]; then
    return 0  # Up to date
  fi

  # 1.3.0 → 1.4.0: Add user_profile to config.json
  if version_lt "$version" "1.4.0"; then
    migrate_1_3_to_1_4 "$file"
  fi

  # Update schema_version
  local tmp="${file}.tmp"
  jq --arg v "$CURRENT_VERSION" '.schema_version = $v' "$file" > "$tmp" && mv "$tmp" "$file"
}

# Run on all state files
for f in .vibecrew/config.json .vibecrew/state.json .vibecrew/backlog.json; do
  [ -f "$f" ] && migrate_file "$f"
done
```

### Backward Compatibility Rules

1. **Additive changes** (new optional fields) → minor version bump (1.0.0 → 1.1.0), auto-migrated by adding defaults
2. **Breaking changes** (field renames, structural changes) → major version bump (1.0.0 → 2.0.0), requires explicit migration function
3. **Signal files** are ephemeral and never migrated — old signals are simply deleted
4. **Lock files** are ephemeral and never migrated

---

## 11. Gamification State

Persistent progression state for the gamification system. Created by `/setup` (via `init-vibecrew-state.sh`). Updated by gamification scripts during `/wrap`.

**File location:** `.vibecrew/gamification.json`

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
| 1 | Base VibeCrew |
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

---

## 12. Project Registry

Central registry of projects using VibeCrew. Lives at `${CLAUDE_PLUGIN_ROOT}/project-registry.json` (plugin root, not per-project). Created automatically during `/setup` if missing.

**File location:** `${CLAUDE_PLUGIN_ROOT}/project-registry.json`

```jsonc
{
  "schema_version": "1.0.0",

  "projects": [
    {
      "path": "/Users/user/projects/my-app",      // Absolute path to project root
      "registered_at": "2026-02-24T10:00:00Z",    // ISO 8601 registration timestamp
      "alias": "project-001"                        // Anonymous ID for telemetry reports
    }
  ]
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `projects` | array | yes | Registered project entries |
| `projects[].path` | string | yes | Absolute path to project root |
| `projects[].registered_at` | string | yes | ISO 8601 registration timestamp |
| `projects[].alias` | string | yes | Anonymous ID (project-NNN format) |

### Registration Rules

- Projects register automatically during `/setup` via `init-vibecrew-state.sh`
- Registration is idempotent — running `/setup` twice does not create duplicate entries
- The `alias` is auto-generated sequentially (project-001, project-002, etc.)
- The registry file is gitignored in the plugin repo (contains user-specific paths)

---

## 13. Telemetry Aggregate

Anonymized cross-project performance data. Generated by `collect-telemetry.sh` from all registered projects. Read by the System Reviewer agent during `/system-review`.

**File location:** `${CLAUDE_PLUGIN_ROOT}/telemetry/aggregate.json`

```jsonc
{
  "schema_version": "1.0.0",
  "collected_at": "2026-02-24T15:00:00Z",         // When this aggregate was generated
  "project_count": 3,                               // Number of projects with data

  "projects": [
    {
      "alias": "project-001",                       // Anonymous ID (never real paths)
      "session_count": 12,                           // Total sessions in this project
      "avg_vibe_score": 87,                          // Average Vibe Score
      "top_deductions": ["prompt-churn", "tool-loops"],  // Most common deduction categories
      "top_bonuses": ["all-phases", "tdd-discipline"],   // Most common bonus categories
      "avg_context_usage": 42,                       // Average peak context %
      "avg_session_cost_usd": 1.20,                  // Average session cost
      "agent_usage": {                               // Invocation counts per agent
        "builder": 10,
        "verifier": 8,
        "stack-scout": 2
      },
      "mcp_servers_enabled": ["context7", "playwright", "supabase"],
      "mutations_proposed": 3,                       // CLAUDE.md mutation proposals
      "mutations_applied": 2,                        // Applied mutations
      "test_pass_rate": 0.92,                        // Test pass/total ratio
      "avg_coverage": 78,                            // Average test coverage %
      "features_completed": 5,                       // Features moved to "done"
      "terminal": "warp"                             // Terminal emulator
    }
  ],

  "aggregates": {
    "total_sessions": 36,                            // Sum across all projects
    "avg_vibe_score_all": 84,                        // Weighted average
    "most_common_deductions": [                      // Sorted by frequency
      { "category": "tool-loops", "count": 15 }
    ],
    "least_used_skills": [                           // Skills with lowest invocations
      { "skill": "simplify", "total_invocations": 0 }
    ],
    "least_used_agents": [                           // Agents with lowest invocations
      { "agent": "opponent-processor", "total_invocations": 1 }
    ],
    "avg_cost_per_session": 1.35,                    // Global average
    "mcp_adoption": {                                // Server → project count
      "context7": 3,
      "playwright": 2,
      "supabase": 1,
      "semgrep": 0
    }
  }
}
```

### Anonymization Rules

The following data is **collected** (anonymized):
- Vibe Score values and deduction/bonus categories (no file paths)
- Token usage (input, output, cache ratio) and costs
- Agent invocation counts (which agents, not what they did)
- MCP server configurations
- Test pass rates and coverage percentages
- Mutation proposal/application counts

The following data is **NOT collected**:
- Project names, paths, or git URLs (replaced by aliases)
- File names, code, or commit messages
- Feature names or backlog items
- Environment variables or credentials

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `collected_at` | string | yes | ISO 8601 collection timestamp |
| `project_count` | integer | yes | Number of projects with data |
| `projects` | array | yes | Per-project anonymized data |
| `projects[].alias` | string | yes | Anonymous project ID |
| `projects[].session_count` | integer | yes | Total session count |
| `projects[].avg_vibe_score` | integer | yes | Average Vibe Score |
| `projects[].top_deductions` | string[] | yes | Most common deduction categories |
| `projects[].top_bonuses` | string[] | yes | Most common bonus categories |
| `projects[].avg_context_usage` | integer | yes | Average peak context % |
| `projects[].avg_session_cost_usd` | number | yes | Average cost per session |
| `projects[].agent_usage` | object | yes | Agent name → invocation count |
| `projects[].mcp_servers_enabled` | string[] | yes | Enabled MCP server names |
| `projects[].mutations_proposed` | integer | yes | Mutation proposal count |
| `projects[].mutations_applied` | integer | yes | Applied mutation count |
| `projects[].test_pass_rate` | number | yes | Test pass/total ratio |
| `projects[].avg_coverage` | integer | yes | Average test coverage % |
| `projects[].features_completed` | integer | yes | Completed feature count |
| `projects[].terminal` | string | yes | Terminal emulator type |
| `aggregates.total_sessions` | integer | yes | Sum of all sessions |
| `aggregates.avg_vibe_score_all` | integer | yes | Global average score |
| `aggregates.most_common_deductions` | array | yes | Deduction frequency list |
| `aggregates.least_used_skills` | array | yes | Underused skills |
| `aggregates.least_used_agents` | array | yes | Underused agents |
| `aggregates.avg_cost_per_session` | number | yes | Global average cost |
| `aggregates.mcp_adoption` | object | yes | Server name → project count |

---

## 14. System Review Report

Structured output from the System Reviewer agent. Created by `/system-review`. Both JSON and markdown versions are saved.

**File pattern:** `${CLAUDE_PLUGIN_ROOT}/reviews/system-review-<TIMESTAMP>.json`

```jsonc
{
  "schema_version": "1.0.0",

  // Identity
  "review_id": "SYS-REVIEW-20260224-001",         // Unique review identifier
  "created_at": "2026-02-24T15:30:00Z",            // ISO 8601 creation timestamp
  "plugin_version": "1.4.0",                        // Plugin version at review time

  // Telemetry context
  "telemetry_summary": {
    "project_count": 3,                              // Projects analyzed
    "total_sessions": 36,                            // Total sessions analyzed
    "avg_vibe_score": 84                             // Average score across projects
  },

  // Findings (from internal audit, telemetry, and external research)
  "findings": [
    {
      "id": "FND-001",                               // Unique finding ID
      "category": "model-routing",                    // Finding category (see below)
      "severity": "medium",                           // "info" | "low" | "medium" | "high"
      "title": "Code Auditor could use Sonnet",       // Short title
      "description": "The Code Auditor agent...",     // Full description
      "affected_files": ["agents/code-auditor.md"],   // Files involved
      "evidence": "Agent only reads and greps...",    // Supporting evidence
      "source_url": null                              // URL for external findings | null
    }
  ],

  // Improvement proposals (prioritized)
  "proposals": [
    {
      "id": "PRP-001",                               // Unique proposal ID
      "priority": "P1",                               // "P1" | "P2" | "P3" | "P4"
      "category": "optimization",                     // Proposal category (see below)
      "title": "Downgrade Code Auditor to Sonnet",   // Short title
      "description": "Switch the Code Auditor...",    // Full description
      "effort_estimate": "1-2h",                      // Time estimate
      "expected_impact": "~15% cost reduction...",    // Impact description
      "implementation_sketch": "1. Edit agents/...",  // Step-by-step outline
      "related_findings": ["FND-001"]                 // Linked finding IDs
    }
  ],

  // Comparison with previous review
  "diff_vs_previous": {
    "new_findings": 5,                                // Findings not in previous review
    "recurring_findings": 2,                          // Findings repeated from previous
    "resolved_findings": 1                            // Previous findings no longer present
  },

  // Research audit trail
  "research_sources": [
    {
      "query": "Claude Code 2026 new features",      // Search query used
      "url": "https://docs.anthropic.com/...",        // Source URL
      "retrieved_at": "2026-02-24T15:15:00Z"          // When retrieved
    }
  ]
}
```

### Finding Categories

| Category | Source | Description |
|----------|--------|-------------|
| `model-routing` | Internal (Step 2) | Agent model assignment concerns |
| `context-budget` | Internal (Step 3) | Budget/maxTurns misalignment |
| `pattern-consistency` | Internal (Step 4) | Structural deviations |
| `component-usage` | Internal (Step 5) | Unreferenced components |
| `telemetry` | Telemetry (Step 6) | Cross-project patterns |
| `anthropic-update` | External (Step 7) | New Anthropic features/changes |
| `mcp-ecosystem` | External (Step 8) | New MCP servers available |
| `community-pattern` | External (Step 9) | Community/competitor patterns |
| `innovation` | External (Step 10) | Forward-looking ideas |

### Proposal Categories

| Category | Description |
|----------|-------------|
| `optimization` | Performance, cost, or efficiency improvement |
| `new-feature` | New capability or component |
| `deprecation` | Remove or replace outdated component |
| `upgrade` | Update to use new platform features |
| `security` | Security-related improvement |

### Priority Levels

| Priority | Meaning |
|----------|---------|
| P1 | Critical — high impact, should be done next |
| P2 | Important — significant value, schedule soon |
| P3 | Nice to have — moderate value, when capacity allows |
| P4 | Backlog — low urgency, track for future consideration |

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `review_id` | string | yes | Unique review identifier |
| `created_at` | string | yes | ISO 8601 creation timestamp |
| `plugin_version` | string | yes | Plugin version |
| `telemetry_summary` | object | yes | Telemetry overview |
| `findings` | array | yes | All findings |
| `findings[].id` | string | yes | Finding identifier |
| `findings[].category` | enum | yes | Finding category |
| `findings[].severity` | enum | yes | Severity level |
| `findings[].title` | string | yes | Short title |
| `findings[].description` | string | yes | Full description |
| `findings[].affected_files` | string[] | yes | Related files |
| `findings[].evidence` | string | yes | Supporting evidence |
| `findings[].source_url` | string\|null | yes | External source URL |
| `proposals` | array | yes | Improvement proposals |
| `proposals[].id` | string | yes | Proposal identifier |
| `proposals[].priority` | enum | yes | Priority level |
| `proposals[].category` | enum | yes | Proposal category |
| `proposals[].title` | string | yes | Short title |
| `proposals[].description` | string | yes | Full description |
| `proposals[].effort_estimate` | string | yes | Time estimate |
| `proposals[].expected_impact` | string | yes | Impact description |
| `proposals[].implementation_sketch` | string | yes | Implementation steps |
| `proposals[].related_findings` | string[] | yes | Linked finding IDs |
| `diff_vs_previous` | object | yes | Previous review comparison |
| `research_sources` | array | yes | Research audit trail |

---

## 15. Expertise Records

Structured knowledge records stored as JSONL (one JSON object per line) in `.vibecrew/expertise/<domain>.jsonl`. Each record captures a typed, tiered learning with confidence scoring and outcome tracking. The expertise system replaces flat Session Learnings in CLAUDE.md with a queryable, ranked knowledge base.

**File pattern:** `.vibecrew/expertise/<domain>.jsonl` where domain is one of: `conventions`, `patterns`, `failures`, `decisions`, `performance`

**Record schema (single JSONL line):**

```jsonc
{
  "id": "exp-20260305100000-a1b2",        // Unique ID: exp-YYYYMMDDHHMMSS-XXXX (hex)
  "type": "convention",                     // "convention" | "pattern" | "failure" | "decision" | "reference" | "guide"
  "tier": "foundational",                   // "foundational" | "tactical" | "observational"
  "domain": "conventions",                  // Must match parent JSONL filename
  "content": "Always use Context7 MCP...",  // The learning (max 500 chars)
  "context": "When looking up library docs", // When this applies (max 200 chars)
  "outcome_status": "success",              // "success" | "failure" | "mixed" | "pending"
  "confidence": 0.85,                       // 0.0-1.0 confidence score
  "tags": ["mcp", "context7"],             // Searchable tags
  "created_at": "2026-03-05T10:00:00Z",    // ISO 8601
  "updated_at": "2026-03-05T10:00:00Z",    // ISO 8601
  "session_id": "session-2026-03-05-001",   // Originating session
  "feature_id": "feat-001",                 // Related feature or null
  "source_agent": "performance-coach",      // Agent that created the record
  "deprecated": false,                      // Whether record is deprecated
  "deprecation_reason": null,               // Reason for deprecation or null
  "access_count": 0,                        // Times read by expertise-read.sh
  "last_accessed_at": null,                 // Last read timestamp or null
  "superseded_by": null                     // ID of superseding record or null
}
```

### Record Types

| Type | Description | Typical Source |
|------|-------------|---------------|
| `convention` | Project-wide coding convention or pattern | Performance Coach, Builder |
| `pattern` | Reusable implementation pattern | Builder |
| `failure` | Anti-pattern or mistake to avoid | Performance Coach, Builder |
| `decision` | Architectural or technology decision | Workflow Orchestrator, Stack Scout |
| `reference` | External reference or documentation pointer | Stack Scout |
| `guide` | Step-by-step guide for a specific task | Builder, Code Reviewer |

### Tier Pruning Rules

| Tier | Auto-Expiry | Manual Deprecation | Notes |
|------|-------------|-------------------|-------|
| `foundational` | Never | Explicit only | Core project knowledge. These generate Session Learnings in CLAUDE.md. |
| `tactical` | 5 sessions after related feature reaches `done` | Allowed | Feature-specific knowledge. Expires when no longer relevant. |
| `observational` | 10 sessions | Allowed | Tentative observations. Promoted to tactical/foundational if confirmed. |

Additionally, records with `access_count == 0` after 20 sessions are auto-deprecated regardless of tier. Domain cap: 500 records per JSONL file (lowest-confidence observational records pruned first).

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | string | yes | Unique record identifier |
| `type` | enum | yes | Record type |
| `tier` | enum | yes | Pruning tier |
| `domain` | enum | yes | Domain (matches filename) |
| `content` | string | yes | The learning (max 500 chars) |
| `context` | string | no | When this applies (max 200 chars) |
| `outcome_status` | enum | yes | Outcome status |
| `confidence` | number | yes | 0.0-1.0 confidence score |
| `tags` | string[] | no | Searchable tags |
| `created_at` | string | yes | ISO 8601 creation timestamp |
| `updated_at` | string | yes | ISO 8601 last update timestamp |
| `session_id` | string | yes | Originating session |
| `feature_id` | string\|null | no | Related feature ID |
| `source_agent` | string | yes | Agent that created the record |
| `deprecated` | boolean | yes | Whether deprecated |
| `deprecation_reason` | string\|null | no | Reason for deprecation |
| `access_count` | integer | yes | Read count |
| `last_accessed_at` | string\|null | no | Last read timestamp |
| `superseded_by` | string\|null | no | ID of superseding record |

---

## 16. Drift Tracker

Ephemeral per-session state for the drift detection system. Created by `drift-tracker.sh` on first tool call, reset on session start and feature completion. Not committed to git (listed in `.gitignore`).

**File:** `.vibecrew/drift-tracker.json`

```jsonc
{
  "schema_version": "1.0.0",
  "session_started_at": "2026-03-05T10:00:00Z",  // Session start timestamp
  "current_phase": "code",                         // Current workflow phase
  "current_feature_id": "feat-001",                // Active feature ID or null
  "total_tool_calls": 47,                          // Total tool calls this session
  "calls_since_progress": 12,                      // Exploration calls since last progress
  "last_progress_at": "2026-03-05T10:30:00Z",     // Timestamp of last progress event
  "last_progress_tool": "Write",                   // Tool that triggered last progress
  "progress_events": 8,                            // Total progress events this session
  "exploration_events": 35,                        // Total exploration events this session
  "warnings": {
    "soft_count": 1,                               // Soft warnings emitted
    "last_warned_at": "2026-03-05T10:45:00Z"       // Last soft warning timestamp
  },
  "escalations": {
    "hard_count": 0,                               // Hard escalations (circuit breaker trips)
    "last_escalated_at": null                       // Last escalation timestamp
  },
  "recent_reads": ["src/a.ts", "src/b.ts"],       // Last N files read (for repeated-read detection)
  "repeated_read_count": 1                         // Files read 3+ times
}
```

### Tool Classification

The `drift-classify.sh` library classifies each tool call:

| Classification | Tools/Patterns | Effect |
|---------------|---------------|--------|
| **progress** | Write/Edit to source files (.ts/.tsx/.js/.jsx/.css/.py/.go/.rs), signal file writes, Bash `git commit` | Resets `calls_since_progress` to 0 |
| **exploration** | Read, Glob, Grep, WebSearch, WebFetch, failed Bash commands | Increments `calls_since_progress` |
| **neutral** | Bash test/build/lint, config file writes | No counter change |

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `schema_version` | string | yes | Schema version |
| `session_started_at` | string | yes | ISO 8601 session start |
| `current_phase` | string | yes | Current workflow phase |
| `current_feature_id` | string\|null | no | Active feature ID |
| `total_tool_calls` | integer | yes | Total tool calls |
| `calls_since_progress` | integer | yes | Calls since last progress |
| `last_progress_at` | string\|null | no | Last progress timestamp |
| `last_progress_tool` | string\|null | no | Last progress tool name |
| `progress_events` | integer | yes | Total progress events |
| `exploration_events` | integer | yes | Total exploration events |
| `warnings.soft_count` | integer | yes | Soft warning count |
| `warnings.last_warned_at` | string\|null | no | Last warning timestamp |
| `escalations.hard_count` | integer | yes | Hard escalation count |
| `escalations.last_escalated_at` | string\|null | no | Last escalation timestamp |
| `recent_reads` | string[] | yes | Recently read file paths |
| `repeated_read_count` | integer | yes | Files read 3+ times |

---

## 17. Erosion Schemas

Three related schemas for the code erosion tracking system. All stored in `.vibecrew/erosion/`.

### 17.1 Erosion Baseline

Project baseline captured after the first feature ships. Used as the reference point for erosion score calculations.

**File:** `.vibecrew/erosion/baseline.json`

```jsonc
{
  "schema_version": "1.0.0",
  "captured_at": "2026-03-05T10:00:00Z",   // When baseline was captured
  "total_project_loc": 1250,                 // Total lines of code at baseline
  "total_dependencies": 12,                  // package.json dependencies count
  "total_dev_dependencies": 8,               // package.json devDependencies count
  "files_analyzed": 15,                      // Source files analyzed
  "file_metrics": [                          // Per-file metrics at baseline
    {
      "file": "src/app.ts",
      "loc": 120,
      "complexity": 8,
      "func_count": 5,
      "max_func_len": 35,
      "imports": 4
    }
  ]
}
```

### 17.2 Erosion Snapshot

Per-session erosion snapshot written during `/wrap`. Contains the erosion score calculation results.

**File pattern:** `.vibecrew/erosion/erosion-<TIMESTAMP>.json`

```jsonc
{
  "score": 85,                              // 0-100 erosion score
  "rating": "moderate",                      // "healthy" | "moderate" | "concerning" | "critical"
  "deductions": [
    {
      "category": "file-size",              // Deduction category
      "points": -4,                          // Points deducted
      "reason": "2 file(s) over 300 LOC limit"
    }
  ],
  "bonuses": [
    {
      "category": "loc-decreased",
      "points": 3,
      "reason": "Total LOC decreased from baseline"
    }
  ],
  "hot_files": ["src/api.ts"],             // Files flagged as hot
  "metrics": {                              // Raw metrics from collect-erosion-metrics.sh
    "timestamp": "2026-03-05T10:00:00Z",
    "total_project_loc": 1450,
    "total_dependencies": 14,
    "total_dev_dependencies": 8,
    "files_analyzed": 5,
    "files_over_loc_limit": 2,
    "functions_over_length_limit": 1,
    "functions_over_complexity_limit": 0,
    "file_metrics": []
  }
}
```

### 17.3 Erosion Trends

Rolling 20-session trend summary with file churn tracking and alert detection. Updated by `update-erosion-trends.sh` during each `/wrap`.

**File:** `.vibecrew/erosion/trends.json`

```jsonc
{
  "schema_version": "1.0.0",
  "updated_at": "2026-03-05T10:00:00Z",    // Last update timestamp
  "direction": "stable",                     // "improving" | "stable" | "declining"
  "window_size": 8,                          // Number of snapshots analyzed (max 20)
  "average_score": 87,                       // Mean erosion score over window
  "file_churn": {                            // Per-file modification tracking
    "src/api.ts": {
      "count": 7,                            // Times modified across sessions
      "last_modified": "2026-03-05T10:00:00Z",
      "last_simplified": null                // null = never simplified, or ISO timestamp
    }
  },
  "hot_files": ["src/api.ts"],             // Files exceeding churn threshold
  "alert": null                              // null | "rapid-decline"
}
```

### Erosion Rating Tiers

| Range | Rating | Interpretation |
|-------|--------|----------------|
| 90-100 | `healthy` | Code quality stable or improving |
| 70-89 | `moderate` | Some complexity growth, manageable |
| 50-69 | `concerning` | Notable quality degradation, recommend `/simplify` |
| 0-49 | `critical` | Significant technical debt accumulation |

### Erosion Thresholds (from config.json)

| Key | Default | Description |
|-----|---------|-------------|
| `erosion.file_max_loc` | 300 | Flag files exceeding this LOC count |
| `erosion.function_max_loc` | 50 | Flag functions exceeding this line count |
| `erosion.complexity_max` | 10 | Flag functions exceeding this cyclomatic complexity |
| `erosion.hot_file_churn_count` | 5 | Churn count to flag as hot file |
| `erosion.rapid_decline_points` | 15 | Score drop to trigger rapid-decline alert |
| `erosion.rapid_decline_sessions` | 3 | Window for rapid decline detection |

---

## 18. Structured Plan Tasks

Extracted from `plan.md` files by `scripts/extract-plan-tasks.sh`. Used by the Builder Code Phase for deterministic task execution.

```jsonc
{
  "structured": true,              // false if no structured tasks found (legacy plan)
  "tasks": [
    {
      "index": 1,                  // Task number from plan.md
      "name": "Create database schema",
      "files": [
        {"path": "prisma/schema.prisma", "action": "modify"},
        {"path": "src/types/user.ts", "action": "create"}
      ],
      "action": "Add User and Session models with email, password_hash, created_at fields...",
      "verify": "npx prisma validate",
      "done_criteria": "Schema validates without errors and includes both models"
    }
  ],
  "milestone_filter": null         // Optional: milestone name to scope tasks to
}
```

### Task Count Guidelines

| Complexity | Tasks per plan (or per milestone) |
|------------|-----------------------------------|
| Trivial | 2-3 |
| Standard | 4-6 |
| Complex | 6-8 per milestone |

---

## 19. Codebase Analysis Documents

Generated by `scripts/generate-analysis-docs.sh` from `onboard-findings.json`. Stored in `.vibecrew/analysis/`. Committed to git.

| File | Sections | Content |
|------|----------|---------|
| `stack.md` | Runtime, Key Dependencies, UI & Components, Data & Deploy | Language, framework, runtime, package manager, key deps, component library, database, deployment target |
| `architecture.md` | Directory Structure, Component Organization, API & Routes, Patterns | Source dirs, component dirs, API routes, schema location, API style, state management, error handling, auth |
| `conventions.md` | Code Style, Naming, Git, Testing | Semicolons/quotes/indent, formatter/linter, component/file naming, import style, commit format, test framework, test co-location |
| `gaps.md` | Test Coverage, Untested Modules, Documentation Gaps, Maintenance | Source vs test file count, coverage estimate, untested modules (top 10), deprecated deps, TODO count |

### Staleness Heuristics

| Condition | Trigger |
|-----------|---------|
| Age >30 days AND >50 commits | Stale warning on session startup |
| `package.json` modified since analysis | Stale warning on session startup |
| New source directories since analysis | Stale warning on session startup |

Refresh via `/onboard --refresh` (re-runs auditor + regenerates analysis docs only).

---

## 20. EARS (Easy Approach to Requirements Syntax)

The standard format for acceptance criteria in VibeCrew plan templates. EARS makes criteria directly testable and eliminates ambiguity.

**Five patterns:**

| Pattern | Template |
|---|---|
| Ubiquitous | THE SYSTEM SHALL {behavior} |
| Event-driven | WHEN {event} THE SYSTEM SHALL {behavior} |
| State-driven | WHILE {state} THE SYSTEM SHALL {behavior} |
| Unwanted | IF {condition} THEN THE SYSTEM SHALL {behavior} |
| Optional | WHERE {condition} THE SYSTEM SHALL {behavior} |

**Enforcement:** `validate-plan.sh` checks for EARS format when a backlog file and feature ID are provided. `verify-plan-goals.sh` includes EARS validation as an advisory (non-blocking) check.

**Files:**
- `templates/plan.md.template` -- EARS format guidance and examples
- `skills/plan-features/SKILL.md` -- Instructs EARS format during planning
- `scripts/validate-plan.sh` -- Validates EARS format in acceptance criteria
- `scripts/verify-plan-goals.sh` -- Advisory EARS check in plan verification loop

---

## 21. Decision Categories (Locked/Deferred/Discretion)

The classification taxonomy for decisions made during the Clarify sub-step (Discuss phase) of Tier 2 Plan. Every ambiguity identified during planning is classified into one of three categories that determine how the Code phase handles it.

**Categories:**

| Category | Meaning | Code Phase Behavior |
|----------|---------|---------------------|
| **Locked** | Explicitly specified in spec, TDR, design brief, or user answer | Follow exactly. Deviation requires plan revision. |
| **Deferred** | Intentionally left open ("TBD", "later", "phase 2") | Do not implement. Add `TODO(deferred)` comment at decision point. |
| **Discretion** | Spec silent, doesn't affect acceptance criteria | Builder picks best option. Document choice with rationale. |

**Classification rules:**
- Spec says it → Locked
- Spec says "TBD"/"later"/"phase 2" → Deferred
- Spec silent, doesn't affect acceptance criteria → Discretion
- Spec silent, affects acceptance criteria → Ask user → Locked

**Decisions table schema (in plan.md):**

| Column | Required | Description |
|--------|----------|-------------|
| `#` | yes | Sequential decision number |
| `Category` | yes | `Locked` / `Deferred` / `Discretion` |
| `Question` | yes | The ambiguity being resolved |
| `Decision` | yes | The resolution or deferral note |
| `Source` | yes | `Spec` / `User` / `Builder (conventions)` / `Spec ("TBD")` |
| `Rationale` | yes | Why this classification and decision |

**Files:**
- `templates/clarify-checklist.md` -- Decision Categories section with taxonomy and classification rules
- `templates/decisions.md.template` -- Standalone decisions document for complex features
- `templates/plan.md.template` -- Decisions table with Category column
- `agents/builder.md` -- Clarify sub-step uses taxonomy; Code phase enforces categories

---

## 22. Agent Memory Records

**Location:** `.vibecrew/memory/<agent>/<domain>.jsonl`

**Purpose:** Per-agent persistent knowledge that accumulates across sessions. Each agent writes operational discoveries (API patterns, flaky tests, library gotchas) that future sessions can read to avoid re-discovering the same information.

### Entry Schema

Each line is a JSON object:

| Field | Required | Type / Constraint |
|---|---|---|
| `content` | yes | String — the knowledge being stored |
| `created_at` | yes | ISO 8601 timestamp |
| `expires_at` | yes | ISO 8601 timestamp (empty string = no expiry) |
| `ttl_days` | yes | Integer — days until auto-prune (default: 90) |

### Limits

| Constraint | Value |
|---|---|
| Max entries per domain file | 50 |
| Max file size per domain | 100 KB |
| Default TTL | 90 days |
| Duplicate detection | Exact content match (skip if exists) |

### Agent Domains

| Agent | Typical Domains |
|---|---|
| `builder` | `api-patterns`, `code-conventions`, `integration-gotchas` |
| `verifier` | `flaky-tests`, `environment-issues`, `failure-patterns` |
| `stack-scout` | `library-gotchas`, `version-conflicts`, `migration-notes` |
| `code-reviewer` | `recurring-issues`, `convention-violations` |

**Scripts:**
- `scripts/agent-memory-write.sh` — writes entry, enforces limits, deduplicates
- `scripts/agent-memory-read.sh` — reads entries, prunes expired, outputs summary or JSON
- `scripts/prepare-feature-context.sh` — injects Builder memory into fresh-session context
