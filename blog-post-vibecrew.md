# VibeCrew: What Happens When You Take Vibe Coding Seriously

**An architectural deep-dive for skeptical developers**

---

You've seen the tweets. Someone prompts an AI, gets a React app, ships it, and calls it "vibe coding." You've also seen the aftermath: spaghetti architectures, security holes, no tests, and codebases that become unmaintainable after 500 lines. If you're a developer who takes craft seriously, your skepticism is well-earned.

Here's the thing: the critics are right about the symptoms, but wrong about the diagnosis. The problem isn't that AI writes bad code. The problem is that nothing stops it from writing code *too early*, writing code *without a plan*, and then writing *more* code to fix the code it shouldn't have written in the first place. The failure mode of vibe coding isn't bad AI — it's the absence of engineering discipline.

VibeCrew is an attempt to add that discipline back. It's a Claude Code plugin that wraps the AI coding experience in the same kind of guardrails, workflows, and feedback loops that mature engineering teams use — except enforced deterministically by bash scripts, not by hoping the model remembers your instructions.

This post explains the architecture in detail: not just *what* it does, but *why* each decision was made. If you're skeptical, good. That's exactly the audience this was written for.

---

## The Core Insight: AI Agents Are Powerful but Unreliable

Every architectural decision in VibeCrew flows from a single observation: **LLMs are probabilistic systems, and probabilistic systems need deterministic guardrails**.

When you write a rule in a system prompt — "always write tests," "never deploy to production without review" — you're making a *suggestion*. The model will follow it most of the time. But "most of the time" isn't good enough when the failure mode is deleting your database, force-pushing to main, or building 2,000 lines against the wrong framework choice.

The conventional approach to this problem is to write better prompts. VibeCrew's approach is different: **enforce rules through bash scripts that intercept tool calls at the Claude Code lifecycle level.** These scripts consume zero model tokens, cannot be forgotten, and cannot be bypassed by the model. They're not suggestions — they're walls.

This is the philosophical foundation. Everything else follows from it.

---

## Architecture Overview: Two Tiers, 14 Agents, 19 Hooks

Before diving into specifics, here's the 30-second mental model:

**Tier 1** creates the project foundation (vision, design system, tech stack, architecture). No source code can be written until this is complete — enforced mechanically.

**Tier 2** implements features through a 6-phase cycle (Plan → Design → Code → Test → Review → Docs). Each phase has entry/exit criteria. Skipping phases reduces your quality score.

**14 specialized agents** handle different tasks, each with precisely the tools and context they need — and no more. An Opus-class model handles planning and coding (where mistakes are expensive). Haiku handles routing and mechanical tasks (where speed matters). Sonnet handles documentation (where templates matter).

**19 hook scripts** enforce rules at the system level. They intercept tool calls (file writes, shell commands, phase transitions) and either allow, block, or modify them.

Now let's unpack each layer.

---

## Tier 1: Research Before Code

### The Problem It Solves

The most expensive mistake in software development isn't a bug — it's building against the wrong architectural decisions. Choosing the wrong database, authentication system, or framework and discovering it 2,000 lines later costs 10x more than discovering it before line 1.

AI coding assistants exacerbate this because they're *eager to write code.* Ask Claude to build a SaaS app and it will happily start generating React components before you've decided whether you even want React. This eagerness is a feature in the right context and a liability in every other context.

### How VibeCrew Solves It

Tier 1 is a sequential pipeline of six artifacts that must be created before any source code:

1. **VISION.md** — Project goals, user personas, constraints, success metrics. Created through a structured interview.
2. **Design System** — CSS custom properties (colors, typography, spacing) plus a design brief. Created through a 3-phase visual direction interview, or imported from existing brand assets.
3. **Technology Decision Record (TDR)** — Every stack choice documented with alternatives considered, trade-offs, and rationale. Produced by a dedicated research agent.
4. **Architecture Diagrams** — Five Mermaid diagrams: system topology, entity-relationship, state flows, API sequences, and component tree.
5. **Roadmap** — Features prioritized into MVP/Growth/Future tiers with dependency mapping.
6. **CLAUDE.md** — Project-specific rules synthesized from all prior artifacts. Under 200 lines (more on why later).

