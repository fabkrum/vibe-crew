# Clarify Checklist

> Evaluate each question against the feature spec and plan. Flag only genuinely ambiguous items — typically 2-5 for standard features, 0-1 for well-specified ones.

## Decision Categories

Classify every decision into one of three categories:

| Category | Meaning | Who decides | Code phase behavior |
|----------|---------|-------------|---------------------|
| **Locked** | Explicitly specified in spec, TDR, design brief, or user answer. Cannot be changed without spec revision. | User / Spec | Follow exactly. Any deviation requires plan revision. |
| **Deferred** | Intentionally left open for later. Not needed for current implementation or depends on future information. | N/A (revisit later) | Skip. Do not implement or assume. Add a `TODO(deferred)` comment at the decision point. |
| **Discretion** | Not specified and not worth blocking on. Builder picks the best option based on conventions, TDR, and design system. | Builder (auto-resolved) | Builder chooses. Document the choice with rationale. Reviewable but not blocking. |

**Classification rules:**
- If the spec says it → **Locked**
- If the spec says "TBD", "later", or "phase 2" → **Deferred**
- If the spec is silent and the answer doesn't affect acceptance criteria → **Discretion**
- If the spec is silent and the answer DOES affect acceptance criteria → ask the user (then classify as **Locked**)

## 1. Layout & Navigation

- Where does this feature appear in the app's navigation? (new sidebar item, nested under existing, top-level route, modal/drawer over current page?)
- Is this a full page, a modal/dialog, a panel/drawer, or an inline section within an existing page?
- What happens when the user presses Back or Escape? (navigate away, close overlay, discard changes with confirmation?)
- Does this feature introduce a new URL route? If so, what is the route pattern?

## 2. Data & State

- Where does the data come from? (existing API endpoint, new endpoint needed, local state only, external service?)
- What should the UI show for empty state? (illustration + CTA, simple message, redirect?)
- What should the UI show during loading? (skeleton, spinner, progressive rendering?)
- Is pagination or infinite scroll needed? If so, what page size?
- What happens on network error? (toast, inline error, retry button, fallback data?)

## 3. Content & Copy

- What specific text should buttons, labels, and headings display? (e.g., "Save" vs "Save Changes" vs "Update Profile")
- How should dates, numbers, and currencies be formatted? (relative time, absolute, locale-specific?)
- Does this feature need internationalization (i18n) support?
- Are there any placeholder or helper texts needed for form fields?

## 4. Interaction Design

- What is the primary action on this screen? (the one button/CTA that should be visually dominant)
- Do any actions require confirmation? (delete, cancel subscription, irreversible operations)
- When should validation run? (on blur, on submit, real-time as user types?)
- What happens after the primary action succeeds? (redirect, toast, inline success state, close modal?)

## 5. Business Logic

- Who can access this feature? (all users, specific roles, subscription tiers, feature flags?)
- Are there rate limits, quotas, or usage caps to enforce?
- What are the boundary values? (max items, character limits, file size limits, date ranges)
- What happens at the boundaries? (graceful degradation, hard block, upgrade prompt?)

## 6. Integration

- Does this feature affect any existing features? (sidebar counts, notification badges, dashboard stats, search results?)
- Does this feature need to emit events or webhooks for other systems?
- Are database schema migrations required? If so, are they backwards-compatible?
- Does this feature depend on any third-party API or service not yet in the TDR?
