# Research: Multi-Agent Orchestration for AI-Assisted Development

> **Phase 1 Research** | Document 02 | February 2026
>
> This document covers patterns and strategies for orchestrating multiple Claude Code sessions as a coordinated multi-agent system. It addresses parallel session management, inter-agent communication via the filesystem, task queuing and dependency resolution, conflict prevention across concurrent agents, branch-per-agent strategies, orchestrator coordination, concurrency limits, and error recovery -- all critical for a system like VibeOS where 5-15 autonomous agents operate simultaneously on a shared codebase.

---

## Table of Contents

1. [Running Parallel Claude Code Sessions](#1-running-parallel-claude-code-sessions)
2. [Inter-Agent Communication Patterns](#2-inter-agent-communication-patterns)
3. [Task Queue and Dependency Management](#3-task-queue-and-dependency-management)
4. [Preventing Conflicts When Multiple Agents Modify the Same Codebase](#4-preventing-conflicts-when-multiple-agents-modify-the-same-codebase)
5. [Branch-Per-Agent Strategies](#5-branch-per-agent-strategies)
6. [Orchestrator Coordination Pattern](#6-orchestrator-coordination-pattern)
7. [Concurrency Limits and Resource Management](#7-concurrency-limits-and-resource-management)
8. [Error Recovery in Multi-Agent Systems](#8-error-recovery-in-multi-agent-systems)
9. [Recommendations for VibeOS](#9-recommendations-for-vibeos)
10. [Sources](#10-sources)

---

## 1. Running Parallel Claude Code Sessions

### 1.1 One Terminal Tab = One Agent

Claude Code operates as a single-process, single-context-window application. Each invocation of the `claude` command creates an independent session with its own context window, its own tool permissions, and its own conversation history. There is no built-in mechanism for multiple Claude Code sessions to share memory, exchange messages, or coordinate actions at the process level.

This architectural constraint is fundamental: **each terminal tab is a completely isolated agent**. Two Claude Code sessions running side by side have no more awareness of each other than two separate users on different machines. Any coordination between them must be mediated through external mechanisms -- the filesystem, git, or other IPC patterns.

For VibeOS, this means:

| Concept | Implementation |
|---------|---------------|
| One agent | One Warp terminal tab running `claude` |
| Agent specialization | Controlled via the agent prompt file passed at launch |
| Agent isolation | Each session has its own context window (no sharing) |
| Agent communication | File-based via `.vibeos/` directory |
| Agent count | 5-15 concurrent sessions depending on task parallelism |

### 1.2 Warp Terminal as the Agent Host

Warp is a Rust-based terminal emulator designed for modern development workflows. It provides several features that are critical for multi-agent orchestration:

**Tab management**: Warp supports multiple tabs within a single window, each running its own shell process. This maps naturally to the "one tab = one agent" model. A developer can see all agent tabs at a glance and switch between them with keyboard shortcuts.

**WARP_SESSION_ID environment variable**: Every Warp tab exposes a unique `WARP_SESSION_ID` environment variable. This identifier is stable for the lifetime of the tab and is accessible to any process running within it -- including Claude Code and any bash scripts it executes. This provides a reliable way to identify which agent is running in which tab.

```bash
# Every Warp tab has a unique session ID
echo "$WARP_SESSION_ID"
# Output: 550e8400-e29b-41d4-a716-446655440000
```

**Deep linking via `warp://session/<id>`**: Warp supports a proprietary URI scheme that brings a specific tab to the foreground when opened. Combined with `terminal-notifier` on macOS, this enables one-click navigation from a notification banner directly to the agent that needs attention.

```bash
# Construct a deep link to a specific Warp tab
DEEP_LINK="warp://session/${WARP_SESSION_ID}"

# Opening this URI brings the tab to the foreground
open "$DEEP_LINK"
```

**OSC 777 notification support**: Warp parses Operating System Command (OSC) escape sequences for desktop notifications. The OSC 777 sequence (`ESC ] 777 ; notify ; <title> ; <body> BEL`) triggers a native macOS banner notification. This is the mechanism by which VibeOS implements the Interrupt Protocol -- agents can fire notifications without consuming any context window tokens, because the notification is triggered by a bash hook script, not by the model itself.

### 1.3 Launching Agents with Specialized Prompts

Each agent type in VibeOS is defined by a specialized prompt file in the `agents/` directory. When the developer (or the Workflow Orchestrator) launches a new agent, they pass the appropriate agent definition:

```bash
# Launch a Stack Scout research agent in a new Warp tab
claude /agent stack-scout "Evaluate the optimal tech stack for a travel app. Compare PWA + IndexedDB versus React Native."

# Launch a Feature Developer agent
claude /agent feature-developer "Implement the user authentication feature per the spec in backlog.json."

# Launch a Test Writer agent
claude /agent test-writer "Write tests for the authentication feature on branch feat/user-auth."
```

The agent prompt file controls:
- **Model selection**: Haiku for lightweight agents (Session Startup, Quality Check), Sonnet for complex agents (Feature Developer, Stack Scout)
- **Tool permissions**: Stack Scout gets `--allowedTools WebSearch,Read,Glob,Grep` (read-only); Feature Developer gets `Write,Edit,Bash` (read-write)
- **Behavioral constraints**: Each prompt defines the agent's role, tone, task boundaries, and output format

### 1.4 Session Lifecycle

Every agent session follows a predictable lifecycle:

```
┌─────────────────────────────────────────────────────────┐
│                    AGENT LIFECYCLE                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. LAUNCH                                              │
│     └─ Developer opens new Warp tab                     │
│     └─ Runs `claude /agent <type> "<task>"`             │
│     └─ SessionStart hook fires → session-startup.md     │
│                                                         │
│  2. INITIALIZE                                          │
│     └─ Agent reads .vibeos/state.json                   │
│     └─ Agent reads .vibeos/backlog.json                 │
│     └─ Agent verifies git status (clean tree, branch)   │
│     └─ Agent registers itself in .vibeos/sessions/      │
│                                                         │
│  3. EXECUTE                                             │
│     └─ Agent performs its specialized task               │
│     └─ Hooks enforce rules (phase gate, safety)         │
│     └─ Notifications fire on block/complete/error       │
│                                                         │
│  4. HANDOFF                                             │
│     └─ Agent writes results to filesystem               │
│     └─ Agent updates .vibeos/state.json                 │
│     └─ Agent writes signal file if applicable           │
│     └─ Agent commits work and creates PR if applicable  │
│                                                         │
│  5. TERMINATE                                           │
│     └─ Developer runs /wrap or Ctrl+D                   │
│     └─ SessionEnd hook fires → Performance Coach        │
│     └─ Vibe Score calculated, CLAUDE.md mutation offered │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Inter-Agent Communication Patterns

### 2.1 Why File-Based Communication

In traditional multi-agent systems, agents communicate through message queues (RabbitMQ, Redis), shared databases, WebSocket connections, or gRPC streams. None of these patterns are appropriate for Claude Code agents because:

1. **No shared runtime**: Each Claude Code session is an independent process. There is no persistent server or daemon that agents can connect to.
2. **No network primitives**: Claude Code agents execute tools (Read, Write, Bash, etc.) but do not have the ability to open persistent network connections or run background daemons.
3. **Ephemeral sessions**: An agent session may last 5 minutes or 2 hours. Setting up and tearing down network infrastructure for each session is impractical.
4. **Simplicity for non-technical users**: VibeOS targets solo non-technical developers. A file-based approach is inspectable, debuggable, and requires no infrastructure.

The filesystem is the natural shared medium. All agents can read and write files. Git provides versioning, conflict detection, and atomic operations. The `.vibeos/` directory serves as the "message bus" for the entire system.

### 2.2 The `.vibeos/` Directory as Shared State

The `.vibeos/` directory is the central nervous system of inter-agent communication. It lives at the project root, is tracked by git (except for ephemeral lock and signal files), and follows a strict schema:

```
.vibeos/
  config.json              # System configuration (terminal, notifications)
  state.json               # Current project state (foundation status, active feature)
  backlog.json             # Feature backlog with specs, status, dependencies
  sessions/                # Per-session metadata (active and historical)
    <session-id>.json      # Individual session record
  scores/                  # Vibe Score breakdowns per session
    <session-id>.json      # Score details
  releases/                # Release notes data
    v1.0.0.json            # Per-release metadata
  signals/                 # Ephemeral signal files (gitignored)
    feature-auth-complete  # Zero-byte file indicating completion
  locks/                   # Advisory lock files (gitignored)
    state.json.lock        # Lock for state.json writes
    backlog.json.lock      # Lock for backlog.json writes
```

### 2.3 state.json -- Project-Wide Shared State

The `state.json` file is the single source of truth for the project's current status. Every agent reads it at session start and updates it when making state transitions.

```json
{
  "version": "1.0.0",
  "project_name": "travel-organizer",
  "foundation": {
    "status": "complete",
    "completed_at": "2026-02-20T14:30:00Z",
    "artifacts": {
      "vision": "VISION.md",
      "design_system": "design-system.css",
      "tdr": "docs/tdr-001-tech-stack.md",
      "roadmap": "docs/roadmap.md",
      "claude_md": "CLAUDE.md"
    }
  },
  "active_feature": {
    "id": "feat-003",
    "name": "user-authentication",
    "phase": "code",
    "branch": "feat/user-authentication",
    "assigned_session": "550e8400-e29b-41d4-a716-446655440000",
    "started_at": "2026-02-23T10:15:00Z"
  },
  "parallel_sessions": [
    {
      "session_id": "550e8400-e29b-41d4-a716-446655440000",
      "agent_type": "feature-developer",
      "task": "feat-003",
      "status": "active",
      "started_at": "2026-02-23T10:15:00Z",
      "warp_tab": "Tab 2"
    },
    {
      "session_id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
      "agent_type": "test-writer",
      "task": "feat-002",
      "status": "active",
      "started_at": "2026-02-23T10:20:00Z",
      "warp_tab": "Tab 3"
    }
  ],
  "last_updated": "2026-02-23T10:20:00Z",
  "last_updated_by": "6ba7b810-9dad-11d1-80b4-00c04fd430c8"
}
```

**Key design decisions:**

- **`foundation.status`**: The phase gate hook reads this field. If it is not `"complete"`, all source code writes are blocked. This is the enforcement mechanism for the Research-First Protocol.
- **`active_feature`**: Tracks which feature is currently in progress. Only one feature is "active" at a time in the primary workflow, though agents may work on different features in parallel via the backlog.
- **`parallel_sessions`**: An array of all currently running agent sessions. Agents register themselves on startup and deregister on shutdown. Stale entries (sessions that crashed without cleanup) are detected by the Session Startup agent.

### 2.4 backlog.json -- Task Queue and Feature Specs

The `backlog.json` file serves as the task queue for the entire system. It contains every feature that has been planned, with its specification, status, dependencies, and assignment.

```json
{
  "version": "1.0.0",
  "features": [
    {
      "id": "feat-001",
      "name": "project-setup",
      "description": "Initialize the project with Next.js, Tailwind CSS, and Supabase per TDR-001.",
      "status": "done",
      "priority": 1,
      "phase": "done",
      "dependencies": [],
      "branch": "feat/project-setup",
      "pr_number": 1,
      "assigned_session": null,
      "completed_at": "2026-02-21T09:00:00Z",
      "acceptance_criteria": [
        "Next.js 15 app router initialized",
        "Tailwind CSS configured with design system tokens",
        "Supabase client configured with environment variables",
        "CI pipeline passing"
      ]
    },
    {
      "id": "feat-002",
      "name": "landing-page",
      "description": "Build the marketing landing page with hero, features, and CTA sections.",
      "status": "testing",
      "priority": 2,
      "phase": "test",
      "dependencies": ["feat-001"],
      "branch": "feat/landing-page",
      "pr_number": null,
      "assigned_session": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
      "completed_at": null,
      "acceptance_criteria": [
        "Hero section with headline and CTA button",
        "Features grid with 3 feature cards",
        "Responsive on mobile and desktop",
        "Lighthouse performance score > 90"
      ]
    },
    {
      "id": "feat-003",
      "name": "user-authentication",
      "description": "Implement email/password and OAuth login using Supabase Auth.",
      "status": "in-progress",
      "priority": 3,
      "phase": "code",
      "dependencies": ["feat-001"],
      "branch": "feat/user-authentication",
      "pr_number": null,
      "assigned_session": "550e8400-e29b-41d4-a716-446655440000",
      "completed_at": null,
      "acceptance_criteria": [
        "Email/password registration and login",
        "Google OAuth login",
        "Protected route middleware",
        "Session persistence across page refreshes"
      ]
    },
    {
      "id": "feat-004",
      "name": "user-dashboard",
      "description": "Build the main dashboard view after login with trip overview cards.",
      "status": "ready",
      "priority": 4,
      "phase": "plan",
      "dependencies": ["feat-002", "feat-003"],
      "branch": null,
      "pr_number": null,
      "assigned_session": null,
      "completed_at": null,
      "acceptance_criteria": [
        "Dashboard layout with sidebar navigation",
        "Trip overview cards with summary data",
        "Empty state for new users",
        "Loading skeleton states"
      ]
    },
    {
      "id": "feat-005",
      "name": "trip-creation",
      "description": "Multi-step form for creating a new trip with dates, destinations, and travelers.",
      "status": "planned",
      "priority": 5,
      "phase": "plan",
      "dependencies": ["feat-004"],
      "branch": null,
      "pr_number": null,
      "assigned_session": null,
      "completed_at": null,
      "acceptance_criteria": [
        "Multi-step form with progress indicator",
        "Date range picker for trip dates",
        "Destination search with autocomplete",
        "Traveler count and names input"
      ]
    }
  ]
}
```

### 2.5 Signal Files -- Lightweight Event Notifications

Signal files are the simplest form of inter-agent communication. An agent creates a zero-byte file in `.vibeos/signals/` to indicate that something has happened. Other agents check for the existence of these files to detect events.

```bash
#!/usr/bin/env bash
# signal-complete.sh
# Called by an agent when it completes a task.

set -euo pipefail

FEATURE_ID="${1:?Usage: signal-complete.sh <feature-id> <phase>}"
PHASE="${2:?Usage: signal-complete.sh <feature-id> <phase>}"
SESSION_ID="${WARP_SESSION_ID:-unknown}"
SIGNAL_DIR=".vibeos/signals"

mkdir -p "$SIGNAL_DIR"

# Create the signal file with minimal metadata
SIGNAL_FILE="${SIGNAL_DIR}/${FEATURE_ID}-${PHASE}-complete"

cat > "$SIGNAL_FILE" << EOF
{
  "feature_id": "$FEATURE_ID",
  "phase": "$PHASE",
  "completed_by": "$SESSION_ID",
  "completed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "Signal created: $SIGNAL_FILE"
```

```bash
#!/usr/bin/env bash
# check-signals.sh
# Called by the Orchestrator or Session Startup agent to detect completed tasks.

set -euo pipefail

SIGNAL_DIR=".vibeos/signals"

if [ ! -d "$SIGNAL_DIR" ]; then
  echo "No signals directory found."
  exit 0
fi

SIGNALS=$(ls -1 "$SIGNAL_DIR" 2>/dev/null | grep -E '.*-complete$' || true)

if [ -z "$SIGNALS" ]; then
  echo "No pending signals."
  exit 0
fi

echo "=== Pending Completion Signals ==="
for signal in $SIGNALS; do
  echo ""
  echo "Signal: $signal"
  if [ -s "${SIGNAL_DIR}/${signal}" ]; then
    cat "${SIGNAL_DIR}/${signal}"
  fi
done

echo ""
echo "Total: $(echo "$SIGNALS" | wc -l | tr -d ' ') signal(s)"
```

Signal files should be gitignored because they are ephemeral coordination artifacts, not persistent project state:

```gitignore
# .gitignore
.vibeos/signals/
.vibeos/locks/
```

### 2.6 Lock Files -- Preventing Concurrent Write Conflicts

When two agents need to update the same shared file (e.g., `state.json` or `backlog.json`), they must coordinate to prevent lost updates. VibeOS uses advisory lock files with atomic creation via `mkdir` (which is atomic on POSIX filesystems):

```bash
#!/usr/bin/env bash
# acquire-lock.sh
# Acquires an advisory lock on a shared file.
# Uses mkdir for atomic lock creation (POSIX-guaranteed atomic).

set -euo pipefail

TARGET_FILE="${1:?Usage: acquire-lock.sh <target-file> [timeout-seconds]}"
TIMEOUT="${2:-30}"
SESSION_ID="${WARP_SESSION_ID:-$$}"
LOCK_DIR=".vibeos/locks"
LOCK_PATH="${LOCK_DIR}/$(basename "$TARGET_FILE").lock"

mkdir -p "$LOCK_DIR"

ELAPSED=0
INTERVAL=1

while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
  # mkdir is atomic on POSIX -- if it succeeds, we have the lock
  if mkdir "$LOCK_PATH" 2>/dev/null; then
    # Write lock metadata
    cat > "${LOCK_PATH}/info.json" << EOF
{
  "locked_by": "$SESSION_ID",
  "locked_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "target_file": "$TARGET_FILE",
  "pid": $$
}
EOF
    echo "Lock acquired: $LOCK_PATH (by $SESSION_ID)"
    exit 0
  fi

  # Lock exists -- check if it's stale
  if [ -f "${LOCK_PATH}/info.json" ]; then
    LOCK_TIME=$(cat "${LOCK_PATH}/info.json" | jq -r '.locked_at // empty')
    LOCK_PID=$(cat "${LOCK_PATH}/info.json" | jq -r '.pid // empty')

    # Check if locking process is still alive
    if [ -n "$LOCK_PID" ] && ! kill -0 "$LOCK_PID" 2>/dev/null; then
      echo "Stale lock detected (PID $LOCK_PID is dead). Removing."
      rm -rf "$LOCK_PATH"
      continue
    fi

    # Check if lock is older than 30 minutes (stale timeout)
    if [ -n "$LOCK_TIME" ]; then
      LOCK_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LOCK_TIME" "+%s" 2>/dev/null || echo "0")
      NOW_EPOCH=$(date "+%s")
      AGE=$(( NOW_EPOCH - LOCK_EPOCH ))
      if [ "$AGE" -gt 1800 ]; then
        echo "Stale lock detected (age: ${AGE}s > 1800s). Removing."
        rm -rf "$LOCK_PATH"
        continue
      fi
    fi
  fi

  echo "Waiting for lock on $TARGET_FILE... (${ELAPSED}s / ${TIMEOUT}s)"
  sleep "$INTERVAL"
  ELAPSED=$(( ELAPSED + INTERVAL ))
done

echo "ERROR: Failed to acquire lock on $TARGET_FILE after ${TIMEOUT}s."
exit 1
```

```bash
#!/usr/bin/env bash
# release-lock.sh
# Releases an advisory lock on a shared file.

set -euo pipefail

TARGET_FILE="${1:?Usage: release-lock.sh <target-file>}"
SESSION_ID="${WARP_SESSION_ID:-$$}"
LOCK_DIR=".vibeos/locks"
LOCK_PATH="${LOCK_DIR}/$(basename "$TARGET_FILE").lock"

if [ ! -d "$LOCK_PATH" ]; then
  echo "No lock found for $TARGET_FILE."
  exit 0
fi

# Verify we own the lock before releasing
if [ -f "${LOCK_PATH}/info.json" ]; then
  LOCK_OWNER=$(cat "${LOCK_PATH}/info.json" | jq -r '.locked_by // empty')
  if [ "$LOCK_OWNER" != "$SESSION_ID" ] && [ "$LOCK_OWNER" != "$$" ]; then
    echo "WARNING: Lock on $TARGET_FILE is owned by $LOCK_OWNER, not $SESSION_ID. Not releasing."
    exit 1
  fi
fi

rm -rf "$LOCK_PATH"
echo "Lock released: $LOCK_PATH"
```

### 2.7 Git-Based Communication

Beyond the `.vibeos/` directory, git itself serves as a communication channel between agents:

**Branch existence signals progress:**

| Branch State | Meaning |
|-------------|---------|
| Branch does not exist | Feature has not started |
| Branch exists, no PR | Feature is in progress |
| Branch exists, PR open | Feature is in review |
| Branch merged, PR closed | Feature is complete |

**Commit messages carry structured metadata:**

Agents use conventional commits (see Research Document 03) with structured metadata that other agents can parse:

```bash
# Query git to determine the status of a feature
BRANCH="feat/user-authentication"

# Check if branch exists
if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
  echo "Branch exists."

  # Check if there's an open PR
  PR_STATE=$(gh pr view "$BRANCH" --json state --jq '.state' 2>/dev/null || echo "none")

  case "$PR_STATE" in
    "OPEN")   echo "Feature is in review (PR open)." ;;
    "MERGED") echo "Feature is complete (PR merged)." ;;
    "CLOSED") echo "Feature was abandoned (PR closed without merge)." ;;
    "none")   echo "Feature is in progress (no PR yet)." ;;
  esac
else
  echo "Feature has not started."
fi
```

### 2.8 Communication Pattern Summary

| Pattern | Use Case | Latency | Reliability | Complexity |
|---------|----------|---------|-------------|------------|
| **state.json** | Project-wide state (foundation, active feature) | Low (file read) | High (with locks) | Medium |
| **backlog.json** | Task queue, feature specs, assignments | Low (file read) | High (with locks) | Medium |
| **Signal files** | Event notifications (task complete, error) | Low (file exists check) | Medium (can miss) | Low |
| **Lock files** | Prevent concurrent writes | Low (mkdir atomic) | High (POSIX atomic) | Medium |
| **Git branches** | Task progress tracking | Medium (git operations) | High (git guarantees) | Low |
| **Git PRs** | Completion and review status | Medium (gh API call) | High (GitHub API) | Low |
| **Commit messages** | Structured metadata | Medium (git log) | High (immutable history) | Low |

---

## 3. Task Queue and Dependency Management

### 3.1 Feature State Machine

Every feature in the backlog progresses through a well-defined state machine. State transitions are triggered by agent actions and are recorded in `backlog.json`.

```
                    ┌──────────────────────────────────────────────┐
                    │           FEATURE STATE MACHINE              │
                    ├──────────────────────────────────────────────┤
                    │                                              │
                    │   idea ──► planned ──► ready ──► in-progress │
                    │                                     │        │
                    │                                     ▼        │
                    │                    done ◄── review ◄── testing│
                    │                                              │
                    └──────────────────────────────────────────────┘
```

| State | Description | Who Transitions | Next State |
|-------|-------------|-----------------|------------|
| `idea` | Raw concept captured via `/idea` command | User | `planned` |
| `planned` | Has a description but no acceptance criteria or spec | Workflow Orchestrator | `ready` |
| `ready` | Has acceptance criteria, dependencies met, can be worked | Feature Developer (claim) | `in-progress` |
| `in-progress` | Agent is actively implementing | Feature Developer (finish) | `testing` |
| `testing` | Code complete, tests being written or run | Test Writer / Quality Check | `review` |
| `review` | PR created, awaiting merge | User (merge PR) | `done` |
| `done` | Merged to main, feature shipped | -- | (terminal) |

### 3.2 Dependency Resolution

Features may depend on other features. A feature cannot transition to `ready` until all of its dependencies are in the `done` state. This prevents agents from starting work on a feature that requires infrastructure not yet available.

```bash
#!/usr/bin/env bash
# check-dependencies.sh
# Checks if all dependencies for a feature are satisfied.

set -euo pipefail

FEATURE_ID="${1:?Usage: check-dependencies.sh <feature-id>}"
BACKLOG_FILE=".vibeos/backlog.json"

if [ ! -f "$BACKLOG_FILE" ]; then
  echo "ERROR: $BACKLOG_FILE not found."
  exit 1
fi

# Extract dependencies for the target feature
DEPENDENCIES=$(jq -r \
  --arg id "$FEATURE_ID" \
  '.features[] | select(.id == $id) | .dependencies[]' \
  "$BACKLOG_FILE" 2>/dev/null)

if [ -z "$DEPENDENCIES" ]; then
  echo "No dependencies for $FEATURE_ID. Ready to start."
  exit 0
fi

ALL_MET=true

for dep_id in $DEPENDENCIES; do
  DEP_STATUS=$(jq -r \
    --arg id "$dep_id" \
    '.features[] | select(.id == $id) | .status' \
    "$BACKLOG_FILE")

  if [ "$DEP_STATUS" = "done" ]; then
    echo "  [OK] $dep_id is done."
  else
    echo "  [BLOCKED] $dep_id is '$DEP_STATUS' (must be 'done')."
    ALL_MET=false
  fi
done

if [ "$ALL_MET" = true ]; then
  echo "All dependencies satisfied. $FEATURE_ID is ready."
  exit 0
else
  echo "Dependencies not met. $FEATURE_ID cannot start."
  exit 1
fi
```

### 3.3 Task Claiming with Optimistic Locking

When an agent is ready to pick up a task, it must claim it to prevent another agent from working on the same feature. The claiming process uses optimistic locking:

1. **Read**: Agent reads `backlog.json` and finds the highest-priority `ready` task with satisfied dependencies.
2. **Verify**: Agent checks that no other session has claimed the task since the read.
3. **Write**: Agent updates the task's `status` to `in-progress` and sets `assigned_session` to its own session ID.

```bash
#!/usr/bin/env bash
# claim-task.sh
# Claims the next available task from the backlog for this agent session.

set -euo pipefail

SESSION_ID="${WARP_SESSION_ID:-$$}"
BACKLOG_FILE=".vibeos/backlog.json"
LOCK_SCRIPT=".vibeos/../scripts/acquire-lock.sh"
UNLOCK_SCRIPT=".vibeos/../scripts/release-lock.sh"

# Acquire lock on backlog.json
bash "$LOCK_SCRIPT" "$BACKLOG_FILE" 10

# Find the highest-priority ready task with no assignee
TASK_ID=$(jq -r '
  [.features[] | select(.status == "ready" and .assigned_session == null)]
  | sort_by(.priority)
  | first
  | .id // empty
' "$BACKLOG_FILE")

if [ -z "$TASK_ID" ]; then
  echo "No available tasks in the backlog."
  bash "$UNLOCK_SCRIPT" "$BACKLOG_FILE"
  exit 0
fi

TASK_NAME=$(jq -r --arg id "$TASK_ID" \
  '.features[] | select(.id == $id) | .name' "$BACKLOG_FILE")

# Check dependencies
DEPS_MET=true
DEPENDENCIES=$(jq -r --arg id "$TASK_ID" \
  '.features[] | select(.id == $id) | .dependencies[]' "$BACKLOG_FILE" 2>/dev/null || true)

for dep_id in $DEPENDENCIES; do
  DEP_STATUS=$(jq -r --arg id "$dep_id" \
    '.features[] | select(.id == $id) | .status' "$BACKLOG_FILE")
  if [ "$DEP_STATUS" != "done" ]; then
    DEPS_MET=false
    break
  fi
done

if [ "$DEPS_MET" = false ]; then
  echo "Task $TASK_ID ($TASK_NAME) has unmet dependencies. Skipping."
  bash "$UNLOCK_SCRIPT" "$BACKLOG_FILE"
  exit 0
fi

# Claim the task: update status and assign session
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq --arg id "$TASK_ID" \
   --arg session "$SESSION_ID" \
   --arg ts "$TIMESTAMP" \
   '(.features[] | select(.id == $id)) |=
    (.status = "in-progress" |
     .assigned_session = $session |
     .started_at = $ts)' \
   "$BACKLOG_FILE" > "${BACKLOG_FILE}.tmp" \
   && mv "${BACKLOG_FILE}.tmp" "$BACKLOG_FILE"

# Release lock
bash "$UNLOCK_SCRIPT" "$BACKLOG_FILE"

echo "Claimed task: $TASK_ID ($TASK_NAME)"
echo "Assigned to session: $SESSION_ID"
```

### 3.4 Task Completion and Handoff

When an agent completes its phase of work on a feature, it must update the backlog, create a signal file, and potentially trigger the next agent in the pipeline:

```bash
#!/usr/bin/env bash
# complete-phase.sh
# Marks the current phase of a feature as complete and advances to the next phase.

set -euo pipefail

FEATURE_ID="${1:?Usage: complete-phase.sh <feature-id>}"
SESSION_ID="${WARP_SESSION_ID:-$$}"
BACKLOG_FILE=".vibeos/backlog.json"

# Phase progression map
declare -A NEXT_PHASE
NEXT_PHASE[plan]="design"
NEXT_PHASE[design]="code"
NEXT_PHASE[code]="test"
NEXT_PHASE[test]="review"
NEXT_PHASE[review]="done"

# Get current phase
CURRENT_PHASE=$(jq -r --arg id "$FEATURE_ID" \
  '.features[] | select(.id == $id) | .phase' "$BACKLOG_FILE")

NEXT="${NEXT_PHASE[$CURRENT_PHASE]:-done}"

# Determine new status based on next phase
if [ "$NEXT" = "done" ]; then
  NEW_STATUS="done"
else
  # Map phase to status
  case "$NEXT" in
    "design"|"code") NEW_STATUS="in-progress" ;;
    "test")          NEW_STATUS="testing" ;;
    "review")        NEW_STATUS="review" ;;
    *)               NEW_STATUS="in-progress" ;;
  esac
fi

# Acquire lock
bash scripts/acquire-lock.sh "$BACKLOG_FILE" 10

# Update backlog
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
jq --arg id "$FEATURE_ID" \
   --arg phase "$NEXT" \
   --arg status "$NEW_STATUS" \
   --arg ts "$TIMESTAMP" \
   '(.features[] | select(.id == $id)) |=
    (.phase = $phase |
     .status = $status |
     .assigned_session = null |
     if $status == "done" then .completed_at = $ts else . end)' \
   "$BACKLOG_FILE" > "${BACKLOG_FILE}.tmp" \
   && mv "${BACKLOG_FILE}.tmp" "$BACKLOG_FILE"

# Release lock
bash scripts/release-lock.sh "$BACKLOG_FILE"

# Create signal file
mkdir -p ".vibeos/signals"
cat > ".vibeos/signals/${FEATURE_ID}-${CURRENT_PHASE}-complete" << EOF
{
  "feature_id": "$FEATURE_ID",
  "completed_phase": "$CURRENT_PHASE",
  "next_phase": "$NEXT",
  "completed_by": "$SESSION_ID",
  "completed_at": "$TIMESTAMP"
}
EOF

echo "Phase '$CURRENT_PHASE' complete for $FEATURE_ID."
echo "Next phase: $NEXT (status: $NEW_STATUS)"
echo "Signal created: .vibeos/signals/${FEATURE_ID}-${CURRENT_PHASE}-complete"
```

### 3.5 The `/run-backlog` Automation Loop

The `/run-backlog` slash command automates the entire task queue processing. It repeatedly claims the next available task, launches the appropriate agent, waits for completion, and moves to the next task:

```
┌────────────────────────────────────────────────────────────┐
│                  /run-backlog FLOW                          │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. Read backlog.json                                      │
│  2. Find next "ready" task (priority order, deps satisfied)│
│  3. No tasks available? → Exit with summary.               │
│  4. Claim the task (optimistic lock).                      │
│  5. Determine the required agent type for the task's phase.│
│  6. Launch the agent in the current session.               │
│  7. Agent executes → completes phase → signals done.       │
│  8. Advance the feature to the next phase.                 │
│  9. If more phases remain → go to step 6 with next agent.  │
│ 10. If feature done → go to step 1 for next feature.       │
│ 11. Repeat until backlog is empty or context exhausted.    │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 4. Preventing Conflicts When Multiple Agents Modify the Same Codebase

### 4.1 The Conflict Problem in Multi-Agent Systems

When 5-15 agents work concurrently on a shared codebase, the risk of conflicts is significant. Two agents might:

1. **Modify the same file simultaneously**: Agent A edits `src/lib/auth.ts` while Agent B also edits it.
2. **Create incompatible changes**: Agent A adds a function to `utils.ts` that Agent B also adds with a different signature.
3. **Depend on code that another agent is changing**: Agent A relies on a component that Agent B is refactoring.
4. **Corrupt shared state files**: Two agents write to `backlog.json` at the same time, and one overwrites the other's changes.

### 4.2 Branch-Per-Agent (Primary Strategy)

The primary conflict prevention strategy is **branch-per-agent**: each agent works on its own feature branch, isolated from all other agents. Changes are integrated through pull requests, which serve as the single merge point.

```
                    main
                      │
            ┌─────────┼─────────┐
            │         │         │
        feat/auth  feat/landing feat/dashboard
        (Agent A)  (Agent B)   (Agent C)
            │         │         │
            │         │         │
            ▼         ▼         ▼
          PR #3     PR #4     PR #5
            │         │         │
            └─────────┼─────────┘
                      │
                    main (merged sequentially)
```

**Why this works:**
- Each agent's changes are isolated in their own branch.
- Conflicts are detected at PR time, not during development.
- Merges happen sequentially (one PR at a time), so conflict resolution is straightforward.
- If a conflict does arise, only the later PR needs to rebase -- the first PR merges cleanly.

**Limitations:**
- Agents cannot see each other's in-progress changes until PR merge.
- If Agent B depends on Agent A's work, Agent B must wait for Agent A's PR to merge before starting.
- Shared infrastructure changes (design system, utility functions) can cause cascading conflicts.

### 4.3 File-Level Locking (Secondary Strategy)

For situations where multiple agents must modify the same file (e.g., updating a shared configuration file or appending to a changelog), VibeOS uses advisory file-level locks:

```json
{
  "locks": {
    "src/lib/supabase.ts": {
      "locked_by": "550e8400-e29b-41d4-a716-446655440000",
      "locked_at": "2026-02-23T10:15:00Z",
      "reason": "Implementing auth middleware",
      "expires_at": "2026-02-23T10:45:00Z"
    },
    "src/styles/globals.css": {
      "locked_by": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
      "locked_at": "2026-02-23T10:20:00Z",
      "reason": "Adding landing page styles",
      "expires_at": "2026-02-23T10:50:00Z"
    }
  }
}
```

```bash
#!/usr/bin/env bash
# check-file-lock.sh
# Checks if a file is locked by another agent before writing.

set -euo pipefail

FILE_PATH="${1:?Usage: check-file-lock.sh <file-path>}"
SESSION_ID="${WARP_SESSION_ID:-$$}"
LOCKS_FILE=".vibeos/locks/file-locks.json"

if [ ! -f "$LOCKS_FILE" ]; then
  echo "No locks file found. File is available."
  exit 0
fi

# Check if this file is locked
LOCK_OWNER=$(jq -r \
  --arg path "$FILE_PATH" \
  '.locks[$path].locked_by // empty' \
  "$LOCKS_FILE")

if [ -z "$LOCK_OWNER" ]; then
  echo "File is available: $FILE_PATH"
  exit 0
fi

if [ "$LOCK_OWNER" = "$SESSION_ID" ]; then
  echo "File is locked by this session: $FILE_PATH"
  exit 0
fi

# Check if lock has expired
EXPIRES=$(jq -r \
  --arg path "$FILE_PATH" \
  '.locks[$path].expires_at // empty' \
  "$LOCKS_FILE")

if [ -n "$EXPIRES" ]; then
  EXPIRES_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$EXPIRES" "+%s" 2>/dev/null || echo "0")
  NOW_EPOCH=$(date "+%s")
  if [ "$NOW_EPOCH" -gt "$EXPIRES_EPOCH" ]; then
    echo "Lock on $FILE_PATH has expired. Removing."
    jq --arg path "$FILE_PATH" 'del(.locks[$path])' \
      "$LOCKS_FILE" > "${LOCKS_FILE}.tmp" \
      && mv "${LOCKS_FILE}.tmp" "$LOCKS_FILE"
    exit 0
  fi
fi

LOCK_REASON=$(jq -r \
  --arg path "$FILE_PATH" \
  '.locks[$path].reason // "unknown"' \
  "$LOCKS_FILE")

echo "BLOCKED: $FILE_PATH is locked by session $LOCK_OWNER."
echo "Reason: $LOCK_REASON"
echo "Expires: $EXPIRES"
exit 1
```

### 4.4 Conflict Prevention Through Task Design

The most effective conflict prevention happens at the design level, before agents start coding. VibeOS enforces this through the Two-Tier Workflow:

**Tier 1 (Project Foundation)** establishes all shared infrastructure before any feature development begins:

| Foundation Artifact | What It Locks Down | Why It Prevents Conflicts |
|--------------------|--------------------|--------------------------|
| `design-system.css` | Colors, typography, spacing, component tokens | All feature agents use the same design tokens -- no conflicting style definitions |
| TDR (Tech Stack) | Framework, libraries, API patterns | All agents use the same stack -- no conflicting dependency choices |
| `CLAUDE.md` | Coding conventions, file structure | All agents follow the same conventions -- consistent code structure |
| Roadmap | Feature boundaries and scope | Features are designed to minimize overlap |

**Tier 2 (Feature Development)** benefits from this foundation because:

1. **Features touch mostly feature-specific files**: A well-designed feature architecture means `feat/auth` modifies `src/app/auth/`, `src/lib/auth.ts`, and `src/components/auth/` -- files that `feat/landing-page` never touches.
2. **Shared utilities are established in Tier 1**: Common utilities, the database client, the design system -- all defined before features begin. Feature agents consume these; they do not modify them.
3. **Feature specs define file boundaries**: Each feature's acceptance criteria implicitly define which files it will create or modify, reducing surprise overlaps.

### 4.5 Conflict Detection Before It Happens

Even with branch isolation and task design, conflicts can still occur. VibeOS should detect potential conflicts before they become merge conflicts:

```bash
#!/usr/bin/env bash
# detect-potential-conflicts.sh
# Checks if the current branch has potential conflicts with other active branches.

set -euo pipefail

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BASE_BRANCH="${1:-main}"

echo "Checking for potential conflicts between $CURRENT_BRANCH and other active branches..."
echo ""

# Get all active feature branches (excluding main and current)
ACTIVE_BRANCHES=$(git branch -r --no-merged "$BASE_BRANCH" 2>/dev/null \
  | grep -v HEAD \
  | grep -v "$CURRENT_BRANCH" \
  | sed 's/^ *origin\///' \
  | grep -E '^feat/' || true)

if [ -z "$ACTIVE_BRANCHES" ]; then
  echo "No other active feature branches. No conflict risk."
  exit 0
fi

# Get files modified in the current branch
CURRENT_FILES=$(git diff --name-only "$BASE_BRANCH..HEAD" 2>/dev/null | sort)

if [ -z "$CURRENT_FILES" ]; then
  echo "No files modified in current branch yet."
  exit 0
fi

CONFLICT_RISK=false

for branch in $ACTIVE_BRANCHES; do
  # Get files modified in the other branch
  OTHER_FILES=$(git diff --name-only "$BASE_BRANCH..origin/$branch" 2>/dev/null | sort || true)

  if [ -z "$OTHER_FILES" ]; then
    continue
  fi

  # Find overlapping files
  OVERLAP=$(comm -12 <(echo "$CURRENT_FILES") <(echo "$OTHER_FILES") || true)

  if [ -n "$OVERLAP" ]; then
    CONFLICT_RISK=true
    echo "WARNING: Potential conflict with branch '$branch':"
    echo "$OVERLAP" | sed 's/^/  - /'
    echo ""
  fi
done

if [ "$CONFLICT_RISK" = true ]; then
  echo "RESULT: Potential conflicts detected. Consider coordinating with the other agent(s)."
  exit 1
else
  echo "RESULT: No overlapping files detected. Low conflict risk."
  exit 0
fi
```

---

## 5. Branch-Per-Agent Strategies

### 5.1 Branch Naming Convention

Every agent-created branch follows a strict naming convention that encodes the feature identity and optionally the session ID for traceability:

```
feat/<feature-slug>
```

For cases where multiple agents work on the same feature (e.g., Feature Developer creates the code, then Test Writer works on the same branch for tests), the branch is shared by passing it between agents. The branch is identified by the feature, not by the agent.

**Examples:**

```
feat/user-authentication        # Feature Developer and Test Writer share this
feat/landing-page               # Standalone feature branch
feat/trip-creation              # Another feature branch
fix/auth-redirect-loop          # Bug fix branch
```

**Rules:**
- Lowercase only
- Hyphens as word separators (no underscores, no spaces)
- Maximum 50 characters for the slug portion
- Prefix matches the conventional commit type (`feat/`, `fix/`, `docs/`, `refactor/`, etc.)
- Branch is created from the latest `main`

### 5.2 Branch Creation Script

```bash
#!/usr/bin/env bash
# create-agent-branch.sh
# Creates a feature branch for an agent to work on.

set -euo pipefail

FEATURE_ID="${1:?Usage: create-agent-branch.sh <feature-id>}"
BACKLOG_FILE=".vibeos/backlog.json"

# Extract feature name from backlog
FEATURE_NAME=$(jq -r \
  --arg id "$FEATURE_ID" \
  '.features[] | select(.id == $id) | .name' \
  "$BACKLOG_FILE")

if [ -z "$FEATURE_NAME" ] || [ "$FEATURE_NAME" = "null" ]; then
  echo "ERROR: Feature $FEATURE_ID not found in backlog."
  exit 1
fi

# Slugify the feature name
SLUG=$(echo "$FEATURE_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-50)
BRANCH_NAME="feat/${SLUG}"

# Check if branch already exists
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
  echo "Branch already exists: $BRANCH_NAME"
  echo "Switching to it..."
  git checkout "$BRANCH_NAME"

  # Rebase onto latest main to pick up any merged changes
  echo "Rebasing onto latest main..."
  git fetch origin main
  if ! git rebase origin/main; then
    echo "WARNING: Rebase has conflicts. Aborting rebase."
    git rebase --abort
    echo "Continuing on current branch state."
  fi
else
  # Create from latest main
  echo "Creating new branch: $BRANCH_NAME"
  git fetch origin main
  git checkout -b "$BRANCH_NAME" origin/main
fi

# Update the backlog with the branch name
bash scripts/acquire-lock.sh "$BACKLOG_FILE" 10

jq --arg id "$FEATURE_ID" \
   --arg branch "$BRANCH_NAME" \
   '(.features[] | select(.id == $id)) |= (.branch = $branch)' \
   "$BACKLOG_FILE" > "${BACKLOG_FILE}.tmp" \
   && mv "${BACKLOG_FILE}.tmp" "$BACKLOG_FILE"

bash scripts/release-lock.sh "$BACKLOG_FILE"

echo "Ready to work on branch: $BRANCH_NAME"
```

### 5.3 Short-Lived Branch Lifecycle

Agent branches should be short-lived to minimize divergence from `main` and reduce conflict risk:

```
Timeline:
  ┌─────────┬─────────┬─────────┬─────────┬─────────┐
  │ Create  │ Develop │ Test    │ PR      │ Merge   │
  │ branch  │ (1-2h)  │ (30m)  │ review  │ + delete│
  │         │         │         │ (manual)│         │
  └─────────┴─────────┴─────────┴─────────┴─────────┘

  Target: < 4 hours from branch creation to merge.
  Maximum: 24 hours before the branch is considered stale.
```

**Branch lifecycle operations:**

```bash
#!/usr/bin/env bash
# cleanup-agent-branches.sh
# Removes merged and stale agent branches.

set -euo pipefail

echo "=== Agent Branch Cleanup ==="
echo ""

# Delete local branches that have been merged into main
echo "Cleaning merged branches..."
MERGED=$(git branch --merged main | grep -E '^\s+feat/' | sed 's/^ *//' || true)

if [ -n "$MERGED" ]; then
  echo "$MERGED" | while read -r branch; do
    echo "  Deleting merged branch: $branch"
    git branch -d "$branch"
    # Also delete remote if it exists
    if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
      git push origin --delete "$branch"
    fi
  done
else
  echo "  No merged branches to clean."
fi

echo ""

# Warn about stale branches (no commits in 24 hours)
echo "Checking for stale branches..."
STALE_THRESHOLD=$((24 * 60 * 60))  # 24 hours in seconds
NOW=$(date "+%s")

git branch -r --no-merged main | grep 'origin/feat/' | sed 's/^ *origin\///' | while read -r branch; do
  LAST_COMMIT=$(git log -1 --format="%ct" "origin/$branch" 2>/dev/null || echo "0")
  AGE=$(( NOW - LAST_COMMIT ))

  if [ "$AGE" -gt "$STALE_THRESHOLD" ]; then
    AGE_HOURS=$(( AGE / 3600 ))
    echo "  STALE: $branch (last commit ${AGE_HOURS}h ago)"
  fi
done

echo ""
echo "Branch cleanup complete."
```

### 5.4 Rebase-Before-PR Strategy

Before creating a PR, every agent branch should rebase onto the latest `main` to ensure a clean, linear history and to surface any conflicts early:

```bash
#!/usr/bin/env bash
# prepare-for-pr.sh
# Rebases the current branch onto main and handles conflicts gracefully.

set -euo pipefail

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "ERROR: Cannot prepare a PR from the main branch."
  exit 1
fi

echo "Preparing branch '$CURRENT_BRANCH' for PR..."

# Fetch latest main
git fetch origin main

# Check if rebase is needed
BEHIND=$(git rev-list --count "HEAD..origin/main" 2>/dev/null || echo "0")

if [ "$BEHIND" -eq 0 ]; then
  echo "Branch is up to date with main. No rebase needed."
  exit 0
fi

echo "Branch is $BEHIND commit(s) behind main. Rebasing..."

# Attempt rebase
if git rebase origin/main; then
  echo "Rebase successful. Branch is ready for PR."
  # Force push the rebased branch (safe because it's a feature branch)
  git push --force-with-lease origin "$CURRENT_BRANCH"
else
  echo "ERROR: Rebase has conflicts."
  echo ""
  echo "Conflicting files:"
  git diff --name-only --diff-filter=U
  echo ""
  echo "Aborting rebase. Manual conflict resolution required."
  git rebase --abort

  # Fire a notification to alert the developer
  if command -v terminal-notifier &>/dev/null; then
    SESSION_ID="${WARP_SESSION_ID:-}"
    DEEP_LINK=""
    if [ -n "$SESSION_ID" ]; then
      DEEP_LINK="warp://session/$SESSION_ID"
    fi

    terminal-notifier \
      -title "VibeOS: Merge Conflict" \
      -message "Branch '$CURRENT_BRANCH' has conflicts with main. Manual resolution needed." \
      -sound "Basso" \
      ${DEEP_LINK:+-execute "open '$DEEP_LINK'"}
  fi

  exit 1
fi
```

---

## 6. Orchestrator Coordination Pattern

### 6.1 The Workflow Orchestrator Role

The Workflow Orchestrator is the central brain of the VibeOS multi-agent system. It runs in the primary terminal tab (Tab 1) and coordinates all other agents. Unlike specialized agents that perform a single task (write code, run tests, generate docs), the Orchestrator's job is purely coordination:

- Read the project state and determine what needs to happen next
- Launch specialized agents in other tabs
- Monitor progress via signal files and git status
- Handle handoffs between agents (e.g., Developer finishes, route to Test Writer)
- Detect and resolve bottlenecks (e.g., stale locks, crashed sessions)

### 6.2 Orchestrator Decision Logic

The Orchestrator follows a decision tree at session start and after each agent completion:

```
┌─────────────────────────────────────────────────────────────┐
│              ORCHESTRATOR DECISION TREE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Read .vibeos/state.json                                 │
│     └─ Is foundation complete?                              │
│        ├─ NO  → Route to Tier 1 (foundation workflow)       │
│        └─ YES → Continue to step 2                          │
│                                                             │
│  2. Check .vibeos/signals/ for completed tasks              │
│     └─ Any completion signals?                              │
│        ├─ YES → Process completions (advance phases)        │
│        └─ NO  → Continue to step 3                          │
│                                                             │
│  3. Check .vibeos/backlog.json for available work           │
│     └─ Any "ready" tasks with satisfied dependencies?       │
│        ├─ YES → Determine agent type, instruct user         │
│        │        to launch agent in new tab                  │
│        └─ NO  → Continue to step 4                          │
│                                                             │
│  4. Check for in-progress tasks                             │
│     └─ Any tasks currently being worked?                    │
│        ├─ YES → Report status, wait for signals             │
│        └─ NO  → All work complete! Report summary.          │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6.3 Agent Routing Table

The Orchestrator maintains a mapping between feature phases and the agent types that handle them:

| Feature Phase | Agent Type | Model | Launch Command |
|--------------|------------|-------|----------------|
| `plan` | Workflow Orchestrator | Sonnet | (self -- handled in current session) |
| `design` | UI Designer | Sonnet | `claude /agent ui-designer "<task>"` |
| `code` | Feature Developer | Sonnet | `claude /agent feature-developer "<task>"` |
| `test` | Test Writer | Sonnet | `claude /agent test-writer "<task>"` |
| `review` | Quality Check | Haiku | `claude /agent quality-check "<task>"` |
| `docs` | Doc Generator | Sonnet | `claude /agent doc-generator "<task>"` |

### 6.4 Orchestrator State Check Script

```bash
#!/usr/bin/env bash
# orchestrator-status.sh
# Generates a comprehensive status report for the Orchestrator agent.

set -euo pipefail

STATE_FILE=".vibeos/state.json"
BACKLOG_FILE=".vibeos/backlog.json"
SIGNAL_DIR=".vibeos/signals"

echo "═══════════════════════════════════════════"
echo "       VibeOS Orchestrator Status Report   "
echo "═══════════════════════════════════════════"
echo ""

# 1. Foundation status
if [ -f "$STATE_FILE" ]; then
  FOUNDATION=$(jq -r '.foundation.status // "unknown"' "$STATE_FILE")
  echo "Foundation: $FOUNDATION"
else
  echo "Foundation: NOT INITIALIZED (state.json missing)"
  echo ""
  echo "Action: Run /setup to initialize the project."
  exit 0
fi

echo ""

# 2. Active sessions
echo "--- Active Sessions ---"
if [ -f "$STATE_FILE" ]; then
  SESSION_COUNT=$(jq -r '.parallel_sessions | length' "$STATE_FILE")
  if [ "$SESSION_COUNT" -gt 0 ]; then
    jq -r '.parallel_sessions[] | "  [\(.status)] \(.agent_type) → \(.task) (Tab: \(.warp_tab))"' "$STATE_FILE"
  else
    echo "  No active sessions."
  fi
fi

echo ""

# 3. Backlog summary
echo "--- Backlog Summary ---"
if [ -f "$BACKLOG_FILE" ]; then
  for status in idea planned ready in-progress testing review done; do
    COUNT=$(jq -r --arg s "$status" '[.features[] | select(.status == $s)] | length' "$BACKLOG_FILE")
    if [ "$COUNT" -gt 0 ]; then
      echo "  $status: $COUNT"
    fi
  done
else
  echo "  No backlog found."
fi

echo ""

# 4. Pending signals
echo "--- Pending Signals ---"
if [ -d "$SIGNAL_DIR" ]; then
  SIGNAL_COUNT=$(ls -1 "$SIGNAL_DIR" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$SIGNAL_COUNT" -gt 0 ]; then
    ls -1 "$SIGNAL_DIR" | while read -r signal; do
      echo "  $signal"
    done
  else
    echo "  No pending signals."
  fi
else
  echo "  No signals directory."
fi

echo ""

# 5. Next action recommendation
echo "--- Recommended Action ---"

# Check for pending signals first
if [ -d "$SIGNAL_DIR" ] && [ "$(ls -1 "$SIGNAL_DIR" 2>/dev/null | wc -l | tr -d ' ')" -gt 0 ]; then
  echo "  Process pending completion signals."
elif [ -f "$BACKLOG_FILE" ]; then
  NEXT_READY=$(jq -r '
    [.features[] | select(.status == "ready")]
    | sort_by(.priority)
    | first
    | "\(.id): \(.name) (priority \(.priority))"
  ' "$BACKLOG_FILE" 2>/dev/null || echo "")

  if [ -n "$NEXT_READY" ] && [ "$NEXT_READY" != "null: null (priority null)" ]; then
    echo "  Launch agent for next ready task: $NEXT_READY"
  else
    IN_PROGRESS=$(jq -r '[.features[] | select(.status == "in-progress" or .status == "testing")] | length' "$BACKLOG_FILE")
    if [ "$IN_PROGRESS" -gt 0 ]; then
      echo "  Wait for in-progress tasks to complete."
    else
      echo "  All tasks complete! Consider running /wrap."
    fi
  fi
fi

echo ""
echo "═══════════════════════════════════════════"
```

### 6.5 Handoff Coordination

When one agent finishes and another needs to pick up, the Orchestrator mediates the handoff. The key challenge is that the Orchestrator cannot programmatically launch a new Claude Code session in another tab -- that requires the developer to manually open a new tab and run the command. The Orchestrator's role is to:

1. Detect the completion (via signal file)
2. Determine the next required agent type
3. Instruct the developer on what to launch next
4. Optionally fire a notification to alert the developer

```bash
#!/usr/bin/env bash
# process-handoff.sh
# Processes a completion signal and determines the next handoff.

set -euo pipefail

SIGNAL_FILE="${1:?Usage: process-handoff.sh <signal-file>}"

if [ ! -f "$SIGNAL_FILE" ]; then
  echo "Signal file not found: $SIGNAL_FILE"
  exit 1
fi

# Parse the signal
FEATURE_ID=$(jq -r '.feature_id' "$SIGNAL_FILE")
COMPLETED_PHASE=$(jq -r '.completed_phase' "$SIGNAL_FILE")
NEXT_PHASE=$(jq -r '.next_phase' "$SIGNAL_FILE")

echo "Handoff detected:"
echo "  Feature: $FEATURE_ID"
echo "  Completed: $COMPLETED_PHASE"
echo "  Next: $NEXT_PHASE"
echo ""

# Determine the next agent
case "$NEXT_PHASE" in
  "design")
    AGENT="ui-designer"
    echo "ACTION: Launch UI Designer agent in a new tab:"
    echo "  claude /agent ui-designer \"Design components for $FEATURE_ID\""
    ;;
  "code")
    AGENT="feature-developer"
    echo "ACTION: Launch Feature Developer agent in a new tab:"
    echo "  claude /agent feature-developer \"Implement $FEATURE_ID per spec in backlog.json\""
    ;;
  "test")
    AGENT="test-writer"
    echo "ACTION: Launch Test Writer agent in a new tab:"
    echo "  claude /agent test-writer \"Write tests for $FEATURE_ID\""
    ;;
  "review")
    AGENT="quality-check"
    echo "ACTION: Launch Quality Check agent in a new tab:"
    echo "  claude /agent quality-check \"Run quality checks for $FEATURE_ID\""
    ;;
  "done")
    echo "Feature $FEATURE_ID is complete! No further agents needed."
    echo "The PR is ready for your review."
    ;;
  *)
    echo "Unknown phase: $NEXT_PHASE"
    exit 1
    ;;
