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

## Load Agent With Overrides

When delegating to an agent, check for user-defined overrides that customize agent behavior per-project. Override files live in `.vibecrew/agent-overrides/<agent>.md` and survive plugin updates.

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/load-agent-with-overrides.sh" "<agent_name>"
```

**Merge rules:**
- Override sections with matching `## Heading` names **replace** the base section entirely.
- Override sections with new headings are **appended** after all base sections.
- The YAML frontmatter from the base file is always preserved (overrides cannot change model, tools, or isolation).
- If no override file exists, the base agent prompt is used as-is.

## Agent Memory Integration

Agents accumulate knowledge across sessions in `.vibecrew/memory/<agent>/`. Memory complements expertise records — expertise captures domain knowledge; agent memory captures agent-specific operational patterns.

### Read Agent Memory

Load relevant memory before starting work:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/agent-memory-read.sh" --agent "<agent_name>"
```

To read a specific domain:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/agent-memory-read.sh" --agent "<agent_name>" --domain "<domain>"
```

### Write Agent Memory

Record significant discoveries for future sessions:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/agent-memory-write.sh" \
  --agent "<agent_name>" --domain "<domain>" \
  --content "<what was learned>" --ttl 90
```

**When to write memory:**
- Builder: API patterns, code conventions discovered, integration gotchas
- Verifier: flaky tests, common failure patterns, environment issues
- Stack Scout: library gotchas, version conflicts, migration notes
- Code Reviewer: recurring issues, project-specific conventions

**TTL defaults:** 90 days. Use shorter TTL (30) for volatile patterns, longer (180) for stable conventions.

**Size limits:** 50 entries per domain, 100KB per file. Oldest entries pruned automatically.

## Code Quality Standards

These standards apply to ALL code generated by VibeCrew agents. Both the Builder (generation) and Code Reviewer (enforcement) reference this section.

### TypeScript First

- Always use TypeScript for JavaScript projects. Never create `.js`/`.jsx` files when the project supports TypeScript (detect via `tsconfig.json`).
- No `any` types. Use `unknown` + type narrowing if the type is truly dynamic. Exception: when fighting incomplete third-party typings, use `any` with an `// eslint-disable-next-line` + comment explaining why.
- Prefer explicit return types on exported functions.

### Readability Over Cleverness

- **Clarity and conciseness over verbosity.** Every function should be immediately understandable from its name, signature, and structure. Do not generate excessive wrappers, boilerplate, or redundant intermediate variables to appear "readable" — that is verbosity, not clarity.
- Prefer simple, explicit code over clever one-liners. A 5-line `if/else` is better than a nested ternary.
- No clever tricks: no bitwise operators for math (`~~x`, `x | 0`), no comma operators, no void operators for side effects.
- If a line requires a comment to explain WHAT it does, rewrite the line to be self-explanatory.
- **No echo comments.** Never generate comments that restate the code (`// increment counter` above `counter++`). Comments that add no information beyond what the code already says are noise.

### Function Design

- **One task per function.** If you can describe what it does using "and", split it into two functions. This is the primary quality signal — not line count. A 50-line function that does one thing with flat nesting is better than 5 scattered 10-line functions you must mentally reassemble.
- **Max 3 parameters.** Beyond 3, use an options object with destructuring: `function createUser({ name, email, role }: CreateUserOptions)`. Every options object MUST have a defined TypeScript interface — never pass untyped objects.
- **Max 3 levels of nesting.** Use early returns and guard clauses to flatten logic. A `for` with an `if` inside (2 levels) is normal code. The third level is where readability degrades — refactor if you hit 4.
- **Pure by default.** Isolate side effects (API calls, mutations, logging) at system boundaries. Business logic should be pure.
- **Early returns** over nested conditionals. Guard clauses at the top; happy path at the lowest indentation level.

### Naming Conventions

- **Functions**: `verb + noun` — `fetchUser`, `validateEmail`, `renderCard`, `handleSubmit`.
- **Variables**: descriptive nouns, no abbreviations — `userEmail` not `ue`, `remainingAttempts` not `ra`.
- **Booleans**: `is/has/can/should` prefix, always affirmative — `isValid` not `isInvalid`, use `!isValid` at call sites.
- **Constants**: `SCREAMING_SNAKE_CASE` — `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS`.
- **Components**: `PascalCase` describing what it renders — `UserProfile`, `PaymentForm`.
- **Hooks**: `use` + descriptive — `useAuth`, `useDebounce`, `useLocalStorage`.
- **Event handlers**: `handle + event` — `handleClick`, `handleSubmit`, `handleFilterChange`.
- **Prefer specific names over generic ones.** `userEmail` over `data`, `orderTotal` over `result`. Idiomatic library destructuring is acceptable (`const { data, error } = useSWR(...)`).
- **No single-letter variables** except `i`/`j` in short loops (<5 lines).
- **Include units** when relevant: `timeoutMs`, `fileSizeBytes`, `maxRetryCount`.

### Error Handling

- **Only catch errors you can handle.** Let others propagate to error boundaries or top-level handlers. A catch block that just `console.error`s and continues is hiding bugs.
- **No empty catch blocks.** Every catch must either recover, re-throw, or report to the user.
- **Use specific error messages with context.** Throw `new Error(\`Order ${orderId} not found\`)` not `new Error("something went wrong")`. Use custom error classes only when callers need to distinguish error types programmatically.
- **No fire-and-forget promises.** Every promise must be `await`ed or explicitly handled. A missing `await` is a silent bug that passes all tests until production.

