# Architecture: Workflow Design

> **Phase 2 Architecture** | Document 2.3 (Revised) | February 2026
>
> This document defines the complete workflow design for VibeCrew v1.0, covering five scenarios: new project initialization, existing project onboarding (deferred), the feature lifecycle, the session lifecycle, and parallel work coordination. Each workflow specifies step-by-step sequences, state transitions, agent handoffs via the Agent Teams API, worktree isolation, and hook interactions.
>
> **v1.0 Revision.** This revision aligns with the 14-agent topology (Session Startup, Workflow Orchestrator, Stack Scout, Builder, Verifier), replaces branch-per-agent with worktree-per-agent isolation, replaces copy-paste tab commands with the Agent Teams API, fixes the feature lifecycle contradiction (sequential with verify-fix loops), and defers Workflow 2 (Existing Project Onboarding) to v1.1. All JSON schemas reference `architecture/schemas.md` as the single source of truth.

---

## Table of Contents

1. [Workflow 1: New Project Initialization](#1-workflow-1-new-project-initialization)
2. [Workflow 2: Existing Project Onboarding (Deferred to v1.1)](#2-workflow-2-existing-project-onboarding-deferred-to-v11)
3. [Workflow 3: Feature Lifecycle](#3-workflow-3-feature-lifecycle)
4. [Workflow 4: Session Lifecycle](#4-workflow-4-session-lifecycle)
5. [Workflow 5: Parallel Work Coordination](#5-workflow-5-parallel-work-coordination)
6. [Workflow 6: System Review](#6-workflow-6-system-review)
7. [State Transition Reference](#7-state-transition-reference)
8. [Error Recovery Across Workflows](#8-error-recovery-across-workflows)

---

## 1. Workflow 1: New Project Initialization

### 1.1 Overview

New project initialization takes a user from zero to a fully scaffolded, architecturally sound project with all foundation artifacts in place and the phase gate unlocked for source code writes. It spans two slash commands (`/setup` and `/new-project`) and involves four of the five v1.0 agents: Session Startup, Workflow Orchestrator, Stack Scout, and Builder.

The Orchestrator coordinates the entire flow using the **Agent Teams API** (`TeamCreate`, `TaskCreate`, `SendMessage`). Stack Scout and Builder work in **isolated worktrees** (`isolation: worktree`), preventing filesystem side effects on the main working tree.

### 1.2 End-to-End Sequence

```
USER                 ORCHESTRATOR              AGENTS (via Agent Teams)
 |                       |                               |
 | (optional) install.sh |                               |
 | Installs missing deps |                               |
 | before entering       |                               |
 | Claude Code           |                               |
 |                       |                               |
 |  claude (start)       |                               |
 |---------------------->|                               |
 |                       |  SessionStart hook fires      |
 |                       |-----> session-startup.sh      |
 |                       |       |                       |
 |                       |       | detect: no .vibecrew/   |
 |                       |       | route: first-time     |
 |                       |<------|                       |
 |                       |                               |
 |  /setup               |                               |
 |---------------------->|                               |
 |                       |  1. Dependency check           |
 |                       |     REQUIRED:                  |
 |                       |       git >= 2.30              |
 |                       |       node >= 18               |
 |                       |       jq >= 1.6               |
 |                       |     OPTIONAL:                  |
 |                       |       gh >= 2.0 (+ auth check)|
 |                       |       terminal-notifier?       |
 |                       |                               |
 |                       |  1b. Auto-install offer       |
 |  <-- "Install now?"   |     (if required deps missing)|
 |  "Yes" ------------->|     Execute install commands   |
 |                       |     Re-verify deps            |
 |                       |                               |
 |  <-- terminal prompt  |  2. Terminal selection        |
 |  "Warp"              |     store in config.json      |
 |---------------------->|                               |
 |                       |  3. Notification test         |
 |  <-- OS notification  |     notify.sh "test"          |
 |  "Working!"          |                               |
 |                       |  4. MCP server health check   |
 |                       |     check-mcp-health.sh       |
 |                       |     3 enabled servers tested  |
 |                       |     per-server pass/fail      |
 |                       |                               |
 |                       |  5. Scaffold .vibecrew/         |
 |                       |     config.json               |
 |                       |     state.json                |
 |                       |     backlog.json              |
 |                       |     sessions/                 |
 |                       |     scores/                   |
 |                       |     signals/                  |
 |                       |     locks/                    |
 |                       |                               |
 |  <-- "Setup complete" |                               |
 |                       |                               |
 |  /new-project         |                               |
 |---------------------->|                               |
 |                       |  Orchestrator activates       |
 |                       |                               |
 |                       |  STEP 1: Vision               |
 |                       |  AskUserQuestion x 5          |
 |  <-- questions        |                               |
 |  answers ------------>|                               |
 |                       |  Generate VISION.md           |
 |                       |  (Orchestrator writes via     |
 |                       |   Bash scripts)               |
 |                       |                               |
 |                       |  STEP 2: Design System        |
 |                       |  TeamCreate("foundation")     |
 |                       |  TaskCreate -> Builder         |
 |                       |------------------------------->|
 |                       |                Builder works   |
 |  <-- brand questions  |                in worktree    |
 |  answers ------------>|                               |
 |                       |  Builder generates            |
 |                       |  design-system.css            |
 |                       |  [worktree: .claude/worktrees/|
 |                       |   builder-foundation/]        |
 |                       |  Builder commits in worktree  |
 |                       |  Orchestrator merges back     |
 |                       |<-------------------------------|
 |                       |                               |
 |                       |  STEP 3: Architecture         |
 |                       |  TaskCreate -> Stack Scout    |
 |                       |------------------------------->|
 |                       |                Stack Scout     |
 |                       |                in worktree    |
 |                       |  WebSearch + Context7 +       |
 |                       |  Chrome DevTools research     |
 |                       |  Generate TDR                 |
 |                       |  [worktree: .claude/worktrees/|
 |                       |   scout-tdr-001/]             |
 |                       |  Scout commits in worktree    |
 |                       |  Orchestrator merges back     |
 |                       |<-------------------------------|
 |                       |  Only TDR enters main context |
 |  <-- TDR for review   |                               |
 |  "Approved" --------->|                               |
 |                       |                               |
 |                       |  STEP 4: Roadmap              |
 |  <-- "List features"  |                               |
 |  feature list ------->|                               |
 |                       |  Generate docs/roadmap.md     |
 |                       |                               |
 |                       |  STEP 5: Architecture Diagrams|
 |                       |  Read VISION + TDR + roadmap  |
 |                       |  Generate 5 .mmd files to     |
 |                       |  .vibecrew/architecture/      |
 |                       |                               |
 |                       |  STEP 6: CLAUDE.md            |
 |                       |  Synthesize from all          |
 |                       |  artifacts + diagrams         |
 |                       |  Generate CLAUDE.md           |
 |                       |                               |
 |                       |  STEP 7: Git init + commit    |
 |                       |  git add + commit foundation  |
 |                       |                               |
 |                       |  Update state.json:           |
 |                       |    foundation.complete = true  |
 |                       |                               |
 |  <-- "Foundation      |  PHASE GATE UNLOCKED          |
 |       complete"       |                               |
```

### 1.3 Worktree Lifecycle During Foundation

Both Stack Scout and Builder use `isolation: worktree` during the foundation workflow. The worktree lifecycle is:

```
1. CREATE     Agent frontmatter `isolation: worktree` causes Claude Code
              to create a worktree at .claude/worktrees/<agent>-<task>/

2. WORK       Agent reads/writes within the worktree (sandboxed filesystem)

3. COMMIT     Agent commits work within the worktree

4. MERGE-BACK Orchestrator merges worktree changes back to main branch

5. CLEANUP    Worktree is automatically removed after agent completes
```

**Foundation worktrees:**

| Agent | Worktree Path | Purpose | Merge Target |
|-------|---------------|---------|--------------|
| Builder | `.claude/worktrees/builder-foundation/` | Create `design-system.css` | `main` |
| Stack Scout | `.claude/worktrees/scout-tdr-001/` | Research and produce TDR | `main` |

### 1.4 Foundation State Machine

```
                FOUNDATION STATE MACHINE

    +----------+     /setup     +-----------+
    |   NONE   |--------------->| SCAFFOLDED|
    |(no state)|                |(.vibecrew/  |
    +----------+                | created)  |
                                +-----+-----+
                                      | /new-project
                                      v
                          +--------------------+
                          |   IN-PROGRESS      |
                          |                    |
                          | Substates:         |
                          |  vision: pending   |
                          |  design: pending   |
                          |  tdr: pending      |
                          |  roadmap: pending  |
                          |  claude_md: pending|
                          +--------+-----------+
                                   |
             Each artifact sets its substatus
             from "pending" to "in-progress"
             to "complete"
                                   |
                                   v
                     +--------------------------+
                     |   vision: complete       |
                     |   design: complete       |
                     |   tdr: complete          |
                     |   roadmap: complete      |
                     |   claude_md: complete    |
                     +------------+-------------+
                                  | All 5 complete
                                  v
                          +---------------+
                          |   COMPLETE    |
                          |               |
                          | Phase gate    |
                          | unlocked.     |
                          | Source code   |
                          | writes now    |
                          | allowed.      |
                          +---------------+
```

See `architecture/schemas.md` Section 3 for the canonical `state.json` schema, including the `foundation.artifacts` object structure.

### 1.5 Foundation Artifacts

| Step | Artifact | Agent | Worktree | User Input Required |
|------|----------|-------|----------|---------------------|
| 1 | `VISION.md` | Orchestrator | No (inline) | Yes -- 5 questions via AskUserQuestion |
| 2 | `design-system.css` | Builder | Yes | Yes -- brand preferences (color, font, radius, density) |
| 3 | `docs/tdr-001-tech-stack.md` | Stack Scout | Yes | Yes -- approval of TDR |
| 4 | `docs/roadmap.md` | Orchestrator | No (inline) | Yes -- feature list |
| 5 | `CLAUDE.md` | Orchestrator | No (inline) | No -- synthesized from above |
| 6 | Git commit | Orchestrator | No (inline) | No -- automatic |

### 1.6 Agent Teams Coordination During Foundation

The Orchestrator uses the Agent Teams API to coordinate foundation work:

```
Orchestrator
    |
    +--- TeamCreate("foundation", [builder, stack-scout])
    |
    +--- STEP 1: Vision (Orchestrator does this inline, no delegation)
    |
    +--- STEP 2: TaskCreate(assignee: builder,
    |         task: "Create design-system.css per VISION.md brand direction")
    |         |
    |         +--- Builder works in worktree
    |         |    .claude/worktrees/builder-foundation/
    |         |    - Asks user brand preference questions
    |         |    - Generates design-system.css with HSL tokens
    |         |    - Runs verification loop (WCAG AA contrast)
    |         |    - Commits in worktree
    |         |    - Signals completion via SendMessage
    |         |
    +--- Orchestrator merges builder worktree back to main
    |
    +--- STEP 3: TaskCreate(assignee: stack-scout,
    |         task: "Research tech stack, produce TDR based on VISION.md")
    |         |
    |         +--- Stack Scout works in worktree
    |         |    .claude/worktrees/scout-tdr-001/
    |         |    - WebSearch + Context7 + Chrome DevTools research
    |         |    - Produces TDR document
    |         |    - Commits in worktree
    |         |    - Signals completion via SendMessage
    |         |
    +--- Orchestrator merges scout worktree back to main
    |    Presents TDR to user for approval
    |
    +--- STEPS 4-6: Orchestrator handles inline (roadmap, CLAUDE.md, git)
```

### 1.7 Phase Gate Enforcement

The phase gate is the enforcement mechanism that prevents source code writes before the foundation is complete. It operates as a `PreToolUse` hook on `Write` and `Edit` tools.

```
                   PHASE GATE DECISION TREE

    PreToolUse (Write/Edit) fires
              |
              v
    +---------------------+
    | Read state.json     |
    | foundation.complete |
    +---------+-----------+
              |
     +--------+--------+
     |                  |
  complete         incomplete
     |                  |
     v                  v
   ALLOW       +----------------+
   (exit 0)    | Check file path|
               +--------+-------+
                        |
              +---------+----------+
              |                    |
         Foundation           Source code
         artifact?            path?
         (.vibecrew/,           (src/, app/,
          CLAUDE.md,           lib/, etc.)
          VISION.md,                |
          docs/,                    v
          design-               BLOCK
          system.css)           (exit 2)
              |                    |
              v                    v
           ALLOW            "Phase Gate:
           (exit 0)          Source code
                             writes blocked.
                             Complete
                             foundation
                             first."
```

### 1.8 `/setup` Dependency Check Details

```
    +------------------------------------------------------+
    |              /setup DEPENDENCY CHECK                  |
    +------------------------------------------------------+
    |                                                      |
    |  REQUIRED (blocks setup if missing):                 |
    |    [x] Claude Code >= 2.0.0                          |
    |    [x] Git >= 2.30                                   |
    |    [x] GitHub CLI >= 2.0 (authenticated)             |
    |                                                      |
    |  RECOMMENDED (warns but continues):                  |
    |    [ ] Node.js >= 18                                 |
    |    [ ] terminal-notifier (macOS notifications)       |
    |    [ ] jq (JSON parsing in hooks)                    |
    |                                                      |
    |  OPTIONAL (informational):                           |
    |    [ ] MCP servers (10 total, 3 enabled by default)    |
    |    [ ] Warp terminal (for deep-link notifications)   |
    |                                                      |
    +------------------------------------------------------+
```

### 1.9 Error Handling

| Failure | When | Recovery |
|---------|------|----------|
| Missing required dependency | `/setup` | Block setup, display install command |
| User abandons `/new-project` mid-step | Any step | State persists partial progress; next `/new-project` resumes from last incomplete artifact |
| Stack Scout research fails (no internet) | Step 3 | Offer manual TDR creation; user provides stack preferences directly |
| Builder worktree creation fails | Step 2 | Fall back to inline execution without worktree isolation |
| Worktree merge conflict | After Steps 2 or 3 | Orchestrator reports conflict; user resolves manually then re-runs |
| Git init fails | Step 6 | Report error; user can manually init and re-run `/new-project` |

---

## 2. Workflow 2: Existing Project Onboarding (Deferred to v1.1)

Existing project onboarding -- adapting VibeCrew to a project that already has source code, dependencies, and possibly tests -- is **deferred to v1.1**. This workflow requires infrastructure not yet built in v1.0:

- **Codebase audit agent** (reverse-engineer TDR from existing dependencies, detect test frameworks, extract design tokens from CSS)
- **Pattern extraction** (analyze file structure conventions, naming patterns, import styles to generate CLAUDE.md)
- **Test coverage gap analysis** (identify untested modules, prioritize by risk)

For v1.0, users with existing projects should manually:

1. Run `/setup` to scaffold `.vibecrew/`
2. Run `/new-project` and answer the foundation questions (the TDR step can document the existing stack rather than choosing a new one)
3. Proceed with the standard foundation workflow

The v1.1 onboarding workflow will automate this process with dedicated audit phases and the Verifier agent handling code quality assessment of the existing codebase.

---

## 3. Workflow 3: Feature Lifecycle

### 3.1 Overview

The feature lifecycle is the iterative Tier 2 workflow. A feature progresses through 7 Kanban columns (`idea` through `done`) and 6 execution phases (`plan`, `design`, `code`, `test`, `review`, `docs`). Four agents participate: Builder (design + code), Verifier (test), Code Reviewer (review), and the Workflow Orchestrator (plan + coordination). Handoffs are mediated by the Agent Teams API.

**Key design resolution.** Phases are **sequential by default** but can be **re-entered** via verify-fix loops and review-fix cycles. If the Verifier finds bugs during testing, it sends the feature back to `in-progress` for the Builder to fix. If the Code Reviewer issues a `request-changes` verdict with critical findings, the Orchestrator routes findings back to the Builder for a structured fix cycle (max 2 cycles). If the Builder hits a blocking error (`builder-blocked.signal`), the Orchestrator attempts auto-recovery via the CI Healer agent before escalating to the developer. The column progression is:

```
idea -> planning -> planned -> in-progress -> testing -> review -> done
                                    ^            |          |
                                    |            |          |
                                    +-- fix -----+          |
                                    (verify-fix loop)       |
                                    ^                       |
                                    |                       |
                                    +-- review-fix cycle ---+
                                    (max 2 cycles)
```

### 3.2 Feature State Machine

```
                        FEATURE STATE MACHINE

    /idea "text"                              /plan-features
   +----------+    Orchestrator refines     +--------------+
   |          |    specs, sets acceptance   |              |
   |   IDEA   |--------------------------->|  PLANNING    |
   |          |    criteria                |  (actively   |
   +----------+                            |  planning)   |
                                           +------+-------+
                                                  |
                                    Spec populated?
                                    Acceptance criteria set?
                                                  |
                                           Yes    |
                                                  v
                                          +--------------+
                                          |              |
                                          |   PLANNED    |
                                          |  (spec done, |
                                          |  ready to    |
                                          |  build)      |
                                          +------+-------+
                                                 |
                              /new-feature "name" or /run-backlog
                              Builder claims task
                              Worktree created
                                                 |
                                                 v
                                         +---------------+
                                         |               |
                                    +--->| IN-PROGRESS   |
                                    |    |               |
                                    |    | Phases:       |
                                    |    |  plan -> done |
                                    |    |  design->done |
                                    |    |  code -> done |
                                    |    +-------+-------+
                                    |            |
                                    |  Code phase complete
                                    |  Verifier takes over
                                    |            |
                                    |            v
                                    |    +--------------+
                                    |    |              |
                                    +----+   TESTING    |
                                  verify |              |
                                  -fix   | test -> done |
                                  loop   +------+-------+
                                                |
                              Tests pass
                              Builder creates PR
                                                |
                                                v
                                         +--------------+
                                         |              |
                                         |    REVIEW    |
                                         |              |
                                         | PR open on   |
                                         | GitHub       |
                                         +------+-------+
                                                |
                              User merges PR
                              /wrap finalizes session
                                                |
                                                v
                                         +--------------+
                                         |              |
                                         |     DONE     |
                                         |              |
                                         | (terminal    |
                                         |  state)      |
                                         +--------------+
```

### 3.3 Feature Phase Detail

Phases within `in-progress` are **sequential by default** with verify-fix loops that allow re-entry:

```
    +----------------------------------------------------------+
    |         FEATURE PHASES (sequential with re-entry)        |
    +----------------------------------------------------------+
    |                                                          |
    |   plan --> design --> code --> test                       |
    |                        ^        |                        |
    |                        |        |                        |
    |                        +--------+                        |
    |                       verify-fix loop                    |
    |                                                          |
    |  Default progression:                                    |
    |    plan -> design -> code -> test -> (review)            |
    |                                                          |
    |  Verify-fix loop:                                        |
    |    If Verifier finds bugs during test phase,             |
    |    feature returns to in-progress for Builder to fix.    |
    |    Builder fixes the bugs, then re-enters testing.       |
    |    Loop continues until Verifier passes all tests.       |
    |                                                          |
    |  Phase tracking:                                         |
    |    phases_completed[] records completed phases.           |
    |    A phase can be re-entered -- it stays in the array    |
    |    and the re-entry is logged in the session log.        |
    |                                                          |
    +----------------------------------------------------------+
```

### 3.4 Step-by-Step: `/idea "text"`

```
    +------------------------------------------------------+
    |                  /idea "text" FLOW                    |
    +------------------------------------------------------+
    |                                                      |
    |  1. Parse idea text from command argument.           |
    |  2. Acquire lock on backlog.json (via Bash script).  |
    |  3. Generate unique feature ID (feat-NNN).           |
    |  4. Append to backlog.json features array.           |
    |     (See architecture/schemas.md Section 4 for       |
    |      the feature object schema.)                     |
    |  5. Release lock on backlog.json.                    |
    |  6. Output: "Idea captured. Continuing current task."|
    |                                                      |
    |  Total tokens consumed: ~20 output tokens.           |
    |  Zero disruption to current workflow.                |
    |                                                      |
    +------------------------------------------------------+
```

### 3.5 Step-by-Step: `/plan-features`

```
    +------------------------------------------------------+
    |               /plan-features FLOW                    |
    +------------------------------------------------------+
    |                                                      |
    |  1. Read backlog.json.                               |
    |  2. Read docs/roadmap.md.                            |
    |                                                      |
    |  3. Surface unprocessed ideas (column: "idea"):      |
    |     "You have N unprocessed ideas:                   |
    |      1. <idea text>                                  |
    |      2. <idea text>                                  |
    |      Promote any to planned features?"               |
    |                                                      |
    |  4. For each feature being planned:                  |
    |     a. Orchestrator refines description              |
    |     b. AskUserQuestion for acceptance criteria       |
    |     c. Set priority (user input or auto from roadmap)|
    |     d. Estimate complexity (S/M/L/XL)                |
    |     e. Identify dependencies                         |
    |                                                      |
    |  5. Update backlog.json via Bash scripts:            |
    |     - Promoted ideas: column "idea" -> "planned"     |
    |     - Refined features: column "idea" -> "planning"   |
    |     - Spec complete: column "planning" -> "planned"  |
    |       (if deps met and criteria set)                 |
    |                                                      |
    |  6. Display backlog summary:                         |
    |     "Backlog: 2 planned, 3 planning, 1 idea"        |
    |                                                      |
    +------------------------------------------------------+
```

### 3.6 Step-by-Step: `/new-feature "name"`

```
USER                 ORCHESTRATOR              AGENTS (via Agent Teams)
 |                       |                               |
 |  /new-feature         |                               |
 |  "user auth"          |                               |
 |---------------------->|                               |
 |                       |                               |
 |                       |  1. FOUNDATION CHECK          |
 |                       |  Read state.json              |
 |                       |  foundation.complete == true?  |
 |                       |  +-- No: "Run /new-project    |
 |                       |  |       first."              |
 |                       |  +-- Yes: continue            |
 |                       |                               |
 |                       |  2. ACTIVE FEATURE CHECK      |
 |                       |  Is there an active feature?  |
 |                       |  +-- Yes: "Wrap current first"|
 |                       |  +-- No: continue             |
 |                       |                               |
 |                       |  3. FIND OR CREATE SPEC       |
 |                       |  Search backlog.json for      |
 |                       |  matching feature name        |
 |                       |  +-- Found (column: planned):  |
 |                       |  |   Load spec + criteria     |
 |                       |  +-- Not found:               |
 |                       |      Quick plan via           |
 |                       |      AskUserQuestion          |
 |                       |      Add to backlog.json      |
 |                       |                               |
 |                       |  4. DEPENDENCY CHECK          |
 |                       |  check-dependencies.sh        |
 |                       |  All deps in "done" column?   |
 |                       |  +-- No: "Blocked by <dep>."  |
 |                       |  +-- Yes: continue            |
 |                       |                               |
 |                       |  5. WIP LIMIT CHECK           |
 |                       |  Is in-progress WIP limit     |
 |                       |  (1) already reached?         |
 |                       |  +-- Yes: "Wrap current first"|
 |                       |  +-- No: continue             |
 |                       |                               |
 |                       |  6. CLAIM TASK                |
 |                       |  claim-task.sh                |
 |                       |  Update backlog.json:         |
 |                       |    column: "in-progress"      |
 |                       |                               |
 |                       |  7. UPDATE STATE              |
 |                       |  state.json:                  |
 |                       |    active_feature.id = feat-003
 |                       |    active_feature.phase = plan|
 |                       |                               |
 |                       |  8. CREATE TEAM + ASSIGN      |
 |                       |  TeamCreate("feat-003-auth",  |
 |                       |    [builder, verifier])       |
 |                       |  TaskCreate -> Builder        |
 |                       |    "Design and implement      |
 |                       |     user-authentication"      |
 |                       |------------------------------->|
 |                       |                               |
 |                       |     Builder gets worktree:    |
 |                       |     .claude/worktrees/        |
 |                       |       builder-feat-003/       |
 |                       |                               |
 |  <-- "Feature session |  Builder begins work.         |
 |       started"        |                               |
```

### 3.7 Feature Development: Agent Teams Handoff Sequence

During feature development, the Orchestrator coordinates agents via the Agent Teams API. The developer no longer manually opens tabs.

```
Orchestrator
    |
    +--- TeamCreate("feat-003-user-auth", [builder, verifier])
    |
    |   PHASE: PLAN (Orchestrator, inline)
    +--- Orchestrator writes feature spec to backlog.json
    |    via Bash scripts (acceptance criteria, UI description,
    |    business logic, technical notes)
    |
    |   PHASE: DESIGN + CODE (Builder, worktree)
    +--- TaskCreate(assignee: builder,
    |        task: "Design and implement feat-003 per spec",
    |        context: { feature_id: "feat-003",
    |                   phases: ["design", "code"] })
    |         |
    |         +--- Builder creates worktree:
    |         |    .claude/worktrees/builder-feat-003/
    |         |
    |         +--- DESIGN: Component specs, CSS tokens
    |         +--- CODE: Implementation per spec + TDR
    |         +--- Verify loop: build + lint pass
    |         +--- Conventional commits in worktree
    |         +--- SendMessage(to: orchestrator,
    |         |      "Builder complete for feat-003")
    |         +--- Signal: builder-complete.signal
    |
    +--- Orchestrator receives completion
    |    Merges builder worktree back to feature branch
    |    Advances column: in-progress (code done)
    |
    |   PHASE: TEST (Verifier, inline)
    +--- TaskCreate(assignee: verifier,
    |        task: "Test feat-003",
    |        context: { feature_id: "feat-003",
    |                   phases: ["test"] })
    |         |
    |         +--- Verifier reads source from merged code
    |         +--- Writes tests (spec-first for business logic,
    |         |    impl-first for UI components)
    |         +--- Runs test suite
    |         +--- Verify loop: all tests pass
    |         |
    |         +--- TESTS PASS?
    |              |
    |         +----+----+
    |         |         |
    |        YES        NO (bugs found)
    |         |         |
    |         |         +--- SendMessage(to: orchestrator,
    |         |         |      "Verify-fix: bugs in feat-003")
    |         |         +--- Signal: verifier-bugs.signal
    |         |         |    (includes failing tests + details)
    |         |         |
    |         |         +--- Orchestrator re-assigns Builder:
    |         |              TaskCreate(assignee: builder,
    |         |                task: "Fix bugs in feat-003",
    |         |                context: { bug_report: "..." })
    |         |              Builder fixes -> re-test -> loop
    |         |
    |         +--- SendMessage(to: orchestrator,
    |              "Verifier complete for feat-003")
    |         +--- Signal: verifier-test-complete.signal
    |
    +--- Orchestrator advances column: testing -> review
    |
    |   PHASE: REVIEW (Builder creates PR)
    +--- TaskCreate(assignee: builder,
    |        task: "Create PR for feat-003")
    |         |
    |         +--- Builder: gh pr create --title "..." --body "..."
    |         +--- Signal: builder-pr-created.signal
    |
    +--- SendMessage(to: developer,
         "feat-003 ready for review. PR: <url>")
```

### 3.8 Verify-Fix Loop Detail

The verify-fix loop is the mechanism that resolves the sequential-vs-flexible contradiction. Phases progress sequentially, but the testing phase can send features back for fixes.

```
    VERIFY-FIX LOOP
    ================

    Builder completes code phase
              |
              v
    [If frontend files changed]
    Builder runs visual verification:
    - Starts dev server (ports 3000-3010)
    - Playwright: navigate, console check,
      screenshot at 1440px
    - Optional: visual-verify.sh + browser_evaluate
      for computed style extraction
    - Fix console errors and token violations
    - Max 2 visual-fix iterations
    - Record results in builder-complete.signal
      visual_verification payload
    - If Playwright unavailable: skip, log reason
              |
              v
    Orchestrator advances to testing
              |
              v
    Verifier runs tests
              |
         +----+----+
         |         |
    ALL PASS    FAILURES
         |         |
         v         v
    Advance    Verifier creates bug report:
    to review  - Failing test names
               - Expected vs actual behavior
               - Relevant source file paths
                    |
                    v
               Orchestrator sends feature
               back to in-progress:
               - Column stays "in-progress"
               - state.json phase = "code"
               - TaskCreate -> Builder with
                 bug report as context
                    |
                    v
               Builder fixes bugs in worktree
               - Reads bug report
               - Fixes source code
               - Runs build + lint verify loop
               - Commits fixes
               - Signals completion
                    |
                    v
               Orchestrator re-advances to testing
               Verifier re-runs tests
                    |
                    v
               (Loop repeats until all tests pass)

    SAFETY LIMIT: Max 3 verify-fix iterations per feature.
    After 3 failed loops, Orchestrator notifies the developer
    and pauses the feature for manual intervention.

    REVIEW-FIX CYCLE (after tests pass):
    Code Reviewer produces review report with verdict.
    If frontend files in scope, Code Reviewer also runs
    visual design compliance (Step 6.5):
      - Playwright: screenshots at 3 viewports (1440/768/375px)
      - visual-verify.sh + browser_evaluate for token comparison
      - Console error check (critical findings)
      - Results reported as "visual-compliance" category findings
      - Skipped if Playwright unavailable (noted in summary)
    If verdict is request-changes with critical findings:
      1. Orchestrator extracts critical findings
      2. Writes builder-review-feedback.json
      3. Builder fixes each critical finding
      4. Builder re-runs build verify
      5. Code Reviewer re-reviews changed files
      6. Max 2 review-fix cycles. After 2 cycles,
         feature marked as blocked.

    AUTO-RECOVERY (on builder-blocked signal):
    Before escalating to the developer:
      1. Orchestrator reads error details from signal
      2. Runs npm install (if missing modules suspected)
      3. Invokes CI Healer agent for diagnosis
      4. If CI Healer succeeds, resumes Builder
      5. If CI Healer fails, escalates to developer
```

### 3.9 `/run-backlog` Automation Loop

```
    +----------------------------------------------------------+
    |                /run-backlog AUTOMATION LOOP               |
    +----------------------------------------------------------+
    |                                                          |
    |  START                                                   |
    |    |                                                     |
    |    v                                                     |
    |  +----------------------+                                |
    |  | Read backlog.json    |                                |
    |  | Find next "planned"  |                                |
    |  | task (priority order,|                                |
    |  | deps satisfied)      |                                |
    |  +----------+-----------+                                |
    |             |                                            |
    |    +--------+--------+                                   |
    |    |                 |                                   |
    |  No tasks          Found task                            |
    |    |                 |                                   |
    |    v                 v                                   |
    |  EXIT with      +------------------+                    |
    |  summary        | Claim task       |                    |
    |                 | Create team      |                    |
    |                 | Set in-progress  |                    |
    |                 +--------+---------+                    |
    |                          |                              |
    |                          v                              |
    |                 +------------------+                    |
    |                 | Execute phases   |                    |
    |                 | via Agent Teams: |                    |
    |                 |  Plan (inline)   |                    |
    |                 |  Design (Builder)|                    |
    |                 |  Code (Builder)  |                    |
    |                 |  Test (Verifier) |                    |
    |                 |  Review (Code    |                    |
    |                 |   Reviewer)      |                    |
    |                 |  Docs            |                    |
    |                 |  (with verify-   |                    |
    |                 |   fix loops,     |                    |
    |                 |   review-fix     |                    |
    |                 |   cycles max 2x, |                    |
    |                 |   auto-recovery  |                    |
    |                 |   via CI Healer) |                    |
    |                 +--------+---------+                    |
    |                          |                              |
    |                          v                              |
    |                 +------------------+                    |
    |                 | QUALITY GATE     |                    |
    |                 |  (Verifier +     |                    |
    |                 |   Stop hook)     |                    |
    |                 |  npm test        |                    |
    |                 |  npm run build   |                    |
    |                 |  npm run lint    |                    |
    |                 +--------+---------+                    |
    |                          |                              |
    |                 +--------+--------+                     |
    |                 |                 |                     |
    |               PASS             FAIL                     |
    |                 |                 |                     |
    |                 v                 v                     |
    |           +-----------+   +--------------+             |
    |           | Create PR |   | STOP.        |             |
    |           | Mark done |   | Notify user  |             |
    |           +-----------+   | with failure |             |
    |                 |         | details.     |             |
    |                 v         +--------------+             |
    |           +-----------------+                          |
    |           | CONTEXT HYGIENE |                          |
    |           | (inter-feature  |                          |
    |           |  compaction)    |                          |
    |           |                 |                          |
    |           | If last feature:|                          |
    |           |   Skip, go to  |                          |
    |           |   completion   |                          |
    |           |   summary      |                          |
    |           | Else:          |                          |
    |           |   /compact     |                          |
    |           |   compact-     |                          |
    |           |   reinject.sh  |                          |
    |           |   re-injects   |                          |
    |           |   state +      |                          |
    |           |   architecture |                          |
    |           |   diagrams     |                          |
    |           +---------+-------+                          |
    |                     |                                  |
    |                     v                                  |
    |               Loop back                                |
    |               to START                                 |
    |                                                        |
    |  CONTEXT CHECK: After each feature, check context %.   |
    |  If > 60%: warn user, suggest wrapping.                |
    |  If > 80%: force wrap, new session for remaining tasks.|
    |                                                        |
    +----------------------------------------------------------+
```

### 3.10 Feature Status Transitions (Complete Reference)

| From | To | Trigger | Agent | Condition |
|------|----|---------|-------|-----------|
| -- | `idea` | `/idea "text"` | Orchestrator | None |
| `idea` | `planning` | `/plan-features` or user drags in dashboard | Orchestrator | User initiates planning |
| `planning` | `planned` | `/plan-features` | Orchestrator | Acceptance criteria set, dependencies identified |
| `planned` | `in-progress` | `/new-feature` or `/run-backlog` | Orchestrator (delegates to Builder) | All dependencies in `done` column, WIP limit not reached |
| `in-progress` | `testing` | Code phase complete | Builder signals Orchestrator | Builder verify loop passes (build + lint); signal includes `changed_files` |
| `testing` | `in-progress` | Verify-fix loop | Verifier signals Orchestrator | Tests fail, bugs need fixing (max 3 loops) |
| `testing` | `review` | Tests pass | Verifier signals Orchestrator | All tests pass; Code Reviewer invoked |
| `review` | `in-progress` | Review-fix cycle | Code Reviewer verdict `request-changes` | Critical findings routed to Builder via `builder-review-feedback.json` (max 2 cycles) |
| `review` | `done` | Review approved + user merges PR + `/wrap` | Code Reviewer approves, Builder creates PR, Verifier wraps | PR merged, Vibe Score calculated |
| `in-progress` | `blocked` | Builder blocked + auto-recovery fails | Orchestrator (via CI Healer) | CI Healer attempted, escalated to developer |

See `architecture/schemas.md` Section 4 for the canonical `backlog.json` schema and Kanban column definitions.

---

## 4. Workflow 4: Session Lifecycle

### 4.1 Overview

Every Claude Code session running under VibeCrew follows a predictable lifecycle: startup (environment check and routing), work phase (hook-enforced execution), and shutdown (quality check, scoring, and cleanup). The lifecycle applies to the Orchestrator session and to all agent sub-sessions spawned via Agent Teams.

### 4.2 End-to-End Session Flow

```
    +----------------------------------------------------------+
    |                SESSION LIFECYCLE                          |
    +----------------------------------------------------------+
    |                                                          |
    |  ========= PHASE 1: STARTUP =========                   |
    |                                                          |
    |  User opens terminal                                     |
    |  User runs: claude                                       |
    |       |                                                  |
    |       v                                                  |
    |  SessionStart hook fires                                 |
    |  Session Startup agent (Haiku):                          |
    |       |                                                  |
    |       +-- 1. Environment check                           |
    |       |     Git status validation                        |
    |       |     (clean tree? right branch? conflicts?)       |
    |       |                                                  |
    |       +-- 2. State file migration check                  |
    |       |     Run migrate-state.sh if schema_version       |
    |       |     is outdated                                  |
    |       |                                                  |
    |       +-- 3. Stale session detection                     |
    |       |     Check .vibecrew/sessions/ for crashed sessions |
    |       |     Remove entries for dead processes             |
    |       |                                                  |
    |       +-- 4. Stale lock cleanup                          |
    |       |     Sweep .vibecrew/locks/                         |
    |       |     Remove expired locks (>30s timeout)          |
    |       |                                                  |
    |       +-- 5. Signal processing                           |
    |       |     Check .vibecrew/signals/ for pending signals   |
    |       |     Report pending handoffs                      |
    |       |                                                  |
    |       +-- 6. Load user profile                            |
    |       |     Run scripts/read-profile.sh                    |
    |       |     Adapt greeting verbosity from profile          |
    |       |                                                  |
    |       +-- 7. State detection + routing                   |
    |       |     Read .vibecrew/state.json                      |
    |       |                                                  |
    |       |     +-------------------------------------+      |
    |       |     | No .vibecrew/?                        |      |
    |       |     | -> "Run /setup"                     |      |
    |       |     |                                     |      |
    |       |     | Foundation incomplete?              |      |
    |       |     | -> "Run /new-project"               |      |
    |       |     |                                     |      |
    |       |     | Active feature in-progress?         |      |
    |       |     | -> "Continue feat/user-auth.        |      |
    |       |     |    Phase: code"                     |      |
    |       |     |                                     |      |
    |       |     | No active feature?                  |      |
    |       |     | -> "Ready. N features in backlog.   |      |
    |       |     |    Run /new-feature or /status."    |      |
    |       |     +-------------------------------------+      |
    |       |                                                  |
    |       +-- 8. Output routing decision                     |
    |             3-line status injected into context           |
    |                                                          |
    |  ========= PHASE 2: WORK =========                      |
    |                                                          |
    |  Agent performs specialized task                          |
    |       |                                                  |
    |       +-- Every Write/Edit:                              |
    |       |     PreToolUse -> phase-gate.sh                  |
    |       |     PostToolUse -> format-code.sh                |
    |       |                                                  |
    |       +-- Every Bash command:                            |
    |       |     PreToolUse -> protect-data.sh                |
    |       |                                                  |
    |       +-- Permission needed:                             |
    |       |     Notification hook -> notify.sh               |
    |       |     (fires OS notification with deep-link)       |
    |       |                                                  |
    |       +-- Tool execution fails:                          |
    |       |     PostToolUseFailure -> notify.sh              |
    |       |     (fires error notification)                   |
    |       |                                                  |
    |       +-- After each turn (Stop hook pipeline):            |
    |       |     check-context.sh   -> context warnings       |
    |       |     cost-guardrails.sh -> cost tracking           |
    |       |     claude-md-lint.sh  -> CLAUDE.md validation    |
    |       |     quality-gate.sh    -> typecheck/lint/build    |
    |       |       (blocks on failure; agent fixes errors)     |
    |       |     60%: "Consider wrapping up."                 |
    |       |     80%: "Wrap now." + OS notification           |
    |       |                                                  |
    |       +-- Agent commits work atomically:                 |
    |             feat(auth): add login form component         |
    |             feat(auth): add OAuth2 flow                  |
    |                                                          |
    |  ========= PHASE 3: SHUTDOWN =========                  |
    |                                                          |
    |  Triggered by: /wrap, context >= 80%, or Ctrl+D         |
    |       |                                                  |
    |       v                                                  |
    |  STEP 1: Completeness check                              |
    |    Show which phases have artifacts:                     |
    |    [x] Plan  [x] Design  [x] Code  [ ] Test             |
    |    Offer to complete missing phases now.                 |
    |                                                          |
    |       |                                                  |
    |       v                                                  |
    |  STEP 2: Quality check (Verifier)                        |
    |    npm test  -> PASS/FAIL                                |
    |    npm run build -> PASS/FAIL                            |
    |    npm run lint  -> PASS/FAIL                            |
    |                                                          |
    |       |                                                  |
    |       v                                                  |
    |  STEP 3: Vibe Score calculation (Verifier)               |
    |    a. Calculate Vibe Score (0-100)                        |
    |    b. Present score + top observation                     |
    |    c. Write score to .vibecrew/scores/                      |
    |    d. Provide coaching suggestions                        |
    |    (See architecture/scoring.md for methodology)          |
    |    (See architecture/schemas.md Section 6 for schema)    |
    |                                                          |
    |       |                                                  |
    |       v                                                  |
    |  STEP 4: Session log                                     |
    |    Verifier writes to .vibecrew/sessions/<id>.json         |
    |    (See architecture/schemas.md Section 5 for schema)    |
    |                                                          |
    |       |                                                  |
    |       v                                                  |
    |  STEP 5: Git commit                                      |
    |    Feature complete?                                     |
    |    -> feat(auth): user authentication with OAuth2        |
    |    Feature in progress?                                  |
    |    -> wip(auth): plan + design + code done               |
    |                                                          |
    |       |                                                  |
    |       v                                                  |
    |  STEP 6: Optional PR creation                            |
    |    Feature complete + all tests pass?                    |
    |    -> "Create a PR? (y/n)"                               |
    |    -> gh pr create --title "..." --body "..."            |
    |                                                          |
    |       |                                                  |
    |       v                                                  |
    |  STEP 7: Cleanup                                         |
    |    Release any held locks                                |
    |    Remove processed signal files                         |
    |    Clean up agent worktrees (if any remain)              |
    |                                                          |
    |  SESSION ENDS                                            |
    |                                                          |
    +----------------------------------------------------------+
```

### 4.3 Context Re-Injection After Compaction

When Claude Code compacts the context window (automatic or manual), the session loses accumulated state. The Session Startup agent's routing output is designed to be re-injectable:

```
    CONTEXT COMPACTION RECOVERY
    ===========================

    Context window fills up
              |
              v
    Claude Code compacts context
    (removes old turns, keeps system prompt)
              |
              v
    Post-compaction, the following state is preserved:
    1. CLAUDE.md (always in system prompt)
    2. .vibecrew/state.json (on disk, re-readable)
    3. .vibecrew/backlog.json (on disk, re-readable)
    4. Git branch + commit history (on disk)
    5. Agent worktree contents (on disk)

    What is lost:
    1. Previous conversation turns
    2. In-memory reasoning about the feature
    3. Tool output from earlier in the session

    Recovery mechanism:
    1. Agent re-reads state.json and backlog.json
    2. Agent reads current feature spec from backlog.json
    3. Agent reads recent git log for commit history
    4. Agent reads existing source files in worktree
    5. Agent resumes work from the last committed state

    This is why frequent atomic commits are critical --
    they checkpoint progress to disk so compaction
    does not lose meaningful work.

    INTER-FEATURE COMPACTION (/run-backlog)
    ========================================
    During /run-backlog, compaction is triggered deliberately
    between features (not just reactively when context fills).
    After a feature passes its quality gate and state is cleared,
    the Orchestrator triggers /compact to compress conversation
    history. The compact-reinject.sh script then re-injects
    project state + architecture diagrams so the next feature
    starts with a clean context window. The last feature in the
    backlog skips compaction and goes straight to the completion
    summary. This prevents "context rot" -- the gradual
    accumulation of stale reasoning from previous features that
    degrades output quality on later features.
```

### 4.4 Session State Machine

```
              SESSION STATE MACHINE

  +--------------+
  |   LAUNCHED   |  (claude command executed)
  +------+-------+
         | SessionStart hook fires
         v
  +--------------+
  | INITIALIZING |  (env check, state load, routing)
  +------+-------+
         | Startup complete
         v
  +--------------+
  |    ACTIVE    |  (work phase -- hooks enforcing rules)
  |              |
  |  Sub-states: |
  |   working    |<--- normal operation
  |   blocked    |<--- waiting for permission (notification sent)
  |   idle       |<--- task complete, waiting for input
  +------+-------+
         | /wrap or context >= 80% or Ctrl+D
         v
  +--------------+
  |  WRAPPING    |  (quality check, Vibe Score, commit)
  +------+-------+
         | All wrap steps complete
         v
  +--------------+
  |  TERMINATED  |  (session log written, state cleaned up)
  +--------------+

  ABNORMAL EXIT (crash, Ctrl+C without /wrap):
  +--------------+
  |   CRASHED    |  (detected by next session's startup)
  |              |  (stale session entry cleaned up)
  |              |  (uncommitted work in worktree)
  +--------------+
```

### 4.5 Notification Trigger Conditions

The Interrupt Protocol fires notifications on exactly three conditions. All other operations stay silent.

```
    +----------------------------------------------------------+
    |           INTERRUPT PROTOCOL TRIGGER CONDITIONS           |
    +----------------------------------------------------------+
    |                                                          |
    |  CONDITION 1: Permission Stall                           |
    |  ----------------------------                            |
    |  Hook: Notification                                      |
    |  Trigger: Claude Code hits a permission prompt           |
    |           (Y/N approval gate)                            |
    |  Notification:                                           |
    |    Title: "VibeCrew: Approval Needed"                      |
    |    Body:  "Agent needs Y/N -- <action description>"      |
    |    Sound: Default                                        |
    |    Action: Deep-link to Warp tab (if Warp)               |
    |                                                          |
    |  CONDITION 2: Task Complete                              |
    |  -------------------------                               |
    |  Hook: Notification                                      |
    |  Trigger: Agent reaches idle state after completing      |
    |           a task (no more autonomous work to do)         |
    |  Notification:                                           |
    |    Title: "VibeCrew: Task Complete"                        |
    |    Body:  "<agent-type> finished <task-description>"     |
    |    Sound: Glass                                          |
    |    Action: Deep-link to Warp tab (if Warp)               |
    |                                                          |
    |  CONDITION 3: Critical Failure                           |
    |  ----------------------------                            |
    |  Hook: PostToolUseFailure                                |
    |  Trigger: A tool execution fails with a fatal error      |
    |  Notification:                                           |
    |    Title: "VibeCrew: Error"                                |
    |    Body:  "<tool-name> failed: <error-summary>"          |
    |    Sound: Basso                                          |
    |    Action: Deep-link to Warp tab (if Warp)               |
    |                                                          |
    |  ALL OTHER OPERATIONS: SILENT                            |
    |  No notification for: file writes, test runs, git        |
    |  operations, context warnings (inline only), normal      |
    |  tool execution, agent progress, worktree operations.    |
    |                                                          |
    +----------------------------------------------------------+
```

### 4.6 Vibe Score Calculation (at `/wrap`)

The Verifier calculates the Vibe Score during `/wrap`. See `architecture/scoring.md` for the complete methodology and `architecture/schemas.md` Section 6 for the score file schema.

```
    +----------------------------------------------------------+
    |              VIBE SCORE CALCULATION                       |
    +----------------------------------------------------------+
    |                                                          |
    |  START: 100 points                                       |
    |                                                          |
    |  DEDUCTIONS:                                             |
    |  ----------                                              |
    |  Prompt churn (3+ consecutive corrections)    -5 each    |
    |  Tool loops (same call 3+ times)              -10 each   |
    |  Low cache utilization (<30% read tokens)     -15        |
    |  Context violation (work after 80% warning)   -20        |
    |  No tests written for feature with code       -10        |
    |  No feature spec before coding                -5         |
    |  Missing phase (any Tier 2 phase skipped)     -3 each    |
    |                                                          |
    |  BONUSES:                                                |
    |  -------                                                 |
    |  All phases completed                         +5         |
    |  Cache utilization > 70%                      +5         |
    |  Test coverage above 80%                      +3         |
    |  Zero warnings triggered                      +2         |
    |                                                          |
    |  FLOOR: 0 (score cannot go negative)                     |
    |  CEILING: 100 (clamped)                                  |
    |                                                          |
    |  RATINGS:                                                |
    |    90-100  Excellent                                     |
    |    70-89   Good                                          |
    |    50-69   Needs improvement                             |
    |    0-49    Review session                                |
    |                                                          |
    |  NOTE: CLAUDE.md mutation proposals are deferred to v1.1 |
    |  with the standalone Performance Coach agent. In v1.0,   |
    |  the Verifier provides coaching suggestions in the score |
    |  file but does not propose rule mutations.               |
    |                                                          |
    +----------------------------------------------------------+
```

---

## 5. Workflow 5: Parallel Work Coordination

### 5.1 Overview

VibeCrew v1.0 supports parallel work through **worktree-per-agent isolation** and the **Agent Teams API**. The Orchestrator autonomously creates agent teams and assigns tasks -- the developer no longer needs to manually open tabs and paste commands. Multiple features can progress in parallel because each Builder instance works in its own git worktree, preventing filesystem conflicts entirely.

### 5.2 Worktree-Per-Agent Model

Git worktrees are the foundational isolation mechanism. As Boris Cherny describes, worktrees are "the single biggest productivity unlock" for multi-agent systems.

```
    +----------------------------------------------------------+
    |             WORKTREE-PER-AGENT ISOLATION                 |
    +----------------------------------------------------------+
    |                                                          |
    |  MAIN WORKING TREE (project root)                        |
    |  +-- Orchestrator works here (read-only, inline)         |
    |  +-- Verifier works here (tests run against real state)  |
    |  +-- Session Startup works here (inline, read-only)      |
    |                                                          |
    |  WORKTREE: .claude/worktrees/builder-feat-003/           |
    |  +-- Builder instance for feat-003 (user-auth)           |
    |  +-- Isolated filesystem: reads/writes sandboxed         |
    |  +-- Own git branch: feat/user-authentication            |
    |  +-- Commits go to the worktree's branch                 |
    |                                                          |
    |  WORKTREE: .claude/worktrees/builder-feat-004/           |
    |  +-- Builder instance for feat-004 (dashboard)           |
    |  +-- Isolated filesystem: no conflicts with feat-003     |
    |  +-- Own git branch: feat/dashboard                      |
    |                                                          |
    |  WORKTREE: .claude/worktrees/scout-tdr-002/              |
    |  +-- Stack Scout researching auth libraries              |
    |  +-- Read-only research: cannot modify source            |
    |  +-- Produces TDR document only                          |
    |                                                          |
    |  LIFECYCLE:                                              |
    |  1. CREATE   Agent frontmatter `isolation: worktree`     |
    |              triggers worktree creation at               |
    |              .claude/worktrees/<agent>-<task>/            |
    |  2. WORK     Agent reads/writes within the worktree      |
    |  3. COMMIT   Agent makes conventional commits            |
    |  4. MERGE    Orchestrator merges worktree branch back    |
    |  5. CLEANUP  Worktree removed after agent completes      |
    |                                                          |
    +----------------------------------------------------------+
```

### 5.3 Agent Teams Coordination Model

The Orchestrator uses the Agent Teams API to coordinate parallel work autonomously:

```
    +----------------------------------------------------------+
    |             AGENT TEAMS COORDINATION MODEL               |
    +----------------------------------------------------------+
    |                                                          |
    |  The Orchestrator:                                       |
    |                                                          |
    |    DOES:                                                 |
    |    - Create agent teams via TeamCreate                   |
    |    - Assign tasks to agents via TaskCreate               |
    |    - Send coordination messages via SendMessage          |
    |    - Process completion signals from agents              |
    |    - Merge worktree branches back to main/feature branch |
    |    - Manage the backlog and feature state transitions     |
    |    - Fire notifications for developer attention          |
    |                                                          |
    |    DOES NOT:                                             |
    |    - Write or edit source code directly                  |
    |    - Force-kill agent sessions                           |
    |    - Override user decisions                             |
    |    - Bypass the phase gate or safety hooks               |
    |                                                          |
    |  Agent Teams API usage:                                  |
    |                                                          |
    |    // Create a team for parallel feature work            |
    |    TeamCreate({                                          |
    |      name: "parallel-sprint",                            |
    |      members: [builder, builder, verifier, stack-scout]  |
    |    })                                                    |
    |                                                          |
    |    // Assign feat-003 to Builder instance 1              |
    |    TaskCreate({                                          |
    |      team: "parallel-sprint",                            |
    |      assignee: "builder",                                |
    |      description: "Implement feat-003 (user-auth)",      |
    |      context: { feature_id: "feat-003" }                 |
    |    })                                                    |
    |                                                          |
    |    // Assign feat-004 to Builder instance 2              |
    |    TaskCreate({                                          |
    |      team: "parallel-sprint",                            |
    |      assignee: "builder",                                |
    |      description: "Implement feat-004 (dashboard)",      |
    |      context: { feature_id: "feat-004" }                 |
    |    })                                                    |
    |                                                          |
    |    // After Builder 1 completes, assign Verifier         |
    |    SendMessage({                                         |
    |      team: "parallel-sprint",                            |
    |      to: "verifier",                                     |
    |      message: "Builder completed feat-003. Test it."     |
    |    })                                                    |
    |                                                          |
    +----------------------------------------------------------+
```

### 5.4 Parallel Workflow: Feature Pipeline

The most common parallel scenario is a pipeline where one feature is being tested while the next is being coded:

```
    TIME ---------------------------------------------------->

    Orchestrator (inline, main working tree):
    +-----------------------------------------------------+
    | /status | plan feat-004 | merge wktree | /status |...|
    +-----------------------------------------------------+

    Builder 1 (worktree: builder-feat-003):
    +-----------------------------------------------------+
    |    feat-003 (DESIGN + CODE)    | (worktree cleaned)  |
    |  commit  commit  commit        |                     |
    +-----------------------------------------------------+

    Builder 2 (worktree: builder-feat-004):
    +-----------------------------------------------------+
    | idle |     feat-004 (DESIGN + CODE)    | ...         |
    +-----------------------------------------------------+

    Verifier (inline, main working tree):
    +-----------------------------------------------------+
    | idle | idle |  feat-003 (TEST)  | feat-004 (TEST) |..|
    +-----------------------------------------------------+

    Stack Scout (worktree: scout-tdr-002):
    +-----------------------------------------------------+
    | idle | research payment APIs | (worktree cleaned) |..|
    +-----------------------------------------------------+

    GIT BRANCHES + WORKTREES:

    main:           --*----------*----------*---------->
                       \        / \        /
    feat/user-auth:     *--*--*    (merged)
    (builder-feat-003   worktree)

    feat/dashboard:               *--*--*--*--*
    (builder-feat-004              worktree)
```

### 5.5 Worktree Branch Naming

Feature branches are named after features, not agents. The worktree path identifies the agent, while the branch identifies the feature:

```
    +----------------------------------------------------------+
    |      WORKTREE + BRANCH NAMING CONVENTIONS                |
    +----------------------------------------------------------+
    |                                                          |
    |  WORKTREE PATH: .claude/worktrees/<agent>-<task>/        |
    |  BRANCH NAME:   <type>/<feature-slug>                    |
    |                                                          |
    |  Examples:                                               |
    |                                                          |
    |    Worktree: .claude/worktrees/builder-feat-003/          |
    |    Branch:   feat/user-authentication                    |
    |    Purpose:  Builder implementing user-auth feature      |
    |                                                          |
    |    Worktree: .claude/worktrees/scout-tdr-002/             |
    |    Branch:   research/payment-api-tdr                    |
    |    Purpose:  Stack Scout researching payment APIs        |
    |                                                          |
    |    Worktree: .claude/worktrees/builder-foundation/        |
    |    Branch:   main (Tier 1 foundation work)               |
    |    Purpose:  Builder creating design-system.css          |
    |                                                          |
    |  RULE: One branch per feature. Multiple agents may work  |
    |  on the same branch sequentially (Builder codes, then    |
    |  Verifier tests -- same branch, different worktrees or   |
    |  inline). The branch tracks the feature, not the agent.  |
    |                                                          |
    +----------------------------------------------------------+
```

### 5.6 File-Level Advisory Locks

When two agents must modify the same `.vibecrew/` state file concurrently, VibeCrew uses `mkdir`-based atomic locks. See `architecture/schemas.md` Section 8 for the lock file schema.

```
    +----------------------------------------------------------+
    |           FILE-LEVEL ADVISORY LOCK FLOW                  |
    +----------------------------------------------------------+
    |                                                          |
    |  Agent A wants to write to backlog.json:                 |
    |                                                          |
    |  1. mkdir .vibecrew/locks/backlog-json/                    |
    |     POSIX-atomic: succeeds or fails, no race             |
    |                                                          |
    |  2. Success? Write lock metadata:                        |
    |     .vibecrew/locks/backlog-json/info.json                 |
    |     (See architecture/schemas.md Section 8)              |
    |                                                          |
    |  3. Perform the write operation.                         |
    |                                                          |
    |  4. rm -rf .vibecrew/locks/backlog-json/                   |
    |     Lock released.                                       |
    |                                                          |
    |  Agent B tries concurrently:                             |
    |                                                          |
    |  1. mkdir .vibecrew/locks/backlog-json/                    |
    |     FAILS (directory already exists)                     |
    |                                                          |
    |  2. Check lock metadata:                                 |
    |     - Is PID alive? (kill -0 $PID)                       |
    |     - Is lock > timeout_seconds old?                     |
    |     - If stale: remove and retry                         |
    |     - If valid: wait 1s, retry (up to 30s timeout)       |
    |                                                          |
    |  3. Lock acquired after Agent A releases.                |
    |                                                          |
    |  SAFETY: Scripts use trap 'rm -rf "$LOCK"' EXIT          |
    |  to release locks on unexpected termination.             |
    |                                                          |
    +----------------------------------------------------------+
```

### 5.7 Signal Files as Persistence Layer

Signal files (`.vibecrew/signals/`) complement the Agent Teams API by providing a persistence layer that survives agent crashes. The primary coordination mechanism is Agent Teams (`SendMessage`), but signal files serve as durable receipts.

See `architecture/schemas.md` Section 7 for signal file schemas.

```
    +----------------------------------------------------------+
    |     SIGNAL FILES + AGENT TEAMS (DUAL COORDINATION)       |
    +----------------------------------------------------------+
    |                                                          |
    |  PRIMARY: Agent Teams API (real-time)                    |
    |  --------                                                |
    |  SendMessage notifies the Orchestrator immediately       |
    |  when an agent completes a task. This is the fast path.  |
    |                                                          |
    |  SECONDARY: Signal files (durable)                       |
    |  ---------                                               |
    |  Agents also write .vibecrew/signals/<event>.signal        |
    |  files as durable receipts. If an agent crashes after    |
    |  sending a SendMessage but before the Orchestrator       |
    |  processes it, the signal file persists on disk.          |
    |  Next session startup picks up unprocessed signals.      |
    |                                                          |
    |  Example flow (happy path):                              |
    |                                                          |
    |  1. Builder completes code for feat-003                  |
    |  2. Builder writes builder-complete.signal to disk       |
    |  3. Builder calls SendMessage to Orchestrator            |
    |  4. Orchestrator receives message, processes it          |
    |  5. Orchestrator deletes the signal file                 |
    |                                                          |
    |  Example flow (crash recovery):                          |
    |                                                          |
    |  1. Builder completes code for feat-003                  |
    |  2. Builder writes builder-complete.signal to disk       |
    |  3. Builder crashes before calling SendMessage           |
    |  4. Next session: Session Startup detects signal file    |
    |  5. Orchestrator processes the signal and continues      |
    |                                                          |
    +----------------------------------------------------------+
```

### 5.8 Conflict Prevention in Parallel Work

```
    +----------------------------------------------------------+
    |          PARALLEL CONFLICT PREVENTION LAYERS             |
    +----------------------------------------------------------+
    |                                                          |
    |  LAYER 1: Architectural Prevention (Tier 1 Foundation)   |
    |  ------------------------------------------------------- |
    |  design-system.css    -> shared tokens, no per-feature   |
    |                          color/spacing conflicts         |
    |  TDR                  -> shared stack, no dependency     |
    |                          conflicts                       |
    |  CLAUDE.md            -> shared conventions, consistent  |
    |                          code style                      |
    |  Roadmap              -> features scoped to minimize     |
    |                          file overlap                    |
    |                                                          |
    |  LAYER 2: Worktree Isolation                             |
    |  -------------------------------------------------------  |
    |  Each agent works in its own worktree.                   |
    |  Builder A in .claude/worktrees/builder-feat-003/        |
    |  Builder B in .claude/worktrees/builder-feat-004/        |
    |  No filesystem conflicts during concurrent work.         |
    |                                                          |
    |  LAYER 3: Sequential Merges                              |
    |  -------------------------------------------------------  |
    |  Orchestrator merges worktree branches one at a time.    |
    |  Later branches rebase onto updated main.                |
    |  Conflicts surface at merge time, not during dev.        |
    |                                                          |
    |  LAYER 4: File-Level Locks (shared state files only)     |
    |  -------------------------------------------------------  |
    |  .vibecrew/state.json   -> advisory lock during updates    |
    |  .vibecrew/backlog.json -> advisory lock during updates    |
    |                                                          |
    |  LAYER 5: Conflict Detection at PR Time                  |
    |  -------------------------------------------------------  |
    |  Before creating a PR, check if other active worktree    |
    |  branches have modified the same files.                  |
    |  If overlap detected: warn developer before proceeding.  |
    |                                                          |
    +----------------------------------------------------------+
```

### 5.9 Concurrency Limits

The `config.json` `concurrency.max_parallel_agents` setting (default: 3) limits how many agents can run simultaneously. See `architecture/schemas.md` Section 2 for the config schema.

| Scenario | Max Parallel Agents | Rate Limit Tier | Notes |
|----------|---------------------|-----------------|-------|
| Solo, free tier | 1-2 | Tier 1 | API rate limits are binding |
| Solo, paid tier | 3 | Tier 2 | Default configuration |
| Solo, Max plan | 3-5 | Tier 2-3 | Notifications solve the attention problem |
| Team, shared account | 2-3 per person | Tier 3+ | Account-level limits shared |

---

## 6. Workflow 6: System Review

### 6.1 Overview

The System Review workflow is a meta-level audit that evaluates the VibeCrew plugin itself rather than user projects. It collects anonymized telemetry from all registered projects, audits plugin internals, researches the external ecosystem, and produces prioritized improvement proposals.

**Key difference from other workflows:** This workflow operates at the plugin level and does NOT require `.vibecrew/state.json`. It requires `${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json`.

### 6.2 Trigger

User runs `/system-review` from the VibeCrew repository (not from a user project).

### 6.3 Data Flow

```
+----------------------------------------------------------------+
|                    SYSTEM REVIEW DATA FLOW                       |
+----------------------------------------------------------------+
|                                                                 |
|  REGISTERED PROJECTS                                            |
|  Project A (.vibecrew/) ──┐                                     |
|  Project B (.vibecrew/) ──┼── collect-telemetry.sh              |
|  Project C (.vibecrew/) ──┘        │                            |
|                                    ▼                            |
|                        telemetry/aggregate.json                 |
|                                    │                            |
|  PLUGIN FILES                      │                            |
|  agents/*.md ──────────┐           │                            |
|  skills/*/SKILL.md ────┤           │                            |
|  scripts/*.sh ─────────┤           │                            |
|  hooks/hooks.json ─────┤           │                            |
|  .mcp.json ────────────┘           │                            |
|         │                          │                            |
|         ▼                          ▼                            |
|  collect-plugin-stats.sh    System Reviewer Agent               |
|         │                   (Opus, worktree, read-only)         |
|         └──────────────────────────┤                            |
|                                    │                            |
|  EXTERNAL SOURCES                  │                            |
|  Anthropic docs ───────┐           │                            |
|  MCP ecosystem ────────┤           │                            |
|  Community patterns ───┘           │                            |
|                                    ▼                            |
|                        reviews/system-review-{ts}.md            |
|                        reviews/system-review-{ts}.json          |
|                                    │                            |
|                                    ▼                            |
|                      diff-review-findings.sh                    |
|                      (compare vs previous review)               |
|                                                                 |
+----------------------------------------------------------------+
```

### 6.4 Step-by-Step Sequence

| Step | Actor | Action | Output |
|------|-------|--------|--------|
| 1 | Skill | Pre-flight: verify plugin manifest | Plugin version |
| 2 | Skill | Check for previous reviews | Previous review JSON (if any) |
| 3 | Skill | Run `collect-plugin-stats.sh` | Plugin inventory JSON |
| 4 | Skill | Run `collect-telemetry.sh` | Aggregated telemetry JSON |
| 5 | Skill | Launch System Reviewer agent (worktree) | Markdown report |
| 6 | Skill | Save report (JSON + markdown) | Files in `reviews/` |
| 7 | Skill | Run `diff-review-findings.sh` (if previous exists) | New/recurring/resolved counts |
| 8 | Skill | Display terminal summary | Formatted output |

### 6.5 Agent Methodology (10 Steps)

The System Reviewer agent executes a structured 10-step analysis:

**Internal Audit (Steps 1-5):**
1. Plugin inventory via `collect-plugin-stats.sh`
2. Model routing audit — evaluate Opus/Sonnet/Haiku assignments
3. Context budget audit — check Budget/Escalation/Verification alignment
4. Pattern consistency audit — scan for structural deviations
5. Component usage audit — find unreferenced scripts, templates, MCP servers

**Telemetry Analysis (Step 6):**
6. Cross-project telemetry — analyze usage patterns, friction points, cost trends

**External Research (Steps 7-10):**
7. Anthropic documentation — new features, model updates, best practices
8. MCP ecosystem — new servers, registry gaps
9. Community patterns — Cursor rules, Windsurf, Aider, Claude Code community
10. Innovation brainstorm — synthesize findings into new ideas

### 6.6 Output Artifacts

| Artifact | Location | Format |
|----------|----------|--------|
| Markdown report | `${CLAUDE_PLUGIN_ROOT}/reviews/system-review-{ts}.md` | Structured markdown with 5 parts |
| JSON report | `${CLAUDE_PLUGIN_ROOT}/reviews/system-review-{ts}.json` | Schema: `system-review-report.json` |
| Telemetry aggregate | `${CLAUDE_PLUGIN_ROOT}/telemetry/aggregate.json` | Fresh aggregate from all projects |

### 6.7 Cross-Project Telemetry Registration

Projects register with the central plugin during `/setup`:

1. `init-vibecrew-state.sh` checks if `${CLAUDE_PLUGIN_ROOT}` is set and valid
2. Creates `project-registry.json` from template if missing
3. Adds the project path with an anonymous alias (project-NNN) if not already registered
4. Registration is idempotent — running `/setup` again is a no-op

### 6.8 Anonymization

All telemetry data uses anonymous project aliases. The registry maps real paths to aliases but this mapping never appears in review reports. Only aggregate statistics and alias-keyed data are included in reports.

---

## 7. State Transition Reference

### 6.1 Foundation State Transitions

```
    FOUNDATION STATES
    =================

    none ------> scaffolded ------> in-progress ------> complete
      |              |                  |                  |
      |  /setup      |  /new-project   |  artifacts      |  Phase gate
      |  creates     |  begins          |  created one    |  unlocked.
      |  .vibecrew/    |  foundation      |  by one via     |  Source code
      |              |  workflow via     |  Agent Teams    |  writes
      |              |  Agent Teams     |                 |  allowed.
```

### 6.2 Feature State Transitions

```
    FEATURE STATES (sequential with verify-fix loops)
    =================================================

    idea --> planning --> planned --> in-progress --> testing --> review --> done
     |          |           |           |    ^         |          |         |
     | /idea    | refine    | deps met  | /new-feat   | code     | tests   | PR
     | command  | specs +   | spec done | Builder     | done     | pass    | merged
     |          | criteria  | ready to  | worktree    |          | PR      |
     |          |           | build     |             |          | created |
     |          |           |           +-- fix ------+          |         |
     |          |           |           (verify-fix loop,        |         |
     |          |           |            max 3 iterations)       |         |
```

### 6.3 Session State Transitions

```
    SESSION STATES
    ==============

    launched --> initializing --> active --> wrapping --> terminated
                                   |
                                   +--> crashed (abnormal exit,
                                        detected by next startup,
                                        worktree preserved)
```

### 6.4 Combined State Diagram (All Workflows)

```
    +----------------------------------------------------------------+
    |                    VIBECREW MASTER STATE DIAGRAM                  |
    +----------------------------------------------------------------+
    |                                                                |
    |  ENVIRONMENT                                                   |
    |  ===========                                                   |
    |  [no plugin] --/setup--> [plugin installed, .vibecrew/ created]  |
    |                                                                |
    |  FOUNDATION                                                    |
    |  ==========                                                    |
    |  [incomplete] --/new-project--> [in-progress] --> [complete]   |
    |                                                                |
    |  - - - - - - PHASE GATE - - - - - - - - - - - -               |
    |  Source code writes blocked until foundation = complete        |
    |  - - - - - - - - - - - - - - - - - - - - - - - -               |
    |                                                                |
    |  BACKLOG (per feature, sequential with verify-fix loops)       |
    |  =======================================================      |
    |  [idea] --> [planning] --> [planned] --> [in-progress]          |
    |                                       |    ^                   |
    |                                       v    | fix               |
    |                           [done] <-- [review] <-- [testing]   |
    |                                                                |
    |  SESSION (per agent)                                           |
    |  ===================                                           |
    |  [launched] --> [initializing] --> [active] --> [wrapping]     |
    |                                      |            |            |
    |                                      |            v            |
    |                                      |      [terminated]       |
    |                                      v                         |
    |                                  [crashed]                     |
    |                                                                |
    |  PARALLEL COORDINATION                                         |
    |  =====================                                         |
    |  Worktrees:     .claude/worktrees/<agent>-<task>/ per agent    |
    |  Branches:      <type>/<feature-slug> per feature              |
    |  Agent Teams:   TeamCreate, TaskCreate, SendMessage            |
    |  Signals:       .vibecrew/signals/ (durable persistence layer)   |
    |  Locks:         .vibecrew/locks/ (mkdir-atomic, timeout-based)   |
    |  Orchestrator:  Autonomous coordination via Agent Teams API    |
    |                                                                |
    +----------------------------------------------------------------+
```

---

## 8. Error Recovery Across Workflows

### 8.1 Error Recovery Matrix

| Workflow | Failure | Detection | Recovery |
|----------|---------|-----------|----------|
| **New Project** | User abandons `/new-project` | Next session reads incomplete state | Resume from last completed artifact |
| **New Project** | Stack Scout cannot reach internet | Stack Scout exits with error | Offer manual TDR creation |
| **New Project** | Builder worktree creation fails | Worktree command fails | Fall back to inline execution |
| **New Project** | Worktree merge conflict | Git merge fails | Orchestrator reports conflict; manual resolution |
| **New Project** | Git init fails | Command exit code | Report error, user fixes manually |
| **Feature** | Builder crashes mid-feature | Stale session detection at startup | Worktree preserved on disk; new session reads worktree branch, resumes from last commit |
| **Feature** | Verify-fix loop exceeds 3 iterations | Iteration counter | Pause feature, notify developer for manual intervention |
| **Feature** | Tests fail at quality gate | Verifier reports failure | Stop backlog execution; developer intervenes |
| **Feature** | Merge conflict when merging worktree | Rebase/merge fails | Notification to developer; manual resolution |
| **Feature** | Dependency not yet complete | Dependency check fails | Skip feature, try next planned task |
| **Session** | Context hits 80% | check-context.sh hook | Force wrap; new session picks up from committed state |
| **Session** | Agent crashes without `/wrap` | Stale session detection | Clean up session entry; worktree has committed work |
| **Session** | Context compacted | Claude Code compaction | Agent re-reads state.json, backlog.json, and git log to recover context |
| **Feature** | Context rot across `/run-backlog` features | Inter-feature compaction (Step 3f) | Forced `/compact` between features; `compact-reinject.sh` re-injects state + architecture diagrams |
| **Session** | Stale lock blocks shared file | Lock age > timeout or PID dead | Auto-remove stale lock on next access |
| **Parallel** | Two worktrees modify same file | Conflict detected at merge time | Orchestrator merges sequentially; second merge gets conflict |
| **Parallel** | Concurrent write to backlog.json | mkdir lock contention | Wait up to 30s; fail with clear error if timeout |
| **Parallel** | Orphaned worktree (agent crashed) | Session Startup scans worktrees | Report orphaned worktrees to developer; offer cleanup |

### 8.2 Worktree-Specific Recovery

Worktrees add a new failure mode (orphaned worktrees) but also simplify recovery for existing failure modes:

```
    +----------------------------------------------------------+
    |          WORKTREE FAILURE + RECOVERY SCENARIOS            |
    +----------------------------------------------------------+
    |                                                          |
    |  SCENARIO 1: Agent crashes mid-work                      |
    |  ------------------------------------------              |
    |  Before (branch-only):                                   |
    |    Uncommitted changes lost. Branch has last commit.     |
    |  After (worktree):                                       |
    |    Worktree preserved on disk with all files.            |
    |    New agent can resume from exact file state.           |
    |    Even uncommitted changes are recoverable.             |
    |                                                          |
    |  SCENARIO 2: Merge conflict                              |
    |  ------------------------------------------              |
    |  Before (branch-only):                                   |
    |    Conflict appears during PR rebase. Developer must     |
    |    switch branches and resolve manually.                 |
    |  After (worktree):                                       |
    |    Conflict appears when Orchestrator merges worktree.   |
    |    The worktree is preserved so the developer can        |
    |    resolve the conflict in-place.                        |
    |                                                          |
    |  SCENARIO 3: Orphaned worktree                           |
    |  ------------------------------------------              |
    |  Cause: Agent crashes and worktree is not cleaned up.    |
    |  Detection: Session Startup scans .claude/worktrees/     |
    |    for directories with no active agent process.         |
    |  Recovery: List orphaned worktrees to the developer.     |
    |    Options: resume work in the worktree, merge it,       |
    |    or delete it.                                         |
    |                                                          |
    |  CLEANUP COMMAND:                                        |
    |    git worktree list                                     |
    |    git worktree remove .claude/worktrees/<name>          |
    |    (or let Orchestrator handle via merge-back)           |
    |                                                          |
    +----------------------------------------------------------+
```

### 7.3 Idempotency Requirements

Every operation across all workflows must be safe to re-run. This is the fundamental guarantee that enables crash recovery.

```
    +----------------------------------------------------------+
    |              IDEMPOTENCY REQUIREMENTS                    |
    +----------------------------------------------------------+
    |                                                          |
    |  File creation:                                          |
    |    Before creating, check if file exists with correct    |
    |    content. Skip or overwrite if content differs.        |
    |                                                          |
    |  Worktree creation:                                      |
    |    Before creating, check if worktree already exists.    |
    |    Reuse if present. git worktree list to verify.        |
    |                                                          |
    |  Branch creation:                                        |
    |    Before creating, check if branch exists. Switch to    |
    |    it if so.                                             |
    |                                                          |
    |  PR creation:                                            |
    |    Before creating, check if PR exists for branch.       |
    |    Skip if so.                                           |
    |                                                          |
    |  Backlog updates:                                        |
    |    Read current state first. Only write if the           |
    |    transition is valid (e.g., planned -> in-progress      |
    |    but not done -> in-progress).                         |
    |                                                          |
    |  Signal file creation:                                   |
    |    Overwrite if signal already exists (latest data).     |
    |                                                          |
    |  Worktree merge-back:                                    |
    |    Check if branch already merged. Skip merge if so.     |
    |    Only delete worktree after confirmed merge.           |
    |                                                          |
    |  Test execution:                                         |
    |    Inherently idempotent.                                |
    |                                                          |
    |  npm install:                                            |
    |    Inherently idempotent (reads lock file).              |
    |                                                          |
    +----------------------------------------------------------+
```

### 7.4 Graceful Degradation Priority

When errors cannot be automatically recovered, VibeCrew degrades gracefully in this priority order:

1. **Preserve committed work.** Git commits are durable. Always commit before doing anything risky. Worktrees preserve even uncommitted work on disk.
2. **Preserve state files.** `state.json` and `backlog.json` reflect the last known-good state. Update only after successful operations.
3. **Preserve worktrees.** Never delete a worktree with uncommitted or unmerged work. Orphaned worktrees are recoverable.
4. **Notify the developer.** Fire an OS notification via the Interrupt Protocol so the developer knows something needs attention.
5. **Provide clear recovery instructions.** Error messages include specific commands the developer can run to fix the issue.
6. **Never leave partial state.** If an operation cannot complete atomically, roll back to the previous state rather than leaving a half-updated file.

---

## 8. GitHub Issue Fix Lifecycle

### 8.1 Overview

The GitHub Issue Fix workflow connects GitHub Issues directly to VibeCrew's development pipeline. It operates in two modes:

- **Interactive** (`/fix-issue <number>`): A developer triggers a fix from the CLI. The agent fetches the issue, implements a fix, runs quality checks, and opens a PR.
- **CI-triggered** (GitHub Actions): A label event triggers the workflow automatically via the `github-actions-autofix.yml` template.

Both paths converge on the same scripts and agents. The only difference is the entry point and autonomy level.

### 8.2 Dual-Mode Paths

**Hotfix path** (default for bugs): Code → Test → Review → PR. Skips Plan and Design since bugs don't need upfront design work.

**Full feature path** (`--full` flag or `enhancement`/`feature-request` labels): Plan → Design → Code → Test → Review → Docs → PR. Uses the standard Tier 2 cycle.

### 8.3 Sequence Diagram

```
┌─────────┐   ┌──────────────┐   ┌─────────────┐   ┌─────────┐   ┌──────────────┐   ┌────────┐
│  GitHub  │   │ fetch-github │   │ import-issue │   │ Builder │   │   Verifier   │   │   gh   │
│  Issue   │   │  -issue.sh   │   │ -to-backlog  │   │  Agent  │   │   Agent      │   │   CLI  │
└────┬─────┘   └──────┬───────┘   └──────┬───────┘   └────┬────┘   └──────┬───────┘   └───┬────┘
     │                │                   │                │               │               │
     │  gh issue view │                   │                │               │               │
     │◄───────────────┤                   │                │               │               │
     │  issue JSON    │                   │                │               │               │
     ├───────────────►│                   │                │               │               │
     │                │  pipe JSON        │                │               │               │
     │                ├──────────────────►│                │               │               │
     │                │  backlog entry    │                │               │               │
     │                │◄─────────────────┤                │               │               │
     │                │                   │  issue context │               │               │
     │                │                   ├───────────────►│               │               │
     │                │                   │  fix applied   │               │               │
     │                │                   │◄───────────────┤               │               │
     │                │                   │                │  run checks   │               │
     │                │                   │                ├──────────────►│               │
     │                │                   │                │  PASS/FAIL    │               │
     │                │                   │                │◄──────────────┤               │
     │                │                   │                │               │  gh pr create │
     │                │                   │                ├───────────────┼──────────────►│
     │                │                   │                │               │  PR URL       │
     │                │                   │                │◄──────────────┼───────────────┤
     │                │                   │                │               │               │
```

### 8.4 State Transitions (Hotfix Mode)

```
planned → in-progress → testing → review → done
```

| Transition | Trigger |
|-----------|---------|
| `planned → in-progress` | `/fix-issue` imports issue and starts Builder |
| `in-progress → testing` | Builder completes code phase |
| `testing → review` | Verifier passes quality checks |
| `review → done` | Code review passes (or skipped per profile), PR created |

### 8.5 Integration with /sync-issues and /run-backlog

The `/sync-issues` command provides batch import:

1. `/sync-issues` fetches issues by label and imports them into the backlog
2. Each imported issue becomes a backlog entry with `source: "github-issue"`
3. `/run-backlog` processes them in priority order using the standard Tier 2 cycle
4. Hotfix entries start at `planned` column (skip planning phase)
5. Feature entries start at `idea` column (full 6-phase cycle)

### 8.6 GitHub Actions Integration

The `github-actions-autofix.yml` template provides fully automated CI-triggered fixes:

1. Issue receives the configured label (default: `autofix`)
2. GitHub Actions workflow triggers on `issues.labeled` event
3. Workflow runs `claude --print "/fix-issue <number>"` headless
4. On success: comments on issue with PR link
5. On failure: comments with workflow run link for manual investigation

Template placeholders (`{{AUTOFIX_LABEL}}`, `{{NODE_VERSION}}`) are filled by `/setup`.

---

## Document References

| Document | Relevance |
|----------|-----------|
| `architecture/schemas.md` | Canonical JSON schemas for all `.vibecrew/` files (state, backlog, sessions, scores, signals, locks) |
| `architecture/system-overview.md` | Plugin structure, agent topology, safety layer |
| `architecture/agents.md` | Per-agent specs (5 agents: triggers, contracts, worktree isolation, verification loops) |
| `architecture/safety.md` | Blocked operations, approval gates, rollback |
| `architecture/scoring.md` | Vibe Score calculation methodology |
| `research/02-multi-agent-orchestration.md` | Communication patterns, locks, signals, Agent Teams research |
| `research/03-git-automation.md` | Worktrees, conventional commits, PR creation |
| `docs/vibecrew-guide-complete.md` | User-facing workflow descriptions |
