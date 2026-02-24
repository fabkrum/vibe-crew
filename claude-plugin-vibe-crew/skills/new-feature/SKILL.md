---
name: new-feature
description: Start a new feature — foundation check, branch, phase tracker, agent handoff
disable-model-invocation: false
args: feature_name
---

# /new-feature

Start a new feature development session. Checks foundation status, creates a feature branch, initializes phase tracking, and prepares the agent handoff for the five-phase development cycle.

---

## Step 1: Parse Arguments

The user invokes this command as `/new-feature "Feature Name"` or simply `/new-feature`.

- Extract the feature name from `$ARGUMENTS` (the `feature_name` arg).
- If `$ARGUMENTS` is empty or blank, ask the user:
  > What feature would you like to build?
  Wait for the response and store it as the feature name.
- Trim surrounding quotes and whitespace from the feature name.
- Store the final feature name for use in all subsequent steps.

---

## Step 2: Foundation Check

Read the project state file to verify the foundation is complete.

1. Check whether the `.vibecrew/` directory exists in the project root.
   - If it does **not** exist, stop and tell the user:
     > VibeCrew is not initialized in this project. Run `/setup` first.
   - Do NOT proceed.
2. Read `.vibecrew/state.json`.
3. Check the value of `foundation.complete`.
   - If `foundation.complete` is `false`, stop and tell the user:
     > Foundation must be complete before starting features. Run `/new-project` to finish your project foundation.
   - Do NOT proceed.
4. If `foundation.complete` is `true`, continue to Step 3.

**Rule: NEVER proceed past this step if the foundation is incomplete.**

---

## Step 3: Check WIP Limits

Enforce work-in-progress limits to maintain focus.

1. Read `.vibecrew/backlog.json`.
2. Count all features in the `features` array whose `column` value is `"in-progress"`.
3. The default WIP limit is **1**. If a custom limit is set in `.vibecrew/config.json` at `wip_limit`, use that value instead.
4. If the in-progress count is **greater than or equal to** the WIP limit:
   - Find the name of the feature currently in progress.
   - Stop and tell the user:
     > There is already a feature in progress: **{name}**. Finish it with `/wrap` or move it to done before starting a new one.
   - Do NOT proceed.
5. If under the WIP limit, continue to Step 4.

**Rule: NEVER exceed WIP limits.**

---

## Step 4: Find or Create Feature in Backlog

Search the backlog for an existing feature or create a new entry.

1. Read `.vibecrew/backlog.json` and iterate over the `features` array.
2. Search for a feature whose `name` matches the user-provided feature name using **case-insensitive partial matching**.
3. **If a match is found:**
   - Check its `column` value:
     - If `"planned"` or `"planning"`: use that feature's `id` and `spec`. Report:
       > Found existing feature: **{name}** ({id})
     - If `"in-progress"`, `"testing"`, `"review"`, or `"done"`: report and stop:
       > Feature '{name}' is already in '{column}' status.
       Do NOT proceed.
4. **If no match is found:**
   - Determine the next feature ID by finding the highest existing `feat-NNN` number and incrementing by 1. If no features exist, start at `feat-001`.
   - Create a new feature entry:
     ```json
     {
       "id": "feat-NNN",
       "name": "<feature name>",
       "column": "in-progress",
       "spec": {
         "acceptance_criteria": [],
         "ui_description": "",
         "business_logic": ""
       },
       "created_at": "<ISO 8601 timestamp>"
     }
     ```
   - Append it to the `features` array in `backlog.json`.
   - Report:
     > Created new feature: **{name}** ({id})

**Rule: Feature IDs are sequential: feat-001, feat-002, etc.**

---

## Step 5: Create Feature Branch

Create a dedicated git branch for this feature.

1. Check if git is initialized in the project root. If not:
   - Run `git init`
   - Run `git add -A && git commit -m "chore: initial commit"`
2. Sanitize the feature name for use as a branch name:
   - Convert to lowercase.
   - Replace spaces and special characters with hyphens.
   - Remove consecutive hyphens.
   - Strip leading/trailing hyphens.
   - Truncate to a maximum of **50 characters**.
3. The target branch name is `feat/<sanitized-name>`.
4. Run `${CLAUDE_PLUGIN_ROOT}/scripts/git-branch-create.sh` with the sanitized branch name.
   - If the branch **already exists**, check it out instead of creating a new one. Report:
     > Branch `feat/{sanitized-name}` already exists. Checked out.
   - If the branch is **new**, create and check it out. Report:
     > Created and checked out branch: `feat/{sanitized-name}`

