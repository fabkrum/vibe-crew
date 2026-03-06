# UI Gotchas — Non-Obvious Rules

Condensed reference of rules Claude consistently gets wrong. Read once during Design Phase and cross-reference against the feature spec. Full pattern details live in the individual `*-patterns.md` files and the docs site.

## HTML & Head
- `<meta charset="utf-8">` MUST be first element in `<head>` — browsers only look in first 1024 bytes.
- Sync `<script src>` (no async/defer) BEFORE `<link rel="stylesheet">` — avoids CSSOM-blocked script execution.
- Max 4 `<link rel="preconnect">` — each wastes a connection if unused.
- OG/description/canonical tags go AFTER all render-critical resources.

## Forms
- Validate on blur, NEVER on keystroke — 22% higher completion (Baymard).
- `autocomplete` tokens on every standard field (name, email, tel, address, cc-number).
- `inputmode="numeric"` for numbers, `inputmode="tel"` for phone — shows correct mobile keyboard.
- Mask/format on blur only, store raw value — never block typing mid-input.
- Single "Full name" field, never split first/last — 6% of humans have one name.

## Media & Fonts
- No animated GIFs — use `<video autoplay muted loop playsinline>` (80-90% smaller).
- Image srcset capped at 2x DPR — human eyes can't distinguish 2x from 3x.
- Exactly ONE image per page gets `fetchpriority="high"` (the LCP candidate).
- Fallback `@font-face` needs `size-adjust`, `ascent-override`, `descent-override` to prevent CLS.
- `font-display: swap` or `optional`, NEVER `block` — blocks render for up to 3s.

## Mobile & Touch
- All `<input>`, `<select>`, `<textarea>` MUST be `font-size: 16px+` — prevents iOS zoom.
- Full-screen layouts: `100dvh` not `100vh` — `vh` ignores mobile browser chrome.
- Pseudo-element `::before`/`::after` on buttons don't receive touch events — expand hit area with padding instead.
- Fixed elements (headers, tab bars, FABs) need `env(safe-area-inset-*)` padding.

## Animation
- `ease-out` for enter, `ease-in` for exit, NEVER `ease-in-out` for either.
- Collapse/expand: use `grid-template-rows: 0fr → 1fr`, not `height: 0 → auto`.
- 600ms cap on all UI animations — longer feels sluggish.
- Only animate `transform` + `opacity` — everything else triggers layout/paint.

## Legal (EU/DACH)
- Impressum required for ALL commercial DACH sites — link from every page footer.
- Cookie consent: "Accept All" and "Reject" buttons MUST have equal visual weight.
- BFSG (German accessibility law) deadline: June 28, 2025 — applies to all B2C digital services.
- Third-party scripts (analytics, chat, marketing) load ONLY after consent callback.

## Auth
- No "confirm password" field — use show/hide toggle instead (reduces friction, same security).
- "Remember me" defaults to checked on personal devices, unchecked on shared/kiosk.
- Auto-detect SSO: check email domain against known IdP list before showing password field.
- Login errors: single generic message ("Invalid email or password") — never reveal which is wrong.

## SEO & Caching
- `Cache-Control: public, max-age=31536000, immutable` for hashed assets; `no-cache` for HTML.
- `llms.txt` at site root for AI agent discovery — plain text site summary + key URLs.
- `X-Robots-Tag` or `robots.txt` for AI bot directives (GPTBot, ClaudeBot, etc.).

## Business & Conversion
- Endowed progress effect: start progress bars at ~20% — 2x completion rate (Nunes & Drèze).
- Trust signals (security badges, guarantees) within 200px of high-commitment CTAs.

## Dark Patterns (7-point detection checklist)
1. Equal weight test — can user decline as easily as accept?
2. Transparency test — are all costs/commitments visible before action?
3. Reversibility test — can user undo within a reasonable window?
4. Neutral language test — does decline text avoid guilt/shame?
5. Data minimization test — is only necessary data collected?
6. Consent granularity test — can user choose individual permissions?
7. Cancellation parity test — is cancelling as easy as signing up?

## i18n
- Budget 40% text expansion for German/Finnish translations in fixed-width containers.
- Arabic has 6 plural forms (not 2) — use ICU `{count, plural, ...}` with CLDR categories.
- Directional icons (arrows, "next") must flip in RTL — use `logical` CSS or `[dir="rtl"]` selector.

## Collaboration
- Typing indicator throttle: 3s minimum between "user is typing" broadcasts.
- CRDTs over OT for conflict resolution — CRDTs are eventually consistent without a central server.

## Settings
- Theme toggle: three states (light/dark/system) — never just two.
- API keys: show full key ONCE at creation with copy button + "won't be shown again" warning.

## Notifications
- Never auto-dismiss error toasts — user must acknowledge. Success toasts: 4-5s then dismiss.
- Don't double up `role="alert"` AND `aria-live="assertive"` on the same element — causes duplicate announcements.

## Filter & Search
- Use `router.replace()` not `router.push()` for filter/sort changes — avoids polluting browser history.
- `aria-live="assertive"` only for zero-result announcements — use `polite` for count updates.

## Data Visualization
- Dashboard: 5-9 widgets max (Miller's Law) — more causes cognitive overload.
- Real-time charts: cap update frequency at 2Hz — faster is imperceptible and wastes renders.

## Onboarding
- 3-5 onboarding steps for 72% completion — 6+ drops to 26% (Appcues data).
- First "quick win" must complete under 30s — builds self-efficacy (Fogg Behavior Model).

## Social
- Zero third-party social scripts on page load — use plain `<a>` + inline SVG icons.
- `rel="me"` on social profile links — enables fediverse identity verification.
