# VibeCrew Agent & Command Routing Table

> Compact reference for the Workflow Orchestrator. Load on-demand instead of verbose agent descriptions.

## Slash Commands (31)

| Command | Agent | Phase | Description |
|---------|-------|-------|-------------|
| `/setup` | session-startup | — | Initialize VibeCrew in a project |
| `/new-project` | workflow-orchestrator | Tier 1 | Run sequential foundation (VISION → Design Discovery → TDR → roadmap → CLAUDE.md) |
| `/plan-features` | workflow-orchestrator | Tier 2 | Create/refine feature backlog with specs |
| `/new-feature "name"` | workflow-orchestrator | Tier 2 | Start feature: branch, state, phase tracker |
| `/run-backlog` | workflow-orchestrator | Tier 2 | Autonomous feature processing loop |
| `/idea "text"` | workflow-orchestrator | Tier 2 | Quick-add feature to backlog |
| `/status` | workflow-orchestrator | — | Project state, backlog, active teams |
| `/check` | verifier | — | Quality gate: tests + build + lint + types |
| `/wrap` | verifier | — | End session: score, log, commit, PR |
| `/heal` | ci-healer | — | Diagnose and fix CI failures (max 3 attempts) |
| `/simplify` | code-simplifier | Tier 2 | Dead code, abstraction flattening, API reduction |
| `/audit` | security-auditor | — | Existing project onboarding analysis |
| `/onboard` | code-auditor | — | Initialize state from audit findings |
| `/replay` | workflow-orchestrator | — | Re-run saved workflow templates |
| `/handoff` | doc-generator | — | Generate cross-session handoff document |
| `/cost` | verifier | — | Token usage and cost estimation |
| `/achievements` | verifier | — | Gamification dashboard: XP, badges, streaks |
| `/quiz` | verifier | — | Interactive learning quizzes |
| `/undo` | workflow-orchestrator | — | Rollback to last checkpoint |
| `/tdd` | builder | Tier 2 | Red-green-refactor TDD cycle |
| `/debug` | workflow-orchestrator | — | Four-phase systematic debugging |
| `/review` | code-reviewer | Tier 2 | Structured code review with severity levels |
| `/e2e` | verifier | Tier 2 | Playwright E2E with Page Object Model |
| `/perf-test` | verifier | — | k6 performance testing (load/stress/spike/soak) |
| `/a11y` | verifier | — | WCAG 2.1 AA accessibility audit via axe-core |
| `/profile` | session-startup | — | Personalize VibeCrew — user profile interview |
| `/apply-simplifications` | code-simplifier | Tier 2 | Apply approved simplification suggestions |
| `/reconsider` | opponent-processor | — | Re-run opponent analysis on specific decisions |
| `/recover-state` | workflow-orchestrator | — | Recover from corrupted state files |
| `/release` | doc-generator | — | Generate release notes and changelog |
| `/system-review` | system-reviewer | — | Cross-project telemetry and ecosystem analysis |

## Agent Registry (14)

| Agent | Model | Isolation | Triggers |
|-------|-------|-----------|----------|
| session-startup | haiku | inline | Every session start |
| workflow-orchestrator | opus | inline | `/new-project`, `/new-feature`, `/run-backlog`, `/status`, `/plan-features`, `/idea`, `/replay`, `/undo`, `/debug` |
| stack-scout | opus | worktree | TDR research (Tier 1 Step 3) |
| builder | opus | worktree | Design + code phases, `/tdd` |
| verifier | haiku | inline | `/check`, `/wrap`, `/cost`, `/achievements`, `/quiz`, `/e2e`, `/perf-test`, `/a11y` |
| performance-coach | opus | inline | `/wrap` Step 9.5 (after 5+ sessions) |
| code-auditor | opus | worktree | `/audit`, `/onboard` |
| security-auditor | opus | worktree | Security analysis (manual) |
| doc-generator | sonnet | inline | `/wrap` Step 10, `/handoff` |
| code-simplifier | opus | worktree | `/simplify` |
| ci-healer | opus | inline | `/heal` |
| opponent-processor | opus | worktree | TDR counter-analysis (Tier 1) |
| code-reviewer | opus | worktree | `/review`, `/run-backlog` Phase 4.5 |
| system-reviewer | opus | worktree | `/system-review` |

## State Routing Decision Table

| Condition | Action |
|-----------|--------|
| `.vibecrew/` missing | Prompt `/setup` |
| `foundation.complete == false` | Route to Tier 1 next incomplete artifact |
| `active_feature != null` | Resume feature at current phase |
| `active_feature == null` + backlog has `ready` | Suggest `/new-feature` or `/run-backlog` |
| `active_feature == null` + backlog empty | Suggest `/plan-features` |
| Signal file exists in `.vibecrew/signals/` | Process signal, advance state |
| Handoff file detected | Summarize previous session context |
