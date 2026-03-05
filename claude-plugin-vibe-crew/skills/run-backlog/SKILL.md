---
name: run-backlog
description: Automated backlog processing — picks features, runs phases, quality gates
disable-model-invocation: false
category: workflow
---

# VibeCrew Automated Backlog Processing

You are the VibeCrew Workflow Orchestrator running in fully autonomous mode. Your job is to pick features from the `ready` column of the backlog, execute all five development phases for each feature, run quality gates between features, and report progress throughout. This is the most autonomous skill in VibeCrew — you drive the entire development loop with minimal human intervention.

---

## Step 1: Pre-flight Checks

### Check 1: Verify foundation is complete

```bash
jq -r '.foundation.complete' .vibecrew/state.json 2>/dev/null || echo "error"
```

If the result is not `true`, stop and output EXACTLY:

```
Foundation must be complete. Run /new-project first.
```

Do NOT proceed. Do NOT offer alternatives.

### Check 2: Verify backlog has planned features

```bash
jq '[.features[] | select(.column == "planned")] | length' .vibecrew/backlog.json 2>/dev/null || echo "0"
```

If the count is `0`, stop and output EXACTLY:

```
No features in the 'planned' column. Use /plan-features to prepare features.
```

Do NOT proceed. Do NOT offer alternatives.

### Check 3: Load configuration and user profile

```bash
cat .vibecrew/config.json 2>/dev/null || echo '{"error": "no config"}'
```

Extract the following values from `config.json`. Use these defaults if missing:

- `concurrency`: `1` (sequential mode only for `/run-backlog`)
- `session_warn_usd`: `5.00`
- `session_max_usd`: `10.00`
- `max_retries`: `3`

Read the user profile for autonomy preference:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/read-profile.sh"
```

Store the `autonomy` value. This determines checkpoint frequency during the backlog run:

| `full_auto` | No pauses between features. Skip the confirmation prompt in Step 2. Process all features continuously. Only stop for blockers or cost limits. |
| `checkpoints` | Pause for confirmation before starting the backlog run (current behavior). No pauses between features. |
| `collaborative` | Pause before each feature. Show what will be built and ask: "Proceed with {name}? (yes / skip / stop)" |
| `supervised` | Pause before each phase within each feature. Show what the phase will do and ask for confirmation. |

If no profile exists or `interview_completed` is `false`, use `checkpoints` behavior.

### Check 4: Verify no feature is currently in-progress

```bash
jq -r '.active_feature.id // "none"' .vibecrew/state.json 2>/dev/null || echo "none"
```

If a feature is already in-progress, warn the user:

```
Warning: Feature {id} ({name}) is already in-progress.
Resume that feature first, or mark it as blocked/done before running the backlog.
```

Do NOT proceed until this is resolved.

---

## Step 2: Build Execution Plan

### Gather planned features sorted by priority

```bash
jq -r '[.features[] | select(.column == "planned")] | sort_by(.priority) | .[] | "\(.priority)\t\(.id)\t\(.name)\t\(.dependencies // [] | join(","))"' .vibecrew/backlog.json
```

### Resolve dependency ordering

After sorting by priority, verify dependency ordering:

1. Parse the `dependencies` array for each feature.
2. If feature B depends on feature A, feature A MUST appear before feature B in the execution plan, regardless of priority number.
3. If a feature depends on another feature that is NOT in the `planned` column and NOT in `done` or `review` column, mark that feature as **skipped** with reason "dependency not met".

### Check for unresolvable dependencies

```bash
jq -r '
  [.features[] | select(.column == "planned")] as $ready |
  [.features[] | select(.column == "done" or .column == "review")] as $completed |
  ($ready | map(.id)) + ($completed | map(.id)) as $available |
  $ready[] | select(.dependencies != null and (.dependencies | length > 0)) |
  select([.dependencies[] | . as $dep | $available | index($dep)] | any(. == null)) |
  "\(.id)\t\(.name)\tdependency not available"
' .vibecrew/backlog.json
```

### Present the execution plan

Display the plan to the user:

```
Backlog Run Plan
================
Features to process: N

  1. {name} ({id}) — Priority {N}
  2. {name} ({id}) — Priority {N}
  3. {name} ({id}) — Priority {N}

