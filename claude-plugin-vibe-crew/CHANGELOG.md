# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2026-03-02

### Added

#### GitHub Issues Auto-Fix Integration

- `skills/fix-issue/SKILL.md` -- `/fix-issue` slash command: fetches a GitHub Issue by number, diagnoses the problem, implements the fix, runs tests, and opens a PR referencing the issue
- `skills/sync-issues/SKILL.md` -- `/sync-issues` slash command: imports open GitHub Issues as backlog features for prioritization and tracking
- `templates/issue-fix-report.json.template` -- Structured report schema for issue diagnosis, fix description, and verification results

#### Mechanical Workflow Enforcement Hooks

- `hooks/hooks.json` -- Added `validate-phase-transition.sh` PreToolUse hook: validates phase ordering and foundation artifact completeness before allowing phase transitions
- `scripts/validate-phase-transition.sh` -- Enforces sequential phase progression (plan → design → code → test → review → docs) and blocks skipping required phases

#### Vibe Dashboard Enhancements

- `templates/docs-site/components/ProductFeatures.vue` -- Product Features page with feature cards, status indicators, and spec previews
- `templates/docs-site/components/ArchitectureOverview.vue` -- Architecture Overview page rendering Mermaid diagrams from `.vibecrew/architecture/*.mmd` with live reload
- Vitest test suite for dashboard components (KanbanBoard, StatsPage, ScoreTrend, ProductFeatures, ArchitectureOverview)

#### Design Discovery & Planning Improvements

- `skills/new-project/SKILL.md` -- Added "What problem does it solve?" question to Design Discovery interview for sharper product-market fit analysis
- `agents/workflow-orchestrator.md` -- Problem statement now required during feature planning (`/plan-features`, `/new-feature`)

#### Visual Feedback Loop

- `agents/builder.md` -- Builder agent captures screenshots after UI changes and compares against design brief token values
- `agents/code-reviewer.md` -- Code Reviewer validates visual consistency against design system during review phase

### Fixed

- `scripts/phase-gate.sh`, `scripts/protect-data.sh`, `scripts/restrict-paths.sh` -- Hardened safety-critical hooks against edge cases and race conditions
- `scripts/calculate-vibe-score.sh` -- Fixed architecture diagram re-rendering when `.mmd` files change during a session
- Removed Stitch MCP server from plugin configuration and all documentation (deprecated upstream)
- 12 weakness findings addressed with 77 new BATS tests (556 total):
  - `scripts/claim-task.sh`, `scripts/complete-phase.sh` -- Dual-write journal no longer finalized on error paths, ensuring crash recovery via `sync-state.sh`
  - `scripts/update-state.sh`, `scripts/update-backlog-raw.sh` -- Consolidated jq sanitizer blocks dangerous builtins (`env`, `debug`, `halt`, `$ENV`) in any context
  - `scripts/lib/lock.sh`, `scripts/add-mcp-server.sh` -- Replaced `((var++))` with safe `$((var + 1))` arithmetic to prevent `set -e` termination
  - `scripts/protect-data.sh` -- Added 4 new security patterns: `bash -e -c` flag bypass, `wget --post-data` exfiltration, `source .env` credential loading, `bash <<<` here-string injection (51 → 59 patterns, 8 → 9 categories)
  - `scripts/lib/compat.sh` -- Added `_compat_parse_timestamp()` for cross-platform timestamp parsing; used in `error-recovery.sh` and `format-code.sh`
  - `scripts/calculate-vibe-score.sh` -- npm test/build/lint wrapped with 120s timeout to prevent runaway processes
  - `scripts/cost-guardrails.sh` -- Warns when custom pricing data is >90 days stale
  - 8 gamification scripts -- Fixed jq `//` operator treating `false` as falsy (`award-xp.sh`, `check-level-up.sh`, `update-streak.sh`, `check-badges.sh`, `distribute-skill-xp.sh`, `refresh-challenges.sh`, `update-challenges.sh`, `session-startup.sh`)
  - `scripts/award-xp.sh` -- Fixed `ls | head` pipeline crash under `set -o pipefail` when no score files exist
  - `scripts/update-backlog.sh`, `scripts/update-backlog-raw.sh` -- Switched to named `"backlog"` lock for independent locking from state file operations
  - `agents/verifier.md` (-70 lines), `agents/builder.md` (-30 lines) -- Condensed gamification pipeline and MCP server sections into tables

### Changed

#### Documentation Site Migration

- Migrated documentation from static HTML to Astro 5.5 with component-based layouts, self-hosted fonts, dark/light theme, and Pagefind search
- `docs-next/` -- Full Astro source with 26 pages, reusable components, CSS design token system
- `docs/` -- Compiled static output served via GitHub Pages at `fabkrum.github.io/vibe-crew/`
- Added `.nojekyll` to `docs-next/public/` to persist across Astro rebuilds (prevents GitHub Pages Jekyll from ignoring `_astro/` directory)
- Added docs build regression tests (`tests/docs-build.bats`) to prevent GitHub Pages styling breakage

#### Configuration

- `.claude-plugin/plugin.json` -- Version bumped to 1.8.0
- `agents/session-startup.md` -- Banner version bumped to 1.8.0
- `docs(setup)` -- Reorganized setup guide to lead with automated `install.sh` workflow

