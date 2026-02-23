---
title: "VibeOS Guide"
subtitle: "The Complete Guide to AI-Assisted Development with VibeOS"
author: "SpeedKit"
date: "February 2026"
---

\newpage

# Part 1: Why VibeOS — The Problem with Vibe Coding Today

## The Rise of Vibe Coding

AI-assisted development — "vibe coding" — has fundamentally changed how software gets built. Instead of writing every line by hand, developers now describe what they want and let an AI agent handle the implementation. Tools like Claude Code have turned the terminal into a collaborative workspace where an AI architect writes, tests, and refactors code autonomously.

This shift is powerful. A single developer can now ship features at the pace of a small team. But it comes with a hidden cost that most teams don't realize until they're deep into a project.

## The Three Problems

### Problem 1: The Attention Bottleneck

When you run a single Claude Code session, the workflow is manageable: you give an instruction, the agent works, you review the output. But high-throughput developers don't run one session — they run five, ten, or fifteen concurrent sessions across multiple terminal tabs.

Here's what happens:

1. You start a complex refactoring task in Tab 1.
2. While it runs, you switch to Tab 2 to work on a different feature.
3. Tab 1 finishes and silently waits for your next instruction.
4. Tab 3 hits a permission prompt and silently blocks.
5. You don't notice either for ten minutes because you're focused on Tab 2.

The agent doesn't ping you. It doesn't send a notification. It just waits. Meanwhile, you're manually clicking through terminal tabs to figure out which sessions need attention — destroying your focus every time.

**The result**: Your most valuable resource — your attention — is wasted on polling instead of building.

### Problem 2: Token Waste and Context Exhaustion

Every AI session has a finite context window. Every token you spend is a token you can't get back. And most developers waste tokens without realizing it.

Common token drains:

- **Pasting documentation into chat** instead of using tool-based lookups (+1,500 tokens per paste)
- **Correcting the AI repeatedly** because the initial instruction was unclear (+500 tokens per correction)
- **Re-explaining project context** after every `/clear` because nothing was persisted (+2,000 tokens per re-initialization)
- **Letting the AI loop on failing commands** without changing approach (+1,000 tokens per loop)

When the context window fills up, you're forced to `/clear` and start fresh — losing all accumulated understanding. The AI forgets your conventions, your architecture decisions, and your progress. You spend the next ten minutes re-establishing what it already knew.

**The result**: Sessions end prematurely, work gets repeated, and velocity drops.

### Problem 3: Code Without Architecture

The most expensive mistake in vibe coding isn't a syntax error — it's building the wrong thing with the right syntax. When you jump straight into code without establishing architectural foundations, the AI makes assumptions:

- It picks a state management library you didn't want.
- It uses an API pattern that doesn't match your team's conventions.
- It generates components that don't follow your design system.
- It pulls in dependencies that conflict with your existing stack.

You catch these issues three features in, when the technical debt has compounded. Now you're spending entire sessions refactoring code that should have been written correctly from the start.

**The result**: Fast starts lead to slow projects. The speed advantage of AI-assisted development evaporates.

## What VibeOS Solves

VibeOS is a Claude Code plugin that addresses all three problems through a structured, automated system:

### 1. The Interrupt Protocol — Solve the Attention Bottleneck

VibeOS treats your attention as the most constrained resource in your workflow. The terminal stays completely silent during normal operation — no noise, no distractions. But when an agent needs you (permission blocked, task completed, critical error), it sends a native OS notification that:

- Tells you exactly what happened ("Agent blocked — needs Y/N approval")
- Deep-links to the exact terminal tab that needs you (one click, zero hunting)

You never poll tabs again. You work on whatever needs your focus, and the system interrupts you only when it matters.

### 2. The Performance Coach — Solve Token Waste

At the end of every session, VibeOS runs a retrospective. It calculates a **Vibe Score** (0-100) based on how efficiently you used the context window:

- Were you pasting docs instead of using Context7?
- Did the AI loop on failing commands?
- Were there excessive prompt corrections?
- Did you blow past context warnings?

The coach identifies the biggest waste, proposes a concrete rule to prevent it, and — with your approval — permanently writes that rule into your project's `CLAUDE.md` file. Next session, the AI knows not to repeat the same mistake.

Your development environment becomes a **learning system** that gets more efficient with every session.

### 3. The Two-Tier Workflow — Solve Architecture Drift

VibeOS enforces a clear separation between **planning** and **building**:

**Tier 1 — Project Foundation** (done once, before any code):

- Define project goals and target users
- Establish a design system
- Research and lock in the tech stack via a Technology Decision Record
- Map out the feature roadmap
- Codify project rules in CLAUDE.md

A **phase gate** blocks all source code writes until the foundation is complete. You literally cannot write code until the architecture is decided.

**Tier 2 — Feature Sessions** (repeated for each feature):

- Plan the feature with acceptance criteria
- Design the UI following your design system
- Write the code within TDR boundaries
- Write tests with a TDD-hybrid approach
- Update docs with session logs and changelogs

Every feature follows the same structured loop. Quality gates ensure tests pass before the next feature begins.

## The VibeOS Philosophy

VibeOS is built on three principles:

1. **Human attention is the bottleneck, not AI speed.** The system is designed to maximize your focus time by minimizing unnecessary interruptions and eliminating manual tab-polling.

2. **Every session should be more efficient than the last.** The Performance Coach and CLAUDE.md mutation system create a recursive improvement loop. Mistakes are identified, codified as rules, and permanently prevented.

3. **Architecture before implementation.** The phase gate and Technology Decision Record ensure that every line of code is written within a deliberate, researched architectural boundary. No more "fast start, slow project" syndrome.

## Who Is VibeOS For?

VibeOS is designed for:

- **Solo developers** who want the productivity of a team without the overhead
- **Small teams** adopting AI-assisted development and wanting consistent quality
- **Performance-focused engineers** who care about token efficiency and context window management
- **Anyone tired of the "just start coding" approach** that leads to technical debt and rework

\newpage

# Part 2: Getting Started — Installation & Setup

## Prerequisites

Before installing VibeOS, make sure you have the following:

| Requirement | Minimum Version | Check Command |
|---|---|---|
| Claude Code | 2.0.0+ | `claude --version` |
| Git | 2.30+ | `git --version` |
| GitHub CLI | 2.0+ | `gh --version` |
| Node.js | 18+ (if building JS/TS projects) | `node --version` |
| macOS | 13+ (for native notifications) | — |

### Terminal Support

VibeOS supports terminal-adaptive notifications across all major terminals:

| Terminal | Notification Method | Tab Deep-Link |
|---|---|---|
| **Warp** | OSC 777 + macOS banner | Yes (via `warp://session/<id>`) |
| **iTerm2** | OSC 9 + macOS banner | No |
| **VS Code Terminal** | macOS banner | No |
| **Terminal.app** | macOS banner | No |
| **Other** | macOS banner (best-effort) | No |

Warp provides the best experience because its deep-link support lets you click a notification and land on the exact tab that needs your attention. Other terminals will bring the app to focus but won't switch to the specific tab.

## Step 1: Install the Plugin

Copy the `claude-plugin-vibe-os/` directory into your project root:

```bash
# Option A: Copy directly
cp -r /path/to/claude-plugin-vibe-os/ /path/to/your-project/claude-plugin-vibe-os/

# Option B: Symlink (recommended for shared team installs)
ln -s /path/to/claude-plugin-vibe-os /path/to/your-project/claude-plugin-vibe-os
```

