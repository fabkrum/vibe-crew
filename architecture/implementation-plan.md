# VibeCrew Implementation Plan

> Phased roadmap for building the VibeCrew Claude Code plugin from foundation through polish. Each phase builds on the previous, with clear deliverables, acceptance criteria, and risk assessment.
>
> **v1.0 scope:** 5 agents, 9 skills, Agent Teams API coordination, worktree-based isolation. Total: 16-23 sessions, ~60-70 files. Performance Coach, Doc Generator, and existing project onboarding are deferred to v1.1.

---

## Conventions

- **Session** = one Claude Code session (typically 30-90 minutes of focused work before context pressure).
- **Effort estimates** assume a single developer working with Claude Code.
- **Deliverable counts** are approximate -- some phases may split or merge files during implementation.
- **Schema references** point to `architecture/schemas.md`, the single source of truth for all `.vibecrew/` JSON file schemas.

---

## Overview

### Agent Topology (v1.0)

| # | Agent | Model | Isolation | Role |
|---|-------|-------|-----------|------|
| 1 | Session Startup | Haiku | Inline | Environment check, state detection, routing |
| 2 | Workflow Orchestrator | Opus | Inline | Tier routing, Agent Teams coordination |
| 3 | Stack Scout | Opus | Worktree | Read-only research, TDR output |
| 4 | Builder | Opus | Worktree | Merged UI Designer + Feature Developer |
| 5 | Verifier | Haiku | Inline | Merged Test Writer + Quality Check + scoring |

### Timeline Summary

| Phase | Description | Sessions |
|-------|-------------|----------|
| Phase 1 | Foundation -- plugin scaffold, hooks, scripts, settings.json | 3-4 |
| Phase 2 | Core Agents -- 5 agent definitions + Agent Teams integration | 4-6 |
| Phase 3 | Quality Layer -- Verifier integration, Vibe Score, test infrastructure | 3-4 |
| Phase 4 | Documentation -- minimal VitePress site (Kanban + stats) | 2-3 |
| Phase 5 | Intelligence Layer -- context re-injection, cost guardrails, CLAUDE.md pruning | 2-3 |
| Phase 6 | Polish -- end-to-end testing, README, plugin packaging | 2-3 |
| **Total** | | **16-23** |

### Critical Path

```
Phase 1: Foundation
    |
    v
Phase 2: Core Agents -----> Phase 5: Intelligence Layer
    |                               |
    v                               |
Phase 3: Quality Layer              |
    |                               |
    v                               v
Phase 4: Documentation    Phase 6: Polish <---+
    |                               ^         |
    +-------------------------------+         |
```

**Longest sequential chain:** Phase 1 -> Phase 2 -> Phase 3 -> Phase 6.

**Parallelizable work:** Phase 4 (Documentation) and Phase 5 (Intelligence Layer) can proceed in parallel after Phase 2 completes. Both converge at Phase 6.

---

## Phase 1: Foundation

**Complexity: High** | **Estimated effort: 3-4 sessions** | **Dependencies: None**

### Goal

Build the plugin skeleton, safety layer, session startup hook, and runtime state directory. This phase produces a plugin that installs cleanly, enforces safety rules via deterministic bash scripts, and initializes the `.vibecrew/` state directory. No agents or slash commands yet -- just the structural spine and protective shell.

