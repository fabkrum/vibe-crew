---
name: new-project
description: Run the Tier 1 foundation workflow to create all 6 project artifacts
disable-model-invocation: true
---

# VibeCrew Tier 1: New Project Foundation

You are the VibeCrew Workflow Orchestrator running the Tier 1 foundation workflow. Your job is to guide the user through creating 6 mandatory project artifacts before any source code can be written. This is the phase gate: no code until the foundation is complete.

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
- `full_auto`: After gathering initial vision answers, auto-generate all 6 artifacts without per-artifact approval. Present a final summary for one approval.
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
- `architecture_diagrams` (Architecture Diagrams)
- `claude_md` (CLAUDE.md)

**If `foundation.complete` is `true`**: Tell the user the foundation is already complete. List all 6 artifacts with their file paths. Suggest: "Run /plan-features to plan your backlog, or /new-feature to start building."

**If partially complete**: Report which artifacts are done and which remain. Resume from the first incomplete artifact.

**If no artifacts are complete**: Start from Step 1.

---

## Step 1: VISION.md

Ask the user these questions (wait for answers before proceeding):

1. "What problem does your project solve? Who experiences this problem?"
2. "Who are your target users? Describe 1-3 user personas."
3. "What are the 3-5 core features that make this product valuable?"
4. "What does success look like? How will you measure it?"
5. "What is the ONE action a new user must take to experience the core value of your product? (e.g., 'create their first project', 'invite a teammate', 'see their first analytics report')"
6. "Are there any technical constraints or preferences? (e.g., must be mobile-first, needs offline support, specific integrations)"

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
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.vision.status = "complete" | .foundation.artifacts.vision.file = "VISION.md" | .foundation.artifacts.vision.approved_at = (now | todate)'
```

---

## Step 2: Design Discovery (design-system.css + design-brief.md)

Read VISION.md to understand the project's personality and audience:

```bash
cat VISION.md
```

Read the user profile for verbosity and autonomy adaptations:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/read-profile.sh"
```

**Profile adaptations for Design Discovery:**
- `minimal` verbosity: Show options only, no explanations of why each question matters.
- `educational` verbosity: Explain the UX principle behind each question before asking.
- `supervised` autonomy: Confirm the Phase 1 summary before proceeding to Phase 2.
- `full_auto` autonomy: Auto-pick Direction A (safest) from Phase 2, skip Phase 2 choice and Phase 3. Generate both files immediately.

If `full_auto` autonomy is set, skip the interactive interview. Use VISION.md to infer answers for all phases, pick Direction A, and generate both output files. Present the final summary for one approval.

---

### Pre-Design Gate: Bring Your Own Design System

Before starting the Design Discovery interview, ask:

> "Do you have an existing design system or style guide you'd like to import? (Yes / No)"

**Profile adaptations for the gate:**
- `full_auto`: Skip gate question. Auto-detect design system files in project root (`tailwind.config.*`, `tokens.json`, `globals.css`, `variables.css`, or any `.css` file with custom properties in `:root`). If found, auto-import. If not found, proceed to interview with Direction A.
- `supervised`/`collaborative`: Show gate question with explanation: "If you have a CSS file, Tailwind config, or design tokens JSON from an existing brand, VibeCrew can import it instead of running the 10-question interview. Both paths produce the same output files."
- All others: Show gate question normally.

**If the user answers "No"** (or no files auto-detected in `full_auto`): Proceed to Phase 1 below.

**If the user answers "Yes"**: Run the **Import Flow (Section 2.1)** below, then skip to Phase 3 (Component Preferences, Q7-Q10).

---

### Section 2.1 — Import Flow (BYODS)

Run this flow when the user wants to import an existing design system instead of running the Phase 1/Phase 2 interview.

#### Step A — Accept Input

Ask the user which format their design system is in:

> "What format is your design system in?
> 1. **CSS file** — a `.css` file with custom properties (e.g., `globals.css`, `variables.css`)
> 2. **Tailwind config** — `tailwind.config.js` or `tailwind.config.ts` with theme tokens
> 3. **Tokens JSON** — a JSON tokens file (W3C Design Token format or flat key-value)
> 4. **URL** — a reference website to extract tokens from (uses Chrome DevTools)
> 5. **Figma link** — a Figma file URL (requires Figma MCP)
> 6. **Brand PDF** — a brand guidelines document (AI-interpreted)
> Or provide a file path directly."

For `full_auto` autonomy: auto-detect files in the project root. Check in order: `tailwind.config.*`, `tokens.json`, `design-tokens.json`, `globals.css`, `variables.css`. Use the first match.

