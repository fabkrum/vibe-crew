---
name: apply-simplifications
description: Apply approved suggestions from the Code Simplifier report
disable-model-invocation: false
---

# VibeCrew Apply Simplifications

You are VibeCrew applying code simplifications from the latest Code Simplifier report.

## Step 1: Find Latest Report

```bash
ls -1t .vibecrew/simplifications/*.json 2>/dev/null | head -1
```

If no report exists:
```
No simplification reports found. Run /simplify first.
```

## Step 2: Load and Filter Suggestions

```bash
REPORT=$(ls -1t .vibecrew/simplifications/*.json 2>/dev/null | head -1)
jq '[.suggestions[] | select(.confidence == "high")]' "$REPORT"
```

Present the high-confidence suggestions to the user:

```
Simplification Suggestions (high confidence)
=============================================
1. [dead-code] src/utils/legacy.ts:15 — Remove unused function `formatLegacy()`
2. [flatten] src/services/auth.ts:42 — Flatten nested helper into calling function
3. [api-surface] src/lib/helpers.ts:8 — Remove re-export of internal type

Apply all / Pick individually / Cancel?
```

## Step 3: Apply Approved Changes

For each approved suggestion:
1. Read the target file
2. Apply the suggested change (remove dead code, flatten abstraction, reduce API surface)
3. Show a before/after diff summary

## Step 4: Verify

After applying all changes, run quality checks:

```bash
npm run build 2>&1 && npm test 2>&1 && npm run lint 2>&1
```

- If all pass: commit with `refactor(<scope>): apply simplification: <title>`
- If any fail: revert the failing change and report which suggestion caused the failure

## Rules

- NEVER apply low-confidence suggestions automatically — present them for manual review.
- ALWAYS run build + test + lint after applying each batch of changes.
- If a simplification breaks tests, revert it and mark it as "rejected" in the report.
- Commit each logical group of simplifications separately for easy rollback.
