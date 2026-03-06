# Social Media Pattern Reference

Agent-facing reference for privacy-respecting social media integration. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Zero third-party scripts on page load. No data leaves the user's browser without explicit action. Social links are plain anchor tags. Embeds use facade/click-to-load patterns. Identity is established via open standards (rel="me", Schema.org sameAs, Webfinger).

## 1. Profile Links

### Icon Link Bar
- **When:** Footer, about page, or contact section where social profiles should be discoverable.
- **What:** Horizontal row of inline SVG icons as plain `<a>` links. `rel="me noopener" target="_blank"`. Flexbox with 0.75-1rem gap. Icons 20-24px. Use `currentColor` for theme adaptation.
- **A11y:** `<nav aria-label="Social media links">`. Each link: `aria-label="Follow us on {Platform}"`. SVG: `aria-hidden="true"`. 44x44px minimum touch target.
- **Anti-pattern:** Never load icon fonts from CDNs (tracking). Never use third-party social button widgets. Never use platform-provided embed scripts for simple profile links.

### Branded Link Card
- **When:** "Connect with us" sections where context beyond a bare icon is needed.
- **What:** Cards with platform icon, name, handle, optional build-time follower count. Entire card is an `<a>`. Never fetch counts client-side.
- **A11y:** Link: `aria-label="{Platform}: @{handle}"`. Platform brand colors: ensure 4.5:1 contrast.
- **Anti-pattern:** Never fetch follower counts client-side (rate limits, tracking). Never auto-update counts in real time.

### Author Attribution Link
- **When:** Blog posts, articles, documentation with identified authors.
- **What:** Byline with author name as `<a>` link to profile. `rel="author me"`. Optional small social icons. Pair with Schema.org Person `sameAs`.
- **A11y:** Author name is the link text (descriptive). Additional icons: `aria-label="Author on {Platform}"`.
- **Anti-pattern:** Never rely solely on avatar for author identification. Always include text name.

### Floating Social Sidebar
- **When:** Long content pages (blog, docs) where persistent social links add value.
- **What:** `position: fixed` vertical icon strip. `display: none` below 1024px. Plain `<a>` tags. z-index below modals.
- **A11y:** `<nav aria-label="Social links">`. Must not overlap main content. Users can Tab past it.
- **Anti-pattern:** Never show on mobile (obscures content). Never make it sticky AND floating (pick one).

### Bio Card with Social Links
- **When:** Team/about pages, speaker profiles, contributor lists.
- **What:** Card with avatar, name, role, bio, social icon row. Icons use Icon Link Bar pattern.
- **A11y:** Avatar `alt="{Name}, {Role}"`. Social links: `aria-label="{Name} on {Platform}"`. Card itself is not interactive.
- **Anti-pattern:** Never make the entire card a link. Never use platform embed widgets for simple profile display.

## 2. Share Buttons

### Native Web Share API
- **When:** Mobile-first or progressive web apps. Primary share mechanism.
- **What:** Feature-detect `navigator.share`. Call with `{ title, text, url }`. Fallback to Static Share Links if unavailable. Wrap in try/catch for AbortError.
- **A11y:** `<button aria-label="Share this page">`. Never auto-trigger — require explicit click.
- **Anti-pattern:** Never assume Web Share API is available. Always provide fallback links. Never call without user gesture.

### Static Share Link
- **When:** Any page with share functionality. The universal default.
- **What:** Platform URL scheme links: Twitter (`/intent/tweet?url=&text=`), LinkedIn (`/shareArticle?mini=true&url=&title=`), Facebook (`/sharer/sharer.php?u=`), Reddit (`/submit?url=&title=`). `target="_blank" rel="noopener"`. Parameters: `encodeURIComponent()`.
- **A11y:** `<nav aria-label="Share this page">`. Each link: `aria-label="Share on {Platform}"`. 44x44px touch targets.
- **Anti-pattern:** Never load platform SDKs for basic sharing. Never hardcode URLs without encoding parameters. Never omit rel="noopener".

### Two-Click Share (Shariff)
- **When:** Strict privacy requirements (GDPR-focused, European markets). Pages where zero tracking on load is mandatory.
- **What:** Static button (click 1 = consent) -> active share (click 2 = action). No external resources until first click. Store consent in sessionStorage.
- **A11y:** First state: `<button aria-label="Activate {Platform} sharing">`. State change announced via aria-live or text update.
- **Anti-pattern:** Never skip the consent step. Never pre-load platform scripts before first click. Never persist consent beyond the session without explicit user preference.

### Copy Link Button
- **When:** Every share button group. Universal fallback.
- **What:** `navigator.clipboard.writeText(url)` on click. Success: swap icon to checkmark for 2s. Use canonical URL. Handle clipboard errors gracefully.
- **A11y:** `<button aria-label="Copy page link to clipboard">`. Success: aria-live="polite" announcement. Never use alert().
- **Anti-pattern:** Never skip the success feedback. Never use a non-canonical URL. Never use document.execCommand (deprecated).

