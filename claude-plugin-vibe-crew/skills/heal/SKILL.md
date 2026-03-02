---
name: heal
description: Auto-heal failing CI — fetch logs, diagnose, fix (max 3 attempts), verify
disable-model-invocation: false
---

# /heal

Auto-heal failing CI pipelines. Fetches the latest failed CI run logs, diagnoses the failure category, creates a safety checkpoint, invokes the CI Healer agent to apply a targeted fix, and verifies the result. Retries up to 3 times with different strategies before escalating to the user.

---

## Pre-flight Check

Verify that the environment is ready for CI healing.

### Check 1: VibeCrew Initialized

```bash
test -f ".vibecrew/state.json" && echo "exists" || echo "missing"
```

If `.vibecrew/state.json` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

Do NOT output anything else. Do NOT create the file. Do NOT offer alternatives.

### Check 2: Git Repository

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "git_ok" || echo "no_git"
```

If not inside a git repository, output:

```
Not inside a git repository. /heal requires git to create checkpoints and commits.
```

And stop.

### Check 3: Provider CLI Available

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-gh-auth.sh"
```

Parse the JSON output. If `status` is not `"ok"`, display the `message` field and stop.

Store the `provider` field from the output (`"github"` or `"gitlab"`) for use when fetching CI logs.

### Check 4: Clean Working Tree

```bash
git status --porcelain 2>/dev/null
```

If the working tree has uncommitted changes, warn the user:

```
Warning: You have uncommitted changes. /heal will create a checkpoint and may commit fixes.
Consider committing or stashing your changes first.

Proceed anyway? (yes/no)
```

If the user says `no`, stop. If `yes`, continue.

---

## Step 1: Fetch CI Logs

Retrieve the latest failed CI run logs using the fetch script.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fetch-ci-logs.sh"
```

Parse the JSON output. Check the `status` field:

- If `"no_failures"`: output the message from the response and stop:

```
No failed CI runs found. Nothing to heal.
```

- If `"fetched"`: proceed with the run details. Display a summary to the user:

```
Failed CI Run Detected
======================
Run ID:   <run_id>
Title:    <title>
Branch:   <branch>
Created:  <created_at>
Log size: <log_lines> lines (truncated to last 500)
```

- If `"error"`: output the error message and stop.

Store the full JSON output (including the `log` field) for use in subsequent steps.

---

## Step 2: Diagnose

Analyze the CI logs to categorize the failure.

Write the log content to a temporary file and run the diagnosis script:

```bash
echo "$CI_LOG" | bash "${CLAUDE_PLUGIN_ROOT}/scripts/diagnose-ci-failure.sh"
```

Parse the JSON output. Display the diagnosis to the user:

```
Diagnosis
=========
Category:   <category> (confidence: <confidence>)
Summary:    <summary>
Matches:    build=<n> test=<n> lint=<n> dep=<n> env=<n>

Key error lines:
  1. <relevant_line_1>
  2. <relevant_line_2>
  3. <relevant_line_3>
  ...
