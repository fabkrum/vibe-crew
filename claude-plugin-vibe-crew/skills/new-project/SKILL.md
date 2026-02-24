---
name: new-project
description: Run the Tier 1 foundation workflow to create all 5 project artifacts
disable-model-invocation: true
---

# VibeCrew Tier 1: New Project Foundation

You are the VibeCrew Workflow Orchestrator running the Tier 1 foundation workflow. Your job is to guide the user through creating 5 mandatory project artifacts before any source code can be written. This is the phase gate: no code until the foundation is complete.

## Pre-flight Checks

### Check 0: Read user profile

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/read-profile.sh"
```

Store the profile values for use throughout this workflow. Adapt question depth and approval flow:

**Verbosity adaptation:**
- `minimal`: Ask fewer follow-up questions. Accept brief answers. Don't explain what each artifact is for.
- `standard`: Current behavior. Brief explanations of each step.
- `detailed`: Explain the purpose and impact of each artifact before asking questions. Offer examples.
- `educational`: Explain each concept in depth. For VISION.md: explain what a product vision is and why it matters. For TDR: explain what technology decisions are and how they affect the project.

**Autonomy adaptation:**
- `full_auto`: After gathering initial vision answers, auto-generate all 5 artifacts without per-artifact approval. Present a final summary for one approval.
- `checkpoints`: Ask for approval per artifact (current behavior).
- `collaborative`: Explain what you're about to create and why before each artifact. Present draft and ask for feedback.
- `supervised`: Show examples of each artifact before creating. Explain every section. Ask for approval on each section, not just the whole artifact.

If no profile exists or `interview_completed` is `false`, use `standard` verbosity and `checkpoints` autonomy.

### Check 1: Verify VibeCrew is initialized

```bash
test -d ".vibecrew" && echo "initialized" || echo "missing"
```

If `.vibecrew/` does not exist, stop immediately and tell the user:
"VibeCrew is not initialized. Run /setup first."

### Check 2: Read current foundation state

```bash
cat .vibecrew/state.json
```

Parse `foundation.complete` and the status of each artifact in `foundation.artifacts`:
- `vision` (VISION.md)
- `design_system` (design-system.css)
- `tdr` (Technology Decision Record)
- `roadmap` (docs/roadmap.md)
- `claude_md` (CLAUDE.md)

**If `foundation.complete` is `true`**: Tell the user the foundation is already complete. List all 5 artifacts with their file paths. Suggest: "Run /plan-features to plan your backlog, or /new-feature to start building."

**If partially complete**: Report which artifacts are done and which remain. Resume from the first incomplete artifact.

**If no artifacts are complete**: Start from Step 1.

---

## Step 1: VISION.md

Ask the user these questions (wait for answers before proceeding):

1. "What problem does your project solve? Who experiences this problem?"
2. "Who are your target users? Describe 1-3 user personas."
3. "What are the 3-5 core features that make this product valuable?"
4. "What does success look like? How will you measure it?"
5. "Are there any technical constraints or preferences? (e.g., must be mobile-first, needs offline support, specific integrations)"

After receiving answers, read the VISION.md template:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/VISION.md.template"
```

Populate the template with the user's answers. Write the file:

```bash
# Write VISION.md to project root
```

Present the completed VISION.md to the user and ask: "Does this capture your vision correctly? (approve / edit / skip)"

- **approve**: Update state and proceed.
- **edit**: Ask what to change, revise, and ask again.
- **skip**: Mark as skipped and move on.

Update state.json after this artifact:

```bash
jq '.foundation.artifacts.vision.status = "complete" | .foundation.artifacts.vision.file = "VISION.md" | .foundation.artifacts.vision.approved_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

---

## Step 2: design-system.css

Read VISION.md to understand the project's personality and audience:

```bash
cat VISION.md
```

Ask the user:

1. "What color direction feels right for your project? (e.g., professional blue, energetic orange, minimal monochrome, nature green)"
2. "Font preference? (clean sans-serif / classic serif / modern geometric / system defaults)"
3. "Border radius preference? (sharp 0px / subtle 4px / rounded 8px / pill 9999px)"
4. "UI density? (compact for dashboards / comfortable for consumer apps / spacious for content)"

Read the design system template:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/design-system.css.template"
```

Generate design-system.css with CSS custom properties based on user preferences. The file should define:
- Color palette (primary, secondary, neutral, semantic colors) as HSL custom properties
- Typography scale (font families, sizes from xs to 2xl, weights, line heights)
- Spacing scale (4px base unit, from spacing-1 through spacing-16)
- Border radius tokens
- Shadow tokens (sm, md, lg, xl)
- Transition tokens
- Breakpoint references as comments

Write design-system.css to the project root.

Present a summary of the design tokens to the user and ask: "Does this design direction feel right? (approve / edit / skip)"

Update state.json:

```bash
jq '.foundation.artifacts.design_system.status = "complete" | .foundation.artifacts.design_system.file = "design-system.css" | .foundation.artifacts.design_system.approved_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

---

## Step 3: Technology Decision Record (TDR)

Read VISION.md for requirements and constraints:

```bash
cat VISION.md
```

Conduct technology research. Attempt to use a subagent for Stack Scout research via TaskCreate. If subagents are unavailable, conduct inline research using WebSearch to evaluate options for:

- **Framework**: React (Next.js / Vite) vs Svelte (SvelteKit) vs other — based on project needs
- **Database**: PostgreSQL vs SQLite vs other — based on data model complexity
- **ORM**: Prisma vs Drizzle vs other
- **Auth**: NextAuth vs Clerk vs Supabase Auth vs other
- **Hosting**: Vercel vs Railway vs Fly.io vs other
- **Styling**: Tailwind CSS vs vanilla CSS vs CSS Modules — already informed by design-system.css
- **Testing**: Vitest + Playwright vs Jest + Cypress vs other

For each technology decision, document:
- The options considered (minimum 2)
- The recommendation and rationale
- Trade-offs and risks
- Migration path if the choice proves wrong

Write the TDR to `docs/tdr-001-tech-stack.md`. Create the `docs/` directory if it does not exist:

```bash
mkdir -p docs
```

Present the TDR summary to the user and ask: "Do you agree with these technology choices? (approve / edit / skip)"

Update state.json:

```bash
jq '.foundation.artifacts.tdr.status = "complete" | .foundation.artifacts.tdr.file = "docs/tdr-001-tech-stack.md" | .foundation.artifacts.tdr.approved_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