### Email Share Link
- **When:** B2B content, professional contexts, newsletters, documentation.
- **What:** `mailto:?subject={title}&body={excerpt + url}`. Subject under 78 chars. Render as `<a>`, not button.
- **A11y:** `aria-label="Share via email"`. Opens native app — no new-tab indicator needed.
- **Anti-pattern:** Never include tracking parameters in the email body. Never pre-fill a recipient address.

### Share Preview Card
- **When:** Below share buttons to build user confidence about what will be shared.
- **What:** Mock social card using page's own OG meta tags: image (1.91:1), title, description (2 lines), domain. Entirely local data — no external fetch.
- **A11y:** Decorative — not interactive. Image: alt from og:title. Text contrast: WCAG AA.
- **Anti-pattern:** Never fetch preview from an external unfurl service. Never show a preview that doesn't match actual OG tags.

## 3. Social Embeds

### Facade Embed (Click-to-Load)
- **When:** Any social media embed (tweets, videos, Instagram posts, TikTok).
- **What:** Static placeholder image + platform logo + "Load" button. Replace with actual iframe/script on click. YouTube: thumbnail from `img.youtube.com/vi/{id}/maxresdefault.jpg`. Use `loading="lazy"` on iframe.
- **A11y:** Placeholder: `<button aria-label="Load {Platform} embed: {title}">`. Loaded iframe: `title="{description}"`. Announce completion via aria-live.
- **Anti-pattern:** Never auto-load social embeds. Never load embed scripts in `<head>`. Never embed without a facade on performance-critical pages.

### Privacy-Proxied Embed
- **When:** Video embeds (YouTube, Vimeo) where the facade pattern is too disruptive to UX.
- **What:** YouTube: `youtube-nocookie.com/embed`. Vimeo: `?dnt=1`. Twitter: blockquote + link instead of widget JS. iframe: `sandbox="allow-scripts allow-same-origin"`.
- **A11y:** Same as standard embeds. iframe: title attribute. Privacy changes must not affect user-facing controls.
- **Anti-pattern:** Never use the standard youtube.com/embed domain. Never omit the sandbox attribute. Never skip the nocookie/dnt parameter.

### Blockquote Fallback Embed
- **When:** Quoting social media posts (tweets, toots, text posts) where interactivity is not needed.
- **What:** `<blockquote cite="{url}"><p>{text}</p><footer>— <a href="{url}" rel="noopener">{author} on {Platform}</a></footer></blockquote>`. Left border accent. Self-hosted avatar copy. Sanitize all content.
- **A11y:** `<blockquote>` with cite attribute. Attribution in `<footer>` or `<figcaption>`. Screen readers announce blockquotes natively.
- **Anti-pattern:** Never use an iframe for text-only social content. Never include unsanitized HTML from social posts. Never omit attribution.

### Consent-Gated Embed Wall
- **When:** Pages with multiple social embeds from the same platform.
- **What:** Single consent banner at top: "Load all {Platform} embeds?" One consent loads all. Store in cookie/localStorage, keyed by platform. Integrate with site consent manager. Provide revoke option.
- **A11y:** Banner: `role="region" aria-label="External content consent"`. After load: aria-live announcement.
- **Anti-pattern:** Never require individual consent for each embed on the same page. Never auto-grant consent. Never omit a revoke mechanism.

### Server-Rendered Social Card
- **When:** Documentation, case studies, testimonials where embed content is known at build time.
- **What:** Fetch post data via API at build time. Render as static HTML: avatar (self-hosted), author, text, media (self-hosted), timestamp, "View on {Platform}" link. Cache API responses.
- **A11y:** `<figure>` with `<figcaption>` for attribution. `<time datetime="{ISO}">`. Descriptive alt text on images.
- **Anti-pattern:** Never fetch social data client-side for static content. Never hotlink images from social platforms (will break). Never skip error handling for deleted posts.

## 4. Social Feeds

### Static Feed Snapshot
- **When:** Homepage, sidebar, marketing pages where social presence is shown.
- **What:** Build-time API fetch of latest 3-5 posts. Static HTML cards. Self-hosted images. "Last updated" footer. Rebuild on schedule. Cache and handle API failures.
- **A11y:** `<section aria-label="Latest posts from {Platform}">`. Each post: `<article>`. `<time>` for timestamps. No auto-scrolling.
- **Anti-pattern:** Never fetch social feeds client-side on page load. Never auto-refresh. Never show more than 5 items (link to profile for more).

### RSS-Powered Feed
- **When:** Aggregating content from Mastodon, Bluesky, WordPress, Ghost, Medium, YouTube, or any RSS source.
- **What:** Parse RSS/Atom at build time. Extract title, link, description, pubDate. Sanitize HTML. Limit to 5-10 items. No API keys needed for most feeds.
- **A11y:** Same as Static Feed Snapshot. Sanitize feed HTML for contrast and structure. Strip inline styles.
- **Anti-pattern:** Never parse RSS client-side. Never trust feed HTML without sanitization. Never display raw XML content.

