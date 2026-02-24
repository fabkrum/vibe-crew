# VibeOS

**Autonomous vibe-coding operating system for Claude Code.**

VibeOS is a Claude Code plugin that transforms your terminal into a managed
software development environment. It orchestrates specialized agents, enforces
architecture-before-code discipline, and keeps you informed only when your
attention is needed -- permission stalls, task completions, and critical failures.

---

## Quick Install

**Prerequisites**

| Dependency | Minimum Version |
|---|---|
| Claude Code | 2.0+ |
| Git | 2.30+ |
| GitHub CLI (`gh`) | 2.0+ |
| Node.js | 18+ |
| `jq` | any |
| `terminal-notifier` (macOS) | any |

Install missing dependencies on macOS:

```bash
brew install jq terminal-notifier gh node
```

**Install the plugin**

```bash
claude plugin install /path/to/claude-plugin-vibe-os
```

Installation takes under 5 minutes. The plugin registers hooks, agents, slash
commands, permission rules, and optional MCP servers automatically.

**Optional MCP servers**

VibeOS ships with configurations for two MCP servers in `.mcp.json`. They are
enabled by default but work is not blocked if they are unavailable.

- **Context7** -- documentation lookup for popular frameworks and libraries.
- **Puppeteer** -- headless browser automation for visual testing and research.

---

## Quick Start

1. Open a new Claude Code session in any directory.
2. Run `/setup` to verify your environment and install dependencies.
3. Run `/new-project` to create a fresh project. VibeOS walks you through
   Tier 1 (project foundation) before any source code can be written.
4. Run `/plan-features` to build your feature backlog.
5. Run `/new-feature "feature name"` to begin developing a feature through the
   Tier 2 cycle.
6. Run `/wrap` when you are done to generate session logs, release notes, and
   a Vibe Score breakdown.

---

## Commands Reference

VibeOS provides 17 slash commands. Each command is defined in the `skills/`
directory and invoked directly from the Claude Code prompt.

### Project Setup

| Command | Description |
|---|---|
| `/setup` | Verify environment (Git, Node, gh, jq, terminal-notifier), detect terminal, initialize `.vibeos/` state directory. |
| `/new-project` | Create a new project and run through Tier 1: generate VISION.md, design-system.css, TDR, roadmap, and CLAUDE.md. Phase gate blocks source code writes until all foundation artifacts exist. |

### Planning

| Command | Description |
|---|---|
| `/plan-features` | Define and prioritize the feature backlog. Creates or updates `.vibeos/backlog.json` with feature specs, priorities, and dependency ordering. |
| `/idea "text"` | Capture a quick idea and append it to the backlog as an unrefined item for later triage during `/plan-features`. |

### Development

| Command | Description |
|---|---|
| `/new-feature "name"` | Start the Tier 2 cycle for a specific feature: plan, design, code, test, docs. Creates a feature branch and claims the task in the backlog. |
| `/run-backlog` | Autonomously process the next unclaimed feature from the backlog. Equivalent to `/new-feature` but picks the highest-priority item automatically. |

### Onboarding

| Command | Description |
|---|---|
| `/onboard` | Onboard an existing project into VibeOS. Analyzes the codebase, extracts conventions, generates a project-specific CLAUDE.md, and initializes state with `foundation.complete = true`. |

### Cost and Safety

| Command | Description |
|---|---|
| `/cost` | Display the real-time token cost dashboard: current session cost, daily/weekly/monthly aggregates, threshold proximity, and model pricing reference. |
| `/undo` | Checkpoint rollback: list VibeOS checkpoints and recent commits, pick a target, and safely revert (pushed) or reset (unpushed) while preserving your working tree. |
| `/audit` | OWASP Top 10 security review: scan codebase for injection, auth, XSS, misconfig, and 7 more vulnerability categories. Runs dependency audit, secret detection, and optionally creates GitHub issues for critical findings. |
| `/heal` | Auto-heal failing CI: fetch logs from GitHub Actions, diagnose failure category (build/test/lint/dep/env), apply targeted fix (max 3 attempts), verify, and commit. Creates a checkpoint before any changes. |

### Code Quality

| Command | Description |
|---|---|
| `/simplify` | Analyze feature code for simplification opportunities: dead code removal, abstraction flattening, API surface reduction, dependency consolidation. Opus-powered read-only analysis with per-suggestion approval and automatic test verification. |
| `/replay` | Reusable workflow templates from successful sessions. `/replay` lists templates, `/replay --create <name>` extracts from sessions with Vibe Score >= 70, `/replay <name>` loads a template to guide development. |

### Quality and Wrap-Up

| Command | Description |
|---|---|
| `/check` | Run the full quality suite: tests, build, lint, type-check. Reports pass/fail status without modifying code. |
| `/wrap` | End the current session. Generates a session log, calculates the Vibe Score, invokes the Performance Coach for CLAUDE.md mutations, auto-generates a handoff document, and triggers the Doc Generator. |
| `/handoff` | Generate a structured context transfer document for the next session. Includes state, work done, blockers, next steps, and key decisions. |
| `/status` | Display current project state: foundation progress, active feature, backlog summary, recent session scores, and context usage. |

