---
name: onboard
description: Onboard an existing project into VibeCrew — analyzes codebase, extracts conventions, generates CLAUDE.md, and initializes state
disable-model-invocation: false
category: analysis
---

# VibeCrew Onboard: Existing Project Onboarding

You are the VibeCrew onboarding workflow for existing projects. Your job is to analyze an existing codebase, extract its conventions and patterns, generate a project-specific CLAUDE.md, and initialize VibeCrew state with `foundation.complete = true` so the project can immediately start Tier 2 feature development. Execute each step sequentially.

---

## Step 1: Pre-flight Checks

### 1.1 Check for existing VibeCrew state

```bash
test -d ".vibecrew" && echo "exists" || echo "missing"
```

**If `.vibecrew/` already exists:**
Ask the user: "This project already has a `.vibecrew/` directory. Re-onboard from scratch? (yes/no)"
- If **yes**: Continue with onboarding (existing state will be preserved, only CLAUDE.md and state.json updated)
- If **no**: Stop and tell the user: "Onboarding cancelled. Use `/status` to see current state."

### 1.2 Check for package.json

```bash
test -f "package.json" && echo "found" || echo "missing"
```

If `package.json` is missing, warn the user:
"No package.json found. VibeCrew onboarding works best with Node.js/TypeScript projects. I'll extract what I can from the file structure and git history, but some analysis will be limited."

Continue with reduced analysis (skip dependency and framework detection).

### 1.3 Check for git

```bash
git rev-parse --is-inside-work-tree 2>/dev/null && echo "git" || echo "no-git"
```

If not a git repo, warn: "This is not a git repository. Some analysis (commit history, branch detection) will be unavailable."

---

## Step 2: Initialize VibeCrew Directory

If `.vibecrew/` does not exist, initialize it:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/init-vibecrew-state.sh"
```

If the script is not available, create the directory manually:

```bash
mkdir -p .vibecrew/sessions .vibecrew/scores .vibecrew/releases .vibecrew/signals .vibecrew/handoffs
```

---

## Step 3: Run Code Auditor

Invoke the Code Auditor agent to perform the full codebase analysis. The auditor is read-only and runs in a worktree.

The auditor produces `.vibecrew/onboard-findings.json` with these sections:
- **dependencies**: Package manager, framework, language, key deps
- **structure**: Source dirs, test dirs, config files
- **conventions**: Naming, imports, formatting, commit format
- **test_gaps**: Untested modules, coverage estimate
- **design_system**: CSS vars, Tailwind, component library
- **architecture**: API style, state management, error handling

If the Code Auditor agent is not available, run the analysis scripts directly:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect-conventions.sh"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/analyze-test-gaps.sh"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/extract-project-conventions.sh"
```

Combine the outputs into a findings JSON and write to `.vibecrew/onboard-findings.json`.

### 3.1 Generate Persistent Analysis Docs

After findings are produced, generate the 4 persistent analysis docs:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate-analysis-docs.sh" --findings ".vibecrew/onboard-findings.json"
```

This creates `.vibecrew/analysis/` with `stack.md`, `architecture.md`, `conventions.md`, and `gaps.md`. These docs are auto-injected into Plan phases and post-compaction context, eliminating the need to re-discover conventions each session.

---

## Step 4: Present Findings for Review

Display the analysis results to the user in a structured format:

```
--- VibeCrew Onboarding Analysis ---

Project: {project_name}
Framework: {framework} | Language: {language}
Package Manager: {package_manager}

Conventions Detected:
  Components: {component_naming}
  Imports: {import_style} {path_alias}
  Style: {quotes} quotes, {indent}, semicolons: {semicolons}
  Formatter: {formatter} | Linter: {linter}
  Commits: {commit_format}

Architecture:
  API: {api_style} | State: {state_management}
  Component Library: {component_library}
  Database: {database}

Testing:
  Framework: {test_framework} | E2E: {e2e_framework}
  Source files: {source_count} | Test files: {test_count}
  Estimated coverage: {coverage}%
  Untested modules: {untested_count}

Design System: {design_type}

Confidence: {confidence}
```

Ask the user: "Do these findings look correct? (yes / edit / cancel)"

- **If "yes"**: Continue to Step 5.
- **If "edit"**: Ask which findings to correct. Update the findings JSON accordingly. Then continue.
- **If "cancel"**: Stop onboarding.

---

## Step 5: Generate CLAUDE.md

Generate a project-specific CLAUDE.md from the findings:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate-onboard-claude-md.sh" \
  --findings ".vibecrew/onboard-findings.json" \
  --output "CLAUDE.md"
```

If a CLAUDE.md already exists, ask the user:
"A CLAUDE.md already exists. Overwrite it with the generated version? (yes / merge / keep existing)"

- **If "yes"**: Overwrite.
- **If "merge"**: Append new conventions under a "## Onboarded Conventions" section.
- **If "keep existing"**: Skip CLAUDE.md generation.

Display the generated CLAUDE.md content and ask: "Review the generated CLAUDE.md. Approve? (yes / edit)"

---

## Step 6: Initialize State