---

## [1.7.0] - 2026-03-01

### Fixed

#### Critical Security Hardening

- `scripts/cost-guardrails.sh` -- AWK injection: replaced string interpolation with `-v` flag passing in `calc()`, `fmt_usd()`, and all inline awk comparisons
- `scripts/check-mcp-health.sh` -- Command injection: replaced `bash -c "$SERVER_CMD"` with array-based execution, mktemp-based temp files with cleanup trap, server name sanitization
- `scripts/restrict-paths.sh` -- JSON injection: replaced heredoc with `jq -Rs` escaping for validation output
- `scripts/update-state.sh` -- jq expression injection: added allowlist validation rejecting dangerous builtins (`input`, `env`, `debug`, `halt`, `builtins`)

#### Robustness Fixes

- `scripts/lib/lock.sh` -- Fixed TOCTOU race in stale lock removal using atomic `mv`-based claim pattern
- `scripts/migrate-state.sh` -- Moved score/mutation migrations inside lock scope; made lock release conditional
- `scripts/sandbox.sh` -- Added realpath error guard and `python3` fallback for `realpath -m`
- `scripts/detect-secrets.sh`, `scripts/run-a11y-scan.sh` -- Added EXIT traps for temp file cleanup
- `scripts/statusline.sh` -- Atomic write via tmp+mv pattern

#### Cross-Platform Compatibility

- `scripts/detect-conventions.sh` -- Replaced `grep -P` (PCRE) with `grep -q`/`grep -qE` for macOS compatibility
- `scripts/quality-gate.sh` -- Added `timeout` command availability check with graceful fallback
- `scripts/bump-version.sh` -- Cross-platform `sed -i` wrapper function for macOS/Linux
- `scripts/check-context.sh` -- Cross-platform date parsing (macOS `date -j` + GNU `date -d` fallback)

#### Script Fixes

- `scripts/generate-feature-docs.sh` -- Fixed `$priority` → `$PRIORITY` variable name
- `scripts/generate-handoff.sh` -- Replaced `echo -e` with `printf '%b'`
- `scripts/extract-design-system.sh` -- Fixed URL escaping in JSON payloads and sed delimiters
- `scripts/generate-counter-tdr.sh` -- Removed double-escaping before `jq --arg`

#### Agent Prompt Fixes

- `agents/session-startup.md` -- Fixed "3 lines" → "4 lines" count, clarified safety constraints
- `agents/code-reviewer.md`, `agents/code-auditor.md`, `agents/code-simplifier.md`, `agents/security-auditor.md` -- Fixed read-only contradictions (agents with Write/Edit tools now clarify their write scope)
- `agents/builder.md` -- Fixed duplicate step numbers, clarified `auto_merge` PR behavior
- `agents/ci-healer.md` -- Aligned dependency fix strategy with safety rules (no auto-add to package.json)
- `agents/workflow-orchestrator.md` -- Fixed agent count (13→14), added signal validation, added concurrent run-backlog guard
- `agents/opponent-processor.md` -- Added profile-aware output adaptation
- `agents/verifier.md` -- Updated vestigial v1.0 mutation text

### Changed

#### Config & Settings

- `settings.json` -- Restricted `cp`/`mv` to project scope, added pnpm/yarn/bun patterns, added deny patterns for `rm -rf /*` and force-push to main/master, fixed statusLine path
- `.mcp.json` -- Fixed supabase package name, replaced empty env values with `YOUR_TOKEN_HERE` placeholders
- `.claude-plugin/plugin.json` -- Added settings reference

#### Templates

- `templates/onboard-state.json.template` -- Updated to schema v1.5.0, added architecture_diagrams artifact and brief_file field
- `templates/signal-schema.json` -- Expanded agent enum from 5 to 11 signal-producing agents
- `templates/workflow.json.template` -- Added review phase to phase_order
- `templates/score-breakdown.json.template` -- Added review phase
- `templates/architecture-manifest.json` -- Removed misleading `$schema` line
- `scripts/init-vibecrew-state.sh` -- Added 7 missing config sections and state fields

#### Documentation

- `CLAUDE.md` -- Fixed hook table (session-startup.md → session-startup.sh, added 4 missing hooks)
- `README.md` -- Updated stale counts (14 agents, 31 commands, 10 MCP servers, v1.7.0 releases), added System Reviewer
- `templates/trigger-table.md` -- Added 5 missing commands, fixed /audit agent mapping, added System Reviewer
- `architecture/agents.md` -- Updated from 5 v1.0 agents to 14 v1.7.0 agents with full summary table
- `architecture/schemas.md` -- Updated schema version to 1.5.0, added review phase
- `architecture/workflows.md` -- Updated from 5-agent to 14-agent topology

---

## [1.6.0] - 2026-03-01

### Added

#### Mermaid Architecture Diagrams — 6th Tier 1 Foundation Artifact

- `templates/architecture-diagrams/system.mmd.template` -- Flowchart TD with Client/Edge/App/Data/External subgraphs and `{{PLACEHOLDER}}` syntax for TDR technology names
- `templates/architecture-diagrams/schema.mmd.template` -- erDiagram with User entity and comment instructions for adding domain entities from VISION.md
- `templates/architecture-diagrams/state-flows.mmd.template` -- stateDiagram-v2 with Authentication state group and placeholder for primary user flows
- `templates/architecture-diagrams/api-sequences.mmd.template` -- sequenceDiagram with auth handshake and primary CRUD flow placeholders
- `templates/architecture-diagrams/component-tree.mmd.template` -- Flowchart TD with App/Layout/Header/Nav/Main/Footer skeleton, arrow labels showing props ↓ / events ↑. Grows during Tier 2 as Builder adds components

