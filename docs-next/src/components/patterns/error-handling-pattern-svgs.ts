export const errorHandlingPatternSvgs: Record<string, string> = {
  'Component Error Boundary': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="20" y="20" width="160" height="30" rx="4" stroke="var(--color-accent)" stroke-width="1.5" stroke-dasharray="4 2" fill="none"/>
    <text x="100" y="39" text-anchor="middle" font-size="9" font-weight="700" fill="var(--color-accent)">ErrorBoundary</text>
    <rect x="30" y="58" width="60" height="40" rx="3" fill="var(--color-accent-bg)"/>
    <text x="60" y="74" text-anchor="middle" font-size="8" fill="var(--color-text-secondary)">Component</text>
    <text x="60" y="88" text-anchor="middle" font-size="18" fill="var(--color-accent)">✓</text>
    <rect x="110" y="58" width="60" height="40" rx="3" fill="#fef2f2" stroke="#ef4444" stroke-width="1"/>
    <text x="140" y="74" text-anchor="middle" font-size="8" fill="#ef4444">Fallback</text>
    <text x="140" y="90" text-anchor="middle" font-size="10" fill="#ef4444">⚠ Retry</text>
  </svg>`,

  'Granular Boundaries': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <text x="100" y="24" text-anchor="middle" font-size="8" font-weight="700" fill="var(--color-text-muted)">ROOT BOUNDARY</text>
    <rect x="18" y="30" width="80" height="35" rx="3" stroke="var(--color-accent)" stroke-width="1" stroke-dasharray="3 2" fill="none"/>
    <text x="58" y="42" text-anchor="middle" font-size="7" fill="var(--color-accent)">Page Boundary</text>
    <rect x="24" y="47" width="68" height="12" rx="2" fill="var(--color-accent-bg)"/>
    <text x="58" y="56" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Main Content ✓</text>
    <rect x="104" y="30" width="78" height="35" rx="3" stroke="#ef4444" stroke-width="1" stroke-dasharray="3 2" fill="none"/>
    <text x="143" y="42" text-anchor="middle" font-size="7" fill="#ef4444">Widget Boundary</text>
    <rect x="110" y="47" width="66" height="12" rx="2" fill="#fef2f2"/>
    <text x="143" y="56" text-anchor="middle" font-size="7" fill="#ef4444">Widget ⚠</text>
    <rect x="18" y="72" width="164" height="30" rx="3" stroke="var(--color-border)" stroke-width="1" fill="var(--color-accent-bg)"/>
    <text x="100" y="91" text-anchor="middle" font-size="8" fill="var(--color-text-secondary)">Page still works — only widget failed</text>
  </svg>`,

  'Error Logging': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="85" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <text x="52" y="26" text-anchor="middle" font-size="8" font-weight="700" fill="var(--color-text)">App</text>
    <rect x="18" y="32" width="69" height="10" rx="2" fill="#fef2f2"/>
    <text x="52" y="40" text-anchor="middle" font-size="7" fill="#ef4444">TypeError caught</text>
    <rect x="18" y="46" width="69" height="10" rx="2" fill="var(--color-accent-bg)"/>
    <text x="52" y="54" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">+ component stack</text>
    <rect x="18" y="60" width="69" height="10" rx="2" fill="var(--color-accent-bg)"/>
    <text x="52" y="68" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">+ user context</text>
    <rect x="18" y="74" width="69" height="10" rx="2" fill="var(--color-accent-bg)"/>
    <text x="52" y="82" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">+ breadcrumbs (5)</text>
    <path d="M95 60 L115 60" stroke="var(--color-accent)" stroke-width="1.5" marker-end="url(#arrow-log)"/>
    <defs><marker id="arrow-log" viewBox="0 0 6 6" refX="6" refY="3" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L6,3 L0,6" fill="var(--color-accent)"/></marker></defs>
    <rect x="115" y="30" width="75" height="60" rx="6" stroke="var(--color-accent)" stroke-width="1.5" fill="var(--color-accent-bg)"/>
    <text x="152" y="50" text-anchor="middle" font-size="9" font-weight="700" fill="var(--color-accent)">Sentry</text>
    <text x="152" y="64" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Error tracking</text>
    <text x="152" y="78" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Rate limited</text>
  </svg>`,

  'Timeout Handling': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <circle cx="55" cy="50" r="22" stroke="var(--color-accent)" stroke-width="2" fill="none"/>
    <line x1="55" y1="50" x2="55" y2="35" stroke="var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
    <line x1="55" y1="50" x2="67" y2="55" stroke="var(--color-accent)" stroke-width="2" stroke-linecap="round"/>
    <text x="55" y="82" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">8s timeout</text>
    <path d="M85 50 L110 50" stroke="#ef4444" stroke-width="1.5" stroke-dasharray="4 2"/>
    <text x="97" y="44" text-anchor="middle" font-size="7" fill="#ef4444">✕</text>
    <rect x="115" y="30" width="65" height="40" rx="4" fill="#fef2f2" stroke="#ef4444" stroke-width="1"/>
    <text x="147" y="46" text-anchor="middle" font-size="7" font-weight="600" fill="#ef4444">Timed out</text>
    <rect x="125" y="54" width="45" height="12" rx="3" fill="#ef4444"/>
    <text x="147" y="63" text-anchor="middle" font-size="7" fill="white">Retry</text>
  </svg>`,

  'Retry with Exponential Backoff': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="18" y="24" width="36" height="24" rx="3" fill="#fef2f2" stroke="#ef4444" stroke-width="1"/>
    <text x="36" y="34" text-anchor="middle" font-size="6" fill="#ef4444">Fail</text>
    <text x="36" y="44" text-anchor="middle" font-size="7" font-weight="600" fill="#ef4444">1s</text>
    <path d="M54 36 L62 36" stroke="var(--color-text-muted)" stroke-width="1"/>
    <rect x="62" y="24" width="36" height="24" rx="3" fill="#fef2f2" stroke="#ef4444" stroke-width="1"/>
    <text x="80" y="34" text-anchor="middle" font-size="6" fill="#ef4444">Fail</text>
    <text x="80" y="44" text-anchor="middle" font-size="7" font-weight="600" fill="#ef4444">2s</text>
    <path d="M98 36 L106 36" stroke="var(--color-text-muted)" stroke-width="1"/>
    <rect x="106" y="24" width="36" height="24" rx="3" fill="#fef2f2" stroke="#ef4444" stroke-width="1"/>
    <text x="124" y="34" text-anchor="middle" font-size="6" fill="#ef4444">Fail</text>
    <text x="124" y="44" text-anchor="middle" font-size="7" font-weight="600" fill="#ef4444">4s</text>
    <path d="M142 36 L150 36" stroke="var(--color-text-muted)" stroke-width="1"/>
    <rect x="150" y="24" width="36" height="24" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="1"/>
    <text x="168" y="40" text-anchor="middle" font-size="8" fill="var(--color-accent)">✓</text>
    <rect x="18" y="62" width="168" height="6" rx="3" fill="var(--color-border-subtle)"/>
    <rect x="18" y="62" width="126" height="6" rx="3" fill="var(--color-accent)" opacity="0.5"/>
    <text x="100" y="84" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Retrying... attempt 3 of 3</text>
    <text x="100" y="98" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">±20% jitter to avoid thundering herd</text>
  </svg>`,

  'Offline Detection': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="18" y="18" width="164" height="16" rx="3" fill="#fefce8" stroke="#eab308" stroke-width="1"/>
    <text x="100" y="29" text-anchor="middle" font-size="7" font-weight="600" fill="#a16207">⚡ You're offline — some features limited</text>
    <rect x="18" y="42" width="164" height="10" rx="2" fill="var(--color-accent-bg)"/>
    <rect x="18" y="56" width="120" height="10" rx="2" fill="var(--color-accent-bg)"/>
    <rect x="18" y="70" width="70" height="26" rx="4" fill="var(--color-border-subtle)"/>
    <text x="53" y="86" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">Submit ✕</text>
    <rect x="96" y="70" width="86" height="26" rx="4" fill="var(--color-accent-bg)"/>
    <text x="139" y="86" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Read-only ✓</text>
  </svg>`,

  'Mutation Queue': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <text x="55" y="24" text-anchor="middle" font-size="8" font-weight="700" fill="var(--color-text)">Offline Queue</text>
    <rect x="18" y="30" width="74" height="14" rx="2" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="0.5"/>
    <text x="55" y="40" text-anchor="middle" font-size="7" fill="var(--color-accent)">POST /like #1</text>
    <rect x="18" y="47" width="74" height="14" rx="2" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="0.5"/>
    <text x="55" y="57" text-anchor="middle" font-size="7" fill="var(--color-accent)">PUT /profile #2</text>
    <rect x="18" y="64" width="74" height="14" rx="2" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="0.5"/>
    <text x="55" y="74" text-anchor="middle" font-size="7" fill="var(--color-accent)">POST /comment #3</text>
    <path d="M100 54 L120 54" stroke="var(--color-accent)" stroke-width="1.5" marker-end="url(#arrow-mq)"/>
    <defs><marker id="arrow-mq" viewBox="0 0 6 6" refX="6" refY="3" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L6,3 L0,6" fill="var(--color-accent)"/></marker></defs>
    <rect x="120" y="30" width="68" height="50" rx="4" fill="var(--color-accent-bg)"/>
    <text x="154" y="48" text-anchor="middle" font-size="8" font-weight="600" fill="var(--color-accent)">Syncing...</text>
    <text x="154" y="62" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">2 of 3 done</text>
    <text x="154" y="74" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">✓ ✓ ◻</text>
    <text x="100" y="100" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">IndexedDB → replay on reconnect</text>
  </svg>`,

  '404 — Not Found': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <text x="100" y="34" text-anchor="middle" font-size="20" font-weight="800" fill="var(--color-accent)">404</text>
    <text x="100" y="50" text-anchor="middle" font-size="9" fill="var(--color-text-secondary)">We can't find that page</text>
    <rect x="40" y="58" width="120" height="14" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-border)" stroke-width="0.5"/>
    <text x="52" y="68" font-size="7" fill="var(--color-text-muted)">🔍 Search the site...</text>
    <rect x="60" y="80" width="80" height="18" rx="4" fill="var(--color-accent)"/>
    <text x="100" y="92" text-anchor="middle" font-size="8" font-weight="600" fill="white">Go Home</text>
  </svg>`,

  '500 — Server Error': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <text x="100" y="32" text-anchor="middle" font-size="18" font-weight="800" fill="#ef4444">500</text>
    <text x="100" y="48" text-anchor="middle" font-size="9" fill="var(--color-text-secondary)">Something went wrong</text>
    <rect x="35" y="56" width="56" height="16" rx="3" fill="#ef4444"/>
    <text x="63" y="67" text-anchor="middle" font-size="7" font-weight="600" fill="white">Try Again</text>
    <rect x="97" y="56" width="68" height="16" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-border)" stroke-width="0.5"/>
    <text x="131" y="67" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Status Page</text>
    <text x="100" y="90" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">Ref: err-a1b2c3d4</text>
    <text x="100" y="102" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">support@example.com</text>
  </svg>`,

  '403 — Forbidden': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <circle cx="100" cy="36" r="14" stroke="var(--color-accent)" stroke-width="2" fill="none"/>
    <rect x="96" y="28" width="8" height="10" rx="2" fill="var(--color-accent)"/>
    <rect x="92" y="36" width="16" height="12" rx="2" fill="var(--color-accent)"/>
    <text x="100" y="68" text-anchor="middle" font-size="9" fill="var(--color-text-secondary)">Access denied</text>
    <rect x="55" y="76" width="90" height="18" rx="4" fill="var(--color-accent)"/>
    <text x="100" y="88" text-anchor="middle" font-size="8" font-weight="600" fill="white">Sign In</text>
  </svg>`,

  'Maintenance Page': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <circle cx="100" cy="34" r="14" stroke="var(--color-accent)" stroke-width="2" fill="none"/>
    <path d="M92 34 L96 38 L108 28" stroke="var(--color-accent)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    <text x="100" y="58" text-anchor="middle" font-size="9" font-weight="600" fill="var(--color-text)">We're improving things</text>
    <text x="100" y="72" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Back in ~30 minutes</text>
    <rect x="40" y="80" width="55" height="14" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-border)" stroke-width="0.5"/>
    <text x="67" y="90" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Status Page</text>
    <rect x="100" y="80" width="60" height="14" rx="3" fill="var(--color-accent)"/>
    <text x="130" y="90" text-anchor="middle" font-size="7" font-weight="600" fill="white">Notify Me</text>
  </svg>`,

  'First Use (No Data Yet)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="70" y="18" width="60" height="40" rx="4" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="1" stroke-dasharray="4 2"/>
    <text x="100" y="36" text-anchor="middle" font-size="16" fill="var(--color-accent)">📭</text>
    <text x="100" y="52" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">Empty</text>
    <text x="100" y="70" text-anchor="middle" font-size="8" fill="var(--color-text-secondary)">No projects yet</text>
    <rect x="50" y="78" width="100" height="20" rx="5" fill="var(--color-accent)"/>
    <text x="100" y="92" text-anchor="middle" font-size="9" font-weight="700" fill="white">+ Create First Project</text>
  </svg>`,

  'No Results (Search/Filter)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="30" y="18" width="140" height="16" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-border)" stroke-width="0.5"/>
    <text x="44" y="29" font-size="7" fill="var(--color-text-muted)">🔍 "xyzzy"</text>
    <text x="100" y="52" text-anchor="middle" font-size="9" fill="var(--color-text-secondary)">No results for "xyzzy"</text>
    <text x="100" y="66" text-anchor="middle" font-size="7" fill="var(--color-accent)">Did you mean "fizzy"?</text>
    <rect x="50" y="74" width="100" height="14" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-border)" stroke-width="0.5"/>
    <text x="100" y="84" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Clear all filters</text>
    <text x="100" y="102" text-anchor="middle" font-size="7" fill="var(--color-accent)">Browse all items →</text>
  </svg>`,

  'User-Cleared (All Done)': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <circle cx="100" cy="40" r="16" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="1.5"/>
    <path d="M92 40 L97 45 L108 34" stroke="var(--color-accent)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    <text x="100" y="70" text-anchor="middle" font-size="9" font-weight="600" fill="var(--color-text)">You're all caught up!</text>
    <text x="100" y="84" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">No pending tasks</text>
    <text x="100" y="100" text-anchor="middle" font-size="7" fill="var(--color-accent)">Review completed →</text>
  </svg>`,

  'Error Empty State': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <circle cx="100" cy="38" r="14" fill="#fef2f2" stroke="#ef4444" stroke-width="1.5"/>
    <text x="100" y="43" text-anchor="middle" font-size="16" fill="#ef4444">⚠</text>
    <text x="100" y="66" text-anchor="middle" font-size="9" fill="var(--color-text-secondary)">Couldn't load items</text>
    <rect x="55" y="74" width="90" height="18" rx="4" fill="#ef4444"/>
    <text x="100" y="86" text-anchor="middle" font-size="8" font-weight="600" fill="white">Try Again</text>
    <text x="100" y="104" text-anchor="middle" font-size="7" fill="var(--color-accent)">Go to dashboard →</text>
  </svg>`,

  'Service Worker Caching': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="18" y="20" width="50" height="36" rx="3" fill="var(--color-accent-bg)"/>
    <text x="43" y="34" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">App Shell</text>
    <text x="43" y="46" text-anchor="middle" font-size="6" fill="var(--color-text-secondary)">HTML CSS JS</text>
    <rect x="75" y="20" width="50" height="36" rx="3" fill="var(--color-accent-bg)"/>
    <text x="100" y="34" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">SW Cache</text>
    <text x="100" y="46" text-anchor="middle" font-size="6" fill="var(--color-text-secondary)">Stale-while</text>
    <rect x="132" y="20" width="50" height="36" rx="3" fill="var(--color-accent-bg)"/>
    <text x="157" y="34" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">Network</text>
    <text x="157" y="46" text-anchor="middle" font-size="6" fill="var(--color-text-secondary)">Revalidate</text>
    <path d="M43 56 L43 64 L100 64" stroke="var(--color-accent)" stroke-width="1"/>
    <path d="M100 56 L100 64" stroke="var(--color-accent)" stroke-width="1"/>
    <path d="M157 56 L157 64 L100 64" stroke="var(--color-accent)" stroke-width="1"/>
    <rect x="30" y="72" width="140" height="28" rx="4" fill="var(--color-surface)" stroke="var(--color-accent)" stroke-width="1"/>
    <text x="100" y="86" text-anchor="middle" font-size="8" font-weight="600" fill="var(--color-accent)">Service Worker</text>
    <text x="100" y="96" text-anchor="middle" font-size="6" fill="var(--color-text-secondary)">CacheFirst · StaleWhileRevalidate · NetworkFirst</text>
  </svg>`,

  'Offline Banner': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="10" y="10" width="180" height="20" rx="6" fill="#fefce8" stroke="#eab308" stroke-width="1"/>
    <rect x="10" y="20" width="180" height="10" fill="#fefce8"/>
    <text x="100" y="24" text-anchor="middle" font-size="8" font-weight="600" fill="#a16207">⚡ You're offline</text>
    <rect x="18" y="38" width="164" height="8" rx="2" fill="var(--color-accent-bg)"/>
    <rect x="18" y="50" width="130" height="8" rx="2" fill="var(--color-accent-bg)"/>
    <rect x="18" y="62" width="100" height="8" rx="2" fill="var(--color-accent-bg)"/>
    <rect x="18" y="80" width="164" height="22" rx="3" fill="var(--color-accent-bg)"/>
    <text x="100" y="94" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Content visible from cache</text>
  </svg>`,

  'Sync on Reconnect': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <rect x="18" y="18" width="74" height="40" rx="3" fill="var(--color-accent-bg)"/>
    <text x="55" y="32" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-text)">Offline</text>
    <text x="55" y="44" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">3 queued</text>
    <text x="55" y="54" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">changes</text>
    <path d="M92 38 L108 38" stroke="var(--color-accent)" stroke-width="2" marker-end="url(#arrow-sync)"/>
    <defs><marker id="arrow-sync" viewBox="0 0 6 6" refX="6" refY="3" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0 L6,3 L0,6" fill="var(--color-accent)"/></marker></defs>
    <rect x="108" y="18" width="74" height="40" rx="3" fill="var(--color-accent-bg)"/>
    <text x="145" y="32" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">Online</text>
    <text x="145" y="44" text-anchor="middle" font-size="7" fill="var(--color-accent)">Syncing...</text>
    <text x="145" y="54" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">✓ ✓ ◻</text>
    <rect x="18" y="68" width="164" height="6" rx="3" fill="var(--color-border-subtle)"/>
    <rect x="18" y="68" width="110" height="6" rx="3" fill="var(--color-accent)"/>
    <text x="100" y="88" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">Syncing 2 of 3 changes...</text>
    <text x="100" y="102" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">Background Sync API</text>
  </svg>`,

  'Optimistic Writes': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="10" y="10" width="180" height="100" rx="6" stroke="var(--color-border)" stroke-width="1.5" fill="var(--color-surface)"/>
    <text x="100" y="24" text-anchor="middle" font-size="8" font-weight="700" fill="var(--color-text)">Optimistic Update</text>
    <rect x="18" y="30" width="50" height="30" rx="3" fill="var(--color-accent-bg)"/>
    <text x="43" y="42" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">1. Click</text>
    <text x="43" y="54" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">♥ → ♥</text>
    <path d="M68 45 L74 45" stroke="var(--color-text-muted)" stroke-width="1"/>
    <rect x="74" y="30" width="52" height="30" rx="3" fill="var(--color-accent-bg)"/>
    <text x="100" y="42" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">2. Update</text>
    <text x="100" y="54" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">UI instant</text>
    <path d="M126 45 L132 45" stroke="var(--color-text-muted)" stroke-width="1"/>
    <rect x="132" y="30" width="52" height="30" rx="3" fill="var(--color-accent-bg)"/>
    <text x="158" y="42" text-anchor="middle" font-size="7" font-weight="600" fill="var(--color-accent)">3. Send</text>
    <text x="158" y="54" text-anchor="middle" font-size="7" fill="var(--color-text-secondary)">API call</text>
    <rect x="18" y="68" width="80" height="22" rx="3" fill="var(--color-accent-bg)" stroke="var(--color-accent)" stroke-width="0.5"/>
    <text x="58" y="82" text-anchor="middle" font-size="7" fill="var(--color-accent)">✓ Success → done</text>
    <rect x="104" y="68" width="80" height="22" rx="3" fill="#fef2f2" stroke="#ef4444" stroke-width="0.5"/>
    <text x="144" y="82" text-anchor="middle" font-size="7" fill="#ef4444">✕ Fail → rollback</text>
    <text x="100" y="104" text-anchor="middle" font-size="7" fill="var(--color-text-muted)">Never for destructive actions (delete, payment)</text>
  </svg>`,
};
