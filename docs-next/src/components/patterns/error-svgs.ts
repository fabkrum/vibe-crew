/** SVG illustrations for "Error Handling" patterns */
export const errorSvgs: Record<string, string> = {

'Error Boundary': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="100" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <rect x="35" y="25" width="55" height="35" rx="5" style="fill: var(--color-accent-bg)"/>
  <rect x="35" y="65" width="55" height="35" rx="5" style="fill: var(--color-accent-bg)"/>
  <rect x="100" y="25" width="65" height="75" rx="5" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="132" y="55" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 20px; font-weight: 700; font-family: var(--font-sans)">!</text>
  <text x="132" y="75" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 8px; font-family: var(--font-sans)">Caught</text>
  <text x="132" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 7px; font-family: var(--font-sans)">Retry ↻</text>
</svg>`,

'Retry Pattern': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="45" cy="50" r="18" style="stroke: hsl(0, 84%, 60%); fill: none" stroke-width="1.5"/>
  <text x="45" y="54" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">×</text>
  <text x="45" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">1s</text>
  <path d="M70 50 L85 50" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="81,46 85,50 81,54" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <circle cx="105" cy="50" r="18" style="stroke: hsl(38, 92%, 50%); fill: none" stroke-width="1.5"/>
  <text x="105" y="54" text-anchor="middle" style="fill: hsl(38, 92%, 50%); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">↻</text>
  <text x="105" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">2s</text>
  <path d="M130 50 L145 50" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <polyline points="141,46 145,50 141,54" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5" stroke-linecap="round"/>
  <circle cx="165" cy="50" r="18" style="stroke: var(--color-accent); fill: var(--color-accent-bg)" stroke-width="1.5"/>
  <text x="165" y="54" text-anchor="middle" style="fill: var(--color-accent); font-size: 12px; font-weight: 700; font-family: var(--font-sans)">✓</text>
  <text x="165" y="80" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">4s</text>
  <text x="105" y="105" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 9px; font-family: var(--font-sans)">exponential backoff</text>
</svg>`,

'Offline Indicator': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="10" width="160" height="24" rx="5" style="fill: hsl(38, 92%, 50%)"/>
  <text x="100" y="26" text-anchor="middle" style="fill: #fff; font-size: 11px; font-weight: 600; font-family: var(--font-sans)">You are offline</text>
  <rect x="40" y="50" width="120" height="50" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="4 3"/>
  <text x="100" y="72" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">Cached content</text>
  <text x="100" y="88" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">available offline</text>
</svg>`,

'Custom 404': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="45" text-anchor="middle" style="fill: var(--color-accent); font-size: 32px; font-weight: 800; font-family: var(--font-sans)">404</text>
  <text x="100" y="65" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Page not found</text>
  <rect x="55" y="78" width="90" height="24" rx="6" style="fill: var(--color-accent)"/>
  <text x="100" y="94" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Go Home →</text>
</svg>`,

'Custom 500': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="100" y="45" text-anchor="middle" style="fill: hsl(0, 84%, 60%); font-size: 32px; font-weight: 800; font-family: var(--font-sans)">500</text>
  <text x="100" y="65" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">Something went wrong</text>
  <rect x="55" y="78" width="90" height="24" rx="6" style="stroke: var(--color-accent); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="100" y="94" text-anchor="middle" style="fill: var(--color-accent); font-size: 10px; font-weight: 600; font-family: var(--font-sans)">Try Again ↻</text>
</svg>`,

'Empty State — First Use': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="10" width="120" height="70" rx="8" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5" stroke-dasharray="6 4"/>
  <text x="100" y="35" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 20px; font-family: var(--font-sans)">📝</text>
  <text x="100" y="55" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">No items yet</text>
  <text x="100" y="68" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Create your first one</text>
  <rect x="60" y="88" width="80" height="24" rx="6" style="fill: var(--color-accent)"/>
  <text x="100" y="104" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 600; font-family: var(--font-sans)">+ Create</text>
</svg>`,

'Empty State — No Results': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="40" y="10" width="120" height="28" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5"/>
  <text x="55" y="28" style="fill: var(--color-text-muted); font-size: 10px; font-family: var(--font-sans)">asdfghj</text>
  <circle cx="150" cy="24" r="8" style="stroke: var(--color-text-muted); fill: none" stroke-width="1.5"/>
  <line x1="155" y1="30" x2="160" y2="35" style="stroke: var(--color-text-muted)" stroke-width="1.5" stroke-linecap="round"/>
  <text x="100" y="65" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 18px; font-family: var(--font-sans)">🔍</text>
  <text x="100" y="85" text-anchor="middle" style="fill: var(--color-text-secondary); font-size: 10px; font-family: var(--font-sans)">No results found</text>
  <text x="100" y="100" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Try different keywords</text>
</svg>`,

'Network Error Toast': `<svg viewBox="0 0 200 120" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="20" y="15" width="160" height="60" rx="6" style="stroke: var(--color-border); fill: var(--color-surface)" stroke-width="1.5" opacity="0.3"/>
  <rect x="30" y="75" width="140" height="36" rx="8" style="stroke: hsl(0, 84%, 60%); fill: var(--color-surface)" stroke-width="1.5"/>
  <circle cx="50" cy="93" r="8" style="fill: hsl(0, 84%, 60%)"/>
  <text x="50" y="97" text-anchor="middle" style="fill: #fff; font-size: 10px; font-weight: 700; font-family: var(--font-sans)">!</text>
  <text x="110" y="90" text-anchor="middle" style="fill: var(--color-text); font-size: 9px; font-weight: 600; font-family: var(--font-sans)">Network error</text>
  <text x="110" y="102" text-anchor="middle" style="fill: var(--color-text-muted); font-size: 8px; font-family: var(--font-sans)">Tap to retry</text>
</svg>`,

};
