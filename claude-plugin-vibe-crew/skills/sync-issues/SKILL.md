---
name: sync-issues
description: Import open GitHub issues by label into the VibeCrew backlog
disable-model-invocation: true
---

# /sync-issues

Batch-import open GitHub issues into the VibeCrew backlog. Fetches issues matching a label (default: `autofix`), imports each one as a backlog entry, and reports results. Zero token cost — pure bash execution.

**Usage:** `/sync-issues` or `/sync-issues --label <name> --limit <n>`

---

## Pre-flight Check

### Check 1: VibeCrew Initialized

```bash
test -f ".vibecrew/state.json" && echo "exists" || echo "missing"
```

If `.vibecrew/state.json` does not exist, output EXACTLY this and stop:

```
VibeCrew not initialized. Run /setup first.
```

### Check 2: GitHub CLI

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-gh-auth.sh"
```

Parse the JSON output. If `status` is not `"ok"`, display the `message` field and stop.

---

## Step 1: Read Config

Read the GitHub Issues configuration for defaults.

```bash
jq -r '.github_issues // {}' .vibecrew/config.json 2>/dev/null
```

Extract:
- `autofix_label` (default: `"autofix"`)
- `sync_limit` (default: `10`)
- `default_mode` (default: `"hotfix"`)

Override with command-line flags if provided:
- `--label <name>` overrides `autofix_label`
- `--limit <n>` overrides `sync_limit`
- `--full` overrides `default_mode` to `"feature"`

---

## Step 2: Fetch Issues

List open issues matching the label.

```bash
gh issue list --label "<label>" --state open --limit <limit> --json number,title,labels,state,url,author,createdAt
```

Parse the JSON output. If no issues are found, output:

```
No open issues found with label "<label>".
```

And stop.

Display the list:

```
Found <n> open issues with label "<label>"
==========================================
  #<number>  <title>
  #<number>  <title>
  ...
```

---

## Step 3: Import Each Issue

Loop through each issue and import it into the backlog.

For each issue:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/fetch-github-issue.sh" <number> | bash "${CLAUDE_PLUGIN_ROOT}/scripts/import-issue-to-backlog.sh" [--full]
```

Pass `--full` if `default_mode` is `"feature"` or `--full` flag was passed.

Track results:
- **Imported**: new backlog entry created
- **Duplicate**: issue already exists in backlog (skipped)
- **Error**: failed to import (log reason)

---

## Step 4: Report Summary

Display the final summary:

```
Sync Complete
=============
Imported: <n> issues
Skipped:  <n> duplicates
Errors:   <n> failures

New backlog entries:
  <feature-id>  #<number>  <title>
  <feature-id>  #<number>  <title>
  ...

Skipped (already in backlog):
  <feature-id>  #<number>  <title>
  ...

Run /run-backlog to process these issues automatically,
or /fix-issue <number> to fix a specific issue interactively.
```

If there were errors, also display:

```
Errors:
  #<number>  <error-message>
  ...
```

---

## Rules

- **Zero token cost.** This skill uses `disable-model-invocation: true`. All operations are bash scripts.
- **Use `${CLAUDE_PLUGIN_ROOT}`** for all plugin-relative paths.
- **Deduplication.** Never create duplicate backlog entries. The import script checks `github_issue_number`.
- **Respect sync_limit.** Never import more issues than the configured limit.
- **Default label is `autofix`.** Only issues explicitly labeled for auto-fix are imported.
- **Do not modify issues.** This command only reads from GitHub and writes to the local backlog. It does not label, comment on, or close issues.