#### Step B — Extract Tokens

Run the appropriate extraction based on format:

- **CSS file**: Run `import-design-tokens.sh --format css --input <file-path>` (add `--shadcn` if `components.json` exists in project root).
- **Tailwind config**: Run `import-design-tokens.sh --format tailwind --input <file-path>`.
- **Tokens JSON**: Run `import-design-tokens.sh --format json --input <file-path>`.
- **URL**: First run `extract-design-system.sh <url>` to extract tokens via Chrome DevTools, then run `import-design-tokens.sh --format css --input <extracted-css>`.
- **Figma link**: Enable the Figma MCP server, use `mcp__figma__get-file` to retrieve design tokens, write them to a temp JSON file, then run `import-design-tokens.sh --format json --input <temp-file>`.
- **Brand PDF**: Read the PDF, use AI interpretation to extract colors (hex/rgb), fonts, and spacing values. Write extracted tokens to a temp CSS file, then run `import-design-tokens.sh --format css --input <temp-file>`.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/import-design-tokens.sh" --format <format> --input <file-path>
```

Parse the JSON output. Store `mapped`, `token_overrides`, `defaults_used`, `unmapped`, `confidence`, and `warnings`.

#### Step C — Review & Gap Analysis

Present an import summary table to the user:

```
Import Summary
══════════════
Source: <filename> (<format>)
Confidence: <high|medium|low>

Mapped Tokens (from your file):
  PRIMARY_HUE:       <value>
  FONT_FAMILY:       <value>
  BORDER_RADIUS:     <value>
  DENSITY_FACTOR:    <value>
  CONTENT_WIDTH_MAX: <value>
  NAV_WIDTH:         <value>

Defaults Applied: <count> of 6
  <list any that used defaults>

Unmapped Tokens: <count>
  <list first 5 unmapped tokens — these exist in source but don't map to VibeCrew placeholders>

Token Overrides: <count>
  <list any CSS custom property overrides that will be applied>
```

If there are unmapped tokens, use AI interpretation to suggest additional mappings. Present suggestions for user approval.

Ask: "Does this import look correct? (approve / edit / re-import)"

- **approve**: Proceed to Step D.
- **edit**: Let the user adjust specific mapped values.
- **re-import**: Return to Step A to try a different file or format.

#### Step D — Component Preferences

Even with an imported design system, layout and UX preferences aren't covered by style tokens. Ask the Phase 3 questions (Q7-Q10 below): navigation style, data display, interaction density, and feedback style.

Skip this step if `full_auto` autonomy is set — use sensible defaults based on the imported tokens and VISION.md.

#### Step E — Generate Output

Proceed to the **Output Generation** section below. When populating templates:

- Use the `mapped` values from the import for template placeholders (`PRIMARY_HUE`, `FONT_FAMILY`, `BORDER_RADIUS`, `DENSITY_FACTOR`, `CONTENT_WIDTH_MAX`, `NAV_WIDTH`).
- Apply `token_overrides` as additional CSS custom property values in `design-system.css`.
- For `design-brief.md`: set the direction name to "Imported from {source filename}", set the rationale to "Brand consistency — tokens imported from existing design system", and fill component preferences from Step D answers.

After generating both files, update state with the import source:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.design_system.status = "complete" | .foundation.artifacts.design_system.file = "design-system.css" | .foundation.artifacts.design_system.brief_file = "design-brief.md" | .foundation.artifacts.design_system.import_source = "<format>" | .foundation.artifacts.design_system.approved_at = (now | todate)'
```

Then skip ahead to **Step 3: Technology Decision Record**.

---

### Phase 1 — Product & Audience Context

Ask 6 questions. For every question, present the numbered options, then add: *"Or describe in your own words."* If the user provides free text, interpret it into the closest design parameters and confirm your interpretation before proceeding.

**Q1: "What are we building?"**
1. SaaS dashboard
2. Marketplace / e-commerce
3. Content platform
4. Mobile-first tool
5. Social / community
6. Creative tool
Or describe it in your own words.

**Q2: "Who uses it?"**
1. Technical professionals
2. Non-technical consumers
3. Enterprise teams
4. Creative freelancers
5. Students / learners
Or describe them in your own words.

**Q3: "What problem does it solve for them?"**
1. Saves time on repetitive tasks
2. Reduces complexity / simplifies decisions
3. Enables collaboration across teams
4. Provides insights from data
5. Replaces manual / offline processes
Or describe the problem in your own words.

