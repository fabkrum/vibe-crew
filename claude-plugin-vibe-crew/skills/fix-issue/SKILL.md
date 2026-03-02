---
name: fix-issue
description: Fix an issue (GitHub/GitLab) — fetch, diagnose, implement, test, and open a PR/MR with auto-close
disable-model-invocation: false
---

# /fix-issue

Fix an issue end-to-end. Fetches the issue details (from GitHub or GitLab, auto-detected), imports it into the backlog, creates a branch, implements the fix, runs quality checks, optionally runs code review, and opens a PR/MR with the appropriate close keyword (`Fixes #N` for GitHub, `Closes #N` for GitLab) for auto-close.

**Usage:** `/fix-issue <issue-number>` or `/fix-issue <issue-number> --full`

- **Default (hotfix):** Code → Test → Review — skips Plan/Design phases. For bugs.
- **`--full` flag:** Runs the standard 6-phase Tier 2 cycle. For enhancements/features.
- Issues labeled `enhancement`, `feature-request`, or `feature` automatically use the full cycle.

---

## Pre-flight Check

Verify the environment is ready for issue fixing.

### Check 1: VibeCrew Initialized

```bash
test -f ".vibecrew/state.json" && echo "exists" || echo "missing"
```

If `.vibecrew/state.json` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Do NOT output anything else. Do NOT create the file. Do NOT offer alternatives.

### Check 2: Foundation Complete

```bash
jq -r '.foundation.complete' .vibecrew/state.json 2>/dev/null
```

If foundation is not `true`, output:

```
Project foundation incomplete. Run /new-project first to complete Tier 1.
```

And stop.

### Check 3: Provider CLI

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-gh-auth.sh"
```

Parse the JSON output. If `status` is not `"ok"`, display the `message` field and stop.

Store the `provider` field from the JSON output (`"github"` or `"gitlab"`) for use in later steps.

### Check 4: Parse Arguments

Extract `<issue-number>` from the command arguments. If no issue number is provided, output:

```
Usage: /fix-issue <issue-number> [--full]
```

And stop.

Check for the `--full` flag in arguments.

### Check 5: Read User Profile

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/read-profile.sh"
```

Store the profile for autonomy-aware confirmations and PR formatting.

---

## Step 1: Fetch Issue

Retrieve the GitHub issue details.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fetch-github-issue.sh" <issue-number>
```

Parse the JSON output. Check the `status` field:

- If `"error"`: output the error message and stop.
- If `"fetched"`: display a summary to the user:

```
Issue #<number>
===============
Title:   <title>
Author:  <author>
Labels:  <labels, comma-separated>
URL:     <url>

<first 10 lines of body, or full body if short>
```

Store the full issue JSON for subsequent steps.

---

## Step 2: Determine Mode

Decide between hotfix and full feature cycle.

### Hotfix Mode (default)

Used when:
- The issue has no `enhancement`, `feature-request`, or `feature` label
- The `--full` flag was NOT passed

Hotfix skips Plan and Design phases. Runs: Code → Test → Review.

### Full Feature Mode

Used when:
- The `--full` flag was passed, OR
- The issue has an `enhancement`, `feature-request`, or `feature` label

Full mode runs the standard 6-phase Tier 2 cycle: Plan → Design → Code → Test → Review → Docs.

Display the selected mode:

```
Mode: <hotfix|full feature>
```

### Autonomy Check

Read the `autonomy` field from the user profile:

- `full_auto` or `checkpoints`: proceed without asking
- `collaborative` or `supervised`: ask for confirmation:

```
Proceed with <mode> for issue #<number>? (yes/no)
```

If `no`, stop.

---

## Step 3: Import to Backlog

Import the issue into the VibeCrew backlog for tracking.

```bash
echo '<issue-json>' | bash "${CLAUDE_PLUGIN_ROOT}/scripts/import-issue-to-backlog.sh" [--full]
```

Pass `--full` if full feature mode was selected.

Parse the JSON output:

- If `"imported"`: display the feature ID and continue.
- If `"duplicate"`: the issue is already in the backlog. Display:

```
Issue #<number> already exists as <feature-id>.
Resume working on this issue? (yes/no)
```

If `yes`, use the existing feature ID and continue from Step 4.
If `no`, stop.

- If `"error"`: display the error and stop.

Store the `feature_id` for subsequent steps.

---

## Step 4: Create Branch

Create a dedicated branch for the fix.

```bash
git checkout -b fix/issue-<number>
```

If the branch already exists (from a previous attempt), switch to it:

```bash
git checkout fix/issue-<number>
```

Display:

```
Branch: fix/issue-<number>
```

---

## Step 5: Create Checkpoint

Create a safety checkpoint before making changes.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-checkpoint.sh" "Before fix: issue #<number> — <title>"
```

Capture the checkpoint tag name. Display:

```
Checkpoint: <tag_name>
```

---

## Step 6: Update State

Set the active feature in state.json to track progress.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" 'active_feature' '{"id":"<feature-id>","source":"issue","issue_number":<number>}'
```

---

## Step 7: Code Phase

Implement the fix using the Builder agent.

### For Hotfix Mode

Pass the following context to the Builder agent:

1. **Issue title and body** as the problem statement
2. **Acceptance criteria** extracted from the backlog entry
3. **Instruction**: "This is a bug fix. Apply the minimal change needed to resolve the issue. No refactoring, no unrelated changes."

The Builder agent will:
- Read relevant source files to understand the problem
- Implement the targeted fix
- Follow TDR conventions and project patterns

### For Full Feature Mode

Run the standard Tier 2 phases. Start with planning (Orchestrator), then design, then code (Builder).

Wait for the Builder agent to complete. Record which files were modified.

---

## Step 8: Test Phase

Run the quality gate to verify the fix.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/run-quality-checks.sh"
```

