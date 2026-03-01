---
id: architecture-planning
title: Architecture Planning
level: 3
questions: 4
---

# Architecture Planning

## Q1

What is the purpose of a Technology Decision Record (TDR) in VibeCrew?

- A) A changelog entry that records which libraries were updated in each release
- B) A document that captures which technology options were evaluated, why one was chosen, and the constraints that decision creates
- C) A configuration file that tells VibeCrew which tools and scripts to use for a given project
- D) A test specification that verifies the chosen technology integrates correctly with the project

**Answer:** B

**Explanation:** A TDR (Technology Decision Record) is an architectural artifact produced by the Stack Scout agent after a research phase. It documents the evaluated options, the selected technology, the reasoning behind the choice, and the constraints or trade-offs that come with it. TDRs are stored as permanent records so future developers understand not just what was chosen but why — and what guardrails the choice imposes on implementation.

---

## Q2

Which of the following correctly lists the 6 foundation artifacts that Tier 1 must produce before any source code can be written?

- A) VISION.md, README.md, package.json, .gitignore, TDR, CLAUDE.md
- B) VISION.md, design-system.css, TDR, roadmap, architecture diagrams, CLAUDE.md
- C) TDR, backlog.json, state.json, VISION.md, design-system.css, CLAUDE.md
- D) CLAUDE.md, TDR, feature-spec.md, roadmap, design-system.css, architecture diagrams

**Answer:** B

**Explanation:** The six Tier 1 foundation artifacts are VISION.md (product vision and goals), design-system.css (visual design tokens and component styles), TDR (technology decisions), roadmap (phased feature plan), architecture diagrams (5 Mermaid .mmd files in .vibecrew/architecture/), and CLAUDE.md (project-specific AI instructions). The phase gate hook enforces that all six exist before any source code writes are permitted. README.md and package.json are standard files but are not VibeCrew phase-gate requirements.

---

## Q3

How does the phase gate hook enforce the "research before code" principle?

- A) It delays session startup until the developer confirms they have reviewed the TDR
- B) It intercepts PreToolUse events for Write and Edit operations and blocks them if foundation artifacts are missing
- C) It adds a mandatory review step in the /new-feature command that requires TDR approval
- D) It runs a nightly job that checks for source files created before foundation artifacts were committed

**Answer:** B

**Explanation:** The phase gate is implemented as a hook on the PreToolUse event for Write and Edit tool calls. When Claude attempts to write a source code file, the hook script checks .vibecrew/state.json to confirm all foundation artifacts are marked complete. If any are missing, the hook blocks the write and returns an error explaining what must be completed first. This is a zero-token enforcement mechanism — it operates through deterministic bash logic, not model reasoning.

---

## Q4

A team wants to skip writing VISION.md and go straight to building features because they feel the product vision is "obvious." What will happen in VibeCrew, and why is skipping VISION.md a bad idea even if the vision seems clear?

- A) VibeCrew will allow it because VISION.md is optional for experienced teams; skipping it just costs -5 Vibe Score points
- B) The phase gate will block all source code writes, and without a documented vision, the AI has no reference for evaluating whether features align with product goals
- C) VibeCrew will auto-generate VISION.md from the project name, so skipping manual creation is fine
- D) The phase gate only applies to new projects; existing projects with any source code already present can skip foundation artifacts

**Answer:** B

**Explanation:** The phase gate will block every source code write until VISION.md exists — there is no bypass for "experienced teams." Beyond the mechanical enforcement, VISION.md serves as the AI's reference for product alignment. Without it, the Feature Developer and Workflow Orchestrator agents have no ground truth for evaluating whether a proposed feature fits the product's goals and constraints. What feels "obvious" to one person on day one becomes ambiguous during handoffs, scope discussions, and future sessions.