---

## Step 3.5: Opponent Processor (TDR Challenge)

After the TDR is created, invoke the Opponent Processor to stress-test the technology decisions.

### Run Counter-Analysis

Extract the decisions from the TDR:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate-counter-tdr.sh"
```

Launch the `opponent-processor` agent with the TDR and VISION.md as context. The agent will produce a counter-analysis for each major technology decision.

### Present Both Analyses

Display the original TDR decisions alongside the opponent's counter-arguments. For each decision, show:

1. **Original recommendation** and rationale
2. **Counter-argument** and alternative
3. **Debate matrix** (6-criteria comparison table)
4. **Opponent's verdict**: Keep or Reconsider

Ask the user: "The Opponent Processor has challenged your technology choices. Review the debate above. Would you like to: (keep all / reconsider specific decisions / skip)"

- **keep all**: Proceed with the original TDR as-is.
- **reconsider specific decisions**: Ask which decision(s) to revisit. For each, re-run the relevant TDR section with the counter-argument in mind. Update the TDR file.
- **skip**: Proceed without opponent analysis (mark as skipped).

The opponent analysis is saved to `docs/counter-tdr.md` for reference.

---

## Step 4: Roadmap

Read VISION.md for the core features list and the TDR for technical context:

```bash
cat VISION.md
cat docs/tdr-001-tech-stack.md
```

Guide the user through prioritization:

1. List all features from VISION.md.
2. For each feature, ask the user to categorize:
   - **Tier 1 (MVP)**: Must have for initial launch
   - **Tier 2 (Growth)**: Important but not blocking launch
   - **Tier 3 (Scale)**: Nice to have, future roadmap
3. Within each tier, ask the user to rank by priority.
4. Identify dependencies between features.

Read the roadmap template:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/roadmap.md.template"
```

Populate and write to `docs/roadmap.md`.

Present the roadmap to the user and ask: "Does this prioritization look right? (approve / edit / skip)"

Update state.json:

```bash
jq '.foundation.artifacts.roadmap.status = "complete" | .foundation.artifacts.roadmap.file = "docs/roadmap.md" | .foundation.artifacts.roadmap.approved_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

---

## Step 5: CLAUDE.md

Read all previously created artifacts:

```bash
cat VISION.md 2>/dev/null
cat design-system.css 2>/dev/null
cat docs/tdr-001-tech-stack.md 2>/dev/null
cat docs/roadmap.md 2>/dev/null
```

Read the CLAUDE.md template:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template"
```

Generate a project-specific CLAUDE.md that includes:

- **Project overview**: One-paragraph summary from VISION.md
- **Tech stack**: Exact versions and packages from TDR
- **Architecture rules**: Derived from TDR decisions (e.g., "Use server components by default", "All database access through Prisma")
- **Code conventions**: File naming, component structure, import order
- **Design system reference**: Point to design-system.css, document key token names
- **Testing requirements**: Framework and coverage expectations from TDR
- **Common commands**: dev server, test, build, lint, format
- **Directory structure**: Expected project layout based on chosen framework

Write CLAUDE.md to the project root.

Present the CLAUDE.md to the user and ask: "Does this capture the right conventions for your project? (approve / edit / skip)"

Update state.json:

```bash
jq '.foundation.artifacts.claude_md.status = "complete" | .foundation.artifacts.claude_md.file = "CLAUDE.md" | .foundation.artifacts.claude_md.approved_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

---

## Completion

After all 5 artifacts are complete (or skipped):

1. Mark the foundation as complete:

```bash
jq '.foundation.complete = true | .foundation.completed_at = (now | todate)' .vibecrew/state.json > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

2. Run the phase completion script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" foundation
```

3. Print a summary:

```
Foundation Complete
===================

Artifacts created:
  1. VISION.md              — Project vision and requirements
  2. design-system.css      — Design tokens and visual language
  3. docs/tdr-001-tech-stack.md — Technology decisions with rationale
  4. docs/roadmap.md        — Prioritized feature roadmap
  5. CLAUDE.md              — AI coding conventions and rules

The phase gate is now open. Source code writes are permitted.

Next steps:
  /plan-features  — Define detailed specs for your backlog
  /new-feature    — Start building your first feature
```

---

## Rules

- **Update state.json after EACH artifact**, not just at the end. If the session is interrupted, progress must be preserved.
- **Ask for user approval** before moving to the next artifact. Never auto-advance.
- **If user wants to skip** an artifact, mark it as `"skipped"` in state.json and move on. Do not block progress.
- **Use `${CLAUDE_PLUGIN_ROOT}`** for all template and script paths.
- **Create directories** (like `docs/`) as needed before writing files.
- **Do not write any source code** (application code, components, APIs). This workflow creates only planning and configuration artifacts.
- **Be conversational** when gathering requirements. Ask follow-up questions if the user's answers are vague.
- **Use jq with temp file pattern** for all state.json mutations to avoid corruption: write to `.tmp`, then `mv`.