### Key Deliverables (~14 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `.claude-plugin/plugin.json` | Plugin manifest: name, version, entry points, required Claude Code version |
| 2 | `hooks/hooks.json` | Event-to-script routing table for all lifecycle hooks |
| 3 | `scripts/session-startup.sh` | SessionStart hook: environment check (git, gh, node, jq, terminal-notifier), state detection, routing |
| 4 | `scripts/compact-reinject.sh` | SessionStart (compact matcher): re-injects state.json summary after context compaction |
| 5 | `scripts/protect-data.sh` | PreToolUse (Bash): blocks 40+ dangerous shell patterns (rm -rf, DROP TABLE, force push, sudo) |
| 6 | `scripts/restrict-paths.sh` | PreToolUse (Write/Edit): validates writes are within project root, blocks .git/, .env, credentials |
| 7 | `scripts/phase-gate.sh` | PreToolUse (Write/Edit): blocks source code writes until `foundation.complete == true` in state.json |
| 8 | `scripts/format-code.sh` | PostToolUse (Write/Edit): auto-detects file type, runs appropriate formatter. Silent skip if none found. |
| 9 | `scripts/notify.sh` | Notification + PostToolUseFailure: OS notifications with Warp deep-linking via WARP_SESSION_ID |
| 10 | `scripts/check-context.sh` | Stop hook: monitors context window usage, warns at 60%/80%/90% thresholds |
| 11 | `settings.json` | Declarative deny rules: 40+ blocked command patterns (defense in depth alongside hook scripts) |
| 12 | `.mcp.json` | MCP server configuration for Context7 and Chrome DevTools |
| 13 | `scripts/init-vibecrew-state.sh` | Creates `.vibecrew/` directory with initial config.json, state.json, backlog.json (schemas per `architecture/schemas.md`) |
| 14 | `LICENSE` | MIT license |

### Dependencies

None. This is the starting point.

### Acceptance Criteria

1. **Plugin installs cleanly**: `claude plugin install /path/to/claude-plugin-vibe-crew` succeeds. Claude Code detects the plugin on next session start.
2. **Hooks bind correctly**: All registered hooks appear with correct event-to-script mappings.
3. **Safety layer blocks dangerous commands**: `rm -rf /`, `git push --force origin main`, `DROP TABLE`, `sudo`, and `chmod 777` are all blocked with exit code 2 and descriptive messages.
4. **Path restriction works**: Writes outside the project root are blocked. Writes to `.git/` internals are blocked.
5. **Phase gate enforces Tier 1**: Writes to `src/`, `app/`, `lib/`, `components/` are blocked when `foundation.complete` is `false`. Writes to `.vibecrew/`, `CLAUDE.md`, `VISION.md`, and `docs/` are always allowed.
6. **State directory initializes**: `init-vibecrew-state.sh` creates the full `.vibecrew/` tree with valid JSON files matching the schemas in `architecture/schemas.md`.
7. **Context re-injection works**: After a compaction event, the compact-reinject.sh script outputs a valid JSON summary of project state.
8. **Notifications degrade gracefully**: Warp deep-link > terminal-notifier > osascript > terminal bell > silent log.

### Agent Teams Integration Points

None in this phase. Agent Teams is introduced in Phase 2.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Claude Code plugin API changes between design and implementation | Medium | High | Pin to Claude Code 2.0+ API. Design hooks against documented lifecycle events. |
| `settings.json` deny rules too aggressive | Medium | Medium | Start with conservative patterns. Document how to disable specific rules. |
| Bash script portability (macOS vs Linux) | Low | Medium | Use POSIX-compatible constructs. Test on macOS (primary) and Ubuntu. |

---

## Phase 2: Core Agents

**Complexity: High** | **Estimated effort: 4-6 sessions** | **Dependencies: Phase 1**

### Goal

Define all five agent prompts, implement the first five slash commands (/setup, /new-project, /status, /idea, /plan-features), configure Agent Teams API coordination, and create the foundational templates. This phase transforms the plugin from a passive safety layer into an active workflow engine with the full Tier 1 foundation workflow operational.

