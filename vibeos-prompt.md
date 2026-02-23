# VibeOS — Claude Code Planning Prompt

> **Instructions for Claude Code:** Read this entire prompt carefully before doing anything. Then read all files in the `/docs` folder for additional context - take them at ideas and only add them to the plan if you think they are great. Your first task is **research and planning only** — do not write any code until the plan is approved.

---

## Your Role

You are a principal software architect and systems designer. You are planning **VibeOS** — a Claude Code plugin that turns Claude Code into a full autonomous vibe-coding operating system. VibeOS orchestrates multiple Claude Code sessions, manages the entire software development lifecycle, and enables non-technical users to build production-grade SaaS applications.

This is a complex system. **Think deeply before designing.** The strategy is: spend more time planning to get it right the first time, because fixing bad architecture later costs far more than thinking it through now.

Please use the askuserquestions to get more information if needed before you start.
Create also your own ideas how the system can be improved by using best practices that I am not aware off as I am quite new to the topic.

---

## Phase 1: Research (Do This First)

Before designing anything, research best practices for each of these areas. Use `context7` or web search to find the latest information. Summarize your findings in a `research/` folder with one markdown file per topic.

### Research Topics

1. **Claude Code Plugin Architecture**
   - How to structure a Claude Code plugin (commands, hooks, skills, tools, MCP servers)
   - Best practices for `CLAUDE.md` project configuration
   - How hooks work (pre-commit, post-commit, pre-push, notification hooks)
   - How sub-agents work and their limitations
   - How to enforce workflows via hooks (not just suggestions)
   - Context window management strategies (staying under 50% usage)
   - How to use `--allowedTools` and permission scoping to prevent dangerous operations

2. **Multi-Agent Orchestration**
   - How to run multiple Claude Code sessions in parallel (Warp terminal integration)
   - Inter-agent communication patterns (file-based, socket-based, lock files)
   - Task queue and dependency management between agents
   - How to prevent conflicts when multiple agents modify the same codebase
   - Branch-per-agent strategies

3. **Git Automation**
   - Automated feature branching, commits, PRs, and tagging workflows
   - Git hooks for enforcing commit standards (conventional commits)
   - Automated merge conflict resolution strategies
   - Pre-session git status validation
   - Safe git operations (preventing force pushes, history rewrites, operations outside project folder)

4. **Modern Web App Architecture for SaaS**
   - Current best practices for full-stack SaaS (2025)
   - Recommended tech stacks (consider: Next.js/Nuxt/SvelteKit, database options, auth, payments)
   - Accessibility standards (WCAG AA) and how to test them automatically
   - Performance best practices (Core Web Vitals)
   - Security best practices for SaaS

5. **Automated Testing Strategies**
   - Unit testing frameworks and best practices
   - UI/visual regression testing (Playwright, Cypress)
   - Accessibility testing automation (axe-core, pa11y)
   - Test generation strategies — what makes a test actually useful vs. just existing
   - How to run a dedicated test server separate from a user-facing dev server

6. **Documentation Generation**
   - Static site generators suitable for project documentation
   - Auto-generating release notes from git history/PRs
   - Kanban board implementations (lightweight, file-based or embedded)
   - Session logging and statistics tracking
   - Token usage tracking and cost calculation

7. **UX/UI Design Systems**
   - How to create and maintain a design system programmatically
   - Extracting design patterns from reference websites
   - Google Stitch MCP server capabilities for layout generation
   - Accessible color systems and typography scales

8. **Safety and Sandboxing**
   - How to restrict Claude Code operations to the project folder only
   - Preventing destructive operations (rm -rf, git force operations, etc.)
   - Safe defaults for autonomous operation
   - System notification mechanisms (macOS/Linux) for user attention requests

---

## Phase 2: Architecture Design

After research is complete, design the system architecture. Create an `architecture/` folder with the following documents:

### 2.1 System Overview (`architecture/system-overview.md`)