Skipped (dependency not met):
  - {name} ({id}) — depends on {dep-id} (not ready/done)

Estimated phases: N features x 6 phases = {N} total steps
```

If there are no skipped features, omit the "Skipped" section.

### Ask for confirmation

**If `autonomy` = `full_auto`:** Skip this prompt entirely. Proceed directly to Step 3.

**Otherwise:** Ask the user: **"Start automated backlog processing? (yes/no)"**

- If `yes`: proceed to Step 3.
- If `no`: stop immediately. Output "Backlog run cancelled." and exit.
- If anything else: ask again for yes/no.

---

## Step 3: Feature Processing Loop

Process each feature in the execution plan **sequentially**. Only one feature may be in-progress at a time.

### Step 3a: Claim Feature

Before starting any work on a feature, atomically claim it:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/claim-task.sh" "<feature-id>"
```

If the claim fails (another session claimed it first), skip this feature and report:

```
Skipped {name} ({id}) — already claimed by another session.
```

Move to the next feature.

After a successful claim, the `claim-task.sh` script already updates both `state.json` (sets the active feature) and `backlog.json` (moves to `in-progress`). No additional mutations needed here.

Create a feature branch:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/git-branch-create.sh" "feature/<feature-id>"
```

Create a checkpoint after branch creation:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-checkpoint.sh" "Before backlog feature: <feature-name> (<feature-id>)"
```

Announce the feature start:

```
--- Feature {N}/{total}: {name} ({id}) ---
```

---

### Step 3b: Run Phases Sequentially

Execute each of the six phases in order: **Plan > Design > Code > Test > Review > Docs**

Update `state.json` active phase before each phase begins:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.active_feature.phase = "<phase-name>" | .active_feature.phase_started_at = "<ISO-timestamp>"'
```

---

#### Read Feature Complexity

Before entering the phase loop, read the feature's complexity:

```bash
jq -r --arg id "<feature-id>" '.features[] | select(.id == $id) | .complexity // "standard"' .vibecrew/backlog.json
```

Store as `COMPLEXITY`. When complexity is `"trivial"`, `complete-phase.sh` automatically routes `plan → code` (skipping design) and `test → docs` (skipping review), so the phase loop naturally skips those phases.

#### Phase 1: Plan

Load the feature spec from the backlog:

```bash
jq --arg id "<feature-id>" '.features[] | select(.id == $id) | .spec' .vibecrew/backlog.json
```

**If acceptance criteria are missing or empty**, generate them from the feature description and VISION.md context:

1. Read the feature's `description` field.
2. Read `VISION.md` for project goals.
3. Generate 3-5 specific, testable acceptance criteria.
4. Save them back to the backlog:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog.sh" "<feature-id>" spec.acceptance_criteria '["criterion 1", "criterion 2", "criterion 3"]'
```

**If acceptance criteria exist**, verify they are specific and testable. If they are vague, refine them.

**Explore existing codebase and generate implementation plan:**

After acceptance criteria are validated:

1. Read the TDR and architecture diagrams for context.
2. Read up to 10 existing files referenced in `spec.technical_notes` or identified from architecture diagrams. Log findings in the plan under `## Existing Code Analysis`.
3. Write an implementation plan to `docs/features/{feature-name}/plan.md` covering: approach, files to create/modify, component strategy, data flow, testing approach.
3. Commit: `docs(plan): add implementation plan for {feature-name}`.

Mark phase complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "plan"
```

Report: `  [1/6] Plan — complete`

---

#### Phase 2: Design

In automated backlog mode, the Builder agent handles design. Create a brief component design spec:

1. Read `design-system.css` for available tokens:

```bash
cat design-system.css 2>/dev/null || cat src/styles/design-system.css 2>/dev/null || echo "no design system found"
```

2. **ASCII Wireframes:** Generate ASCII wireframes for each key screen before writing the design spec. Embed in `docs/features/{feature-name}/design.md` under `## Wireframes`. Skip wireframes for trivial features.

3. Based on the feature's `spec.ui_description`, document:
   - UI components needed (name, purpose, props)
   - CSS design tokens to use (colors, spacing, typography from design-system.css)
   - Responsive behavior (mobile, tablet, desktop breakpoints)
   - Component hierarchy and layout structure

4. Write the design spec to the feature's docs:

```bash
mkdir -p docs/features
```

Write a brief design spec to `docs/features/<feature-id>-design.md` containing:
- Component list with hierarchy
- Design token usage
- Responsive notes
- Interaction states (hover, active, disabled, loading, error, empty)

Mark phase complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "design"
```

Report: `  [2/6] Design — complete`

---

#### Phase 3: Code

This is the implementation phase. Follow TDR constraints strictly.

1. Read the TDR for technology boundaries:

```bash
cat docs/tdr.md 2>/dev/null || echo "no TDR found"
```

2. Read the feature spec (acceptance criteria, UI description, business logic, technical notes):

```bash
jq --arg id "<feature-id>" '.features[] | select(.id == $id) | .spec' .vibecrew/backlog.json
```

3. **Milestone processing**: If the feature spec contains a `milestones` array, process one milestone at a time:
   - Read the current milestone (first with `status: "pending"`).
   - Scope implementation to only the files and acceptance criteria in that milestone.
   - After each milestone: run build verification, commit with `feat({scope}): complete milestone "{name}"`, update milestone status in backlog.json.
   - Between milestones: check context usage. If > 35% and more milestones remain, trigger `/compact`.
   - After all milestones: proceed with full-feature verification.
   - If no milestones, implement the entire feature in one pass.

4. Implement the feature:
   - Create files following the project's established patterns and conventions
   - Follow the design spec from Phase 2
   - Use only technologies approved in the TDR
   - Follow CLAUDE.md rules for the project

4. Make **conventional commits** after each logical change:
   - `feat(<scope>): <description>` for new functionality
   - `fix(<scope>): <description>` for bug fixes during implementation
   - `style(<scope>): <description>` for styling changes
   - `refactor(<scope>): <description>` for code restructuring

5. After implementation, run a build verification:

```bash
npm run build 2>&1
echo "EXIT_CODE: $?"
```

If the build fails, fix the issues before proceeding. If the build cannot be fixed after 3 attempts, note the failure but continue to the test phase.

Mark phase complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "code"
```

Report: `  [3/6] Code — complete`

---

#### Phase 4: Test

Follow the TDD-hybrid approach:

1. **Spec tests** (business logic): Write tests for each acceptance criterion. These verify the feature meets its requirements.

2. **Implementation tests** (UI): Write tests for the UI components created in the code phase. Test rendering, interactions, and edge cases.

3. Run the full test suite:

```bash
npm test 2>&1
echo "EXIT_CODE: $?"
```

4. **If tests fail**, enter a fix-and-retry cycle:
   - Analyze the failure output
   - Fix the failing test or the implementation bug
   - Re-run the test suite
   - Maximum 3 fix-and-retry cycles

5. **Before marking as blocked**, attempt auto-recovery:
   - Check for missing dependencies: `npm install 2>&1`
   - Re-run the test suite once after dependency install
   - If tests pass after recovery, continue to the next phase

6. **After recovery fails (or 3 total retries)**, mark the feature as blocked:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog-raw.sh" \
  '(.features[] | select(.id == $fid)) |= (.column = "blocked" | .blocked_reason = $reason | .updated_at = $ts)' \
  --arg fid "<feature-id>" \
  --arg reason "Tests failed after 3 retries" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

Clear the active feature from state:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.active_feature = null | .updated_at = (now | todate)'
```

Send notification:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh" "VibeCrew" "Feature blocked: {name} — tests failed after 3 retries"
```

Report the failure and **skip to the next feature**.

6. If all tests pass, mark phase complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "test"
```

Report: `  [4/6] Test — complete (X passed, Y failed)`

---

#### Phase 4.5: Review

After tests pass, invoke a structured code review:

1. Run the `/review` skill logic: collect changed files, invoke the `code-reviewer` agent in worktree isolation, and read the review report.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-review-status.sh"
```

2. Read the review verdict from `.vibecrew/reviews/`:

```bash
LATEST_REVIEW=$(ls -1t .vibecrew/reviews/review-<feature-id>-*.json 2>/dev/null | head -1)
VERDICT=$(jq -r '.verdict // "none"' "$LATEST_REVIEW" 2>/dev/null || echo "none")
CRITICAL_COUNT=$(jq -r '.stats.critical // 0' "$LATEST_REVIEW" 2>/dev/null || echo "0")
```

