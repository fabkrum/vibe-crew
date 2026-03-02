# VibeCrew

**Autonomous vibe-coding operating system for Claude Code.**

VibeCrew is a Claude Code plugin that transforms your terminal into a managed
software development environment. It orchestrates specialized agents, enforces
architecture-before-code discipline, and keeps you informed only when your
attention is needed -- permission stalls, task completions, and critical failures.

---

## Quick Install

**Option A: Bootstrap script (installs everything)**

```bash
cd claude-plugin-vibe-crew
./install.sh
```

This detects your OS and package manager, installs any missing dependencies, and
prompts for GitHub CLI authentication. Pass `--yes` to skip confirmation prompts.

**Option B: Manual install**

| Dependency | Tier | Minimum Version | Installation |
|---|---|---|---|
| Git | Required | 2.30+ | Pre-installed on macOS |
| Node.js | Required | 18+ | `brew install node` |
| `jq` | Required | any | `brew install jq` |
| GitHub CLI (`gh`) | Optional | 2.0+ | `brew install gh` |
| `terminal-notifier` (macOS) | Optional | any | `brew install terminal-notifier` |

> **Note:** GitHub CLI is only needed for PR automation (`/review`, `gh pr create`).
> `terminal-notifier` enables desktop notifications. Both are optional — VibeCrew
> works without them.

**Install the plugin**

```bash
claude plugin install /path/to/claude-plugin-vibe-crew
```

Installation takes under 5 minutes. The plugin registers hooks, agents, slash
commands, permission rules, and optional MCP servers automatically. The `/setup`
command can also auto-install missing dependencies from within Claude Code.

**Optional MCP servers**

VibeCrew ships with configurations for 10 MCP servers in `.mcp.json`. They are
enabled or conditionally enabled based on TDR technology choices.

- **Context7** -- documentation lookup for popular frameworks and libraries.
- **Chrome DevTools** -- browser debugging and automation for visual testing and research.

---

## Documentation

VibeCrew ships with a full companion documentation website. Open any page locally
in your browser, or browse them on GitHub:

| Page | Description |
|---|---|
| [Why VibeCrew](../docs/why.html) | The three problems VibeCrew solves, core design philosophy, and principles. |
| [Setup Guide](../docs/setup.html) | Step-by-step installation, multi-project setup, Warp Terminal config. |
| [New Project](../docs/new-project.html) | Two-Tier Workflow: foundation (Tier 1) and 6-phase feature cycle (Tier 2). |
| [Existing Project](../docs/existing-project.html) | Onboard an existing codebase: code auditing, convention extraction, backlog mapping. |
| [Detailed Workflow](../docs/workflow.html) | Advanced commands, Opponent Processor, cost tracking, Vibe Score, efficiency tips. |
| [Example Session](../docs/example-session.html) | Full walkthrough: Day 1 foundation through parallel features, dev servers, best practices. |
| [Architecture](../docs/architecture.html) | 14-agent system, hooks, interrupt protocol, state management, VitePress dashboard. |
| [Warp Tips](../docs/warp.html) | Launch Configurations, keyboard shortcuts, Warp Drive, Notebooks, themes. |
| [Release Notes](../docs/releases.html) | Complete changelog from v1.0.0 through v1.7.0. |

> **Tip:** To browse the docs locally, open `docs/index.html` in your browser.

---

## Quick Start

1. Run `./install.sh` to install dependencies (or install them manually).
2. Install the plugin: `claude plugin install /path/to/claude-plugin-vibe-crew`
3. Open a new Claude Code session in any directory.
4. Run `/setup` to verify your environment and initialize VibeCrew. If any
   dependencies are missing, `/setup` offers to install them automatically.
5. Run `/new-project` to create a fresh project. VibeCrew walks you through
   Tier 1 (project foundation) before any source code can be written.