**Why symlink?** If your team shares the plugin from a central location (monorepo, shared drive, or a dedicated repo), a symlink means everyone gets updates automatically without copying files around.

### Verify the Plugin Loads

Start Claude Code in your project directory:

```bash
cd /path/to/your-project
claude
```

Claude Code automatically detects the plugin from the `.claude-plugin/plugin.json` manifest. You should see the VibeOS session startup agent run on first launch.

## Step 2: Install System Dependencies

### macOS Notifications (required)

```bash
brew install terminal-notifier
```

This enables native macOS banner notifications. Without it, VibeOS falls back to terminal-only output (no system-level alerts).

### GitHub CLI (required for PR automation)

```bash
brew install gh
gh auth login
```

The `/wrap` command can auto-create pull requests. The GitHub CLI handles authentication and PR creation.

### Optional: MCP Servers

VibeOS ships with two MCP server configurations:

**Context7** — Library documentation lookup:

- Saves ~1,500 tokens per API lookup by fetching docs on-demand instead of pasting them into chat
- Automatically available if configured in your Claude Code settings
- Check: Run a Context7 query in Claude Code to verify

**Puppeteer** — Browser automation:

- Used by the Stack Scout agent for web research during architecture evaluation
- Used for visual testing and screenshot verification
- Check: Verify the Puppeteer MCP server is configured

Both are optional but strongly recommended. Context7 alone can save thousands of tokens per session.

## Step 3: Run /setup

With the plugin installed and dependencies in place, start Claude Code and run the setup command:

```
/setup
```

The setup wizard walks you through:

### 3a. Terminal Selection

```
Which terminal do you use?
1. Warp — Full native notification support (OSC 777 + macOS banner)
2. iTerm2 — Native notification support (OSC 9 + macOS banner)
3. VS Code Terminal — macOS banner notifications
4. Terminal.app — macOS banner notifications
5. Other — Best-effort notification support
```

Your selection is stored in `.vibeos/config.json` and determines how notifications are dispatched.

### 3b. Notification Test

VibeOS sends a test notification to confirm your setup works:

```bash
./claude-plugin-vibe-os/scripts/notify.sh "Setup test: notifications working!"
```

If you see the notification — you're good. If not, the wizard checks whether `terminal-notifier` is installed and helps you fix it.

### 3c. MCP Server Verification

The wizard checks which MCP servers are available:

```
MCP Servers:
  Context7:  Connected
  Stitch:    Not configured (optional — needed for Figma-to-code)
  Puppeteer: Not configured (optional — needed for web research)
```

Don't worry if optional servers show warnings — they're not required for core functionality.

### 3d. Git Verification

```
Git: v2.43.0
GitHub CLI: v2.40.0
```

### 3e. Directory Initialization

The wizard creates the `.vibeos/` data directory:

```
.vibeos/
  config.json          # Your terminal preference and settings
  state.json           # Project foundation status + active feature
  backlog.json         # Feature backlog (initially empty)
  sessions/            # Session logs (populated after each /wrap)
  scores/              # Vibe Score breakdowns (populated by Performance Coach)
  releases/            # Release notes data (populated on tagged releases)
```

### Setup Complete

```
VibeOS Setup Complete

Terminal:      Warp (notifications enabled)
MCP Servers:   Context7, Stitch (optional), Puppeteer (optional)
Git:           v2.43.0, gh v2.40.0
Project State: New project — run /new-project to begin

Next step: /new-project
```

## Understanding the Directory Structure

Once setup is complete, your project has the following VibeOS-related files:

```
your-project/
  claude-plugin-vibe-os/          # The plugin itself (don't modify)
    .claude-plugin/
      plugin.json                 # Plugin manifest
    mcp-servers.json              # MCP server configuration
    hooks/
      hooks.json                  # Event hook bindings
    scripts/                      # 6 bash automation scripts
    agents/                       # 9 specialized AI agent prompts
    commands/                     # 9 slash command definitions

  .vibeos/                        # Your project's VibeOS data
    config.json
    state.json
    backlog.json
    sessions/
    scores/
    releases/
```

**Should you commit `.vibeos/`?** It depends on your team setup:

- **Solo developer**: Committing `.vibeos/` preserves your session history and vibe scores across machines.
- **Team**: Committing `.vibeos/state.json` and `.vibeos/backlog.json` shares project state. Session-specific files (`sessions/`, `scores/`) can be gitignored.
- **Sensitive projects**: Add `.vibeos/` to `.gitignore` if you don't want session data in version control.

## Verifying Everything Works

After setup, test the full pipeline:

1. **Notifications**: You already tested this during setup.
2. **Session startup**: Exit and restart Claude Code — the session startup agent should run automatically and show you a 3-line status summary.
3. **Phase gate**: Try writing a source file before running `/new-project`. The phase gate should block it with a message explaining that the project foundation must be completed first.

If all three checks pass, your environment is ready.

\newpage

# Part 3: Project Foundation (Tier 1) — Before You Write Code

## Why Foundation First?

The most expensive mistake in AI-assisted development isn't a bug — it's building on the wrong foundation. When you skip architecture and jump straight to code, the AI makes assumptions about your stack, your patterns, and your conventions. Three features in, you discover that those assumptions were wrong. Now you're spending entire sessions refactoring code that should have been written correctly from the start.

VibeOS prevents this with Tier 1: a one-time, sequential process that creates the architectural "contract" for your project. Every decision is made deliberately, every choice is documented, and the AI is constrained to work within those boundaries.

**The phase gate enforces this.** Until the foundation is complete, VibeOS blocks all source code writes. You literally cannot write `src/` files until the architecture is decided. This isn't a suggestion — it's a hard gate implemented via a PreToolUse hook.

## Starting the Foundation

Run the command:

```
/new-project
```

This launches a guided, 6-step process. Each step must produce an artifact before the next begins.

## Step 1: Project Goals — VISION.md

The system asks you a series of questions:

1. **What problem does this project solve?** (1-2 sentences)
2. **Who are the target users?** (e.g., "small business owners", "developers", "students")
3. **What's the value proposition?** (Why would someone use this over alternatives?)
4. **What are the constraints?** (Budget, timeline, team size, existing tech preferences)
5. **What does success look like?** (Metrics, launch criteria)

From your answers, VibeOS generates `VISION.md`:

```markdown
# Project Vision: TravelPack

## Problem Statement
Travelers waste hours switching between booking apps, spreadsheets,
and messaging threads to organize group trips.

## Target Users

### Persona 1: Sarah — The Trip Organizer
- Role: Plans group trips for friends and family
- Goal: Coordinate flights, hotels, and activities in one place
- Pain point: Herding 8 people across 4 different apps

### Persona 2: Mike — The Budget Traveler
- Role: Joins group trips, tracks personal spending
- Goal: See what he owes and what's been paid
- Pain point: Venmo requests flying in from every direction

## Value Proposition
One shared workspace for trip planning — itinerary, budget,
and group coordination in a single app.

## Constraints
- Budget: Solo developer, no paid infrastructure initially
- Timeline: MVP in 4 weeks
- Team: 1 developer using VibeOS
- Technical: Must work offline (travelers have spotty connectivity)

## Success Metrics
- MVP launched with 3 core features
- Offline-first with full sync when connected
- Sub-2-second page loads on 3G connections
```

