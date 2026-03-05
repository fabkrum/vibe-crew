# Agent Observability & Self-Improvement

Architecture doc for VibeCrew's agent-level observability pipeline.

## Overview

Three-stage pipeline: **Capture** (hooks log agent-tagged tool calls), **Aggregate** (wrap-time scripts compute per-agent summaries), **Improve** (expertise records feed back into agent context).

## Data Flow

```
RUNTIME (per tool call, ~5ms overhead)
  drift-tracker.sh reads active-agent.json → appends JSONL line to agent-logs/

WRAP TIME (once per session)
  collect-agent-metrics.sh → per-agent metrics from JSONL
  generate-agent-report.sh → enriches session log agents[]
  analyze-agent-effectiveness.sh → cross-session inefficiency detection
  Performance Coach → agent-level mutations via expertise records

DASHBOARD (live reload)
  agent-logs.data.ts → reads JSONL + session metrics
  AgentInsightsPanel.vue → efficiency charts, heatmaps, alerts
  SessionLogbookEntry.vue → per-agent breakdown in logbook
```

## Agent Identity

Agents register at start and deregister at end via `scripts/register-agent.sh` / `scripts/deregister-agent.sh`. Identity is stored in `.vibecrew/locks/active-agent.json`:

```json
{
  "agent": "builder",
  "started_at": "2026-03-05T14:00:00Z",
  "pid": 12345,
  "session_id": "session-2026-03-05-001",
  "feature_id": "feat-001",
  "phase": "code"
}
```

Library: `scripts/lib/agent-identity.sh` — `register_agent`, `deregister_agent`, `read_active_agent`.

Worktree agents resolve `PROJECT_ROOT` to the worktree root, isolating their identity file from inline agents.

## JSONL Tool Call Log

One line per tool call (~180 bytes), appended by `drift-tracker.sh`:

```json
{"ts":"2026-03-05T14:23:01Z","agent":"builder","tool":"Write","target":"src/Auth.tsx","exit":0,"class":"progress","phase":"code","feat":"feat-001"}
```

Location: `.vibecrew/agent-logs/session-{id}.jsonl`. Pruned to `max_log_files` during `/wrap`.

## Per-Agent Metrics

`collect-agent-metrics.sh` aggregates JSONL into:

| Metric | Description |
|--------|-------------|
| `total_tool_calls` | Total calls by this agent |
| `progress_calls` | Calls classified as progress (Write, Edit, successful Bash) |
| `exploration_calls` | Calls classified as exploration (Read, Glob, Grep) |
| `efficiency_ratio` | `progress_calls / total_tool_calls` |
| `repeated_reads` | Files read more than once |
| `tools_used` | Breakdown by tool type |

## Inefficiency Detection

`analyze-agent-effectiveness.sh` reads last 10 session logs and flags:

| Pattern | Trigger | Impact |
|---------|---------|--------|
| `repeated_reads` | Agent reads same file 3+ times in 3+ sessions | ~12 wasted calls/session |
| `excessive_exploration` | Write-heavy agent efficiency < 0.20 in 3+ sessions | Low progress rate |
| `high_failure_rate` | Failed calls > 15% in 3+ sessions | Build/test loops |
| `tool_concentration` | Single tool > 60% of calls in 3+ sessions | Possible stuck loop |

## Self-Improvement Loop

1. Pattern detected by `analyze-agent-effectiveness.sh`
2. Performance Coach writes `performance` expertise record
3. Next session: `expertise-prime.sh` injects record into agent context
4. Agent adjusts behavior
5. Pattern resolves → expertise record marked `success`

## Vibe Score Integration

| Condition | Impact |
|-----------|--------|
| Write-heavy agent efficiency < 0.20 for 3+ sessions | -3 |
| All agents above baseline for 3+ sessions | +2 |

## Configuration

In `.vibecrew/config.json` under `agent_observability`:

```json
{
  "enabled": true,
  "log_tool_calls": true,
  "max_log_files": 50,
  "efficiency_thresholds": {
    "write_agents": 0.20,
    "min_sessions": 3
  },
  "self_improvement": true
}
```

## Files

| File | Type | Purpose |
|------|------|---------|
| `scripts/lib/agent-identity.sh` | bash lib | Identity management |
| `scripts/register-agent.sh` | bash | Register active agent |
| `scripts/deregister-agent.sh` | bash | Deregister active agent |
| `scripts/collect-agent-metrics.sh` | bash | JSONL → per-agent metrics |
| `scripts/generate-agent-report.sh` | bash | Merge metrics into session log |
| `scripts/analyze-agent-effectiveness.sh` | bash | Cross-session pattern detection |
| `templates/agent-log-entry.json.template` | template | JSONL entry schema |
| `templates/docs-site/data/agent-logs.data.ts` | VitePress | Dashboard data loader |
| `templates/docs-site/components/AgentInsightsPanel.vue` | VitePress | Dashboard panel |
| `templates/docs-site/agent-insights.md` | VitePress | Dashboard page |