esac

# Clean up the processed signal
rm -f "$SIGNAL_FILE"
echo ""
echo "Signal processed and removed."
```

---

## 7. Concurrency Limits and Resource Management

### 7.1 API Rate Limits

Running 5-15 parallel Claude Code sessions means 5-15 simultaneous API call streams to Anthropic's servers. Each session independently manages its own API requests, but they all draw from the same account's rate limits.

**Anthropic API rate limits** (as of early 2026):

| Tier | Requests/min | Tokens/min (input) | Tokens/min (output) |
|------|-------------|---------------------|---------------------|
| Tier 1 (free) | 50 | 40,000 | 8,000 |
| Tier 2 (paid) | 1,000 | 400,000 | 80,000 |
| Tier 3 (scale) | 4,000 | 2,000,000 | 400,000 |
| Tier 4 (enterprise) | Custom | Custom | Custom |

**Practical implications for VibeOS:**

- With 10 parallel Sonnet sessions, each session needs roughly 100 requests/min and 40,000 input tokens/min of headroom. This is feasible on Tier 2 but tight on Tier 1.
- Haiku sessions (Session Startup, Quality Check) consume significantly fewer tokens per request, making them suitable for high-frequency lightweight tasks.
- The `--max-turns` flag in Claude Code can limit the number of autonomous turns per session, preventing runaway token consumption.

### 7.2 Cost Management Through Model Selection

VibeOS's agent architecture assigns models strategically to minimize cost while maintaining quality:

| Agent | Model | Rationale |
|-------|-------|-----------|
| Session Startup | Haiku | Simple routing logic -- does not need advanced reasoning |
| Workflow Orchestrator | Sonnet | Needs to understand project context and make routing decisions |
| Stack Scout | Sonnet | Research requires strong analytical and synthesis capabilities |
| UI Designer | Sonnet | Design decisions require creative and contextual reasoning |
| Feature Developer | Sonnet | Code generation requires the highest quality model |
| Test Writer | Sonnet | Test design requires understanding of both code and requirements |
| Doc Generator | Sonnet | Technical writing requires good language and structure |
| Performance Coach | Sonnet | Transcript analysis requires nuanced pattern recognition |
| Quality Check | Haiku | Running tests/lint is mostly command execution, minimal reasoning |

**Cost ratio**: Haiku is approximately 10-20x cheaper per token than Sonnet. By routing lightweight tasks (startup routing, running tests) to Haiku, VibeOS saves significantly on the most frequently executed agents.

### 7.3 Context Window Budget Per Agent

Each agent session has its own context window. VibeOS targets <50% context usage per session to leave room for the model to reason and for tool results. Exceeding this target triggers warnings via the `check-context.sh` hook.

| Budget Threshold | Action |
|-----------------|--------|
| 0-50% | Normal operation. No intervention. |
| 50-60% | INFO: Agent should start wrapping up the current task. |
| 60-80% | WARNING: Notification fires. Agent should commit work and prepare to hand off. |
| 80-100% | CRITICAL: Session must terminate. Force commit, create signal, hand off. |

```bash
#!/usr/bin/env bash
# check-context.sh
# Hook: Stop
# Warns the developer when context usage approaches limits.
# Called by Claude Code after each assistant turn.