**Why this matters**: Every agent in VibeOS reads this file. When the Feature Developer writes code, it knows who Sarah and Mike are. When the Stack Scout evaluates technologies, it factors in the offline requirement and 3G performance target. The VISION.md is the single source of truth for project intent.

## Step 2: Design System — design-system.css

The **UI Designer agent** takes over. It asks about your brand preferences:

- **Primary color**: A color or general direction ("blue", "warm tones", "#3B82F6")
- **Font preference**: System fonts, Inter, or a specific choice
- **Border radius**: Sharp (0-2px), rounded (6-8px), or pill (999px)
- **Density**: Compact, comfortable, or spacious

From your answers, it generates `design-system.css` with CSS custom properties:

```css
:root {
  /* Colors */
  --color-primary: #3B82F6;
  --color-primary-foreground: #FFFFFF;
  --color-secondary: #F1F5F9;
  --color-secondary-foreground: #0F172A;
  --color-destructive: #EF4444;
  --color-muted: #94A3B8;
  --color-border: #E2E8F0;
  --color-background: #FFFFFF;
  --color-foreground: #0F172A;

  /* Typography */
  --font-sans: 'Inter', system-ui, -apple-system, sans-serif;
  --font-mono: 'JetBrains Mono', 'Fira Code', monospace;

  /* Spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
  --spacing-md: 1rem;
  --spacing-lg: 1.5rem;
  --spacing-xl: 2rem;

  /* Radii */
  --radius-sm: 0.25rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
}
```

The UI Designer also creates a **component inventory** — a list of UI components the project will likely need based on the features described in VISION.md. These aren't built yet; they're documented as a plan for Tier 2 feature sessions.

**Why this matters**: Every component built during feature sessions uses these tokens. No hardcoded colors, no inconsistent spacing. The design system is the visual contract.

## Step 3: Architecture — docs/tdr-001-tech-stack.md

This is where the **Research-First Protocol** kicks in.

The **Stack Scout agent** activates. It's a read-only research agent with access to WebSearch, Context7, and Puppeteer. Its job is to evaluate your project requirements against current technology options and produce a definitive architecture decision.

The Stack Scout:

1. **Analyzes requirements** from VISION.md — extracts technical needs (offline support, real-time sync, performance targets)
2. **Researches current options** — uses web search for current benchmarks, community data, and pricing
3. **Evaluates trade-offs** — considers learning curve, ecosystem maturity, token efficiency, and your constraints
4. **Verifies with Context7** — confirms recommended libraries are current, not deprecated

The output is a **Technology Decision Record (TDR)**:

```markdown
# TDR-001: Technology Stack

## Status
Accepted — February 16, 2026

## Context
TravelPack requires offline-first functionality, sub-2-second
page loads on 3G, and a solo-developer workflow optimized
for AI-assisted development.

## Options Considered

### Frontend
| Option | Pros | Cons | Fit |
|--------|------|------|-----|
| Next.js 15 | SSR/SSG, large ecosystem | Heavy for offline-first | Medium |
| Remix + PWA | Nested routing, progressive enhancement | Smaller community | High |
| Vite + React + PWA | Fast builds, full PWA control | No SSR out of box | Medium |

### Database
| Option | Pros | Cons | Fit |
|--------|------|------|-----|
| IndexedDB (Dexie.js) | Native browser, offline-first | No server sync built-in | High |
| SQLite (wa-sqlite) | Familiar SQL, WASM-based | Newer ecosystem | Medium |

## Decision
Remix + PWA with Dexie.js for offline storage. Cloudflare
Workers for the sync API (free tier covers MVP traffic).

## Consequences

### Positive
- True offline-first: works without connectivity
- Remix's progressive enhancement = graceful degradation
- Dexie.js has excellent Context7 documentation coverage

### Negative
- Smaller community than Next.js — fewer Stack Overflow answers
- Mitigation: Context7 MCP compensates for documentation needs

### Token Impact Assessment
- Estimated boilerplate level: Low
- Context7 coverage: Excellent for Remix, Dexie.js, Cloudflare Workers
- Recommendation: Use Context7 for all Dexie.js API calls
```

**Why this matters**: The TDR is the architectural contract. Once you approve it, every subsequent agent works within these boundaries. The Feature Developer won't introduce Next.js when you chose Remix. The Stack Scout's research happens in an isolated context window — all those thousands of research tokens stay outside your main session, keeping it clean.

### The Research Happens in Isolation

This is a critical efficiency point. The Stack Scout runs as an isolated subagent. All the web searches, documentation fetches, and comparison analysis happen outside your main context window. Only the final TDR — the distilled decision — enters your primary session. This saves an estimated 8,000-15,000 tokens per project initialization.

## Step 4: Feature Roadmap — docs/roadmap.md

Now that the architecture is decided, VibeOS asks you to list your planned features:

> What are the main features you want to build? List them in rough priority order. Don't worry about details — we'll plan each one properly later.

The output is `docs/roadmap.md`:

```markdown
# Feature Roadmap

## Priority 1 (Must Have)
- Trip creation and itinerary builder
- Group member management and invitations
- Offline-first data sync

## Priority 2 (Should Have)
- Expense tracking and split calculations
- Push notifications for itinerary changes

## Priority 3 (Nice to Have)
- Flight and hotel price alerts
- Photo sharing timeline

## Out of Scope (for now)
- Direct booking integration — too complex for MVP
- Social features (public trips, reviews) — post-launch
```

This roadmap becomes the input for `/plan-features` later, where each feature gets a full specification with acceptance criteria.

## Step 5: Project Rules — CLAUDE.md

VibeOS synthesizes everything into `CLAUDE.md` — the master rules file that governs every AI interaction in your project:

```markdown
# CLAUDE.md — TravelPack

## Project
Offline-first group travel organizer — itinerary, budget, and
coordination in one PWA.

## Tech Stack
- Frontend: Remix + React 19
- Styling: Tailwind CSS + design-system.css tokens
- Database: Dexie.js (IndexedDB)
- API: Cloudflare Workers
- Testing: Vitest + Testing Library

## Architecture
- File structure: Remix conventions (app/routes/, app/components/)
- Offline-first: Dexie.js for local storage, background sync
- API: REST endpoints on Cloudflare Workers

## Design System
- Reference: design-system.css for all color, spacing, and typography
- Components: shadcn/ui adapted to project tokens
- Never use hardcoded values — always use CSS custom properties

## Conventions
- TypeScript strict mode
- Named exports (no default exports)
- Error boundaries on every route
- Loading states for all async operations
- Mobile-first responsive design

## Commands
- /new-feature "name" — Start a new feature
- /plan-features — Plan and prioritize the feature backlog
- /idea "text" — Quick-capture an idea
- /run-backlog — Auto-run through planned features
- /status — Check project and feature status
- /check — Run tests, build, and lint
- /wrap — End session with coaching and git commit

## Session Learnings
[This section is populated by the Performance Coach after each session]
```

**Why this matters**: `CLAUDE.md` is the first file Claude Code reads when it starts a session. Every rule here is enforced automatically. When the Performance Coach identifies an anti-pattern (like pasting docs instead of using Context7), it proposes a new rule for this file. Over time, `CLAUDE.md` becomes a living document that captures everything the AI needs to know about your project.

## Step 6: Git Initialization

VibeOS commits the foundation:

```bash
git init
git add VISION.md CLAUDE.md design-system.css docs/ .vibeos/
git commit -m "plan: project foundation — vision, TDR, design system, roadmap"
```

The foundation is now version-controlled. Any changes to the architecture are tracked.

## The Phase Gate Unlocks

With all 6 steps complete, `.vibeos/state.json` updates to mark the foundation as complete. The phase gate script checks this status on every Write/Edit operation. With the foundation complete, source code writes are now allowed. You're ready for Tier 2.

```
Project Foundation Complete

Created:
  VISION.md — Project goals and personas
  design-system.css — Design tokens and theme
  docs/tdr-001-tech-stack.md — Architecture decision
  docs/roadmap.md — Feature priorities
  CLAUDE.md — Project rules and conventions

The phase gate is now unlocked. You can write source code.

Next steps:
  /plan-features — Plan your feature backlog in detail
  /new-feature "name" — Jump straight into a feature
```

## How Long Does This Take?

The foundation process typically takes 15-30 minutes, depending on how detailed your answers are and how complex the Stack Scout's research needs to be. That investment pays for itself many times over:

- No more mid-project architecture debates
- No more wasted tokens re-explaining your stack
- No more rework from wrong assumptions
- Every agent, every session, starts with full context

\newpage

# Part 4: Building Features (Tier 2) — The Development Loop

## The Feature Lifecycle

With the project foundation in place, you're ready to build features. Tier 2 is iterative and flexible — unlike the sequential Tier 1 process, you can work on feature phases in any order. The completeness check happens when you wrap the session, not during work.

Every feature follows a lifecycle:

```
Plan  >  UI Design  >  Code  >  Test  >  Docs
```

But you're not locked into that order. You might start coding, realize you need a design decision, switch to UI design, then come back to code. VibeOS tracks which phases have artifacts — it doesn't enforce a rigid sequence.

## Planning Features: /plan-features

Before building anything, define what you're building. Run:

```
/plan-features
```

This command reads your `docs/roadmap.md` and creates structured specifications for each feature.

### What It Asks

For each feature, VibeOS gathers:

| Field | Purpose | Example |
|---|---|---|
| **Name** | Short, descriptive identifier | "User Authentication" |
| **Description** | What does this feature do? | "Login/signup with OAuth2 + email/password" |
| **Acceptance Criteria** | Specific, testable requirements | "User can sign up with email and password" |
| **Priority** | Execution order (1 = highest) | 1 |
| **Complexity** | Estimated effort | S / M / L / XL |
| **Dependencies** | Which features must come first? | "Depends on: Authentication" |

### Complexity Guide

| Size | Sessions | Examples |
|---|---|---|
| **S** (Small) | Less than 1 session | Error page, loading skeleton, about page |
| **M** (Medium) | 1-2 sessions | Auth flow, form with validation, search |
| **L** (Large) | 3-5 sessions | Booking system, real-time chat, dashboard |
| **XL** (Extra Large) | 5+ sessions | Payment integration, offline sync engine |

### The Backlog

Planned features are stored in `.vibeos/backlog.json` as structured JSON with IDs, specs, priorities, complexity ratings, statuses, and dependency references.

### Unprocessed Ideas

If you've captured ideas with `/idea` during previous sessions, `/plan-features` surfaces them:

```
You have 3 unprocessed ideas:
  1. "Add dark mode toggle using shadcn theme switcher"
  2. "Offline sync — research CRDTs"
  3. "Analytics dashboard for admin users"

Would you like to promote any of these to planned features?
```

Promoted ideas go through the full spec process. Unpromoted ideas stay in the backlog for later review.

## Starting a Feature: /new-feature

Ready to build? Start a feature session:

```
/new-feature "user authentication"
```

### What Happens

1. **Foundation check**: Verifies the project foundation is complete. If not, redirects you to `/new-project`.

2. **Active feature check**: If you already have a feature in progress, asks what you want to do:
   - Wrap it up first (`/wrap`)
   - Abandon it and start fresh
   - Cancel and continue the current feature

3. **Branch creation**: Creates a feature branch using conventional naming:
   ```
   git checkout -b feat/user-authentication
   ```

4. **Phase tracking**: Initializes the 5-phase tracker in `.vibeos/state.json` with plan, ui_design, coding, testing, and documentation — all set to "pending."

5. **Feature spec**: If the feature exists in the backlog, loads its spec. If not, guides you through quick planning (description + acceptance criteria).

6. **Hand off**: You're now in the iterative feature loop.

```
Feature session started: user-authentication
   Branch: feat/user-authentication
   Plan: docs/features/user-authentication.md

   Work on any phase — design, code, test — in whatever order feels right.

   When done: /wrap
   Quick check: /check
```

## The 5-Phase Cycle

### Phase 1: Plan

The feature spec is created during `/plan-features` or at the start of `/new-feature`. It lives at `docs/features/<feature-name>.md` and contains the description, acceptance criteria, edge cases, and technical notes.

### Phase 2: UI Design

The **UI Designer agent** handles component design. It:

- Reads the feature spec to understand what UI components are needed
- Designs component structure (hierarchy, props, variants)
- Builds using your design system tokens (never hardcoded values)
- Follows mobile-first responsive patterns
- Ensures WCAG 2.1 AA accessibility compliance

The UI Designer recommends the right tool for each component:

- **shadcn/ui**: Best for individual components (forms, cards, dialogs, data tables)
- **Google Stitch**: Best for full page layouts and complex responsive designs

### Phase 3: Coding

The **Feature Developer agent** writes the implementation. It:

- Reads the TDR to stay within architectural boundaries
- Uses design system tokens from `design-system.css`
- Checks Context7 MCP before using any library API
- Follows conventions from `CLAUDE.md`
- Updates phase tracking as files are created

### Phase 4: Testing

The **Test Writer agent** follows a TDD-hybrid approach:

**Business logic** (spec tests — written FIRST):

- Acceptance criterion: "User can sign up with email"
- Tests: "creates account with valid email and password", "rejects invalid email format", "rejects password under 8 characters"

**UI components** (implementation tests — written AFTER):

- Component: LoginForm
- Tests: "renders email and password fields", "shows validation errors for empty fields", "calls onSubmit with credentials", "disables submit while loading"

### Phase 5: Documentation

The **Doc Generator agent** creates:

- Feature documentation at `docs/features/<name>.md`
- CHANGELOG.md entries
- Updated README if needed

## Automated Backlog Execution: /run-backlog

For maximum throughput, use the automated backlog runner:

```
/run-backlog
```

This runs a REPL-style loop through your planned features:

```
1. Pick next planned feature (by priority)
2. Start feature session (/new-feature)
3. Execute: Plan > Design > Code > Test
4. Quality gate: tests + build + lint
5. Pass? Mark complete, loop to step 1
   Fail? Stop. Developer fixes. Resume.
```

### The Quality Gate

Before moving to the next feature, every feature must pass:

| Check | Requirement |
|---|---|
| Tests | `npm test` exits 0 (all tests pass) |
| Build | `npm run build` exits 0 (compilation succeeds) |
| Lint | `npm run lint` exits 0 (no lint errors — warnings OK) |

If any check fails, the loop stops. You fix the issue, then run `/run-backlog` again to resume from where it left off.

### Dependency Awareness

The backlog runner respects feature dependencies. If Feature B depends on Feature A, it won't start Feature B until Feature A has status "complete" in the backlog.