**Q4: "How do they use it?"**
1. Quick daily checks
2. Deep focused sessions
3. On-the-go mobile
4. Collaborative team use
5. Passive consumption
Or describe the usage in your own words.

**Q5: "How should it feel?"**
1. Trustworthy & professional
2. Playful & energetic
3. Minimal & calm
4. Bold & premium
5. Warm & approachable
Or describe the feeling in your own words.

**Q6: "What is the primary thing users do?"**
1. Analyze data
2. Create content
3. Manage workflows
4. Browse & discover
5. Communicate
6. Transact
Or describe the action in your own words.

**Free-text interpretation:** When the user provides free text instead of picking a numbered option, interpret their answer, map it to the closest design parameters, and present your interpretation for confirmation. Example: user types "busy nurses checking patient vitals between rounds" → interpret as: saves time on repetitive tasks + quick daily checks + trustworthy & professional + analyze data, and confirm before proceeding.

After all 6 answers, present a summary:

> "We're building a **{category}** for **{audience}** that **{problem}**, designed for **{usage}** sessions. It should feel **{emotion}**, focused on **{action}**."

If autonomy is `supervised` or `collaborative`, ask the user to confirm this summary before proceeding.

---

### Phase 2 — Visual Direction

Generate 3 tailored visual directions based on the Phase 1 answers. Use the seed matrix below as creative starting points — do NOT copy them literally. Adapt and blend based on the specific combination of product category, audience, and emotional direction.

**Seed Matrix (creative starting points):**

| Product + Feel | Direction A (Safe) | Direction B (Modern) | Direction C (Signature) |
|---|---|---|---|
| Dashboard + Professional | Tableau / Datadog | Linear / Vercel | Stripe Dashboard |
| Dashboard + Minimal | Plausible Analytics | Raycast | Arc Browser |
| Marketplace + Energetic | Shopify | Gumroad | Product Hunt |
| Content + Calm | Medium | Notion | iA Writer |
| Mobile + Playful | Duolingo | Headspace | Cash App |
| Social + Energetic | Discord | Threads | BeReal |
| Creative + Bold | Figma | Framer | Runway |

For each of the 3 directions, generate:
- **Name** (2-3 words, e.g., "Linear Finance")
- **Reference** (1-2 known products for inspiration)
- **Color palette** (primary HSL, neutral temperature warm/cool/neutral, accent approach complementary/analogous/monochromatic)
- **Typography** (heading font + body font pairing)
- **Spacing/density** (compact / comfortable / spacious)
- **Border radius** (sharp / subtle / rounded / pill)
- **Shadow strategy** (flat / subtle / layered / dramatic)
- **One-line vibe** sentence

Present as a compact comparison table. Then ask:

> "Which direction speaks to you? (A / B / C) — or describe a different direction in your own words."

If the user describes their own direction, generate the full specification for their custom direction (same format as A/B/C) and confirm before proceeding.

#### tweakcn Theme Presets (optional)

After the user picks a direction (A/B/C/custom), offer matching tweakcn theme presets as optional starting points for design-system token values. Map the chosen direction's characteristics (color temperature, density, shadows) to 2 relevant presets:

> "There are some ready-made theme presets that match this direction. Want to start from one of these?
> 1. **{preset-name-1}** — {1-line description matching chosen direction}
> 2. **{preset-name-2}** — {1-line description matching chosen direction}
> 3. **Start from scratch** — I'll generate custom tokens from the direction above
> 4. **Skip** — Move on to component preferences"

If the user picks a preset, use it as the starting point for `design-system.css` token values, then customize based on the direction spec. If "Start from scratch" or "Skip", generate tokens purely from the direction spec as before.

---

### Phase 3 — Component Preferences

Ask 2-3 contextual questions filtered by Phase 1 answers. All questions include *"or describe your preference"* as a free-text option.

**Q7: Navigation style** (always asked, options vary by product category):
- Dashboards → "1. Sidebar with collapsible sections (Sidebar) 2. Top navigation bar (Navigation Menu) 3. Combined: sidebar + top bar 4. Or describe your preference"
- Content/marketplace → "1. Top navigation bar (Navigation Menu) 2. Hamburger slide-out (Sheet) 3. Bottom tab bar (mobile Tabs) 4. Or describe your preference"
- Mobile-first → "1. Bottom tab bar (Tabs) 2. Hamburger slide-out (Sheet) 3. Gesture-based navigation 4. Or describe your preference"
- Other → "1. Sidebar (Sidebar) 2. Top navigation bar (Navigation Menu) 3. Combined: sidebar + top bar 4. Or describe your preference"