### Async Discipline

- **Prefer `async/await`** over `.then()` chains for readability.
- **No `async` on functions that don't `await`.** An `async` function without `await` misleadingly wraps the return in a Promise.

### Tests and Linting

- **Failing tests must be fixed immediately.** Never leave a failing test and move on. If a test breaks during implementation, stop current work and fix it before continuing.
- **Linting must be 100% clean.** Zero warnings, zero errors. Run `lint --fix` first, then manually fix remaining issues. Max 3 fix attempts per lint error — if still failing after 3 tries, escalate to the user. Never enter a jitter loop destroying business logic to satisfy a linter rule.
- **Every exported function with logic or side effects has at least one meaningful test.** Simple re-exports, type guards, and trivial one-line getters don't need tests. Every acceptance criterion has at least one test.

### Test Quality

- **Only mock external boundaries.** Mock third-party APIs, databases, filesystem, and network calls. Never mock the code under test or internal modules — that creates circular validation where flawed code passes flawed tests.
- **Test observable behavior, not implementation details.** Assert on return values, state changes, DOM output, and API calls — not on which internal functions were called or in what order. Tests that assert `toHaveBeenCalledWith()` on internal functions break on every refactor and prove nothing about correctness.
- **Each test must be able to fail.** If a test can never fail (e.g., asserting `toBeDefined()` on a hardcoded value, or asserting on a fully mocked return), it provides zero safety. Every assertion must exercise real logic.

### Import Hygiene

- **No wildcard imports.** Import what you use: `import { Button, Card } from './components'` not `import * as Components from './components'`.
- **No `export *` re-exports.** `export * from './components'` causes bundle bloat and hides what's actually exported. Barrel files with named exports are fine: `export { Button, Card, Dialog } from './components'`.
- **Consistent import style.** Follow the project's existing pattern (absolute vs relative, import ordering).

### Codebase Consistency

- **Follow existing patterns above all.** Before writing new code, read the surrounding codebase for conventions. If the project uses functional components, never introduce a class component. If it uses `async/await`, don't add `.then()` chains. If it uses a specific state management pattern, follow it.
- **Never introduce a new paradigm without explicit justification.** Adding a new library, pattern, or convention to an existing codebase requires a reason beyond personal preference.

### Code Simplicity

- **No premature abstractions.** Rule of Three — tolerate duplication until the 3rd occurrence, then extract. But never duplicate business logic across distant files. If the same logic appears in two separate modules, extract into a shared utility immediately — scattered duplication causes silent bugs when updates miss a copy.
- **No unnecessary wrappers.** If a wrapper adds no logic beyond delegation, inline it.
- **No design patterns for simple problems.** Factory, Strategy, Observer — only when complexity genuinely warrants them.
- **No magic numbers or strings.** All literals used more than once must be named constants.
- **Comments explain WHY, never WHAT.** Delete comments that restate the code. If the code needs a WHAT comment, rewrite the code.
- **Use framework conventions.** Don't reimplement what the framework provides (routing, validation, error boundaries, data fetching).

### Review Checklist

When reviewing code (used by Code Reviewer Step 5.5), check for these violations:

| # | Check | Severity |
|---|---|---|
| 1 | `.js`/`.jsx` files in TypeScript projects | `critical` |
| 2 | `any` types without justification comment | `warning` |
| 3 | Missing return types on exported functions | `info` |
| 4 | Clever one-liners, bitwise tricks, nested ternaries | `warning` |
| 5 | Excessive verbosity, echo comments | `warning` |
| 6 | Functions doing multiple tasks (describable with "and") | `warning` |
| 7 | Functions with 4+ parameters without options object | `warning` |
| 8 | Options objects without TypeScript interface | `warning` |
| 9 | Nesting deeper than 3 levels | `warning` |
| 10 | Abbreviations unless universal (`url`, `id`, `api`) | `warning` |
| 11 | Booleans without `is/has/can/should` prefix | `warning` |
| 12 | Functions without `verb + noun` pattern | `warning` |
| 13 | Single-letter variables outside short loops | `warning` |
| 14 | Generic names when specific alternative exists | `warning` |
| 15 | Empty catch blocks or catch-and-console.error-only | `warning` |
| 16 | Fire-and-forget promises (missing `await` without `void`) | `critical` |
| 17 | Generic error messages without context | `warning` |
| 18 | `async` functions that never `await` | `warning` |
| 19 | `.then()` chains in async/await codebase | `warning` |
| 20 | Failing tests | `critical` |
| 21 | Missing tests for exported functions with logic | `warning` |
| 22 | Missing tests for acceptance criteria | `critical` |
| 23 | Tests mocking internal modules or code under test | `warning` |
| 24 | Tests asserting implementation details not behavior | `warning` |
| 25 | Shallow tests that can never fail | `warning` |
| 26 | Lint warnings or errors | `critical` |
| 27 | Wildcard imports | `warning` |
| 28 | `export *` re-exports (named barrel exports are fine) | `warning` |
| 29 | New paradigms diverging from codebase conventions | `warning` |
| 30 | Premature abstractions (single-use wrappers) | `warning` |
| 31 | Scattered duplication across distant files | `warning` |
| 32 | Unnecessary design patterns for simple problems | `warning` |
| 33 | Magic numbers or strings | `warning` |

Category for all review findings: `"code-quality"`.

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