### Completion

When all planned features pass their quality gates:

```
Backlog Complete!

Completed features:
  1. User Authentication
  2. Trip Creation
  3. Group Management
  4. Offline Sync

2 unprocessed ideas remain. Run /plan-features to review them.
```

## Daily Commands

### /idea — Zero-Disruption Idea Capture

Mid-session inspiration? Capture it without breaking flow:

```
/idea "add dark mode toggle using the shadcn theme switcher"
```

Output (exactly one line):

```
Idea captured. Continuing current task.
```

That's it. No follow-up questions, no research, no agent spawning. The idea is timestamped and added to `.vibeos/backlog.json` with status "idea." You'll see it next time you run `/plan-features`.

### /status — Where Am I?

Lost your place? Starting a new session and can't remember what you were working on?

```
/status
```

This reads all VibeOS state files and presents a comprehensive dashboard showing:

- **Project Foundation** status — which artifacts exist
- **Feature Backlog** — completed, in-progress, and planned features plus unprocessed ideas
- **Active Feature** — current branch, which phases are complete/pending
- **Recent Sessions** — last few sessions with Vibe Scores
- **Git Status** — current branch, uncommitted changes

The `/status` command is read-only and saves ~500 tokens compared to asking "where was I?" in free-form text.

### /check — Quick Quality Validation

Run tests, build, and lint without blocking your workflow:

```
/check
```

```
=== VibeOS Quality Check ===

Tests:  24 passed, 0 failed (1.2s)
Build:  Compiled successfully (3.4s)
Lint:   0 errors, 3 warnings (0.8s)

Overall: PASS
```

The `/check` command uses the fast haiku model for minimal token cost. It auto-detects your project type (Node.js, Rust, Go, Python, Ruby) and runs the appropriate commands.

## Ending a Session: /wrap

When you're done working — whether the feature is complete or you're stopping for the day:

```
/wrap
```

The wrap sequence:

1. **Completeness check**: Shows which phases have artifacts and which are missing
2. **Offers to complete missing phases**: If testing or docs are missing, offers to handle them now
3. **Quality check**: Runs tests, build, and lint
4. **Performance Coach**: Calculates your Vibe Score and provides coaching (covered in detail in Part 5)
5. **Session log**: Records session data to `.vibeos/sessions/`
6. **Git commit**: Creates an appropriate commit:
   - Feature complete: `feat(auth): user authentication with OAuth2 and email`
   - Feature in progress: `wip(trip-creation): plan + design + coding done`
7. **Optional PR**: Offers to create a pull request for completed features

### Why Always Wrap?

Never just close the terminal. Always run `/wrap` because:

- **Uncommitted work is invisible work.** The wrap ensures everything is committed — at minimum a WIP commit.
- **Session data feeds the learning system.** The Performance Coach needs session data to calculate Vibe Scores and propose CLAUDE.md improvements.
- **State tracking stays accurate.** The `.vibeos/state.json` file is updated so your next session knows exactly where you left off.

## A Typical Day with VibeOS

```
# Morning — start fresh
claude
# Session startup agent runs automatically, shows you where you left off

/status
# Full dashboard: 2/4 features done, Trip Creation in progress

# Continue where you left off
"Continue implementing the itinerary builder component"

# Mid-session inspiration
/idea "add drag-and-drop reordering to itinerary items"

# Quick quality check
/check

# End of day
/wrap
# Vibe Score, coaching, commit, session log
```

\newpage

# Part 5: The Intelligence Layer — Hooks, Agents & Automation

## How VibeOS Works Under the Hood

VibeOS isn't just a collection of slash commands. It's a system of automated hooks, specialized agents, and shell scripts that run behind the scenes — enforcing quality, managing your attention, and continuously improving your workflow. This part explains the machinery.

## The Hook System

Claude Code exposes lifecycle events that VibeOS binds to via `hooks/hooks.json`. These hooks fire automatically — no user action required. Because they're shell scripts, they consume zero AI context tokens.

| Hook Event | Script/Agent | When It Fires | What It Does |
|---|---|---|---|
| **SessionStart** | session-startup.md | Every time Claude Code starts | Environment check, state detection, routing |
| **PreToolUse** (Write/Edit) | phase-gate.sh | Before any file write | Blocks source code writes if foundation is incomplete |
| **PreToolUse** (Bash) | protect-data.sh | Before any shell command | Blocks dangerous operations |
| **PostToolUse** (Write/Edit) | format-code.sh | After every file write | Auto-formats the written file |
| **Notification** | notify.sh | Permission blocked or task complete | Sends native OS notification |
| **PostToolUseFailure** | notify.sh | Any tool execution fails | Sends error notification |
| **Stop** | check-context.sh | Context usage hits thresholds | Warns at 60% and 80% context usage |

### How Hooks Work

When Claude Code encounters a lifecycle event, it:

1. Checks `hooks.json` for matching entries
2. Passes a JSON payload to the script via stdin
3. The script processes the payload and returns an exit code
4. Exit code 0 = continue; Exit code 2 = block the operation

This means hooks can both **observe** (PostToolUse) and **control** (PreToolUse) the agent's behavior.

## The Interrupt Protocol: Notifications That Actually Work

### The Problem with Terminal Notifications

Standard terminal notifications have a critical flaw: they tell you *something* happened but not *where*. When you're running multiple terminal tabs, a notification saying "Agent needs approval" forces you to click through every tab to find the right one. This manual polling destroys your focus.

### How VibeOS Solves It

The `notify.sh` script implements the Interrupt Protocol — a terminal-adaptive notification system that:

1. **Stays silent by default.** Normal operations produce no notifications. Your attention is only consumed when it's needed.

2. **Fires on three specific conditions:**
   - **Permission blocked** — The agent needs your Y/N approval to proceed
   - **Task complete** — A complex operation finished and the agent is idle
   - **Critical failure** — A tool execution failed with a fatal error

3. **Adapts to your terminal:**

| Terminal | Method | Deep-Link |
|---|---|---|
| **Warp** | terminal-notifier with deep-link | Click notification goes to exact tab |
| **iTerm2** | OSC 9 escape sequence + terminal-notifier | Click notification goes to iTerm2 |
| **VS Code** | terminal-notifier | Click notification goes to VS Code |
| **Terminal.app** | terminal-notifier | Click notification goes to Terminal.app |

### Warp Deep-Linking

Warp Terminal exposes a `WARP_SESSION_ID` environment variable for each tab session. VibeOS captures this and constructs a `warp://session/<id>` deep link. When the notification fires and you click it, macOS executes the deep link — Warp brings itself to the foreground and switches to the exact tab that needs you.

This reduces context-switching from "hunt through 15 tabs" to "one click."

### The Notification Script Flow

```
Event fires > notify.sh receives JSON via stdin
  |
Parse notification_type with jq
  |
Is it permission_prompt, idle_prompt, or error?
  |-- No  > Exit silently (preserve Deep Work)
  |-- Yes > Construct notification
              |
         Detect terminal type
              |
         Build notification with appropriate title/body
              |
         If Warp: attach deep-link via -execute flag
              |
         Dispatch via terminal-notifier
              |
         Exit 0 (allow agent to continue)
```

## The Phase Gate: Architecture Before Code

### How It Works

The `phase-gate.sh` script runs on every PreToolUse event for Write and Edit tools. It:

1. Reads `.vibeos/state.json`
2. Checks `project_foundation.status`
3. If "incomplete" — examines the file path being written:
   - Configuration files (`.vibeos/`, `CLAUDE.md`, `VISION.md`, `docs/`, `design-system.css`) — **Allowed** (these are foundation artifacts)
   - Source code files (`src/`, `app/`, `lib/`, `components/`, etc.) — **Blocked**
4. Returns exit code 2 to block, or exit code 0 to allow

### What the Developer Sees

When blocked:

```
Phase Gate: Source code writes are blocked.

The project foundation is incomplete. Complete these steps first:
  - VISION.md — Run /new-project
  - design-system.css
  - docs/tdr-001-tech-stack.md
  - docs/roadmap.md
  - CLAUDE.md

Run /new-project to create the project foundation.
```

Once the foundation is complete, the gate unlocks permanently for that project.

## Data Protection

The `protect-data.sh` script runs on every PreToolUse event for Bash commands. It scans the command for dangerous patterns:

| Pattern | Why It's Blocked |
|---|---|
| `rm -rf /` or `rm -rf ~` | Catastrophic file deletion |
| `DROP TABLE` / `DROP DATABASE` | Database destruction |
| `git push --force` to main/master | Overwriting shared history |
| Deletion of `.env`, `.git/`, `node_modules/` | Critical project files |
| `chmod 777` | Insecure permissions |

If a dangerous command is detected, the script blocks it with a warning and suggests a safer alternative.

## Auto-Formatting

The `format-code.sh` script runs on every PostToolUse event for Write and Edit tools. It:

1. Detects the file type from the extension
2. Runs the appropriate formatter:
   - JS/TS/JSX/TSX: Prettier (if installed)
   - Python: Black or Ruff (if installed)
   - Rust: rustfmt (if installed)
   - Go: gofmt
   - CSS/SCSS: Prettier (if installed)
3. If no formatter is found, silently skips

This ensures every file the AI writes is properly formatted without consuming any context tokens.

## Context Management

The `check-context.sh` script monitors context window usage and fires at two thresholds:

**At 60% usage:**

```
Context usage: 60%. Consider wrapping up soon (/wrap) or
reducing token-heavy operations.
```

**At 80% usage:**

```
Context usage: 80%. High risk of context exhaustion.
Recommended: /wrap now to preserve session state and
start a fresh context.
```

These warnings prevent the worst-case scenario: losing all accumulated context because you didn't notice the window filling up.

## The Agent Architecture

VibeOS uses 9 specialized agents, each with a specific role, model selection, and tool access.

### Model Strategy

| Model | Cost | Speed | Used For |
|---|---|---|---|
| **Haiku** | Lowest | Fastest | Routine checks: session startup, quality validation |
| **Sonnet** | Medium | Fast | Core work: coding, testing, design, research, coaching |

Haiku is used for agents that run frequently and need to be fast (session startup runs every session, quality check runs on every `/check`). Sonnet handles the heavy lifting.

### Agent Roster

**Session Startup** (Haiku) — Runs automatically on every session start. Checks for first-time setup, reads git status, loads project state, presents a 3-sentence summary, routes to the next action. Token budget: under 200 words of output.

**Workflow Orchestrator** (Sonnet) — Runs when routing between Tier 1 and Tier 2. Reads project state, determines which workflow is appropriate, coordinates handoffs between agents. Never writes source code itself — always delegates.

**Stack Scout** (Sonnet) — Runs during Tier 1 architecture step. Has access to WebSearch, WebFetch, Context7 MCP, and Puppeteer MCP. Researches technology options, evaluates trade-offs, generates the TDR. Read-only — never creates source files, only documentation. Runs in a separate context window, keeping research tokens out of the main session.

**UI Designer** (Sonnet) — Runs during Tier 1 (design system) and Tier 2 (component design). Creates design systems, designs components, ensures accessibility. Always uses design tokens — never hardcoded values.

**Feature Developer** (Sonnet) — Runs during Tier 2 coding phase. Implements features within TDR boundaries. Checks Context7 before using any library API — no guessing at signatures.

**Test Writer** (Sonnet) — Runs during Tier 2 testing phase. Writes spec tests for business logic (TDD — before implementation), writes implementation tests for UI (after implementation). Tests behavior, not implementation — tests should survive refactoring.

**Doc Generator** (Sonnet) — Runs during `/wrap` and Tier 2 documentation phase. Creates session logs, CHANGELOG entries, feature docs, release notes. Structured JSON output for session logs and release notes (feeds the companion web app).

**Performance Coach** (Sonnet) — Runs during `/wrap`. Calculates Vibe Score, provides coaching, proposes CLAUDE.md mutations. One actionable tip per session — specific, not generic.

**Quality Check** (Haiku) — Runs during `/check`, `/wrap`, and `/run-backlog` quality gates. Auto-detects project type, runs tests/build/lint, reports results. Fast execution with 60-second timeout per command.

## The Performance Coach Deep Dive

### The Vibe Score (0-100)

The Performance Coach calculates a score starting at 100 and applying deductions:

| Anti-Pattern | Deduction | How It's Detected |
|---|---|---|
| **Prompt churn** | -5 per sequence | 3+ consecutive messages correcting the same task |
| **Tool loops** | -10 per loop | Same tool call with identical args repeated 3+ times |
| **Low cache utilization** | -15 | Cache read tokens < 20% of input tokens |
| **Context violation** | -20 | Significant work continued after 80% context warning |
| **No tests written** | -10 | Feature has coding artifacts but no test artifacts |
| **No feature spec** | -5 | Coding started without a plan artifact |

Bonus points (up to +10):

- +5 for all 5 phases having artifacts
- +5 for cache utilization > 50%

### Score Ranges

| Range | Rating | Meaning |
|---|---|---|
| 90-100 | Excellent | Efficient, well-structured session |
| 75-89 | Good | Minor inefficiencies |
| 60-74 | Needs improvement | Notable token waste |
| Below 60 | Review session | Significant anti-patterns |

### The Coaching Dialogue

After calculating the score, the Performance Coach:

1. **Presents the score** with the top observation:

   "Vibe Score: 82/100. Top observation: You pasted API documentation into the chat 3 times (~4,500 tokens). Using Context7 MCP would have saved those tokens."

2. **Asks for feedback**: "How did this session feel? Any friction points?"

3. **Proposes a CLAUDE.md rule** based on the analysis and your feedback:

   "Proposed rule: Always use Context7 MCP to look up Dexie.js API documentation instead of pasting docs into chat. Add this rule? (y/n)"

4. **Mutates CLAUDE.md** if approved — appends the rule to the Session Learnings section.

### Why This Matters

The coaching cycle creates a **recursive improvement loop**:

- **Session 1**: Developer pastes API docs. Vibe Score 78. Coach proposes rule: "Use Context7 for API docs." Developer approves. Rule added to CLAUDE.md.
- **Session 2**: AI reads CLAUDE.md, sees the rule, uses Context7. No doc pasting. Vibe Score 89. Coach identifies a new inefficiency. New rule proposed.
- **Session 3**: Two rules active. Even more efficient. Vibe Score 94.

Each session is more efficient than the last. Mistakes are identified, codified, and permanently prevented.

## MCP Servers

VibeOS configures two MCP (Model Context Protocol) servers:

### Context7 — Library Documentation