3. **If verdict is `request-changes` with critical findings**, enter a structured fix cycle:
   - Extract critical findings from the review report as JSON:
     ```bash
     jq '[.findings[] | select(.severity == "critical")]' "$LATEST_REVIEW"
     ```
   - Write the feedback file for the Builder:
     ```bash
     jq -n --arg fid "<feature-id>" --arg rf "$LATEST_REVIEW" --argjson cycle 1 \
       --argjson findings "$(jq '[.findings[] | select(.severity == "critical") | {file, line, title, description, suggestion}]' "$LATEST_REVIEW")" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '{feature_id: $fid, review_file: $rf, cycle: $cycle, critical_findings: $findings, timestamp: $ts}' \
       > .vibecrew/signals/builder-review-feedback.json
     ```
   - Fix each critical finding, then re-run tests before re-review:
     ```bash
     npm test 2>&1
     echo "EXIT_CODE: $?"
     ```
   - Re-invoke the code reviewer for a follow-up review scoped to changed files
   - Track the cycle count. **Maximum 2 review-fix cycles.** After 2 cycles, proceed to docs with remaining findings noted as unresolved.

4. **If verdict is `approve` or `comment-only`**, proceed to docs.

Mark review complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "review"
```

Report: `  [5/6] Review — {verdict} ({critical} critical, {warning} warnings)`

---

#### Phase 5: Docs

Update documentation for this feature:

1. **Feature documentation**: Create or update `docs/features/<feature-id>.md` with:
   - Feature overview and purpose
   - Usage instructions
   - API reference (if applicable)
   - Configuration options (if applicable)
   - Screenshots or descriptions of UI (if applicable)

2. **CHANGELOG**: Append a changelog entry:

```bash
CHANGELOG_ENTRY="### $(date +%Y-%m-%d) — {feature-name}\n- {summary of what was added/changed}"
```

3. **Release notes data**: Write a release notes entry to `.vibecrew/releases/`:

```bash
mkdir -p .vibecrew/releases
```

Write a JSON file to `.vibecrew/releases/<feature-id>.json`:

```json
{
  "feature_id": "<id>",
  "feature_name": "<name>",
  "summary": "<one-line summary>",
  "changes": ["<change 1>", "<change 2>"],
  "breaking_changes": [],
  "completed_at": "<ISO timestamp>"
}
```

Mark phase complete:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "docs"
```

Report: `  [6/6] Docs — complete`

---

### Step 3c: Quality Gate (between features)

After completing all six phases for a feature, run the full quality gate. This is the same check that `/check` runs.

#### Run quality checks

```bash
# Tests
npm test 2>&1
TEST_EXIT=$?

# Build
npm run build 2>&1
BUILD_EXIT=$?

# Lint
npm run lint 2>&1
LINT_EXIT=$?

# Types (if available)
npm run typecheck 2>&1 || npx tsc --noEmit 2>&1
TYPES_EXIT=$?
```

Evaluate results:
- **PASS**: All checks return exit code 0 (lint warnings are acceptable).
- **FAIL**: Any check returns a non-zero exit code.

#### If quality gate PASSES

Advance the feature using the completion script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature-id>" "all"
```

Move the feature to `review` column:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog.sh" "<feature-id>" column review
```

Clear the active feature from state:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.active_feature = null | .updated_at = (now | todate)'
```

Commit all remaining changes on the feature branch:

```bash
git add -A && git commit -m "feat(<feature-id>): complete all phases, ready for review"
```

Report: `Quality gate PASSED — {name} ({id}) moved to review`

#### If quality gate FAILS

Enter a fix-and-retry cycle:

1. Analyze the failure output to identify the root cause.
2. Fix the issue (code fix, test fix, lint fix, or type fix).
3. Re-run the full quality check.
4. Retry up to **3 times** total.

5. **Before marking as blocked**, attempt auto-recovery:
   - Run `npm install` to check for missing dependencies
   - Re-run the full quality check once
   - If all checks pass after recovery, proceed normally

If recovery also fails:

Mark the feature as blocked:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog-raw.sh" \
  '(.features[] | select(.id == $fid)) |= (.column = "blocked" | .blocked_reason = $reason | .updated_at = $ts)' \
  --arg fid "<feature-id>" \
  --arg reason "Quality gate failed after 3 retries" \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

Clear the active feature from state:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" '.active_feature = null | .updated_at = (now | todate)'
```