---

## Architecture Overview

### Two-Tier Workflow

**Tier 1 -- Project Foundation** is a sequential, one-time process that
produces five artifacts before any source code is written:

1. `VISION.md` -- product vision, target users, success criteria
2. `design-system.css` -- colors, typography, spacing, component tokens
3. `TDR` (Technology Decision Record) -- stack choices with rationale
4. `roadmap.md` -- phased delivery plan
5. `CLAUDE.md` -- project-specific rules for Claude Code

A phase gate hook (`phase-gate.sh`) blocks all Write and Edit operations on
source code files until every foundation artifact is present.

**Tier 2 -- Feature Development** is an iterative 5-phase cycle for each
feature:

1. **Plan** -- feature spec, acceptance criteria, task breakdown
2. **Design** -- UI/component design aligned to the design system
3. **Code** -- implementation within TDR boundaries
4. **Test** -- unit tests (Vitest), E2E tests (Playwright), accessibility (axe)
5. **Docs** -- feature documentation, CHANGELOG entry, session log

### Agents

VibeOS uses 12 specialized agents, each with a dedicated system prompt:

| Agent | Model | Execution | Role |
|---|---|---|---|
| Session Startup | Haiku | Inline | Environment check, state detection, handoff detection, progressive hints, routing. |
| Workflow Orchestrator | Opus | Inline | Routes between Tier 1 and Tier 2, coordinates agent handoffs, manages backlog state. |
| Stack Scout | Opus | Worktree | Read-only research agent. Uses WebSearch, Context7, and Puppeteer to produce Technology Decision Records in an isolated context. |
| Builder | Opus | Worktree | Implements features within TDR boundaries. Runs in a worktree to isolate work-in-progress from the main branch. |
| Verifier | Haiku | Inline | Runs quality checks (tests, lint, build, type-check), calculates Vibe Score. |
| Performance Coach | Opus | Inline | Cross-session trend analysis, anti-pattern detection, CLAUDE.md mutation proposals with 7-step guardrailed workflow. |
| Code Auditor | Opus | Worktree | Read-only codebase analysis for existing project onboarding. Extracts conventions, test gaps, and architecture patterns. |
| Security Auditor | Opus | Worktree | Read-only OWASP Top 10 security analysis. Scans for injection, auth, XSS, misconfig, vulnerable dependencies, secrets, and SSRF. |
| Doc Generator | Sonnet | Inline | Feature documentation, CHANGELOG updates, VitePress sidebar regeneration, release notes. |
| Code Simplifier | Opus | Worktree | Read-only code analysis for simplification: dead code, abstraction flattening, API reduction, dependency consolidation. |
| CI Healer | Opus | Inline | CI failure diagnosis and repair. Categorizes failures (build/test/lint/dep/env), applies targeted fixes with max 3 attempts. |
| Opponent Processor | Opus | Worktree | Devil's advocate for TDR decisions. Generates counter-arguments, debate matrices, and risk assessments for technology choices. |

### Hook System

Hooks enforce rules deterministically via bash scripts, consuming zero LLM
tokens. The `hooks/hooks.json` file binds 10 hook entries across 6 lifecycle
events:

| Event | Scripts | Purpose |
|---|---|---|
| SessionStart | `session-startup.sh`, `sync-state.sh`, `error-recovery.sh` | Initialize session, reconcile state, clear stale locks. |
| SessionStart (compact) | `compact-reinject.sh` | Re-inject project state after context compaction. |
| PreToolUse (Write/Edit) | `phase-gate.sh`, `restrict-paths.sh` | Block source writes before foundation; validate write targets. |
| PreToolUse (Bash) | `protect-data.sh` | Block dangerous commands (rm -rf, force push, DROP TABLE). |
| PostToolUse (Write/Edit) | `format-code.sh` | Auto-format written files with Prettier. |
| Notification | `notify.sh` | Native OS notifications on permission stalls and task completion. |
| PostToolUseFailure | `notify.sh error` | Error notifications on tool failures. |
| Stop | `check-context.sh`, `cost-guardrails.sh`, `claude-md-lint.sh` | Context usage warnings, cost threshold checks, CLAUDE.md validation. |

### Status Bar

A persistent status line updates after every assistant message, showing six
data segments at zero token cost:

```
Opus ▓▓▓▓░░░░░░ 38% | $0.42 | auth-flow · Code | ↑85 | 12m | ⟳0
```