- **Purpose**: On-demand API documentation lookup
- **Savings**: ~1,500 tokens per API lookup (vs. pasting docs into chat)
- **Used by**: Stack Scout (research), Feature Developer (implementation), Test Writer (test framework APIs)

Instead of the developer pasting documentation into the chat (or the AI hallucinating API signatures), Context7 fetches the current, accurate docs in real-time.

### Puppeteer — Browser Automation

- **Purpose**: Web research and visual testing
- **Used by**: Stack Scout (researching technology options), UI Designer (visual verification)

Puppeteer allows agents to browse the web, take screenshots, and interact with web applications — useful for competitor research during architecture evaluation and for visual regression testing.

## State Management: The .vibeos/ Directory

All VibeOS state lives in `.vibeos/`:

| File | Purpose | Updated By |
|---|---|---|
| `config.json` | Terminal preference, notification settings | `/setup` |
| `state.json` | Project foundation status + active feature | All commands |
| `backlog.json` | Feature backlog with specs and priorities | `/plan-features`, `/idea`, `/run-backlog` |
| `sessions/*.json` | Session logs with phase data and token metrics | `/wrap` |
| `scores/*.json` | Vibe Score breakdowns with deductions and bonuses | Performance Coach |
| `releases/*.json` | Release notes data | Doc Generator |

This structured data serves two purposes:

1. **Session continuity**: The startup agent reads state.json to know exactly where you left off.
2. **Analytics**: Session logs and scores feed the companion web dashboard for team retrospectives and trend analysis.

## Git Automation

The `git-auto.sh` script handles all git operations:

- **Branch creation**: `feat/<name>`, `fix/<name>`, `docs/<name>` with sanitized names
- **Conventional commits**: `feat(auth): user authentication with OAuth2`
- **WIP commits**: `wip(trip-creation): plan + design + coding done`
- **PR generation**: Auto-creates GitHub PRs with structured descriptions via `gh pr create`

All commits follow conventional commit format, making changelogs and release notes automatable.

\newpage

# Part 6: Team Rollout & Continuous Improvement

## Sharing VibeOS Across Your Team

VibeOS is designed to scale from a solo developer to a full team. The plugin architecture makes distribution straightforward, and the state management system supports both individual and shared workflows.

### Distribution Options

| Method | Best For | How It Works |
|---|---|---|
| **Git submodule** | Teams with a shared monorepo or plugin repo | `git submodule add <repo-url> claude-plugin-vibe-os` in each project |
| **Symlink** | Teams on shared machines or with a central plugin directory | `ln -s /shared/path/claude-plugin-vibe-os ./claude-plugin-vibe-os` |
| **Direct copy** | Quick setup, no ongoing sync needed | `cp -r claude-plugin-vibe-os/ /path/to/project/` |
| **npm/package** | JavaScript/TypeScript teams | Publish as a private package and install via npm |

**Recommended for most teams**: Git submodule. It keeps the plugin version-controlled, allows updates to propagate via `git submodule update`, and each project gets the same version.

### Team Setup Process

1. **Admin**: Add `claude-plugin-vibe-os/` to the project repository (submodule or direct copy).
2. **Each developer**: Runs `/setup` on first use to configure their terminal preference and verify dependencies.
3. **Project lead**: Runs `/new-project` once to create the shared foundation (VISION.md, TDR, design system, CLAUDE.md).
4. **Everyone**: Uses `/plan-features`, `/new-feature`, and `/run-backlog` for their individual feature work.

### What's Shared vs. Individual

| Data | Shared (committed to git) | Individual (per-developer) |
|---|---|---|
| Plugin files | Yes | — |
| Foundation (VISION.md, CLAUDE.md, TDR, design system) | Yes | — |
| Backlog (`.vibeos/backlog.json`) | Yes | — |
| Feature state (`.vibeos/state.json`) | Depends on workflow | Can be per-branch |
| Session logs (`.vibeos/sessions/`) | Optional | Usually individual |
| Vibe Scores (`.vibeos/scores/`) | Recommended | — |
| Config (`.vibeos/config.json`) | No (terminal-specific) | Yes |

**Recommendation**: Commit `.vibeos/state.json` and `.vibeos/backlog.json` so the team shares project state and the feature backlog. Commit `.vibeos/scores/` so scores are available for team retrospectives. Gitignore `.vibeos/config.json` (terminal preference is per-developer).

### Suggested .gitignore

```
# VibeOS — per-developer config
.vibeos/config.json
```

## CLAUDE.md as a Team Knowledge Base

The `CLAUDE.md` file is the most powerful team asset VibeOS produces. Over time, it accumulates project-specific rules that every AI session reads on startup.

### How Rules Accumulate

- **Week 1**: CLAUDE.md has 5 rules from project foundation
- **Week 2**: Developer A's Performance Coach adds a rule. Developer B's Coach adds another. Now 7 rules.
- **Week 4**: 4 more rules added across team sessions. Now 11 rules.
- **Month 2**: CLAUDE.md has 20+ rules — a comprehensive codex of project conventions, anti-patterns to avoid, and tool-usage best practices.

### Why This Matters for Teams

When a new developer joins:

1. They run `/setup` — environment configured in 2 minutes
2. They run `/status` — see the full project state
3. They start working — Claude reads CLAUDE.md and immediately knows:
   - The tech stack and architecture decisions
   - Every convention the team has established
   - Every anti-pattern previous sessions have identified
   - Which MCP tools to use for which operations

**There's no onboarding doc to read.** The AI already knows everything.

### Curating CLAUDE.md

Over time, some rules may become redundant or outdated. Periodically review `CLAUDE.md` as a team:

- **Remove obsolete rules**: If you changed your stack, remove rules about the old stack.
- **Consolidate similar rules**: If three rules say "use Context7," merge them into one.
- **Promote critical rules**: Move the most important rules to the top of the file — Claude Code reads them with higher priority.
- **Add team conventions**: Beyond what the Performance Coach adds, manually add team agreements (PR review process, branch naming, etc.).

## Vibe Score Retrospectives

### Using Scores in Team Retros

Vibe Scores are stored as structured JSON in `.vibeos/scores/`. Each file contains the date, feature name, score, deductions, bonuses, coaching given, developer feedback, and any CLAUDE.md mutations.

### Retro Agenda Template

Use Vibe Scores to drive data-driven retrospectives:

**1. Score Trends (5 min)**

- Average team Vibe Score this sprint
- Trend: improving, stable, or declining?
- Highest and lowest scores — what drove them?

**2. Common Anti-Patterns (10 min)**

- What deductions appeared most often across the team?
- Are we still pasting docs? Are we still hitting context limits?
- Which CLAUDE.md rules were added this sprint?

**3. Efficiency Wins (5 min)**

- Which sessions scored 90+? What made them efficient?
- Did any CLAUDE.md mutation have a noticeable impact?
- Are we using MCP servers effectively?

**4. Action Items (5 min)**

- New rules to add to CLAUDE.md manually
- MCP server setup that needs to happen
- Training needed (Context7 usage, TDD practices, etc.)

### Score Benchmarks

| Team Average | Assessment | Action |
|---|---|---|
| 90+ | Excellent | Team is highly efficient — maintain current practices |
| 80-89 | Good | Minor improvements possible — focus on the most common deduction |
| 70-79 | Needs attention | Review session transcripts — likely a systemic issue |
| Below 70 | Requires intervention | Workshop on AI-assisted development best practices |