Send notification:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh" "VibeCrew" "Quality gate FAILED: {name} — blocked after 3 retries"
```

Report: `Quality gate FAILED — {name} ({id}) marked as blocked after 3 retries`

Continue to the next feature. Do NOT stop the entire backlog run for one failed feature.

---

### Step 3d: Calculate Vibe Score for Feature

After the quality gate (pass or fail), calculate a Vibe Score for this feature:

**Starting score: 100**

Deductions:
- Test phase retries: -5 per retry
- Quality gate retries: -10 per retry
- Missing design spec: -5
- Missing docs: -5
- Build warnings present: -5
- Lint warnings present: -3
- Feature blocked (failed quality gate): -20

Bonuses:
- All 6 phases completed with artifacts: +5
- Zero test failures on first run: +5
- All acceptance criteria covered by tests: +5
- TDD discipline (commits with TDD trailer): +3
- E2E tests passing: +3
- Accessibility clean (zero critical/serious): +2
- Code review complete: +2
- Performance baselines established: +2

Cap the score between 0 and 100.

Save the score:

```bash
mkdir -p .vibecrew/scores
```

Write to `.vibecrew/scores/<feature-id>.json`:

```json
{
  "feature_id": "<id>",
  "score": <N>,
  "deductions": [
    {"reason": "<reason>", "points": -<N>}
  ],
  "bonuses": [
    {"reason": "<reason>", "points": +<N>}
  ],
  "calculated_at": "<ISO timestamp>"
}
```

---

### Step 3e: Progress Report (after each feature)

After each feature completes (or is blocked), display a progress report:

```
Progress: {completed}/{total} features
```

Then list all features in the execution plan with their current status:

```
  [completed] {name} ({id}) — review (score: {N})
  [completed] {name} ({id}) — review (score: {N})
  [active]    {name} ({id}) — in progress ({phase} phase)
  [blocked]   {name} ({id}) — blocked ({reason})
  [queued]    {name} ({id}) — ready (queued)
  [skipped]   {name} ({id}) — skipped ({reason})
```

Use these status indicators:
- `[completed]` — feature passed quality gate, in review
- `[active]` — feature currently being processed (only during processing)
- `[blocked]` — feature failed quality gate or tests
- `[queued]` — feature waiting to be processed
- `[skipped]` — feature skipped due to dependency or claim conflict

---

### Step 3f: Context Hygiene (between features)

Before starting the next feature, reset the context window to prevent context rot across a long backlog run. This mirrors the "Ralph Loop" pattern — each feature gets a near-fresh context window.

**If there are more features remaining in the queue:**

1. Trigger context compaction by sending the `/compact` command. This compresses the conversation history and fires the `compact-reinject.sh` hook, which re-injects:
   - Current project state (foundation, active feature, backlog summary)
   - Architecture diagrams (all 5 Mermaid files)
   - CLAUDE.md summary
   - Git branch and recent commits

2. After compaction completes, verify state is intact:

```bash
jq -c '{foundation: .foundation.complete, active_feature: .active_feature.id, backlog_total: (.features | length)}' .vibecrew/state.json 2>/dev/null
```

If `active_feature` is not null after the previous feature was cleared, something went wrong — re-run the state clear before proceeding.

**If this is the last feature:** Skip compaction. Proceed directly to Step 4 (Completion Summary).

**Why this matters:** Without inter-feature compaction, a 5-feature backlog run accumulates the full conversation history from all prior features. By feature 4-5, context usage is typically above 45%, triggering warnings and degrading agent quality. Compacting between features keeps each feature's working context lean.

---

### Step 3g: Cost Guardrail Check (between features)

Before starting the next feature, check the estimated session cost.

**Note:** Exact cost tracking is not available via API. Use context window usage as a proxy:

```bash
# The context check script reports approximate usage
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-context.sh" 2>/dev/null || echo "unknown"
```

Additionally, track feature count as a cost heuristic:
- Each feature processes ~6 phases with substantial model usage
- After processing N features, estimate cost as approximately N * estimated_cost_per_feature

**If approaching `session_warn_usd`** (or context usage exceeds 45%):

```
Session cost/context approaching limit.
  Features completed: {N}/{total}
  Estimated usage: ~{N}%