set -euo pipefail

# Claude Code passes context usage info via environment or stdin
INPUT=$(cat)
CONTEXT_PERCENT=$(echo "$INPUT" | jq -r '.percent_used // 0')

if [ "$CONTEXT_PERCENT" -ge 80 ]; then
  echo "CRITICAL: Context usage at ${CONTEXT_PERCENT}%."
  echo "Commit your work immediately and terminate this session."
  echo "Run /wrap to gracefully end the session."

  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
      -title "VibeOS: Context Critical" \
      -message "Context at ${CONTEXT_PERCENT}%. Session must end soon." \
      -sound "Basso"
  fi
elif [ "$CONTEXT_PERCENT" -ge 60 ]; then
  echo "WARNING: Context usage at ${CONTEXT_PERCENT}%."
  echo "Start wrapping up the current task."

  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
      -title "VibeOS: Context Warning" \
      -message "Context at ${CONTEXT_PERCENT}%. Consider wrapping up." \
      -sound "Submarine"
  fi
fi
```

### 7.4 Parallel Session Guidelines

Based on practical constraints, the following guidelines help developers balance parallelism against resource limits:

| Developer Scenario | Recommended Sessions | Rationale |
|-------------------|---------------------|-----------|
| Solo developer, free tier | 2-3 | API rate limits are the binding constraint |
| Solo developer, paid tier | 5-8 | Attention is the binding constraint -- more tabs mean more polling |
| Solo developer, paid tier + VibeOS notifications | 8-15 | Notifications solve the attention problem, API limits are generous |
| Team (shared account) | 3-5 per person | Account-level rate limits shared across the team |

---

## 8. Error Recovery in Multi-Agent Systems

### 8.1 Failure Modes

Multi-agent systems have more failure modes than single-agent systems. Understanding these modes is critical for designing robust recovery:

| Failure Mode | Description | Impact | Recovery |
|-------------|-------------|--------|----------|
| **Agent crash** | Claude Code process terminates unexpectedly | Uncommitted work lost, stale session in state.json | Session Startup detects stale entry, cleans up |
| **Context exhaustion** | Agent hits 100% context without finishing | Task incomplete, may be in inconsistent state | New session picks up from last committed state |
| **API rate limit** | Anthropic API rejects requests (429) | Agent stalls, retries, may timeout | Wait and retry -- Claude Code handles this internally |
| **Stale lock** | Agent crashes while holding a lock | Other agents cannot update shared state | Timeout-based lock expiry (30 minutes) |
| **Git conflict** | Rebase or merge produces conflicts | Agent cannot complete PR preparation | Notification fired, developer resolves manually |
| **Hook failure** | Bash script in hook pipeline exits non-zero | Agent action blocked (by design for safety hooks) | Agent should not bypass -- report to developer |
| **Network failure** | Internet connectivity lost | API calls fail, git push/fetch fail | Agent should commit locally, retry on reconnect |

### 8.2 Session State Preservation

The most important principle for error recovery is that **session state is preserved on disk, not in the context window**. If an agent crashes, the next agent can pick up where it left off by reading the filesystem:

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440000",
  "agent_type": "feature-developer",
  "task_id": "feat-003",
  "status": "crashed",
  "started_at": "2026-02-23T10:15:00Z",
  "last_activity": "2026-02-23T10:45:00Z",
  "branch": "feat/user-authentication",
  "last_commit": "a1b2c3d",
  "last_commit_message": "feat(auth): add login form component",
  "files_modified_since_commit": [
    "src/lib/auth.ts",
    "src/middleware.ts"
  ],
  "crash_info": {
    "detected_at": "2026-02-23T11:00:00Z",
    "detected_by": "session-startup",
    "reason": "Session entry in state.json but process not running"
  }
}
```

