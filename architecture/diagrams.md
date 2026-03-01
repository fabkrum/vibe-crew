# Mermaid Architecture Diagrams

## Purpose

Architecture diagrams are the 6th Tier 1 foundation artifact. They provide agents with a compact visual representation of the project's architecture at a fraction of the token cost of reading full-text documents.

**Token efficiency:** All 5 `.mmd` files together are typically 250-600 tokens, compared to the TDR (2,000-5,000 tokens) and VISION.md (500-1,500 tokens) they distill.

## Diagram Types

### 1. System Architecture (`system.mmd`)

**Syntax:** `flowchart TD`

Infrastructure topology showing service boundaries: Client → Edge → Application → Data → External. Subgraphs group related services. Technology names from the TDR replace placeholders.

### 2. Database Schema (`schema.mmd`)

**Syntax:** `erDiagram`

Entity-relationship diagram showing entities, attributes, relationships, and cardinality. Starts with a `User` entity; domain entities are added from VISION.md personas and core features. Updated when migrations or models change.

### 3. Application State & User Flows (`state-flows.mmd`)

**Syntax:** `stateDiagram-v2`

State machine covering authentication states and primary user journeys derived from VISION.md personas. Updated when auth flows or state logic changes.

### 4. API Interactions (`api-sequences.mmd`)

**Syntax:** `sequenceDiagram`

Request/response patterns for authentication, primary CRUD operations, SSR flows, and third-party integrations. Updated when routes, API endpoints, or middleware change.

### 5. Component Tree (`component-tree.mmd`)

**Syntax:** `flowchart TD`

React/Vue/Svelte component hierarchy with data flow direction (props ↓, events ↑). **Unique lifecycle:** skeleton generated in Tier 1 from the TDR framework choice (App → Layout → Header/Main/Footer), then extended by the Builder during each Tier 2 feature as new components are added.

## Lifecycle

### Generation (Tier 1)

1. After the roadmap is approved and before CLAUDE.md is generated, the Workflow Orchestrator triggers diagram generation.
2. Templates from `${CLAUDE_PLUGIN_ROOT}/templates/architecture-diagrams/` are populated using:
   - VISION.md — user personas, core features, domain entities
   - TDR — technology choices, framework, database, auth provider
   - Roadmap — feature scope for user flow estimation
3. Five `.mmd` files are written to `.vibecrew/architecture/`.
4. The user approves, edits, or skips. State is recorded in `state.json` as `architecture_diagrams.status`.

### Context Injection

After routing is determined, the **Workflow Orchestrator** runs `inject-architecture.sh` to concatenate all 5 diagrams into a single context block. This gives every downstream agent (Builder, Code Reviewer, Doc Generator) instant architectural awareness without each loading diagrams independently. The script is also called by `compact-reinject.sh` so diagrams survive context compaction.

### Updates (Tier 2)

During each feature development cycle:

- **Builder** references the diagrams already in context (pre-loaded by the Orchestrator via `inject-architecture.sh`) for implementation context. After adding new components, the Builder updates `component-tree.mmd` and notes diagram deviations via the `Diagram-Drift:` commit trailer.
- **Doc Generator** checks diagram freshness during `/wrap` using the same drift detection logic as feature docs. Stale diagrams are updated automatically.
- **Code Reviewer** checks diagram consistency as a `warning`-level finding (not critical).

### Stale Detection Rules

| Diagram | Triggers staleness when... |
|---------|---------------------------|
| `schema.mmd` | Migration, model, or schema files change |
| `api-sequences.mmd` | Route, API, or middleware files change |
| `state-flows.mmd` | Auth, state machine, or workflow files change |
| `system.mmd` | Infrastructure config, deployment, or service integration files change |
| `component-tree.mmd` | Component files are added, renamed, deleted, or re-parented |

## Agent Consumption Matrix

| Agent | Reads | Writes | Purpose |
|-------|-------|--------|---------|
| Workflow Orchestrator | All 5 (via `inject-architecture.sh`) | — | Pre-loads diagrams into agent context after routing; coordinates generation during Tier 1 |
| Builder | All 5 | `component-tree.mmd` | Implementation context; extends component tree |
| Code Reviewer | All 5 | — | Consistency checks vs actual code |
| Doc Generator | All 5 | All 5 | Freshness detection and stale diagram updates |
| Security Auditor | `system.mmd`, `api-sequences.mmd` | — | Topology and data flow context for OWASP scan |
| Performance Coach | — | — | Documentation drift anti-pattern includes diagrams |

## Storage

```
.vibecrew/architecture/
  system.mmd              # Infrastructure topology
  schema.mmd              # Entity-relationship diagram
  state-flows.mmd         # Authentication and user flow states
  api-sequences.mmd       # Request/response sequence patterns
  component-tree.mmd      # Component hierarchy with data flow
```

## Vibe Score Integration

| Condition | Score Impact |
|-----------|-------------|
| Architecture diagram stale after code changes | -3 per stale diagram (via `doc-drift` deduction) |
| All diagrams current after code changes | Contributes to `all-phases` bonus eligibility |

Stale architecture diagrams count toward the existing `stale_docs` metric (capped at -9 total across all stale docs).

## Token Budget Comparison

| Artifact | Typical Tokens | Purpose |
|----------|---------------|---------|
| VISION.md | 500-1,500 | Product vision, personas, success criteria |
| TDR | 2,000-5,000 | Technology decisions with rationale |
| All 5 diagrams | 250-600 | Visual architecture summary of both |

Agents that need quick architectural context can read the 5 diagrams instead of re-reading the full TDR and VISION.md, saving 2,000-6,000 tokens per session.
