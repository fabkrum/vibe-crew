# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-23

### Added

#### Phase 1 -- Foundation (17 files)

Plugin scaffold and core infrastructure.

- `.claude-plugin/plugin.json` -- plugin manifest with name, version, author, and entry points
- `hooks/hooks.json` -- hook system with 10 bindings across 6 lifecycle events (SessionStart, PreToolUse, PostToolUse, Notification, PostToolUseFailure, Stop)
- `scripts/session-startup.sh` -- session initialization and environment detection
- `scripts/phase-gate.sh` -- blocks source code writes until Tier 1 foundation is complete
- `scripts/restrict-paths.sh` -- validates write targets against allowed directories
- `scripts/protect-data.sh` -- blocks dangerous bash commands (rm -rf, force push, DROP TABLE, sudo)
- `scripts/format-code.sh` -- auto-formats files after Write/Edit via Prettier
- `scripts/notify.sh` -- native OS notifications via terminal-notifier with Warp deep-linking
- `scripts/check-context.sh` -- context usage warnings at 60% and 80% thresholds
- `scripts/sandbox.sh` -- sandboxed command execution wrapper
- `scripts/check-deps.sh` -- dependency verification (Git, Node, gh, jq, terminal-notifier)
- `scripts/init-vibeos-state.sh` -- initializes `.vibeos/` state directory with config, state, and backlog
- `scripts/migrate-state.sh` -- state schema migration for version upgrades
- `settings.json` -- 68 permission rules (50 allowed tools, 18 denied tools)
- `.mcp.json` -- MCP server configuration for Context7 and Puppeteer
- `LICENSE` -- MIT license
- `templates/config.json.template` -- default `.vibeos/config.json` scaffold

#### Phase 2 -- Core Agents (22 files)

Agent definitions, project templates, and primary slash commands.

- `agents/session-startup.md` -- Session Startup agent prompt (Haiku model, inline execution)
- `agents/workflow-orchestrator.md` -- Workflow Orchestrator agent prompt (Sonnet model, inline execution)
- `agents/stack-scout.md` -- Stack Scout agent prompt (Sonnet model, worktree execution)
- `agents/builder.md` -- Builder agent prompt (Sonnet model, worktree execution)
- `agents/verifier.md` -- Verifier agent prompt (Sonnet model, inline execution)
- `templates/VISION.md.template` -- product vision document scaffold
- `templates/design-system.css.template` -- design tokens (colors, typography, spacing, components)
- `templates/tdr.md.template` -- Technology Decision Record scaffold
- `templates/roadmap.md.template` -- phased delivery plan scaffold
- `templates/CLAUDE.md.template` -- project-specific Claude Code rules scaffold
- `templates/state.json.template` -- foundation status and active feature state
- `templates/backlog.json.template` -- feature backlog with specs and priorities
- `templates/feature-spec.md.template` -- individual feature specification scaffold
- `skills/setup/SKILL.md` -- `/setup` command (environment check, state initialization)
- `skills/new-project/SKILL.md` -- `/new-project` command (Tier 1 foundation workflow)
- `skills/status/SKILL.md` -- `/status` command (project state display)
- `skills/idea/SKILL.md` -- `/idea` command (quick backlog capture)
- `skills/plan-features/SKILL.md` -- `/plan-features` command (backlog definition and prioritization)
- `scripts/claim-task.sh` -- claims a backlog task and sets it as active feature
- `scripts/complete-phase.sh` -- marks a Tier 2 phase as complete and advances workflow
- `scripts/update-backlog.sh` -- updates backlog.json with new items or status changes
- `scripts/detect-terminal.sh` -- detects terminal type (Warp, iTerm2, Terminal.app) for notification routing

#### Phase 3 -- Quality Layer (15 files)

Remaining slash commands, test infrastructure templates, and quality scripts.

