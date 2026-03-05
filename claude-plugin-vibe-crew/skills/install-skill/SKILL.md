---
name: install-skill
description: Manually install a companion Claude Code skill from any source
disable-model-invocation: true
category: utility
---

# Install Companion Skill

Manually install a Claude Code skill from any source — GitHub repos, local paths, or company-internal repositories. Validates safety before installation.

## Usage

```
/install-skill <source>
/install-skill https://github.com/my-company/internal-skills --skill our-api-patterns
/install-skill /path/to/local/skill
/install-skill my-company/codebase-conventions
```

## Step 1: Parse Source

Extract the source argument from the user's command. Determine the source type:

- **GitHub URL**: `https://github.com/<org>/<repo>` — extract org and repo name
- **GitHub shorthand**: `<org>/<repo>` — expand to full URL
- **Local path**: `/path/to/skill` or `./relative/path` — resolve to absolute path
- **With --skill flag**: Extract the specific skill name from a multi-skill repo

If no source argument is provided, list installed skills:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/recommend-companion-skills.sh" --detect-only
```
Display the installed list and exit.

## Step 2: Fetch Skill Content

For **remote sources**:
1. If the source is a GitHub URL or shorthand, verify the repository exists.
2. Check for a SKILL.md file at the repo root (or in the `--skill` subdirectory if specified).
3. If no SKILL.md is found, inform the user: "No SKILL.md found at <source>. This may not be a Claude Code skill."

For **local paths**:
1. Verify the path exists and contains a SKILL.md file.
2. If within the project root, mark as trusted (skip quality gate in Step 3).

## Step 3: Validate Safety

Run the quality gate:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/validate-skill-safety.sh" "<source>"
```

Parse the JSON output and present the validation report:

### Trusted author + all gates pass
> "Skill **{name}** from **{author}** validated successfully.
> Stars: {stars} | License: {license} | Size: {size}KB
> Install this skill?"

### Unknown author + all gates pass
> "Skill **{name}** passes safety checks but is from an unverified author ({author}).
> Review the source: {source_url}
> Stars: {stars} | License: {license} | Size: {size}KB
> Install anyway?"

### Any gate fails
> "Skill **{name}** failed safety validation:
> - {warning_1}
> - {warning_2}
> Install anyway? (not recommended)"

### Local path within project root
Skip the quality gate entirely — the user owns these files.
> "Local skill **{name}** detected. Install?"

Wait for user confirmation before proceeding.

## Step 4: Install Skill

If the user approves:

For **remote skills** (GitHub):
```bash
npx skills add <source>
```
If `--skill` was specified:
```bash
npx skills add <source> --skill <skill-name>
```

For **local paths**:
```bash
mkdir -p ".claude/skills/$(basename <path>)"
cp -r "<path>/." ".claude/skills/$(basename <path>)/"
```

If the install command fails, show the error output and suggest:
- Check that `npx` is available
- For private repos, ensure `gh auth login` has been run
- For local paths, check file permissions

## Step 5: Register in Config

Read the current config and add the skill to the `companion_skills.manual` array:

```bash
jq --arg name "<skill-name>" \
   --arg source "<source>" \
   --arg verdict "<pass|fail>" \
   '.companion_skills.manual += [{
     name: $name,
     source: $source,
     installed_at: (now | todate),
     safety_verdict: $verdict
   }]' .vibecrew/config.json > .vibecrew/config.json.tmp && \
mv .vibecrew/config.json.tmp .vibecrew/config.json
```

If `.vibecrew/config.json` doesn't exist or doesn't have the `companion_skills` key, create it:
```bash
jq '. + {companion_skills: {detected: {}, manual: [], last_checked: null}}' \
  .vibecrew/config.json > .vibecrew/config.json.tmp && \
mv .vibecrew/config.json.tmp .vibecrew/config.json
```

## Step 6: Confirm

Print confirmation:

```
Skill installed: {name}
Source: {source}
Location: .claude/skills/{name}/
Safety: {verdict}

This skill will be active in all future Claude Code sessions for this project.
```

If the skill has an `agent_adaptation` field in the companion-skills registry, note:
"VibeCrew agents will adapt their behavior to work alongside this skill."

---

## Rules

- ALWAYS run the safety validation for remote skills (Step 3). Never skip it.
- For local paths within the project root, trust implicitly — the user owns them.
- For local paths outside the project root, run the safety validation.
- If the user declines installation after seeing the validation report, respect their decision and exit.
- Never modify any project source files during installation.
- Use `${CLAUDE_PLUGIN_ROOT}` for all references to plugin scripts.