**Rule: Always create a feature branch. NEVER work on main.**
**Rule: Branch names are sanitized: lowercase, hyphens only, max 50 chars.**

---

## Step 5.5: Create Checkpoint

Create a safety checkpoint before feature development begins.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-checkpoint.sh" "Before feature: <feature-name>"
```

Report:
> Checkpoint created: `vibecrew-checkpoint-<timestamp>`. Use `/undo` to roll back if needed.

---

## Step 6: Update State

Update the backlog and project state to reflect the new active feature.

1. Run `${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog.sh` to move the feature to the `"in-progress"` column in `backlog.json` (if not already there from Step 4).
2. Update `.vibecrew/state.json` with the active feature details:
   ```json
   {
     "active_feature": {
       "id": "<feature ID>",
       "name": "<feature name>",
       "phase": "plan",
       "phases_completed": [],
       "worktree": "feat/<sanitized-name>"
     }
   }
   ```
3. Write the updated `state.json` back to disk.
4. Report:
   > State updated. Active feature set to **{name}** ({id}), starting at **plan** phase.

---

## Step 7: Load Feature Spec

Display existing acceptance criteria or prompt the user to define them.

1. Read the feature's `spec` from `backlog.json`.
2. **If the feature has acceptance criteria** (non-empty `acceptance_criteria` array):
   - Display them:
     > **Acceptance Criteria for {name}:**
     > 1. {criterion 1}
     > 2. {criterion 2}
     > ...
3. **If the spec is empty** (no acceptance criteria):
   - Prompt the user:
     > No spec found for this feature. Would you like to define acceptance criteria now? (Recommended)
   - **If yes:**
     - Guide the user through defining:
       - **3-5 acceptance criteria** (clear, testable statements of what "done" looks like)
       - **Brief UI description** (key screens, components, layout notes)
       - **Business logic notes** (rules, edge cases, data flow)
     - Save the spec to `backlog.json` via `${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog.sh`.
     - Confirm:
       > Spec saved for **{name}**.
   - **If no:**
     - Warn the user:
       > Starting without a spec will incur a **-5 Vibe Score** deduction. You can add a spec later with `/plan-features`.

---

## Step 8: Phase Tracker Display

Display the current feature phase tracker to orient the user.

```
Feature: {name} ({id})
Branch:  feat/{sanitized-name}
Phase:   plan (1/5)

Phase Tracker:
  [>] Plan      -- Define acceptance criteria and approach
  [ ] Design    -- Component design specs and CSS tokens
  [ ] Code      -- Implementation within TDR boundaries
  [ ] Test      -- TDD-hybrid testing (spec-first + impl-first)
  [ ] Review    -- Code review (optional, +2 Vibe Score bonus)
  [ ] Docs      -- Feature documentation and release notes

Next: Define the implementation approach for this feature.
```

**Note:** The Review phase is optional in manual workflows. It earns a +2 Vibe Score bonus when completed. Run `/review` after tests pass to invoke the code reviewer. In `/run-backlog`, review runs automatically.

Phase marker legend:
- `[x]` = completed phase
- `[>]` = current active phase
- `[ ]` = pending phase

If any phases were already completed (e.g., from a resumed feature), mark them with `[x]` accordingly.

---

## Step 9: Agent Handoff

Complete the initialization and hand off to the development workflow.

1. Report that the feature session is ready:
   > Feature session initialized. You can now work through each phase.

2. If the Workflow Orchestrator agent is available, note:
   > Builder and Verifier agents will be coordinated automatically as you progress through phases.

3. Suggest the next action:
   > Start with the **Plan** phase. Define your approach, then move to **Design**.

---

## Rules

- **NEVER** proceed if the foundation is incomplete.
- **NEVER** exceed WIP limits.
- **Always** create a feature branch -- never work on `main`.
- Feature IDs are sequential: `feat-001`, `feat-002`, `feat-003`, etc.
- Branch names are sanitized: lowercase, hyphens only, max 50 characters.
- If git is not initialized, run `git init` and `git add -A && git commit -m "chore: initial commit"` first.
- Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative file paths (scripts, agents, etc.).
- Keep output concise but informative -- no walls of text, but enough context for the user to understand what happened and what to do next.