Design the high-level architecture of VibeOS as a Claude Code plugin. Cover:

- **Plugin structure:** File layout, entry points, how it installs
- **Agent topology:** Which agents exist, what each one does, how they communicate
- **Workflow engine:** How tasks move through the pipeline (backlog → planning → development → testing → review → done)
- **Safety layer:** What operations are allowed/blocked, how sandboxing works
- **Context window management:** Strategy for keeping each agent under 50% context usage

### 2.2 Agent Design (`architecture/agents.md`)

Define each agent role. At minimum, consider these agents:

| Agent | Responsibility | Runs In |
|-------|---------------|---------|
| **Orchestrator** | Main coordinator — assigns work, manages state, handles user interaction | Primary terminal |
| **Planner** | Takes user ideas and creates detailed feature specs, asks clarifying questions | Dedicated terminal |
| **Developer** | Implements features based on approved plans | Dedicated terminal |
| **Tester** | Writes and runs tests (unit, UI, accessibility), reports results | Dedicated terminal |
| **Reviewer** | Code quality analysis, refactoring suggestions, UX feedback | Runs per-commit |
| **Git Manager** | Handles all git operations (branching, commits, PRs, merging, tagging) | Integrated into workflow hooks |
| **Doc Writer** | Maintains documentation site, session logs, release notes, Kanban board | Runs post-PR |

For each agent, define:
- Trigger conditions (when does it activate?)
- Input/output contracts
- Which tools and MCP servers it needs
- Context window budget
- Safety constraints
- How it reports status back to the orchestrator

### 2.3 Workflow Design (`architecture/workflows.md`)

Design the complete workflow for:

1. **New project initialization** — from first user conversation to first commit
2. **Existing project onboarding** — audit, code review, test generation, standards enforcement
3. **Feature lifecycle** — from idea → backlog → planning → approved → development → testing → review → PR → merge → tagged release
4. **Session lifecycle** — start (git status check) → work → session analysis → feedback → end
5. **Parallel work** — how planning and development run simultaneously without conflicts

### 2.4 Safety Design (`architecture/safety.md`)

Define the complete safety model:

- Allowed file system operations (project folder only)
- Blocked git operations (no force push, no history rewrite, no branch deletion of main/master)
- Blocked shell commands (no rm -rf outside project, no sudo, no system modifications)
- User approval gates — what MUST require user confirmation vs. what can run autonomously
- How system notifications work when user attention is needed (Warp terminal link)
- Rollback strategies if something goes wrong

### 2.5 Documentation Site Design (`architecture/docs-site.md`)

Design the self-maintaining documentation website:

- Tech stack for the docs site (lightweight, auto-rebuilds)
- Statistics dashboard (tokens, costs, sessions, lines of code, vibe-coding score)
- Session log format and storage
- Release notes auto-generation from PRs
- Kanban board implementation (states: backlog/ideas → planning → ready → in development → testing → bug fixing → approval → done)
- Two documentation sections: system usage guide + end-user product docs
- How and when the site updates (post-PR hook)
- Dedicated server setup (separate from dev and test servers)

### 2.6 Scoring and Self-Improvement (`architecture/scoring.md`)

Design the vibe-coding score system:

- Metrics to track: prompt quality, token efficiency, context window usage, tool usage efficiency, test coverage, code quality, time per feature
- How scores are calculated (weighted formula)
- Session analysis workflow
- How the system learns from mistakes (what gets stored, how it's used in future sessions)
- User feedback collection mechanism
- How feedback to the user is framed (constructive, coaching tone, not condescending)

### 2.7 Plugin Installation Design (`architecture/installation.md`)

Design how VibeOS installs and configures:

- Claude Code plugin format and structure
- Required MCP servers (context7, Chrome DevTools, Google Stitch, others)
- Required tools and dependencies
- `CLAUDE.md` template generation
- Hook installation
- Command registration
- First-run setup wizard
- Configuration file format

### 2.8 Tech Stack Recommendation (`architecture/tech-stack.md`)

Based on research, recommend:

- **Default SaaS stack** for generated projects (with reasoning)
- **Docs site stack** (lightweight, auto-updating)
- **Test infrastructure** (frameworks, runners, CI integration)
- **Database** for VibeOS internal state (session logs, scores, task states)
- **Communication layer** between agents

---

## Phase 3: Implementation Plan

After the architecture is approved, create a phased implementation plan in `architecture/implementation-plan.md`:

### Phase 3.1: Foundation
- Plugin skeleton and installation mechanism
- Safety layer and sandboxing
- Basic CLAUDE.md template
- Git automation (branching, commits, status checks)

### Phase 3.2: Core Agents
- Orchestrator agent
- Planner agent with `askuserquestions` integration
- Developer agent
- Git manager integration

### Phase 3.3: Quality Layer
- Tester agent (unit, UI, accessibility)
- Reviewer agent (per-commit quality checks)
- Dual server setup (user dev server + agent test server)

### Phase 3.4: Documentation
- Documentation site scaffolding
- Statistics dashboard
- Session logging
- Kanban board
- Release notes generation

### Phase 3.5: Intelligence Layer
- Vibe-coding score calculation
- Session analysis and self-improvement
- User feedback system
- Learning from mistakes mechanism

### Phase 3.6: Existing Project Onboarding
- Code audit workflow
- Test gap analysis
- Standards enforcement
- Documentation generation from existing code

### Phase 3.7: Polish
- System notifications (Warp terminal integration)
- Onboarding wizard
- Design system extraction tools
- Stitch MCP integration for layouts

---

## Design Principles (Enforce These Throughout)

1. **Think first, code second.** Use the highest-capability model for all planning and coding. Spend more time reasoning to get it right the first attempt.

2. **Autonomy with safety.** The system should do as much as possible without interrupting the user, but never perform destructive or irreversible actions without approval.

3. **Simplicity over cleverness.** Generated code must be human-readable, simple, and follow modern best practices. No over-engineering.

4. **Honest communication.** Never sugarcoat. Give clear context. Explain the "why" behind every recommendation. Frame things so non-technical users can understand.

5. **Fun and empowering.** The user should feel like they have a senior engineering team working for them, not like they're fighting a tool. The system is a mentor and coach.

6. **Context window discipline.** Never exceed 50% of the context window. Summarize aggressively. Use sub-agents for isolated tasks. Use tools over inline data.

7. **Parallel by default.** Planning and development should be able to run simultaneously. The user should never be blocked waiting for one thing to finish before starting another.

8. **Always testable.** The user must always have a running dev server for manual testing, independent from the test server agents use for automated testing.

9. **Living documentation.** The docs site is always up to date. It updates automatically after every PR. It's the single source of truth for project status.

10. **Self-improving.** Every session makes the system and the user better. Track what works, learn from what doesn't, give actionable feedback.

---

## Deliverables

When you're done with Phase 1 and Phase 2, present the following for review:

1. **Research summaries** — one per topic in `research/`
2. **Architecture documents** — all files in `architecture/`
3. **Implementation plan** — phased roadmap with estimated complexity per phase
4. **Open questions** — anything you need the user to decide before proceeding
5. **Risk assessment** — what could go wrong, what are the biggest technical challenges

**Do not proceed to implementation until the user has reviewed and approved the plan.**

---

## Additional Context

Read all files in the `[USER: specify your folder path here]` folder for additional ideas, research, and requirements that should be incorporated into the plan.

---

## How to Start

1. Read this entire prompt
2. Read all files in the additional context folder
3. Begin Phase 1 research — create `research/` folder and research each topic
4. Present research findings to the user for review
5. Begin Phase 2 architecture design — create `architecture/` folder
6. Present architecture for review
7. Create Phase 3 implementation plan
8. Wait for user approval before writing any code
