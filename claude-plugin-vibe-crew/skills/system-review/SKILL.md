---
name: system-review
description: Meta-level audit of VibeCrew plugin internals, cross-project telemetry analysis, and ecosystem research
disable-model-invocation: false
category: analysis
---

# /system-review

Run a comprehensive system review of the VibeCrew plugin itself. Audits internal components, analyzes cross-project telemetry, researches the Claude Code ecosystem, and produces prioritized improvement proposals. This command operates at the plugin level — it does NOT require `.vibecrew/state.json` and should be run from the VibeCrew repository.

---

## Step 1: Pre-flight Check

Verify that we're running from the VibeCrew plugin root:

```bash
test -f "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" && echo "exists" || echo "missing"
```

If the plugin manifest does not exist, output EXACTLY this and stop:

```
Not running from VibeCrew plugin. Run /system-review from the VibeCrew repository.
```

Do NOT output anything else. Do NOT create the file. Do NOT offer alternatives.

Read the plugin version:

```bash
jq -r '.version // "unknown"' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"
```

Store the version for the report header.

---

## Step 2: Check Review History

Look for previous system reviews:

```bash
ls -t "${CLAUDE_PLUGIN_ROOT}/reviews/system-review-"*.json 2>/dev/null | head -1
```

If a previous review exists:
- Read it and store as context for the System Reviewer agent (for deduplication)
- Display: "Previous review found: {filename}"
- Note the previous review's date and finding count

If no previous review exists:
- Display: "No previous reviews found. This will be the first system review."

---

## Step 3: Collect Plugin Stats

Run the plugin stats collector:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/collect-plugin-stats.sh"
```

Parse the JSON output and display:

```
Plugin Inventory
================
  Version:     {version}
  Agents:      {count}
  Skills:      {count}
  Scripts:     {count}
  Hooks:       {count}
  MCP Servers: {bundled} bundled + {registry} in registry
  Templates:   {count}
  Projects:    {registered_projects} registered
  Reviews:     {previous_reviews} previous
```

---

## Step 4: Collect Telemetry

Run the telemetry collector to aggregate fresh data from all registered projects:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/collect-telemetry.sh"
```

Parse the output and display:

```
Telemetry Collection
====================
  Projects scanned: {project_count}
  Total sessions:   {total_sessions}
  Avg Vibe Score:   {avg_vibe_score_all}
  Avg Cost/Session: ${avg_cost_per_session}
```

If 0 projects are registered, display:

```
Telemetry Collection
====================
  No projects registered yet. Run /setup in a project to enable telemetry.
```

---

## Step 5: Invoke System Reviewer Agent

Launch the System Reviewer agent in worktree isolation. Pass the following context:

1. The plugin stats JSON from Step 3
2. The telemetry aggregate JSON from Step 4 (if available)
3. The previous review JSON from Step 2 (if available)

The agent will execute its 10-step methodology and return a markdown report.

**Important:** The System Reviewer agent is read-only. It cannot modify files. You (the skill orchestrator) handle all file writes after the agent returns.

---

## Step 6: Save Report

Generate a review ID and save both JSON and markdown reports:

```bash
REVIEW_DATE=$(date -u +%Y%m%dT%H%M%S)
REVIEW_SEQ=$(ls "${CLAUDE_PLUGIN_ROOT}/reviews/system-review-"*.json 2>/dev/null | wc -l | tr -d ' ')
REVIEW_SEQ=$((REVIEW_SEQ + 1))
REVIEW_ID="SYS-REVIEW-$(date -u +%Y%m%d)-$(printf '%03d' $REVIEW_SEQ)"
```

Save the structured JSON report:
- Use the template from `${CLAUDE_PLUGIN_ROOT}/templates/system-review-report.json.template`
- Populate all fields from the agent's output
- Write to `${CLAUDE_PLUGIN_ROOT}/reviews/system-review-${REVIEW_DATE}.json` using `.tmp` + `mv` pattern

Save the markdown report:
- Write the agent's full markdown output to `${CLAUDE_PLUGIN_ROOT}/reviews/system-review-${REVIEW_DATE}.md` using `.tmp` + `mv` pattern

---

## Step 7: Deduplication

If a previous review was found in Step 2, run the diff script:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/diff-review-findings.sh" \
  "${CLAUDE_PLUGIN_ROOT}/reviews/system-review-${REVIEW_DATE}.json" \
  "${PREVIOUS_REVIEW_PATH}"
```

Parse the diff output and display:

```
Review Comparison
=================
  New findings:       {new_count}
  Recurring findings: {recurring_count}
  Resolved findings:  {resolved_count}
```

If no previous review exists, skip this step.

---

## Step 8: Display Summary

Output a formatted summary to the terminal:

```
System Review Complete
======================
Review ID:  {REVIEW_ID}
Plugin:     v{PLUGIN_VERSION}
Projects:   {project_count} registered ({total_sessions} total sessions)

--- Internal Findings ---
  Model routing:       {count} findings
  Context budgets:     {count} findings
  Pattern consistency: {count} findings
  Component usage:     {count} findings

--- Cross-Project Insights ---
  Avg Vibe Score:      {score} (across {sessions} sessions)
  Top friction:        {category} ({count} occurrences)
  Unused skills:       {list}
  Cost trend:          ${avg}/session avg

--- External Findings ---
  Anthropic updates:   {count} findings
  New MCP servers:     {count} found
  Community patterns:  {count} findings

--- Top 5 Proposals ---
  P1: {title} (effort: {estimate})
  P2: {title} (effort: {estimate})
  P3: {title} (effort: {estimate})
  P4: {title} (effort: {estimate})
  P5: {title} (effort: {estimate})

Full report: ${CLAUDE_PLUGIN_ROOT}/reviews/system-review-${REVIEW_DATE}.md
```