#### New Project Workflow — Step 5: Architecture Diagrams

- `skills/new-project/SKILL.md` -- New Step 5 reads VISION.md + TDR + roadmap, loads 5 templates, generates `.mmd` files to `.vibecrew/architecture/`, presents summary for approval. CLAUDE.md generation moves to Step 6

#### Agent Enhancements

- `agents/stack-scout.md` -- Produces preliminary `flowchart TD` system diagram alongside the TDR using chosen technology names
- `agents/builder.md` -- Reads all 5 `.mmd` files during Code Phase for implementation context; updates `component-tree.mmd` after adding components; adds `Diagram-Drift:` commit trailer for deviations
- `agents/code-reviewer.md` -- New Step 4.5 "Architecture Diagram Consistency" checks schema.mmd, api-sequences.mmd, state-flows.mmd, and component-tree.mmd against actual code (warning level)
- `agents/doc-generator.md` -- New "Architecture Diagram Freshness" section with stale detection rules; `/wrap` workflow checks and updates stale diagrams
- `agents/security-auditor.md` -- Reads `system.mmd` and `api-sequences.mmd` before OWASP scan for topology and data flow context
- `agents/performance-coach.md` -- Documentation drift template expanded to include architecture diagrams

#### Schema & Migration

- `templates/state.json.template` -- Schema version 1.1.0 → 1.2.0; added `architecture_diagrams` artifact to foundation
- `scripts/sync-state.sh` -- Migration logic for existing projects: adds `architecture_diagrams` with status `"skipped"` for complete foundations, `"pending"` for incomplete

#### Phase Gate & Scoring

- `scripts/phase-gate.sh` -- Added `*.mmd` to allowed file patterns during Tier 1
- `architecture/scoring.md` -- `stale_docs` definition expanded to include `.vibecrew/architecture/*.mmd` files

#### Documentation

- `architecture/diagrams.md` -- Design doc covering purpose (token efficiency), 5 diagram types, lifecycle, stale detection rules, agent consumption matrix, Vibe Score integration

### Changed

- All "5 artifact" references updated to "6" across 31 files (agents, skills, scripts, architecture docs, HTML docs, quizzes, README, CLAUDE.md)
- `agents/workflow-orchestrator.md` -- Tier 1 routing: Architecture Diagrams inserted as step 5, CLAUDE.md renumbered to step 6
- `skills/wrap/SKILL.md` -- Doc Generator invocation includes diagram freshness check
- `scripts/session-startup.sh` -- Foundation completion denominator updated to 6

### Files Changed

- `.claude-plugin/plugin.json` -- Version bumped to 1.6.0
- `agents/session-startup.md` -- Banner version bumped to 1.6.0

## [1.5.0] - 2026-02-25

### Added

#### `/profile` — User Profile System

- `skills/profile/SKILL.md` -- Interactive 8-question interview (~2 minutes) with 3 presets (Builder, Explorer, Founder). 8 dimensions: role, code_literacy, autonomy, pr_review, verbosity, gamification_preference, learning, risk_tolerance. Stored in `.vibecrew/config.json` under `user_profile` key
- `scripts/read-profile.sh` -- Universal profile reader: outputs JSON with all 8 dimensions, merges stored values over defaults, fills missing fields. Single bash call (~500 tokens)
- `scripts/save-profile.sh` -- Atomic profile writer with `.tmp` + `mv` pattern. Auto-syncs gamification settings (enabled, show_xp_in_status, streak_reminders) based on gamification_preference dimension

#### `/system-review` — Plugin Meta-Analysis

- `agents/system-reviewer.md` -- Opus agent, worktree isolation, read-only. 10-step methodology: internal audit (inventory, model routing, context budgets, patterns, component usage), telemetry analysis (cross-project skill/agent usage, Vibe Score trends, cost analysis, MCP adoption), external research (Anthropic updates, MCP ecosystem, community patterns), innovation proposals (P1-P5 with effort estimates)
- `skills/system-review/SKILL.md` -- Pre-flight check for plugin root, collect plugin stats and telemetry, invoke system-reviewer agent, output structured reports to `${CLAUDE_PLUGIN_ROOT}/reviews/`
- `scripts/collect-telemetry.sh` -- Aggregates anonymized cross-project data (project aliases like project-001, never real paths). Tracks sessions, Vibe Scores, costs, deductions, agent usage
- `scripts/collect-plugin-stats.sh` -- Parses agent definitions, skill/script/hook counts, MCP servers (bundled + registry)
- `templates/system-review-report.json.template` -- Structured report schema with plugin stats, telemetry aggregate, findings, proposals

#### MCP Server Registry

- `templates/mcp-registry.json` -- Extended registry with 25 MCP servers total. 15 additional servers beyond the 10 bundled: Firebase, Prisma, Clerk, Auth0, Netlify, Railway, Shopify, MongoDB, Resend, Next.js DevTools, shadcn/ui, Terraform, Kubernetes, Neon, Upstash Redis. Each entry includes name, category, trigger patterns, command, args, env vars, docs_url. Auto-discoverable by Stack Scout based on TDR technology choices

