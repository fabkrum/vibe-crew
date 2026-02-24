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
  scripts/                      # ~53 bash automation scripts
  agents/                       # 12 specialized AI agent prompts
  skills/                       # 17 slash command definitions
  templates/                    # Project templates and doc-site scaffold

architecture/                   # Architecture design docs (contributor reference)
docs/                           # Companion documentation website (HTML)
CLAUDE.md                       # This file
```

## Core Architecture Concepts

### Two-Tier Workflow

- **Tier 1 (Project Foundation)**: Sequential, one-time process that creates VISION.md, design-system.css, TDR (Technology Decision Record), roadmap, and CLAUDE.md before any source code can be written. Enforced by a phase gate hook.
- **Tier 2 (Feature Development)**: Iterative 5-phase cycle (Plan > UI Design > Code > Test > Docs) for each feature. Phases can be worked in any order.

### Agent Topology (12 agents)

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

### Interrupt Protocol

Notifications fire only on three conditions: permission stalls (permission_prompt), task completion (idle_prompt), and critical failures (PostToolUseFailure). All other operations stay silent. Warp Terminal gets deep-link support via `WARP_SESSION_ID` and `warp://session/<id>` URIs.

### Vibe Score System

Starts at 100, applies deductions: prompt churn (-5/sequence), tool loops (-10/loop), low cache utilization (-15), context violations (-20), no tests (-10), no feature spec (-5). Bonuses up to +10 for complete phase artifacts and high cache utilization. The Performance Coach proposes permanent CLAUDE.md rule mutations based on identified anti-patterns.

### Per-Project Runtime State

When VibeCrew is used in a project, it creates a `.vibecrew/` folder:

```
.vibecrew/                        # Per-project runtime state (auto-created)
  config.json                   # Terminal preference, notification settings
  state.json                    # Foundation status + active feature
  backlog.json                  # Feature backlog with specs
  sessions/                     # Session logs (JSON)
  scores/                       # Vibe Score breakdowns (JSON)
  releases/                     # Release notes data (JSON)
  handoffs/                     # Cross-session handoff documents
  workflows/                    # Reusable workflow templates (/replay)
```

### Slash Commands

`/setup`, `/new-project`, `/plan-features`, `/new-feature "name"`, `/run-backlog`, `/idea "text"`, `/status`, `/check`, `/wrap`, `/heal`, `/simplify`, `/replay`, `/handoff`, `/audit`, `/cost`, `/achievements`, `/quiz`, `/undo`

## Design Principles

1. **Research before code** — The phase gate enforces architecture decisions (TDR) before any source code writes are allowed.
2. **Human attention is the bottleneck** — The system stays silent during normal operation and interrupts only when blocked, complete, or failed.
3. **Context window discipline** — Target <50% context usage. Subagents isolate expensive research. MCP servers (Context7) replace pasting docs. Warnings at 60%/80%.
4. **Hooks over suggestions** — Enforce rules via deterministic bash scripts (zero tokens) rather than relying on the model to remember.
5. **Self-improving** — Every session's Performance Coach analysis can permanently mutate CLAUDE.md rules, creating a recursive efficiency improvement loop.
6. **Parallel by default** — Planning and development can run simultaneously across terminal tabs.

## Current Status

VibeCrew v1.3.0 — the plugin is feature-complete. The repository contains:
- The full plugin (`claude-plugin-vibe-crew/`) with all agents, hooks, scripts, skills, and templates
- Architecture design docs (`architecture/`) for contributor reference
- Companion documentation website (`docs/`) with setup guide, workflows, example sessions, and best practices

## Key Dependencies

- Claude Code 2.0+, Git 2.30+, GitHub CLI 2.0+, Node.js 18+
- `terminal-notifier` (macOS notifications via Homebrew)
- `jq` (JSON parsing in hook scripts)
- MCP servers (10 total, all optional): Context7, Chrome DevTools, Playwright (enabled by default); Semgrep, Sentry, Supabase, Stripe, Vercel, Figma, Stitch (conditionally enabled from TDR)
