# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VibeCrew is a Claude Code plugin that transforms Claude Code into an autonomous vibe-coding operating system. It orchestrates multiple Claude Code sessions, manages the full software development lifecycle, and enables non-technical users to build production-grade SaaS applications.

## Repository Structure

```
claude-plugin-vibe-crew/          # The plugin — install this into your projects
  .claude-plugin/plugin.json    # Plugin manifest
  .mcp.json                     # MCP server config (10 servers)
  settings.json                 # Permission rules
  hooks/hooks.json              # Event hook bindings
  scripts/                      # ~80 bash automation scripts
  agents/                       # 14 specialized AI agent prompts
  skills/                       # 28 slash command definitions
  tests/                        # BATS test suite
  templates/                    # Project templates and doc-site scaffold

architecture/                   # Architecture design docs (contributor reference)
docs/                           # Companion documentation website (HTML)
CLAUDE.md                       # This file
```

## Core Architecture Concepts

### Two-Tier Workflow

- **Tier 1 (Project Foundation)**: Sequential, one-time process that creates VISION.md, design-system.css + design-brief.md (via Design Discovery interview), TDR (Technology Decision Record), roadmap, Architecture Diagrams (5 Mermaid `.mmd` files), and CLAUDE.md before any source code can be written. Enforced by a phase gate hook. Step 2 (Design Discovery) runs a 3-phase contextual interview: Product & Audience Context → Visual Direction → Component Preferences, producing both the CSS token file and a design brief that captures rationale for agents to reference.
- **Tier 2 (Feature Development)**: Iterative 6-phase cycle (Plan > UI Design > Code > Test > Review > Docs) for each feature. Review is optional in manual workflows but automatic in `/run-backlog`.

### Agent Topology (14 agents)

Opus agents handle planning, research, code, security, and analysis — tasks where mistakes are expensive to fix later. Haiku agents handle fast, mechanical tasks (routing, running shell commands). Sonnet handles template-driven output like documentation.

| Agent | Model | Isolation | Role |
|---|---|---|---|
| Session Startup | Haiku | Inline | Environment check, state detection, routing on every session start |
| Workflow Orchestrator | Opus | Inline | Routes between Tier 1/Tier 2, coordinates agent handoffs |
| Stack Scout | Opus | Worktree | Read-only research agent (WebSearch, Context7, Chrome DevTools) that produces TDRs in isolated context |
| Builder | Opus | Worktree | Implements features within TDR boundaries |
| Verifier | Haiku | Inline | Runs tests/build/lint/type-check for `/check`, `/wrap`, `/run-backlog` |
| Performance Coach | Opus | Inline | Cross-session trend analysis, anti-pattern detection, CLAUDE.md mutation proposals |
| Code Auditor | Opus | Worktree | Read-only codebase analysis for existing project onboarding |
| Security Auditor | Opus | Worktree | OWASP Top 10 security analysis (read-only) |
| Doc Generator | Sonnet | Inline | Session logs, CHANGELOG, feature docs, release notes |
| Code Simplifier | Opus | Worktree | Dead code detection, abstraction flattening, API surface reduction |
| CI Healer | Opus | Inline | CI failure diagnosis and repair (max 3 attempts) |
| Opponent Processor | Opus | Worktree | Devil's advocate for TDR decisions, debate matrices, risk assessments |
| Code Reviewer | Opus | Worktree | Read-only code review against feature spec, TDR compliance, conventions |
| System Reviewer | Opus | Worktree | Read-only plugin meta-analysis, cross-project telemetry, ecosystem research |

### Hook System (zero-token enforcement via bash scripts)

| Hook | Script | Purpose |
|---|---|---|
| SessionStart | session-startup.md | Environment check and state routing |
| PreToolUse (Write/Edit) | phase-gate.sh | Blocks source code writes until foundation complete |
| PreToolUse (Bash) | protect-data.sh | Blocks dangerous commands (rm -rf, DROP TABLE, force push) |
| PostToolUse (Write/Edit) | format-code.sh | Auto-formats written files |
| Notification | notify.sh | Native OS notifications with Warp deep-linking |
| PostToolUseFailure | notify.sh | Error notifications |
| Stop | check-context.sh | Warns at 60% and 80% context usage |
| Stop | cost-guardrails.sh | Session and daily cost tracking against thresholds |
| Stop | claude-md-lint.sh | CLAUDE.md size and quality validation |
| Stop | quality-gate.sh | Runs typecheck/lint/build on modified source files; blocks on failure |

### Interrupt Protocol

