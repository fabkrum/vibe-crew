# System Overview

> **Phase 2 Architecture** | Document 2.1 | February 2026
>
> High-level architecture of VibeCrew as a Claude Code plugin. Covers plugin structure, agent topology, workflow engine, safety layer, context window management, and slash command mapping. All design decisions reference research findings from Phase 1 documents 01, 02, and 08.

---

## Table of Contents

1. [Plugin Structure](#1-plugin-structure)
2. [Agent Topology](#2-agent-topology)
3. [Workflow Engine](#3-workflow-engine)
4. [Safety Layer](#4-safety-layer)
5. [Context Window Management](#5-context-window-management)
6. [Slash Commands](#6-slash-commands)
7. [Appendix A: Hook Configuration Summary](#appendix-a-hook-configuration-summary)
8. [Appendix B: Interrupt Protocol](#appendix-b-interrupt-protocol)

---

## 1. Plugin Structure

### 1.1 Overview

VibeCrew is distributed as a standard Claude Code plugin. It follows the canonical plugin layout established in the official Claude Code documentation: a `.claude-plugin/plugin.json` manifest at the root, with all component directories (`agents/`, `skills/`, `hooks/`, `scripts/`) at the plugin root level -- never nested inside `.claude-plugin/`.

The plugin is self-contained. All internal path references use the `${CLAUDE_PLUGIN_ROOT}` environment variable, which Claude Code sets to the absolute path of the plugin directory at runtime. This ensures correct resolution regardless of where the plugin is installed (marketplace cache, symlink, or direct placement).

### 1.2 Complete Directory Tree

```
claude-plugin-vibe-crew/                      # Plugin root
  .claude-plugin/
    plugin.json                             # Plugin manifest (entry point)
  agents/                                   # 14 specialized sub-agent definitions
    session-startup.md                      #   Haiku  -- environment check, routing
    workflow-orchestrator.md                 #   Opus   -- tier routing, Agent Teams coordination
    stack-scout.md                          #   Opus   -- read-only research, TDR output
    builder.md                              #   Opus   -- merged UI Designer + Feature Developer
    verifier.md                             #   Haiku  -- merged Test Writer + Quality Check
    performance-coach.md                    #   Opus   -- session analysis, CLAUDE.md mutations
    code-auditor.md                         #   Opus   -- code quality review, anti-pattern detection
    security-auditor.md                     #   Opus   -- security analysis, vulnerability scanning
    doc-generator.md                        #   Sonnet -- session logs, CHANGELOG, feature docs
    code-simplifier.md                      #   Opus   -- complexity reduction, refactoring
    ci-healer.md                            #   Opus   -- CI/CD failure diagnosis and repair
    opponent-processor.md                   #   Opus   -- adversarial review, edge case discovery
    system-reviewer.md                      #   Opus   -- plugin meta-analysis, telemetry, ecosystem research
  skills/                                   # 26 slash commands (SKILL.md per command)
    setup/
      SKILL.md                              #   /setup -- first-run installation wizard
    new-project/
      SKILL.md                              #   /new-project -- Tier 1 foundation workflow
    plan-features/
      SKILL.md                              #   /plan-features -- backlog planning session
    new-feature/
      SKILL.md                              #   /new-feature "name" -- Tier 2 feature cycle
    run-backlog/
      SKILL.md                              #   /run-backlog -- automated backlog processing
    idea/
      SKILL.md                              #   /idea "text" -- quick capture to backlog
    status/
      SKILL.md                              #   /status -- project state dashboard
    check/
      SKILL.md                              #   /check -- run tests, build, lint
    wrap/
      SKILL.md                              #   /wrap -- session end with coaching
    system-review/
      SKILL.md                              #   /system-review -- plugin meta-analysis
  hooks/
    hooks.json                              # Event-to-script routing table
  scripts/                                  # ~67 bash automation scripts
    session-startup.sh                      #   SessionStart: env check, state detection
    compact-reinject.sh                     #   SessionStart(compact): re-inject state after compaction
    phase-gate.sh                           #   PreToolUse(Write|Edit): foundation enforcement
    protect-data.sh                         #   PreToolUse(Bash): dangerous command blocker
    restrict-paths.sh                       #   PreToolUse(Write|Edit): sandbox path validation
    format-code.sh                          #   PostToolUse(Write|Edit): auto-format
    notify.sh                               #   Notification + PostToolUseFailure: OS alerts
    check-context.sh                        #   Stop: context usage warnings (60%/80%/90%)
  settings.json                             # Default permission rules (allow/deny lists)
  .mcp.json                                 # MCP server definitions (10 servers, 3 enabled by default)
  templates/
    architecture-diagrams/                  #   Mermaid diagram templates (5 .mmd.template files)
    project-registry.json.template          #   Empty project registry template
    system-review-report.json.template      #   System review report schema template
  telemetry/                                # Cross-project aggregated telemetry
    aggregate.json                          #   Anonymized performance data from all registered projects
  reviews/                                  # System review reports
    system-review-{timestamp}.md            #   Markdown review reports
    system-review-{timestamp}.json          #   Structured JSON review reports
  project-registry.json                     # Registered project paths + anonymous aliases
  LICENSE
  CHANGELOG.md

.vibecrew/                                    # Per-project runtime state (created by /setup)
  config.json                               #   Terminal preference, notification settings
  state.json                                #   Foundation status, active feature, sessions
  backlog.json                              #   Feature backlog with specs and status
  sessions/                                 #   Per-session metadata (JSON, gitignored)
  scores/                                   #   Vibe Score breakdowns (JSON)
  releases/                                 #   Release notes data (JSON)
  signals/                                  #   Ephemeral completion signals (gitignored)
  locks/                                    #   Advisory lock files (gitignored)
```

**Key differences from the pre-review design (9 agents):**

- `agents/` contains 13 files. The UI Designer and Feature Developer merged into `builder.md`. The Test Writer, Quality Check, and scoring responsibilities merged into `verifier.md`. New specialized agents added: Performance Coach, Code Auditor, Security Auditor, Code Simplifier, CI Healer, Opponent Processor, and Code Reviewer.
- `scripts/` includes `compact-reinject.sh` for context re-injection after compaction (see [Section 5.7](#57-context-re-injection-after-compaction)).

### 1.3 Plugin Manifest

The `plugin.json` manifest is the entry point that Claude Code reads to identify and load the plugin. All component path fields use relative paths starting with `./` and supplement default directory discovery -- they do not replace it.

```json
{
  "name": "vibe-crew",
  "version": "1.0.0",
  "description": "Autonomous vibe-coding operating system for Claude Code",
  "author": {
    "name": "Fabian Krumbholz",
    "url": "https://github.com/fabkrum"
  },
  "homepage": "https://docs.vibecrew.dev",
  "repository": "https://github.com/fabkrum/vibe-crew",
  "license": "MIT",
  "keywords": ["vibe-coding", "automation", "multi-agent", "sdlc"],
  "agents": "./agents/",
  "skills": "./skills/",
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### 1.4 Installation Methods

VibeCrew supports three installation methods at four scope levels:

```
Method 1: Marketplace install (recommended)
  claude plugin install vibe-crew@marketplace --scope project

Method 2: Direct placement (symlink for development)
  ln -s /path/to/claude-plugin-vibe-crew /path/to/project/claude-plugin-vibe-crew

Method 3: CLI install with explicit scope
  claude plugin install vibe-crew@marketplace --scope user    # all projects
  claude plugin install vibe-crew@marketplace --scope project # team-shared
  claude plugin install vibe-crew@marketplace --scope local   # gitignored
```

| Scope | Settings File | Use Case |
|-------|--------------|----------|
| `user` | `~/.claude/settings.json` | Personal -- active across all projects |
| `project` | `.claude/settings.json` | Team -- committed to version control |
| `local` | `.claude/settings.local.json` | Personal per-project -- gitignored |
| `managed` | `managed-settings.json` | Enterprise -- read-only, admin-controlled |

After installation, the user runs `/setup` to initialize the `.vibecrew/` runtime directory in the target project.

### 1.5 MCP Server Configuration

The `.mcp.json` file at the plugin root registers 10 bundled MCP servers. Three ship enabled by default (Context7, Chrome DevTools, Playwright); seven ship disabled and are auto-enabled when the TDR selects matching technologies via `scripts/sync-mcp-from-tdr.sh`. An additional 15 servers are defined in `templates/mcp-registry.json` and can be discovered and injected into `.mcp.json` based on TDR technology choices via `scripts/add-mcp-server.sh`.

| Server | Ships Enabled | Purpose |
|--------|:------------:|---------|
| Context7 | Yes | Documentation lookup (~1,500 tokens saved per query) |
| Chrome DevTools | Yes | Browser debugging and automation for research |
| Playwright | Yes | Interactive E2E browser debugging |
| Semgrep | No | Static security analysis (Security Auditor) |
| Sentry | No | Production error context (CI Healer) |
| Supabase | No | Database schema inspection (Stack Scout, Builder) |
| Stripe | No | Payment product management (Builder) |
| Vercel | No | Deployment management (Builder) |
| Figma | No | Design spec extraction (Builder) |
| Stitch | No | Google AI design platform (experimental) |

Servers are toggled via `scripts/enable-mcp-server.sh <name> [enable|disable]`. Remote servers (Sentry, Vercel, Figma) use `npx mcp-remote <url>` as a local proxy. All agents gracefully degrade when MCP servers are unavailable.

### 1.6 Path Reference Rule

Every path in hooks, scripts, and MCP configurations must use `${CLAUDE_PLUGIN_ROOT}` rather than absolute or relative paths. This variable is set by Claude Code at runtime to the plugin's installed location:

```json
{
  "command": "${CLAUDE_PLUGIN_ROOT}/scripts/phase-gate.sh"
}
```

This is critical because marketplace-installed plugins are cached to `~/.claude/plugins/cache/`, which is not predictable at authoring time.

---

## 2. Agent Topology

### 2.1 The Fourteen Agents

VibeCrew operates through fourteen specialized sub-agents. Each agent is a markdown file in `agents/` with YAML frontmatter that defines its model, tools, permissions, and behavioral constraints. Each runs in its own isolated context window -- the parent session's conversation history is never shared.

The topology expands the original 9-agent design to 14 agents, consolidating some roles (Builder = UI Designer + Feature Developer; Verifier = Test Writer + Quality Check) while adding specialized agents for code quality, security, simplification, CI healing, adversarial review, code review, and plugin-level meta-analysis.

```
+------------------------------------------------------------------+
|                     VIBECREW AGENT TOPOLOGY (v1.0)                  |
+------------------------------------------------------------------+
|                                                                   |
|  LIGHTWEIGHT (Haiku)         CORE (Opus)                          |
|  +-------------------+      +----------------------------+        |
|  | Session Startup   |----->| Workflow Orchestrator       |        |
|  | (every session)   |      | (routing, Agent Teams API) |        |
|  +-------------------+      +----------------------------+        |
|                                |                                  |
|  MECHANICAL (Haiku)            |  TeamCreate / TaskCreate          |
|  +-------------------+        |  SendMessage                     |
|  | Verifier          |        |                                  |
|  | (test + check)    |        |                                  |
|  +-------------------+        |                                  |
|                      +---------+----+----+----+----+----+        |
|                      |              |    |    |    |    |         |
|                      v              v    v    v    v    v         |
|              +---------------+  +--+--+ +--+ +--+ +--+ +------+  |
|              | Stack Scout   |  |Build| |CA| |SA| |CS| | CI   |  |
|              | (research,    |  |(des+| |  | |  | |  | |Healer|  |
|              |  TDR output)  |  |code)| |  | |  | |  | |      |  |
|              | Opus          |  |Opus | |Op| |Op| |Op| |Opus  |  |
|              +---------------+  +-----+ +--+ +--+ +--+ +------+  |
|                                                                   |
|  +----------------------------+  +----------------------------+   |
|  | Performance Coach (Opus)    |  | Doc Generator (Sonnet)     |  |
|  | (project memory, scoring,   |  | (CHANGELOG, feature docs,  |  |
|  |  CLAUDE.md mutations)       |  |  release notes)             |  |
|  +----------------------------+  +----------------------------+   |
|                                                                   |
|  +----------------------------+                                   |
|  | Opponent Processor (Opus)   |                                  |
|  | (adversarial review,        |                                  |
|  |  edge case discovery)       |                                  |
|  +----------------------------+                                   |
|                                                                   |
+------------------------------------------------------------------+
|  CA = Code Auditor, SA = Security Auditor, CS = Code Simplifier  |
+------------------------------------------------------------------+
```

### 2.2 Agent Specifications

| # | Agent | Model | Isolation | Memory | Primary Role |
|---|-------|-------|-----------|--------|-------------|
| 1 | Session Startup | Haiku | Inline | None | Environment check, state detection, routing |
| 2 | Workflow Orchestrator | Opus | Inline | None | Routes between Tier 1/Tier 2, coordinates via Agent Teams API |
| 3 | Stack Scout | Opus | Worktree | None | Read-only research agent producing TDRs |
| 4 | Builder | Opus | Worktree | None | Merged UI Designer + Feature Developer: design system, component design, feature implementation |
| 5 | Verifier | Haiku | Fork | None | Merged Test Writer + Quality Check: tests, build, lint |
| 6 | Performance Coach | Opus | Fork | Project | Session analysis, Vibe Score, CLAUDE.md mutations |
| 7 | Code Auditor | Opus | Fork | None | Code quality review, anti-pattern detection |
| 8 | Security Auditor | Opus | Fork | None | Security analysis, vulnerability scanning |
| 9 | Doc Generator | Sonnet | Fork | None | Session logs, CHANGELOG, feature docs, release notes |
| 10 | Code Simplifier | Opus | Fork | None | Complexity reduction, refactoring proposals |
| 11 | CI Healer | Opus | Fork | None | CI/CD failure diagnosis and automated repair |
| 12 | Opponent Processor | Opus | Fork | None | Adversarial review, edge case discovery |
| 13 | Code Reviewer | Opus | Worktree | None | Code review against feature spec, TDR compliance, conventions |

### 2.3 Agent Merging Rationale

**Builder = UI Designer + Feature Developer.** The original design separated design from code, but in practice the design phase produces CSS custom properties and component specs that flow directly into implementation. Running both in one agent eliminates the handoff cost (reading design output, re-establishing context) and reduces the number of worktrees. The Builder handles both `design-system.css` creation during Tier 1 and component implementation during Tier 2.

**Verifier = Test Writer + Quality Check.** The original design had Test Writer (Sonnet) authoring tests and Quality Check (Haiku) running them. Separating authoring from running created unnecessary coordination: the runner needed to report failures back to the author. Merging them into a single Verifier agent means test authoring, execution, lint, and build happen in one context with full access to failure details. The Verifier uses Haiku because test execution and lint/build runs are mechanical tasks that do not require deep reasoning -- they follow deterministic patterns of running commands and reporting pass/fail results.

**Performance Coach and Doc Generator included in v1.0.** Both are now part of the v1.0 agent lineup. The Performance Coach (Opus) handles Vibe Score calculation and CLAUDE.md mutation proposals with persistent cross-session memory. The Doc Generator (Sonnet) handles session logs, CHANGELOG, and feature documentation -- documentation generation is a structured writing task well-suited to Sonnet's capabilities.

**New specialized agents.** Seven additional agents extend the system's quality and resilience capabilities: Code Auditor and Security Auditor (both Opus) provide deep review capabilities, Code Simplifier (Opus) proposes complexity reductions, CI Healer (Opus) diagnoses and repairs CI/CD failures, Opponent Processor (Opus) performs adversarial review to surface edge cases and failure modes, and Code Reviewer (Opus) provides automated code review against the feature spec, TDR compliance, and project conventions.

### 2.4 Tool Permissions Per Agent

Each agent receives only the tools it needs. Read-only agents use `disallowedTools` to explicitly block write access, while write agents receive explicit `tools` allowlists.

| Agent | Allowed Tools | Disallowed Tools |
|-------|--------------|-----------------|
| Session Startup | Read, Glob, Grep, Bash | Write, Edit, WebSearch |
| Workflow Orchestrator | Read, Write, Edit, Glob, Grep, Bash, TeamCreate, TaskCreate, SendMessage | -- |
| Stack Scout | Read, Glob, Grep, WebSearch, WebFetch, Context7, Chrome DevTools | Write, Edit |
| Builder | Read, Write, Edit, Glob, Grep, Bash, Context7 | -- |
| Verifier | Read, Write, Edit, Glob, Grep, Bash | -- |

### 2.5 Communication: Agent Teams API + `.vibecrew/`

VibeCrew v1.0 uses the **Agent Teams API** (released February 5, 2026) for agent coordination. The Orchestrator creates teams and assigns tasks programmatically -- the developer no longer needs to manually open terminal tabs and paste launch commands.

```
+-------------------------------------------------------------------+
|                    AGENT TEAMS COORDINATION                        |
+-------------------------------------------------------------------+
|                                                                    |
|  Workflow Orchestrator                                              |
|  (primary session)                                                 |
|       |                                                            |
|       |  TeamCreate("feat-001-auth")                               |
|       |                                                            |
|       +---> TaskCreate(agent: "stack-scout",                       |
|       |         task: "Research auth libraries for React/Supabase") |
|       |                                                            |
|       +---> TaskCreate(agent: "builder",                           |
|       |         task: "Implement login form and OAuth flow")       |
|       |                                                            |
|       +---> TaskCreate(agent: "verifier",                          |
|                 task: "Write and run tests for auth feature")      |
|                                                                    |
|  Agents coordinate via SendMessage and .vibecrew/signals/ payloads   |
|                                                                    |
+-------------------------------------------------------------------+
|                                                                    |
|  +---------------+   +---------------+   +---------------+         |
|  | Stack Scout   |   | Builder       |   | Verifier      |         |
|  | (worktree)    |   | (worktree)    |   | (fork)        |         |
|  +-------+-------+   +-------+-------+   +-------+-------+         |
|          |                    |                    |                 |
|          |  write             |  write             |  write         |
|          v                    v                    v                 |
|  +--------------------------------------------------------------+  |
|  |                    .vibecrew/ DIRECTORY                         |  |
|  |                                                              |  |
|  |  state.json        -- foundation status, active feature      |  |
|  |  backlog.json      -- feature queue with specs & status      |  |
|  |  signals/          -- ephemeral completion notifications     |  |
|  |  locks/            -- advisory locks for concurrent writes   |  |
|  |  sessions/         -- per-session metadata                   |  |
|  |  scores/           -- Vibe Score breakdowns                  |  |
|  +--------------------------------------------------------------+  |
|          ^                    ^                    ^                 |
|          |  read              |  read              |  read          |
|          |                    |                    |                 |
|  +-------+-------+   +-------+-------+   +-------+-------+         |
|  | Orchestrator   |   | Orchestrator   |   | Orchestrator   |       |
|  | (reads signals)|   | (reads state)  |   | (reads scores) |       |
|  +---------------+   +---------------+   +---------------+         |
|                                                                    |
+-------------------------------------------------------------------+
```

**Communication patterns:**

| Mechanism | Purpose | Persistence | Git-Tracked |
|-----------|---------|-------------|-------------|
| Agent Teams API | Task assignment, inter-agent messaging | Session-scoped | No |
| `state.json` | Project-wide state (see [schemas.md](schemas.md#3-statejson)) | Persistent | Yes |
| `backlog.json` | Feature queue (see [schemas.md](schemas.md#4-backlogjson)) | Persistent | Yes |
| `signals/` | Lightweight event payloads (see [schemas.md](schemas.md#7-signal-files)) | Ephemeral | No |
| `locks/` | Advisory locks (see [schemas.md](schemas.md#8-lock-files)) | Ephemeral | No |
| `sessions/` | Per-session metadata for crash detection | Ephemeral | No |
| `scores/` | Vibe Score history per session | Persistent | Optional |
| Git worktrees | Agent isolation (see [Section 3.6](#36-worktree-based-agent-isolation)) | Persistent | Yes |
| Commit messages | Structured metadata via conventional commits | Persistent | Yes |

**Agent Teams API vs. manual tabs.** The pre-review design had the Orchestrator presenting copy-paste commands for the developer to launch agents in separate terminal tabs. With Agent Teams API, the Orchestrator calls `TeamCreate` to define a team, `TaskCreate` to assign tasks to specific agents, and `SendMessage` to coordinate progress. The developer remains hands-off during feature execution. Signal files in `.vibecrew/signals/` are still used as data payloads for structured results (test reports, TDR summaries) -- the API handles routing while the filesystem handles data.

### 2.6 Agent Lifecycle

Every agent session follows a five-phase lifecycle. With Agent Teams API, steps 1 and 5 are managed by the Orchestrator rather than the developer.

```
1. LAUNCH          Orchestrator calls TaskCreate with agent type and task
       |           Agent starts in its own context window
       v
2. INITIALIZE      Agent reads .vibecrew/state.json and backlog.json
       |           Agent verifies git status (clean tree, correct worktree)
       v           Agent registers itself in .vibecrew/sessions/
3. EXECUTE         Agent performs its specialized task
       |           Hooks enforce rules (phase gate, sandbox, safety)
       v           Notifications fire on block/complete/error
4. HANDOFF         Agent writes results to filesystem
       |           Agent updates .vibecrew/state.json and backlog.json
       v           Agent creates signal file and sends SendMessage
5. TERMINATE       Orchestrator receives completion signal
                   /wrap runs Verifier for scoring (Vibe Score calculated)
                   Session metadata recorded
```

### 2.7 Model Selection Rationale

Three models are used across the thirteen agents, following an **Opus-first strategy**: Opus is the default for any task requiring reasoning, analysis, or creative output. Haiku handles mechanical tasks, and Sonnet handles structured documentation writing.

**Opus** (10 agents: Workflow Orchestrator, Stack Scout, Builder, Performance Coach, Code Auditor, Security Auditor, Code Simplifier, CI Healer, Opponent Processor, Code Reviewer) -- Selected as the primary model for all tasks requiring deep reasoning, architectural judgment, creative design, security analysis, or adversarial thinking. Opus provides the highest quality output for research (Stack Scout), design and code generation (Builder), project coordination (Workflow Orchestrator), code and security review (Code Auditor, Security Auditor, Code Reviewer), CI failure diagnosis (CI Healer), complexity reduction (Code Simplifier), adversarial review (Opponent Processor), and self-improvement analysis (Performance Coach).

**Haiku** (2 agents: Session Startup, Verifier) -- Selected for high-frequency, mechanical tasks. Session Startup runs at the beginning of every session and performs simple routing logic. The Verifier runs tests, build, and lint -- deterministic operations that follow a predictable pattern of executing commands and reporting pass/fail results. Haiku is approximately 60x cheaper per token than Opus, making it cost-effective for tasks that do not benefit from deeper reasoning.

**Sonnet** (1 agent: Doc Generator) -- Selected for structured documentation writing. Generating session logs, CHANGELOG entries, feature documentation, and release notes is a well-defined writing task that benefits from Sonnet's strong language capabilities without requiring the full reasoning depth of Opus. Sonnet is approximately 15x cheaper per token than Opus, providing a good balance of quality and cost for documentation tasks.

### 2.8 Persistent Memory (Performance Coach)

The Performance Coach is the only agent with persistent cross-session memory, configured via the `memory: project` frontmatter field. This stores learnings in `.claude/agent-memory/performance-coach/MEMORY.md`, which is automatically injected into the agent's system prompt on subsequent invocations.

This memory enables the self-improvement loop: the Performance Coach identifies anti-patterns across sessions (e.g., "prompt churn on API calls" or "repeated lint failures on import ordering") and proposes permanent CLAUDE.md rule mutations to prevent recurrence. Running on Opus ensures the highest quality analysis for these high-impact, cross-session improvement decisions.

---

## 3. Workflow Engine

### 3.1 Two-Tier System

VibeCrew enforces a two-tier workflow that separates project foundation from feature development. This is the architectural core of the system -- Tier 1 must complete before Tier 2 can begin, enforced deterministically by the phase gate hook.

```
+==================================================================+
||                      VIBECREW WORKFLOW ENGINE                     ||
+==================================================================+
||                                                                ||
||  TIER 1: PROJECT FOUNDATION (Sequential, One-Time)             ||
||  +---------+  +----------+  +-----+  +---------+  +----------+||
||  | VISION  |->| Design   |->| TDR |->| Roadmap |->| CLAUDE   |||
||  | .md     |  | System   |  |     |  |         |  | .md      |||
||  +---------+  +----------+  +-----+  +---------+  +----------+||
||       |            |           |          |             |       ||
||       v            v           v          v             v       ||
||  [Phase Gate: foundation.complete == true required]            ||
||                                                                ||
||  TIER 2: FEATURE DEVELOPMENT (Iterative, Per-Feature)          ||
||  +------+ +--------+ +------+ +------+ +--------+ +------+   ||
||  | Plan |>| Design |>| Code |>| Test |>| Review |>| Docs |   ||
||  +------+ +--------+ +------+ +------+ +--------+ +------+   ||
||       ^                                                |       ||
||       |              (next feature)                    |       ||
||       +------------------------------------------------+       ||
||                                                                ||
+==================================================================+
```

### 3.2 Tier 1: Project Foundation

Tier 1 is a sequential, one-time process that creates the six foundation artifacts before any source code is written. The phase gate hook (`phase-gate.sh`) reads `.vibecrew/state.json` and blocks all writes to source code paths (`src/`, `app/`, `lib/`, `components/`, `pages/`, `features/`) until `foundation.complete` is `true`.

> **Schema reference:** The `foundation.complete` field is defined in [schemas.md, Section 3: state.json](schemas.md#3-statejson). The phase gate checks this boolean -- not a string status value.

**Foundation artifacts (produced in order):**

| Step | Artifact | Agent | Purpose |
|------|----------|-------|---------|
| 1 | `VISION.md` | Workflow Orchestrator | Project identity, goals, audience, success metrics |
| 2 | `design-system.css` | Builder | CSS custom properties for colors, typography, spacing |
| 3 | TDR (Technology Decision Record) | Stack Scout | Chosen tech stack with competitive analysis |
| 4 | `docs/roadmap.md` | Workflow Orchestrator | Prioritized feature list with dependencies |
| 5 | Architecture Diagrams (5 `.mmd` files) | Workflow Orchestrator | Mermaid diagrams: system topology, DB schema, state flows, API sequences, component tree |
| 6 | `CLAUDE.md` | Workflow Orchestrator | Project rules, conventions, commands, stack reference |

**Why sequential:** Each artifact depends on the previous one. The design system requires the vision (audience, tone). The TDR requires the design system (framework compatibility). The roadmap requires the TDR (what is technically feasible). Architecture diagrams require VISION.md + TDR + roadmap (they distill all three into compact visual form). CLAUDE.md requires all of the above.

#### Mermaid Architecture Diagram System

The 5th foundation artifact is a set of Mermaid diagrams stored in `.vibecrew/architecture/`. They provide agents with a compact visual architecture summary (~250-600 total tokens for all 5 files) compared to re-reading the full TDR (2,000-5,000 tokens).

| File | Syntax | Content |
|------|--------|---------|
| `system.mmd` | `flowchart TD` | Infrastructure topology with service boundaries |
| `schema.mmd` | `erDiagram` | Entity-relationship diagram from VISION.md domain |
| `state-flows.mmd` | `stateDiagram-v2` | Auth states and primary user journeys |
| `api-sequences.mmd` | `sequenceDiagram` | Request/response patterns for auth and CRUD |
| `component-tree.mmd` | `flowchart TD` | Component hierarchy with data flow (props ↓, events ↑) |

`component-tree.mmd` is unique: it starts as a skeleton in Tier 1 and grows during Tier 2 as the Builder adds components. All diagrams are checked for freshness by the Doc Generator during `/wrap` and updated when stale. See [diagrams.md](diagrams.md) for the full design doc.

**Phase gate enforcement:**

```
Agent attempts Write to src/app/page.tsx
    |
    v
PreToolUse hook fires --> phase-gate.sh
    |
    v
Script reads .vibecrew/state.json
    |
    +--> foundation.complete == true  --> EXIT 0 (allow)
    |
    +--> foundation.complete == false --> JSON deny response:
         "Phase Gate: Source code writes blocked.
          Foundation incomplete. Run /new-project first."
```

### 3.3 Tier 2: Feature Development

Tier 2 is an iterative 6-phase cycle applied to each feature in the backlog. Phases run sequentially per feature but multiple features can be in different phases simultaneously across different agent worktrees.

**The 6 phases (agent mapping):**

| Phase | Agent | Inputs | Outputs |
|-------|-------|--------|---------|
| **Plan** | Workflow Orchestrator | User idea, roadmap | Feature spec with acceptance criteria in `backlog.json` |
| **Design** | Builder | Feature spec, design-system.css | Component mockups, layout specifications |
| **Code** | Builder | Feature spec, design output, TDR | Implementation in worktree |
| **Test** | Verifier | Implementation, acceptance criteria | Unit tests, integration tests, accessibility tests |
| **Review** | Code Reviewer | Implementation, feature spec, TDR | Review report with findings (critical/warning/info) |
| **Docs** | Doc Generator | All phase outputs | Feature documentation, CHANGELOG entry |

The Builder handles both the Design and Code phases. The Verifier handles Test. The Code Reviewer handles Review (optional in manual workflow, automatic in `/run-backlog`). The Doc Generator handles the Docs phase.

### 3.4 Feature State Machine

Every feature in `backlog.json` progresses through a seven-state lifecycle. Transitions are triggered by agent actions and recorded atomically using advisory locks.

> **Schema reference:** The feature object schema and Kanban column definitions are in [schemas.md, Section 4: backlog.json](schemas.md#4-backlogjson).

```
    idea --> planning --> planned --> in-progress --> testing --> review --> done
     |          |           |           |              |          |
     |          |           |           |              |          |
   /idea   /plan-      spec done    agent         tests pass   PR merged
           features    + deps met   completes     + PR created  by user
                       + claimed    coding
                       by agent
```

| State | Description | Transition Trigger | Next State |
|-------|-------------|--------------------|------------|
| `idea` | Raw concept captured via `/idea` | User runs `/plan-features` or drags in dashboard | `planning` |
| `planning` | Actively being planned, spec in progress | Orchestrator writes spec, acceptance criteria defined | `planned` |
| `planned` | Spec done, ready to build, all dependencies in `done` state | Agent claims via lock | `in-progress` |
| `in-progress` | Agent is actively implementing (design or code phase) | Builder completes coding | `testing` |
| `testing` | Code complete, tests being written and run | Verifier passes all tests, PR created | `review` |
| `review` | Pull request open, awaiting human merge | User merges PR | `done` |
| `done` | Merged to main, feature shipped | (terminal state) | -- |

**Dependency resolution:** A feature cannot transition from `planning` to `planned` until all features listed in its dependency relationships have reached the `done` state. This prevents agents from starting work on features that require infrastructure not yet available.

### 3.5 Backlog Reference

The `backlog.json` schema -- including feature object fields, Kanban column definitions, and WIP limits -- is defined in [schemas.md, Section 4: backlog.json](schemas.md#4-backlogjson). All agents read and write this file using the canonical schema. Below is a summary of key fields for workflow context:

| Field | Purpose |
|-------|---------|
| `features[].column` | Current Kanban state (`idea`, `planning`, `planned`, `in-progress`, `testing`, `review`, `done`) |
| `features[].priority` | Lower number = higher priority. Used by `/run-backlog` to select next task |
| `features[].spec.acceptance_criteria` | Requirements that the Verifier validates against |
| `features[].worktree` | Git worktree path when a Builder agent is actively working on the feature |
| `features[].phases_completed` | Tracks which Tier 2 phases have been completed |
| `columns[].wip_limit` | Maximum features allowed in each column simultaneously |

### 3.6 Worktree-Based Agent Isolation

VibeCrew uses **git worktrees** for agent isolation instead of feature branches alone. Boris Cherny (Anthropic) identifies worktrees as "the single biggest productivity unlock" for multi-agent development. Each agent that writes code operates in its own worktree, providing true filesystem isolation without the overhead of branch switching.

```
PROJECT ROOT (./)                   WORKTREES (.claude/worktrees/)
+------------------+                +----------------------------------+
| main branch      |                | builder-feat-001/                |
| (clean, stable)  |                |   feat/user-authentication       |
|                  |                |   (Builder writes here)          |
| .vibecrew/         |                +----------------------------------+
|   state.json     |<--- shared     | scout-tdr-001/                   |
|   backlog.json   |     state      |   research/tdr-draft             |
|   signals/       |                |   (Stack Scout writes here)      |
+------------------+                +----------------------------------+
                                    | builder-feat-002/                |
                                    |   feat/dashboard-widgets         |
                                    |   (parallel Builder)             |
                                    +----------------------------------+
```

**Why worktrees, not branches:**

| Concern | Branch-Only | Worktree |
|---------|-------------|----------|
| Filesystem isolation | No -- switching branches changes all files | Yes -- each worktree has its own working directory |
| Parallel agents | Requires `git stash` or careful branch switching | Agents run simultaneously in separate directories |
| Merge conflicts | Frequent if agents modify overlapping files | Isolated until explicit merge |
| `.vibecrew/` state | Must be branch-independent (complex) | Naturally shared via the main working directory |
| Agent recovery | Stash/branch state is fragile | Worktree can be deleted without affecting other work |

**Worktree lifecycle:**

```
1. CREATE          Orchestrator assigns task to Builder
                   Builder creates worktree:
                     git worktree add .claude/worktrees/builder-feat-001 \
                       -b feat/user-authentication
       |
       v
2. WORK            Builder operates entirely within the worktree
                   All file reads/writes scoped to worktree path
                   .vibecrew/ accessed from main working directory
       |
       v
3. COMMIT          Builder commits to the feature branch within the worktree
                   Conventional commit messages
       |
       v
4. MERGE-BACK      Orchestrator merges the feature branch to main
                   Or creates a PR for user review
       |
       v
5. CLEANUP         Worktree removed:
                     git worktree remove .claude/worktrees/builder-feat-001
                   Feature branch kept until PR is merged
```

**Agents that use worktrees:**

| Agent | Worktree Pattern | Purpose |
|-------|-----------------|---------|
| Stack Scout | `.claude/worktrees/scout-<task>` | Isolates research output; TDR written without touching main tree |
| Builder | `.claude/worktrees/builder-<feature-id>` | Isolates design and code output per feature |

**Agents that do NOT use worktrees:**

| Agent | Isolation | Reason |
|-------|-----------|--------|
| Session Startup | Inline | Reads state only, no file writes |
| Workflow Orchestrator | Inline | Coordinates via API, writes to `.vibecrew/` only |
| Verifier | Fork | Runs tests against existing worktree content, writes test files alongside implementation |

### 3.7 Task Processing Flow (Agent Teams API)

When a feature moves through its lifecycle, the Workflow Orchestrator coordinates handoffs between agents using the Agent Teams API. The developer no longer needs to manually open tabs or paste commands.

```
+------------------------------------------------------------------+
|                   TASK PROCESSING FLOW                            |
+------------------------------------------------------------------+
|                                                                  |
|  /run-backlog or manual /new-feature                             |
|       |                                                          |
|       v                                                          |
|  1. Read backlog.json                                            |
|  2. Find highest-priority "planned" task (deps satisfied)        |
|  3. No tasks? --> Exit with summary                              |
|  4. Claim task (acquire lock, set column = "in-progress")        |
|  5. TeamCreate("feat-<id>-<name>")                               |
|  6. Determine agent for current phase:                           |
|       plan   --> Workflow Orchestrator (self)                     |
|       design --> Builder (via TaskCreate)                         |
|       code   --> Builder (via TaskCreate)                         |
|       test   --> Verifier (via TaskCreate)                        |
|       docs   --> Workflow Orchestrator (self, inline)             |
|  7. Agent creates worktree (if Builder/Scout)                    |
|  8. Agent executes phase                                         |
|  9. Agent signals completion (signal file + SendMessage)         |
| 10. Orchestrator reads signal, advances to next phase            |
| 11. Repeat from step 6 until all phases complete                 |
| 12. Feature column = "review", PR created from worktree          |
| 13. User merges PR --> column = "done"                           |
| 14. Worktree cleaned up                                          |
| 15. Return to step 1 for next feature                            |
|                                                                  |
+------------------------------------------------------------------+
```

### 3.8 Parallel Execution Model

With Agent Teams API and worktrees, multiple features can be worked on simultaneously without developer intervention. Each feature gets its own worktree, and agents operate in isolation.

```
Orchestrator (primary session)
+---------------------------------------------------+
| TeamCreate("feat-003-dashboard")                  |
| TeamCreate("feat-004-settings")                   |
+---------------------------------------------------+
         |                           |
         v                           v
+------------------+        +------------------+
| Builder          |        | Builder          |
| worktree:        |        | worktree:        |
|  builder-feat-003|        |  builder-feat-004|
| branch:          |        | branch:          |
|  feat/dashboard  |        |  feat/settings   |
+------------------+        +------------------+
         |                           |
         v                           v
+------------------+        +------------------+
| Verifier         |        | Verifier         |
| (tests feat-003) |        | (tests feat-004) |
+------------------+        +------------------+
```

The default concurrency budget is 3 parallel agents (configurable in `config.json` -- see [schemas.md, Section 2: config.json](schemas.md#2-configjson)):

| Slot | Agent | Purpose |
|------|-------|---------|
| Slot 1 | Builder | Primary implementation work (worktree) |
| Slot 2 | Verifier | Tests for the previous feature while next is being coded |
| Slot 3 | Stack Scout / Builder | On-demand research or parallel feature work |

The Orchestrator itself does not count against the concurrency budget because it runs in the primary session.

---

## 4. Safety Layer

### 4.1 Design Philosophy

Safety in VibeCrew follows one principle: **enforce rules via deterministic bash scripts, not by asking the model to remember them.** Hook scripts run as external processes at zero token cost. They cannot be forgotten, hallucinated away, or ignored due to context exhaustion.

The safety layer uses dual enforcement: declarative deny rules in `settings.json` for simple pattern blocking, and PreToolUse hook scripts for complex conditional logic. Both layers run simultaneously on every tool invocation.

### 4.2 Three-Tier Trust Model

All operations fall on a spectrum from fully autonomous to unconditionally blocked:

```
FULLY AUTONOMOUS              SUPERVISED                  BLOCKED
(auto-approved)          (user approval required)    (unconditionally denied)
      |                          |                          |
 Read files                 Create new files          git push --force
 Search/Grep                Install npm packages      sudo / su / doas
 Run tests                  git push (feature)        rm -rf / or ~
 Format code                Create PRs                chmod 777
 Lint / Build               Delete files              DROP TABLE
 Git status/log/diff        Modify package.json       System modifications
 Read .vibecrew/              Run dev server             Credential file access
 Context7 lookup            Merge PRs                 Force push / rebase main
 Git add / commit           Database migrations       kill -9
 Create worktrees           Deploy / publish          Fork bombs
```

| Trust Level | Approval Mechanism | Examples |
|-------------|-------------------|----------|
| **Low risk** (auto-approve) | `settings.json` allow list | Read, Grep, test, lint, build, git queries, worktree operations |
| **Medium risk** (approve once per session) | Permission prompt, then session token | npm install, git push, PR creation, file deletion |
| **High risk** (always ask) | Permission prompt every time | Main branch operations, deploy, CLAUDE.md mutation |
| **Blocked** (unconditional deny) | `settings.json` deny list + `protect-data.sh` | Force push, sudo, destructive deletes, system mods |

### 4.3 Layer 1: settings.json Deny Rules

The `settings.json` file ships with the plugin and provides declarative tool restrictions. These are evaluated by Claude Code's built-in permission system before any hook fires.

```json
{
  "permissions": {
    "deny": [
      "Bash(sudo *)",
      "Bash(su *)",
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(git reset --hard *)",
      "Bash(git clean -f *)",
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(chmod 777 *)",
      "Bash(npm install -g *)",
      "Bash(kill -9 *)",
      "Bash(launchctl *)",
      "Bash(defaults write *)",
      "Bash(DROP TABLE *)",
      "Bash(DROP DATABASE *)"
    ]
  }
}
```

This catches the most common destructive patterns declaratively. The deny list is a first line of defense -- fast, zero-token, and impossible for the model to circumvent.

### 4.4 Layer 2: PreToolUse Hook Scripts

Hook scripts provide conditional logic that `settings.json` deny rules cannot express. Two scripts run on every tool invocation:

**`phase-gate.sh`** (matcher: `Write|Edit`) -- Reads `.vibecrew/state.json` and blocks source code writes when `foundation.complete` is `false` (see [schemas.md, Section 3: state.json](schemas.md#3-statejson)). Foundation artifacts (VISION.md, design-system.css, TDR, etc.) are allowed through. This enforces the Research-First Protocol: architecture decisions must be made before code is written.

**`protect-data.sh`** (matcher: `Bash`) -- Inspects the command string via regex and blocks 40+ dangerous patterns across eight categories:

| Category | Pattern Count | Examples |
|----------|--------------|---------|
| Destructive file operations | 7 | `rm -rf`, `mkfs`, `dd if=`, `truncate` |
| Privilege escalation | 8 | `sudo`, `su -`, `doas`, `chmod 777`, `setuid` |
| Git danger zone | 8 | `push --force`, `reset --hard`, `clean -f`, `branch -D main` |
| Database destruction | 5 | `DROP TABLE`, `DROP DATABASE`, `TRUNCATE TABLE` |
| Credential exposure | 5 | `cat .ssh/`, `cat .aws/`, `cat .env`, `printenv` |
| System modification | 8 | `npm install -g`, `brew install`, `crontab`, `systemctl` |
| Network exfiltration | 4 | `nc`, `scp`, `rsync` to remote |
| Resource exhaustion | 3 | Fork bombs, `yes |`, infinite loops |

**`restrict-paths.sh`** (matcher: `Write|Edit`) -- Validates that file write targets are within the project root using `realpath` canonicalization. Defends against path traversal (`../`), absolute paths outside the project, symlink escape attacks, and writes to sensitive files (`.env`, `.git/`, SSH keys, AWS credentials).

### 4.5 Defense-in-Depth Architecture

No single layer catches everything. The four layers operate as concentric defenses:

```
+---------------------------------------------------------------+
|  Layer 4: GIT-BASED ROLLBACK                                  |
|  Checkpoint commits before major operations.                  |
|  git reset --soft to any checkpoint if damage occurs.         |
|  Worktrees isolate blast radius to one feature.               |
|                                                               |
|  +-----------------------------------------------------------+|
|  |  Layer 3: SETTINGS.JSON DENY RULES                        ||
|  |  Declarative pattern blocking. Zero token cost.            ||
|  |  Evaluated before hooks. Cannot be circumvented.           ||
|  |                                                            ||
|  |  +-------------------------------------------------------+||
|  |  |  Layer 2: PRETOOLUSE HOOK SCRIPTS                      |||
|  |  |  Conditional logic. Path validation. Phase gate.       |||
|  |  |  40+ regex patterns. Symlink detection.                |||
|  |  |                                                        |||
|  |  |  +---------------------------------------------------+|||
|  |  |  |  Layer 1: AGENT TOOL PERMISSIONS                   ||||
|  |  |  |  Each agent gets only the tools it needs.          ||||
|  |  |  |  Read-only agents cannot Write or Edit.            ||||
|  |  |  |  disallowedTools in agent frontmatter.             ||||
|  |  |  +---------------------------------------------------+|||
|  |  +-------------------------------------------------------+||
|  +-----------------------------------------------------------+|
+---------------------------------------------------------------+
```

| Layer | Mechanism | What It Catches | Token Cost |
|-------|-----------|-----------------|------------|
| 1 | Agent `tools` / `disallowedTools` frontmatter | Wrong tool for the agent role | Zero |
| 2 | PreToolUse hook scripts (`phase-gate.sh`, `protect-data.sh`, `restrict-paths.sh`) | Dangerous commands, path escapes, premature source writes | Zero |
| 3 | `settings.json` deny rules | Common destructive patterns | Zero |
| 4 | Git checkpoint commits + worktree isolation | Recovery from any damage that bypasses layers 1-3 | Zero |

### 4.6 Phase Gate Detail

The phase gate is the enforcement mechanism for the Two-Tier Workflow. It reads `foundation.complete` from `.vibecrew/state.json` (see [schemas.md, Section 3: state.json](schemas.md#3-statejson)) and applies path-based filtering:

```
PreToolUse(Write|Edit) fires
    |
    v
Read .vibecrew/state.json
    |
    +--> File does not exist --> DENY "VibeCrew not initialized. Run /setup."
    |
    +--> foundation.complete == true --> ALLOW (exit 0)
    |
    +--> foundation.complete == false
         |
         v
    Check file path against source code patterns:
    (src|app|lib|components|pages|features)/
         |
         +--> Path matches source code --> DENY "Phase Gate: Foundation incomplete."
         |
         +--> Path does NOT match --> ALLOW (foundation artifact write)
```

Foundation artifacts (VISION.md, design-system.css, docs/, .vibecrew/, CLAUDE.md) are always allowed through the phase gate regardless of foundation status, because they are the artifacts being created during Tier 1.

### 4.7 Known Limitations

The regex-based command blocking in `protect-data.sh` is inherently imperfect. A sufficiently creative command can bypass string matching via:

- Base64 encoding: `echo "cm0gLXJmIC8=" | base64 -d | bash`
- Variable expansion: `CMD="rm"; $CMD -rf /`
- eval: `eval "$(echo 'rm -rf /'| tr 'a-z' 'a-z')"`

These bypass vectors are unlikely in model-generated commands but are documented as a known limitation. The mitigation is the layered defense: even if Layer 2 is bypassed, Layer 3 (settings.json deny rules) and Layer 4 (git rollback via worktrees) provide recovery.

---

## 5. Context Window Management

### 5.1 Target: Below 50% Usage

Every VibeCrew agent session targets less than 50% context window utilization. This is a safety requirement, not merely a performance optimization. When context usage exceeds 60%, the model begins to lose track of earlier instructions -- including safety constraints, project conventions from CLAUDE.md, and architectural decisions from the TDR. For a non-technical user who cannot recognize degraded output quality, context exhaustion is a silent failure mode.

### 5.2 Strategy Overview

```
+------------------------------------------------------------------+
|              CONTEXT WINDOW MANAGEMENT STRATEGIES                 |
+------------------------------------------------------------------+
|                                                                  |
|  STRATEGY                     SAVINGS         IMPLEMENTATION     |
|  ---------                    -------         --------------     |
|  Sub-agent isolation          8K-15K tokens   Stack Scout and    |
|  (research in separate        per research    Builder run in     |
|  context window)              session         own worktrees,     |
|                                               return only        |
|                                               results            |
|                                                                  |
|  Context7 MCP for docs        ~1,500 tokens   On-demand API     |
|  (fetch docs on demand        per lookup      lookup replaces   |
|  instead of pasting)                          pasting docs      |
|                                                                  |
|  Haiku for mechanical         ~60x cheaper    Session Startup    |
|  agents (routing and          per token       and Verifier use   |
|  test execution do not        vs Opus         Haiku              |
|  need Opus reasoning)                                            |
|                                                                  |
|  Context re-injection         Prevents state  SessionStart hook  |
|  after compaction             loss after      with "compact"     |
|  (compact hook)               auto-compact    matcher re-injects |
|                                               state.json summary |
|                                                                  |
|  Stop hook for warnings       Prevents        check-context.sh  |
|  (60%/80%/90% thresholds)     exhaustion      fires after each  |
|                                               assistant turn     |
|                                                                  |
|  CLAUDE.md under 500 lines    Hundreds of     Re-read on every  |
|  (concise, reference files    tokens per      API call -- bloat  |
|  instead of inlining)         turn saved      is cumulative      |
|                                                                  |
|  Clear initial prompts        ~500 tokens     Avoid correction   |
|  (reduces correction loops)   per avoided     sequences that     |
|                               correction      churn context      |
|                                                                  |
|  Reference files, do not      Hundreds to     "Read design-      |
|  inline content               thousands       system.css" not    |
|                                               paste it           |
|                                                                  |
+------------------------------------------------------------------+
```

### 5.3 Sub-Agent Isolation (8K-15K Token Savings)

Sub-agent isolation is the single most impactful context management strategy. When the Stack Scout performs research, it runs in a completely separate context window within its own worktree. The parent session sends a task prompt via `TaskCreate` (a few hundred tokens) and receives back only the TDR output via a signal file (typically 2K-4K tokens). The research process itself -- web searches, documentation fetching, comparative analysis -- consumes 8K-15K tokens that never enter the parent's context.

```
ORCHESTRATOR                         STACK SCOUT SUB-AGENT
(primary session)                    (isolated worktree + context)

  TaskCreate:                    --> [Fresh context window]
  "Research optimal tech              |
   stack for travel app.              +--> WebSearch: "Next.js vs Remix 2026"
   Compare PWA vs React              +--> Context7: Remix docs
   Native."                           +--> Context7: Next.js docs
                                      +--> WebSearch: "Supabase vs Planetscale"
  [Waits for SendMessage...]          +--> Analysis and comparison
                                      |
  <-- Signal file with TDR            [Context discarded]
      (3K tokens of payload)          [Worktree available for merge]

  Net cost to parent: ~3K tokens
  If done inline: ~15K+ tokens
  Savings: ~12K tokens
```

### 5.4 Context7 MCP (1,500 Tokens Per Lookup)

Without Context7, an agent needing API documentation must either paste the documentation into the conversation (consuming thousands of tokens) or rely on potentially outdated training data. Context7 fetches current documentation on demand via an MCP tool call, returning only the relevant sections.

CLAUDE.md includes the rule: "Always use Context7 MCP for API documentation lookups. Never paste documentation into the conversation."

### 5.5 Haiku for Mechanical Agents

Two agents use Haiku instead of Opus:

- **Session Startup** runs at the beginning of every session. It reads state.json, checks the environment, and routes to the appropriate workflow. This is simple conditional logic that does not require advanced reasoning.

- **Verifier** runs tests, build, and lint commands. These are mechanical tasks that follow a deterministic pattern: execute a command, parse the output, report pass/fail results. Haiku handles this efficiently at approximately 60x lower cost per token than Opus.

The Opus-first strategy reserves the most capable model for tasks that benefit from deep reasoning (research, code generation, security analysis, adversarial review), while Haiku handles the high-frequency, low-complexity tasks where cost efficiency matters most.

### 5.6 Stop Hook: Context Warnings

The `check-context.sh` script fires on the Stop event (after each assistant turn) and reads context usage from the hook payload:

| Threshold | Level | Response |
|-----------|-------|----------|
| 0-50% | Normal | No intervention |
| 50-60% | Info | Agent should start wrapping up |
| 60-80% | Warning | Notification fires, agent should commit and prepare handoff |
| 80-90% | Critical | Session must terminate, force WIP commit |
| 90%+ | Danger | Agent quality severely degraded, immediate `/wrap` required |

The hook also checks `stop_hook_active` to prevent infinite loops (a Stop hook that forces continuation triggers another Stop event).

### 5.7 Context Re-Injection After Compaction

When Claude Code automatically compacts the conversation to free context space, the agent loses awareness of project state. VibeCrew uses the `SessionStart` hook with the `compact` matcher to re-inject critical state after every compaction event.

**How it works:**

1. Claude Code detects context usage exceeds its internal threshold and triggers compaction.
2. After compaction, a `SessionStart` event fires with the `compact` matcher.
3. The `compact-reinject.sh` script runs, reading `.vibecrew/state.json` and outputting a structured summary.
4. The summary is injected into the fresh context, restoring the agent's awareness of foundation status, active feature, and last update time.

**Hook configuration:**

```json
{
  "event": "SessionStart",
  "matcher": "compact",
  "command": "cat .vibecrew/state.json | jq '{foundation: .foundation.complete, feature: .active_feature, updated: .updated_at}'"
}
```

**Example output injected after compaction:**

```json
{
  "foundation": true,
  "feature": {
    "id": "feat-001",
    "name": "User Authentication",
    "worktree": ".claude/worktrees/builder-feat-001",
    "phase": "code",
    "phases_completed": ["plan", "design"]
  },
  "updated": "2026-02-23T14:30:00Z"
}
```

This ensures the agent can resume work without losing track of where it is in the workflow. The re-injected data is minimal (under 200 tokens) but sufficient for the agent to make correct routing and continuation decisions.

**Why this matters for non-technical users:** Compaction is invisible to the user. Without re-injection, the agent might restart foundation work that was already completed, re-plan a feature that is mid-implementation, or lose track of which worktree it should be operating in. The compact hook prevents these silent regressions.

### 5.8 CLAUDE.md Budget

CLAUDE.md is re-read on every API call. A 500-line CLAUDE.md consumes roughly 2,000-3,000 tokens per turn. A bloated 1,000-line file doubles this cost across every interaction for the entire session.

Rules for keeping CLAUDE.md lean:

1. Maximum 500 lines
2. Reference external files instead of inlining content ("Reference: design-system.css")
3. Use imperative language ("Always use X", "Never do Y")
4. 20-40 high-impact rules, not 200 minor ones
5. Review monthly -- remove stale rules, consolidate duplicates
6. Performance Coach proposes mutations; bloat is pruned in the same cycle

### 5.9 Cache Utilization as Efficiency Signal

Claude Code tracks `cache_read_input_tokens` (tokens served from prompt cache at 90% discount) versus total `input_tokens`. The ratio is a powerful efficiency metric:

- **High (>50%):** Session efficiently reusing cached context. Same CLAUDE.md and file contents served from cache.
- **Low (<20%):** Context churning. New content constantly pushing old content out of cache. Indicates doc pasting, excessive corrections, or rapid context changes.

The Vibe Score deducts 15 points when cache utilization drops below 20%, incentivizing behaviors that maintain cache stability. See [schemas.md, Section 6: Score Files](schemas.md#6-score-files) for the full score calculation.

---

## 6. Slash Commands

### 6.1 Overview

VibeCrew exposes 26 slash commands, each implemented as a `SKILL.md` file in the `skills/` directory. Skills follow the Agent Skills open standard and create `/name` shortcuts in the Claude Code interface.

All VibeCrew commands use `disable-model-invocation: true` to prevent Claude from auto-loading them. They are user-triggered workflows, not background capabilities. Two commands (`/status` and `/check`) also allow model invocation for internal use by the Orchestrator.

### 6.2 Command Map

```
+-------------------------------------------------------------------+
|                    VIBECREW SLASH COMMANDS                           |
+-------------------------------------------------------------------+
|                                                                   |
|  SETUP & FOUNDATION                                               |
|  /setup          First-run wizard: install deps, create .vibecrew/  |
|  /new-project    Run Tier 1 foundation (VISION -> CLAUDE.md)      |
|                                                                   |
|  PLANNING                                                         |
|  /plan-features  Interactive backlog planning session              |
|  /idea "text"    Quick-capture an idea to backlog as "idea" state |
|                                                                   |
|  DEVELOPMENT                                                      |
|  /new-feature    Start Tier 2 cycle for a feature                 |
|  /run-backlog    Automated processing of entire backlog           |
|                                                                   |
|  QUALITY                                                          |
|  /check          Run tests, build, lint (Verifier agent)          |
|  /review         Code review against spec and TDR                 |
|  /tdd            Test-driven development cycle                    |
|  /e2e            Generate Playwright E2E tests                    |
|  /a11y           Run WCAG 2.1 AA accessibility audit              |
|  /perf-test      Generate k6 performance test suite               |
|  /debug          Interactive debugging session                    |
|                                                                   |
|  OPERATIONS                                                       |
|  /status         Project state dashboard (read-only)              |
|  /wrap           End session with scoring, commit                 |
|  /heal           Diagnose and repair CI failures                  |
|  /simplify       Dead code detection, complexity reduction        |
|  /handoff        Generate cross-session context transfer          |
|  /replay         Re-run a saved workflow template                 |
|  /audit          Security audit (OWASP Top 10)                    |
|  /undo           Revert last VibeCrew action                      |
|                                                                   |
|  INFO & GAMIFICATION                                              |
|  /cost           Token usage and cost breakdown                   |
|  /achievements   View badges, level, streaks, skill tree          |
|  /quiz           Test your VibeCrew knowledge                     |
|                                                                   |
|  PERSONALIZATION                                                   |
|  /profile        User profile interview — adapts all agents        |
|                                                                   |
|  META                                                              |
|  /system-review  Plugin self-audit, telemetry, ecosystem research |
|                                                                   |
+-------------------------------------------------------------------+
```

### 6.3 Command Specifications

| Command | Skill Name | Arguments | Context | Agent | Model |
|---------|-----------|-----------|---------|-------|-------|
| `/setup` | `setup` | None | Fork (general-purpose) | -- | Inherit |
| `/new-project` | `new-project` | None | Inline | Workflow Orchestrator | Opus |
| `/plan-features` | `plan-features` | None | Inline | Workflow Orchestrator | Opus |
| `/new-feature` | `new-feature` | `"feature-name"` | Fork (general-purpose) | Builder | Opus |
| `/run-backlog` | `run-backlog` | None | Inline | Workflow Orchestrator | Opus |
| `/idea` | `idea` | `"description text"` | Inline | -- | Inherit |
| `/status` | `status` | None | Inline (read-only) | -- | Inherit |
| `/check` | `check` | None | Fork (Haiku) | Verifier | Haiku |
| `/wrap` | `wrap` | None | Inline | Verifier | Haiku |
| `/heal` | `heal` | None | Inline | CI Healer | Opus |
| `/simplify` | `simplify` | None | Worktree | Code Simplifier | Opus |
| `/replay` | `replay` | `"workflow-name"` | Inline | Workflow Orchestrator | Opus |
| `/handoff` | `handoff` | None | Inline | Doc Generator | Sonnet |
| `/audit` | `audit` | None | Worktree | Security Auditor | Opus |
| `/cost` | `cost` | None | Inline | -- | Inherit |
| `/achievements` | `achievements` | None | Inline | -- | Inherit |
| `/quiz` | `quiz` | None | Inline | -- | Inherit |
| `/undo` | `undo` | None | Inline | -- | Inherit |
| `/tdd` | `tdd` | `"component-name"` | Inline | Verifier | Haiku |
| `/debug` | `debug` | `"issue description"` | Inline | Builder | Opus |
| `/review` | `review` | None | Worktree | Code Reviewer | Opus |
| `/e2e` | `e2e` | `"feature-name"` | Inline | Verifier | Haiku |
| `/perf-test` | `perf-test` | `"endpoint-or-flow"` | Inline | Verifier | Haiku |
| `/a11y` | `a11y` | None | Inline | Verifier | Haiku |
| `/profile` | `profile` | None | Inline | -- | Inherit |
| `/system-review` | `system-review` | None | Worktree | System Reviewer | Opus |

### 6.4 Command Details

**`/setup`** -- First-run installation wizard. Verifies prerequisites (Git 2.30+, GitHub CLI 2.0+, Node.js 18+, jq, terminal-notifier). Creates the `.vibecrew/` directory with initial `config.json`, `state.json`, and `backlog.json` (see [schemas.md](schemas.md) for initial file structures). Configures MCP servers. Runs in a forked context to avoid polluting the main session.

**`/new-project`** -- Triggers the Tier 1 foundation workflow. Sequentially produces VISION.md, design-system.css, TDR, roadmap, architecture diagrams (5 Mermaid `.mmd` files), and CLAUDE.md. Sets `foundation.complete` to `true` in `state.json` when all six artifacts are created and approved. This is the command that unlocks Tier 2.

**`/plan-features`** -- Interactive planning session. Reads the roadmap, asks clarifying questions about each feature, and populates `backlog.json` with feature specs including acceptance criteria, priorities, and dependency relationships. Features move from `idea` to `planning` when planning begins, and advance to `planned` when specs are complete and dependencies are met.

**`/new-feature "name"`** -- Starts a Tier 2 feature cycle. Verifies foundation is complete (reads `foundation.complete` from `state.json`). Looks up the named feature in `backlog.json` (or creates a new entry). Creates a worktree via `git worktree add`. Initializes the 6-phase tracker. Uses `TaskCreate` to launch the appropriate agent for the current phase.

**`/run-backlog`** -- Automated batch processing. Repeatedly claims the next `planned` task from the backlog, creates a team via `TeamCreate`, and runs it through all six phases (Plan, Design, Code, Test, Review, Docs) using agent coordination. Continues until the backlog is empty or context is exhausted. Ideal for overnight or unattended runs.

**`/profile`** -- User profile interview. Presents 8 questions covering role, code literacy, autonomy preference, PR review style, verbosity, gamification preference, learning style, and risk tolerance. Users can answer all questions (~2 minutes), pick a preset (Builder, Explorer, or Founder), or skip for balanced defaults. Saves to `config.json` under `user_profile`. All agents read the profile via `scripts/read-profile.sh` and adapt their communication style, approval gates, and output depth accordingly. Re-running `/profile` shows the current profile and lets users update any dimension.

**`/idea "text"`** -- Quick capture. Appends a new feature entry to `backlog.json` with column `idea` and the provided text as the description. No acceptance criteria, no priority, no dependencies -- those are added during `/plan-features`. This command is intentionally lightweight for capturing thoughts without breaking flow.

**`/status`** -- Read-only dashboard. Uses dynamic context injection (`` !`command` `` syntax) to display current git branch, foundation status, active feature, backlog summary, and session count. Produces no side effects. Available to both the user and the Orchestrator agent.

```yaml
# Example /status SKILL.md using dynamic injection
---
name: status
description: Show current VibeCrew project status
disable-model-invocation: false
---

## Current State
- Git branch: !`git rev-parse --abbrev-ref HEAD`
- Foundation: !`jq -r '.foundation.complete' .vibecrew/state.json 2>/dev/null || echo "not initialized"`
- Active feature: !`jq -r '.active_feature.name // "none"' .vibecrew/state.json 2>/dev/null || echo "none"`
- Backlog: !`jq '[.features[] | .column] | group_by(.) | map({(.[0]): length}) | add' .vibecrew/backlog.json 2>/dev/null || echo "no backlog"`
```

**`/check`** -- Runs the Verifier agent in a forked context. Executes `npm test`, `npm run build`, and `npm run lint`. Reports pass/fail results. Used standalone for ad-hoc validation and also called automatically during `/wrap` and `/run-backlog`.

**`/wrap`** -- Ends the current session gracefully. Runs `/check` to verify quality. Triggers the Performance Coach (Opus) to calculate the Vibe Score, analyze session metrics, and propose CLAUDE.md mutations based on identified anti-patterns. Creates a WIP commit for incomplete features or a conventional commit for completed work. Updates session logs and score history.

### 6.5 Invocation Control Matrix

| Command | User Can Invoke | Claude Can Invoke | Loads Into Context |
|---------|----------------|-------------------|--------------------|
| `/setup` | Yes | No | Only on invocation |
| `/new-project` | Yes | No | Only on invocation |
| `/plan-features` | Yes | No | Only on invocation |
| `/new-feature` | Yes | No | Only on invocation |
| `/run-backlog` | Yes | No | Only on invocation |
| `/idea` | Yes | No | Only on invocation |
| `/status` | Yes | Yes | Description always in context |
| `/check` | Yes | Yes | Description always in context |
| `/wrap` | Yes | No | Only on invocation |
| `/profile` | Yes | No | Only on invocation |

Commands with `disable-model-invocation: true` are invisible to Claude until the user types the slash command. This prevents accidental invocation and keeps the context budget clean -- only `/status` and `/check` descriptions consume context tokens passively.

---

## Appendix A: Hook Configuration Summary

The complete `hooks/hooks.json` routing table:

| Event | Matcher | Script | Type | Blocking | Notes |
|-------|---------|--------|------|----------|-------|
| SessionStart | `startup` | `session-startup.sh` | command | No | Environment check, routing |
| SessionStart | `compact` | `compact-reinject.sh` | command | No | Re-injects state after compaction |
| PreToolUse | `Write\|Edit` | `phase-gate.sh` | command | Yes (deny) | Blocks source writes when `foundation.complete` is `false` |
| PreToolUse | `Write\|Edit` | `restrict-paths.sh` | command | Yes (deny) | Sandbox path validation |
| PreToolUse | `Bash` | `protect-data.sh` | command | Yes (deny) | Dangerous command blocker |
| PostToolUse | `Write\|Edit` | `format-code.sh` | command | No | Auto-format written files |
| Notification | `permission_prompt` | `notify.sh` | command | No | Interrupt Protocol |
| Notification | `idle_prompt` | `notify.sh` | command | No | Interrupt Protocol |
| PostToolUseFailure | (all) | `notify.sh` | command | No | Error notifications |
| Stop | (all) | `check-context.sh` | command | No | Context usage warnings |

**New in v1.0 (post-review):** The `SessionStart` hook with `compact` matcher. This was not present in the pre-review design. It fires after every context compaction event and re-injects a summary of `.vibecrew/state.json` so the agent does not lose track of project state. See [Section 5.7](#57-context-re-injection-after-compaction) for details.

**Note:** The `SessionEnd` hook for `coach-retro.sh` (Performance Coach retrospective) is handled by the Performance Coach (Opus) during `/wrap`, which calculates Vibe Scores and proposes CLAUDE.md mutations.

---

## Appendix B: Interrupt Protocol

VibeCrew notifications fire on exactly three conditions. All other operations are silent to preserve Deep Work state:

| Condition | Hook Event | Sound | Action |
|-----------|------------|-------|--------|
| Permission stall | Notification (`permission_prompt`) | Submarine | Warp deep-link to blocked tab |
| Task completion | Notification (`idle_prompt`) | Glass | Warp deep-link to idle tab |
| Critical failure | PostToolUseFailure | Basso | Warp deep-link to failed tab |

The notification script degrades gracefully: Warp deep-link + terminal-notifier > terminal-notifier without deep-link > osascript > terminal bell > silent log to `.vibecrew/notifications.log`.

With the Agent Teams API, the Orchestrator receives `SendMessage` notifications from agents when they complete tasks. OS-level notifications via `notify.sh` still fire for the three conditions above (permission stalls, task completion, critical failures) to alert the human developer. The difference from the pre-review design is that the Orchestrator can now act on completions programmatically instead of waiting for the developer to notice and respond.