### Key Deliverables (~22 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `agents/session-startup.md` | Haiku agent: environment check, state detection, 3-line status summary, routing |
| 2 | `agents/workflow-orchestrator.md` | Opus agent: Tier 1/Tier 2 routing, Agent Teams coordination, state management |
| 3 | `agents/stack-scout.md` | Opus agent: read-only research with WebSearch, Context7, Chrome DevTools. `isolation: worktree`. |
| 4 | `agents/builder.md` | Opus agent: design system (Tier 1) + component design + feature implementation (Tier 2). `isolation: worktree`. |
| 5 | `agents/verifier.md` | Haiku agent: TDD-hybrid testing, quality checks, Vibe Score calculation |
| 6 | `skills/setup/SKILL.md` | /setup: interactive wizard -- terminal selection, notification test, MCP verification, .vibecrew/ init |
| 7 | `skills/new-project/SKILL.md` | /new-project: guided 5-step Tier 1 foundation -- VISION.md, design-system.css, TDR, roadmap, CLAUDE.md |
| 8 | `skills/status/SKILL.md` | /status: read-only dashboard with dynamic context injection |
| 9 | `skills/idea/SKILL.md` | /idea: zero-disruption backlog capture. Exactly one line of output. |
| 10 | `skills/plan-features/SKILL.md` | /plan-features: interactive planning session with feature specs and acceptance criteria |
| 11 | `templates/VISION.md.template` | Vision document: problem statement, personas, value proposition, constraints, success metrics |
| 12 | `templates/tdr.md.template` | Technology Decision Record: context, options, decision, consequences, token impact |
| 13 | `templates/roadmap.md.template` | Feature roadmap: priority tiers, dependencies, out-of-scope section |
| 14 | `templates/design-system.css.template` | Base design system CSS custom properties: colors (HSL), typography, spacing, radii |
| 15 | `templates/feature-spec.md.template` | Feature specification: acceptance criteria, UI description, business logic, complexity |
| 16 | `templates/CLAUDE.md.template` | Base CLAUDE.md: tech stack, conventions, session learnings, references |
| 17 | `templates/config.json.template` | Default config.json matching the schema in `architecture/schemas.md` Section 2 |
| 18 | `templates/state.json.template` | Default state.json matching the schema in `architecture/schemas.md` Section 3 |
| 19 | `templates/backlog.json.template` | Default backlog.json matching the schema in `architecture/schemas.md` Section 4 |
| 20 | `scripts/complete-phase.sh` | Utility: advances a feature's phase in backlog.json with lock-based concurrency control |
| 21 | `scripts/claim-task.sh` | Utility: atomically claims a ready feature for an agent using advisory locks |
| 22 | `scripts/update-backlog.sh` | Utility: updates feature fields in backlog.json with validation |

### Dependencies

Phase 1 must be complete. All hook scripts and the plugin manifest must be functional.

### Acceptance Criteria

1. **Session Startup runs on every session**: Opens Claude Code in a VibeCrew project, Session Startup activates automatically, prints a 3-line status summary under 200 words.
2. **/setup completes full wizard**: Terminal selection, notification test, MCP verification, .vibecrew/ initialization. Config persisted to `.vibecrew/config.json`.
3. **/new-project produces all 5 foundation artifacts**: VISION.md, design-system.css, TDR, roadmap.md, and CLAUDE.md created. `state.json` updated to `foundation.complete: true`. Phase gate unlocks.
4. **Stack Scout runs in isolated worktree**: Research tokens stay outside the main session. Only the TDR result returns to the parent context.
5. **/status is read-only**: Dashboard with no side effects -- no state mutations, no file writes, no git operations.
6. **/idea captures instantly**: Appends to backlog.json, returns one line, no follow-up questions.
7. **/plan-features populates backlog**: Features get specs with acceptance criteria, priorities, and dependencies.
8. **Agent Teams coordination works**: Orchestrator can create teams, assign tasks, and receive completion messages via the Agent Teams API.
9. **Shared state scripts work atomically**: `complete-phase.sh`, `claim-task.sh`, and `update-backlog.sh` use advisory locks and produce valid JSON.

### Agent Teams Integration Points

- **TeamCreate**: Orchestrator creates teams for feature development (e.g., `feat-001-user-auth`).
- **TaskCreate**: Orchestrator assigns design/code tasks to Builder, research tasks to Stack Scout.
- **SendMessage**: Orchestrator sends coordination messages and receives completion notifications.
- **Signal files** (`.vibecrew/signals/`): Agents write structured payloads for handoff data (TDR summaries, test results). See `architecture/schemas.md` Section 7.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Agent prompt quality -- verbose or inconsistent output | High | High | Iterative prompt engineering. Test each prompt in isolation with 5+ scenarios. Strict output contracts (word limits, required sections). Budget 30% of phase for refinement. |
| Stack Scout context isolation -- tokens leak into parent | Medium | High | Verify Claude Code subagent isolation. If tokens leak, switch to file-based handoff (agent writes TDR to disk, parent reads file). |
| Agent Teams API behavior differs from expectations | Medium | Medium | Test API surface early in Phase 2. Fall back to signal-file-only coordination if API is unstable. |