### 8.3 Idempotent Operations

All agent operations should be designed to be **idempotent** -- safe to re-run without causing harm. This is the foundation of error recovery: if an agent crashes halfway through a task, a new agent can re-run the same task from the beginning and produce the correct result.

**Idempotent patterns:**

| Operation | Idempotent Approach |
|-----------|-------------------|
| Create file | Check if file exists first; overwrite if content differs |
| Create branch | Check if branch exists; switch to it if so |
| Create PR | Check if PR already exists for the branch; skip if so |
| Update backlog | Read current state, only write if change needed |
| Run tests | Tests are inherently idempotent |
| Install dependencies | `npm install` is idempotent (reads lock file) |

```bash
#!/usr/bin/env bash
# idempotent-pr.sh
# Creates a PR only if one doesn't already exist for this branch.

set -euo pipefail

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Check if a PR already exists
EXISTING_PR=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number // empty' 2>/dev/null || true)

if [ -n "$EXISTING_PR" ]; then
  echo "PR #$EXISTING_PR already exists for branch $BRANCH. Skipping creation."
  echo "URL: $(gh pr view "$EXISTING_PR" --json url --jq '.url')"
  exit 0
fi

echo "No existing PR for $BRANCH. Creating..."
# Proceed with PR creation
```

### 8.4 Stale Session Detection and Cleanup