Notifications fire only on three conditions: permission stalls (permission_prompt), task completion (idle_prompt), and critical failures (PostToolUseFailure). All other operations stay silent. Warp Terminal gets deep-link support via `WARP_SESSION_ID` and `warp://session/<id>` URIs.

### Vibe Score System

Starts at 100, applies deductions: prompt churn (-5/sequence), tool loops (-10/loop), low cache utilization (-15), context violations (-20), no tests (-10), no feature spec (-5), skipped code review (-5), documentation drift (-3/stale doc). Bonuses up to +25 for complete phase artifacts, high cache utilization, full test coverage, clean sessions, TDD discipline (+3), E2E tests passing (+3), accessibility clean (+2), code review complete (+2), and performance baselines (+2). The Performance Coach proposes permanent CLAUDE.md rule mutations based on identified anti-patterns.

### Per-Project Runtime State

When VibeCrew is used in a project, it creates a `.vibecrew/` folder:

```
.vibecrew/                        # Per-project runtime state (auto-created)
  config.json                   # Terminal preference, notification settings (editable via dashboard Settings page)
  state.json                    # Foundation status + active feature
  backlog.json                  # Feature backlog with specs
  gamification.json             # Achievements & progression (opt-in)
  architecture/                 # Mermaid architecture diagrams (Tier 1 artifact)
    system.mmd                  #   Infrastructure topology (flowchart TD)
    schema.mmd                  #   Entity-relationship diagram (erDiagram)
    state-flows.mmd             #   Auth states and user flows (stateDiagram-v2)
    api-sequences.mmd           #   API request/response patterns (sequenceDiagram)
    component-tree.mmd          #   Component hierarchy with data flow (flowchart TD)
  sessions/                     # Session logs (JSON)
  scores/                       # Vibe Score breakdowns (JSON)
  signals/                      # Inter-agent signal files
  locks/                        # Advisory locks for concurrent access
  releases/                     # Release notes data (JSON)
  handoffs/                     # Cross-session handoff documents
  workflows/                    # Reusable workflow templates (/replay)
```

### Cross-Project Telemetry

Projects auto-register with the central VibeCrew plugin during `/setup`. Anonymized performance data (Vibe Scores, agent usage, cost metrics, MCP adoption) is aggregated for the `/system-review` command. Project paths and names are replaced with anonymous aliases (project-001, etc.). Telemetry data lives at `${CLAUDE_PLUGIN_ROOT}/telemetry/aggregate.json` and the project registry at `${CLAUDE_PLUGIN_ROOT}/project-registry.json`.

### Slash Commands

`/setup`, `/new-project`, `/plan-features`, `/new-feature "name"`, `/run-backlog`, `/idea "text"`, `/status`, `/check`, `/wrap`, `/heal`, `/simplify`, `/replay`, `/handoff`, `/audit`, `/cost`, `/achievements`, `/quiz`, `/undo`, `/tdd`, `/debug`, `/review`, `/e2e`, `/perf-test`, `/a11y`, `/system-review`, `/profile`, `/release`, `/onboard`

### User Profile System

The `/profile` command runs an 8-question interview (or offers presets) that stores user preferences in `.vibecrew/config.json` under the `user_profile` key. Every agent reads the profile via `scripts/read-profile.sh` and adapts behavior accordingly.

**8 Dimensions:**
- `role` — developer, technical_pm, designer, non_technical, learner
- `code_literacy` — fluent, conversational, basic, none
- `autonomy` — full_auto, checkpoints, collaborative, supervised
- `pr_review` — auto_merge, summary, review, walkthrough
- `verbosity` — minimal, standard, detailed, educational
- `gamification_preference` — full, light, score_only, disabled
- `learning` — none, reference_docs, inline, teach
- `risk_tolerance` — conservative, balanced, progressive, experimental

**Presets:** Builder (developer defaults), Explorer (learner defaults), Founder (non-technical defaults).

**Agent Adaptations:**
- Session Startup: greeting depth from `verbosity`
- Workflow Orchestrator: approval gates from `autonomy`, explanation depth from `verbosity`
- Builder: commit messages from `verbosity`, code comments from `code_literacy`, PR format from `pr_review`
- Verifier: coaching output from `verbosity`, gamification display from `gamification_preference`
- Stack Scout: technology maturity criteria from `risk_tolerance`
- Doc Generator: documentation depth from `learning` and `code_literacy`
- Code Reviewer: finding explanations from `code_literacy`, review thoroughness from `pr_review`

**Scripts:** `read-profile.sh` (universal reader with defaults), `save-profile.sh` (writer with gamification sync)

## Design Principles