| Segment | Source | Notes |
|---|---|---|
| **Context %** | stdin `context_window.used_percentage` | 10-char progress bar. Green ≤45%, Yellow 46-55%, Red >55%. |
| **Session cost** | stdin `cost.total_cost_usd` | Formatted as `$X.XX`. |
| **Feature · Phase** | `.vibeos/state.json` | Feature name truncated to 16 chars. Falls back to "foundation · Tier-1" or "no project". |
| **Vibe Score** | Latest `.vibeos/scores/score-*.json` | Shows trend suffix: `+` improving, `-` declining. |
| **Duration** | stdin `cost.total_duration_ms` | Displayed in minutes. |
| **Compactions** | Latest `.vibeos/sessions/session-*.json` | Count of context compactions this session. |

The script (`scripts/statusline.sh`) gracefully degrades: if `jq` is missing
it shows "VibeOS"; if `.vibeos/` is absent it shows "no project".

### Interrupt Protocol

The system stays silent during normal operation. Notifications fire only on
three conditions:

1. **Permission stalls** (`permission_prompt`) -- the agent needs approval.
2. **Task completion** (`idle_prompt`) -- work is done, awaiting next instruction.
3. **Critical failures** (`PostToolUseFailure`) -- a tool call failed.

---

## File Structure

```
claude-plugin-vibe-os/
  .claude-plugin/
    plugin.json                 # Plugin manifest (name, version, entry points)
  .mcp.json                    # Context7 + Puppeteer MCP server config
  settings.json                # 71 permission rules (allowed + denied tools)
  hooks/
    hooks.json                 # 10 hook bindings across 6 lifecycle events
  agents/
    session-startup.md         # Session Startup agent prompt
    workflow-orchestrator.md   # Workflow Orchestrator agent prompt
    stack-scout.md             # Stack Scout agent prompt
    builder.md                 # Builder agent prompt
    verifier.md                # Verifier agent prompt
    performance-coach.md       # Performance Coach agent prompt
    code-auditor.md            # Code Auditor agent prompt
    security-auditor.md        # Security Auditor agent prompt
    doc-generator.md           # Doc Generator agent prompt
    code-simplifier.md         # Code Simplifier agent prompt
    ci-healer.md               # CI Healer agent prompt
    opponent-processor.md      # Opponent Processor agent prompt
  skills/
    setup/SKILL.md             # /setup command
    new-project/SKILL.md       # /new-project command
    plan-features/SKILL.md     # /plan-features command
    new-feature/SKILL.md       # /new-feature command
    run-backlog/SKILL.md       # /run-backlog command
    idea/SKILL.md              # /idea command
    status/SKILL.md            # /status command
    check/SKILL.md             # /check command
    wrap/SKILL.md              # /wrap command
    onboard/SKILL.md           # /onboard command
    handoff/SKILL.md           # /handoff command
    cost/SKILL.md              # /cost command
    undo/SKILL.md              # /undo command
    audit/SKILL.md             # /audit command
    replay/SKILL.md            # /replay command
    simplify/SKILL.md          # /simplify command
    heal/SKILL.md              # /heal command
  scripts/                     # ~53 bash automation scripts
  templates/                   # Project templates and doc-site scaffold
  LICENSE                      # MIT License

.vibeos/                       # Per-project runtime state (created by /setup)
  config.json                  # Terminal preference, notification settings
  state.json                   # Foundation status + active feature
  backlog.json                 # Feature backlog with specs and priorities
  sessions/                    # Session log JSON files
  scores/                      # Vibe Score breakdown JSON files
  releases/                    # Release notes data JSON files
  handoffs/                    # Cross-session handoff documents
  mutation-log.json            # CLAUDE.md mutation audit log
  workflows/                   # Reusable workflow templates (/replay)
  simplifications/             # Code simplification reports (/simplify)
  ci-heals/                    # CI heal reports (/heal)
```

---

## Troubleshooting

**Phase gate blocked -- "Foundation not complete"**

The phase gate hook prevents source code writes until all five Tier 1 artifacts
exist (VISION.md, design-system.css, TDR, roadmap, CLAUDE.md). Run `/status`
to see which artifacts are missing, then run `/new-project` to complete the
foundation.

**Notifications not working**

Verify `terminal-notifier` is installed:

```bash
which terminal-notifier
```

If missing, install it with `brew install terminal-notifier`. Check that
`.vibeos/config.json` has `"notifications": true`. On macOS, ensure
System Settings > Notifications allows alerts from `terminal-notifier`.

**MCP servers not connecting**

MCP servers (Context7, Puppeteer) are optional. If they fail to start:

1. Verify Node.js 18+ is available: `node --version`
2. Test manually: `npx -y @upstash/context7-mcp@latest`
3. Check `.mcp.json` for correct configuration.
4. VibeOS continues to function without MCP servers -- research agents fall
   back to WebSearch.

**Stale locks or corrupted state**

If a previous session crashed or left stale locks:

```bash
./scripts/error-recovery.sh
```

This script clears lock files in `.vibeos/`, repairs corrupted JSON state files,
and resets any in-progress tasks that were interrupted.

---

## License

MIT -- see [LICENSE](LICENSE) for details.

## Author

[Fabian Krumbholz](https://github.com/fabkrum)