The Session Startup agent runs at the beginning of every new session and is responsible for detecting stale sessions from crashed agents:

```bash
#!/usr/bin/env bash
# detect-stale-sessions.sh
# Detects and cleans up session entries from crashed agents.

set -euo pipefail

STATE_FILE=".vibeos/state.json"

if [ ! -f "$STATE_FILE" ]; then
  echo "No state file found. Nothing to clean."
  exit 0
fi

STALE_COUNT=0

# Get all registered sessions
SESSIONS=$(jq -r '.parallel_sessions[] | @base64' "$STATE_FILE" 2>/dev/null || true)

if [ -z "$SESSIONS" ]; then
  echo "No active sessions registered."
  exit 0
fi

echo "Checking for stale sessions..."

for encoded in $SESSIONS; do
  SESSION=$(echo "$encoded" | base64 --decode)
  SID=$(echo "$SESSION" | jq -r '.session_id')
  AGENT_TYPE=$(echo "$SESSION" | jq -r '.agent_type')
  STARTED=$(echo "$SESSION" | jq -r '.started_at')
  STATUS=$(echo "$SESSION" | jq -r '.status')

  # Only check "active" sessions
  if [ "$STATUS" != "active" ]; then
    continue
  fi

  # Check if the session's started_at is older than 2 hours (likely stale)
  if [ -n "$STARTED" ]; then
    STARTED_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$STARTED" "+%s" 2>/dev/null || echo "0")
    NOW_EPOCH=$(date "+%s")
    AGE=$(( NOW_EPOCH - STARTED_EPOCH ))

    if [ "$AGE" -gt 7200 ]; then
      echo "  STALE: Session $SID ($AGENT_TYPE) started ${AGE}s ago."
      STALE_COUNT=$((STALE_COUNT + 1))

      # Archive the stale session
      mkdir -p ".vibeos/sessions"
      echo "$SESSION" | jq '. + {"status": "crashed", "detected_stale_at": now | todate}' \
        > ".vibeos/sessions/${SID}.json"
    fi
  fi
done

if [ "$STALE_COUNT" -gt 0 ]; then
  echo ""
  echo "Found $STALE_COUNT stale session(s). Cleaning state.json..."

  # Remove stale sessions (older than 2 hours) from parallel_sessions
  NOW_EPOCH=$(date "+%s")
  jq --argjson threshold 7200 \
     --argjson now "$NOW_EPOCH" \
     '.parallel_sessions = [.parallel_sessions[] |
       select(
         .status != "active" or
         ((.started_at | sub("Z$"; "+00:00") | fromdate) > ($now - $threshold))
       )
     ]' "$STATE_FILE" > "${STATE_FILE}.tmp" \
     && mv "${STATE_FILE}.tmp" "$STATE_FILE"

  echo "Stale sessions removed from state.json."
else
  echo "No stale sessions detected."
fi
```