6. Run `/plan-features` to build your feature backlog.
7. Run `/new-feature "feature name"` to begin developing a feature through the
   Tier 2 cycle.
8. Run `/wrap` when you are done to generate session logs, release notes, and
   a Vibe Score breakdown.

---

## Commands Reference

VibeCrew provides 31 slash commands. Each command is defined in the `skills/`
directory and invoked directly from the Claude Code prompt.

### Project Setup

| Command | Description |
|---|---|
| `/setup` | Verify environment (Git, Node.js, jq required; gh, terminal-notifier optional), auto-install missing deps, health-check MCP servers, detect terminal, initialize `.vibecrew/` state directory. |
| `/new-project` | Create a new project and run through Tier 1: generate VISION.md, design-system.css, TDR, roadmap, and CLAUDE.md. Phase gate blocks source code writes until all foundation artifacts exist. |

### Planning

| Command | Description |
|---|---|
| `/plan-features` | Define and prioritize the feature backlog. Creates or updates `.vibecrew/backlog.json` with feature specs, priorities, and dependency ordering. |
| `/idea "text"` | Capture a quick idea and append it to the backlog as an unrefined item for later triage during `/plan-features`. |

### Development

| Command | Description |
|---|---|
| `/new-feature "name"` | Start the Tier 2 cycle for a specific feature: plan, design, code, test, review (optional), docs. Creates a feature branch and claims the task in the backlog. |
| `/run-backlog` | Autonomously process the next unclaimed feature from the backlog. Equivalent to `/new-feature` but picks the highest-priority item automatically. Includes automatic code review. |

### Onboarding

| Command | Description |
|---|---|
| `/onboard` | Onboard an existing project into VibeCrew. Analyzes the codebase, extracts conventions, generates a project-specific CLAUDE.md, and initializes state with `foundation.complete = true`. |

### Cost and Safety

| Command | Description |
|---|---|
| `/cost` | Display the real-time token cost dashboard: current session cost, daily/weekly/monthly aggregates, threshold proximity, and model pricing reference. |
| `/undo` | Checkpoint rollback: list VibeCrew checkpoints and recent commits, pick a target, and safely revert (pushed) or reset (unpushed) while preserving your working tree. |
| `/audit` | OWASP Top 10 security review: scan codebase for injection, auth, XSS, misconfig, and 7 more vulnerability categories. Runs dependency audit, secret detection, and optionally creates GitHub issues for critical findings. |
| `/heal` | Auto-heal failing CI: fetch logs from GitHub Actions, diagnose failure category (build/test/lint/dep/env), apply targeted fix (max 3 attempts), verify, and commit. Creates a checkpoint before any changes. |

### Code Quality

| Command | Description |
|---|---|
| `/tdd` | Vertical-slice TDD workflow: red-green-refactor cycles with automatic commit trailers. Plans test interfaces, writes one failing test, implements minimal code, refactors. |
| `/debug` | Four-phase systematic debugging: observe, hypothesize, test, verify. Generates ranked root cause hypotheses and saves reports to `.vibecrew/debug-reports/`. |
| `/review` | Structured code review against feature spec. Invokes Code Reviewer agent in worktree isolation. Findings classified as critical/warning/info. Optional in manual workflow, automatic in `/run-backlog`. |
| `/e2e` | Playwright E2E test generation with Page Object Model. Scaffolds Playwright if missing, generates accessible-first locators, runs with trace-on-failure. |
| `/perf-test` | k6 performance testing: load, stress, spike, soak profiles. Scaffolds k6 scripts from template, parses p95/p99 latency and error rates. |
| `/a11y` | WCAG 2.1 AA accessibility audit via axe-core + Playwright. Scans for violations by severity, checks keyboard navigation and ARIA attributes. |
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
produces six artifacts before any source code is written:

1. `VISION.md` -- product vision, target users, success criteria
2. `design-system.css` -- colors, typography, spacing, component tokens
3. `TDR` (Technology Decision Record) -- stack choices with rationale
4. `roadmap.md` -- phased delivery plan
5. Architecture Diagrams -- 5 Mermaid `.mmd` files (system, schema, state flows, API sequences, component tree)
6. `CLAUDE.md` -- project-specific rules for Claude Code

A phase gate hook (`phase-gate.sh`) blocks all Write and Edit operations on
source code files until every foundation artifact is present.

**Tier 2 -- Feature Development** is an iterative 6-phase cycle for each
feature:

1. **Plan** -- feature spec, acceptance criteria, task breakdown
2. **Design** -- UI/component design aligned to the design system
3. **Code** -- implementation within TDR boundaries
4. **Test** -- unit tests (Vitest), E2E tests (Playwright), accessibility (axe)
5. **Review** -- code review against spec (optional in manual workflow, automatic in `/run-backlog`)
6. **Docs** -- feature documentation, CHANGELOG entry, session log

### Agents

VibeCrew uses 14 specialized agents, each with a dedicated system prompt:

| Agent | Model | Execution | Role |
|---|---|---|---|
| Session Startup | Haiku | Inline | Environment check, state detection, handoff detection, progressive hints, routing. |
| Workflow Orchestrator | Opus | Inline | Routes between Tier 1 and Tier 2, coordinates agent handoffs, manages backlog state. |
| Stack Scout | Opus | Worktree | Read-only research agent. Uses WebSearch, Context7, and Chrome DevTools to produce Technology Decision Records in an isolated context. |
| Builder | Opus | Worktree | Implements features within TDR boundaries. Runs in a worktree to isolate work-in-progress from the main branch. |
| Verifier | Haiku | Inline | Runs quality checks (tests, lint, build, type-check), calculates Vibe Score. |
| Performance Coach | Opus | Inline | Cross-session trend analysis, anti-pattern detection, CLAUDE.md mutation proposals with 7-step guardrailed workflow. |
| Code Auditor | Opus | Worktree | Read-only codebase analysis for existing project onboarding. Extracts conventions, test gaps, and architecture patterns. |
| Security Auditor | Opus | Worktree | Read-only OWASP Top 10 security analysis. Scans for injection, auth, XSS, misconfig, vulnerable dependencies, secrets, and SSRF. |
| Doc Generator | Sonnet | Inline | Feature documentation, CHANGELOG updates, VitePress sidebar regeneration, release notes. |
| Code Simplifier | Opus | Worktree | Read-only code analysis for simplification: dead code, abstraction flattening, API reduction, dependency consolidation. |
| CI Healer | Opus | Inline | CI failure diagnosis and repair. Categorizes failures (build/test/lint/dep/env), applies targeted fixes with max 3 attempts. |
| Opponent Processor | Opus | Worktree | Devil's advocate for TDR decisions. Generates counter-arguments, debate matrices, and risk assessments for technology choices. |
| Code Reviewer | Opus | Worktree | Read-only code review against feature spec, TDR compliance, conventions, security surface, and performance anti-patterns. |
| System Reviewer | Opus | Worktree | Read-only plugin meta-analysis, cross-project telemetry, ecosystem research, and innovation proposals. |

### Hook System

Hooks enforce rules deterministically via bash scripts, consuming zero LLM
tokens. The `hooks/hooks.json` file binds 12 hook entries across 6 lifecycle
events:

| Event | Scripts | Purpose |
|---|---|---|
| SessionStart | `session-startup.sh`, `sync-state.sh`, `error-recovery.sh` | Initialize session, reconcile state, clear stale locks. |
| SessionStart (compact) | `compact-reinject.sh` | Re-inject project state after context compaction. |
| PreToolUse (Write/Edit) | `phase-gate.sh`, `restrict-paths.sh`, `validate-signal.sh` | Block source writes before foundation; validate write targets; validate signal file schema. |
| PreToolUse (Bash) | `protect-data.sh`, `validate-phase-transition.sh` | Block dangerous commands (rm -rf, force push, DROP TABLE); validate phase transition ordering. |
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
| **Feature · Phase** | `.vibecrew/state.json` | Feature name truncated to 16 chars. Falls back to "foundation · Tier-1" or "no project". |
| **Vibe Score** | Latest `.vibecrew/scores/score-*.json` | Shows trend suffix: `+` improving, `-` declining. |
| **Duration** | stdin `cost.total_duration_ms` | Displayed in minutes. |
| **Compactions** | Latest `.vibecrew/sessions/session-*.json` | Count of context compactions this session. |

The script (`scripts/statusline.sh`) gracefully degrades: if `jq` is missing
it shows "VibeCrew"; if `.vibecrew/` is absent it shows "no project".

### Interrupt Protocol

The system stays silent during normal operation. Notifications fire only on
three conditions:

1. **Permission stalls** (`permission_prompt`) -- the agent needs approval.
2. **Task completion** (`idle_prompt`) -- work is done, awaiting next instruction.
3. **Critical failures** (`PostToolUseFailure`) -- a tool call failed.

---

## File Structure

```
claude-plugin-vibe-crew/
  .claude-plugin/
    plugin.json                 # Plugin manifest (name, version, entry points)
  .mcp.json                    # Context7 + Chrome DevTools MCP server config
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
    code-reviewer.md           # Code Reviewer agent prompt
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
    tdd/SKILL.md               # /tdd command
    debug/SKILL.md             # /debug command
    review/SKILL.md            # /review command
    e2e/SKILL.md               # /e2e command
    perf-test/SKILL.md         # /perf-test command
    a11y/SKILL.md              # /a11y command
    achievements/SKILL.md      # /achievements command
    quiz/SKILL.md              # /quiz command
  scripts/                     # ~67 bash automation scripts
  templates/                   # Project templates and doc-site scaffold
  install.sh                   # Bootstrap script for dependency installation
  LICENSE                      # MIT License

.vibecrew/                       # Per-project runtime state (created by /setup)
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
  reviews/                     # Code review reports (/review)
  debug-reports/               # Debug session reports (/debug)
  a11y/                        # Accessibility audit reports (/a11y)
  perf-tests/                  # Performance test results (/perf-test)
```

---

## Testing

VibeCrew uses [BATS](https://github.com/bats-core/bats-core) (Bash Automated
Testing System) for all hook and script tests. The test framework is bundled in
the repository — no global installation required.

**Run all tests:**

```bash
./tests/bats/bin/bats tests/*.bats
```

**Run a single test file:**

```bash
./tests/bats/bin/bats tests/protect-data.bats
```

**Test suite structure:**