Set up the VibeCrew state for an onboarded project:

```bash
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DEFAULT_BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||' || echo "main")

jq -n \
  --arg ts "$TIMESTAMP" \
  --arg branch "$DEFAULT_BRANCH" \
  '{
    schema_version: "1.1.0",
    foundation: {
      complete: true,
      completed_at: $ts,
      artifacts: {
        vision: {status: "skipped", file: null, approved_at: null},
        design_system: {status: "skipped", file: null, approved_at: null},
        tdr: {status: "skipped", file: null, approved_at: null},
        roadmap: {status: "skipped", file: null, approved_at: null},
        claude_md: {status: "complete", file: "CLAUDE.md", approved_at: $ts}
      }
    },
    active_feature: {id: null, name: null, worktree: null, phase: null, phases_completed: []},
    git: {default_branch: $branch, initialized: true},
    onboarded: true,
    onboarded_at: $ts,
    updated_at: $ts
  }' > .vibecrew/state.json.tmp && mv .vibecrew/state.json.tmp .vibecrew/state.json
```

---

## Step 7: Pre-populate Backlog from Test Gaps

If the test gap analysis found untested modules, create backlog items:

```bash
# Read untested modules from findings
UNTESTED=$(jq -r '.test_gaps.untested_modules // []' .vibecrew/onboard-findings.json)
UNTESTED_COUNT=$(echo "$UNTESTED" | jq 'length')
```

For each untested module (up to 10), create a backlog feature:

```json
{
  "id": "feat-gap-NNN",
  "name": "Add tests for <module_name>",
  "column": "idea",
  "priority": "medium",
  "labels": ["test-gap", "onboarding"],
  "spec": {
    "description": "Add test coverage for <module_path>",
    "acceptance_criteria": [
      "Unit tests exist for all exported functions",
      "Edge cases covered",
      "Tests pass in CI"
    ]
  },
  "created_at": "ISO8601",
  "updated_at": "ISO8601"
}
```

Write to `.vibecrew/backlog.json`:

```bash
# Initialize backlog if needed
if [[ ! -f .vibecrew/backlog.json ]]; then
  cat "${CLAUDE_PLUGIN_ROOT}/templates/backlog.json.template" > .vibecrew/backlog.json
fi
```

Add each test gap feature to the backlog using the update-backlog script or direct jq mutation.

---

## Step 8: Verification

### 8.1 Verify state

```bash
jq '.foundation.complete' .vibecrew/state.json
# Should output: true

jq '.onboarded' .vibecrew/state.json
# Should output: true
```

### 8.2 Verify CLAUDE.md

```bash
test -f CLAUDE.md && echo "exists" || echo "missing"
wc -l CLAUDE.md
```

### 8.3 Verify backlog

```bash
jq '.features | length' .vibecrew/backlog.json
```

### 8.4 Print summary

```
--- VibeCrew Onboarding Complete ---

Project: {project_name}
Foundation: Complete (onboarded)
CLAUDE.md: Generated with {N} conventions
Backlog: {M} test-gap items added

Next steps:
  /plan-features — Define feature specs for your backlog
  /new-feature "name" — Start building a feature
  /status — View project state
```

---

## Rules

### Execution rules
- Execute all 8 steps sequentially. Do NOT skip steps.
- Always present findings for user review before generating CLAUDE.md.
- Never modify source code, test files, or project configuration.
- Use temp file pattern for all JSON writes.

### Safety rules
- The Code Auditor agent is read-only. Do not allow file modifications during analysis.
- Do not install dependencies or run package scripts during onboarding.
- Do not create git branches or make commits during onboarding.
- Preserve any existing `.vibecrew/` data when re-onboarding.

### Quality rules
- Every extracted convention must be verifiable (show the evidence).
- Mark confidence as "low" for any convention detected from fewer than 3 file samples.
- The generated CLAUDE.md should reflect actual project conventions, not template defaults.
- Test gap items should reference specific file paths, not generic descriptions.

### The `--refresh` flag

When invoked as `/onboard --refresh`:
1. Skip Steps 1.1 (existing check prompt), 2 (directory init), 5 (CLAUDE.md generation), 6 (state init), and 7 (backlog pre-population).
2. Re-run Step 3 (Code Auditor) to produce fresh findings.
3. Re-run Step 3.1 (generate analysis docs) to overwrite `.vibecrew/analysis/` with current data.
4. Present updated findings (Step 4) for review.
5. Run Step 8 (verification) to confirm analysis docs are current.

This is useful when the codebase has evolved significantly since the original onboarding. The session startup script warns when analysis docs are stale.

### Edge cases
- **Monorepo**: If multiple `package.json` files exist at different depths, ask the user which package to analyze.
- **No tests**: Set test_file_count to 0, skip test gap backlog items, note in findings.
- **Non-standard structure**: Adapt source directory detection. Set confidence to "low".
- **Non-Node.js**: Detect language from file extensions. Generate minimal CLAUDE.md with file structure only. Set confidence to "low".
- **Existing `.vibecrew/`**: Ask before overwriting. Preserve session history and scores.