#### Vibe Dashboard

- 7-tab interactive VitePress-powered dashboard: Guide, Kanban Board (7-column drag-and-drop), Session Statistics, Trends (score charts, token breakdown, agent heatmap), Coverage (test gauge, feature progress), Achievements (XP, badges, skill radar, streak calendar), Settings (browser-based `.vibecrew/config.json` editor)
- Dev mode (`npm run docs:dev`): hot-reload, interactive drag-drop, settings writes directly to `.vibecrew/` files
- Production mode (`npm run docs:build`): static HTML snapshot, read-only rendering

#### Gamification System

- XP & leveling with 50 tiers (Newcomer to Vibe Legend). XP earned through real work: session completion (+10 base), Vibe Score bonus, clean session (+25), ship feature (+50), Tier 1 completion (+100), tests first-pass (+15), quiz correct (+5)
- 15 badges across 3 categories: milestone (Hello World, Architect, Shipper, Momentum, Researcher), skill (Smooth Operator, On Fire, Untouchable, Cache Master, Clear Communicator, Test First, Context Ninja), special (Perfectionist, Comeback Kid, Weekly Warrior, Unstoppable)
- 5-domain skill tree (Prompting, Architecture, Testing, Context Management, Workflow Discipline) with 5 levels each (Novice to Master). Visual radar chart
- Streaks with weekend auto-grace and 2 grace days/month. No penalty for broken streaks
- Daily/weekly/one-time challenges (optional, never punish failure)
- 7 quizzes unlockable at Level 3+ via `/quiz`
- Achievements dashboard with level badge, XP progress, badge grid, 5-axis skill radar SVG, 12-week streak heatmap

#### `/release` — Automated Release Process

- `skills/release/SKILL.md` -- Slash command: bump version across 5 files, regenerate `docs/releases.html` from CHANGELOG.md, git commit and tag. No auto-push
- `scripts/bump-version.sh` -- Updates version in `plugin.json` (jq), `session-startup.md`, `docs/index.html`, `CLAUDE.md`, `CHANGELOG.md` (renames `[Unreleased]` heading). Atomic JSON writes
- `scripts/generate-releases-html.sh` -- State-machine CHANGELOG.md parser producing standalone `docs/releases.html` with embedded CSS, sidebar nav, version pills, and per-release sections

### Changed

#### Agent Model Upgrades

- `agents/workflow-orchestrator.md` -- Model upgraded from Sonnet to Opus
- `agents/stack-scout.md` -- Model upgraded from Sonnet to Opus
- `agents/builder.md` -- Model upgraded from Sonnet to Opus
- `agents/code-auditor.md` -- Model upgraded from Sonnet to Opus
- `agents/security-auditor.md` -- Model upgraded from Sonnet to Opus
- `agents/code-simplifier.md` -- Model upgraded from Sonnet to Opus
- `agents/opponent-processor.md` -- Model upgraded from Sonnet to Opus
- `agents/ci-healer.md` -- Model upgraded from Sonnet to Opus

#### Profile-Aware Agent Adaptations

- All agents read profile via `read-profile.sh` and adapt behavior: Session Startup adjusts greeting depth, Workflow Orchestrator adjusts approval gates, Builder adjusts commit messages and code comments, Verifier adjusts coaching and gamification display, Stack Scout adjusts tech maturity criteria, Doc Generator adjusts documentation depth, Code Reviewer adjusts finding explanations

#### Documentation Site

- Redesigned docs with sticky collapsible sidebar navigation (260px fixed width), mobile hamburger menu
- Added `personalization.html` -- comprehensive 8-dimension profile + full gamification system documentation
- Added `dashboard.html` -- Vibe Dashboard reference with 7-tab walkthrough
- Split architecture docs into dedicated section with collapsible sidebar nav
- Reorganized sidebar groups: Intro, Getting Started, Workflows, Architecture, Releases

#### Configuration

- `.claude-plugin/plugin.json` -- Version bumped to 1.5.0
- Agent topology updated to 14 agents (was 13), 27 commands (was 25)
- `templates/trigger-table.md` -- Updated with `/profile`, `/system-review` commands and System Reviewer agent

---

## [1.4.0] - 2026-02-24

### Added

#### `/tdd` — Vertical-Slice TDD Workflow

- `skills/tdd/SKILL.md` -- Red-green-refactor TDD with planning phase (interface signatures, behaviors, DI points). One failing test at a time, minimal implementation, refactor with full suite green. Commits with `TDD cycle: red-green-refactor` trailer. Discipline score (0-10)
- `scripts/detect-tdd-discipline.sh` -- Search git log for TDD cycle trailers, output JSON with discipline_detected and cycle_count

#### `/debug` — Systematic Debugging

- `skills/debug/SKILL.md` -- Four-phase debugging: Observe (gather evidence, reproduce), Hypothesize (3-5 ranked root causes), Test (confirm/refute each), Verify (checkpoint, fix, full test suite). Reports saved to `.vibecrew/debug-reports/`

#### `/review` — Structured Code Review