## Best Practices

### For Solo Developers

1. **Always run /wrap.** Never close the terminal without wrapping. The session log and Vibe Score are your accountability system.
2. **Use /idea aggressively.** When inspiration strikes mid-feature, capture it and move on. Don't let tangential ideas derail your current work.
3. **Trust the phase gate.** It feels restrictive at first, but the foundation prevents exponentially more pain later.
4. **Review CLAUDE.md monthly.** Remove stale rules, consolidate duplicates, and ensure it reflects your current practices.

### For Teams

1. **One person owns the foundation.** The project lead should run `/new-project` and establish the TDR. Don't have 5 people debating architecture in separate sessions.
2. **Share the backlog.** Use `/plan-features` as a team exercise — everyone contributes feature specs, then prioritize together. Commit `backlog.json` so everyone works from the same list.
3. **Commit Vibe Scores.** Make scores visible to the team. Not as a competition, but as a shared learning signal.
4. **Do score retros.** Even 15 minutes every two weeks, reviewing score trends and adding team rules to CLAUDE.md, compounds into massive efficiency gains.
5. **Standardize terminal setup.** If possible, standardize on Warp for the team — the deep-link notifications are worth it.

### For Token Efficiency

1. **Use Context7 for everything.** Before pasting any documentation into chat, check if Context7 has it. This is consistently the single biggest token saver.
2. **Write clear initial prompts.** Prompt churn (-5 points each) comes from vague instructions. Spend 30 seconds writing a precise prompt instead of 3 follow-up corrections.
3. **Respect context warnings.** When you see the 60% warning, start thinking about wrapping. At 80%, definitely wrap. Pushing to 100% risks losing everything.
4. **Let agents run in isolation.** The Stack Scout, Test Writer, and Doc Generator run in separate contexts. Don't duplicate their work in the main session.
5. **Review the TDR before coding sessions.** If you start a session and Claude asks about your stack, it means the TDR or CLAUDE.md isn't comprehensive enough. Add the missing information.

## Common Anti-Patterns to Avoid

| Anti-Pattern | What Happens | Fix |
|---|---|---|
| **Skipping /wrap** | No session log, no Vibe Score, no CLAUDE.md improvements | Always wrap. Make it a habit. |
| **Ignoring the phase gate** | Foundation artifacts are missing, AI makes wrong assumptions | Complete /new-project fully before any feature work |
| **Pasting docs into chat** | 1,500+ tokens wasted per paste | Use Context7 MCP — it's configured and ready |
| **Starting features without specs** | Feature Developer guesses at requirements, rework later | Always run /plan-features or write a spec at /new-feature |
| **Pushing past context 80%** | Context exhaustion, /clear, lose all session state | Wrap at 80%. Fresh context + CLAUDE.md = fast restart |
| **Not reading the Vibe Score** | Same mistakes repeat across sessions | Take 30 seconds to read the coaching output at /wrap |
| **Hardcoding design values** | Inconsistent UI, wasted tokens fixing later | Reference design-system.css tokens |

## Troubleshooting

### Notifications Don't Appear

1. **Check terminal-notifier**: Run `terminal-notifier -message "test"` in your terminal. If nothing appears, reinstall: `brew install terminal-notifier`
2. **Check macOS notification settings**: System Settings > Notifications > terminal-notifier > ensure "Allow Notifications" is on
3. **Check VibeOS config**: Verify `.vibeos/config.json` has `"notifications": true`
4. **Warp deep-links not working**: Ensure Warp is running and check that `echo $WARP_SESSION_ID` returns a value in the terminal tab

### Phase Gate Blocks When It Shouldn't

1. **Check state.json**: Read `.vibeos/state.json` — is `project_foundation.status` set to `"complete"`?
2. **Foundation incomplete**: If any foundation step is null, run `/new-project` to complete the missing steps
3. **File path issue**: The phase gate allows writes to config files (`.vibeos/`, `CLAUDE.md`, `docs/`). If a legitimate config file is being blocked, check the path patterns in `phase-gate.sh`

### MCP Servers Not Available

1. **Context7**: Verify it's configured in your Claude Code settings. Try a test query.
2. **Puppeteer**: Ensure the Puppeteer MCP server is running. Check the MCP server configuration.
3. **Not critical**: Both MCP servers are optional. VibeOS works without them — you just miss the token efficiency benefits.

### Vibe Score Seems Inaccurate

1. **New projects**: Scores are less meaningful in the first few sessions as the system establishes baselines.
2. **Complex features**: Large features naturally have more tool calls and corrections — the score accounts for this but may seem low.
3. **Override deductions**: If the coach flags something that was unavoidable, say so during the coaching dialogue — it factors into the next proposal.

### Git Conflicts in .vibeos/

When multiple developers work on the same project:

- `state.json` can conflict if two people have different active features — resolve by keeping the most recent active feature
- `backlog.json` can conflict if features are added simultaneously — merge the feature arrays
- `scores/` and `sessions/` rarely conflict because they're timestamped per-developer

## Quick Reference Card

### Commands

| Command | Purpose | When to Use |
|---|---|---|
| `/setup` | First-time environment configuration | Once per developer |
| `/new-project` | Create project foundation | Once per project |
| `/plan-features` | Define and prioritize feature backlog | Before starting feature work |
| `/idea "text"` | Capture an idea instantly | Anytime — zero disruption |
| `/new-feature "name"` | Start a feature session | Beginning of each feature |
| `/run-backlog` | Auto-execute features in priority order | Hands-free execution |
| `/status` | See project and feature status | Start of session or when lost |
| `/check` | Run tests, build, and lint | During development |
| `/wrap` | End session properly | End of every session |

### Workflow at a Glance

```
TIER 1: Foundation (once per project)

  /setup  >  /new-project

  Creates: VISION.md, design system, TDR, roadmap, CLAUDE.md
  Then: Phase gate unlocks

              |
              v

TIER 2: Features (repeat per feature)

  /plan-features  >  /new-feature  (or /run-backlog)

  Cycle: Plan > Design > Code > Test > Docs

  End: /wrap (coaching + commit)
```

### Key Files

| File | What It Is |
|---|---|
| `VISION.md` | Project goals, personas, constraints |
| `CLAUDE.md` | AI rules — tech stack, conventions, session learnings |
| `design-system.css` | Design tokens (colors, spacing, typography) |
| `docs/tdr-001-tech-stack.md` | Architecture decision record |
| `docs/roadmap.md` | Feature priority list |
| `.vibeos/state.json` | Current project state |
| `.vibeos/backlog.json` | Feature backlog with specs |
| `.vibeos/scores/*.json` | Vibe Score history |
| `.vibeos/sessions/*.json` | Session logs |

## Closing Thoughts

VibeOS isn't just a set of tools — it's a development philosophy. It embodies the idea that AI-assisted development should be structured, efficient, and continuously improving.

The three core principles:

1. **Attention is your most valuable resource.** The Interrupt Protocol ensures it's never wasted on manual polling.
2. **Architecture before implementation.** The phase gate and TDR ensure every line of code serves a deliberate purpose.
3. **Every session should be better than the last.** The Performance Coach and CLAUDE.md mutation system guarantee compounding efficiency gains.

Start with `/setup`. Build your foundation with `/new-project`. Ship features with `/new-feature`. Wrap every session with `/wrap`. And watch your Vibe Scores climb.
