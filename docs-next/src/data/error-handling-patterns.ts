export interface ErrorHandlingPattern {
  name: string;
  category: 'boundaries' | 'network' | 'pages' | 'empty' | 'offline';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<ErrorHandlingPattern['category'], string> = {
  boundaries: 'Error Boundaries',
  network: 'Network & API Errors',
  pages: 'HTTP Error Pages',
  empty: 'Empty States',
  offline: 'Offline & Connectivity',
};

export const categoryOrder: ErrorHandlingPattern['category'][] = [
  'boundaries', 'network', 'pages', 'empty', 'offline',
];

export const errorHandlingPatterns: ErrorHandlingPattern[] = [
  // --- Error Boundaries ---
  {
    name: 'Component Error Boundary',
    category: 'boundaries',
    description: 'Wrap every route-level component and any component making async calls in an error boundary that catches rendering errors. Show a fallback UI with error context and a retry/reset button. Log the error to a tracking service (Sentry, LogRocket).',
    implementation: 'React: Use `react-error-boundary` with `fallbackRender` prop providing a reset function. Wrap at route level and around data-fetching widgets. The fallback component should offer "Try again" (resets boundary) and "Go home" actions.',
    a11y: 'Fallback UI must be keyboard-accessible. Move focus to the error message heading on render using `useEffect` with `ref.focus()`. Include `role="alert"` on the error container so screen readers announce it immediately.',
    docsUrl: 'https://react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary',
  },
  {
    name: 'Granular Boundaries',
    category: 'boundaries',
    description: 'Page has independently-functioning sections (sidebar, main content, widgets). Wrap each section in its own error boundary so a failing widget doesn\'t crash the entire page. At minimum wrap: (1) root layout, (2) each route/page, (3) each data-fetching widget.',
    implementation: 'Nest error boundaries from root down: App → Layout → Page → Widget. Each boundary has its own fallback UI appropriate to its scope — a widget fallback is a small card, a page fallback is full-page, root fallback is minimal HTML.',
    a11y: 'Granular boundaries preserve the accessible experience for unaffected sections. A failing sidebar shouldn\'t remove the main content\'s landmark structure or keyboard navigation.',
    docsUrl: null,
  },
  {
    name: 'Error Logging',
    category: 'boundaries',
    description: 'Log every caught error with type, message, component stack, user context (ID, page, action), and breadcrumbs (last 5 user actions). Rate-limit to avoid flooding. Never swallow errors with empty catch blocks — they hide bugs.',
    implementation: 'Initialize Sentry/LogRocket in the app entry point. Capture errors in error boundary `onError` callback and in global `window.onerror`/`unhandledrejection` handlers. Add breadcrumbs for navigation, clicks, and API calls.',
    a11y: 'Never log sensitive data (passwords, tokens, PII) in error reports. Error logging is invisible to users but enables faster bug resolution, indirectly improving the experience for all users.',
    docsUrl: null,
  },

  // --- Network & API Errors ---
  {
    name: 'Timeout Handling',
    category: 'network',
    description: 'Set explicit request timeouts — 5-10 seconds for data fetches, 30 seconds for uploads. Show a specific "Request timed out" message with a retry button rather than letting requests hang indefinitely or showing "Unknown error".',
    implementation: 'Use `AbortController` with `setTimeout`: `const controller = new AbortController(); setTimeout(() => controller.abort(), 8000); fetch(url, { signal: controller.signal })`. Catch `AbortError` specifically to show timeout UI.',
    a11y: 'Announce timeout to screen readers with `role="alert"`. The retry button should be immediately focusable. Show estimated wait time if known ("Retrying in 3 seconds...").',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/AbortController',
  },
  {
    name: 'Retry with Exponential Backoff',
    category: 'network',
    description: 'Retry transient failures (5xx, timeout, network error) up to 3 times with exponential backoff (1s → 2s → 4s) and jitter (±20%) to avoid thundering herd. Show retry status to the user. Never retry 4xx client errors.',
    implementation: '`async function fetchWithRetry(url, maxRetries = 3) { for (let i = 0; i <= maxRetries; i++) { try { return await fetch(url); } catch (e) { if (i === maxRetries) throw e; await sleep(Math.pow(2, i) * 1000 * (0.8 + Math.random() * 0.4)); } } }`. Show "Retrying... (attempt 2 of 3)".',
    a11y: 'Use `aria-live="polite"` to announce retry attempts. Show a visible progress indicator during retries. After final failure, focus the error message and provide manual retry.',
    docsUrl: null,
  },
  {
    name: 'Offline Detection',
    category: 'network',
    description: 'Listen to `navigator.onLine` and `offline`/`online` events. When offline, show a persistent banner and disable actions that require network. Never fail silently when offline or show generic network errors for a known offline state.',
    implementation: '`window.addEventListener("offline", () => setOffline(true))`. Check `navigator.onLine` on mount. Show a non-dismissible top banner: "You\'re offline — some features may be limited." Disable submit buttons and show tooltips explaining why.',
    a11y: 'Offline banner uses `role="status"` and `aria-live="polite"`. Disabled buttons retain their label but add `aria-disabled="true"` with a tooltip explaining the offline state. Don\'t use `disabled` attribute alone.',
    docsUrl: null,
  },
  {
    name: 'Mutation Queue',
    category: 'network',
    description: 'When users perform actions while offline, queue mutations in localStorage or IndexedDB and replay on reconnect in order. Show sync status. Handle conflicts with last-write-wins or by prompting the user. Never discard user actions due to temporary offline state.',
    implementation: 'Store each mutation as `{ id, endpoint, method, body, timestamp }` in IndexedDB. On `online` event, replay queue sequentially. Dedup by id. Show "Syncing 3 changes..." progress. On conflict, surface a merge dialog.',
    a11y: 'Announce sync progress via `aria-live="polite"`: "Syncing your changes — 2 of 3 complete." Announce completion or conflicts. Merge conflict dialog must be keyboard-accessible and focusable.',
    docsUrl: null,
  },

  // --- HTTP Error Pages ---
  {
    name: '404 — Not Found',
    category: 'pages',
    description: 'Friendly page with a clear "Page not found" message, search bar, links to popular pages, and a "Go home" button. Tone is apologetic: "We can\'t find that page" — never blame the user. Optionally auto-redirect to home after 10 seconds.',
    implementation: 'Create a dedicated 404 page with the app shell intact (header, footer, nav). Include: (1) clear h1 heading, (2) search input, (3) 3-4 popular page links, (4) prominent "Go home" button. Log 404 URLs for broken link monitoring.',
    a11y: 'Proper heading hierarchy (`h1` for "Page not found"). Focus the heading on page load. Search input has a visible label. All links and buttons are keyboard-accessible. Include `<title>` with "Page not found".',
    docsUrl: null,
  },
  {
    name: '500 — Server Error',
    category: 'pages',
    description: 'Apology page with a "Something went wrong" message, retry button, status page link, and support contact. Show a reference ID for support tickets. Never show stack traces or suggest the user caused the error.',
    implementation: 'Minimal static HTML (don\'t rely on JS that might also be broken). Include: (1) h1 apology, (2) "Try again" button, (3) link to status page (e.g., status.example.com), (4) support email. Generate a UUID reference ID and show it.',
    a11y: 'Must work without JavaScript — pure HTML/CSS. Focus the heading. The retry button should be a standard `<button>` or `<a>` element. Reference ID should be copyable (select-all on click or copy button).',
    docsUrl: null,
  },
  {
    name: '403 — Forbidden',
    category: 'pages',
    description: 'Explain why access is denied. If authentication is needed, show a login button. For sensitive resources, treat 403 like 404 to avoid revealing resource existence. Always provide a clear next action.',
    implementation: 'Two variants: (1) Unauthenticated — "Sign in to access this page" with login CTA, (2) Unauthorized — "You don\'t have permission. Contact your admin." For security-sensitive resources, return 404 instead of 403.',
    a11y: 'Focus the explanatory heading. Login button should be prominent and keyboard-accessible. Don\'t auto-redirect to login without warning — let the user read the message first.',
    docsUrl: null,
  },
  {
    name: 'Maintenance Page',
    category: 'pages',
    description: 'Show an estimated time of return (ETA), link to a status page, and an option to get notified when back (email input). Style consistently with the app. Serve as a static page that doesn\'t depend on the application server.',
    implementation: 'Serve from CDN or static hosting (not the app server being maintained). Include: (1) h1 "We\'re improving things", (2) estimated return time, (3) status page link, (4) optional email signup for notification. HTTP 503 with `Retry-After` header.',
    a11y: 'Must be fully accessible as a standalone page. Proper heading structure. Email input with visible label. All interactive elements keyboard-operable. Include `<meta>` refresh as fallback for automatic check-back.',
    docsUrl: null,
  },

  // --- Empty States ---
  {
    name: 'First Use (No Data Yet)',
    category: 'empty',
    description: 'User has no items in a collection (no projects, no messages). Show an illustration/icon, a brief explanation of what will appear here, and a primary CTA to create the first item. Make the CTA the most prominent element — capitalize on motivation (Fogg Behavior Model).',
    implementation: 'Center-aligned layout: (1) SVG illustration (not a photo, keeps file size small), (2) heading like "No projects yet", (3) short paragraph explaining the value, (4) primary button "Create your first project". Hide secondary nav that has nothing to show.',
    a11y: 'Illustration uses `role="img"` with `aria-label`. CTA is a standard `<button>` or `<a>` with clear label. The empty state should be announced as a complete region, not just as missing content.',
    docsUrl: null,
  },
  {
    name: 'No Results (Search/Filter)',
    category: 'empty',
    description: 'Search or filter returns zero results. Show what was searched, suggest corrections ("Did you mean...?"), offer to clear filters, and link to browse all items. Never show an empty page without context about why it\'s empty.',
    implementation: 'Show: (1) "No results for \'[query]\'" heading, (2) spelling suggestions from a fuzzy matcher (Fuse.js), (3) "Clear all filters" button, (4) "Browse all [items]" link. Maintain the search/filter UI so users can immediately adjust.',
    a11y: 'Announce "No results found" with `role="status"`. Suggestions and clear-filters button must be keyboard-reachable. Don\'t remove the search input — keep focus context so users can immediately refine.',
    docsUrl: null,
  },
  {
    name: 'User-Cleared (All Done)',
    category: 'empty',
    description: 'User has completed all items (empty inbox, no pending tasks). Show a positive, celebratory message with an illustration and suggest a next action: "Review completed items" or "Create a new project." This is an achievement, not an error.',
    implementation: 'Center-aligned layout: (1) celebratory illustration (checkmark, confetti), (2) heading like "You\'re all caught up!", (3) short positive message, (4) secondary action links to related areas. Use a distinct visual treatment from error empty states.',
    a11y: 'Use positive language that doesn\'t imply something is wrong. The illustration should have descriptive `aria-label`. Next-action links should be clearly labeled and keyboard-accessible.',
    docsUrl: null,
  },
  {
    name: 'Error Empty State',
    category: 'empty',
    description: 'Data failed to load — this is not a real "empty" state, it\'s a masked error. Show error context, a retry button, and alternative navigation. Never show "No items" when the real problem is a failed API call.',
    implementation: 'Distinguish from true empty: (1) error icon (⚠️ not 📭), (2) "Couldn\'t load [items]" heading, (3) "Try again" retry button that re-triggers the fetch, (4) "Go to [alternative]" link. Track the error in logging.',
    a11y: 'Error state uses `role="alert"` to announce immediately. Retry button gets focus after the error renders. Distinguish visually and semantically from informational empty states.',
    docsUrl: null,
  },

  // --- Offline & Connectivity ---
  {
    name: 'Service Worker Caching',
    category: 'offline',
    description: 'Cache the app shell (HTML, CSS, JS) and critical data so the app works offline or loads instantly on repeat visits. Use stale-while-revalidate for dynamic data. Clear stale caches on new deployments.',
    implementation: 'Register a service worker that caches the app shell on install. Use Workbox for caching strategies: `CacheFirst` for static assets, `StaleWhileRevalidate` for API data, `NetworkFirst` for HTML. Version caches and delete old versions in the `activate` event.',
    a11y: 'Service workers are invisible to users and assistive technology. Ensure cached content maintains the same accessible structure as live content. Cache ARIA-related resources (icon fonts, SVG sprites).',
    docsUrl: 'https://developer.chrome.com/docs/workbox',
  },
  {
    name: 'Offline Banner',
    category: 'offline',
    description: 'Show a non-dismissible banner at the top when the user goes offline: "You\'re offline — some features may be limited." Remove automatically when connection restores. Use warning color (yellow/amber), not error (red) — offline is a state, not an error.',
    implementation: 'Fixed-position top banner with `z-index` above content but below modals. Yellow/amber background. Listen to `online` event to auto-remove. Add `transition: transform 0.3s` for smooth slide-in/out.',
    a11y: '`role="status"` with `aria-live="polite"` so screen readers announce the state change without interrupting. Don\'t use `role="alert"` — offline is informational, not urgent. Ensure sufficient color contrast on the amber background.',
    docsUrl: null,
  },
  {
    name: 'Sync on Reconnect',
    category: 'offline',
    description: 'When connection restores, replay queued mutations in order. Show sync progress. Handle conflicts (server data may have changed). Notify on completion. Never silently sync without notifying or overwrite newer server data with stale offline data.',
    implementation: 'On `online` event: (1) show "Syncing..." toast, (2) replay IndexedDB queue sequentially, (3) compare timestamps for conflicts, (4) show "All changes synced" or surface conflicts. Use Background Sync API where supported.',
    a11y: 'Announce sync start, progress, and completion via `aria-live="polite"`. Conflict resolution dialogs must be keyboard-accessible and trap focus. Provide a "View sync details" link for transparency.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/Background_Synchronization_API',
  },
  {
    name: 'Optimistic Writes',
    category: 'offline',
    description: 'For mutations with high success probability (likes, toggles, simple creates), update the UI instantly, queue the server request, and roll back on failure with an error toast. Never use optimistic writes for destructive actions (delete, payment) — wait for server confirmation.',
    implementation: 'Pattern: (1) update local state immediately, (2) fire API request, (3) on success — do nothing (UI already correct), (4) on failure — revert local state and show error toast with "Retry" action. Store the previous state for rollback.',
    a11y: 'Optimistic UI feels instant and responsive, benefiting all users. On rollback, announce the error via `role="alert"` and explain what happened: "Couldn\'t save — your change was reverted." Focus the retry action.',
    docsUrl: null,
  },
];