### 8.5 Lock Cleanup

Stale locks (left behind by crashed agents) are a common problem in advisory locking systems. VibeOS handles this through multiple mechanisms:

1. **Timeout-based expiry**: Locks older than 30 minutes are considered stale and are automatically removed by any agent that encounters them (implemented in `acquire-lock.sh` in Section 2.6).

2. **PID-based detection**: When acquiring a lock, the locking agent records its process ID. If the process is no longer running (`kill -0 $PID` fails), the lock is stale.

3. **Startup cleanup**: The Session Startup agent sweeps the `.vibeos/locks/` directory at the beginning of every session and removes expired locks.

```bash
#!/usr/bin/env bash
# cleanup-stale-locks.sh
# Removes all stale locks from the .vibeos/locks/ directory.

set -euo pipefail

LOCKS_DIR=".vibeos/locks"
STALE_THRESHOLD=1800  # 30 minutes in seconds

if [ ! -d "$LOCKS_DIR" ]; then
  echo "No locks directory. Nothing to clean."
  exit 0
fi

NOW=$(date "+%s")
CLEANED=0

for lock_dir in "$LOCKS_DIR"/*/; do
  [ -d "$lock_dir" ] || continue

  INFO_FILE="${lock_dir}info.json"
  if [ ! -f "$INFO_FILE" ]; then
    echo "Removing orphaned lock directory: $lock_dir"
    rm -rf "$lock_dir"
    CLEANED=$((CLEANED + 1))
    continue
  fi

  LOCK_PID=$(jq -r '.pid // empty' "$INFO_FILE")
  LOCK_TIME=$(jq -r '.locked_at // empty' "$INFO_FILE")
  LOCK_TARGET=$(jq -r '.target_file // "unknown"' "$INFO_FILE")

  # Check PID
  if [ -n "$LOCK_PID" ] && ! kill -0 "$LOCK_PID" 2>/dev/null; then
    echo "Removing lock for $LOCK_TARGET (PID $LOCK_PID is dead)."
    rm -rf "$lock_dir"
    CLEANED=$((CLEANED + 1))
    continue
  fi

  # Check age
  if [ -n "$LOCK_TIME" ]; then
    LOCK_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LOCK_TIME" "+%s" 2>/dev/null || echo "0")
    AGE=$(( NOW - LOCK_EPOCH ))
    if [ "$AGE" -gt "$STALE_THRESHOLD" ]; then
      echo "Removing stale lock for $LOCK_TARGET (age: ${AGE}s)."
      rm -rf "$lock_dir"
      CLEANED=$((CLEANED + 1))
      continue
    fi
  fi
done

echo "Lock cleanup complete. Removed $CLEANED stale lock(s)."
```