- `agents/code-reviewer.md` -- Opus agent, worktree isolation, read-only (disallowedTools: Write, Edit). 10-step analysis: correctness vs spec, TDR compliance, conventions, design tokens, error handling, test coverage, security, performance. Findings: critical/warning/info. Verdict: APPROVE / REQUEST CHANGES / COMMENT ONLY
- `skills/review/SKILL.md` -- Collect changed files, load feature spec as review contract, invoke code-reviewer agent, display findings by severity, track in `.vibecrew/reviews/`. Optional in manual workflow (+2 Vibe Score), automatic in `/run-backlog`
- `scripts/detect-review-status.sh` -- Check `.vibecrew/reviews/` for review reports matching active feature

#### `/e2e` — Playwright E2E Test Generation

- `skills/e2e/SKILL.md` -- Detect/scaffold Playwright, generate Page Object classes with accessible locators (getByRole → getByLabel → getByText → getByTestId), generate spec files from acceptance criteria, run with trace-on-first-retry

#### `/perf-test` — k6 Performance Testing

- `skills/perf-test/SKILL.md` -- Four test profiles (load, stress, spike, soak), scaffold from template, parse p95/p99 latency and error rates, save to `.vibecrew/perf-tests/`
- `templates/k6-config.js.template` -- k6 scaffold with configurable stages, default thresholds (p95 < 500ms, error rate < 1%), handleSummary JSON output
- `scripts/detect-perf-baselines.sh` -- Check `.vibecrew/perf-tests/` for results matching active feature

#### `/a11y` — WCAG 2.1 AA Accessibility Audit

- `skills/a11y/SKILL.md` -- axe-core scan via Playwright, keyboard navigation checklist, ARIA validation, violations by severity (critical/serious/moderate/minor), reports saved to `.vibecrew/a11y/`
- `scripts/run-a11y-scan.sh` -- Create temp Playwright script, run axe-core with WCAG 2.1 AA tags, output JSON report

#### Context Budget Optimization

- `templates/trigger-table.md` -- Compact routing table for all 25 slash commands with agent, phase, description. Agent registry (13 agents) with model, isolation, triggers. State routing decision table (~60 lines)

### Changed

#### Tier 2 Phase Expansion (5 → 6 phases)

- `skills/new-feature/SKILL.md` -- Added optional Review phase to phase tracker display. Review is optional in manual workflow but earns +2 Vibe Score bonus
- `skills/run-backlog/SKILL.md` -- Inserted Phase 4.5 (Review) between Test and Docs. Invokes `/review` after tests pass, loops back for fixes on critical findings (max 2 cycles). Updated all phase counts from 5 to 6
- `agents/workflow-orchestrator.md` -- Added Code Reviewer to Tier 2 agent assignments. Added "Tier 2 Phase Sequence" subsection, `reviewer-complete.signal` processing, and "Context Budget: On-Demand Loading" referencing trigger-table.md

#### Vibe Score Expansion

- `skills/wrap/SKILL.md` -- Added skipped-code-review deduction (-5). Added 5 new bonuses: TDD discipline (+3), E2E tests passing (+3), accessibility clean (+2), code review complete (+2), performance baselines (+2)
- `scripts/calculate-vibe-score.sh` -- Added 5 new detection sections (TDD, E2E, a11y, review, perf) and 10 new JSON output fields
- `agents/verifier.md` -- Updated Vibe Score tables with new deduction and 5 new bonus rows. Added E2E, a11y, and perf references to Test Infrastructure

#### Agent Enhancements

- `agents/builder.md` -- Added TDD Integration section: red-green-refactor cycle with commit trailer when `/tdd` is active
- `agents/ci-healer.md` -- Added systematic debugging methodology (Observe → Hypothesize → Test → Verify) for complex failures

#### Configuration

- `settings.json` -- Added 3 allowedTools: `k6 *`, `npx k6 *`, `npx @axe-core/playwright *`
- `.claude-plugin/plugin.json` -- Version bumped to 1.4.0

---

## [1.3.0] - 2026-02-23

### Added

#### Status Bar — Persistent Status Line

- `scripts/statusline.sh` -- Status line script rendering 6 data segments (context %, cost, feature · phase, Vibe Score, duration, compaction count). Reads session JSON from stdin and `.vibecrew/` state files from disk. ANSI color-coded context bar (green/yellow/red). Graceful fallback if `jq` missing or `.vibecrew/` absent. Bash 3.2 compatible
- `settings.json` -- Added `statusLine` config pointing to `./scripts/statusline.sh`
- `README.md` -- Added Status Bar section documenting segments, sources, and color thresholds

#### `/replay` — Reusable Session Workflow Templates

- `skills/replay/SKILL.md` -- Slash command: list/create/apply workflow templates from successful sessions. `/replay` lists templates, `/replay --create <name>` extracts from sessions with Vibe Score >= 70, `/replay <name>` loads and guides development
- `scripts/extract-workflow.sh` -- Parse session logs and score files to extract phase order, commit patterns, test strategy, and quality thresholds into a reusable workflow template
- `scripts/list-workflows.sh` -- List `.vibecrew/workflows/workflow-*.json` files with name, description, phase count, and min score summaries
- `templates/workflow.json.template` -- Schema v1.3.0 workflow template: phase_order, branch_convention, test_strategy, quality_thresholds, commit_convention

