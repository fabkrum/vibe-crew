---
id: workflow-mastery
title: Workflow Mastery
level: 3
questions: 5
---

# Workflow Mastery

## Q1

What is the key structural difference between Tier 1 and Tier 2 workflows in VibeOS?

- A) Tier 1 uses Sonnet models while Tier 2 uses Haiku models to save costs on repetitive work
- B) Tier 1 is a sequential, one-time foundation process; Tier 2 is an iterative 5-phase cycle repeated for every feature
- C) Tier 1 handles backend development while Tier 2 handles frontend development
- D) Tier 1 runs automatically on session start; Tier 2 requires manual invocation with /new-feature

**Answer:** B

**Explanation:** Tier 1 is a one-time sequential process — you complete it once per project to produce the five foundation artifacts (VISION.md, design-system.css, TDR, roadmap, CLAUDE.md). After Tier 1 is complete, every new feature follows the Tier 2 cycle: Plan, UI Design, Code, Test, and Docs. The phases in Tier 2 can be worked in any order within a feature, but the Tier 1 gate must be passed before any Tier 2 work can begin.

---

## Q2

What does the /wrap command do, and when should you use it?

- A) It packages the project into a deployable build artifact and pushes it to the configured hosting provider
- B) It ends the current feature and moves it to the "completed" state in backlog.json
- C) It runs /check quality gates, generates a session handoff log, and prepares context for a clean new session
- D) It wraps long prompts into structured spec format and sends them to the Workflow Orchestrator

**Answer:** C

**Explanation:** /wrap is the session completion command. It first runs the same quality checks as /check (tests, build, lint), then the Doc Generator agent creates a session log capturing what was completed, key decisions made, and what comes next. This handoff log becomes the starting context for the next session, enabling clean state transfer without relying on the developer's memory. Use /wrap whenever a session is winding down or context is approaching 60-80%.

---

## Q3

What are the 5 phases of the Tier 2 feature development cycle, in their default sequence?

- A) Research, Spec, Build, Review, Deploy
- B) Plan, UI Design, Code, Test, Docs
- C) Design, Implement, Validate, Document, Release
- D) Spec, Prototype, Code, QA, Merge

**Answer:** B

**Explanation:** The Tier 2 cycle has five phases: Plan (feature spec and acceptance criteria), UI Design (component design aligned to the design system), Code (feature implementation within TDR boundaries), Test (spec-first for business logic, implementation-first for UI), and Docs (session logs, CHANGELOG entry, feature documentation). While these phases have a natural flow, VibeOS allows working them in any order within a single feature to accommodate different working styles.

---

## Q4

What does the /check command validate, and which agent runs it?

- A) It validates that all foundation artifacts exist and are complete; run by the Workflow Orchestrator
- B) It checks the current context usage percentage and warns if above the threshold; run by the Session Startup agent
- C) It runs the test suite, build process, and linter to verify code quality; run by the Quality Check agent
- D) It checks the Vibe Score and generates a Performance Coach report; run by the Performance Coach agent

**Answer:** C

**Explanation:** /check invokes the Quality Check agent (a Haiku model, chosen for its speed and low cost on repetitive tasks) to run three gates: the test suite must pass, the build must compile cleanly, and the linter must report zero errors. /check is a prerequisite for /wrap and /run-backlog. It is also used as a mid-session sanity check. The Vibe Score calculation happens separately via the Performance Coach, not during /check.

---

## Q5

A developer completes a feature and wants to maintain their Vibe Score streak. They have passing tests and clean lint. Which sequence of actions correctly wraps the feature and sets up the next session?

- A) Commit code, run /wrap, close the terminal
- B) Run /check, then /wrap, then start a new session with the handoff log as context
- C) Run /status to review the Vibe Score, then commit, then close
- D) Use /new-feature to automatically close the current feature before starting the next one

**Answer:** B

**Explanation:** The correct flow is: run /check to validate tests, build, and lint pass — then run /wrap which generates the session handoff log. The next session should open with that handoff log provided as context so the Workflow Orchestrator knows exactly where the project stands. Committing before /check is fine, but /wrap should be the final action before closing the terminal. /status shows current state but does not generate the handoff artifact needed to preserve momentum across sessions.