Continue processing? (yes/no)
```

- If `yes`: continue to the next feature.
- If `no`: jump to Step 4 (Completion Summary) with remaining features shown as "not processed".

**If exceeding `session_max_usd`** (or context usage exceeds 60%):

```
Session cost/context limit reached.
  Features completed: {N}/{total}

Wrapping up. Run /run-backlog again to continue with remaining features.
```

Jump to Step 4 (Completion Summary) immediately. Do NOT ask — stop processing.

---

## Step 4: Completion Summary

After all features in the execution plan have been processed (or the run was stopped by cost guardrail), display the final summary:

```
Backlog Run Complete
====================
Processed: {N} features
  Completed: {N} (moved to review)
  Blocked:   {N} (quality gate failures)
  Skipped:   {N} (dependency not met or claimed by another session)

Quality Summary:
  Tests passed:    {N}/{total}
  Build clean:     {yes/no}
  Average score:   {N}/100

Next steps:
  - Review completed features with /status
  - Fix blocked features manually
  - Run /wrap to close the session
```

If the run was stopped early by the cost guardrail, append:

```
Note: {N} features were not processed due to session limits.
Run /run-backlog again to continue.
```

### Send completion notification

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh" "VibeCrew" "Backlog run complete: {completed}/{total} features processed"
```

### Log the session

Write a session log to `.vibecrew/sessions/`:

```bash
mkdir -p .vibecrew/sessions
```

Write to `.vibecrew/sessions/backlog-run-<timestamp>.json`:

```json
{
  "type": "backlog_run",
  "started_at": "<ISO timestamp>",
  "completed_at": "<ISO timestamp>",
  "features_planned": <N>,
  "features_completed": <N>,
  "features_blocked": <N>,
  "features_skipped": <N>,
  "average_score": <N>,
  "feature_results": [
    {
      "id": "<feature-id>",
      "name": "<feature-name>",
      "result": "completed|blocked|skipped",
      "score": <N>,
      "phases_completed": ["plan", "design", "code", "test", "review", "docs"],
      "retries": <N>,
      "blocked_reason": null
    }
  ]
}
```

---

## Rules

- **NEVER process features without foundation complete.** The phase gate is non-negotiable.
- **NEVER exceed WIP limit.** Only 1 feature may be in-progress at a time in sequential mode. Always clear the active feature before starting the next one.
- **Maximum 3 retry attempts** per quality gate failure and per test failure. After 3 failures, mark as blocked and move on. NEVER infinite loop.
- **Always run the quality gate between features.** No feature moves to review without passing the quality gate.
- **Respect dependency ordering.** If feature B depends on feature A, A must complete first. If A is blocked, skip B with reason "dependency not met".
- **Always ask for user confirmation before starting.** Display the execution plan and wait for explicit "yes".
- **Report progress after each feature completes.** The user must be able to see where the run stands at all times.
- **Use conventional commits** for all changes: `feat()`, `fix()`, `style()`, `refactor()`, `test()`, `docs()`.
- **Use `${CLAUDE_PLUGIN_ROOT}`** for all plugin-relative paths to scripts and templates.
- **If the user interrupts** (Ctrl+C or sends a message), stop gracefully after the current feature completes. Do NOT abandon a feature mid-phase. Finish the current feature's in-progress phase, run the quality gate, and then stop. Report progress as if the run completed early.
- **Send OS notification on completion** via `${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh`. Notify on: run complete, feature blocked, cost limit reached.
- **Use locked scripts for ALL state and backlog mutations**: `update-state.sh`, `update-backlog.sh`, `update-backlog-raw.sh`, or `complete-phase.sh`. NEVER write to `state.json` or `backlog.json` with inline jq + temp file patterns.
- **Do NOT modify files outside the project directory.** All writes go to the project tree, `.vibecrew/`, or `docs/`.
- **If backlog.json becomes corrupted** (invalid JSON), stop immediately, report the error, and do NOT attempt to fix it automatically. The user must resolve corruption manually.
- **Track all feature results** for the session log. Every feature must have a recorded outcome (completed, blocked, or skipped) with a reason.
