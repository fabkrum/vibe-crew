---
title: Command Reference
---

# Command Reference

VibeCrew provides 9 slash commands for managing the full development lifecycle.

## /setup

**Configure VibeCrew environment.**

```
/setup
```

Interactive wizard that detects your terminal, tests notifications, verifies MCP servers, and initializes `.vibecrew/` state directory. Run once per project.

## /new-project

**Create project foundation (Tier 1).**

```
/new-project
```

Guided 5-step workflow that creates VISION.md, design-system.css, Technology Decision Record, roadmap, and CLAUDE.md. The phase gate blocks source code writes until all 5 artifacts are approved.

## /plan-features

**Plan and prioritize features.**

```
/plan-features
```

Interactive planning session that populates the backlog with feature specs, acceptance criteria, priorities, and dependencies. Features move from "idea" to "planning" to "planned".

## /new-feature

**Start working on a feature.**

```
/new-feature "Feature Name"
```

Checks foundation is complete, enforces WIP limits, creates a feature branch, initializes the phase tracker, and loads the feature spec. Hands off to the Builder agent.

**Options:**
- Feature name is required (quoted string)
- Respects WIP limit of 1 for in-progress features

## /run-backlog

**Autonomous feature development loop.**

```
/run-backlog
```

Picks the highest-priority ready feature, runs all 6 phases (plan, design, code, test, review, docs), executes quality gates between features, and continues until the backlog is empty or a failure occurs.

**Guardrails:**
- Max 3 retries per feature on quality gate failure
- Cost guardrails stop execution at session limit
- Stops on persistent test failures

## /idea

**Quick backlog capture.**

```
/idea "Brief description of the feature"
```

Appends a new feature to backlog.json in the "idea" column. Produces exactly one line of output. No follow-up questions.

## /status

**Read-only project dashboard.**

```
/status
```

Displays:
- Foundation progress (5 artifacts)
- Active feature and current phase
- Backlog summary (features per column)
- Session count and latest Vibe Score
- Context window usage

No side effects — no state mutations, no file writes, no git operations.

## /check

**Run quality checks.**

```
/check
```

Executes the Verifier agent to run:
- Unit and component tests (Vitest)
- End-to-end tests (Playwright)
- Accessibility checks (axe-core)
- Build verification
- Lint checks

Reports a pass/fail summary with details on failures.

## /wrap

**Close session with quality gate and scoring.**

```
/wrap
```

10-step sequence:
1. Run quality gate (tests, build, lint)
2. Calculate Vibe Score (0-100)
3. Generate score breakdown with coaching
4. Create session log in `.vibecrew/sessions/`
5. Save score breakdown in `.vibecrew/scores/`
6. Generate release notes from commits
7. Update backlog with feature progress
8. Create git commit (conventional format)
9. Optionally create pull request
10. Display session summary with score