Or invoke `/check` for full quality checks (tests, build, lint, type-check).

### If quality checks pass:

Display:

```
Quality Gate: PASS
```

Proceed to Step 9.

### If quality checks fail:

Retry up to 3 times total. On each retry:

1. Display the failure summary
2. Pass the error context back to the Builder agent with instruction: "The previous fix caused quality check failures. Fix these issues."
3. Re-run quality checks

If all 3 attempts fail, display:

```
Quality checks failed after 3 attempts. Manual intervention needed.

Errors:
  <error summary>

Your code is on branch fix/issue-<number>.
Checkpoint: <tag_name>
```

Save the report with outcome `"failed"` and stop.

---

## Step 9: Code Review (Optional)

Run code review if the user profile requests it.

Read the `pr_review` field from the user profile:

- `auto_merge`: skip review entirely
- `summary`: skip detailed review, proceed to PR
- `review` or `walkthrough`: invoke the Code Reviewer agent

```
Pass to the Code Reviewer agent:
1. The issue title and body as the feature spec
2. The list of modified files
3. Instruction: "Review this fix for issue #<number>. Check for correctness, edge cases, and TDR compliance."
```

If the reviewer finds critical issues, pass findings back to the Builder for one fix cycle (max 1 review iteration for hotfixes, max 2 for full features).

---

## Step 10: Create PR

Stage changes, commit, and open a pull request.

### Commit

Use the provider-appropriate close keyword (`Fixes` for GitHub, `Closes` for GitLab):

```bash
git add -A
git commit -m "fix: <issue-title-slug>

<close-keyword> #<number>

Co-Authored-By: VibeCrew Builder <noreply@vibecrew.dev>"
```

For full feature mode, use `feat:` prefix instead of `fix:`.

### Push

```bash
git push -u origin fix/issue-<number>
```

### Create PR/MR

**GitHub:**

```bash
gh pr create \
  --title "fix: <issue-title>" \
  --body "## Summary

Fixes #<number>

<brief description of the fix based on what the Builder agent did>

## Changes

<list of modified files with brief description of each change>

## Quality Gate

- Tests: PASS
- Build: PASS
- Lint: PASS
- Types: PASS

---
*Automated fix by VibeCrew `/fix-issue`*"
```

**GitLab:**

```bash
glab mr create \
  --title "fix: <issue-title>" \
  --description "## Summary

Closes #<number>

<brief description of the fix based on what the Builder agent did>

## Changes

<list of modified files with brief description of each change>

## Quality Gate

- Tests: PASS
- Build: PASS
- Lint: PASS
- Types: PASS

---
*Automated fix by VibeCrew `/fix-issue`*"
```

Adjust PR/MR title prefix to `feat:` for full feature mode.

Store the PR/MR URL from the output.

Display:

```
<PR|MR> Created
===============
URL:    <pr-url>
Branch: fix/issue-<number>
<close-keyword>:  #<number> (will auto-close on merge)
```

---

## Step 11: Save Report

Write a fix report for historical tracking.

### Create Reports Directory

```bash
mkdir -p .vibecrew/issue-fixes
```

### Generate Report

Use the template from `${CLAUDE_PLUGIN_ROOT}/templates/issue-fix-report.json.template` as the base. Fill in all fields:

- `issue_number`: The GitHub issue number
- `title`: The issue title
- `url`: The issue URL
- `feature_id`: The backlog feature ID
- `branch`: `fix/issue-<number>`
- `mode`: `"hotfix"` or `"feature"`
- `outcome`: `"fixed"`, `"failed"`, or `"skipped"`
- `pr_url`: The PR URL (null if no PR created)
- `pr_number`: The PR number (null if no PR created)
- `commit_sha`: The fix commit SHA
- `files_modified`: Array of modified file paths
- `quality_gate`: Object with pass/fail for tests, build, lint, typecheck
- `attempts`: Number of quality gate attempts
- `started_at`: ISO timestamp when `/fix-issue` started
- `completed_at`: ISO timestamp when the process finished

### Write the Report

```bash
FIX_TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
```

Write the JSON report to `.vibecrew/issue-fixes/fix-<number>-${FIX_TIMESTAMP}.json`.

Display:

```
Report saved: .vibecrew/issue-fixes/fix-<number>-<timestamp>.json
```

---

## Step 12: Clean Up State

Clear the active feature and update backlog status.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-state.sh" 'active_feature' 'null'
```

Update the backlog entry column:
- On success: move to `"done"`
- On failure: leave in current column

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update-backlog.sh" <feature-id> column done
```

---

## Rules

- **Use `${CLAUDE_PLUGIN_ROOT}`** for all references to plugin-relative paths (scripts, templates, agents).
- **Minimal fixes only.** For hotfix mode, apply the smallest possible change to fix the issue. No refactoring, no "improvements," no unrelated changes.
- **Always create a checkpoint first.** Before any file modifications, a checkpoint MUST be created via `create-checkpoint.sh`.
- **Never push to main/master.** Always work on the `fix/issue-<number>` branch.
- **Auto-close via PR/MR body.** The PR/MR body MUST include the provider-appropriate close keyword (`Fixes #<number>` for GitHub, `Closes #<number>` for GitLab) to auto-close the issue when merged.
- **Maximum 3 quality gate attempts.** After 3 failures, stop and report.
- **Respect user autonomy settings.** Check the profile before proceeding at decision points.
- **Deduplication.** If the issue is already in the backlog, offer to resume rather than creating a duplicate.
- **Conventional commits.** Use `fix:` for hotfixes, `feat:` for full features.
- **Never modify CI configuration secrets.** Environment variables, API keys, and CI secrets are off-limits.
- **Report everything.** Every fix attempt and outcome must be recorded in the fix report.
