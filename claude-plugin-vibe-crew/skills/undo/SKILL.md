---
name: undo
description: Checkpoint rollback — list checkpoints, pick target, revert or reset
disable-model-invocation: false
---

# /undo

Roll back to a previous VibeCrew checkpoint or git commit. Lists available checkpoints, lets the user pick a target, detects the safest rollback mode, confirms the action, and executes the rollback.

---

## Step 1: List Checkpoints

Show available VibeCrew checkpoints and recent git commits.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/list-checkpoints.sh"
```

Parse the JSON output. It contains two sections:

1. **VibeCrew Checkpoints** — tagged commits created by VibeCrew before feature work.
2. **Recent Commits** — the 10 most recent commits (whether tagged or not).

Display both sections to the user in a numbered list:

```
Available Checkpoints:
  1. vibecrew-checkpoint-2026-02-23T12-00-00Z — abc1234 — "Before feature: auth" (2026-02-23)
  2. vibecrew-checkpoint-2026-02-22T15-30-00Z — def5678 — "Before feature: dashboard" (2026-02-22)

Recent Commits:
  3. abc1234 — feat(auth): add login form (2026-02-23)
  4. def5678 — feat(dashboard): initial layout (2026-02-22)
  5. ghi9012 — chore: initial commit (2026-02-21)
  ...
```

If no checkpoints or commits are found, tell the user:

> No checkpoints or commits found. Nothing to undo.

Do NOT proceed.

---

## Step 2: Select Target

Ask the user to pick a checkpoint or commit to roll back to:

> Enter the number of the checkpoint or commit to roll back to:

Wait for the user's response. Validate:

- The number must correspond to an entry in the list from Step 1.
- If the input is invalid, ask again.

Store the selected target's **commit hash** for subsequent steps.

---

## Step 3: Detect Mode

Determine whether the target commit has been pushed to the remote.

```bash
git log --oneline origin/$(git rev-parse --abbrev-ref HEAD)..HEAD 2>/dev/null
```

Parse the output:

- If the target commit hash appears in the list of unpushed commits (i.e., it has NOT been pushed), the safe mode is **reset** (`git reset --soft`).
- If the target commit hash does NOT appear in the unpushed list (i.e., it HAS been pushed to the remote), the safe mode is **revert** (`git revert`).
- If the remote branch does not exist (the `git log` command fails), default to **reset** mode since nothing has been pushed.

Store the detected mode (`"revert"` or `"reset"`) for the next steps.

---

## Step 4: Confirm

Show the user exactly what will happen before executing.

### If mode is "reset":

Determine which commits will be undone (between HEAD and the target):

```bash
git log --oneline <target-hash>..HEAD
```

Display:

```
Rollback Plan (reset --soft):
  The following commits will be undone (changes kept staged):

    abc1234 feat(auth): add login form
    def5678 feat(auth): add validation

  Target: <target-hash> — <target subject>

  Your working tree will be preserved. No data will be lost.
```

### If mode is "revert":

Display:

```
Rollback Plan (revert):
  A new commit will be created that reverses changes back to:

    Target: <target-hash> — <target subject>

  Commits to be reverted:
    abc1234 feat(auth): add login form
    def5678 feat(auth): add validation

  Your working tree will be preserved. No data will be lost.
  This is safe for shared branches since it does not rewrite history.
```

Then ask:

> Proceed with rollback? (yes/no)

- If `yes`: proceed to Step 5.
- If `no`: output "Rollback cancelled." and stop.

---

## Step 5: Execute Rollback

Run the rollback script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/rollback-checkpoint.sh" "<target-hash>" "<mode>"
```

Where `<mode>` is either `"revert"` or `"reset"`.

If the script reports an error, display the error message to the user and stop.

---

## Step 6: Report

After a successful rollback, display a summary:

### If mode was "reset":

```
Rollback complete (reset --soft).
  HEAD is now at: <target-hash> — <target subject>
  Previous changes are staged and ready to be re-committed or discarded.

  Tip: Use `git status` to see staged changes. Use `git diff --cached` to review them.
```

### If mode was "revert":

```
Rollback complete (revert).
  A revert commit has been created.
  HEAD is now at: <new-head-hash> — <new-head subject>

  Tip: Use `git log --oneline -5` to see the revert commit.
```

---

## Rules

- **NEVER force push.** The `/undo` command must never run `git push --force` or any variant. If the user needs to update the remote after a reset, they must do so manually.
- **Always preserve the working tree.** Use `--soft` for reset and `--no-commit` for revert so that no uncommitted work is destroyed.
- **Always confirm before rollback.** The user must explicitly say "yes" before any rollback is executed. Never auto-execute.
- **Use `${CLAUDE_PLUGIN_ROOT}` for all plugin-relative paths** to scripts (list-checkpoints.sh, rollback-checkpoint.sh, etc.).
- **Exit gracefully on errors.** If any git command fails, report the error clearly and stop. Do not attempt recovery.
- **Keep output concise but informative.** Show enough context (commit hashes, subjects, mode reasoning) for the user to make an informed decision.