**Q8: Data display** (only ask if Q6 key action involves data, workflows, or transactions):
1. Dense sortable tables with filters (Data Table)
2. Card grid with previews (Card grid)
3. Compact list with expandable details (Accordion)
4. Mixed: summary cards + detailed table below
Or describe your preference.

**Q9: Interaction density** (always asked):
1. Minimal — lots of whitespace, one action per view
2. Moderate — balanced density, grouped actions
3. Dense — information-rich, multiple actions visible (Data Table, Sidebar, Tabs)
Or describe your preference.

**Q10: Feedback style** (always asked):
1. Subtle — small toasts for confirmations, inline validation (Sonner + inline errors)
2. Conversational — confirmation dialogs for important actions (Alert Dialog + Sonner)
3. Minimal — no confirmations, undo-based (Optimistic UI + undo Sonner)
Or describe your preference.

**Internal note:** Use precise component names from `${CLAUDE_PLUGIN_ROOT}/templates/components.md` in parentheses when presenting options. Users see the plain language; agents use the component vocabulary for design specs and implementation.

---

### Output Generation

Read the templates:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/design-system.css.template"
cat "${CLAUDE_PLUGIN_ROOT}/templates/design-brief.md.template"
```

1. **Generate `design-system.css`**: Populate the template with the chosen direction's values. Map the direction to concrete CSS custom properties:
   - Color palette (primary, secondary, neutral, semantic colors) as HSL custom properties
   - Typography scale (font families, sizes from xs to 2xl, weights, line heights)
   - Spacing scale (4px base unit, from spacing-1 through spacing-16)
   - Border radius tokens
   - Shadow tokens (sm, md, lg, xl)
   - Transition tokens
   - Layout context tokens (density factor, content width, nav width from Phase 3 answers)
   - Breakpoint references as comments
   - **shadcn/ui compatibility** (default when shadcn/ui is expected): Generate all 46 shadcn CSS tokens using OKLCH color space. Include `--background`, `--foreground`, `--card`, `--popover`, `--primary`, `--secondary`, `--muted`, `--accent`, `--destructive`, `--border`, `--input`, `--ring`, `--chart-*`, and `--sidebar-*` tokens mapped from the chosen direction's palette. This ensures `npx shadcn@latest init` and component installations work without manual theming. If a tweakcn preset was selected in Phase 2, use its token values as the base and customize from there.

2. **Generate `design-brief.md`**: Populate the template with all Phase 1-3 answers, the chosen direction's rationale, design token summary, component preferences, and 3 derived design principles.

3. Write both files to the project root.

4. Present a summary showing the chosen direction name, key tokens (primary color, fonts, radius, density), and component preferences. Ask: "Does this design direction feel right? (approve / edit / skip)"

   - **approve**: Update state and proceed.
   - **edit**: Ask what to change, revise, and ask again.
   - **skip**: Mark as skipped and move on.

5. Update state.json with both file paths:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.design_system.status = "complete" | .foundation.artifacts.design_system.file = "design-system.css" | .foundation.artifacts.design_system.brief_file = "design-brief.md" | .foundation.artifacts.design_system.approved_at = (now | todate)'
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
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.tdr.status = "complete" | .foundation.artifacts.tdr.file = "docs/tdr-001-tech-stack.md" | .foundation.artifacts.tdr.approved_at = (now | todate)'
```

---

## Step 4: Architecture Diagrams

Read the previously created foundation artifacts for context:

```bash
cat VISION.md 2>/dev/null
cat docs/tdr-001-tech-stack.md 2>/dev/null
```

Generating architecture diagrams before the roadmap and Opponent Processor ensures both have access to the full architectural picture for more informed analysis.