#### `/simplify` — Code Simplifier

- `agents/code-simplifier.md` -- Opus agent, worktree isolation, read-only. Analyzes code for 4 simplification categories: dead code removal, abstraction flattening, API surface reduction, dependency consolidation
- `skills/simplify/SKILL.md` -- Slash command: collect feature files, invoke code-simplifier agent, display suggestions with before/after previews, apply with per-suggestion approval and automatic test verification, revert on test failure
- `scripts/collect-feature-files.sh` -- Gather source files changed on feature branch via `git diff --name-only`, filter to code files only
- `templates/simplification-report.json.template` -- Schema v1.3.0 report with per-suggestion status tracking (pending/applied/rejected/reverted)

#### `/heal` — Auto-Healing CI

- `agents/ci-healer.md` -- Sonnet agent, maxTurns 15. Categorizes CI failures (build/test/lint/dep/env) and applies targeted minimal fixes
- `skills/heal/SKILL.md` -- Slash command: fetch CI logs from GitHub Actions, diagnose failure category, create checkpoint, invoke ci-healer agent, verify fix, retry loop (max 3 attempts), escalate to user on failure
- `scripts/fetch-ci-logs.sh` -- Fetch latest failed CI run via `gh run view --log-failed`, truncate to 500 lines, output structured JSON
- `scripts/diagnose-ci-failure.sh` -- Pattern-match CI error logs to categorize as build/test/lint/dep/env with confidence rating and relevant line extraction
- `templates/ci-heal-report.json.template` -- Schema v1.3.0 report: attempts array with diagnosis, fix description, CI result per attempt

#### Opponent Processor — TDR Debate System

- `agents/opponent-processor.md` -- Sonnet agent, worktree isolation, read-only. Devil's advocate for technology decisions: generates counter-arguments, debate matrices (6 criteria), risk assessments, and Keep/Reconsider verdicts
- `scripts/generate-counter-tdr.sh` -- Extract technology decisions from TDR markdown, output structured JSON with category, chosen option, and stated rationale per decision
- `templates/counter-tdr.md.template` -- Counter-analysis format: per-decision devil's advocate position, debate matrix table, risk assessment, recommendation

### Changed

- `skills/new-project/SKILL.md` -- Added Step 3.5: invoke Opponent Processor after TDR creation. Presents both analyses side-by-side, offers keep all / reconsider / skip choice
- `agents/workflow-orchestrator.md` -- Added Opponent Processor coordination section to Tier 1 routing
- `.claude-plugin/plugin.json` -- Version bumped to 1.3.0
- `settings.json` -- Added 3 allowedTools: `gh run list`, `gh run view`, `gh run watch`
- `scripts/migrate-state.sh` -- Added `migrate_1_2_to_1_3()`: opponent_processor, simplify, ci_healing config sections + active_workflow in state. Updated version chain to 1.3.0
- `templates/config.json.template` -- Added `opponent_processor`, `simplify`, `ci_healing` config sections. Schema version bumped to 1.3.0
- `templates/state.json.template` -- Added `active_workflow: null` field
- `README.md` -- Updated to 12 agents (was 9), 17 commands (was 14). Added /replay, /simplify, /heal sections and 3 new agent entries

---

## [1.2.0] - 2026-02-23

### Added

#### `/cost` — Real-time Token Cost Dashboard

- `skills/cost/SKILL.md` -- Slash command displaying current session cost, daily/weekly/monthly aggregates, threshold proximity indicators, and model pricing reference table (Opus/Sonnet/Haiku)
- `scripts/aggregate-costs.sh` -- Scans `.vibecrew/sessions/session-*.json` and live `session-cost.json`, computes daily/weekly/monthly/all-time cost totals

#### `/undo` — Checkpoint Rollback

- `skills/undo/SKILL.md` -- Slash command listing VibeCrew checkpoints and recent commits, detecting pushed vs unpushed state, and performing safe rollback via `git revert` (pushed) or `git reset --soft` (unpushed)
- `scripts/create-checkpoint.sh` -- Creates lightweight git tag `vibecrew-checkpoint-<ISO-timestamp>` with description
- `scripts/list-checkpoints.sh` -- Lists `vibecrew-checkpoint-*` tags sorted by date with commit hash and subject
- `scripts/rollback-checkpoint.sh` -- Validates target commit, performs rollback in revert or reset mode, reports summary

#### `/audit` — OWASP Top 10 Security Review

- `agents/security-auditor.md` -- Sonnet agent, worktree isolation, read-only. 10-step OWASP scan (A01-A10): broken access control, cryptographic failures, injection, insecure design, misconfiguration, vulnerable components, auth failures, data integrity, logging gaps, SSRF
- `skills/audit/SKILL.md` -- Slash command detecting project language, invoking security-auditor agent, formatting findings by severity, optional GitHub issue creation for critical/high findings
- `scripts/scan-dependencies.sh` -- Multi-language dependency audit: npm audit, pip audit, bundle audit, govulncheck, cargo audit, composer audit. Graceful fallback if tool missing
- `scripts/detect-secrets.sh` -- Regex scan for AWS keys, API keys, private keys, passwords, JWTs, connection strings, Stripe/GitHub tokens. Redacts actual values in output
- `templates/audit-report.json.template` -- Schema v1.2.0 report structure with findings array, dependency vulnerabilities, secrets detected, summary counts