---

## Phase 3: Quality Layer

**Complexity: Medium** | **Estimated effort: 3-4 sessions** | **Dependencies: Phase 2**

### Goal

Integrate the Verifier agent's full pipeline: TDD-hybrid test writing, quality gate execution, Vibe Score calculation, and session logging. Implement the /check, /wrap, /new-feature, and /run-backlog slash commands. Set up Vitest with coverage thresholds and Playwright for E2E/accessibility testing.

### Key Deliverables (~15 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `skills/check/SKILL.md` | /check: runs Verifier for tests, build, lint. Reports pass/fail summary. |
| 2 | `skills/wrap/SKILL.md` | /wrap: quality gate, Vibe Score, session log, git commit, optional PR |
| 3 | `skills/new-feature/SKILL.md` | /new-feature: foundation check, branch creation, phase tracker, agent handoff |
| 4 | `skills/run-backlog/SKILL.md` | /run-backlog: automated loop -- picks ready features, runs all phases, quality gate between features |
| 5 | `templates/vitest.config.ts.template` | Vitest config: coverage thresholds (80% statements, 70% branches), reporters |
| 6 | `templates/playwright.config.ts.template` | Playwright config: Chromium, Firefox, WebKit, base URL on test server |
| 7 | `templates/axe-config.ts.template` | axe-core accessibility configuration for WCAG 2.1 AA |
| 8 | `templates/test-utils.ts.template` | Shared test utilities: custom render, mock factories, a11y helpers |
| 9 | `templates/session-log.json.template` | Session log schema (see `architecture/schemas.md` Section 5) |
| 10 | `templates/score-breakdown.json.template` | Vibe Score breakdown schema (see `architecture/schemas.md` Section 6) |
| 11 | `scripts/calculate-vibe-score.sh` | Pre-calculation of score metrics from transcript .jsonl: prompt churn, tool loops, cache ratio |
| 12 | `scripts/generate-release-notes.sh` | Parses git log (conventional commits), generates structured release notes JSON |
| 13 | `scripts/detect-terminal.sh` | Utility: detects Warp, iTerm2, VS Code, Terminal.app and sets notification method |
| 14 | `scripts/git-branch-create.sh` | Utility: creates feature branches with sanitized names from feature titles |
| 15 | `scripts/git-commit-validate.sh` | PreToolUse (Bash) helper: enforces conventional commit format |

### Dependencies

Phase 2 must be complete. All 5 agents must be defined and the Agent Teams coordination flow must work.

### Acceptance Criteria

1. **Verifier produces spec-first tests**: Given a feature spec, the Verifier generates test files that describe expected behavior before implementation. Tests fail initially (red phase of TDD).
2. **Verifier produces impl-first tests**: Given a completed component, the Verifier generates integration tests covering rendering, interaction, and edge cases.
3. **/check completes in under 2 minutes**: For a standard Node.js project with 50 tests, runs tests + build + lint within 120 seconds.
4. **/wrap completes full sequence**: Quality gate, Vibe Score calculation, session log creation, git commit with conventional format, optional PR.
5. **Vibe Score calculates correctly**: Score 0-100 with itemized deductions/bonuses matching the formula in `architecture/schemas.md` Section 6.
6. **/new-feature creates a full feature session**: Branch, worktree, phase tracker initialization, feature spec loading, agent handoff.
7. **/run-backlog executes autonomously**: Picks features in priority order, respects dependencies, runs quality gates between features, stops on failure or completion.
8. **Session logs are persisted**: After /wrap, valid JSON exists in `.vibecrew/sessions/` matching the session log schema.

### Agent Teams Integration Points