```

Show up to 10 of the most relevant error lines from the diagnosis output. Store the full diagnosis JSON for the healer agent.

---

## Step 3: Create Checkpoint

Before making any changes, create a safety checkpoint so the user can roll back if needed.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/create-checkpoint.sh" "Before CI heal: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

Capture the checkpoint tag name from the output. Display:

```
Checkpoint created: <tag_name>
You can roll back with /undo if needed.
```

Store the checkpoint tag name for the heal report.

---

## Step 4: Invoke CI Healer Agent

Launch the `ci-healer` agent with the diagnosis context. Pass the following information to the agent:

1. **Diagnosis JSON** from Step 2 (category, confidence, relevant_lines, summary)
2. **Full CI log** from Step 1 (the truncated log text)
3. **Current attempt number** (starts at 1)
4. **Previous attempt context** (empty on first attempt; on retries, includes what was tried and why it failed)

The agent will:
- Read the relevant source files identified in the error lines
- Apply a targeted fix based on the failure category
- Follow the fix strategies defined in the agent prompt

Wait for the agent to complete. The agent will report:
- What files were modified
- What fix was applied
- Whether it believes the fix addresses the root cause

---

## Step 5: Verify Fix

After the healer agent completes its fix, run the full quality check suite to verify.

Invoke the `/check` command (tests, build, lint, type checks). Parse the output for the overall result.

### If `/check` passes (Overall: PASS):

1. Stage and commit the changes with a conventional commit message:

```bash
git add -A
git commit -m "fix(ci): <description of what was fixed>"
```

The commit message should:
- Use the `fix(ci):` prefix (conventional commits)
- Briefly describe the actual fix (e.g., "fix(ci): correct import path for utils module")
- Include `Co-Authored-By: VibeCrew CI Healer <noreply@vibecrew.dev>` trailer

2. Display success:

```
CI Heal Successful
==================
Attempt:  <attempt_number> of 3
Fix:      <description>
Files:    <list of modified files>
Commit:   <commit_sha>

The fix has been committed locally but NOT pushed.
Run `git push` when you are ready to push to the remote.
```

3. Proceed to Step 7 (save report with outcome `"healed"`).

### If `/check` fails (Overall: FAIL):

Proceed to Step 6 (retry loop).

---

## Step 6: Retry Loop

If the fix did not resolve the CI failure, retry with escalating strategies. Maximum 3 attempts total.

### Attempt Tracking

Maintain a list of attempts, each containing:
- Attempt number (1, 2, or 3)
- Diagnosis at that point
- Fix description
- Files modified
- Result of `/check`
- Why it failed (the new error output)

### Retry Strategy

Each retry re-diagnoses the current state since the previous fix may have changed the error:

1. **Attempt 2**: Re-run diagnosis on the NEW `/check` output. The healer agent receives:
   - The original CI log
   - The attempt 1 diagnosis and fix description
   - The NEW error output from the failed `/check`
   - Instruction: "The previous fix did not work. Try a different approach."

2. **Attempt 3**: Re-run diagnosis again. The healer agent receives:
   - The original CI log
   - Both previous attempts (diagnoses, fixes, outcomes)
   - The latest error output
   - Instruction: "Two previous fixes failed. Try a fundamentally different approach. Consider whether the root cause was misidentified."

### Between Attempts

Before each retry:

1. Reset to the checkpoint to undo the failed fix:

```bash
git checkout -- .
git clean -fd
```

2. Re-create the checkpoint (the tag already exists, so this is just verification):

```bash
git tag -l "vibecrew-checkpoint-*" | sort -r | head -1
```

3. Display:

```
Attempt <N-1> failed. Retrying... (<N> of 3)
Previous fix: <description>
Failure: <brief error summary>
```

### After Attempt 3 Fails

If all 3 attempts fail, proceed to Step 7 (escalation).

---

## Step 7: Escalation

If all 3 fix attempts fail, reset to the checkpoint and report to the user with full context.

### Reset to Clean State

```bash
git checkout -- .
git clean -fd
```

### Display Escalation Report

```
CI Heal Failed — Escalation Required
=====================================
All 3 fix attempts were unsuccessful. Manual intervention is needed.

Attempt 1:
  Diagnosis: <category> — <summary>
  Fix tried: <description>
  Result:    FAIL — <brief error>

Attempt 2:
  Diagnosis: <category> — <summary>
  Fix tried: <description>
  Result:    FAIL — <brief error>

Attempt 3:
  Diagnosis: <category> — <summary>
  Fix tried: <description>
  Result:    FAIL — <brief error>

Remaining Error:
  <the current error output from the last /check run, truncated to 30 lines>

Manual Recovery Suggestions:
  1. Review the error output above — the root cause may span multiple files or systems.
  2. Check if the CI environment differs from local (Node version, env vars, OS).
  3. Roll back to the checkpoint: /undo → select <checkpoint_tag>
  4. Try running the failing command locally to reproduce.
  5. Check if a dependency update introduced a breaking change.