#### Non-Node.js Convention Detection

- `scripts/detect-conventions.sh` -- Added language detection from manifests (pyproject.toml, Gemfile, go.mod, Cargo.toml, composer.json, pom.xml/build.gradle). Per-language formatter/linter/naming/indent detection for Python (Black/Ruff, PEP8), Ruby (RuboCop), Go (gofmt, golangci-lint), Rust (rustfmt, clippy), PHP (PHP-CS-Fixer), Java (Checkstyle). Added `language` and `package_manager` to JSON output
- `scripts/extract-project-conventions.sh` -- Per-language framework/ORM/auth/API detection: Python (Django/Flask/FastAPI, SQLAlchemy), Ruby (Rails, ActiveRecord, Devise), Go (Gin/Echo/Fiber, GORM), Rust (Actix/Axum, Diesel/SeaORM), PHP (Laravel/Symfony, Eloquent/Doctrine), Java (Spring Boot, Hibernate). Added `language` to JSON output

### Changed

- `scripts/cost-guardrails.sh` -- Multi-model pricing via `case` on model name (Opus $15/$75, Sonnet $3/$15, Haiku $0.25/$1.25). Added `model` field to session-cost.json output
- `skills/new-feature/SKILL.md` -- Added Step 5.5: create checkpoint before feature development
- `skills/run-backlog/SKILL.md` -- Added checkpoint creation after branch creation in feature claim step
- `agents/code-auditor.md` -- Updated Step 1 to detect language before reading manifest. Non-Node.js supported languages now get "medium" confidence (was "low")
- `scripts/migrate-state.sh` -- Added `migrate_1_1_to_1_2()`: adds `audit` config section. Updated version chain to 1.2.0
- `templates/config.json.template` -- Added `audit: { auto_github_issues: false, severity_threshold: "high" }`. Schema version bumped to 1.2.0
- `settings.json` -- Added audit and git permissions: npm audit, pip audit, bundle audit, govulncheck, cargo audit, composer audit, git tag, git revert, git reset --soft
- `.claude-plugin/plugin.json` -- Version bumped to 1.2.0
- `README.md` -- Updated to 9 agents (was 8), 14 commands (was 11), added /cost + /undo + /audit docs and Security Auditor agent entry

---

## [1.1.0] - 2026-02-23

### Added

#### Performance Coach (Phase 1)

Self-improvement engine with cross-session trend analysis and CLAUDE.md mutation system.

- `agents/performance-coach.md` -- Sonnet agent with persistent MEMORY.md, 7-step mutation workflow, and 5 anti-pattern templates
- `scripts/aggregate-scores.sh` -- Reads last 10 score files, classifies trends (improving/declining/recurring/plateau/volatile), calculates satisfaction-score correlation
- `scripts/detect-anti-patterns.sh` -- Scans score history for recurring deduction categories, outputs frequency data
- `scripts/apply-mutation.sh` -- Appends approved rules to CLAUDE.md "Session Learnings" section, updates mutation-log.json
- `scripts/check-mutation-eligibility.sh` -- Enforces guardrails: min 5 sessions, 3+ occurrences, max 1/session, no duplicates, 3-rejection cooldown
- `templates/memory-md.template` -- Persistent Performance Coach memory (anti-patterns, mutations, trends, notes)
- `templates/mutation-proposal.json.template` -- Structured mutation proposal format
- `skills/wrap/SKILL.md` -- Added Step 9.5 (Performance Coach invocation), Step 9.7 (4-point user satisfaction feedback)
- `templates/score-breakdown.json.template` -- Added `user_feedback` (rating 1-4, comment) and `trend` (direction, window_size, average_score) fields
- `templates/mutation-log.json.template` -- Added `rejection_count`, `cooldown_until`, `confidence` fields

#### Existing Project Onboarding (Phase 2)

Unlocks VibeCrew for existing projects with `/onboard` command and Code Auditor agent.

- `agents/code-auditor.md` -- Sonnet agent, read-only worktree analysis, scans dependencies, conventions, test gaps, design system, architecture
- `skills/onboard/SKILL.md` -- 8-step guided onboarding: dependency detection, convention extraction, test gap analysis, CLAUDE.md generation, state initialization
- `scripts/detect-conventions.sh` -- Scans naming, imports, formatting, commit format, linters, formatters
- `scripts/analyze-test-gaps.sh` -- Compares source vs test files, identifies untested modules, estimates coverage
- `scripts/extract-project-conventions.sh` -- Deep scanner: framework, state management, API patterns, component libraries, auth, database
- `scripts/generate-onboard-claude-md.sh` -- Generates project-specific CLAUDE.md from onboard findings
- `templates/onboard-state.json.template` -- Pre-filled state.json for onboarded projects (foundation.complete=true)

#### Doc Generator + /handoff (Phase 3)

Documentation automation and cross-session context transfer.