### 8.6 Graceful Degradation

When the multi-agent system encounters failures that cannot be automatically recovered, it should degrade gracefully rather than leaving the project in an inconsistent state:

1. **Uncommitted changes**: If an agent is about to crash or exhaust context, it should `git stash` or commit with a `wip:` prefix so work is not lost.

2. **Partial feature completion**: If an agent completes 3 of 5 acceptance criteria before crashing, the next agent should be able to read the git history and the backlog spec to determine what remains.

3. **Notification on failure**: The PostToolUseFailure hook fires a notification whenever a critical tool execution fails, alerting the developer immediately rather than silently stalling.

4. **State consistency**: The `state.json` and `backlog.json` files should always reflect the last known-good state. Agents update state files only after successfully completing an operation -- never before.

---

## 9. Recommendations for VibeOS

Based on the research above, here are the specific recommendations for implementing multi-agent orchestration in VibeOS:

### 9.1 Primary Communication Channel: `.vibeos/` Directory

Use the `.vibeos/` directory as the sole communication channel between agents. Do not introduce sockets, databases, or other infrastructure. The file-based approach is:

- **Inspectable**: Developers can `cat .vibeos/state.json` at any time to understand the system state.
- **Debuggable**: If something goes wrong, the developer can manually edit the JSON files to fix the state.
- **Persistent**: State survives agent crashes, terminal closures, and even machine reboots.
- **Simple**: No additional infrastructure to install, configure, or maintain.

