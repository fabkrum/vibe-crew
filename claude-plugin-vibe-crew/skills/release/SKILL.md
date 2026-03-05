---
name: release
description: Bump version, regenerate release notes, commit, and tag a new release
disable-model-invocation: false
category: workflow
---

# VibeCrew Release: Automated Version Release

You are executing the VibeCrew `/release` command. This automates the full release process: version bump across all files, release notes regeneration from CHANGELOG.md, git commit, and git tag. Execute each step sequentially. Do NOT skip steps.

---

## Step 1: Pre-flight

### 1.1 Read current version

```bash
jq -r '.version' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"
```

Store the current version. Display it to the user:
"Current version: vX.Y.Z"

### 1.2 Determine new version

The new version is passed as the argument to `/release` (e.g. `/release 1.6.0`).

If no argument was provided, ask the user:
"What version should this release be? (current: vX.Y.Z)"

### 1.3 Validate semver format

The version must match the pattern `X.Y.Z` where X, Y, Z are non-negative integers. If invalid, tell the user and stop.

### 1.4 Check for uncommitted changes

```bash
git status --porcelain
```

If there are uncommitted changes, warn the user:
"Warning: You have uncommitted changes. They will be included in the release commit."

---

## Step 2: Bump version

Run the bump-version script to update all 5 locations where the version appears:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/bump-version.sh" "<new_version>"
```

This updates:
- `.claude-plugin/plugin.json` (version field)
- `agents/session-startup.md` (banner string)
- `docs/index.html` (hero badge + release card)
- `CLAUDE.md` (Current Status section)
- `CHANGELOG.md` (renames `[Unreleased]` heading if present, adds link reference)

Display the script output to the user.

---

## Step 3: Generate releases.html

Regenerate the release notes page from CHANGELOG.md:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate-releases-html.sh"
```

Display the script output to the user.

---

## Step 4: Git commit

Stage all changed files and create a release commit:

```bash
git add \
  "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" \
  "${CLAUDE_PLUGIN_ROOT}/agents/session-startup.md" \
  "${CLAUDE_PLUGIN_ROOT}/CHANGELOG.md" \
  "docs/index.html" \
  "docs/releases.html" \
  "CLAUDE.md"
```

```bash
git commit -m "release: v<new_version>"
```

If additional files were modified (e.g. from uncommitted changes), do NOT stage them — only stage the 6 release-related files.

---

## Step 5: Git tag

Create an annotated git tag:

```bash
git tag -a "v<new_version>" -m "Release v<new_version>"
```

If the tag already exists, skip this step and inform the user:
"Tag v<new_version> already exists, skipping."

---

## Step 6: Summary

Print a summary:

```
Release v<new_version> complete!

Files updated:
  - .claude-plugin/plugin.json
  - agents/session-startup.md
  - docs/index.html
  - docs/releases.html
  - CLAUDE.md
  - CHANGELOG.md

Commit: <short hash>
Tag: v<new_version>

To publish: git push origin main --tags
```

Do NOT auto-push. The user decides when to push.