### Hybrid Feed (Static + Client Refresh)
- **When:** Pages where users may want fresher content than the last build.
- **What:** Build-time snapshot as default. "Load latest" button fetches from your own API proxy (never direct platform API from client). Show loading indicator. Rate-limit the button (30s cooldown).
- **A11y:** Button: `<button aria-label="Load latest posts">`. During load: `aria-busy="true"`. After update: aria-live announcement. No disruption to focus/scroll.
- **Anti-pattern:** Never auto-poll. Never call social APIs directly from the client. Never replace content without user action.

### Testimonial Wall
- **When:** Landing pages, about pages, case study sections.
- **What:** Curated social mentions in a data file. Responsive grid (2-3 columns) of blockquote cards. Self-hosted avatars. Attribution links. Optionally randomize subset per build.
- **A11y:** Each testimonial: `<blockquote>` with `<footer>`. Carousel: provide pause button. Grid: logical tab order. No auto-playing animations.
- **Anti-pattern:** Never auto-import all mentions (quality control). Never use live platform feeds for testimonials. Never omit attribution.

## 5. Social Proof

### Static Counter Display
- **When:** Landing pages, hero sections, social proof bars.
- **What:** Build-time API fetch of counts (GitHub stars, npm downloads, followers). Format with Intl.NumberFormat or abbreviate (12.3k). Icon + count + label. Refresh on deploy.
- **A11y:** `<span aria-label="{full count} {metric} on {Platform}">`. Full number in aria-label for abbreviated displays.
- **Anti-pattern:** Never use real-time counter widgets. Never animate counting-up without respecting prefers-reduced-motion. Never show stale "0" on API failure (use last known value).

### GitHub Star Badge
- **When:** Open source project pages, README-style sections.
- **What:** Self-hosted shields.io badge or static HTML with star icon + count. Link to repo. Fetch count at build time.
- **A11y:** Image: `alt="{repo} has {count} stars on GitHub"`. Link: `aria-label="{count} GitHub stars - view repository"`.
- **Anti-pattern:** Never use the official GitHub star button widget (loads external JS). Never hotlink shields.io without caching/self-hosting.

### Testimonial Carousel
- **When:** Hero sections with limited space for social proof.
- **What:** Rotating testimonials from local data file. CSS scroll-snap or minimal JS. Auto-rotation 5-8s with pause on hover/focus. Dots + prev/next. No third-party carousel library.
- **A11y:** `role="region" aria-roledescription="carousel"`. Auto-rotation: must pause on focus/hover. Visible pause button. Prev/next: aria-labels.
- **Anti-pattern:** Never use auto-rotation without pause controls. Never load carousel libraries with tracking. Never pull testimonials from live API.

### User Count Banner
- **When:** Above primary CTAs, site header, hero sections.
- **What:** "Join {count}+ {audience}" with round number. Updated manually or at build time. Optional avatar stack (3-5 overlapping circles). One line maximum.
- **A11y:** Plain HTML text. Avatar stack: `alt=""` (decorative). Count is not the only value proposition.
- **Anti-pattern:** Never show an exact count (round it). Never use a real-time counter widget. Never place without adjacent CTA.

## 6. Structured Identity

### rel="me" Verification
- **When:** Any page linking to social profiles.
- **What:** `<a href="{profile}" rel="me noopener">`. Add site URL to each social profile's bio. Place on homepage for maximum verification. Mastodon verifies bidirectional links automatically.
- **A11y:** Invisible metadata — no user-facing impact. Link text/aria-label describes destination.
- **Anti-pattern:** Never use rel="me" on links to other people's profiles. Never place only on subpages (homepage is most authoritative).

### Schema.org sameAs
- **When:** Any site with official social accounts.
- **What:** JSON-LD with Organization or Person type. `"sameAs": ["{twitter}", "{github}", "{linkedin}", "{mastodon}"]`. Place in `<head>` via `<script type="application/ld+json">`. Validate with Rich Results Test.
- **A11y:** Invisible JSON-LD — no accessibility impact.
- **Anti-pattern:** Never list unofficial or fan accounts. Never omit from homepage. Never use invalid JSON.

### Open Graph Profile Tags
- **When:** Personal profile pages, individual team member pages.
- **What:** `og:type="profile"` with `profile:first_name`, `profile:last_name`, `profile:username`. Keep standard OG tags too. Only for individual pages — team listing pages use `og:type="website"`.
- **A11y:** Invisible metadata — no accessibility impact.
- **Anti-pattern:** Never use og:type="profile" on multi-person pages. Never omit standard OG tags when using profile type.

### Fediverse Discovery (Webfinger)
- **When:** Projects wanting to establish domain-based identity on the fediverse.
- **What:** Static JSON file at `/.well-known/webfinger` mapping `acct:user@domain` to the actual fediverse account. Content-Type: `application/jrd+json`. Enables `@you@yourdomain.com` follows.
- **A11y:** Invisible protocol endpoint — no user-facing UI or accessibility impact.
- **Anti-pattern:** Never omit Content-Type header. Never return invalid JSON. Never map to inactive accounts.