Checkpoint: <checkpoint_tag> (your code is unchanged)
```

Proceed to Step 8 (save report with outcome `"escalated"`).

---

## Step 8: Save Report

Write a CI heal report to `.vibecrew/` for historical tracking and Performance Coach analysis.

### Create Reports Directory

```bash
mkdir -p .vibecrew/ci-heals
```

### Generate Report

Use the template from `${CLAUDE_PLUGIN_ROOT}/templates/ci-heal-report.json.template` as the base structure. Fill in all fields:

- `schema_version`: `"1.3.0"`
- `run_id`: The CI run ID from Step 1
- `branch`: The branch from Step 1
- `started_at`: ISO timestamp from when `/heal` started
- `completed_at`: ISO timestamp when the process finished
- `checkpoint_tag`: The tag name from Step 3
- `attempts`: Array of attempt objects, each with:
  - `attempt`: Attempt number (1, 2, or 3)
  - `diagnosis`: The full diagnosis JSON from that attempt
  - `fix_description`: What the healer agent tried
  - `files_modified`: List of files that were changed
  - `ci_result`: `"pass"` or `"fail"`
  - `commit_sha`: The commit SHA if the fix was committed (null if failed)
- `outcome`: One of `"healed"`, `"escalated"`, or `"no_failures"`
- `final_diagnosis`: The last diagnosis object (for escalated cases)
- `escalation_notes`: The manual recovery suggestions (for escalated cases, null otherwise)

### Write the Report

```bash
HEAL_TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
```

Write the JSON report to `.vibecrew/ci-heals/heal-${HEAL_TIMESTAMP}.json` using the temp-file-then-mv pattern:

```bash
cat > ".vibecrew/ci-heals/heal-${HEAL_TIMESTAMP}.json.tmp" << 'REPORT_EOF'
{ ... report JSON ... }
REPORT_EOF
mv ".vibecrew/ci-heals/heal-${HEAL_TIMESTAMP}.json.tmp" ".vibecrew/ci-heals/heal-${HEAL_TIMESTAMP}.json"
```

### Display Report Location

```
Report saved: .vibecrew/ci-heals/heal-<timestamp>.json
```

---

## Rules

- **Maximum 3 attempts.** Never exceed 3 fix attempts. After 3 failures, escalate to the user immediately. Do not ask the user if they want more attempts.
- **Always create a checkpoint first.** Before any file modifications, a checkpoint MUST be created via `create-checkpoint.sh`. This is a non-negotiable safety requirement.
- **Conventional commits only.** All fix commits must use the `fix(ci): <description>` prefix following the conventional commits specification.
- **Never push without user confirmation.** The `/heal` command commits fixes locally but NEVER pushes to the remote. The user must explicitly push when ready.
- **Use `${CLAUDE_PLUGIN_ROOT}`** for all references to plugin-relative paths (scripts, templates, agents).
- **Minimal fixes only.** The healer agent must apply the smallest possible change to fix the CI failure. No refactoring, no "improvements," no unrelated changes.
- **Preserve user code intent.** If a test fails because of a legitimate code change, fix the test to match the new behavior — do not revert the code change.
- **Never disable tests or linting rules.** The fix must make the code pass the checks, not make the checks ignore the code.
- **Never modify CI configuration secrets.** Environment variables, API keys, and CI secrets are off-limits.
- **Clean up on failure.** If a fix attempt fails, reset the working tree to the checkpoint state before the next attempt.
- **Report everything.** Every attempt, diagnosis, and outcome must be recorded in the heal report for auditability.
- **Respect `/check` as the source of truth.** The verification step uses `/check` — the same quality gate used by `/wrap` and `/run-backlog`. If `/check` passes, the fix is valid.
- **Do not retry on `no_failures`.** If the initial CI log fetch returns no failed runs, stop immediately. Do not invent problems to fix.