- `skills/check/SKILL.md` -- `/check` command (run tests, build, lint, type-check)
- `skills/wrap/SKILL.md` -- `/wrap` command (session log, Vibe Score, release notes, CLAUDE.md mutations)
- `skills/new-feature/SKILL.md` -- `/new-feature` command (Tier 2 feature development cycle)
- `skills/run-backlog/SKILL.md` -- `/run-backlog` command (autonomous backlog processing)
- `templates/vitest.config.ts.template` -- Vitest configuration scaffold
- `templates/playwright.config.ts.template` -- Playwright E2E test configuration scaffold
- `templates/axe-config.ts.template` -- axe accessibility testing configuration scaffold
- `templates/test-utils.ts.template` -- shared test utilities (render helpers, mock factories, fixtures)
- `templates/session-log.json.template` -- session log data structure
- `templates/score-breakdown.json.template` -- Vibe Score breakdown data structure
- `scripts/calculate-vibe-score.sh` -- Vibe Score calculation (deductions for churn, loops, violations; bonuses for artifacts and cache)
- `scripts/generate-release-notes.sh` -- generates release notes from session logs and git history
- `scripts/git-branch-create.sh` -- creates feature/fix branches with naming conventions
- `scripts/git-commit-validate.sh` -- validates commit messages against conventional commit format
- `scripts/update-backlog.sh` -- backlog state management (also listed in Phase 2; extended here with phase-tracking)

#### Phase 4 -- Documentation (12 files)

VitePress documentation site scaffold with live data integration.

- `templates/docs-site/package.json` -- VitePress project manifest
- `templates/docs-site/.vitepress/config.ts` -- VitePress site configuration (nav, sidebar, theme)
- `templates/docs-site/data/sessions.data.ts` -- data loader for `.vibeos/sessions/` JSON files
- `templates/docs-site/data/backlog.data.ts` -- data loader for `.vibeos/backlog.json`
- `templates/docs-site/components/KanbanBoard.vue` -- Vue component for feature backlog kanban view
- `templates/docs-site/components/StatsPage.vue` -- Vue component for session stats and Vibe Score charts
- `templates/docs-site/index.md` -- documentation site landing page
- `templates/docs-site/kanban.md` -- kanban board page (renders KanbanBoard component)
- `templates/docs-site/stats.md` -- stats dashboard page (renders StatsPage component)
- `templates/docs-site/system/commands.md` -- full slash command reference
- `templates/docs-site/system/getting-started.md` -- installation and first-project guide
- `scripts/update-docs.sh` -- copies session data into docs-site for static build

#### Phase 5 -- Intelligence Layer (7 files)

Enhanced automation scripts for self-improvement and operational safety.

- `scripts/compact-reinject.sh` -- enhanced context compaction handler (re-injects project state, active feature, and phase after compaction)
- `scripts/cost-guardrails.sh` -- session cost threshold checks with configurable limits
- `scripts/claude-md-lint.sh` -- validates CLAUDE.md size, structure, and rule quality
- `scripts/sync-state.sh` -- reconciles `.vibeos/state.json` with filesystem (detects missing artifacts, repairs drift)
- `scripts/error-recovery.sh` -- clears stale locks, repairs corrupted JSON, resets interrupted tasks
- `scripts/validate-plugin.sh` -- validates plugin structure (required files, hook bindings, agent refs, permission rules)
- `templates/mutation-log.json.template` -- audit log for CLAUDE.md mutations proposed by Performance Coach

#### Phase 6 -- Polish (8 files)

Documentation, cleanup utilities, and finalized configurations.

- `README.md` -- project README with install guide, command reference, architecture overview, and troubleshooting
- `CHANGELOG.md` -- this changelog
- `scripts/uninstall.sh` -- clean uninstall (removes plugin registration, preserves `.vibeos/` project state)
- `scripts/extract-design-system.sh` -- extracts design tokens from existing CSS/Tailwind config into design-system.css
- `templates/gitignore-additions.template` -- recommended .gitignore entries for `.vibeos/` runtime files
- `templates/CONTRIBUTING.md.template` -- contribution guidelines scaffold for generated projects
- `hooks/hooks.json` -- finalized hook bindings with all 10 entries across 6 lifecycle events
- `scripts/notify.sh` -- finalized notification script with Warp deep-link support and error routing

---

**Total: ~81 files across 6 implementation phases.**

[1.0.0]: https://github.com/speedkit/vibe-os/releases/tag/v1.0.0
