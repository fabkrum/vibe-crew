# Agent Design

> **Phase 2 Architecture** | Document 02 (Revised) | February 2026
>
> This document defines all 14 VibeCrew v1.7.0 agents -- their trigger conditions, input/output contracts, tool permissions, verification loops, context budgets, safety constraints, status reporting mechanisms, and complete YAML frontmatter for their `.md` definition files. Each agent runs as an isolated Claude Code sub-agent with its own context window, as documented in [Research 01: Plugin Architecture](../research/01-claude-code-plugin-architecture.md) and [Research 02: Multi-Agent Orchestration](../research/02-multi-agent-orchestration.md).
>
> **v1.0 Consolidation.** This revision reduces the agent count from 9 to 5, following Boris Cherny / Anthropic best practices for multi-agent systems. The primary changes: UI Designer and Feature Developer merge into **Builder**; Test Writer, Quality Check, and Performance Coach scoring merge into **Verifier**; Doc Generator and Performance Coach (as standalone agents) are deferred to v1.1. Every agent now includes an explicit **Verification Loop** -- the single most important practice for reliable agent output.

---

## Table of Contents

1. [Agent Summary Table](#1-agent-summary-table)
2. [Tool Access Matrix](#2-tool-access-matrix)
3. [Session Startup Agent](#3-session-startup-agent)
4. [Workflow Orchestrator Agent](#4-workflow-orchestrator-agent)
5. [Stack Scout Agent](#5-stack-scout-agent)
6. [Builder Agent](#6-builder-agent)
7. [Verifier Agent](#7-verifier-agent)
8. [Agent Interaction Map](#8-agent-interaction-map)
9. [Design Decisions](#9-design-decisions)
10. [System Reviewer Agent](#10-system-reviewer-agent)

---

## 1. Agent Summary Table

| # | Agent | Model | Trigger | Context Budget | Isolation | maxTurns |
|---|-------|-------|---------|----------------|-----------|----------|
| 1 | Session Startup | Haiku | `SessionStart` hook | <10% | Inline | 5 |
| 2 | Workflow Orchestrator | Opus | Primary tab (always running) | <40% | Inline | 30 |
| 3 | Stack Scout | Opus | Delegated by Orchestrator for research | <45% | Worktree | 50 |
| 4 | Builder | Opus | Delegated for design and code phases | <45% | Worktree | 100 |
| 5 | Verifier | Haiku | Delegated for test phase, `/check`, `/wrap` | <40% | Inline | 60 |
| 6 | Performance Coach | Opus | `/wrap` Step 9.5 (after 5+ sessions) | <30% | Inline | 25 |
| 7 | Doc Generator | Sonnet | `/wrap` Step 10, `/handoff`, `/release` | <25% | Inline | 20 |
| 8 | Code Auditor | Opus | `/audit`, `/onboard` | <40% | Worktree | 40 |
| 9 | Security Auditor | Opus | Security analysis (manual trigger) | <40% | Worktree | 40 |
| 10 | Code Simplifier | Opus | `/simplify` | <35% | Worktree | 30 |
| 11 | CI Healer | Opus | `/heal` (GitHub Actions and GitLab CI) | <30% | Inline | 15 |
| 12 | Opponent Processor | Opus | TDR counter-analysis (Tier 1 Step 3.5) | <35% | Worktree | 30 |
| 13 | Code Reviewer | Opus | `/review`, `/run-backlog` Phase 4.5 | <35% | Worktree | 30 |
| 14 | System Reviewer | Opus | `/system-review` | <30% | Worktree | 25 |

### Agents Originally Deferred, Now Implemented

| Agent | Role | Status |
|-------|------|--------|
| Performance Coach | Session retrospective, CLAUDE.md mutations, persistent memory, erosion trend analysis, expertise record writing | **Implemented.** Standalone Opus agent with `memory: project`. Reads erosion trends (`.vibecrew/erosion/trends.json`), detects recurring anti-patterns including erosion-complexity and erosion-hot-file, proposes CLAUDE.md mutations via 7-step guardrailed workflow. Writes failure/convention records to `.vibecrew/expertise/`. |
| Doc Generator | VitePress docs, session logs, release notes, CHANGELOG | **Implemented.** Sonnet agent invoked during `/wrap` Step 10.5. Checks architecture diagram freshness, generates feature docs, updates CHANGELOG, rebuilds VitePress sidebar. |

---

## 2. Tool Access Matrix

| Agent | Read | Write | Edit | Bash | Glob | Grep | WebSearch | WebFetch | Context7 | Chrome DevTools | Playwright | Semgrep | Sentry | Supabase | Stripe | Vercel | Figma | Agent Teams |
|-------|:----:|:-----:|:----:|:----:|:----:|:----:|:---------:|:--------:|:--------:|:---------:|:----------:|:-------:|:------:|:--------:|:------:|:------:|:-----:|:-----------:|
| Session Startup | x | - | - | x | x | x | - | - | - | - | - | - | - | - | - | - | - | - |
| Workflow Orchestrator | x | - | - | x | x | x | - | - | - | - | - | - | - | - | - | - | - | x |
| Stack Scout | x | - | - | x | x | x | x | x | x | x | - | - | - | x | - | - | - | - |
| Builder | x | x | x | x | x | x | - | - | x | - | x | - | - | x | x | x | x | - |
| Verifier | x | x | x | x | x | x | - | - | x | - | x | - | - | - | - | - | - | - |
| Security Auditor | x | - | - | x | x | x | - | - | - | - | - | x | - | - | - | - | - | - |
| CI Healer | x | x | x | x | x | x | - | - | - | - | - | - | x | - | - | - | - | - |
| Code Reviewer | x | x | - | x | x | x | - | - | x | - | x | - | - | - | - | - | - | - |
| System Reviewer | x | - | - | x | x | x | x | x | x | - | - | - | - | - | - | - | - | - |

Note: Conditional MCP servers (Supabase, Stripe, Vercel, Figma, Sentry, Semgrep) only expose tools when enabled. Agents list these tools in frontmatter regardless — they activate when the server is enabled.

**Key changes from v0.9 (9-agent) design:**

- **Workflow Orchestrator** now uses Agent Teams API (`TeamCreate`, `TaskCreate`, `SendMessage`) instead of presenting copy-paste commands. Still cannot use `Write` or `Edit` directly -- all `.vibecrew/` state mutations go through Bash scripts (see Section 4 for details).
- **Builder** inherits the combined tool set of UI Designer and Feature Developer, plus `isolation: worktree` for parallel work.
- **Verifier** inherits the combined tool set of Test Writer and Quality Check, plus the scoring logic from Performance Coach.

---

## 3. Session Startup Agent

### Purpose

The Session Startup agent is the entry point for every VibeCrew session. It fires automatically on the `SessionStart` hook, performs a rapid environment check, reads project state, detects stale sessions from crashed agents, and produces a routing decision that tells Claude Code which workflow to enter. It runs on Haiku for speed and cost efficiency -- this agent fires on every single session start, so it must be fast and cheap.

### YAML Frontmatter

```yaml
---
name: session-startup
description: >
  Fires on every session start. Reads .vibecrew/state.json, checks git status,
  detects stale sessions, and routes to the appropriate workflow. Use this
  agent automatically on session initialization.
model: haiku
tools:
  - Read
  - Bash
  - Glob
  - Grep
maxTurns: 5
---
```

### Trigger Conditions

| Condition | Details |
|-----------|---------|
| **Primary trigger** | `SessionStart` hook (matcher: `startup`) |
| **Secondary trigger** | `SessionStart` hook (matcher: `resume`) -- fires when resuming a previous session |
| **Frequency** | Every session start -- the most frequently fired agent in the system |

The `SessionStart` hook invokes the `session-startup.sh` script, which sets environment variables via `CLAUDE_ENV_FILE` and outputs a status summary. The Session Startup agent processes this output and makes routing decisions.

### Input/Output Contract

**Input:**

| Source | Data | Format |
|--------|------|--------|
| `.vibecrew/state.json` | Foundation status, active feature, parallel sessions | JSON (see `architecture/schemas.md` Section 3 for the canonical schema) |
| `.vibecrew/backlog.json` | Feature queue, statuses, dependencies | JSON (see `architecture/schemas.md` Section 4 for the canonical schema) |
| `.vibecrew/signals/` | Pending completion signals from other agents | Signal files (see `architecture/schemas.md` Section 7) |
| `.vibecrew/locks/` | Active advisory locks | Lock directories (see `architecture/schemas.md` Section 8) |
| `git status` | Working tree state, current branch, uncommitted changes | CLI output |
| `CLAUDE_ENV_FILE` | Session environment variable file path | Environment variable |

**Output:**

| Output | Description | Destination |
|--------|-------------|-------------|
| Routing decision | Which workflow to enter (Tier 1, Tier 2, resume feature, idle) | stdout (injected into Claude's context) |
| Environment report | 3-line status summary (foundation, active feature, git branch) | stdout |
| Environment variables | `VIBECREW_ACTIVE=true`, `VIBECREW_VERSION`, project name | `CLAUDE_ENV_FILE` |
| Stale session cleanup | Removes crashed session entries from `state.json` | `.vibecrew/state.json` |
| Stale lock cleanup | Removes expired lock directories | `.vibecrew/locks/` |

**Output format (stdout, injected into Claude's context):**

```
VibeCrew v1.0.0 | TravelPack | Branch: feat/user-auth
Foundation: complete | Active feature: user-authentication (phase: code)
Routing: Resume Tier 2 feature session -- continue implementing user-authentication.
```

### Verification Loop

| Step | Action | Retry Behavior |
|------|--------|----------------|
| 1. **Verify state files exist** | After reading `.vibecrew/state.json` and `backlog.json`, confirm both parsed successfully and contain valid `schema_version` fields | If parse fails, attempt to run `migrate-state.sh` to repair. Max 1 retry. |
| 2. **Verify routing decision is complete** | After producing the routing decision, verify it contains all three required lines (VibeCrew version, foundation status, routing instruction) | If incomplete, re-read state files and regenerate. Max 1 retry. |
| 3. **Verify stale cleanup succeeded** | After cleaning stale locks and sessions, re-read the locks directory to confirm no stale entries remain | If stale entries persist, log a warning but do not block session start. No retry -- escalate to Orchestrator. |

**Escalation:** If the Session Startup agent cannot produce a valid routing decision after retries, it outputs a fallback message: `"VibeCrew: State corrupted. Run /setup to reinitialize."` and exits. This ensures the session always starts, even if state is damaged.

### Context Window Budget

**Target: <10%** of the context window.

This agent performs only file reads and simple shell commands. It should complete in 3-5 turns maximum. No research, no code generation, no lengthy analysis. If it exceeds 10%, something is wrong with the agent prompt.

### Safety Constraints

| Constraint | Enforcement |
|------------|-------------|
| **Cannot write source code** | `tools` list excludes `Write` and `Edit` |
| **Cannot modify backlog** | No `Write` tool -- can only read `backlog.json` |
| **Cannot spawn sub-agents** | `tools` list excludes Agent Teams tools |
| **Cannot access the internet** | `tools` list excludes `WebSearch`, `WebFetch`, and all MCP tools |
| **Limited turns** | `maxTurns: 5` prevents runaway execution |
| **Read-only state inspection** | May only clean up stale sessions and locks via `Bash` (defensive operations) |

### Status Reporting

The Session Startup agent reports by writing to stdout, which Claude Code injects into the main session's context. It does not write signal files or update `state.json` beyond stale session cleanup. Its routing decision is consumed by the Workflow Orchestrator to determine the next action.

---

## 4. Workflow Orchestrator Agent

### Purpose

The Workflow Orchestrator is the central coordinator of the VibeCrew system. It runs in the primary terminal tab and is responsible for reading project state, processing completion signals from other agents, creating agent teams for feature work, and guiding the developer through the Two-Tier Workflow.

The Orchestrator never writes source code. Its job is purely strategic: understand the current state, determine what should happen next, assemble the right team of agents, and communicate progress to the developer. In v1.0, the Orchestrator uses the **Agent Teams API** (`TeamCreate`, `TaskCreate`, `SendMessage`) to coordinate work across agents instead of presenting copy-paste commands.

**Write permission resolution.** The Orchestrator has `disallowedTools: Write, Edit` to prevent scope creep into source code writing. However, it needs to update `.vibecrew/` state files (e.g., advancing feature phases, processing signals, updating backlog). This is resolved by using `Bash` to run shared scripts (`complete-phase.sh`, `claim-task.sh`, `update-backlog.sh`) that modify `.vibecrew/` state files. The scripts are the same validated code paths used by all agents, ensuring consistent state mutations regardless of which agent triggers them.

### YAML Frontmatter

```yaml
---
name: workflow-orchestrator
description: >
  Main coordinator agent that runs in the primary terminal tab. Reads project
  state, processes completion signals, routes between Tier 1 and Tier 2
  workflows, and coordinates agent teams. Cannot write source code directly.
  Updates .vibecrew/ state via shared Bash scripts. Use this agent for project
  coordination and task routing.
model: opus
tools:
  - Read
  - Bash
  - Glob
  - Grep
  - TeamCreate
  - TaskCreate
  - SendMessage
disallowedTools:
  - Write
  - Edit
  - WebSearch
  - WebFetch
maxTurns: 30
---
```

### Trigger Conditions

| Condition | Details |
|-----------|---------|
| **Primary trigger** | Runs as the main agent in Tab 1 (primary terminal) |
| **On session start** | Session Startup agent routes to Orchestrator when project state requires coordination |
| **On signal detection** | When completion signals appear in `.vibecrew/signals/`, the Orchestrator processes them |
| **On user command** | `/status`, `/plan-features`, `/run-backlog`, `/idea` route through the Orchestrator |

### Input/Output Contract

**Input:**

| Source | Data | Format |
|--------|------|--------|
| `.vibecrew/state.json` | Foundation status, active feature, parallel sessions | JSON (see `architecture/schemas.md` Section 3) |
| `.vibecrew/backlog.json` | Feature queue with specs, statuses, dependencies | JSON (see `architecture/schemas.md` Section 4) |
| `.vibecrew/signals/` | Completion signals from other agents | Signal files (see `architecture/schemas.md` Section 7) |
| Session Startup output | Routing decision and environment report | stdout text |
| User commands | `/status`, `/plan-features`, `/run-backlog`, `/idea` | Skill invocations |

**Output:**

| Output | Description | Destination |
|--------|-------------|-------------|
| Status report | Comprehensive project state summary | stdout (presented to developer) |
| Agent team creation | Creates teams with Builder, Verifier, Stack Scout via Agent Teams API | Agent Teams |
| Task assignments | Assigns design, code, test, research tasks to team members | Agent Teams |
| Signal processing | Advances feature phases after processing completion signals | `.vibecrew/backlog.json` (via `Bash` scripts) |
| Feature specs | Creates/updates feature specifications during `/plan-features` | `.vibecrew/backlog.json` (via `Bash` scripts) |
| Progress updates | Sends inter-agent coordination messages | Agent Teams (`SendMessage`) |

**Agent Teams API usage:**

```
// Creating a feature development team
TeamCreate({
  name: "feat-001-user-auth",
  members: ["builder", "verifier"]
})

// Assigning the design + code task to Builder
TaskCreate({
  team: "feat-001-user-auth",
  assignee: "builder",
  description: "Design and implement user-authentication feature per spec in backlog.json",
  context: { feature_id: "feat-001", phases: ["design", "code"] }
})

// After Builder signals completion, assigning test task to Verifier
SendMessage({
  team: "feat-001-user-auth",
  to: "verifier",
  message: "Builder completed code phase for feat-001. Run tests and quality checks."
})
```

### Verification Loop

| Step | Action | Retry Behavior |
|------|--------|----------------|
| 1. **Verify signal processing** | After processing a completion signal from `.vibecrew/signals/`, re-read `backlog.json` to confirm the feature's column/phase was updated correctly | If state did not update, re-run the `complete-phase.sh` script. Max 2 retries. |
| 2. **Verify team creation** | After calling `TeamCreate`, confirm the team was created by listing active teams | If creation failed, retry once. If still fails, fall back to presenting manual instructions. |
| 3. **Verify task handoff** | After assigning a task via `TaskCreate`, poll for the agent's first status update within 30 seconds | If no status update, send a `SendMessage` ping. If no response after 60 seconds, notify the developer that the agent may need manual launch. Max 1 retry. |
| 4. **Verify state consistency** | After any state mutation (phase advance, backlog update), read both `state.json` and `backlog.json` to confirm they are consistent (e.g., active feature phase matches backlog column) | If inconsistent, run `sync-state.sh` to reconcile. Max 1 retry. Log discrepancy to session log. |

**Escalation:** If verification fails after retries, the Orchestrator presents a clear error message to the developer with the current state and suggested manual recovery steps. It never silently proceeds with inconsistent state.

### Context Window Budget

**Target: <40%** of the context window.

The Orchestrator runs for the duration of the session and accumulates context as it processes signals, presents status reports, and coordinates handoffs. It must stay well under 50% to leave room for tool results and reasoning. Context is managed by:

- Using `Bash` scripts for state inspection (avoids reading large files into context)
- Delegating expensive operations to sub-agents (Stack Scout for research, Verifier for validation)
- Summarizing signal contents rather than loading full signal files

### Safety Constraints

| Constraint | Enforcement |
|------------|-------------|
| **Cannot write source code** | `disallowedTools: Write, Edit` |
| **Cannot write any files directly** | `disallowedTools: Write, Edit` -- all file mutations go through Bash scripts |
| **State mutations via scripts only** | When updating `backlog.json` or `state.json`, must use shared scripts (`complete-phase.sh`, `claim-task.sh`, `update-backlog.sh`) to ensure validated code paths |
| **Cannot access the internet** | `disallowedTools: WebSearch, WebFetch` -- delegates research to Stack Scout |
| **Cannot modify design system** | No Write/Edit tools prevents direct file changes |
| **Agent Teams scoping** | Can only create teams with registered VibeCrew agents (session-startup, stack-scout, builder, verifier) |

### Status Reporting

The Orchestrator is the **recipient** of status reports from other agents, not a reporter itself. It consumes:

- Signal files from completing agents (see `architecture/schemas.md` Section 7 for signal file schemas)
- Git branch/PR state via `gh` CLI
- `state.json` and `backlog.json` for current project state

It presents synthesized status to the developer via stdout, formatted as a structured report.

---

## 5. Stack Scout Agent

### Purpose

The Stack Scout is a **read-only research agent** that evaluates technology options and produces Technology Decision Records (TDRs). It has access to web search, URL fetching, Context7 library documentation, and Chrome DevTools browser automation -- the full research toolkit. It is explicitly forbidden from creating or modifying source files.

The Stack Scout runs in an **isolated git worktree** (`isolation: worktree`), meaning it operates in a separate filesystem workspace that prevents any accidental side effects on the main working tree. All the thousands of tokens consumed by web searches, documentation fetches, and comparative analysis stay outside the main session. Only the distilled TDR output returns to the parent context. This isolation saves an estimated 8,000-15,000 tokens per research session.

### YAML Frontmatter

```yaml
---
name: stack-scout
description: >
  Read-only research agent that evaluates technology options and produces
  Technology Decision Records (TDRs). Has access to WebSearch, WebFetch,
  Context7, and Chrome DevTools for comprehensive research. Cannot create or
  modify source files. Works in an isolated worktree to prevent filesystem
  side effects. Use proactively for architecture research before any
  implementation begins.
model: opus
tools:
  - Read
  - Glob
  - Grep
  - Bash
  - WebSearch
  - WebFetch
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
  - mcp__chrome-devtools__navigate
  - mcp__chrome-devtools__screenshot
  - mcp__chrome-devtools__evaluate
  - mcp__supabase__list-tables
  - mcp__supabase__get-table
disallowedTools:
  - Write
  - Edit
  - TeamCreate
  - TaskCreate
  - SendMessage
maxTurns: 50
isolation: worktree
---
```

### Trigger Conditions

| Condition | Details |
|-----------|---------|
| **Tier 1 trigger** | Delegated by Orchestrator during Step 3 of `/new-project` (architecture decision) |
| **Tier 2 trigger** | Delegated when a feature requires technology research before implementation |
| **Ad-hoc trigger** | Developer or Orchestrator invokes for specific research questions |
| **Never auto-invoked** | Always explicitly delegated -- research is too expensive to run speculatively |

### Input/Output Contract

**Input:**

| Source | Data | Format |
|--------|------|--------|
| Task prompt | Research question or requirements to evaluate | Text (from Orchestrator via Agent Teams) |
| `VISION.md` | Project goals, constraints, performance targets | Markdown (read from filesystem) |
| `CLAUDE.md` | Existing tech stack decisions (if any) | Markdown (read from filesystem) |
| `.vibecrew/backlog.json` | Feature requirements that inform tech choices | JSON (see `architecture/schemas.md` Section 4) |

**Output:**

| Output | Description | Destination |
|--------|-------------|-------------|
| Technology Decision Record | Structured document with context, options, decision, and consequences | Returned to parent context as task result |
| Preliminary System Diagram | `flowchart TD` Mermaid diagram using chosen TDR technology names | Returned as text within TDR output; Orchestrator extracts for `.vibecrew/architecture/system.mmd` |
| TDR file | Written to `docs/tdr-NNN-<topic>.md` by the Orchestrator (not by Stack Scout directly) | Orchestrator delegates the write |

**TDR output structure:**

```markdown
# TDR-NNN: <Decision Title>

## Status
Proposed | Accepted | Superseded

## Context
Technical requirements and business goals extracted from VISION.md and the feature spec.

## Options Considered
Comparative analysis table with pros, cons, and fit assessment for each option.

## Decision
The chosen option with detailed justification.

## Consequences
### Positive
Expected benefits of the decision.

### Negative
Known trade-offs and mitigation strategies.

### Token Impact Assessment
Estimated boilerplate level, Context7 coverage, and token efficiency recommendations.
```

### Verification Loop

| Step | Action | Retry Behavior |
|------|--------|----------------|
| 1. **Verify TDR completeness** | After producing the TDR, check that all required sections are present: Status, Context, Options Considered, Decision, Consequences (Positive, Negative, Token Impact) | If any section is missing, re-generate the missing section. Max 2 retries. |
| 2. **Verify all options have pros/cons** | For each option in "Options Considered", confirm it has at least one pro and one con listed | If an option lacks pros or cons, research further and fill in the gap. Max 2 retries. |
| 3. **Verify Context7 citations** | Check that at least one library documentation reference was consulted via Context7 for the chosen technology | If no Context7 reference exists and the technology has a Context7 entry, perform the lookup and add the reference. Max 1 retry. |
| 4. **Verify decision rationale** | Confirm the "Decision" section references specific criteria from VISION.md or the feature spec (not generic reasoning) | If rationale is generic, re-read VISION.md and strengthen the justification with project-specific references. Max 1 retry. |

**Escalation:** If the research exceeds `maxTurns` or the context budget before verification is complete, the agent returns a partial result with a clear indication of what was completed and what remains to be researched. The Orchestrator can then decide whether to spawn a fresh Stack Scout session to continue.

### Context Window Budget

**Target: <45%** of the context window.

Research sessions are inherently context-heavy due to web search results, documentation fetches, and comparative analysis. The 45% target is achievable because:

- Context7 lookups return focused documentation snippets (not full pages)
- WebSearch results are summarized by the tool before entering context
- The agent should search, analyze, and synthesize -- not accumulate raw data
- `maxTurns: 50` provides a hard ceiling on execution length

### Safety Constraints

| Constraint | Enforcement |
|------------|-------------|
| **Cannot create or modify files** | `disallowedTools: Write, Edit` |
| **Cannot spawn sub-agents** | `disallowedTools: TeamCreate, TaskCreate, SendMessage` |
| **Cannot execute arbitrary code** | `Bash` is available for `git` and `jq` queries only -- no package installation or builds |
| **Cannot modify project state** | No Write/Edit prevents changes to `state.json`, `backlog.json`, or any project file |
| **Isolated worktree** | `isolation: worktree` -- runs in a separate git worktree to prevent any filesystem side effects |
| **Research output only** | All output returns as text to the Orchestrator, which decides whether to persist it |

**Bash usage note:** The Stack Scout has `Bash` access for read-only operations like `git log`, `jq` queries on JSON files, and checking file existence. The agent prompt explicitly instructs it not to run installation commands, build scripts, or anything that modifies the filesystem.

### Status Reporting

The Stack Scout returns its TDR as the task result when it completes. The Orchestrator receives the TDR text via Agent Teams and decides whether to write it to a file. A signal file is created in `.vibecrew/signals/` (see `architecture/schemas.md` Section 7.3 for the research-complete signal schema).

If the research exceeds `maxTurns` or the context budget, the agent returns a partial result with a clear indication of what was completed and what remains to be researched.

---

## 6. Builder Agent

### Purpose

The Builder is the combined **design and implementation** agent in VibeCrew v1.0. It merges the responsibilities of the former UI Designer and Feature Developer agents into a single agent that handles the full creative pipeline:

- **Tier 1 (Foundation):** Creates the project's `design-system.css` with HSL color palettes, typography scales, spacing systems, and component tokens. Alternatively, validates and extends an imported design system provided via the BYODS (Bring Your Own Design System) import flow.
- **Tier 2 (Feature Development):** Reads architecture diagrams from `.vibecrew/architecture/` for implementation context, designs component specifications, implements features within TDR boundaries, creates feature branches, writes application code, updates `component-tree.mmd` as new components are added, and makes conventional commits with `Co-Authored-By` trailers.

The Builder uses Context7 to look up documentation for CSS frameworks, component libraries (such as shadcn/ui), design system conventions, and application framework APIs. It works in an **isolated git worktree** (`isolation: worktree`), enabling parallel feature development across multiple terminal tabs without filesystem conflicts.

### YAML Frontmatter

```yaml
---
name: builder
description: >
  Combined design and implementation agent. Creates design-system.css during
  Tier 1 and implements features during Tier 2. Uses Context7 for library
  documentation. Works in an isolated worktree for parallel development.
  Handles component design specs, source code implementation, conventional
  commits, and PR preparation. Uses Playwright MCP for visual verification
  of frontend changes.
model: opus
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
  - mcp__playwright__browser_navigate
  - mcp__playwright__browser_screenshot
  - mcp__playwright__browser_console_messages
  - mcp__playwright__browser_evaluate
  - mcp__playwright__browser_resize
maxTurns: 100
isolation: worktree
---
```

### Trigger Conditions

| Condition | Details |
|-----------|---------|
| **Tier 1 trigger** | Delegated by Orchestrator during Step 2 of `/new-project` (design system creation via Design Discovery interview or BYODS import) |
| **Tier 2 design trigger** | Delegated when a feature enters the `design` phase |
| **Tier 2 code trigger** | Delegated when a feature enters the `code` phase, or continues from design into code |
| **`/new-feature` trigger** | Launched via the `/new-feature "name"` skill, which creates a branch and loads the feature spec |
| **`/run-backlog` trigger** | Automatically invoked for the `design` and `code` phases during backlog processing |
| **Prerequisite (Tier 2)** | Foundation must be complete (`state.json` foundation status = `complete`) |

### Input/Output Contract

**Input:**

| Source | Data | Format |
|--------|------|--------|
| `VISION.md` | Project goals, target users, brand preferences | Markdown |
| `design-system.css` | Existing design tokens (Tier 2 or updates) | CSS |
| Feature spec from `backlog.json` | Name, description, acceptance criteria, dependencies | JSON (see `architecture/schemas.md` Section 4) |
| `CLAUDE.md` | Tech stack, coding conventions, architecture rules | Markdown |
| TDR | Technology boundaries and patterns | Markdown |
| Component design spec | Layout, states, responsive behavior (if design phase precedes code) | Markdown |
| Existing codebase | Current source files for context | Source files |
| User preferences | Color direction, font preference, border radius, density (Tier 1 design only) | Conversational input |

**Output (Tier 1 -- Foundation Design):**

| Output | Description | Destination |
|--------|-------------|-------------|
| `design-system.css` | Complete CSS custom properties file with colors, typography, spacing, radii, shadows, breakpoints | Project root |
| Component inventory | List of anticipated UI components based on VISION.md features | `docs/component-inventory.md` |

**Output (Tier 2 -- Feature Design + Implementation):**

| Output | Description | Destination |
|--------|-------------|-------------|
| Component design spec | Layout, states, responsive behavior, accessibility requirements | Feature branch (e.g., `docs/design/feat-name.md`) |
| CSS additions | New tokens or component-specific styles added to `design-system.css` | `design-system.css` (appended) |
| Source code | Feature implementation files | Feature branch (`feat/<name>`) in worktree |
| Conventional commits | Atomic commits with `feat:`, `fix:`, `refactor:` prefixes | Git history |
| `Co-Authored-By` trailer | `Co-Authored-By: Claude <noreply@anthropic.com>` on every commit | Git commit messages |
| Branch push | Feature branch pushed to origin | Remote repository |
| Signal file | `.vibecrew/signals/builder-complete.signal` | `.vibecrew/signals/` |
| Phase update | Feature column advanced from `in-progress` to `testing` | `.vibecrew/backlog.json` (via `complete-phase.sh`) |

**Design system output structure:**

```css
:root {
  /* Colors -- HSL for easy manipulation */
  --color-primary-h: 217;
  --color-primary-s: 91%;
  --color-primary-l: 60%;
  --color-primary: hsl(var(--color-primary-h), var(--color-primary-s), var(--color-primary-l));
  --color-primary-foreground: hsl(0, 0%, 100%);
  /* ... full palette ... */

  /* Typography -- modular scale (1.25 ratio) */
  --font-size-xs: 0.75rem;
  --font-size-sm: 0.875rem;
  --font-size-base: 1rem;
  --font-size-lg: 1.125rem;
  --font-size-xl: 1.25rem;
  --font-size-2xl: 1.5rem;
  --font-size-3xl: 1.875rem;
  /* ... */

  /* Spacing -- 4px base unit */
  --spacing-1: 0.25rem;
  --spacing-2: 0.5rem;
  --spacing-3: 0.75rem;
  --spacing-4: 1rem;
  /* ... */
}
```

**Commit message format:**

```
feat(auth): add login form with email/password validation

- Create LoginForm component with controlled inputs
- Add form validation using zod schema
- Integrate with Supabase Auth signInWithPassword
- Add loading state and error handling

Acceptance: 2/4 criteria met (login form, validation)
Remaining: OAuth login, session persistence

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Verification Loop

The Builder's verification loop is the most critical in the system. Every code change is verified before the agent moves on.

| Step | Action | Retry Behavior |
|------|--------|----------------|
| 1. **Verify build passes** | After writing or modifying source files, run `npm run build` to confirm the project compiles without errors | Read the error output, identify the failing file and line, fix the issue, re-run build. Max 3 retries. If build still fails after 3 retries, commit current progress as WIP and signal the Orchestrator with the build error. |
| 2. **Verify lint passes** | After build succeeds, run `npm run lint` to confirm no linting violations were introduced | Read lint errors, apply auto-fixes where possible (`npm run lint -- --fix`), then manually fix remaining issues. Max 3 retries. |
| 3. **Verify design system tokens** | After writing CSS or styled components, grep for hardcoded color values (`#[0-9a-fA-F]{3,8}`, `rgb(`, `hsl(` not using variables) to confirm all styling uses CSS custom properties | Replace any hardcoded values with the appropriate `var(--*)` token. Max 2 retries. |
| 4. **Verify WCAG AA contrast** | After design system creation (Tier 1), verify that all foreground/background color combinations meet WCAG AA contrast ratio (4.5:1 for normal text, 3:1 for large text) | Adjust lightness values to achieve compliant contrast. Max 2 retries. |
| 4.5. **Visual verification (frontend only)** | After frontend changes (`.tsx`, `.jsx`, `.vue`, `.svelte`, `.css`, `.scss`): navigate to affected pages via Playwright MCP, check `browser_console_messages` for errors, screenshot at 1440px viewport. Optionally run `visual-verify.sh` + `browser_evaluate` for computed style extraction against design-system.css tokens. | Fix console errors immediately. Fix token violations if found. Max 2 visual-fix iterations. If Playwright unavailable, skip silently and log in signal payload. |
| 5. **Verify conventional commits** | Before committing, verify the commit message follows the conventional format (`type(scope): description`) | Reformat the commit message if it does not match. No retry needed -- fix inline. |
| 6. **Verify acceptance criteria progress** | After implementing a feature, check each acceptance criterion from the feature spec and report which are met vs. remaining | If criteria are unmet due to a bug, fix the implementation. If unmet due to scope (not yet implemented), include the status in the commit message. No retry -- informational. |

**Escalation:** If build or lint verification fails after maximum retries, the Builder:
1. Creates a WIP commit with current progress: `wip(feature-name): build/lint failing -- see error`
2. Creates a signal file with the error details: `.vibecrew/signals/builder-blocked.signal`
3. The Orchestrator notifies the developer of the blockage

### Context Window Budget

**Target: <45%** of the context window.

The Builder is the most context-intensive agent because it must hold the feature spec, design tokens, relevant existing code, TDR constraints, and its own generated code simultaneously. Strategies for staying under 45%:

- Read files on demand rather than loading the entire codebase upfront
- Use Context7 for API documentation instead of pasting docs
- Make atomic commits frequently to reduce the amount of uncommitted context
- If approaching 45%, commit current progress and signal for a new session to continue
- The `isolation: worktree` setting means the worktree contains only the relevant branch, reducing filesystem noise

### Safety Constraints

| Constraint | Enforcement |
|------------|-------------|
| **Must stay within TDR boundaries** | Agent prompt instructs: use only the technologies specified in the TDR. If a library not in the TDR is needed, stop and request a TDR amendment via the Orchestrator |
| **Must use design system tokens** | Agent prompt instructs: never hardcode colors, spacing, or typography. Always use CSS custom properties from `design-system.css`. Verified by the verification loop (Step 3). |
| **Must follow CLAUDE.md conventions** | Agent prompt instructs: follow all rules in CLAUDE.md (TypeScript strict, named exports, error boundaries, etc.) |
| **Must create feature branches** | Agent prompt instructs: never commit directly to `main`. Always work on `feat/<name>` branches |
| **Cannot force push** | Blocked by `protect-data.sh` PreToolUse hook and `settings.json` deny rules |
| **Cannot delete branches** | Blocked by `protect-data.sh` for `main`/`master` branches |
| **Cannot modify foundation artifacts during Tier 2** | Agent prompt instructs: do not modify `VISION.md`, TDR, or `CLAUDE.md` during feature work. `design-system.css` may be extended (new tokens added) but existing tokens must not be changed |
| **No destructive commands** | Blocked by `protect-data.sh` PreToolUse hook (`rm -rf`, `DROP TABLE`, `sudo`, etc.) |
| **WCAG AA compliance** | Agent prompt instructs: all color combinations must meet WCAG AA contrast ratio. Verified by the verification loop (Step 4). |
| **Isolated worktree** | `isolation: worktree` -- works in a separate git worktree to prevent filesystem conflicts with other agents or the main working tree |

### Status Reporting

1. **During work:** Makes frequent conventional commits that serve as progress markers. The Orchestrator can inspect `git log` on the feature branch to see progress.
2. **On design completion (Tier 1):** Reports completion by writing `design-system.css` to the project root. The Orchestrator detects this file's existence to advance the foundation status.
3. **On design completion (Tier 2):** Creates a signal file: `.vibecrew/signals/builder-design-complete.signal` with the component design spec summary.
4. **On code completion:** Runs the `complete-phase.sh` script to advance the feature from `in-progress` to `testing` in `backlog.json` and creates a signal file: `.vibecrew/signals/builder-complete.signal`. If frontend files were changed, the signal includes a `visual_verification` payload (screenshots taken, console errors found, token violations detected, or skipped reason).
5. **On PR/MR creation:** Creates a pull request (GitHub, via `gh pr create`) or merge request (GitLab, via `glab mr create`) with a structured description referencing the feature spec and acceptance criteria. The provider is auto-detected from the git remote.
6. **On blockage:** Creates `.vibecrew/signals/builder-blocked.signal` with error details if verification fails after max retries.

---

## 7. Verifier Agent

### Purpose

The Verifier is the combined **testing, quality validation, and scoring** agent in VibeCrew v1.0. It merges the responsibilities of the former Test Writer, Quality Check, and Performance Coach scoring logic into a single agent that handles the full verification pipeline:

- **Test writing (TDD-hybrid dual-track):**
  - **Spec-first track (business logic):** Write tests before code. For services, utilities, API routes, and data models, the Verifier produces test files based on the feature spec's acceptance criteria. These tests define the expected behavior and fail initially (red). The Builder then makes them pass (green).
  - **Impl-first track (UI components):** Write tests after code. For React/Vue/Svelte components, the Verifier reads the existing implementation and writes integration tests, visual regression tests, and accessibility tests after the components exist.

- **Quality validation:** Runs tests, builds, linting, and type checking. Reports pass/fail results. Validates that the codebase is in a shippable state.

- **Vibe Score calculation (v1.0):** During `/wrap`, calculates the session's Vibe Score (0-100) based on metrics from the session transcript, project state, and tool outputs. Produces a score breakdown with coaching suggestions. See `architecture/scoring.md` for the full scoring methodology and `architecture/schemas.md` Section 6 for the score file schema.

The Verifier uses Vitest for unit/integration tests, Playwright for end-to-end and visual regression tests, and axe-core for automated accessibility validation.

### YAML Frontmatter

```yaml
---
name: verifier
description: >
  Combined testing, quality validation, and scoring agent. TDD-hybrid testing
  with dual-track strategy (spec-first for business logic, impl-first for UI).
  Runs tests, build, lint, and type checks. Calculates Vibe Score during /wrap.
  Uses Vitest for unit/integration, Playwright for E2E, axe-core for
  accessibility, and Context7 for testing library documentation.
model: haiku
tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - mcp__context7__resolve-library-id
  - mcp__context7__get-library-docs
maxTurns: 60
---
```

### Trigger Conditions

| Condition | Details |
|-----------|---------|
| **Primary trigger (testing)** | Delegated by Orchestrator when a feature enters the `test` phase |
| **Spec-first trigger** | Delegated before the `code` phase for business logic features (TDD approach) |
| **`/check` trigger** | Invoked directly to run quality validation checks |
| **`/wrap` trigger** | Invoked as part of the wrap-up sequence to run final validation, calculate Vibe Score, and write session log |
| **`/run-backlog` trigger** | Automatically invoked for the `test` phase during backlog processing |
| **Orchestrator delegation** | Orchestrator sends tasks via Agent Teams for quality gates between phases |

### Input/Output Contract

**Input:**

| Source | Data | Format |
|--------|------|--------|
| Feature spec from `backlog.json` | Acceptance criteria (converted to test cases) | JSON (see `architecture/schemas.md` Section 4) |
| Source code | Implementation files to test (impl-first track) | Source files |
| `CLAUDE.md` | Testing conventions and framework configuration | Markdown |
| TDR | Test infrastructure decisions | Markdown |
| Existing test files | Current test coverage for context | Test source files |
| `package.json` | Available npm scripts (test, build, lint) | JSON |
| Session transcript (for `/wrap`) | Full conversation history with token usage per turn | `.claude/sessions/<session-id>.jsonl` |
| `.vibecrew/state.json` | What work was done this session (for scoring) | JSON (see `architecture/schemas.md` Section 3) |

**Output (Testing):**

| Output | Description | Destination |
|--------|-------------|-------------|
| Unit tests | Vitest test files for business logic | `src/**/__tests__/` or `src/**/*.test.ts` |
| Integration tests | Vitest + Testing Library tests for component behavior | Same as unit tests |
| E2E tests | Playwright test files for critical user flows | `e2e/` or `tests/e2e/` |
| Accessibility tests | axe-core integration within Playwright tests | Embedded in E2E tests |
| Test run results | Pass/fail output from running the test suite | stdout (reported to Orchestrator) |
| Signal file | `.vibecrew/signals/verifier-test-complete.signal` | `.vibecrew/signals/` |
| Phase update | Feature column advanced from `testing` to `review` | `.vibecrew/backlog.json` (via `complete-phase.sh`) |

**Output (Quality Check -- `/check`):**

| Output | Description | Destination |
|--------|-------------|-------------|
| Check results | Pass/fail for each check category | stdout (presented to developer or Orchestrator) |
| Exit status | Overall pass (0) or fail (non-zero) | Process exit code |

**Quality check output format:**

```
Quality Check Results
=====================
Tests:  PASS (47 passed, 0 failed)
Build:  PASS (compiled in 3.2s)
Lint:   WARN (2 warnings, 0 errors)
Types:  PASS (no type errors)
---------------------
Overall: PASS
```

**Output (Vibe Score -- `/wrap`):**

| Output | Description | Destination |
|--------|-------------|-------------|
| Vibe Score breakdown | Score (0-100) with itemized deductions and bonuses | `.vibecrew/scores/score-<date>-<NNN>.json` (see `architecture/schemas.md` Section 6) |
| Session log | Structured log of the session's activities, token usage, and score | `.vibecrew/sessions/session-<date>-<NNN>.json` (see `architecture/schemas.md` Section 5) |
| Coaching suggestions | Actionable improvement tips based on session analysis | Included in score breakdown `coaching` field |
| Session summary | Concise 3-5 line session recap | stdout (presented to developer) |
| WIP commit | If work is incomplete, creates a WIP commit | Git history |

**Vibe Score calculation** (see `architecture/schemas.md` Section 6 and `architecture/scoring.md` for the complete methodology):

| Metric | Condition | Points |
|--------|-----------|--------|
| **Base score** | Starting value | 100 |
| Prompt churn | User corrects/rephrases instructions 3+ times in sequence | -5 per sequence (max -20) |
| Tool loops | Same tool fails and retries 3+ times with identical arguments | -10 per loop (max -30) |
| Low cache utilization | `cache_read_input_tokens` < 30% of `input_tokens` | -15 |
| Context violation | Agent exceeded 60% context | -20 |
| No tests | Feature completed without test files | -10 |
| No feature spec | Development started without acceptance criteria | -5 |
| Missing phase | Any Tier 2 phase skipped | -3 per phase |
| **Bonus: all phases** | All 6 phases completed | +5 |
| **Bonus: high cache** | `cache_read_input_tokens` > 70% of `input_tokens` | +5 |
| **Bonus: full coverage** | Test coverage above 80% | +3 |
| **Bonus: clean session** | Zero warnings triggered | +2 |
| **Bonus: TDD discipline** | Commits with `TDD cycle:` trailer detected | +3 |
| **Bonus: E2E passing** | Playwright spec files exist and tests pass | +3 |
| **Bonus: a11y clean** | axe-core report with zero critical/serious violations | +2 |
| **Bonus: code review** | Review report exists in `.vibecrew/reviews/` | +2 |
| **Bonus: perf baselines** | k6 results exist in `.vibecrew/perf-tests/` | +2 |
| **Floor** | Minimum score | 0 |
| **Ceiling** | Maximum score | 100 |

**Test file structure:**

```typescript
// src/lib/auth/__tests__/login.test.ts
import { describe, it, expect } from 'vitest';
import { loginWithEmail } from '../login';

describe('loginWithEmail', () => {
  it('returns a session token on valid credentials', async () => {
    // Spec-first: this test was written before the implementation
    const result = await loginWithEmail('user@example.com', 'password123');
    expect(result.session).toBeDefined();
    expect(result.session.access_token).toBeTypeOf('string');
  });

  it('throws AuthError on invalid credentials', async () => {
    await expect(
      loginWithEmail('user@example.com', 'wrong-password')
    ).rejects.toThrow('Invalid login credentials');
  });
});
```

### Verification Loop

The Verifier is unique in that its primary function IS verification. But it still needs its own meta-verification loop to ensure its outputs are correct.

| Step | Action | Retry Behavior |
|------|--------|----------------|
| 1. **Verify tests execute** | After writing test files, run `npm test` (or `npx vitest run`) to confirm the test files are syntactically valid and the test runner picks them up | If tests fail to execute (import errors, syntax errors), read the error, fix the test file, re-run. Max 3 retries. |
| 2. **Verify test assertions are meaningful** | After tests pass, review each test to confirm it tests actual behavior (not just `expect(true).toBe(true)` or trivial assertions) | If a trivial assertion is found, rewrite the test with a meaningful assertion derived from the acceptance criteria. Max 2 retries. |
| 3. **Verify spec-first tests fail initially** | For spec-first (TDD) tests written before implementation, confirm they fail with the expected error (not an unexpected crash) | If the test crashes instead of failing predictably, adjust the test setup (mocks, imports) so the failure is clean. Max 2 retries. |
| 4. **Verify quality check completeness** | After running `/check`, confirm all four categories were executed (tests, build, lint, types). If a category was skipped (e.g., no test script in `package.json`), report it explicitly | If a category was skipped due to missing config, log a warning: "No test script found in package.json -- tests skipped." No retry -- informational. |
| 5. **Verify Vibe Score calculation** | After computing the Vibe Score, verify that `base_score + sum(deductions) + sum(bonuses)` equals the reported `score` (clamped to 0-100) | If arithmetic is incorrect, recalculate. Max 1 retry. This should never fail if the algorithm is correct. |
| 6. **Verify score file written** | After writing the score file to `.vibecrew/scores/`, re-read it to confirm valid JSON with all required fields per the schema | If the file is invalid, rewrite it. Max 1 retry. |

**Escalation:**
- **Test failures that indicate implementation bugs:** The Verifier creates a detailed bug report in the signal file, including the failing test name, expected vs. actual behavior, and the relevant source file. It does NOT fix source code -- only test code.
- **Quality check failures during `/wrap`:** If build or lint fails during wrap, the Verifier warns the developer but does not block the wrap. The warning includes the specific failures and a recommendation to fix them in the next session.

### Context Window Budget

**Target: <40%** of the context window.

The Verifier reads both feature specs (for acceptance criteria) and source code (for impl-first tests). Strategies:

- Read source files selectively -- only the files being tested, not the entire codebase
- Use Context7 for testing library API documentation (Vitest matchers, Playwright selectors)
- Write tests incrementally and run them after each batch to get feedback
- For Vibe Score calculation, use `Bash` + `jq` to extract metrics from the transcript rather than loading the full transcript into context
- Focus on the last 200 lines of the transcript for recent patterns

### Safety Constraints

| Constraint | Enforcement |
|------------|-------------|
| **Cannot modify source code** | Agent prompt instructs: write only test files when in testing mode. If a test reveals a bug, report it -- do not fix the source code |
| **Can write to specific locations** | Test files: `src/**/__tests__/`, `src/**/*.test.ts`, `e2e/`, `tests/`. Score files: `.vibecrew/scores/`. Session logs: `.vibecrew/sessions/`. Signal files: `.vibecrew/signals/`. |
| **Cannot modify project state directly** | Agent prompt instructs: use `complete-phase.sh` for phase transitions, never edit `state.json` or `backlog.json` by hand |
| **Test server isolation** | Agent prompt instructs: run tests against the dedicated test server (port 3001), not the developer's dev server (port 3000) |
| **No destructive commands** | Blocked by `protect-data.sh` PreToolUse hook |
| **Cannot skip tests** | Agent prompt instructs: never use `.skip` or `xit` to silence failing tests. Fix the test or report the issue |
| **Cannot install dependencies** | Agent prompt instructs: run `npm test`, `npm run build`, `npm run lint` only. Do not run `npm install` or modify `package.json` |
| **Constructive tone (scoring)** | Agent prompt instructs: frame all Vibe Score feedback as coaching, not criticism. Use "Next time, try X" not "You did X wrong" |
| **No CLAUDE.md mutations in v1.0** | Unlike the deferred standalone Performance Coach, the Verifier does NOT propose CLAUDE.md mutations. It only calculates the score and provides coaching suggestions in the score file's `coaching` field. CLAUDE.md mutation capability is deferred to v1.1 with the standalone Performance Coach. |

### Status Reporting

1. **During testing:** Runs the test suite after writing each batch of tests. Reports pass/fail counts.
2. **On test completion:** Creates a signal file `.vibecrew/signals/verifier-test-complete.signal` with test coverage summary. Advances the feature column from `testing` to `review` in `backlog.json`.
3. **On test failure (implementation bug):** Creates a detailed bug report in the signal file, including the failing test name, expected vs. actual behavior, and the relevant source file. The Orchestrator routes this back to the Builder.
4. **On `/check`:** Prints quality check results to stdout.
5. **On `/wrap`:** Runs final quality checks, calculates Vibe Score, writes score file to `.vibecrew/scores/`, writes session log to `.vibecrew/sessions/`, and presents a session summary to the developer.

---

## 8. Agent Interaction Map

The following diagram shows how agents interact during a typical feature development lifecycle in v1.0:

```
                        +-------------------+
                        |   DEVELOPER       |
                        |   (Human)         |
                        +--------+----------+
                                 |
                    Launches sessions, approves PRs,
                    responds to notifications
                                 |
                        +--------v----------+
                +-------| Session Startup   |-------+
                |       | (Haiku)           |       |
                |       +--------+----------+       |
                |                |                   |
                |       Routes to appropriate        |
                |       workflow                     |
                |                |                   |
     +----------v-----------+   |   +---------------v--------------+
     | Tier 1: Foundation   |   |   | Tier 2: Feature Dev          |
     |                      |   |   |                               |
     | +------------------+ |   |   | +---------------------------+ |
     | | Workflow          | |   |   | | Workflow                  | |
     | | Orchestrator      |<+---+   | | Orchestrator              | |
     | | (Opus)            | |       | | (Opus)                    | |
     | +--+--------+------+ |       | +--+------+------+----------+ |
     |    |        |        |       |    |      |      |            |
     |    |        |        |       |    |      |      |            |
     |    v        v        |       |    v      v      v            |
     | Stack    Builder     |       | Stack  Builder  Verifier      |
     | Scout    (Opus)      |       | Scout  (Opus)   (Haiku)       |
     | (Opus)   [worktree]  |       | (Opus) [wktree]               |
     | [wktree]             |       | [wktree]                      |
     |                      |       |                               |
     |  Creates:            |       |  Builder: design + code       |
     |  - VISION.md         |       |  Verifier: test + check +    |
     |  - design-system.css |       |            score + wrap       |
     |  - TDR               |       |                               |
     |  - roadmap.md        |       |  On /wrap:                    |
     |  - CLAUDE.md         |       |    Verifier calculates        |
     |                      |       |    Vibe Score                 |
     +----------------------+       +-------------------------------+
```

### Agent Teams Coordination Flow

```
Orchestrator
    |
    +--- TeamCreate("feat-001-user-auth", [builder, verifier])
    |
    +--- TaskCreate(assignee: builder, task: "design + implement feat-001")
    |         |
    |         +--- Builder works in worktree
    |         |    - Creates design spec
    |         |    - Implements feature
    |         |    - Runs verify loop (build + lint)
    |         |    - Commits + pushes
    |         |    - Writes signal: builder-complete.signal
    |         |
    +--- (Orchestrator reads signal, processes)
    |
    +--- TaskCreate(assignee: verifier, task: "test feat-001")
    |         |
    |         +--- Verifier works inline
    |         |    - Writes tests
    |         |    - Runs verify loop (tests pass)
    |         |    - Writes signal: verifier-test-complete.signal
    |         |
    +--- (Orchestrator reads signal, advances to review)
    |
    +--- SendMessage(to: developer, "feat-001 ready for review")
```

### Signal Flow Between Agents

```
Builder ----------signal----------> Orchestrator -------task-------> Verifier
    |                                     |                              |
    v                                     v                              v
builder-complete.signal           reads signal,                 verifier-test-complete.signal
(includes changed_files)          advances column,
                                  creates next task
                                       |
                              +--------+--------+
                              |                 |
                              v                 v
                         Code Reviewer    CI Healer (on error)
                              |                 |
                              v                 v
                    reviewer-complete      auto-recovery
                         .signal           attempt
                              |
                     +--------+--------+
                     |                 |
               approve/            request-
               comment-only        changes
                     |                 |
                     v                 v
                  advance         builder-review-
                  to docs         feedback.json
                                      |
                                      v
                                   Builder
                                   (fix cycle,
                                    max 2x)
```

### Handoff Sequence for a Complete Feature (v1.0)

```
1. Orchestrator       identifies next ready feature in backlog
2. Orchestrator       creates Agent Team with Builder + Verifier + Code Reviewer
3. Builder            creates component design spec (design phase) [worktree]
4. Builder            implements the feature (code phase) [worktree]
5. Builder            runs verify loop: build + lint pass
6. Builder            signals completion (includes changed_files list)
7. Orchestrator       processes signal, assigns Verifier
8. Verifier           writes and runs tests (test phase), targets changed_files
9. Verifier           runs verify loop: all tests pass
10. Verifier          signals completion
11. Orchestrator      assigns Code Reviewer for structured review
12. Code Reviewer     produces review report with verdict
13. Orchestrator      if REQUEST_CHANGES: routes findings → Builder → re-review (max 2 cycles)
14. Orchestrator      if builder-blocked: attempts auto-recovery via CI Healer before escalating
15. Builder           creates PR via gh pr create (GitHub) or MR via glab mr create (GitLab)
16. Developer         reviews and merges PR
17. Verifier          runs /wrap: final quality check, Vibe Score, session log
```

---

## 9. Design Decisions

### Why 5 Agents Instead of 9?

The v1.0 consolidation from 9 to 5 agents follows Boris Cherny's recommendation (Anthropic multi-agent best practices) to minimize coordination overhead while preserving the core benefits of specialization:

1. **Fewer handoffs, fewer failure points.** Every agent handoff is a potential coordination failure. Reducing from 9 to 5 agents eliminates 4 handoff points per feature. The design-to-code handoff (UI Designer -> Feature Developer) was the most fragile because the two agents needed to agree on a shared design spec format. Merging them into Builder eliminates this.

2. **Verification loops matter more than agent count.** Boris Cherny's #1 practice is "probably the most important thing" -- every agent must verify its own output. Adding verification loops to 5 agents is more impactful than having 9 agents without them. A Builder that verifies its build/lint is more reliable than a Feature Developer that hands off to a separate Quality Check.

3. **Preserved isolation where it matters.** The two cases where isolation is genuinely valuable -- research (Stack Scout) and parallel development (Builder) -- retain their isolation via `isolation: worktree`. The cases where isolation added complexity without benefit (separate UI Designer, separate Doc Generator) are consolidated.

4. **Context window efficiency.** A Builder that does both design and implementation avoids duplicating the context setup (reading VISION.md, design-system.css, CLAUDE.md, feature spec) that both UI Designer and Feature Developer needed independently. This saves an estimated 5,000-8,000 tokens per feature.

5. **Model cost remains optimized.** Haiku is used for Session Startup (the most frequent agent) and Verifier (focused quality checks). Opus handles the Workflow Orchestrator, Stack Scout, and Builder, providing stronger reasoning for coordination, research, and implementation. The consolidation reduces the number of agent sessions needed per feature.

### Why Merge UI Designer + Feature Developer into Builder?

The UI Designer and Feature Developer had significant overlap:

- Both read `VISION.md`, `design-system.css`, `CLAUDE.md`, and feature specs
- Both write to the filesystem
- Both use Context7 for library documentation
- The design spec produced by UI Designer was consumed exclusively by Feature Developer

Merging them eliminates the handoff friction and ensures the agent that designs the component also implements it, leading to higher fidelity between design intent and implementation.

The Builder retains both capabilities:
- **Tier 1:** Creates `design-system.css` (former UI Designer responsibility)
- **Tier 2 design phase:** Creates component design specs
- **Tier 2 code phase:** Implements the feature using the design spec it created

### Why Merge Test Writer + Quality Check + Scoring into Verifier?

The Test Writer, Quality Check, and Performance Coach scoring had a natural lifecycle alignment:

- **Test Writer** wrote tests and ran them (write + execute)
- **Quality Check** ran build/lint/types (execute only)
- **Performance Coach** calculated Vibe Score from session data (analyze + write score)

All three are verification activities that answer the question "Is this work correct?" Merging them into Verifier creates a single agent responsible for all quality assurance:

- **Testing:** Writes and runs tests (former Test Writer)
- **Quality gates:** Runs build/lint/types (former Quality Check). Note: the `quality-gate.sh` Stop hook now runs lightweight typecheck/lint/build checks on modified files after every assistant turn, providing fast feedback. The Verifier handles the full test suite and deep quality checks on demand via `/check` and `/wrap`.
- **Scoring:** Calculates Vibe Score during `/wrap` (former Performance Coach scoring)

The standalone Performance Coach is deferred to v1.1 because its most advanced features (persistent `memory: project`, cross-session trend analysis, CLAUDE.md mutation proposals) require more infrastructure. For v1.0, the Verifier calculates the score and provides coaching suggestions without persistent memory or mutation capability.

### Why `isolation: worktree` for Stack Scout and Builder?

Both agents benefit from filesystem isolation, but for different reasons:

- **Stack Scout:** The worktree prevents any accidental file modifications during research. Even though Stack Scout has `disallowedTools: Write, Edit`, the worktree provides defense-in-depth. If a `Bash` command accidentally creates a file (e.g., a redirected output), it happens in the worktree, not the main working tree.

- **Builder:** The worktree enables parallel feature development. Multiple Builder instances can work on different features simultaneously, each in their own worktree, without filesystem conflicts. This is essential for the `/run-backlog` workflow where multiple features may be in flight.

The Verifier does NOT use `isolation: worktree` because:
- Tests need to run against the actual project state (not a potentially stale worktree)
- Quality checks must validate the real build output
- Vibe Score calculation reads from `.vibecrew/` state files that must be current

### Why Agent Teams API Instead of Copy-Paste Commands?

The v0.9 design had the Orchestrator present copy-paste commands like:

```
Open a new terminal tab and run:
  claude --agent stack-scout --prompt "Research auth libraries for React"
```

This had three problems:
1. **Manual effort.** The developer had to manually open tabs and paste commands.
2. **No feedback loop.** The Orchestrator could not verify whether the agent was actually launched.
3. **No coordination.** Signal files were the only inter-agent communication mechanism.

The Agent Teams API (`TeamCreate`, `TaskCreate`, `SendMessage`) solves all three:
1. **Automated.** The Orchestrator programmatically creates teams and assigns tasks.
2. **Feedback.** `TaskCreate` returns confirmation that the agent started.
3. **Coordination.** `SendMessage` enables real-time inter-agent communication beyond signal files.

Signal files (`.vibecrew/signals/`) are retained as a persistence mechanism -- they survive agent crashes and provide an audit trail. But the primary coordination mechanism is now Agent Teams.

### Why Opus for Orchestrator, Stack Scout, and Builder?

The three agents with the highest reasoning demands run on Opus:

1. **Workflow Orchestrator (Opus).** The coordinator must reason about project state, agent handoffs, signal processing, and multi-step workflow routing. Opus provides stronger planning and strategic reasoning for these coordination decisions.
2. **Stack Scout (Opus).** Research and technology evaluation require deep comparative analysis across multiple sources. Opus produces higher-quality Technology Decision Records with more nuanced trade-off assessments.
3. **Builder (Opus).** Design and implementation benefit from Opus's superior code generation, architectural reasoning, and ability to maintain coherence across complex feature implementations.

### Why Haiku for Verifier?

The Verifier runs on Haiku because its workload is primarily mechanical:

1. **Structured validation.** Running tests, builds, lints, and type checks are deterministic operations. The agent reads pass/fail output and reports results -- this does not require deep reasoning.
2. **Vibe Score calculation is algorithmic.** The scoring formula is well-defined (base score + deductions + bonuses). Haiku can execute this arithmetic reliably.
3. **Cost efficiency.** The Verifier fires frequently (every phase transition, every `/check`, every `/wrap`). Using Haiku for these frequent invocations keeps costs proportional to value.
4. **v0.9 Quality Check was Haiku.** The original Quality Check agent ran on Haiku successfully for pass/fail validation. While the Verifier's scope expanded to include test writing and scoring, the core operations remain structured enough for Haiku.

### Why the Orchestrator Still Cannot Write Files?

The Orchestrator's `disallowedTools: Write, Edit` constraint is retained from v0.9:

1. **Prevents scope creep.** If the Orchestrator can write files, it will eventually be tempted to "just fix this small thing" instead of delegating to the appropriate specialist agent.
2. **Enforces delegation.** Every file mutation must go through a specialized agent (Builder for source, Verifier for tests/scores), ensuring that tool restrictions, safety constraints, and verification loops are properly applied.
3. **State mutations via scripts.** When the Orchestrator needs to update `backlog.json` or process signals, it uses `Bash` to run the shared scripts (`complete-phase.sh`, `claim-task.sh`, `update-backlog.sh`). This ensures state mutations go through the same validated code paths regardless of which agent triggers them.
4. **Agent Teams resolves the old contradiction.** In v0.9, `safety.md` listed `Write(.vibecrew/*)` as allowed for the Orchestrator while `agents.md` listed `disallowedTools: Write`. The v1.0 resolution is clear: Orchestrator cannot use `Write` or `Edit` tools directly, but CAN use `Bash` to run scripts that modify `.vibecrew/` state files. No contradiction.

### Why Were Performance Coach and Doc Generator Originally Deferred?

**Performance Coach:** The standalone agent's most valuable features required infrastructure: `memory: project` for persistent `MEMORY.md`, approval workflows for CLAUDE.md mutations, and historical score file reading. These have since been implemented with a 7-step guardrailed mutation flow, expertise accumulation (JSONL-based records), erosion trend analysis, and drift detection integration.

**Doc Generator:** Documentation generation was not critical-path for feature development. It has since been implemented as a Sonnet agent handling VitePress docs, CHANGELOG, release notes, architecture diagram freshness checks, and sidebar rebuilds.

### Code Simplifier Erosion Integration

After `/simplify` applies approved changes, the skill updates `.vibecrew/erosion/trends.json` to set `last_simplified` timestamps on simplified files. This resets their hot-file churn counter, preventing them from being flagged as hot files in future erosion checks.

### Verification Loop Design Rationale

The verification loop is the most important addition in the v1.0 revision, based on Boris Cherny's observation that it is "probably the most important thing" for reliable agent output. Key design principles:

1. **Every agent verifies.** Not just the Builder and Verifier -- Session Startup verifies its routing decision, the Orchestrator verifies state consistency, and Stack Scout verifies TDR completeness.

2. **Bounded retries.** Every verification step has a maximum retry count (typically 2-3). Unbounded retries can consume the entire context window. After max retries, the agent must escalate rather than loop.

3. **Escalation over silence.** When verification fails after retries, the agent signals the failure explicitly. A Builder that cannot get its build to pass after 3 retries commits WIP and signals the Orchestrator, rather than silently continuing with broken code.

4. **Verification is cheap.** Running `npm run build` costs shell execution time but zero model tokens (it is a Bash tool call). The verification overhead is negligible compared to the cost of unverified output propagating through the system.

5. **Fix before escalate.** Agents attempt self-repair before escalating. The Builder reads the build error, identifies the fix, and retries. Only after exhausting self-repair does it escalate. This is the verify-fix loop pattern.

---

## 10. System Reviewer Agent

### 10.1 Purpose

The System Reviewer is a meta-analysis agent that audits the VibeCrew plugin itself rather than user projects. It analyzes plugin internals, cross-project telemetry data, and the external Claude Code ecosystem to produce structured improvement proposals. It is the only agent that operates at the plugin level rather than the project level.

### 10.2 Specification

| Property | Value |
|----------|-------|
| **Model** | Opus |
| **Isolation** | Worktree |
| **maxTurns** | 50 |
| **Context Budget** | <40% |
| **Trigger** | `/system-review` command (run from VibeCrew repo) |
| **Read-only** | Yes — cannot Write, Edit, or create tasks |

### 10.3 Tools

**Allowed:** Read, Bash, Glob, Grep, WebSearch, WebFetch, mcp\_\_context7\_\_resolve-library-id, mcp\_\_context7\_\_get-library-docs

**Disallowed:** Write, Edit, TeamCreate, TaskCreate, SendMessage

### 10.4 Ten-Step Methodology

The agent executes a structured 10-step analysis divided into three parts:

**Part 1 — Internal Audit (Steps 1-5, ~15% context):**

1. **Plugin Inventory** — Run `collect-plugin-stats.sh`, establish baseline counts
2. **Model Routing Audit** — Read all agent frontmatter, evaluate Opus/Sonnet/Haiku assignments, estimate cost savings
3. **Context Budget Audit** — Check Budget/Escalation/Verification sections, flag misaligned maxTurns
4. **Pattern Consistency Audit** — Scan for structural deviations across agents, skills, and scripts
5. **Component Usage Audit** — Find unreferenced scripts, templates, and MCP servers

**Part 2 — Telemetry Analysis (Step 6, ~5% context):**

6. **Cross-Project Telemetry** — Read `telemetry/aggregate.json`, identify unused skills/agents, common deductions, cost outliers, MCP adoption gaps, recurring mutation patterns

**Part 3 — External Research (Steps 7-10, ~20% context):**

7. **Anthropic Documentation** — Search for new Claude Code features, model updates, best practices
8. **MCP Ecosystem** — Search for new MCP servers, cross-reference against registry
9. **Community & Competitor Patterns** — Research Cursor rules, Windsurf cascades, Aider conventions
10. **Innovation Brainstorm** — Synthesize all findings into forward-looking ideas

### 10.5 Output

The agent returns a single markdown report with five parts:

- **Executive Summary** (5-10 lines)
- **Part 1: Internal Audit** (5 subsections with tables)
- **Part 2: Cross-Project Insights** (telemetry analysis with anonymous aliases)
- **Part 3: External Research** (Anthropic, MCP, community, competitors)
- **Part 4: Innovation Ideas** (value/effort matrix)
- **Part 5: Prioritized Proposals** (top 10 with implementation sketches)
- **Appendix: Research Sources** (all queries and URLs)

### 10.6 Verification Loop

1. All sections present (no empty sections without "No findings" note)
2. Internal findings cite specific file paths
3. Telemetry findings reference anonymous project aliases only
4. External findings include source URLs
5. Every proposal has priority, effort estimate, and implementation sketch
6. No duplicate findings vs previous review (if provided)

### 10.7 Key Differences from Other Agents

| Aspect | Other Agents | System Reviewer |
|--------|-------------|-----------------|
| **Scope** | User project | VibeCrew plugin itself |
| **Pre-flight** | Checks `.vibecrew/state.json` | Checks `plugin.json` |
| **Data sources** | Project files | Plugin files + telemetry + web |
| **Output** | Project artifacts | Review report (JSON + markdown) |
| **Frequency** | Per-session/feature | Periodic (manual invocation) |