- **/new-feature** creates a team (`TeamCreate`) and assigns the Builder for design+code phases.
- **/run-backlog** creates teams per feature and orchestrates the full Plan -> Design -> Code -> Test -> Docs cycle.
- Verifier receives tasks via `TaskCreate` when Builder signals completion.
- Quality gate results are communicated back to Orchestrator via `SendMessage` and signal files.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Vibe Score feels arbitrary or unfair | Medium | Medium | Provide full itemized breakdown. Show evidence for each deduction. Tune weights based on feedback in first 10 sessions. |
| /run-backlog infinite loop on persistent quality gate failure | Medium | Medium | Max 3 retries per feature. After 3 failures, mark as "blocked" and move to next. Notify via OS notification. |
| Transcript .jsonl format changes between Claude Code versions | Medium | High | Abstract parsing into calculate-vibe-score.sh. Pin expected field names in documentation. |

---

## Phase 4: Documentation

**Complexity: Low** | **Estimated effort: 2-3 sessions** | **Dependencies: Phase 3**

### Goal

Build a minimal VitePress documentation site with a Kanban board (reading from backlog.json) and a basic stats page. This is a 60% scope reduction from the original plan -- complex Chart.js dashboards, trend visualizations, and 7 Vue components are deferred to v1.1.

### Key Deliverables (~10 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `templates/docs-site/package.json` | VitePress dependencies and scripts (dev, build, preview) |
| 2 | `templates/docs-site/.vitepress/config.ts` | VitePress configuration: site title, navigation, sidebar, port 3002 |
| 3 | `templates/docs-site/index.md` | Documentation site homepage with project overview |
| 4 | `templates/docs-site/system/getting-started.md` | System docs: VibeCrew installation and setup guide |
| 5 | `templates/docs-site/system/commands.md` | System docs: all 9 slash command references |
| 6 | `templates/docs-site/components/KanbanBoard.vue` | Kanban board reading from backlog.json -- columns for idea, planned, in-progress, testing, review, done |
| 7 | `templates/docs-site/components/StatsPage.vue` | Basic statistics: total sessions, features completed, average Vibe Score, total tokens |
| 8 | `templates/docs-site/data/backlog.data.ts` | VitePress data loader: reads .vibecrew/backlog.json, maps features to Kanban columns |
| 9 | `templates/docs-site/data/sessions.data.ts` | VitePress data loader: reads .vibecrew/sessions/*.json, aggregates session statistics |
| 10 | `scripts/update-docs.sh` | PostToolUse helper: triggers VitePress rebuild after documentation changes |

### Dependencies

Phase 3 must be complete. The `.vibecrew/` state files (sessions, scores, backlog) must have defined schemas and working read/write paths.

### Acceptance Criteria

1. **VitePress site builds and serves**: `npm run docs:dev` starts on port 3002 without errors.
2. **Kanban board reads backlog.json**: Features appear in correct columns based on their `column` field. Read-only display, no drag-and-drop.
3. **Stats page displays real data**: With sample `.vibecrew/` data, the stats page renders session count, feature count, average Vibe Score, and total tokens.
4. **Data loaders handle empty state**: When `.vibecrew/` directories are empty, zero-state messages appear instead of errors.
5. **System docs are accurate**: Getting-started guide and command reference match the actual plugin behavior.

### Agent Teams Integration Points

None directly. The docs site reads from `.vibecrew/` state files that are populated by agents during normal workflow.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| VitePress version incompatibility with Vue components | Low | Medium | Pin VitePress version. Test components against pinned version. |
| Scope creep toward full dashboard | Medium | Low | Strict scope: only KanbanBoard.vue and StatsPage.vue. No charts, no trend lines. Defer to v1.1. |

---

## Phase 5: Intelligence Layer

**Complexity: Medium** | **Estimated effort: 2-3 sessions** | **Dependencies: Phase 2**

### Goal

Build the intelligence features that make VibeCrew self-aware: context re-injection after compaction (building on the Phase 1 compact-reinject.sh), cost guardrails (session and daily spend tracking), CLAUDE.md size monitoring and pruning recommendations, and enhanced session analysis. This phase makes the system smarter about resource management.

### Key Deliverables (~8 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `scripts/compact-reinject.sh` (enhanced) | Enhanced re-injection: includes active feature context, recent commits, and worktree state alongside foundation status |
| 2 | `scripts/cost-guardrails.sh` | Monitors session cost against `config.json` limits (`session_warn_usd`, `session_max_usd`, `daily_warn_usd`). Warns or pauses agent. |
| 3 | `scripts/claude-md-lint.sh` | Validates CLAUDE.md: checks line count (<500), detects duplicate rules, flags inlined documentation, reports bloat |
| 4 | `scripts/migrate-state.sh` | Schema migration: reads `schema_version` from each .vibecrew/ file, applies sequential migrations (see `architecture/schemas.md` Section 9) |
| 5 | `scripts/sync-state.sh` | Reconciles state.json and backlog.json when inconsistencies are detected (e.g., active feature mismatch) |
| 6 | `templates/mutation-log.json.template` | Log for future CLAUDE.md mutations: timestamp, session_id, proposed_rule, reasoning. Prepares data structure for v1.1 Performance Coach. |
| 7 | `scripts/error-recovery.sh` | Common error recovery: stale lock cleanup, port conflict resolution, orphaned process cleanup, git state recovery |
| 8 | `scripts/validate-plugin.sh` | Self-test: validates all files exist, hooks.json references valid scripts, scripts are executable, JSON templates are valid |

### Dependencies

Phase 2 must be complete (agents defined, state files in use). Can run in parallel with Phase 3 and Phase 4.

### Acceptance Criteria

1. **Context re-injection is complete**: After compaction, the re-injected summary includes foundation status, active feature with phase, recent commits, and worktree path. Under 300 tokens.
2. **Cost guardrails trigger correctly**: When session cost exceeds `session_warn_usd`, a warning appears. When it exceeds `session_max_usd`, the agent pauses and asks the user for permission to continue.
3. **CLAUDE.md lint reports accurately**: Detects files over 500 lines, identifies duplicate rules, flags inlined content that should reference external files.
4. **State migration works**: Files with older `schema_version` are migrated forward. Files with newer versions are refused with a warning.
5. **Plugin self-test passes**: `validate-plugin.sh` confirms all files exist, scripts are executable, and JSON is valid.
6. **Error recovery handles common failures**: Stale locks, port conflicts, orphaned processes, and git conflicts are detected and resolved or reported clearly.

### Agent Teams Integration Points

- Cost guardrails integrate with the Orchestrator's session monitoring. If `session_max_usd` is exceeded, the Orchestrator pauses all active agent tasks.
- State sync (`sync-state.sh`) is called by the Orchestrator's verification loop when inconsistencies are detected (see `architecture/agents.md` Section 4, Verification Loop Step 4).

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Cost estimation inaccuracy | Medium | Low | Use Claude Code's reported token counts and published pricing. Estimates are advisory, not billing -- err on the conservative side. |
| CLAUDE.md pruning removes valuable rules | Low | Medium | Lint only recommends, never auto-deletes. All pruning requires explicit user approval. |

---

## Phase 6: Polish

**Complexity: Low** | **Estimated effort: 2-3 sessions** | **Dependencies: Phases 1-5**

### Goal

End-to-end testing across the full workflow (Tier 1 foundation through Tier 2 feature cycle), final documentation (README, CHANGELOG), plugin packaging for distribution, and edge case hardening. This phase turns the plugin from functional into shippable.

### Key Deliverables (~8 files)

| # | File | Purpose |
|---|------|---------|
| 1 | `README.md` | Plugin README: installation, quick start, command reference, architecture overview, troubleshooting |
| 2 | `CHANGELOG.md` | Plugin changelog following Keep a Changelog format |
| 3 | `scripts/uninstall.sh` | Clean removal: removes plugin files, optionally .vibecrew/. Does not touch source code. |
| 4 | `scripts/extract-design-system.sh` | Uses Chrome DevTools MCP to extract color, typography, spacing from a reference URL. Outputs design-system.css tokens. |
| 5 | `templates/gitignore-additions.template` | Recommended .gitignore additions for VibeCrew projects (.vibecrew/config.json, signals/, locks/) |
| 6 | `templates/CONTRIBUTING.md.template` | Contribution guide for plugin development |
| 7 | `hooks/hooks.json` (finalized) | Final hook routing table with all bindings verified and tested |
| 8 | `scripts/notify.sh` (finalized) | Finalized notification: full Warp deep-linking, iTerm2 OSC 9, VS Code, Terminal.app fallback |

### Dependencies

All previous phases must be complete.

### Acceptance Criteria

1. **End-to-end Tier 1 works**: A fresh project runs /setup -> /new-project and produces all 5 foundation artifacts. Phase gate unlocks. Zero manual intervention required after initial user inputs.
2. **End-to-end Tier 2 works**: A feature goes from /new-feature through all 5 phases (plan, design, code, test, docs) and produces a PR. Quality gate passes.
3. **Plugin self-test passes**: `validate-plugin.sh` confirms all files exist, scripts are executable, hooks reference valid scripts.
4. **README is complete**: Installation (<5 minutes), quick start, command reference, architecture overview, troubleshooting section.
5. **Uninstall is clean**: `uninstall.sh` removes all plugin files without affecting project source code.
6. **Edge cases handled**: Stale lock files, port conflicts, orphaned processes, git merge conflicts, missing MCP servers, missing formatters -- all detected and handled gracefully.
7. **All 9 slash commands work**: /setup, /new-project, /plan-features, /new-feature, /run-backlog, /idea, /status, /check, /wrap all produce correct behavior.

### Agent Teams Integration Points

- End-to-end testing validates the full Agent Teams workflow: TeamCreate -> TaskCreate -> Builder works in worktree -> SendMessage completion -> Verifier runs tests -> feature advances through Kanban.

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Design system extraction produces inaccurate tokens | Medium | Low | Extraction is a starting point. Builder validates and adjusts. User reviews during /new-project. Chrome DevTools is optional -- manual input fallback exists. |
| E2E tests reveal integration issues across phases | High | Medium | Budget extra time for integration debugging. Fix issues inline rather than deferring. |

---

## Total Estimated Effort

| Phase | Complexity | Sessions | Cumulative |
|-------|-----------|----------|------------|
| Phase 1: Foundation | High | 3-4 | 3-4 |
| Phase 2: Core Agents | High | 4-6 | 7-10 |
| Phase 3: Quality Layer | Medium | 3-4 | 10-14 |
| Phase 4: Documentation | Low | 2-3 | 12-17 |
| Phase 5: Intelligence Layer | Medium | 2-3 | 14-20 |
| Phase 6: Polish | Low | 2-3 | 16-23 |
| **Total** | | **16-23** | |

**Total deliverables**: ~60-70 files across all phases.

- 5 agent `.md` files
- 9 skill `SKILL.md` files
- ~8 hook/automation scripts (session-startup.sh, compact-reinject.sh, phase-gate.sh, protect-data.sh, restrict-paths.sh, format-code.sh, notify.sh, check-context.sh)
- ~8 utility scripts (init-vibecrew-state.sh, complete-phase.sh, claim-task.sh, update-backlog.sh, calculate-vibe-score.sh, cost-guardrails.sh, validate-plugin.sh, etc.)
- ~10 templates (JSON schemas, CSS, markdown)
- ~10 docs-site files (VitePress config, 2 Vue components, 2 data loaders, markdown pages)
- ~5 supporting files (README, CHANGELOG, LICENSE, settings.json, .mcp.json, plugin.json)

**Realistic timeline**: 2-3 weeks of focused development (assuming 1-3 sessions per day).

### Optimal Execution Strategy

Run two parallel tracks after Phase 2:

- **Track A**: Phase 3 (Quality) -> Phase 6 (Polish)
- **Track B**: Phase 4 (Documentation) + Phase 5 (Intelligence) -> Phase 6 (Polish)

Both tracks converge at Phase 6. This reduces elapsed time by approximately 25%.

---

## v1.1 Roadmap

The following items are explicitly deferred from v1.0 and will be addressed in v1.1:

| Item | Description | Why Deferred |
|------|-------------|--------------|
| **Performance Coach** | Standalone agent with `memory: project`, cross-session trend analysis, CLAUDE.md mutation proposals, historical comparison | Requires persistent memory infrastructure and careful approval workflow. v1.0 Verifier handles basic scoring. |
| **Doc Generator** | Standalone agent for VitePress maintenance, automated release notes, feature documentation, CHANGELOG | Not critical-path for feature development. v1.0 handles docs inline during /wrap. |
| **Existing Project Onboarding** | Code audit workflow, test gap analysis, CLAUDE.md generation from detected patterns, state initialization reflecting project maturity | Complex, requires separate agent (code-auditor). v1.0 targets greenfield projects. |
| **Full Documentation Dashboard** | Chart.js visualizations, ScoreTrend.vue, TokenBreakdown.vue, CoverageGauge.vue, FeatureProgress.vue (5 additional Vue components) | Scope reduction. v1.0 ships Kanban + basic stats only. |
| **Cross-session Vibe Score trends** | Historical score comparison, trend lines, improvement tracking | Requires persistent data aggregation. v1.0 provides per-session scores. |
| **CLAUDE.md mutation proposals** | Automated rule suggestions based on anti-pattern detection, with developer approval workflow | Requires Performance Coach agent with persistent memory. |
| **Progressive onboarding** | Guided first-session experience, tooltips, feature discovery | Polish item. v1.0 relies on /setup wizard and README. |

---

## Risk Register

### Top 5 Risks Across All Phases

| # | Risk | Phases | Likelihood | Impact | Mitigation |
|---|------|--------|-----------|--------|------------|
| 1 | **Claude Code plugin API instability** -- plugin format, hook events, or subagent behavior changes | All | Medium | Critical | Pin to Claude Code 2.0+ surface. Abstract Claude Code-specific calls behind utility scripts so API changes require updating one file. Monitor release notes weekly. |
| 2 | **Agent prompt quality and consistency** -- prompts produce verbose, inconsistent, or off-target output | 2, 3, 6 | High | High | Dedicated testing per prompt (5+ scenarios). Strict output contracts (word limits, JSON schemas). Budget 30% of agent phases for refinement. Maintain prompt regression test suite. |
| 3 | **Context window management across multi-agent workflows** -- subagent isolation may not fully prevent token leakage | 2, 5 | Medium | High | Measure actual token consumption during Phase 2 testing. If tokens leak, switch to file-based handoff. Keep agent output contracts under 500 tokens. Target under 50% context usage per workflow. |
| 4 | **Agent Teams API reliability** -- API may be new and behavior may differ from expectations | 2, 3 | Medium | Medium | Test API surface early in Phase 2. Retain signal-file coordination as fallback. Design all handoffs to work with degraded API availability. |
| 5 | **Scope creep** -- tendency to add features beyond v1.0 boundaries | All | High | Medium | Strict v1.0/v1.1 boundary. Any new feature request goes to v1.1 backlog. Review scope weekly. The v1.1 Roadmap section above is the parking lot. |

---

## Implementation Principles

These principles govern all implementation work across all phases.

1. **Test each phase in isolation before integrating.** Phase 1's hooks should be tested without agents. Phase 2's agents should be tested without Phase 3's quality layer.

2. **Agent prompts are the hardest deliverable.** Budget 30% of each agent-related phase for prompt engineering. A well-crafted 200-line prompt is worth more than 2,000 lines of bash.

3. **Bash scripts must be idempotent.** Every script in `scripts/` must be safe to run multiple times. No "already exists" errors, no duplicate entries, no corrupted state.

4. **JSON schemas are contracts.** The `.vibecrew/` schemas defined in `architecture/schemas.md` are the data contracts between agents, scripts, and the docs site. Changing a schema requires updating all consumers.

5. **Fail open, not closed.** If a hook script encounters an unexpected error (jq not installed, malformed JSON, missing file), it should exit 0 and log a warning -- not exit 2 and block the operation. Exception: safety scripts (protect-data.sh, restrict-paths.sh) fail closed.

6. **Measure token consumption continuously.** From Phase 2 onward, track actual token usage for every agent interaction. If any single operation exceeds 30% of the context window, redesign it.

7. **Ship incrementally.** Each phase produces a usable plugin. After Phase 1: safety enforcement. After Phase 2: full Tier 1 workflow. After Phase 3: quality gates and scoring. The plugin is never "all or nothing."