Each artifact feeds into the next. The design system needs the vision. The TDR needs the design system. The architecture diagrams need the TDR. This order isn't just suggested — it's enforced.

### The Phase Gate: Where Enforcement Gets Real

Here's where VibeCrew diverges from "best practices in your prompt" approaches. A bash script called `phase-gate.sh` intercepts every Write and Edit tool call. If the foundation isn't complete, it blocks source code writes with a message like:

```
Foundation progress: 4/6 artifacts complete.
Missing: architecture_diagrams, claude_md
Source code writes blocked until foundation is complete.
```

Planning artifacts (VISION.md, TDR files, Mermaid diagrams, config files) are always allowed through. The gate only blocks *source code* — the kind of premature writing that creates technical debt.

This script runs at the Claude Code hook level. The model doesn't see it in its prompt. It can't be "convinced" to skip it. It's not a rule to follow — it's a wall to not walk through. Zero tokens, zero ambiguity.

### The Opponent Processor: Devil's Advocate by Design

After the TDR is drafted, an agent called the Opponent Processor reviews it. This is a read-only Opus agent whose entire purpose is to challenge every decision. It searches for real CVEs, benchmarks, and community complaints about the chosen technologies. It rates each decision (Strong / Adequate / Questionable / Weak) and produces a debate matrix.

The design rationale: "You do not tear decisions down for sport; you stress-test them so the team can proceed with higher confidence."

This is the kind of step a human tech lead performs instinctively and that AI coding assistants skip entirely. By the time you write your first line of code in VibeCrew, the tech stack has survived adversarial review.

---

## Tier 2: The Feature Development Lifecycle

Once the foundation is complete, each feature passes through six phases:

### 1. Plan (Including a Clarify Sub-Step)

The Plan phase doesn't just generate a task list — it first runs a Clarify sub-step that checks six categories of ambiguity in the feature spec. Decisions are classified as:

- **Locked** — explicitly stated in the spec, cannot be changed
- **Deferred** — intentionally postponed, will be decided later
- **Discretion** — the builder can make a reasonable choice

Why this matters: ambiguity in specs is the #1 cause of mid-feature rework. Instead of the AI making silent assumptions and building the wrong thing, VibeCrew surfaces ambiguities before a single line of code is written.

Plans use a structured task format: **Files / Action / Verify / Done**. Each task specifies which files to touch, what to do, how to verify it worked, and the completion criteria. This makes the Code phase deterministic rather than vague — the builder executes tasks, it doesn't interpret intentions.

A verification loop (up to 3 iterations) checks goal coverage, dependency integrity, and format compliance before the plan is finalized.

### 2. UI Design (ASCII Wireframes)

Before writing any frontend code, the system generates ASCII wireframes:

```
┌─────────────────────────────────┐
│  Logo    [Home] [Features] [•]  │
├───────┬─────────────────────────┤
│ Nav   │  Welcome, {user}        │
│ ----  │  ┌─────┐ ┌─────┐       │
│ Dash  │  │ KPI │ │ KPI │       │
│ Tasks │  └─────┘ └─────┘       │
│ Settn │  ┌──────────────┐      │
│       │  │ Recent Items │      │
└───────┴──┴──────────────┴──────┘
```

These cost ~50 tokens each, compared to 500–2,000 tokens for a code rebuild. Users can iterate ("make the sidebar narrower," "move the CTA above the fold") at near-zero cost before any code exists. It's visual prototyping at the speed of conversation.

### 3. Code

The Builder agent implements the plan in an isolated git worktree. It consults the TDR for technology boundaries and uses MCP servers (Context7 for library docs, Playwright for visual testing, Supabase/Stripe/Vercel when applicable) instead of pasting documentation into the context window.

One enforced rule: **always use Context7 for library documentation, never paste docs manually.** This prevents the single largest context waste pattern — a developer pasting an entire API reference when the agent only needs three function signatures.

### 4. Test