- `agents/doc-generator.md` -- Sonnet agent for feature docs, CHANGELOG, VitePress sidebar, release notes
- `scripts/generate-feature-docs.sh` -- Reads backlog, generates markdown feature docs from specs
- `scripts/update-changelog.sh` -- Parses conventional commits, groups by type, appends to CHANGELOG.md
- `scripts/rebuild-sidebar.sh` -- Scans docs/features/, outputs VitePress sidebar config
- `skills/handoff/SKILL.md` -- Structured context transfer: state, work done, blockers, next steps, decisions (<500 words)
- `templates/handoff.md.template` -- Handoff document template
- `scripts/generate-handoff.sh` -- Reads state, backlog, commits; produces structured handoff
- `skills/wrap/SKILL.md` -- Added Step 10.5 (auto-generate handoff, invoke Doc Generator)
- `agents/session-startup.md` -- Added handoff detection: reads latest from `.vibecrew/handoffs/`, includes in banner

#### Enhanced Dashboard (Phase 4)

5 new Vue dashboard components with cross-session data visualization.

- `templates/docs-site/data/scores.data.ts` -- Data loader: reads scores, aggregates trends, top deductions
- `templates/docs-site/data/agents.data.ts` -- Data loader: reads sessions, extracts agent activity and token usage
- `templates/docs-site/components/ScoreTrend.vue` -- SVG line chart: Vibe Score over last 20 sessions, trend indicator, target line at 80
- `templates/docs-site/components/TokenBreakdown.vue` -- Stacked horizontal bars: input/cache/output tokens per session, cost overlay
- `templates/docs-site/components/CoverageGauge.vue` -- SVG radial gauge: test coverage % with color bands
- `templates/docs-site/components/FeatureProgress.vue` -- Horizontal bars: features by kanban column, velocity metric
- `templates/docs-site/components/AgentActivityPanel.vue` -- Agent invocation bars and session timeline with agent chips
- `templates/docs-site/trends.md` -- Trends dashboard page
- `templates/docs-site/coverage.md` -- Coverage and progress dashboard page
- `templates/docs-site/system/welcome.md` -- Dashboard welcome page with guided first-session flow

#### Progressive Onboarding (Phase 4)

Contextual command hints for new users.

- `scripts/onboarding-hints.sh` -- State-aware hint engine: suggests next command based on project phase, respects dismissals
- `agents/session-startup.md` -- Added progressive onboarding hints (max 1/session, dismissable)

### Changed

- `templates/docs-site/package.json` -- Added `chart.js` and `vue-chartjs` dependencies
- `templates/docs-site/.vitepress/config.ts` -- Added Trends and Coverage nav items
- `templates/config.json.template` -- Added `performance_coach`, `doc_generator`, `onboarding` config sections
- `templates/state.json.template` -- Added `onboarded` (bool) and `onboarded_at` (ISO timestamp) fields
- `scripts/migrate-state.sh` -- Added 1.0.0 -> 1.1.0 migration (new optional fields with defaults)
- `scripts/session-startup.sh` -- Added handoff file detection and hint integration
- `.claude-plugin/plugin.json` -- Version bumped to 1.1.0
- `README.md` -- Updated agent count (5->8), command count (9->11), added /onboard and /handoff docs

---

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
- `scripts/init-vibecrew-state.sh` -- initializes `.vibecrew/` state directory with config, state, and backlog
- `scripts/migrate-state.sh` -- state schema migration for version upgrades
- `settings.json` -- 68 permission rules (50 allowed tools, 18 denied tools)
- `.mcp.json` -- MCP server configuration for Context7 and Chrome DevTools
- `LICENSE` -- MIT license
- `templates/config.json.template` -- default `.vibecrew/config.json` scaffold

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
- `templates/docs-site/data/sessions.data.ts` -- data loader for `.vibecrew/sessions/` JSON files
- `templates/docs-site/data/backlog.data.ts` -- data loader for `.vibecrew/backlog.json`
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
- `scripts/sync-state.sh` -- reconciles `.vibecrew/state.json` with filesystem (detects missing artifacts, repairs drift)
- `scripts/error-recovery.sh` -- clears stale locks, repairs corrupted JSON, resets interrupted tasks
- `scripts/validate-plugin.sh` -- validates plugin structure (required files, hook bindings, agent refs, permission rules)
- `templates/mutation-log.json.template` -- audit log for CLAUDE.md mutations proposed by Performance Coach

#### Phase 6 -- Polish (8 files)

Documentation, cleanup utilities, and finalized configurations.

- `README.md` -- project README with install guide, command reference, architecture overview, and troubleshooting
- `CHANGELOG.md` -- this changelog
- `scripts/uninstall.sh` -- clean uninstall (removes plugin registration, preserves `.vibecrew/` project state)
- `scripts/extract-design-system.sh` -- extracts design tokens from existing CSS/Tailwind config into design-system.css
- `templates/gitignore-additions.template` -- recommended .gitignore entries for `.vibecrew/` runtime files
- `templates/CONTRIBUTING.md.template` -- contribution guidelines scaffold for generated projects
- `hooks/hooks.json` -- finalized hook bindings with all 10 entries across 6 lifecycle events
- `scripts/notify.sh` -- finalized notification script with Warp deep-link support and error routing

---

**Total: ~81 files across 6 implementation phases.**

[1.8.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.8.0
[1.7.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.7.0
[1.6.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.6.0
[1.5.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.5.0
[1.4.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.4.0
[1.3.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.3.0
[1.2.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.2.0
[1.1.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.1.0
[1.0.0]: https://github.com/fabkrum/vibe-crew/releases/tag/v1.0.0