1. **Research before code** — The phase gate enforces architecture decisions (TDR) before any source code writes are allowed.
2. **Human attention is the bottleneck** — The system stays silent during normal operation and interrupts only when blocked, complete, or failed.
3. **Context window discipline** — Target <50% context usage. Subagents isolate expensive research. MCP servers (Context7) replace pasting docs. MCP Tool Search (Claude Code built-in, Jan 2026) dynamically loads only relevant tool definitions when 5+ servers are enabled. Architecture diagrams pre-loaded once via `inject-architecture.sh` instead of per-agent reads. Warnings at 60%/80%. During `/run-backlog`, forced `/compact` between features prevents context rot across long autonomous runs.
4. **Hooks over suggestions** — Enforce rules via deterministic bash scripts (zero tokens) rather than relying on the model to remember. The quality gate Stop hook (`quality-gate.sh`) catches typecheck/lint/build errors immediately after every task completion.
5. **Self-improving** — Every session's Performance Coach analysis can permanently mutate CLAUDE.md rules, creating a recursive efficiency improvement loop. Capped at 15 Session Learnings with automatic oldest-pruning.
6. **Parallel by default** — Planning and development can run simultaneously across terminal tabs.
7. **Minimal CLAUDE.md** — Research (arxiv.org/abs/2602.11988) shows oversized context files increase agent cost 20%+ without improving success rates. User project CLAUDE.md files target <200 lines. Never include directory enumerations (agents navigate via architecture diagrams). Never restate rules that hooks enforce. Every line must earn its token cost.

## Documentation Sync Rule

When any feature is added, modified, or removed in user projects built with VibeCrew, the system MUST automatically update the project's documentation and architecture artifacts in the same session. Stale documentation is treated as a missing phase artifact.

### What triggers a doc sync

Any session that modifies source code, configuration, or project structure must update:

1. **Feature docs** (`docs/features/{feature-name}/`): The Doc Generator updates feature documentation to reflect implementation changes — new endpoints, changed props, modified behavior.
2. **CHANGELOG.md**: New entries from conventional commits made during the session.
3. **Architecture artifacts**: If the change affects data models, API contracts, component hierarchy, or routing — update the relevant architecture docs (TDR addendum, component design spec, or data model doc).
4. **Architecture diagrams** (`.vibecrew/architecture/*.mmd`): If the change affects database schema, API routes, auth flows, infrastructure topology, or component hierarchy — update the relevant Mermaid diagram(s). The Doc Generator checks diagram freshness during `/wrap`.
5. **VitePress sidebar**: Regenerated when any doc pages are added or removed.
6. **Project CLAUDE.md**: If the change introduces new conventions, patterns, or constraints that future sessions should follow.

### Enforcement in the Tier 2 workflow

The Doc Generator agent runs during `/wrap` and checks for documentation drift:

- Compare source files modified in the session (from git diff) against existing feature docs
- Flag any completed feature that has outdated or missing documentation
- Auto-generate or update feature docs from backlog specs and git history
- Rebuild the VitePress sidebar if doc pages changed

### Vibe Score integration

Documentation drift is scored as a **missing phase artifact** (-3 per stale doc). Additionally:

| Condition | Score Impact |
|---|---|
| Source code changed but matching feature doc not updated | -3 (missing-phase: docs) |
| New API endpoints/routes without doc coverage | -3 (missing-phase: docs) |
| Architecture diagram stale after code changes (schema, routes, components, etc.) | -3 per stale diagram (doc-drift) |
| All feature docs and architecture diagrams current after code changes | +5 (all-phases bonus eligible) |

The Performance Coach can propose a CLAUDE.md mutation if documentation drift recurs across 3+ sessions, using template: "Always update feature documentation in the same session as code changes. Run the Doc Generator before wrapping."

## Current Status

VibeCrew v1.6.0 — the plugin is feature-complete. The repository contains:
- The full plugin (`claude-plugin-vibe-crew/`) with all agents, hooks, scripts, skills, and templates
- Architecture design docs (`architecture/`) for contributor reference
- Companion documentation website (`docs/`) with setup guide, workflows, example sessions, and best practices

## Key Dependencies

- **Required:** Git 2.30+, Node.js 18+, `jq` (JSON parsing in hook scripts)
- **Optional:** GitHub CLI 2.0+ (PR automation), `terminal-notifier` (macOS notifications)
- **Bootstrap:** `install.sh` at plugin root auto-installs missing deps; `/setup` offers in-session auto-install
- MCP servers: 10 bundled in `.mcp.json` (Context7, Chrome DevTools, Playwright enabled by default; Semgrep, Sentry, Supabase, Stripe, Vercel, Figma, Stitch conditionally enabled from TDR) + 15 additional servers in `templates/mcp-registry.json` that can be auto-discovered and injected based on TDR technology choices