| Test file | Script under test | Coverage |
|---|---|---|
| `apply-mutation.bats` | `apply-mutation.sh` | CLAUDE.md mutation application |
| `atomic-write.bats` | `lib/atomic-write.sh` | Safe JSON file writes with backup/rollback |
| `check-deps.bats` | `check-deps.sh` | Dependency validation (Git, Node.js, jq, gh) |
| `check-mcp-health.bats` | `check-mcp-health.sh` | MCP server health checks |
| `claim-task.bats` | `claim-task.sh` | Backlog feature claiming with WIP limits |
| `compact-reinject.bats` | `compact-reinject.sh` | Context re-injection after `/compact` |
| `complete-phase.bats` | `complete-phase.sh` | Phase completion and state transitions |
| `cost-guardrails.bats` | `cost-guardrails.sh` | Session/daily cost threshold enforcement |
| `docs-build.bats` | — | Documentation site build verification |
| `error-log.bats` | `lib/error-log.sh` | JSONL error logging |
| `error-recovery.bats` | `error-recovery.sh` | Stale lock cleanup, git state detection |
| `init-vibecrew-state.bats` | `init-vibecrew-state.sh` | `.vibecrew/` directory initialization |
| `lock.bats` | `lib/lock.sh` | Advisory locking (state-files lock) |
| `lock-config.bats` | `lib/lock.sh` | Lock timeout configuration |
| `lock-named.bats` | `lib/lock.sh` | Named lock API (independent resource groups) |
| `migrate-state.bats` | `migrate-state.sh` | Schema version migrations (1.0.0 → 1.5.0) |
| `phase-gate.bats` | `phase-gate.sh` | Source code write blocking before foundation |
| `protect-data.bats` | `protect-data.sh` | Dangerous command blocking (9 categories, 54 patterns) |
| `quality-gate-timeout.bats` | `quality-gate.sh` | Quality gate timeout configuration |
| `restrict-paths.bats` | `restrict-paths.sh` | Write path restriction enforcement |
| `review-feedback-loop.bats` | `review-feedback-loop.sh` | Code review feedback generation |
| `session-startup.bats` | `session-startup.sh` | Session start routing and status output |
| `signal-schema.bats` | `validate-signal.sh` | Inter-agent signal file validation |
| `state-backup.bats` | `lib/atomic-write.sh` | State file backup and rotation |
| `sync-state.bats` | `sync-state.sh` | State file consistency checks |
| `update-backlog-raw.bats` | `update-backlog-raw.sh` | Safe backlog jq expressions |
| `update-state.bats` | `update-state.sh` | Safe state jq expressions |
| `validate-phase-transition.bats` | `validate-phase-transition.sh` | Phase ordering validation |
| `validate-signal.bats` | `validate-signal.sh` | Signal file schema and enum validation |
| `visual-verify.bats` | `visual-verify.sh` | Visual verification token parsing |
| `visual-verification-integration.bats` | — | Visual compliance scoring integration |

**Writing new tests:**

Tests use shared helpers from `tests/test_helper/common-setup.bash` which
provides `setup_vibecrew_dir`, `teardown_vibecrew_dir`, `set_active_feature`,
`set_foundation_complete`, `add_feature_to_backlog`, and hook input builders.

**Bash arithmetic pitfall:** All scripts use `set -euo pipefail`. When
incrementing counters, use `VAR=$(( VAR + 1 ))` instead of `((VAR++))` —
the latter evaluates to 0 (falsy) when `VAR` is 0, causing `set -e` to
terminate the script.

---

## Troubleshooting

**Phase gate blocked -- "VibeCrew designs before it codes"**

The phase gate hook prevents source code writes until all six Tier 1 artifacts
are complete (VISION.md, design-system.css, TDR, roadmap, architecture diagrams,
CLAUDE.md). The error message shows your progress (e.g., "2/6 artifacts complete")
and lists what's missing. Run `/status` for details, then `/new-project` to
continue the foundation.

**Notifications not working**

Verify `terminal-notifier` is installed:

```bash
which terminal-notifier
```

If missing, install it with `brew install terminal-notifier`. Check that
`.vibecrew/config.json` has `"notifications": true`. On macOS, ensure
System Settings > Notifications allows alerts from `terminal-notifier`.

**MCP servers not connecting**

MCP servers (Context7, Chrome DevTools) are optional. If they fail to start:

1. Verify Node.js 18+ is available: `node --version`
2. Test manually: `npx -y @upstash/context7-mcp@latest`
3. Check `.mcp.json` for correct configuration.
4. VibeCrew continues to function without MCP servers -- research agents fall
   back to WebSearch.

**Stale locks or corrupted state**

If a previous session crashed or left stale locks:

```bash
./scripts/error-recovery.sh
```

This script clears lock files in `.vibecrew/`, repairs corrupted JSON state files,
and resets any in-progress tasks that were interrupted.

---

## License

MIT -- see [LICENSE](LICENSE) for details.

## Author

[Fabian Krumbholz](https://github.com/fabkrum)
