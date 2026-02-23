# Research: Git Automation for AI-Assisted Development

> **Phase 1 Research** | Document 03 | February 2026
>
> This document covers best practices for automating Git workflows in AI-assisted development environments. It addresses automated branching, conventional commits, PR creation, safety guardrails, conflict resolution, and semantic versioning -- all critical for a system like VibeOS where AI agents perform git operations autonomously.

---

## Table of Contents

1. [Automated Feature Branching](#1-automated-feature-branching)
2. [Conventional Commits](#2-conventional-commits)
3. [Automated PR Creation](#3-automated-pr-creation)
4. [Pre-Session Git Status Validation](#4-pre-session-git-status-validation)
5. [Safe Git Operations](#5-safe-git-operations)
6. [Automated Merge Conflict Resolution](#6-automated-merge-conflict-resolution)
7. [Tagging and Versioning](#7-tagging-and-versioning)
8. [Recommendations for VibeOS](#8-recommendations-for-vibeos)
9. [Sources](#9-sources)

---

## 1. Automated Feature Branching

### 1.1 Conventional Branch Naming

The widely-adopted convention uses a **type prefix** followed by a slash and a descriptive slug. This mirrors conventional commit types and makes it trivial to identify the purpose of any branch at a glance.

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feat/` | New feature | `feat/user-authentication` |
| `fix/` | Bug fix | `fix/login-redirect-loop` |
| `docs/` | Documentation only | `docs/api-reference-update` |
| `refactor/` | Code restructure | `refactor/extract-auth-service` |
| `test/` | Adding/fixing tests | `test/payment-integration` |
| `chore/` | Maintenance tasks | `chore/upgrade-dependencies` |
| `perf/` | Performance improvement | `perf/optimize-query-n-plus-one` |
| `ci/` | CI/CD changes | `ci/add-staging-pipeline` |
| `hotfix/` | Urgent production fix | `hotfix/null-pointer-crash` |
| `release/` | Release preparation | `release/v2.1.0` |

**Naming rules:**
- Use lowercase only
- Use hyphens (not underscores) as word separators
- Optionally include an issue number: `feat/GH-42-user-authentication`
- Keep slugs under 50 characters
- Avoid special characters (spaces, periods, tildes)

### 1.2 Automated Branch Creation from Task Specs

In an AI-assisted workflow, the agent can derive the branch name directly from a task specification. This eliminates naming inconsistency and ensures traceability.

```bash
#!/usr/bin/env bash
# create-feature-branch.sh
# Creates a conventionally-named branch from a task spec.

set -euo pipefail

TASK_TYPE="${1:?Usage: create-feature-branch.sh <type> <description> [issue-number]}"
DESCRIPTION="${2:?Usage: create-feature-branch.sh <type> <description> [issue-number]}"
ISSUE_NUMBER="${3:-}"

# Validate type
VALID_TYPES="feat fix docs refactor test chore perf ci hotfix release"
if ! echo "$VALID_TYPES" | grep -qw "$TASK_TYPE"; then
  echo "Error: Invalid type '$TASK_TYPE'. Must be one of: $VALID_TYPES"
  exit 1
fi

# Slugify the description
SLUG=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | cut -c1-50)

# Build branch name
if [ -n "$ISSUE_NUMBER" ]; then
  BRANCH_NAME="${TASK_TYPE}/GH-${ISSUE_NUMBER}-${SLUG}"
else
  BRANCH_NAME="${TASK_TYPE}/${SLUG}"
fi

# Ensure we're on the latest main
git fetch origin main
git checkout -b "$BRANCH_NAME" origin/main

echo "Created branch: $BRANCH_NAME"
```

### 1.3 Branch Lifecycle Management

Stale branches accumulate quickly in AI-assisted workflows where agents may create many feature branches. Automated cleanup is essential.

```bash
#!/usr/bin/env bash
# cleanup-merged-branches.sh
# Removes local and remote branches that have been merged into main.

set -euo pipefail

BASE_BRANCH="${1:-main}"
DRY_RUN="${2:-false}"

echo "Checking for branches merged into $BASE_BRANCH..."

# List merged branches (excluding main, master, and current branch)
MERGED_BRANCHES=$(git branch --merged "$BASE_BRANCH" | grep -vE '^\*|main|master|develop' | sed 's/^ *//')

if [ -z "$MERGED_BRANCHES" ]; then
  echo "No merged branches to clean up."
  exit 0
fi

echo "Merged branches found:"
echo "$MERGED_BRANCHES"

if [ "$DRY_RUN" = "true" ]; then
  echo "(dry run -- no branches deleted)"
  exit 0
fi

echo "$MERGED_BRANCHES" | while read -r branch; do
  echo "Deleting local branch: $branch"
  git branch -d "$branch"

  # Also delete from remote if it exists
  if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
    echo "Deleting remote branch: origin/$branch"
    git push origin --delete "$branch"
  fi
done

echo "Branch cleanup complete."
```

**Branch protection rules** (set via GitHub repo settings or `gh api`):

```bash
# Protect the main branch via GitHub CLI
gh api repos/{owner}/{repo}/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci/test","ci/lint"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null
```

---

## 2. Conventional Commits

### 2.1 The Standard

The Conventional Commits specification (v1.0.0) defines a structured commit message format that is both human-readable and machine-parseable. It maps directly to Semantic Versioning (SemVer).

**Format:**

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Commit types and their SemVer mapping:**

| Type | Description | SemVer Impact |
|------|-------------|---------------|
| `feat` | A new feature | MINOR bump |
| `fix` | A bug fix | PATCH bump |
| `docs` | Documentation only changes | No release |
| `style` | Formatting, missing semicolons, etc. | No release |
| `refactor` | Code change that neither fixes nor adds | No release |
| `perf` | Performance improvement | PATCH bump |
| `test` | Adding or correcting tests | No release |
| `chore` | Build process or auxiliary tool changes | No release |
| `ci` | CI configuration files and scripts | No release |
| `build` | Changes affecting the build system | No release |
| `revert` | Reverts a previous commit | Depends on reverted commit |

**Breaking changes** are signaled by:
- Adding `!` after the type/scope: `feat!: remove deprecated API endpoint`
- Including `BREAKING CHANGE:` in the footer

A breaking change triggers a **MAJOR** version bump regardless of the commit type.

**Examples:**

```
feat(auth): add OAuth2 login with Google provider

Implements the full OAuth2 authorization code flow with PKCE.
Includes token refresh logic and session persistence.

Closes #42

---

fix(payments): correct decimal rounding in invoice totals

The previous implementation used floating-point arithmetic,
causing penny discrepancies on invoices with many line items.
Switched to integer-based cent calculations.

Fixes #187

---

feat(api)!: change pagination from offset to cursor-based

BREAKING CHANGE: The `page` and `per_page` query parameters
have been replaced with `cursor` and `limit`. All API clients
must update to the new pagination scheme.

---

chore(deps): upgrade Next.js from 14.1 to 15.0

---

docs: add deployment guide for Railway
```

### 2.2 Enforcing Conventional Commits via Git Hooks

#### commitlint

commitlint is the standard tool for validating commit messages against the conventional commits specification. It runs as a `commit-msg` git hook.

**Installation and setup:**

```bash
# Install commitlint and the conventional config
npm install --save-dev @commitlint/cli @commitlint/config-conventional
```

**Configuration (`commitlint.config.js`):**

```javascript
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    // Type must be one of the conventional types
    'type-enum': [
      2, // error level (0 = disable, 1 = warn, 2 = error)
      'always',
      [
        'feat',
        'fix',
        'docs',
        'style',
        'refactor',
        'perf',
        'test',
        'chore',
        'ci',
        'build',
        'revert',
      ],
    ],
    // Subject must not be empty
    'subject-empty': [2, 'never'],
    // Subject must not end with a period
    'subject-full-stop': [2, 'never', '.'],
    // Subject must be lowercase
    'subject-case': [2, 'always', 'lower-case'],
    // Type must be lowercase
    'type-case': [2, 'always', 'lower-case'],
    // Header must be under 100 characters
    'header-max-length': [2, 'always', 100],
    // Body lines must be under 100 characters
    'body-max-line-length': [2, 'always', 100],
  },
};
```

#### Husky

Husky (v9+) is the standard tool for managing git hooks in JavaScript/Node.js projects. It installs hooks that run scripts before commits, pushes, and other git events.

**Installation and setup (Husky v9+):**

```bash
# Install husky
npm install --save-dev husky

# Initialize husky (creates .husky/ directory)
npx husky init
```

This creates a `.husky/` directory and adds a `prepare` script to `package.json`:

```json
{
  "scripts": {
    "prepare": "husky"
  }
}
```

**Setting up the commit-msg hook for commitlint:**

```bash
# Create the commit-msg hook
echo 'npx --no -- commitlint --edit "$1"' > .husky/commit-msg
```

**Setting up a pre-commit hook (e.g., for lint-staged):**

```bash
# .husky/pre-commit
npx lint-staged
```

**Setting up a pre-push hook:**

```bash
# .husky/pre-push
npm test
```

#### Alternative: Pure Bash commit-msg Hook (No Node.js Required)

For projects that do not use Node.js, a bash-based commit-msg hook can enforce conventional commits without any dependencies:

```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg (or .husky/commit-msg for husky)
# Validates that commit messages follow the Conventional Commits format.

set -euo pipefail

COMMIT_MSG_FILE="$1"
COMMIT_MSG=$(head -1 "$COMMIT_MSG_FILE")

# Pattern: type(optional-scope)optional-!: description
PATTERN='^(feat|fix|docs|style|refactor|perf|test|chore|ci|build|revert)(\([a-z0-9_-]+\))?(!)?: .{1,100}$'

if ! echo "$COMMIT_MSG" | grep -Eq "$PATTERN"; then
  echo "ERROR: Commit message does not follow Conventional Commits format."
  echo ""
  echo "Expected: <type>[optional scope]: <description>"
  echo "  Types: feat, fix, docs, style, refactor, perf, test, chore, ci, build, revert"
  echo ""
  echo "Examples:"
  echo "  feat(auth): add OAuth2 login"
  echo "  fix: correct null pointer in payment flow"
  echo "  docs: update API reference"
  echo ""
  echo "Your message: $COMMIT_MSG"
  exit 1
fi

echo "Commit message validated."
```

### 2.3 AI-Specific Considerations for Conventional Commits

When AI agents generate commits, additional discipline is needed:

1. **Co-authorship attribution**: AI-generated commits should include a `Co-Authored-By` trailer to maintain an honest audit trail.
   ```
   feat(dashboard): add real-time metric charts

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```

2. **Avoid mega-commits**: AI agents tend to make large changes in a single pass. Enforce a maximum diff-size check in the pre-commit hook.

3. **Scope enforcement**: When an agent is assigned to work on a specific feature, the commit scope should match the task scope. This can be validated programmatically.

4. **Automated message generation**: The agent should derive the commit type and scope from the task spec, not guess. For example, if the task says "fix the login redirect bug," the commit should start with `fix(auth):`.

---

## 3. Automated PR Creation

### 3.1 Using `gh pr create` Programmatically

The GitHub CLI (`gh`) is the standard tool for creating pull requests from the command line or scripts. It supports structured descriptions, auto-linking, labels, reviewers, and more.

**Basic usage:**

```bash
gh pr create \
  --title "feat(auth): add OAuth2 login with Google" \
  --body "## Summary
- Implements OAuth2 authorization code flow with PKCE
- Adds Google as identity provider
- Includes token refresh and session persistence

## Test Plan
- [ ] Manual login flow test on staging
- [ ] Verify token refresh after 1 hour
- [ ] Check session persistence across browser restart

Closes #42" \
  --base main \
  --head feat/GH-42-oauth-login \
  --label "feature" \
  --reviewer "teammate-handle"
```

### 3.2 Structured PR Descriptions

A well-structured PR template makes review faster and ensures nothing is missed. For AI-assisted development, the template should be generated automatically from the task spec and the actual changes made.

**Recommended PR template (`.github/pull_request_template.md`):**

```markdown
## Summary
<!-- One-line description of what this PR does -->

## Changes
<!-- Bullet list of specific changes -->
-

## Type of Change
- [ ] New feature (`feat`)
- [ ] Bug fix (`fix`)
- [ ] Refactoring (`refactor`)
- [ ] Documentation (`docs`)
- [ ] Tests (`test`)
- [ ] Chore / maintenance (`chore`)
- [ ] Breaking change (describe in "Breaking Changes" section below)

## Test Plan
<!-- How to test these changes -->
- [ ]

## Breaking Changes
<!-- List any breaking changes, or "None" -->
None

## Related Issues
<!-- Link issues with "Closes #X" or "Fixes #X" for auto-close -->
```

### 3.3 Automated PR Creation Script

```bash
#!/usr/bin/env bash
# create-pr.sh
# Creates a structured PR from the current branch with auto-detection.

set -euo pipefail

# Extract branch info
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BASE_BRANCH="${1:-main}"

# Parse type and description from branch name
# Expected format: type/optional-issue-slug
TYPE=$(echo "$BRANCH" | cut -d'/' -f1)
SLUG=$(echo "$BRANCH" | cut -d'/' -f2-)

# Extract issue number if present (format: GH-42-description)
ISSUE_NUMBER=""
if echo "$SLUG" | grep -qE '^GH-[0-9]+'; then
  ISSUE_NUMBER=$(echo "$SLUG" | grep -oE 'GH-[0-9]+' | head -1 | sed 's/GH-//')
fi

# Build human-readable title from slug
TITLE_DESC=$(echo "$SLUG" | sed 's/GH-[0-9]*-//' | tr '-' ' ')
PR_TITLE="${TYPE}: ${TITLE_DESC}"

# Collect commit messages for the body
COMMITS=$(git log "${BASE_BRANCH}..HEAD" --pretty=format:"- %s" --reverse)

# Count changes
FILES_CHANGED=$(git diff --name-only "${BASE_BRANCH}..HEAD" | wc -l | tr -d ' ')
INSERTIONS=$(git diff --stat "${BASE_BRANCH}..HEAD" | tail -1 | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
DELETIONS=$(git diff --stat "${BASE_BRANCH}..HEAD" | tail -1 | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")

# Build the body
BODY="## Summary
${TITLE_DESC}

## Commits
${COMMITS}

## Stats
- **Files changed:** ${FILES_CHANGED}
- **Insertions:** +${INSERTIONS}
- **Deletions:** -${DELETIONS}"

# Add issue link if available
if [ -n "$ISSUE_NUMBER" ]; then
  BODY="${BODY}

## Related Issues
Closes #${ISSUE_NUMBER}"
fi

# Create the PR
gh pr create \
  --title "$PR_TITLE" \
  --body "$BODY" \
  --base "$BASE_BRANCH" \
  --head "$BRANCH"

echo "PR created successfully."
```

### 3.4 Auto-Linking to Issues

GitHub supports several keywords in PR descriptions and commit messages that automatically link and close issues:

- `Closes #42` -- closes issue when PR is merged
- `Fixes #42` -- same behavior, alternative keyword
- `Resolves #42` -- same behavior, alternative keyword
- `Relates to #42` -- creates a link without auto-close

These keywords work in:
- Commit messages
- PR descriptions (body)
- PR comments

For cross-repository linking: `Closes org/repo#42`

### 3.5 Generating PR Descriptions from Git History

For AI agents, the best approach is to generate the PR description by analyzing the diff and commit history:

```bash
# Get a summary of all changes between base and HEAD
git diff --stat main..HEAD

# Get the full diff for AI analysis
git diff main..HEAD

# Get all commit messages
git log main..HEAD --pretty=format:"%h %s" --reverse
```

The AI agent can then produce a structured summary from this information, ensuring the PR description accurately reflects what was changed and why.

---

## 4. Pre-Session Git Status Validation

### 4.1 Why Pre-Session Validation Matters

Before an AI agent begins work, it must verify the git environment is in a known-good state. Starting work on a dirty tree, an unexpected branch, or with unresolved conflicts leads to compounding errors.

### 4.2 Comprehensive Validation Script

```bash
#!/usr/bin/env bash
# git-session-check.sh
# Validates git status before an AI agent begins work.
# Exit codes: 0 = clean, 1 = warning (can proceed), 2 = blocker (must fix)

set -euo pipefail

ERRORS=0
WARNINGS=0

echo "=== Git Session Pre-Check ==="
echo ""

# 1. Check we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "BLOCKER: Not inside a git repository."
  exit 2
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
echo "Repository: $REPO_ROOT"

# 2. Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "Current branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  echo "  WARNING: On protected branch '$CURRENT_BRANCH'. Create a feature branch before making changes."
  WARNINGS=$((WARNINGS + 1))
fi

# 3. Check for uncommitted changes
STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
UNSTAGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

if [ "$STAGED" -gt 0 ]; then
  echo "  WARNING: $STAGED staged but uncommitted file(s)."
  git diff --cached --name-only | sed 's/^/    /'
  WARNINGS=$((WARNINGS + 1))
fi

if [ "$UNSTAGED" -gt 0 ]; then
  echo "  WARNING: $UNSTAGED unstaged modification(s)."
  git diff --name-only | sed 's/^/    /'
  WARNINGS=$((WARNINGS + 1))
fi

if [ "$UNTRACKED" -gt 0 ]; then
  echo "  INFO: $UNTRACKED untracked file(s)."
fi

# 4. Check for merge conflicts
CONFLICT_FILES=$(git diff --name-only --diff-filter=U 2>/dev/null || true)
if [ -n "$CONFLICT_FILES" ]; then
  echo "  BLOCKER: Unresolved merge conflicts detected!"
  echo "$CONFLICT_FILES" | sed 's/^/    /'
  ERRORS=$((ERRORS + 1))
fi

# 5. Check if we're in the middle of a rebase or merge
if [ -d "$REPO_ROOT/.git/rebase-merge" ] || [ -d "$REPO_ROOT/.git/rebase-apply" ]; then
  echo "  BLOCKER: Rebase in progress. Complete or abort it before starting."
  ERRORS=$((ERRORS + 1))
fi

if [ -f "$REPO_ROOT/.git/MERGE_HEAD" ]; then
  echo "  BLOCKER: Merge in progress. Complete or abort it before starting."
  ERRORS=$((ERRORS + 1))
fi

# 6. Check if branch is behind remote
git fetch origin "$CURRENT_BRANCH" 2>/dev/null || true
LOCAL=$(git rev-parse "$CURRENT_BRANCH" 2>/dev/null || echo "unknown")
REMOTE=$(git rev-parse "origin/$CURRENT_BRANCH" 2>/dev/null || echo "unknown")

if [ "$LOCAL" != "unknown" ] && [ "$REMOTE" != "unknown" ]; then
  BEHIND=$(git rev-list --count "$CURRENT_BRANCH..origin/$CURRENT_BRANCH" 2>/dev/null || echo "0")
  AHEAD=$(git rev-list --count "origin/$CURRENT_BRANCH..$CURRENT_BRANCH" 2>/dev/null || echo "0")

  if [ "$BEHIND" -gt 0 ]; then
    echo "  WARNING: Branch is $BEHIND commit(s) behind origin. Consider pulling."
    WARNINGS=$((WARNINGS + 1))
  fi
  if [ "$AHEAD" -gt 0 ]; then
    echo "  INFO: Branch is $AHEAD commit(s) ahead of origin."
  fi
fi

# 7. Check for large files that shouldn't be committed
LARGE_FILES=$(git diff --cached --name-only 2>/dev/null | while read -r f; do
  if [ -f "$f" ]; then
    SIZE=$(wc -c < "$f" | tr -d ' ')
    if [ "$SIZE" -gt 5242880 ]; then  # 5MB
      echo "    $f ($(( SIZE / 1048576 ))MB)"
    fi
  fi
done || true)

if [ -n "$LARGE_FILES" ]; then
  echo "  WARNING: Large files staged for commit:"
  echo "$LARGE_FILES"
  WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "=== Summary ==="
if [ "$ERRORS" -gt 0 ]; then
  echo "RESULT: BLOCKED ($ERRORS blocker(s), $WARNINGS warning(s))"
  echo "Fix blockers before starting work."
  exit 2
elif [ "$WARNINGS" -gt 0 ]; then
  echo "RESULT: PROCEED WITH CAUTION ($WARNINGS warning(s))"
  exit 1
else
  echo "RESULT: CLEAN -- Ready to work."
  exit 0
fi
```

### 4.3 Integration with VibeOS Session Startup

The Session Startup agent in VibeOS should run this validation as the first step of every session. The results inform the agent's routing decision:

- **Exit 0 (clean):** Proceed normally to task routing.
- **Exit 1 (warnings):** Inform the user and suggest resolution, but proceed if the user confirms.
- **Exit 2 (blockers):** Stop and require the user to resolve the issue before any work begins.

---

## 5. Safe Git Operations

### 5.1 Preventing Dangerous Commands

AI agents must never execute destructive git commands without explicit user consent. The following operations should be blocked by default:

| Command | Risk | Mitigation |
|---------|------|------------|
| `git push --force` | Overwrites remote history | Block entirely; use `--force-with-lease` if necessary |
| `git push --force-with-lease` | Overwrites remote but with safety check | Allow only with explicit user confirmation |
| `git reset --hard` | Destroys uncommitted changes | Block; suggest `git stash` instead |
| `git checkout .` / `git restore .` | Discards all unstaged changes | Block; require file-specific operations |
| `git clean -f` | Deletes untracked files permanently | Block entirely |
| `git rebase` (on shared branches) | Rewrites shared history | Block on main/master/develop |
| `git branch -D` | Force-deletes branch even if unmerged | Block; use `git branch -d` (safe delete) |

### 5.2 Pre-Push Safety Hook

```bash
#!/usr/bin/env bash
# .husky/pre-push (or .git/hooks/pre-push)
# Prevents force pushes and pushes to protected branches.

set -euo pipefail

PROTECTED_BRANCHES="main master develop"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Block pushes to protected branches
for branch in $PROTECTED_BRANCHES; do
  if [ "$CURRENT_BRANCH" = "$branch" ]; then
    echo "ERROR: Direct push to '$branch' is not allowed."
    echo "Create a feature branch and open a pull request instead."
    exit 1
  fi
done

# Detect force push by reading the push info from stdin
while read -r local_ref local_sha remote_ref remote_sha; do
  if [ "$local_sha" = "0000000000000000000000000000000000000000" ]; then
    # Branch deletion -- allow
    continue
  fi

  if [ "$remote_sha" != "0000000000000000000000000000000000000000" ]; then
    # Check if this is a force push (remote commits not in local history)
    NON_FAST_FORWARD=$(git rev-list "$local_sha..$remote_sha" --count 2>/dev/null || echo "0")
    if [ "$NON_FAST_FORWARD" -gt 0 ]; then
      echo "ERROR: Force push detected. This rewrites history and is not allowed."
      echo "If you must force push, use: git push --force-with-lease (after getting approval)"
      exit 1
    fi
  fi
done

exit 0
```

### 5.3 Pre-Commit Safety Hook

```bash
#!/usr/bin/env bash
# .husky/pre-commit (or .git/hooks/pre-commit)
# Prevents committing sensitive files and enforces basic hygiene.

set -euo pipefail

# Patterns for files that should never be committed
FORBIDDEN_PATTERNS=(
  '\.env$'
  '\.env\.local$'
  '\.env\.production$'
  'credentials\.json$'
  'service-account\.json$'
  '\.pem$'
  'id_rsa'
  'id_ed25519'
  '\.key$'
  'secret'
)

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

for file in $STAGED_FILES; do
  for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if echo "$file" | grep -qE "$pattern"; then
      echo "ERROR: Attempting to commit potentially sensitive file: $file"
      echo "If this is intentional, use: git commit --no-verify"
      exit 1
    fi
  done
done

# Check for debug statements (console.log, debugger, print())
DEBUG_PATTERNS='console\.log\(|debugger;|print\(.*DEBUG|TODO.*REMOVE|FIXME.*BEFORE.*MERGE'
MATCHES=$(git diff --cached -G "$DEBUG_PATTERNS" --name-only || true)
if [ -n "$MATCHES" ]; then
  echo "WARNING: Debug statements detected in staged files:"
  echo "$MATCHES" | sed 's/^/  /'
  echo "Review these before committing."
  # Warning only -- do not block
fi

exit 0
```

### 5.4 Bash Command Guard for AI Agents

In VibeOS, the `protect-data.sh` hook should intercept shell commands before execution. Here is an implementation pattern:

```bash
#!/usr/bin/env bash
# protect-data.sh
# Hook: PreToolUse (Bash)
# Blocks dangerous git commands from being executed by AI agents.

set -euo pipefail

COMMAND="$1"

# Dangerous git patterns
BLOCKED_PATTERNS=(
  'git push.*--force[^-]'       # --force but not --force-with-lease
  'git push.*-f[^o]'            # -f but not -force-with-lease
  'git reset --hard'
  'git checkout \.'
  'git restore \.'
  'git clean -f'
  'git branch -D'
  'git rebase.*main'
  'git rebase.*master'
  'rm -rf'
  'DROP TABLE'
  'DROP DATABASE'
  'truncate '
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: This command matches a dangerous pattern: $pattern"
    echo "Command: $COMMAND"
    echo ""
    echo "If this operation is necessary, ask the user for explicit confirmation."
    exit 1
  fi
done

exit 0
```

### 5.5 Git Configuration for Safety

These git config options add guardrails at the git level:

```bash
# Prevent accidental pushes to main
git config --local branch.main.pushRemote no_push

# Default to --force-with-lease when force pushing (Git 2.30+)
git config --local push.default current
git config --local push.autoSetupRemote true

# Require signed commits (if using GPG)
# git config --local commit.gpgsign true

# Show diff in commit message editor (helps AI generate better messages)
git config --local commit.verbose true

# Auto-prune deleted remote branches on fetch
git config --local fetch.prune true

# Prevent pushing to multiple remotes simultaneously
git config --local push.default simple
```

---

## 6. Automated Merge Conflict Resolution

### 6.1 Conflict Types and Resolution Strategies

Merge conflicts in AI-assisted workflows fall into categories with different resolution strategies:

| Conflict Type | Auto-Resolvable? | Strategy |
|--------------|-------------------|----------|
| **Lock file conflicts** (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`) | Yes | Accept either side, then regenerate |
| **Auto-generated files** (build output, compiled CSS) | Yes | Accept either side, then regenerate |
| **Whitespace / formatting** | Yes | Accept the version that matches project formatter |
| **Additive conflicts** (both sides add to the same area) | Sometimes | Combine both additions if they don't contradict |
| **Semantic conflicts** (both sides modify the same logic) | No | Escalate to human review |
| **Schema conflicts** (database migrations, API contracts) | No | Escalate to human review |

### 6.2 Automated Lock File Resolution

The most common conflict in JavaScript projects is `package-lock.json`. This should always be resolved by regeneration:

```bash
#!/usr/bin/env bash
# resolve-lockfile-conflicts.sh
# Automatically resolves lock file conflicts by regenerating them.

set -euo pipefail

CONFLICT_FILES=$(git diff --name-only --diff-filter=U)

for file in $CONFLICT_FILES; do
  case "$file" in
    package-lock.json)
      echo "Resolving: $file (regenerating with npm install)"
      git checkout --theirs "$file"
      npm install
      git add "$file"
      ;;
    yarn.lock)
      echo "Resolving: $file (regenerating with yarn install)"
      git checkout --theirs "$file"
      yarn install
      git add "$file"
      ;;
    pnpm-lock.yaml)
      echo "Resolving: $file (regenerating with pnpm install)"
      git checkout --theirs "$file"
      pnpm install
      git add "$file"
      ;;
    *)
      echo "Cannot auto-resolve: $file -- requires manual review."
      ;;
  esac
done
```

### 6.3 AI-Assisted Conflict Resolution Workflow

For semantic conflicts, the AI agent can analyze the conflict and propose a resolution, but should always get human approval:

```bash
#!/usr/bin/env bash
# analyze-conflicts.sh
# Extracts conflict information for AI analysis.

set -euo pipefail

CONFLICT_FILES=$(git diff --name-only --diff-filter=U)

if [ -z "$CONFLICT_FILES" ]; then
  echo "No conflicts detected."
  exit 0
fi

echo "=== Merge Conflict Analysis ==="
echo ""

for file in $CONFLICT_FILES; do
  echo "--- File: $file ---"
  echo ""

  # Show the three-way diff
  echo "Ours (current branch):"
  git show :2:"$file" 2>/dev/null | head -50 || echo "  (file does not exist in ours)"
  echo ""

  echo "Theirs (incoming branch):"
  git show :3:"$file" 2>/dev/null | head -50 || echo "  (file does not exist in theirs)"
  echo ""

  echo "Base (common ancestor):"
  git show :1:"$file" 2>/dev/null | head -50 || echo "  (no common ancestor)"
  echo ""
  echo "---"
  echo ""
done
```

### 6.4 Resolution Decision Framework for AI Agents

The AI agent should follow this decision tree when encountering conflicts:

1. **Is it a lock file or generated file?** --> Auto-resolve by regeneration.
2. **Is it a formatting-only conflict?** --> Run the project formatter and accept its output.
3. **Are both sides additive (no deletions, no modifications to existing lines)?** --> Attempt to merge both additions; verify with tests.
4. **Does the conflict involve business logic?** --> Present both versions to the user with analysis; do not auto-resolve.
5. **Does the conflict involve database schemas or API contracts?** --> Always escalate; these require architectural decisions.

### 6.5 Merge Strategy Configuration

```bash
# Use the "ort" merge strategy (default in Git 2.34+, more performant)
git config --local merge.conflictstyle diff3   # Show base version in conflicts
git config --local rerere.enabled true          # Remember conflict resolutions

# Auto-resolve specific file types
echo 'package-lock.json merge=ours' >> .gitattributes
echo 'yarn.lock merge=ours' >> .gitattributes
```

The `rerere` (Reuse Recorded Resolution) feature is particularly valuable for AI-assisted workflows: once a conflict resolution is recorded, Git will automatically apply the same resolution if the same conflict recurs.

---

## 7. Tagging and Versioning

### 7.1 Semantic Versioning (SemVer)

The Semantic Versioning specification (v2.0.0) defines version numbers as `MAJOR.MINOR.PATCH`:

- **MAJOR**: Incompatible API changes (breaking changes)
- **MINOR**: New functionality (backwards-compatible)
- **PATCH**: Bug fixes (backwards-compatible)

Pre-release versions: `1.0.0-alpha.1`, `1.0.0-beta.2`, `1.0.0-rc.1`

### 7.2 Automated Version Bumping

When using conventional commits, version bumps can be fully automated based on commit types:

| Commit Type | Version Bump |
|-------------|-------------|
| `fix:` | PATCH (0.0.x) |
| `perf:` | PATCH (0.0.x) |
| `feat:` | MINOR (0.x.0) |
| Any type with `BREAKING CHANGE` or `!` | MAJOR (x.0.0) |

#### standard-version / release-please

**standard-version** (now deprecated in favor of **release-please**) and its successor **release-please** automate the entire release process:

```bash
# Install release-please (Google's tool for automated releases)
npm install --save-dev release-please
```

**release-please** works as a GitHub Action:

```yaml
# .github/workflows/release-please.yml
name: Release Please

on:
  push:
    branches:
      - main

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node
          # For monorepos, you can configure multiple packages
```

When conventional commits are pushed to `main`, release-please:
1. Automatically opens a "Release PR" that bumps the version
2. Updates `CHANGELOG.md` with entries generated from commit messages
3. When the Release PR is merged, creates a GitHub Release with the tag

#### Manual Version Bumping Script

For projects not using GitHub Actions, a script can handle this:

```bash
#!/usr/bin/env bash
# bump-version.sh
# Determines the next version from conventional commits since the last tag.

set -euo pipefail

# Get the latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "Latest tag: $LATEST_TAG"

# Get commits since the last tag
COMMITS=$(git log "${LATEST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null)

if [ -z "$COMMITS" ]; then
  echo "No new commits since $LATEST_TAG. Nothing to release."
  exit 0
fi

# Determine bump type
BUMP="none"

while IFS= read -r msg; do
  # Check for breaking changes
  if echo "$msg" | grep -qE '^[a-z]+(\(.+\))?!:' || echo "$msg" | grep -q 'BREAKING CHANGE'; then
    BUMP="major"
    break
  fi

  # Check for features
  if echo "$msg" | grep -qE '^feat(\(.+\))?:'; then
    if [ "$BUMP" != "major" ]; then
      BUMP="minor"
    fi
  fi

  # Check for fixes
  if echo "$msg" | grep -qE '^(fix|perf)(\(.+\))?:'; then
    if [ "$BUMP" = "none" ]; then
      BUMP="patch"
    fi
  fi
done <<< "$COMMITS"

if [ "$BUMP" = "none" ]; then
  echo "No version-affecting commits found. Skipping release."
  exit 0
fi

# Parse current version
VERSION="${LATEST_TAG#v}"
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# Apply bump
case "$BUMP" in
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  patch) PATCH=$((PATCH + 1)) ;;
esac

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
echo "Bump type: $BUMP"
echo "New version: $NEW_VERSION"

# Create annotated tag
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"
echo "Tag created: $NEW_VERSION"

# Optionally push the tag
# git push origin "$NEW_VERSION"
```

### 7.3 Generating Release Notes from Git History

```bash
#!/usr/bin/env bash
# generate-release-notes.sh
# Generates structured release notes from conventional commits.

set -euo pipefail

FROM_TAG="${1:?Usage: generate-release-notes.sh <from-tag> [to-ref]}"
TO_REF="${2:-HEAD}"

echo "# Release Notes"
echo ""
echo "## Changes since $FROM_TAG"
echo ""

# Collect commits by type
declare -A SECTIONS
SECTIONS[feat]="### New Features"
SECTIONS[fix]="### Bug Fixes"
SECTIONS[perf]="### Performance Improvements"
SECTIONS[refactor]="### Refactoring"
SECTIONS[docs]="### Documentation"
SECTIONS[test]="### Tests"
SECTIONS[chore]="### Maintenance"
SECTIONS[ci]="### CI/CD"
SECTIONS[breaking]="### BREAKING CHANGES"

# Process breaking changes first
BREAKING=$(git log "${FROM_TAG}..${TO_REF}" --pretty=format:"%s|%h" | grep -E '!:|BREAKING CHANGE' || true)
if [ -n "$BREAKING" ]; then
  echo "${SECTIONS[breaking]}"
  echo ""
  while IFS='|' read -r msg hash; do
    CLEAN_MSG=$(echo "$msg" | sed 's/^[a-z]*(\?[^)]*)\?!: //')
    echo "- $CLEAN_MSG (\`$hash\`)"
  done <<< "$BREAKING"
  echo ""
fi

# Process each type
for type in feat fix perf refactor docs test chore ci; do
  ENTRIES=$(git log "${FROM_TAG}..${TO_REF}" --pretty=format:"%s|%h" | grep -E "^${type}(\(|:)" || true)
  if [ -n "$ENTRIES" ]; then
    echo "${SECTIONS[$type]}"
    echo ""
    while IFS='|' read -r msg hash; do
      # Extract scope and description
      SCOPE=$(echo "$msg" | grep -oE "\([^)]+\)" | tr -d '()' || true)
      DESC=$(echo "$msg" | sed "s/^${type}([^)]*): //" | sed "s/^${type}: //")
      if [ -n "$SCOPE" ]; then
        echo "- **$SCOPE**: $DESC (\`$hash\`)"
      else
        echo "- $DESC (\`$hash\`)"
      fi
    done <<< "$ENTRIES"
    echo ""
  fi
done

# Stats
echo "### Stats"
echo ""
COMMIT_COUNT=$(git rev-list --count "${FROM_TAG}..${TO_REF}")
CONTRIBUTORS=$(git log "${FROM_TAG}..${TO_REF}" --pretty=format:"%an" | sort -u | wc -l | tr -d ' ')
echo "- **Commits:** $COMMIT_COUNT"
echo "- **Contributors:** $CONTRIBUTORS"
```

### 7.4 GitHub Release Creation

```bash
#!/usr/bin/env bash
# create-release.sh
# Creates a GitHub release with auto-generated notes.

set -euo pipefail

TAG="${1:?Usage: create-release.sh <tag>}"
PREVIOUS_TAG=$(git describe --tags --abbrev=0 "${TAG}^" 2>/dev/null || echo "")

if [ -n "$PREVIOUS_TAG" ]; then
  # Generate notes from commits
  NOTES=$(bash generate-release-notes.sh "$PREVIOUS_TAG" "$TAG")
else
  NOTES="Initial release."
fi

# Detect pre-release
PRERELEASE_FLAG=""
if echo "$TAG" | grep -qE '(alpha|beta|rc)'; then
  PRERELEASE_FLAG="--prerelease"
fi

gh release create "$TAG" \
  --title "Release $TAG" \
  --notes "$NOTES" \
  $PRERELEASE_FLAG

echo "GitHub release created for $TAG"
```

---

## 8. Recommendations for VibeOS

Based on the research above, here are the specific recommendations for implementing git automation in VibeOS:

### 8.1 Session Startup Integration

The **Session Startup agent** should execute the git session pre-check script (Section 4.2) before routing to any task. The check should:
- Verify clean working tree
- Detect and report the current branch
- Warn if on a protected branch
- Block if there are unresolved conflicts or an in-progress rebase/merge

### 8.2 Feature Developer Agent Git Workflow

The **Feature Developer agent** should follow this workflow:

1. **Branch creation**: Auto-create a conventionally-named branch from the feature spec in `backlog.json`.
2. **Atomic commits**: Make small, focused commits with conventional commit messages. Each commit should represent one logical change.
3. **Co-authorship**: Always include `Co-Authored-By: Claude <noreply@anthropic.com>` in commit trailers.
4. **PR creation**: When the feature is complete, auto-create a structured PR using `gh pr create`.

### 8.3 Hook Configuration for VibeOS

| Hook | Script | Purpose |
|------|--------|---------|
| `commit-msg` | `validate-commit-msg.sh` | Enforce conventional commit format |
| `pre-commit` | `pre-commit-safety.sh` | Block sensitive files, check for debug statements |
| `pre-push` | `pre-push-safety.sh` | Block force pushes and pushes to protected branches |
| `PreToolUse (Bash)` | `protect-data.sh` | Block dangerous git commands from AI agents |
| `SessionStart` | `git-session-check.sh` | Validate git status before starting work |

### 8.4 Versioning Strategy

- Use **conventional commits** to drive version bumps automatically.
- Use **release-please** (GitHub Action) or the manual `bump-version.sh` script for projects without CI.
- The **Doc Generator agent** should generate release notes from git history using the `generate-release-notes.sh` pattern.
- Tags should follow the `v{MAJOR}.{MINOR}.{PATCH}` format.

### 8.5 Conflict Resolution Policy

- **Auto-resolve**: Lock files, generated files, formatting conflicts.
- **AI-assisted**: Additive conflicts where both sides add non-contradictory code; present the proposed resolution to the user.
- **Always escalate**: Business logic conflicts, schema changes, API contract changes.
- Enable `rerere` to learn from past resolutions.

---

## 9. Sources

The following sources informed this research:

- **Conventional Commits Specification v1.0.0**: https://www.conventionalcommits.org/en/v1.0.0/
- **Semantic Versioning Specification v2.0.0**: https://semver.org/
- **commitlint documentation**: https://commitlint.js.org/
- **Husky documentation (v9)**: https://typicode.github.io/husky/
- **GitHub CLI (`gh`) documentation**: https://cli.github.com/manual/
- **`gh pr create` reference**: https://cli.github.com/manual/gh_pr_create
- **release-please by Google**: https://github.com/googleapis/release-please
- **Git documentation -- githooks**: https://git-scm.com/docs/githooks
- **Git documentation -- gitattributes (merge strategies)**: https://git-scm.com/docs/gitattributes
- **GitHub branch protection rules**: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule
- **GitHub auto-linking references**: https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls
- **Git rerere documentation**: https://git-scm.com/docs/git-rerere
- **lint-staged**: https://github.com/lint-staged/lint-staged

> **Note**: Web search and web fetch tools were unavailable during this research session. The content above is based on established documentation, specifications, and best practices for these widely-used tools as of early 2025. All tool versions and APIs referenced were current at the time of writing. Verify specific version numbers and API details against the linked sources for the latest information.
