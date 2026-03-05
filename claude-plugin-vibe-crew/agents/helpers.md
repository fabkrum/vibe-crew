# Agent Helpers

Shared procedures for VibeCrew agents. Agents reference these by section anchor (e.g., `helpers.md#Registration`) to avoid duplicating instructions across 14 agent files.

## Registration

Register for observability tracking as the **first action** in every agent execution:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/register-agent.sh" "<agent_name>"
```

Replace `<agent_name>` with the agent's `name` from its YAML frontmatter (e.g., `"builder"`, `"verifier"`, `"session-startup"`).

## Deregistration

Deregister as the **last action** before writing signal files or returning final output:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/deregister-agent.sh"
```

## Read User Profile

Read the user profile to adapt output behavior. Call this at the start of relevant phases:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/read-profile.sh"
```

If no profile exists or `interview_completed` is `false`, use default behavior for your agent.

**Profile dimensions:**

| Dimension | Values |
|-----------|--------|
| `code_literacy` | fluent, conversational, basic, none |
| `autonomy` | full_auto, checkpoints, collaborative, supervised |
| `pr_review` | auto_merge, summary, review, walkthrough |
| `verbosity` | minimal, standard, detailed, educational |
| `gamification_preference` | full, light, score_only, disabled |
| `learning` | none, reference_docs, inline, teach |
| `risk_tolerance` | conservative, balanced, progressive, experimental |

## Read State

Read current project state from `.vibecrew/state.json`:

```bash
jq -r '.active_feature.id // empty' .vibecrew/state.json 2>/dev/null
jq -r '.active_feature.name // empty' .vibecrew/state.json 2>/dev/null
jq -r '.active_feature.phase // empty' .vibecrew/state.json 2>/dev/null
jq -r '.foundation.complete' .vibecrew/state.json 2>/dev/null
```

## Load Architecture Diagrams

Inject pre-generated architecture diagrams into context:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/inject-architecture.sh"
```

If unavailable, read directly from `.vibecrew/architecture/`:

| File | Content |
|------|---------|
| `system.mmd` | Infrastructure topology (flowchart TD) |
| `schema.mmd` | Entity-relationship diagram (erDiagram) |
| `state-flows.mmd` | Auth states and user flows (stateDiagram-v2) |
| `api-sequences.mmd` | API request/response patterns (sequenceDiagram) |
| `component-tree.mmd` | Component hierarchy with data flow (flowchart TD) |

## Escalation on Max Turns

If `maxTurns` is reached before your task is complete:

1. Return a **partial output** with a clear status indicator (e.g., `"status": "incomplete"` or `## Status: Incomplete — N of M items analyzed`).
2. Include **all work gathered so far** — never discard partial progress.
3. Note **what remains unfinished** (files not analyzed, sections not written, decisions not evaluated).
4. The Orchestrator will decide whether to spawn a follow-up session or proceed with partial output.

**Never silently return incomplete work. Always signal when the output is partial.**

## Read-Only Agent Constraints

For agents that must not modify the codebase:

- **NEVER** use Write or Edit tools on source code, test files, or configuration files.
- **NEVER** install dependencies or modify package manifests (`package.json`, `requirements.txt`, `Gemfile`, etc.).
- **NEVER** run commands that modify the filesystem (builds, installs, formatters).
- **NEVER** create or delete branches, commit, or push.
- Only use Bash for read-only commands: `cat`, `ls`, `find`, `grep`, `wc`, `jq`, `git log`, `git status`, `git diff`, `git show`.
- The **only write** permitted is your designated output file (report, review, audit, simplification) in `.vibecrew/`.

## Budget Discipline

Follow this context window discipline regardless of your specific budget percentage:

- Read files on demand — do not pre-read the entire codebase.
- Use Context7 for library documentation instead of pasting docs.
- Use targeted grep/search patterns before reading full files.
- Summarize findings as you go — do not accumulate raw data.
- If approaching your budget limit: finalize current work, write any signal/report files, and stop.
- The Orchestrator handles continuation if needed.

## Expertise Integration

### Prime Expertise Context

Load relevant expertise records before starting work:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/expertise-prime.sh" --agent <agent_name>
```

### Write Expertise Records

Record significant discoveries or failures for future sessions:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/expertise-write.sh" \
  --domain "<domain>" --type "<type>" --tier "<tier>" \
  --content "<what was learned>" \
  --context "<feature and context>" \
  --outcome "<success|failure>" --confidence "<0.0-1.0>" \
  --session-id "<session_id>" --feature-id "<feature_id>" \
  --source-agent "<agent_name>"
```

## Signal File Format

Write signal files to `.vibecrew/signals/` on phase completion. Standard format:

```json
{
  "feature_id": "{id}",
  "agent": "{agent_name}",
  "status": "complete",
  "phase": "{phase}",
  "timestamp": "{ISO 8601}",
  "branch": "{branch_name}",
  "commit": "{head_commit_sha}"
}
```

Populate `changed_files` (if applicable) by running:

```bash
git diff --name-status HEAD~$(git rev-list --count origin/main..HEAD) -- | awk '{print "{\"path\":\"" $2 "\",\"type\":\"" ($1=="A"?"added":($1=="M"?"modified":"deleted")) "\"}"}' | jq -s '.'
```

If the git command fails, omit the `changed_files` field — the Verifier will fall back to `git diff`.

## Phase Advancement

After completing a phase and writing the signal file:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/complete-phase.sh" "<feature_id>" "<phase>"
```