### 9.2 Lock Strategy: `mkdir`-Based Advisory Locks

Use the `mkdir`-based locking approach (Section 2.6) for all shared file writes. Key points:

- `mkdir` is atomic on POSIX filesystems -- it either succeeds or fails, with no race conditions.
- Include PID and timestamp in lock metadata for stale detection.
- Set a 30-minute timeout for automatic stale lock removal.
- Always release locks in a trap handler to handle unexpected script termination:

```bash
# Example: lock with cleanup trap
LOCK_PATH=".vibeos/locks/state.json.lock"
trap 'rm -rf "$LOCK_PATH"' EXIT

mkdir "$LOCK_PATH"
# ... do work ...
# Lock is automatically released on exit (normal or error)
```

### 9.3 Branch-Per-Feature, Not Branch-Per-Agent

Name branches after the feature they implement, not the agent that creates them. Multiple agents may work on the same branch sequentially (Developer creates code, Test Writer adds tests on the same branch). The branch is the feature's workspace, not the agent's workspace.

### 9.4 Orchestrator as Advisor, Not Controller

The Workflow Orchestrator cannot programmatically launch Claude Code sessions in other terminal tabs. It should function as an advisor:

1. Present a clear status report of the project.
2. Recommend the next action with a copy-pasteable command.
3. Fire a notification when a handoff is needed.
4. Leave the actual session launch to the developer.

This aligns with the VibeOS philosophy that human attention is the bottleneck -- the system should minimize the developer's cognitive load but not remove their agency.

### 9.5 Signal Files for Loose Coupling

Use signal files (Section 2.5) for all inter-agent event notifications. Signals are:

- **Fire-and-forget**: The signaling agent does not wait for acknowledgment.
- **Idempotent**: Multiple agents can check the same signal without conflict.
- **Cheap**: A zero-byte file creation is the cheapest possible filesystem operation.
- **Ephemeral**: Signals are gitignored and cleaned up after processing.

### 9.6 Idempotency as a Hard Rule

Every agent operation must be safe to re-run. This is non-negotiable in a system where agents can crash at any point. Specific requirements:

- Before creating a file, check if it already exists with the correct content.
- Before creating a branch, check if it already exists.
- Before creating a PR, check if one already exists for the branch.
- Before updating `backlog.json`, verify the current state matches expectations.
- Tests are inherently idempotent and should be the primary verification mechanism.

### 9.7 Error Recovery Chain

Implement a three-tier error recovery chain:

| Tier | Mechanism | Example |
|------|-----------|---------|
| **Automatic** | Built into scripts | Stale lock removal, stale session cleanup |
| **Notification** | Alert developer via Interrupt Protocol | Merge conflict, critical failure, context exhaustion |
| **Manual** | Developer intervenes directly | Edit state.json, resolve git conflicts, restart session |

The goal is to handle the majority of failures automatically (Tier 1), escalate only genuine ambiguities to the developer (Tier 2), and provide clear documentation for manual recovery (Tier 3).

### 9.8 Concurrency Budget

Set a default concurrency limit of **5 parallel sessions** for new users, with an option to increase to 15 for experienced users. The default should prioritize simplicity over throughput:

- Tab 1: Workflow Orchestrator (always running)
- Tab 2: Primary Feature Developer
- Tab 3: Test Writer (works on the previous feature while the Developer works on the current one)
- Tab 4: Stack Scout / UI Designer (launched on demand)
- Tab 5: Quality Check / Doc Generator (launched on demand)

This 5-tab configuration provides effective parallelism while keeping the attention budget manageable. The Interrupt Protocol ensures the developer never needs to manually poll tabs.

### 9.9 Gitignore Configuration for `.vibeos/`

The `.vibeos/` directory should be partially tracked by git. Persistent state files are committed; ephemeral coordination files are gitignored:

```gitignore
# .gitignore additions for VibeOS

# Ephemeral coordination (never commit)
.vibeos/signals/
.vibeos/locks/

# Session-specific data (never commit)
.vibeos/sessions/

# Vibe Score data (optionally commit for historical tracking)
# .vibeos/scores/

# Config and state (always commit -- shared across sessions)
# !.vibeos/config.json
# !.vibeos/state.json
# !.vibeos/backlog.json
```

---

## 10. Sources

The following sources informed this research:

- **Claude Code documentation -- Hooks**: https://code.claude.com/docs/en/hooks
- **Claude Code documentation -- Hooks Guide**: https://code.claude.com/docs/en/hooks-guide
- **Claude Code documentation -- Plugins**: https://code.claude.com/docs/en/plugins
- **Claude Code documentation -- Plugins Reference**: https://code.claude.com/docs/en/plugins-reference
- **Claude Code documentation -- Costs**: https://code.claude.com/docs/en/costs
- **Warp Terminal -- How Warp Works**: https://www.warp.dev/blog/how-warp-works
- **Warp Terminal -- Desktop Notifications**: https://docs.warp.dev/terminal/more-features/notifications
- **Warp Terminal -- Session ID Environment Variable and Deep Link Support (Issue #8611)**: https://github.com/warpdotdev/warp/issues/8611
- **Warp Terminal -- OSC 9 Desktop Notifications (Issue #7896)**: https://github.com/warpdotdev/warp/issues/7896
- **Official Warp terminal integration for Claude Code**: https://github.com/warpdotdev/claude-code-warp
- **Claude Code Notifications: Get Alerts When Tasks Finish -- alexop.dev**: https://alexop.dev/posts/claude-code-notification-hooks/
- **disler/claude-code-hooks-mastery -- GitHub**: https://github.com/disler/claude-code-hooks-mastery
- **Anthropic API Rate Limits**: https://docs.anthropic.com/en/api/rate-limits
- **POSIX specification -- mkdir atomicity**: https://pubs.opengroup.org/onlinepubs/9699919799/functions/mkdir.html
- **Git documentation -- git-branch**: https://git-scm.com/docs/git-branch
- **Git documentation -- git-rebase**: https://git-scm.com/docs/git-rebase
- **GitHub CLI (`gh`) documentation**: https://cli.github.com/manual/
- **VibeOS Architecture Design Paper (project-local)**: `docs/VibeOS_ Claude Plugin Architecture Design.pdf`
- **VibeOS Complete Guide (project-local)**: `docs/vibeos-guide-complete.md`
- **My Claude Code Setup -- Pedro H. C. Sant'Anna**: https://psantanna.com/claude-code-my-workflow/workflow-guide.html
- **AI-generated Architecture Decision Records (ADR) -- Dennis Adolfi**: https://adolfi.dev/blog/ai-generated-adr/
- **Agent Decision Records (AgDR)**: https://github.com/me2resh/agent-decision-record

> **Note**: Web search and web fetch tools were unavailable during this research session. The content above is based on established documentation, official project design documents, and best practices for file-based IPC, concurrent process coordination, and multi-agent AI systems as of early 2026. All tool versions and APIs referenced were current at the time of writing. Verify specific version numbers, rate limit tiers, and API details against the linked sources for the latest information.
