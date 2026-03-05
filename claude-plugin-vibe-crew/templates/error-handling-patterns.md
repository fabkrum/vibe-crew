# Error Handling Pattern Reference

Agent-facing reference for error boundaries, network resilience, error pages, empty states, and offline support.
The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Every error state should explain what happened, reassure the user, and offer a clear next action.

## 1. Error Boundaries

### Component Error Boundary
- **When:** Every route-level component and any component making async calls.
- **What:** Wrap in an error boundary that catches rendering errors. Show a fallback UI with the error context and a retry/reset button. Log the error to an error tracking service (Sentry, LogRocket, etc.).
- **React:** Use `ErrorBoundary` component (class-based or `react-error-boundary` library). Provide `fallbackRender` with reset function.
- **A11y:** Fallback UI must be keyboard-accessible. Focus the error message on render.
- **Anti-pattern:** Never show a white screen on error. Never show raw stack traces to users.

### Granular Boundaries
- **When:** Page has independently-functioning sections (sidebar, main content, widgets).
- **What:** Wrap each section in its own error boundary. A failing widget shouldn't crash the entire page.
- **Rule:** At minimum, wrap: (1) the root layout, (2) each route/page, (3) any data-fetching widget.

### Error Logging
- **When:** Every caught error.
- **What:** Log error type, message, component stack, user context (ID, page, action). Rate-limit to avoid flooding. Include breadcrumbs (last 5 user actions).
- **Anti-pattern:** Never swallow errors silently (empty `catch {}`). Never log sensitive data (passwords, tokens, PII).

## 2. Network & API Errors

### Timeout Handling
- **When:** Any API call.
- **What:** Set a request timeout (5-10 seconds for data, 30 seconds for uploads). Show a specific "Request timed out" message with a retry button.
- **Anti-pattern:** Never let requests hang indefinitely. Never show "Unknown error" for timeouts.

### Retry with Exponential Backoff
- **When:** Transient network failures (5xx, timeout, network error).
- **What:** Retry up to 3 times with exponential backoff (1s → 2s → 4s). Add jitter (±20%) to avoid thundering herd. Show retry status to user.
- **Anti-pattern:** Never retry 4xx errors (client errors). Never retry without backoff. Never retry indefinitely.

### Offline Detection
- **When:** Any app that makes API calls.
- **What:** Listen to `navigator.onLine` and the `offline`/`online` events. When offline, show a persistent banner. Disable actions that require network.
- **Anti-pattern:** Never fail silently when offline. Never show network errors for known offline state.

### Mutation Queue
- **When:** User performs actions while offline.
- **What:** Queue mutations in localStorage or IndexedDB. Replay on reconnect in order. Show sync status. Handle conflicts (last-write-wins or prompt user).
- **Anti-pattern:** Never discard user actions because of temporary offline state.

## 3. HTTP Error Pages

### 404 — Not Found
- **What:** Friendly page with: (1) clear "Page not found" message, (2) search bar, (3) links to popular pages, (4) "Go home" button. Auto-redirect after 10s (optional).
- **Tone:** Apologetic, not blaming. "We can't find that page" not "You entered a wrong URL".
- **A11y:** Proper heading hierarchy. Focus management on page load.

### 500 — Server Error
- **What:** Apology page with: (1) "Something went wrong" message, (2) retry button, (3) status page link, (4) support contact. Show a reference ID for support tickets.
- **Anti-pattern:** Never show stack traces. Never suggest the user did something wrong.

### 403 — Forbidden
- **What:** Explain why access is denied. If auth is needed, show a login button. If the resource doesn't exist for this user, show a helpful message.
- **Anti-pattern:** Never reveal whether the resource exists (security — treat 403 like 404 for sensitive resources).

### Maintenance Page
- **What:** Show estimated time of return (ETA), link to status page, option to get notified when back. Style it consistently with the rest of the app.

## 4. Empty States

### First Use (No Data Yet)
- **When:** User has no items in a collection (no projects, no messages, no orders).
- **What:** (1) Illustration or icon, (2) brief explanation of what will appear, (3) primary CTA button to create the first item. Make the CTA the most prominent element.
- **Why:** Fogg Behavior Model — capitalize on motivation by reducing friction to the first action.
- **Anti-pattern:** Never show a blank page. Never show only "No data".

### No Results (Search/Filter)
- **When:** Search or filter returns zero results.
- **What:** (1) Show what was searched, (2) suggest corrections ("Did you mean...?"), (3) offer to clear filters, (4) link to browse all items.
- **Anti-pattern:** Never show an empty page without context about why it's empty.

### User-Cleared (All Done)
- **When:** User has completed all items (empty inbox, no pending tasks).
- **What:** Celebrate! Show a positive message and illustration. Suggest a next action ("Review completed items" or "Create a new project").

### Error Empty State
- **When:** Data failed to load.
- **What:** Show error context, retry button, and alternative navigation. Never show an empty page when the real issue is a failed API call.

## 5. Offline & Connectivity

### Service Worker Caching
- **When:** Any app that should work offline or load fast on repeat visits.
- **What:** Cache the app shell (HTML, CSS, JS) and critical data. Use stale-while-revalidate for dynamic data. Clear stale cache on new deployments.

### Offline Banner
- **When:** User goes offline.
- **What:** Show a non-dismissible banner at the top: "You're offline. Some features may be limited." Remove automatically when connection restores.
- **Style:** Warning color (yellow/amber), not error (red). Offline is a state, not an error.

### Sync on Reconnect
- **When:** User performed actions while offline.
- **What:** When connection restores, replay queued mutations. Show sync progress. Handle conflicts. Notify on completion.
- **Anti-pattern:** Never silently sync without notifying the user. Never overwrite newer server data with stale offline data.

### Optimistic Writes
- **When:** User mutations that have a high success probability (likes, toggles, simple creates).
- **What:** Update the UI instantly. Queue the server request. On failure, roll back the UI and show an error toast.
- **Anti-pattern:** Never use optimistic writes for destructive actions (delete, payment) — wait for confirmation.

## Builder Agent Key Principles

1. **Every error state has a next action** — retry, go home, contact support, or clear filters.
2. **Never show blank pages** — empty states are onboarding opportunities.
3. **Retry with backoff, not loops** — exponential backoff with jitter for transient failures.
4. **Log errors, don't swallow them** — empty catch blocks hide bugs.
5. **Offline is a state, not an error** — show a banner, queue mutations, sync on reconnect.
6. **Blame-free language** — "Something went wrong" not "You caused an error".