Read the 5 architecture diagram templates:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/architecture-diagrams/system.mmd.template"
cat "${CLAUDE_PLUGIN_ROOT}/templates/architecture-diagrams/schema.mmd.template"
cat "${CLAUDE_PLUGIN_ROOT}/templates/architecture-diagrams/state-flows.mmd.template"
cat "${CLAUDE_PLUGIN_ROOT}/templates/architecture-diagrams/api-sequences.mmd.template"
cat "${CLAUDE_PLUGIN_ROOT}/templates/architecture-diagrams/component-tree.mmd.template"
```

Create the architecture directory:

```bash
mkdir -p .vibecrew/architecture
```

Generate 5 `.mmd` files to `.vibecrew/architecture/` by populating the templates:

- **system.mmd** — Replace `{{PLACEHOLDER}}` values with TDR technology choices (framework, database, auth provider, CDN, etc.)
- **schema.mmd** — Add domain entities from VISION.md personas and core features. Define relationships and cardinality.
- **state-flows.mmd** — Map primary user journeys from VISION.md personas. Include authentication states and key feature flows.
- **api-sequences.mmd** — Add primary CRUD sequences and any third-party integration flows from the TDR.
- **component-tree.mmd** — Generate a skeleton component hierarchy based on the TDR framework choice. Include layout components (App, Layout, Header, Nav, Main, Footer) with data flow direction.

Present a summary of all 5 diagrams to the user and ask: "Do these architecture diagrams capture the right structure? (approve / edit / skip)"

- **approve**: Update state and proceed.
- **edit**: Ask which diagram(s) to change, revise, and ask again.
- **skip**: Mark as skipped and move on.

Update state.json:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.architecture_diagrams.status = "complete" | .foundation.artifacts.architecture_diagrams.file = ".vibecrew/architecture/" | .foundation.artifacts.architecture_diagrams.approved_at = (now | todate)'
```

---

## Step 4.5: Opponent Processor (TDR Challenge)

After the TDR and architecture diagrams are created, invoke the Opponent Processor to stress-test the technology decisions. The Opponent Processor now has access to the architecture diagrams for more informed counter-analysis.

### Run Counter-Analysis

Extract the decisions from the TDR:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate-counter-tdr.sh"
```

Launch the `opponent-processor` agent with the TDR, VISION.md, and architecture diagrams as context. The agent will produce a counter-analysis for each major technology decision.

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

## Step 5: Roadmap

Read VISION.md for the core features list, the TDR for technical context, and the architecture diagrams for structural awareness:

```bash
cat VISION.md
cat docs/tdr-001-tech-stack.md
ls .vibecrew/architecture/*.mmd 2>/dev/null
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
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.roadmap.status = "complete" | .foundation.artifacts.roadmap.file = "docs/roadmap.md" | .foundation.artifacts.roadmap.approved_at = (now | todate)'
```

---

## Step 6: CLAUDE.md

Read all previously created artifacts:

```bash
cat VISION.md 2>/dev/null
cat design-system.css 2>/dev/null
cat docs/tdr-001-tech-stack.md 2>/dev/null
cat docs/roadmap.md 2>/dev/null
ls .vibecrew/architecture/*.mmd 2>/dev/null
```

Read the CLAUDE.md template:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.md.template"
```

Generate a project-specific CLAUDE.md that includes:

- **Project overview**: One-paragraph summary from VISION.md
- **Tech stack**: Exact versions and packages from TDR
- **Architecture rules**: Derived from TDR decisions (e.g., "Use server components by default", "All database access through Prisma")
- **Architecture diagrams**: Reference `.vibecrew/architecture/` and list the 5 `.mmd` files (system.mmd, schema.mmd, state-flows.mmd, api-sequences.mmd, component-tree.mmd) with brief descriptions
- **Code conventions**: File naming, component structure, import order
- **Design system reference**: Point to design-system.css, document key token names
- **Testing requirements**: Framework and coverage expectations from TDR
- **Common commands**: dev server, test, build, lint, format
- **Directory structure**: Expected project layout based on chosen framework

Write CLAUDE.md to the project root.

Present the CLAUDE.md to the user and ask: "Does this capture the right conventions for your project? (approve / edit / skip)"

Update state.json:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.foundation.artifacts.claude_md.status = "complete" | .foundation.artifacts.claude_md.file = "CLAUDE.md" | .foundation.artifacts.claude_md.approved_at = (now | todate)'
```

---

## Completion

After all 6 artifacts are complete (or skipped):

1. Mark the foundation as complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" foundation
```

2. Launch the dashboard (opens browser on first project creation):

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/ensure-dashboard.sh" --open
```

3. Print a summary:

```
Foundation Complete
===================

Artifacts created:
  1. VISION.md              — Project vision and requirements
  2. design-system.css      — Design tokens and visual language
  3. docs/tdr-001-tech-stack.md — Technology decisions with rationale
  4. .vibecrew/architecture/ — Mermaid architecture diagrams (5 files)
  5. docs/roadmap.md        — Prioritized feature roadmap
  6. CLAUDE.md              — AI coding conventions and rules

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
- **Use locked scripts for ALL state.json mutations**: `update-state.sh` or `complete-phase.sh`. NEVER write to `state.json` with inline jq + temp file patterns.