The system supports a TDD-hybrid approach: test scaffolding is generated during planning (Wave 0 tasks), and the Code phase fills in implementation. The Verifier agent (Haiku, because test running is mechanical) executes tests, lint, type-check, and build.

### 5. Review

A Code Reviewer agent (Opus, read-only, in a separate worktree) checks the implementation against the feature spec, TDR boundaries, and project conventions. It cannot modify code — only flag issues. This separation of concerns mirrors the human code review model: the person who wrote the code shouldn't be the one reviewing it.

### 6. Docs

The Doc Generator (Sonnet, because documentation is template-driven) updates feature docs, CHANGELOG, and architecture diagrams. Documentation drift — where docs fall behind the code — is tracked and penalized in the quality score.

### Complexity-Based Phase Skipping

Features carry a complexity field: `trivial`, `standard`, or `complex`.

- **Trivial** features skip Design and Review (a one-line CSS fix doesn't need a wireframe)
- **Standard** features run all six phases
- **Complex** features enable wave-based milestone decomposition — the feature is broken into independent milestones that can execute in parallel across separate agent instances

This isn't one-size-fits-all ceremony. It's right-sized process.

---

## The Hook System: Why Bash, Not Prompts

This is the most distinctive architectural decision in VibeCrew, and it deserves careful explanation.

### The Problem with Prompt-Based Rules

Every rule you put in a system prompt is probabilistic. "Never force-push to main" works until the model is at 80% context utilization, the user says "just push it," and the model complies because it's trying to be helpful. The failure probability is low per interaction but compounds across sessions.

For rules that *matter* — security boundaries, data protection, workflow enforcement — probabilistic compliance isn't good enough.

### The Solution: Deterministic Interception

Claude Code exposes lifecycle hooks: events that fire before and after tool calls, at session start and stop, and on specific conditions. VibeCrew attaches bash scripts to these hooks. The scripts inspect the tool call, check project state, and either allow, block, or modify the operation.

Here's the taxonomy:

**Session Start (4 hooks):**
- Environment checks (git, jq, node installed?)
- State synchronization (is there an active feature? which phase?)
- Error recovery (stale locks? previous session errors?)
- Context re-injection after `/compact` (so nothing is lost when the context window is compressed)

**Pre-Tool Guards (5 hooks):**
- **Phase gate** — blocks source code writes until foundation is complete
- **Path restriction** — confines writes to the project root, blocks `.env`, `.git/`, credentials files. Uses `realpath` canonicalization to defeat path traversal attacks (e.g., `src/../../etc/passwd`)
- **Command protection** — blocks 54 dangerous command patterns across 9 categories (destructive file ops, privilege escalation, git danger zone, database destruction, credential exposure, system modification, network exfiltration, resource exhaustion, indirect execution)
- **Phase transition validation** — ensures phases proceed in order
- **Signal validation** — validates inter-agent communication schema

**Post-Tool Processors (5 hooks):**
- Auto-formatting of written files
- Skill schema validation
- Drift tracking (detecting agents stuck in exploration loops)
- Context usage monitoring
- Notifications (on permission stalls, completion, and failures only)

**Session End Checks (5 hooks):**
- Quality gate — runs typecheck/lint/build on modified files; *blocks* on failure
- CLAUDE.md size/quality validation
- Cost tracking against configurable thresholds
- Context usage warnings at 45% and 60%
- Drift circuit breaker (hard stop after 35+ exploration calls without source writes)

### Two Layers of Defense

VibeCrew uses both declarative tool permissions (`settings.json`) and hook scripts. Why two layers?

`settings.json` is the coarse filter — fast, unconditional, zero-overhead. It whitelists ~95 safe tool patterns and blacklists ~23 dangerous ones (sudo, force push, rm -rf /, chmod 777). But it can't inspect command *content*.

Hook scripts are the fine filter — they can parse arguments, check project state, and provide contextual error messages. They catch nuanced patterns like "git push to main" or "write to a sensitive file path."

Neither alone is sufficient. Together, they create defense-in-depth: even if one layer is bypassed, the other catches the violation.

### Cost: Zero Tokens

This bears repeating. Every hook script runs outside the model's context window. It doesn't consume input tokens, output tokens, or context space. The model doesn't know the hook exists — it just sees "operation blocked" when it tries something forbidden. This is enforcement without cognitive overhead.

---

## Agent Topology: 14 Agents, Precisely Scoped

### Why Multiple Agents?

A single long-running AI session accumulates context, loses focus, and becomes increasingly expensive. Every additional token in the context window makes every subsequent token more expensive (input tokens are charged per request). Worse, AI models degrade at high context utilization — they become more likely to forget instructions, hallucinate, or go in circles.

VibeCrew's solution: **specialize and isolate.**

Each agent gets:
- A specific model (Opus, Sonnet, or Haiku) matched to task complexity
- A specific set of tools (principle of least privilege)
- A specific isolation level (inline or worktree)
- A specific turn budget (preventing runaway sessions)

### Model Tiering: Why Not Just Use Opus for Everything?

Opus is the most capable model — and the most expensive ($15/$75 per million input/output tokens). Using it for every task is like hiring a senior architect to run `npm test`. The model tiering follows a simple principle:

- **Opus** for tasks where mistakes are expensive to fix later: planning, code generation, security analysis, architecture review
- **Haiku** for fast, mechanical tasks: session routing (5 turns max), test execution, verification
- **Sonnet** for template-driven output: documentation generation, changelogs

This isn't just cost optimization — it's also speed optimization. Haiku responds in milliseconds where Opus takes seconds.

### Isolation: Worktrees and Tool Restrictions

Seven of the fourteen agents run in isolated git worktrees (`.claude/worktrees/<agent>-<task>/`). This means:

1. **No filesystem side effects** on the main working tree. If the Builder agent creates a mess, it's contained.
2. **Parallel execution** is possible. Multiple agents can work simultaneously without file conflicts.
3. **Research stays isolated.** Stack Scout's web searches and the Opponent Processor's adversarial analysis stay in their own context windows, not polluting the main session.

Tool restrictions follow least privilege. The Workflow Orchestrator — despite being the "brain" of the system — cannot write files. It coordinates through validated bash scripts (`complete-phase.sh`, `claim-task.sh`, `update-backlog.sh`). The Stack Scout and Opponent Processor are read-only: they can research and analyze but never modify code. The Code Reviewer can read everything but edit nothing.

If an agent has a tool, it's because the architecture specifically requires it. If it doesn't, the architecture specifically prevents it.

### The 14 Agents at a Glance

| Agent | Model | Tools | Purpose |
|---|---|---|---|
| Session Startup | Haiku | Read-only | Environment check, route to correct workflow |
| Workflow Orchestrator | Opus | State scripts only | Coordinate agents, manage phase transitions |
| Stack Scout | Opus | WebSearch, Context7 | Research technologies, produce TDR |
| Builder | Opus | Write, Edit, MCP servers | Implement features within TDR boundaries |
| Verifier | Haiku | Test/lint/build runners | Mechanical quality checks |
| Performance Coach | Opus | Read + CLAUDE.md writes | Analyze sessions, propose rule improvements |
| Code Auditor | Opus | Read-only | Existing project onboarding analysis |
| Security Auditor | Opus | Read-only, Semgrep | OWASP Top 10 vulnerability scanning |
| Doc Generator | Sonnet | Write (docs only) | Feature docs, CHANGELOG, release notes |
| Code Simplifier | Opus | Read-only analysis | Dead code detection, complexity reduction |
| CI Healer | Opus | CI logs + fix attempts | Diagnose and repair CI failures (max 3 tries) |
| Opponent Processor | Opus | Read-only + WebSearch | Devil's advocate for tech decisions |
| Code Reviewer | Opus | Read-only | Review against spec, TDR, conventions |
| System Reviewer | Opus | Read-only + telemetry | Cross-project meta-analysis |

---

## The Vibe Score: Making Quality Visible

### Why Gamify Quality?

Quality is typically invisible until something breaks. Test coverage is a number in a CI report. Code complexity is a linter warning. Documentation freshness is a hope. None of these create the tight feedback loop that drives behavioral change.

The Vibe Score answers one question: **"How efficient was this session?"** It's a coaching tool, not a report card.

### How It Works

Every session starts at 100. Points are deducted for waste and added (up to +30 cap) for completeness.

**Deductions (selected):**

| Behavior | Penalty | Why |
|---|---|---|
| Prompt churn (vague → retry → retry) | -5 per sequence | Wastes 300–500 tokens re-reading context |
| Tool loops (retrying same command) | -10 per loop | ~1,000 wasted tokens per loop |
| Low cache utilization | -15 | Context churning pushes out cached content |
| Context window violation (>60%) | -20 | Session in danger zone |
| No tests written | -10 | Feature without coverage |
| No feature spec | -5 | Implementation without a plan |
| Documentation drift | -3 per stale doc | Stale docs mislead future sessions |

**Bonuses (selected):**

| Behavior | Bonus | Why |
|---|---|---|
| All phases completed | +5 | Full lifecycle discipline |
| TDD discipline detected | +3 | Tests before implementation |
| E2E tests passing | +3 | Full user flow validation |
| Code review completed | +2 | Second-pair-of-eyes verification |
| Design system compliance | +3 | Visual consistency maintained |

### Why Subtractive?

A subtractive model (start at 100, deduct) is easier to reason about than a weighted additive model. "I lost 10 points for tool loops" is immediately actionable. "My tool efficiency weight contributed 0.73 to my composite score" is not. Each deduction maps to a specific behavior to change.

The bonus cap (+30) is also deliberate: bonuses cannot compensate for waste. A session with three tool loops (-30) but clean lint and TDD (+11) still scores 81. Bonuses reward completeness; they don't excuse inefficiency.

### Erosion Tracking: Quality Over Time

A 4-script pipeline tracks code quality degradation across sessions: per-file complexity metrics, a project baseline, rolling 20-session trends, and hot-file detection (files modified 5+ times without simplification). This catches technical debt accumulation before it becomes critical — something no single-session tool can do.

---

## The Self-Improving System

This is where VibeCrew gets genuinely interesting from an engineering perspective.

### The Performance Coach

After each session wrap, the Performance Coach agent (Opus) analyzes prompt efficiency, cache utilization, phase completeness, context discipline, and recurring patterns. When the same anti-pattern appears in 3+ of the last 10 sessions, it proposes a **permanent CLAUDE.md rule mutation**.

For example, if the Builder agent repeatedly re-reads the same configuration file across sessions, the Performance Coach might propose:

> **Proposed rule:** "Cache frequently-read config values in plan.md task context rather than re-reading from disk per task."

This proposal is shown to the user for approval — it's never auto-applied. The system has guardrails:

- Maximum 1 mutation per session
- 3-rejection cooldown (if the user rejects a proposal 3 times, it stops proposing it)
- Minimum 5 sessions of data before any proposals
- Never proposes rules that hooks already enforce (no redundancy)
- Maximum 15 accumulated learnings (oldest pruned automatically)

The result: the system's rules evolve based on observed patterns. Week 2 is more efficient than Week 1 because the rules have adapted to the specific project's patterns.

### Three Learning Mechanisms

1. **CLAUDE.md mutations** — Global rules that all agents follow. The broadest impact.
2. **Expertise records** — Structured, queryable data about specific decisions (e.g., "In this project, date formatting uses date-fns, not Moment.js"). Read by the Builder and Code Reviewer.
3. **Agent memory** — Private, free-form notes per agent. The Security Auditor remembers which vulnerability patterns it found. The Code Simplifier remembers which abstractions it recommended removing.

These persist across sessions. The system literally gets better at working on your specific project over time.

---

## Context Window Management: The Hidden Bottleneck

Most developers don't think about context window management because they interact with AI through chat interfaces where the context is implicit. But for an autonomous AI system that runs for extended periods, context is the critical resource.

### Why Context Matters

Claude's context window is 200K tokens. That sounds enormous, but it fills fast:
- A medium-sized codebase tour: 20–50K tokens
- Library documentation: 5–20K tokens per library
- Previous conversation history: grows linearly
- The system prompt itself: 2–5K tokens

At high utilization (>60%), model quality degrades. Instructions get forgotten. Responses become less coherent. The model starts going in circles. VibeCrew targets **<50% utilization** at all times.

### How VibeCrew Manages Context

**Architecture diagrams as compressed context.** Five Mermaid files total ~250–600 tokens, distilling what would otherwise be 2,000–6,000 tokens of TDR and vision documents. All five are injected once at session start.

**Context7 MCP server instead of pasted docs.** Instead of copying library documentation into the prompt, agents query Context7 for exactly the function signatures they need. This is the difference between "paste the entire React docs" (50K tokens) and "query the useEffect signature" (200 tokens).

**Fresh context per feature in batch mode.** When running `/run-backlog` (processing multiple features), each feature gets a fresh 200K context window through a new Agent instance. No context rot between features.

**Minimal CLAUDE.md.** Research (arXiv paper 2602.11988) shows oversized context files increase agent cost 20%+ without improving success rates. VibeCrew targets <200 lines for project CLAUDE.md files. The `claude-md-lint.sh` hook enforces this.

**Compact re-injection.** When context gets compressed (via `/compact`), a hook automatically re-injects project state and architecture diagrams so nothing critical is lost.

**Drift circuit breaker.** If an agent makes 35+ exploration calls (file reads, searches) without writing any source code, it's forcibly stopped. This prevents the "research death spiral" where an agent endlessly explores without making progress.

---

## Safety: Defense-in-Depth for Autonomous Execution

VibeCrew runs agents autonomously across parallel sessions. This means the safety architecture can't rely on human oversight to catch dangerous operations.

### Three-Tier Trust Model

**Tier 1 — Autonomous:** Read-only operations, tests, lint, build, git queries, feature branch commits. These either can't cause harm or are trivially reversible.

**Tier 2 — Supervised:** Source code writes, dependency installs, git push to feature branches, PR creation. Approved once per session.

**Tier 3 — Manual (always ask):** Force push, `.env` modification, database migrations, deployment, merge to main, CLAUDE.md mutations. No "approve once" shortcut exists.

### Command Protection

The `protect-data.sh` hook blocks 54 dangerous command patterns across 9 categories:

1. **Destructive file ops:** `rm -rf /`, `mkfs`, `dd if=/dev/zero`
2. **Privilege escalation:** `sudo`, `su`, `chmod 777`
3. **Git danger zone:** force push, `reset --hard`, `clean -f`, rebase main
4. **Database destruction:** `DROP TABLE`, `DELETE FROM` without `WHERE`
5. **Credential exposure:** `cat .env`, reading SSH keys or AWS credentials
6. **System modification:** global `npm install`, `brew install`
7. **Network exfiltration:** `curl POST` to non-localhost
8. **Resource exhaustion:** fork bombs, infinite loops
9. **Indirect execution:** `eval`, `shell -c`, `base64 | bash`

Each blocked command gets a descriptive error message with a safer alternative.

### Path Traversal Defense

The `restrict-paths.sh` hook uses `realpath` canonicalization to defeat path traversal attacks. The architecture doc explicitly notes: "String-based path comparison is trivially bypassed. All path checks must use `realpath` canonicalization first." This catches `../` sequences, absolute paths, home directory references, symlink escapes, null bytes, and double encoding.

### An Honest Limitation

The safety documentation acknowledges: "Regex-based command blocking is a necessary but imperfect defense. A sufficiently creative command can bypass string matching through base64 encoding, variable expansion, eval, or heredocs." The mitigation is defense-in-depth — even if command blocking is bypassed, file system restrictions and worktree rollback provide additional layers.

This honesty matters. A system that claims perfect security is lying. A system that documents its limitations and adds compensating controls is doing real security engineering.

---

## The Notification Model: Silence as a Feature

Most developer tools default to noisy. VibeCrew inverts this.

Notifications fire on exactly three conditions:
1. **Permission stall** — the system needs approval to continue
2. **Task completion** — the work is done
3. **Critical failure** — something broke that requires human attention

Everything else is silent. The rationale: **human attention is the scarcest resource.** If you're running VibeCrew in one terminal while doing other work, you don't need to know that the Builder is 40% through the feature. You need to know when it's done or when it's stuck.

The notification system includes a 7-priority fallback chain (Warp deep-link → terminal-notifier → osascript → OSC 777 → terminal bell → silent log) that adapts to whatever terminal the user is running. In Warp Terminal, notifications include deep links that jump directly to the relevant session.

---

## The User Profile System: Not Everyone Is a Senior Engineer

VibeCrew adapts to its user across 7 dimensions:

| Dimension | Range | What It Affects |
|---|---|---|
| Code Literacy | none → fluent | Technical language, comment density, explanation depth |
| Autonomy | supervised → full_auto | Approval gates, pause points |
| PR Review | walkthrough → auto_merge | PR detail level, merge behavior |
| Verbosity | minimal → educational | Output length, reasoning explanations |
| Gamification | disabled → full | Score display, achievements, challenges |
| Learning Style | don't explain → teach me | Documentation depth, inline tutorials |
| Risk Tolerance | conservative → experimental | Technology maturity criteria, framework choices |

A `supervised` + `educational` user sees detailed explanations at every decision point. A `full_auto` + `minimal` user sees near-silent execution with results. Same system, different experience.

This is why the "one right workflow" approach fails. A junior developer and a senior backend engineer have different needs from the same tool. The profile system makes the adaptation explicit rather than implicit.

---

## Slash Commands: The User Interface

VibeCrew exposes 36 slash commands as the primary user interface. Rather than writing natural language prompts, users invoke structured operations:

**The Lifecycle:**
- `/new-project` — runs the entire Tier 1 foundation pipeline
- `/new-feature "name"` — starts a Tier 2 feature cycle
- `/run-backlog` — processes multiple features with fresh context per feature
- `/wrap` — ends a session with docs, scoring, and analysis
- `/release` — generates release notes from commits since last tag

**Quality & Analysis:**
- `/check` — run tests, lint, type-check, and build
- `/review` — code review by read-only Opus agent
- `/simplify` — dead code detection and complexity reduction
- `/audit` — security analysis against OWASP Top 10
- `/a11y` — accessibility audit
- `/perf-test` — performance baseline measurement

**Operations:**
- `/fix-issue 42` — fetches a GitHub/GitLab issue, implements the fix, opens a PR
- `/heal` — diagnoses and repairs CI failures (max 3 attempts)
- `/onboard` — analyzes an existing codebase for project adoption
- `/cost` — real-time cost tracking with per-model breakdown

**Workflow Management:**
- `/idea "text"` — zero-context-cost idea capture to backlog
- `/status` — current state, active feature, phase, backlog size
- `/handoff` — generates a handoff document for another developer or session
- `/replay` — re-execute a previous high-scoring session as a template

Each command maps to a specific agent and tool set. `/idea` is particularly notable: it runs as a pure bash script, captures the idea to `backlog.json`, and returns — consuming zero model tokens. Not everything needs AI.

---

## Testing: 137 Scripts, All Tested

The plugin itself is tested using BATS (Bash Automated Testing System). Every script has a corresponding test file. Tests run in isolated temp directories with external commands mocked via PATH prepend.

Integration tests cover the full feature lifecycle, session startup chain, hook enforcement, wrap sequence, and concurrent access (parallel lock contention).

A regression test feedback loop detects `fix:` commits without accompanying test changes and auto-generates test skeletons. If this pattern recurs across 3+ sessions, the Performance Coach proposes a CLAUDE.md mutation: "Always write regression tests for bug fixes."

---

## What a Week Looks Like

A practical example: building a travel planning SaaS from scratch.

**Monday (~45 min):** Foundation. `/new-project` runs the vision interview, design discovery, Stack Scout research, Opponent Processor review, architecture diagrams, roadmap, and CLAUDE.md generation. By the end, you have a complete architectural blueprint and zero source code. This is intentional.

**Tuesday (~2 hours):** First two features. `/new-feature "User authentication"` runs Plan → Design → Code → Test → Review → Docs. Then the same for the dashboard. Each feature gets a fresh context window.

**Wednesday (~2 hours):** Parallel workflow. Planning the next feature in one terminal while the Builder implements the current one in another. `/run-backlog --parallel` for independent features.

**Thursday (~1.5 hours):** Final feature + cleanup. `/simplify` finds dead code from iteration. `/check` validates everything passes.

**Friday (~1 hour):** Polish. `/review` on the full codebase. `/a11y` for accessibility. `/release` generates release notes.

**Total: 5 features shipped, ~8 hours, average Vibe Score 89.** The second week is faster because CLAUDE.md has been refined by the Performance Coach and `/replay` templates exist for recurring patterns.

---

## Addressing the Skepticism

If you've read this far, you probably have specific objections. Let me address the most common ones:

**"This is just prompt engineering with extra steps."**

The hook system is the answer. Prompts are suggestions to a probabilistic system. Hooks are deterministic enforcement that runs outside the model's context. The phase gate, command protection, path restriction, and quality gate cannot be circumvented by clever prompting. This distinction matters when the failure mode is "AI deletes your production database."

**"14 agents is over-engineered."**

Each agent exists because the alternative is worse. A single agent that does everything burns through context, forgets instructions, and can't be run in parallel. The agent count matches the number of genuinely distinct roles in a software team: architect, developer, tester, reviewer, security analyst, documentation writer, project manager, and so on. Each runs with minimum viable context and tools.

**"AI-generated code is still low quality."**

That's a tools problem, not an AI problem. The same LLM that writes spaghetti code in a blank prompt writes significantly better code when it has: a TDR establishing constraints, a plan with structured tasks, architecture diagrams for context, a quality gate that blocks on type errors, a code reviewer that flags convention violations, and a Vibe Score that penalizes shortcuts. VibeCrew doesn't make the AI smarter — it makes the AI *more constrained*, which paradoxically produces better output.

**"Non-technical users can't build production software."**

They can't build production software *alone*. VibeCrew doesn't replace engineering judgment — it codifies it into the workflow. The TDR captures technology decisions. The phase gate prevents premature implementation. The security auditor catches OWASP vulnerabilities. The quality gate enforces type safety. These are the judgments a senior engineer would make, encoded into deterministic scripts. The human provides the *what*; the system provides the *how*.

**"I'll lose control of my codebase."**

Every change is a git commit. Every agent runs in a worktree that can be discarded. The `/undo` command rolls back the last operation. The checkpoint system creates restore points. And the human approves every consequential action (Tier 2 and Tier 3 operations). You have *more* control than in a typical AI coding session, not less — because the control mechanisms are explicit and mechanical.

---

## The Compounding Effect

The most important thing about VibeCrew isn't any single feature — it's that the features compound.

Session 1 is the slowest. You're establishing the foundation, training the system on your project, building the initial architecture. Session 10 is dramatically faster because:

- CLAUDE.md has been refined by 10 sessions of Performance Coach analysis
- Expertise records tell agents exactly how your project handles dates, auth, state management
- Agent memory prevents repeated exploration of the same code paths
- `/replay` templates encode proven patterns from high-scoring sessions
- Erosion tracking catches quality degradation before it accumulates

This is the difference between a tool and a system. A tool does the same thing every time. A system learns, adapts, and improves. VibeCrew's architecture is designed for the 50th session to be qualitatively different from the 1st — not because the AI got smarter, but because the constraints, knowledge, and patterns accumulated over time make it increasingly effective.

---

## Getting Started

VibeCrew is free and open source. Install it as a Claude Code plugin:

```bash
claude install github:fabkrum/vibe-crew
```

Run `/setup` in any project directory. The system will check your environment, create the `.vibecrew/` state directory, and guide you through foundation creation.

If you're the kind of developer who's skeptical about vibe coding — good. That skepticism is what makes you the right audience for a tool that takes engineering discipline seriously. VibeCrew doesn't ask you to trust the AI. It asks you to trust the guardrails.

---

*VibeCrew is created by Fabian Krumbholz and available at [github.com/fabkrum/vibe-crew](https://github.com/fabkrum/vibe-crew). It's MIT licensed and works with any Claude Code installation.*
