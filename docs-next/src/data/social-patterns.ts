export interface SocialPattern {
  name: string;
  category: 'profile_links' | 'share' | 'embeds' | 'feeds' | 'social_proof' | 'identity';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<SocialPattern['category'], string> = {
  profile_links: 'Profile Links',
  share: 'Share Buttons',
  embeds: 'Social Embeds',
  feeds: 'Social Feeds',
  social_proof: 'Social Proof',
  identity: 'Structured Identity',
};

export const categoryOrder: SocialPattern['category'][] = [
  'profile_links', 'share', 'embeds', 'feeds', 'social_proof', 'identity',
];

export const socialPatterns: SocialPattern[] = [
  // --- Profile Links ---
  {
    name: 'Icon Link Bar',
    category: 'profile_links',
    description: 'A horizontal row of social platform icons rendered as plain anchor links. Each icon is an inline SVG linking to the corresponding social profile. No third-party JavaScript is loaded — the browser only navigates when the user clicks. Commonly placed in the site footer, about page, or contact section. Popularized by every modern SaaS marketing site, from Stripe to Linear.',
    implementation: 'Render a <nav> or <ul> with one <a> per platform. Use inline SVGs for icons (no icon font CDN). Set rel="me noopener" and target="_blank" on each link. Space icons with flexbox gap (typically 0.75-1rem). Icon size: 20-24px for footers, 24-32px for hero sections. Use currentColor for SVG fill so icons inherit text color and adapt to light/dark themes.',
    a11y: '<nav aria-label="Social media links">. Each <a> has aria-label="Follow us on {Platform}" since the icon has no visible text. SVG icons: aria-hidden="true" (the link label carries the accessible name). Focus ring visible on all links. Minimum 44x44px touch target (pad with CSS if icon is smaller).',
    docsUrl: null,
  },
  {
    name: 'Branded Link Card',
    category: 'profile_links',
    description: 'Larger cards displaying the platform name, handle/username, and icon for each social account. Used in "Connect with us" or "Follow us" sections where more context than a bare icon is needed. Optionally shows a follower count fetched at build time (never client-side). Each card is a single anchor link to the profile page.',
    implementation: 'Card layout with platform icon (left), name + handle (center), and optional follower count (right). Entire card is an <a> element. Follower counts fetched via platform API at build time and baked into static HTML — never fetch client-side (avoids rate limits and tracking). Style with border, padding, and hover background. Use the platform brand color subtly (icon tint or left border accent).',
    a11y: 'Each card link has aria-label="{Platform}: @{handle}". Follower count is supplementary — do not make it the only content. Ensure sufficient color contrast for platform brand colors against card background (4.5:1 text, 3:1 decorative). Focus-visible outline on the card.',
    docsUrl: null,
  },
  {
    name: 'Author Attribution Link',
    category: 'profile_links',
    description: 'Social profile links displayed in article or blog post bylines. Links the author name or avatar to their social profile. Used to establish authorship and allow readers to follow the author. Commonly paired with Schema.org Person markup and rel="author" for search engine attribution.',
    implementation: 'Byline component: avatar (optional) + author name as <a> to profile. Add rel="author me" to the link. Include small social icons after the name for additional profiles. Keep inline with post metadata (date, reading time). For multi-author posts, show each author as a separate linked byline.',
    a11y: 'Author link: descriptive text (the name itself). Additional social icons: aria-label="Author on {Platform}". Do not rely solely on avatar images for author identification — always include the text name.',
    docsUrl: null,
  },
  {
    name: 'Floating Social Sidebar',
    category: 'profile_links',
    description: 'A fixed-position vertical strip of social icons along the left or right edge of the viewport. Stays visible while scrolling long content pages. Desktop only — hidden on mobile to preserve screen real estate. Icons are plain anchor links with no tracking scripts. Common on blogs, documentation sites, and content-heavy marketing pages.',
    implementation: 'position: fixed with top: 50%; transform: translateY(-50%) for vertical centering. Use a <nav> with flex-direction: column. Hide with display: none below 1024px breakpoint (mobile/tablet). Icons: 20px inline SVGs in <a> tags. Subtle background/border on hover. z-index below modals but above content. Add a slight left/right offset (16-24px) from viewport edge.',
    a11y: '<nav aria-label="Social links">. Each link: aria-label="Follow on {Platform}". The sidebar must not overlap or obscure main content. Do not trap keyboard focus — users should be able to Tab past it. Consider aria-hidden="true" when sidebar is display:none on mobile.',
    docsUrl: null,
  },
  {
    name: 'Bio Card with Social Links',
    category: 'profile_links',
    description: 'A team member or founder card displaying photo, name, role, short bio, and a row of social icon links. Used on about/team pages and speaker profiles. Each social icon is a plain anchor link. No third-party widgets or embeds — entirely static HTML.',
    implementation: 'Card with circular/rounded avatar (120-160px), name heading, role subtitle, 2-3 sentence bio paragraph, and a row of social icon links at the bottom. Use CSS Grid or Flexbox for the card layout. Avatar: <img> with proper alt text. Social links: same Icon Link Bar pattern. Responsive: stack vertically on narrow screens. Consider a grid of bio cards (2-3 columns) for team pages.',
    a11y: 'Avatar <img> has alt="{Name}, {Role}" or alt="" if name is displayed as text nearby. Social links within the card: aria-label="{Name} on {Platform}". Card itself is not an interactive element — only the links inside are focusable.',
    docsUrl: null,
  },

  // --- Share Buttons ---
  {
    name: 'Native Web Share API',
    category: 'share',
    description: 'Uses the browser\'s built-in navigator.share() API to trigger the OS-native share sheet. Supports sharing to any installed app (social media, messaging, email, notes). Progressive enhancement: the share button only renders if the API is available, with a fallback to manual share links. Zero third-party code — the browser handles everything.',
    implementation: 'Feature-detect with if (navigator.share). Call navigator.share({ title, text, url }) on button click. Wrap in try/catch to handle AbortError (user cancelled) gracefully. Fallback: if navigator.share is undefined, show Static Share Links instead. Use navigator.canShare() to validate data before calling share(). Available on mobile browsers, Safari, and Chromium desktop.',
    a11y: 'Button: <button aria-label="Share this page">. Include visible text or icon+text. Fallback links must be equally accessible. Do not auto-trigger share — always require explicit user click.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share',
  },
  {
    name: 'Static Share Link',
    category: 'share',
    description: 'Plain anchor links using each platform\'s share URL scheme. No JavaScript or third-party SDK required. The link navigates the user to the platform\'s share page with pre-populated title and URL. Works for Twitter/X, LinkedIn, Facebook, Reddit, Hacker News, WhatsApp, Telegram, and email. The simplest and most privacy-respecting share pattern.',
    implementation: 'Construct URLs with encodeURIComponent for parameters. Twitter: https://twitter.com/intent/tweet?url={url}&text={title}. LinkedIn: https://www.linkedin.com/shareArticle?mini=true&url={url}&title={title}. Facebook: https://www.facebook.com/sharer/sharer.php?u={url}. Reddit: https://reddit.com/submit?url={url}&title={title}. Open in new tab with target="_blank" rel="noopener". Pre-populate URL from canonical link, title from document.title or meta.',
    a11y: 'Each link: aria-label="Share on {Platform}". Links open in new window — include visual indicator or screen reader hint. Group in <nav aria-label="Share this page">. Minimum 44x44px touch targets.',
    docsUrl: null,
  },
  {
    name: 'Two-Click Share (Shariff)',
    category: 'share',
    description: 'A privacy-first share pattern developed by the German tech publisher c\'t/Heise. Shows a static, non-tracking preview button as the first click (consent). Only loads the actual platform share widget or navigates to the share URL on the second click (action). No third-party scripts are loaded until the user explicitly opts in. Compliant with strict European privacy regulations.',
    implementation: 'First state: static button with platform icon and "Share on X" text. No external resources loaded. On first click, swap to active state: either redirect to share URL (simple) or load the platform embed JS (widget mode). Add a visual transition (button color change, checkmark) to indicate activation. Store consent preference in sessionStorage to avoid re-consent on the same visit. Use the Shariff library or implement the two-state pattern manually.',
    a11y: 'First state: <button aria-label="Activate {Platform} sharing">. After activation: aria-label changes to "Share on {Platform}" or link is rendered. Announce state change with aria-live="polite" or by changing button text. Keyboard: Enter/Space activates both clicks.',
    docsUrl: 'https://github.com/heiseonline/shariff',
  },
  {
    name: 'Copy Link Button',
    category: 'share',
    description: 'A "Copy link" button that copies the current page URL to the clipboard using the Clipboard API. Shows a brief confirmation (checkmark icon or "Copied!" text). Platform-independent, works everywhere, and is the most privacy-respecting share option since no data leaves the browser. Should be included as the first or fallback option in any share button group.',
    implementation: 'Use navigator.clipboard.writeText(url) on click. Show success feedback: swap icon to checkmark, add "Copied!" text, or show a toast. Revert after 2 seconds. Use the canonical URL (from <link rel="canonical"> or window.location.href). Handle errors gracefully (clipboard API may be blocked in some contexts). Fallback: select-all in a hidden input for older browsers.',
    a11y: 'Button: <button aria-label="Copy page link to clipboard">. Success: announce with aria-live="polite" region or update button text to "Link copied". Do not use alert() for confirmation. Keyboard accessible: Enter/Space triggers copy.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText',
  },
  {
    name: 'Email Share Link',
    category: 'share',
    description: 'A mailto: link that opens the user\'s default email client with the page title as subject and URL + excerpt as body. Zero tracking, universal compatibility, works on all devices. Often overlooked but remains one of the most-used sharing methods, especially in professional and B2B contexts.',
    implementation: 'Construct: mailto:?subject={encodedTitle}&body={encodedBody}. Body format: "{excerpt}\\n\\nRead more: {url}". Use encodeURIComponent for all parameters. Keep subject under 78 characters. Keep body concise (2-3 sentences + URL). Render as an <a> tag, not a button. Style consistently with other share icons.',
    a11y: 'Link: aria-label="Share via email". Opens external app — screen readers will announce the mailto: protocol. No new-tab indicator needed since it opens a native app, not a browser tab.',
    docsUrl: null,
  },
  {
    name: 'Share Preview Card',
    category: 'share',
    description: 'Shows a visual preview of how the shared post will appear on social platforms before the user clicks share. Displays the OG image, title, and description as a mock social card. Builds user confidence by showing exactly what recipients will see. Data is sourced entirely from the page\'s own meta tags — no external API calls.',
    implementation: 'Read og:title, og:description, og:image from the page\'s <meta> tags (or pass as props). Render a card matching the typical social preview format: image on top (1.91:1 aspect ratio), title below, description truncated to 2 lines, domain name. Style with subtle border and shadow. Position above or alongside the share buttons. Update preview if the page has different OG tags per section.',
    a11y: 'Preview card is decorative/informational — not interactive itself. Image: alt text from og:title or empty alt if title is displayed as text. Ensure text contrast meets WCAG AA within the preview card.',
    docsUrl: null,
  },

  // --- Social Embeds ---
  {
    name: 'Facade Embed (Click-to-Load)',
    category: 'embeds',
    description: 'Shows a static screenshot or placeholder image of the social content instead of the actual embed. The real iframe or embed script loads only when the user explicitly clicks. Massively improves page load performance (embeds can add 500KB-2MB of JS) and blocks all tracking until consent. Works for Twitter/X posts, YouTube videos, Instagram posts, TikTok, and any iframe-based embed.',
    implementation: 'Render a <button> or clickable <div> containing: a static image (screenshot or thumbnail), the platform logo overlay, and a "Load embed" or play button icon. On click, replace the placeholder with the actual <iframe> or <script>-based embed. For YouTube: use the video thumbnail (https://img.youtube.com/vi/{id}/maxresdefault.jpg) and load the iframe on click. Use loading="lazy" on the iframe. Add a subtle "Click to load content from {Platform}" label.',
    a11y: 'Placeholder: <button aria-label="Load {Platform} embed: {content title}">. After loading: the iframe should have title="{content description}". Announce load completion with aria-live="polite". Keyboard: Enter/Space triggers load. Focus should move into the loaded embed if it is interactive.',
    docsUrl: null,
  },
  {
    name: 'Privacy-Proxied Embed',
    category: 'embeds',
    description: 'Uses privacy-enhanced embed URLs that strip tracking cookies and scripts. YouTube\'s youtube-nocookie.com domain is the canonical example — it serves video without setting cookies until the user plays. For Twitter/X, use a static screenshot + link instead of the widget JS. For other platforms, self-hosted proxies or server-rendered snapshots replace tracking-heavy embeds.',
    implementation: 'YouTube: replace youtube.com/embed with youtube-nocookie.com/embed. Add &rel=0 to disable related video suggestions. Vimeo: add ?dnt=1 (Do Not Track parameter). Twitter: render tweet text as a styled <blockquote> with a "View on Twitter" link. Instagram: server-render the post image + caption at build time. Set the iframe sandbox attribute to restrict capabilities: sandbox="allow-scripts allow-same-origin".',
    a11y: 'Same requirements as standard embeds: iframe title attribute, keyboard accessibility. Privacy-proxied URLs should not change the user-facing content or controls. If using blockquote fallback, ensure the attribution link is clearly labeled.',
    docsUrl: 'https://support.google.com/youtube/answer/171780',
  },
  {
    name: 'Blockquote Fallback Embed',
    category: 'embeds',
    description: 'Renders social media content as a styled HTML <blockquote> with attribution, instead of using an iframe or embed script. Zero JavaScript, zero tracking, zero external requests. The content is static text with a link to the original post. Accessible, fast, and works everywhere. This is the ideal fallback for any social embed and the default for content that does not require interactivity (tweets, quotes, text posts).',
    implementation: 'Structure: <blockquote cite="{post-url}"><p>{post text}</p><footer>— <a href="{post-url}" rel="noopener" target="_blank">{author} on {Platform}, {date}</a></footer></blockquote>. Style with a left border accent, subtle background, platform icon. Include the author avatar as a small <img> if available (self-hosted copy). For tweets: preserve @mentions and #hashtags as plain text or links. Sanitize all user-generated content.',
    a11y: '<blockquote> with cite attribute for the source URL. Attribution in <footer> or <figcaption>. If wrapped in <figure>, use <figcaption> for attribution. Screen readers announce blockquotes natively. Ensure link text is descriptive ("View original post by @author").',
    docsUrl: null,
  },
  {
    name: 'Consent-Gated Embed Wall',
    category: 'embeds',
    description: 'For pages with multiple social embeds, shows a single consent banner instead of individual click-to-load buttons on each embed. The user grants consent once, and all embeds on the page load simultaneously. Respects cookie/consent preferences and integrates with the site\'s cookie consent manager. Reduces friction for content-heavy pages with many embeds while maintaining privacy compliance.',
    implementation: 'Before consent: replace all embed slots with a uniform placeholder showing platform name and a "Load all {Platform} embeds" button. Store consent in a cookie or localStorage, keyed by platform. After consent: inject all iframes. Integrate with the site-wide consent manager (if using one) so social embed consent is a separate category. Provide "Revoke consent" option in privacy settings. On subsequent visits, check stored consent before loading.',
    a11y: 'Consent banner: role="region" aria-label="External content consent". Button: "Load {count} {Platform} embeds on this page". After loading, announce with aria-live="polite": "{count} embeds loaded". Provide a way to revoke consent that is discoverable (privacy settings or a persistent "Loaded via consent" indicator).',
    docsUrl: null,
  },
  {
    name: 'Server-Rendered Social Card',
    category: 'embeds',
    description: 'Fetches social media post data at build time (via API or scraping) and renders it as static HTML. The card looks like a social media post (avatar, name, text, images, timestamp) but is entirely self-hosted with zero runtime external requests. Ideal for documentation, case studies, and testimonial pages where embed content is known ahead of time and does not need to be live.',
    implementation: 'At build time: fetch post data from the platform API (Twitter API v2, Instagram oEmbed, etc.). Store the response in a local JSON file. Render the card with: avatar image (self-hosted copy), author name, post text, media (self-hosted copies), and timestamp. Link to original with "View on {Platform}". Cache API responses to avoid rate limits. Re-fetch on deploy or on a schedule. Handle deleted posts gracefully (show "This post is no longer available").',
    a11y: 'Card is a <figure> with <figcaption> for attribution. Images: descriptive alt text. Timestamp: <time datetime="{ISO}">. Text content: use semantic HTML (paragraphs, links). The card is not interactive beyond the "View original" link.',
    docsUrl: null,
  },

  // --- Social Feeds ---
  {
    name: 'Static Feed Snapshot',
    category: 'feeds',
    description: 'Fetches the latest N posts from a social media API at build time and renders them as static HTML cards. The feed only refreshes when the site is rebuilt/deployed. No client-side API calls, no real-time updates, no tracking scripts. Fast, private, and reliable. Ideal for homepages, sidebars, and marketing pages where freshness within hours is acceptable.',
    implementation: 'At build time: call the platform API (Twitter v2, Mastodon, Bluesky, LinkedIn) for the latest 3-5 posts. Transform response into a normalized data format. Render as a grid or list of static cards (avatar, name, text, media, timestamp, link to original). Self-host all images. Set a Rebuild schedule (hourly, daily) via CI/CD. Handle API failures gracefully (use cached data). Show "Last updated: {date}" footer.',
    a11y: 'Feed container: <section aria-label="Latest posts from {Platform}">. Each post: <article> with heading (author name) and content. Timestamps: <time> element. Images: alt text. Links: "View post on {Platform}". Avoid auto-scrolling or auto-updating.',
    docsUrl: null,
  },
  {
    name: 'RSS-Powered Feed',
    category: 'feeds',
    description: 'Consumes an RSS or Atom feed instead of a proprietary platform API. Platform-agnostic — works with Mastodon, Bluesky, WordPress, Ghost, Medium, Substack, YouTube channels, and any service that publishes RSS. Rendered server-side at build time. No API keys required for most feeds, making this the most maintainable feed pattern.',
    implementation: 'Parse the RSS/Atom XML at build time with a lightweight parser. Extract: title, link, description/content, pubDate, author, and enclosure (media). Render as styled post cards. For Mastodon: use the /users/{handle}.rss endpoint. For YouTube: use the channel RSS feed (https://www.youtube.com/feeds/videos.xml?channel_id={id}). Sanitize all HTML content from feeds. Limit to 5-10 items. Cache parsed feed data.',
    a11y: 'Same as Static Feed Snapshot. Content from RSS may contain raw HTML — sanitize and ensure it meets contrast and structure requirements. Strip inline styles from feed content. Ensure all feed-sourced images have alt text (use title as fallback).',
    docsUrl: null,
  },
  {
    name: 'Hybrid Feed (Static + Client Refresh)',
    category: 'feeds',
    description: 'Combines a build-time static snapshot with an optional client-side "Load latest" button. The page loads instantly with pre-rendered content (no loading spinners). Users who want fresher data can explicitly request it. No auto-polling, no background fetches. The client refresh is user-initiated only, keeping the pattern privacy-respecting.',
    implementation: 'Render the build-time snapshot as the default view. Add a "Load latest" button below the feed. On click: fetch from your own API proxy (never directly from the social platform client-side) and replace/prepend new items. Show a loading indicator during fetch. If no new items, show "You\'re up to date". Rate-limit the refresh button (disable for 30 seconds after click). The proxy endpoint should cache and rate-limit upstream API calls.',
    a11y: 'Refresh button: <button aria-label="Load latest posts">. During loading: aria-busy="true" on the feed container. After update: announce "{count} new posts loaded" via aria-live="polite". New items should be added to the DOM without disrupting focus or scroll position.',
    docsUrl: null,
  },
  {
    name: 'Testimonial Wall',
    category: 'feeds',
    description: 'A curated collection of social media mentions, reviews, or endorsements displayed as testimonial cards. Content is manually curated or semi-automatically fetched and approved. No live connection to any platform. Attribution links point to the original post. Used on landing pages, about pages, and case study sections for social proof.',
    implementation: 'Store testimonials in a data file (JSON, YAML, or CMS). Each entry: author name, handle, avatar (self-hosted), quote text, platform, original post URL, and date. Render as a responsive grid (2-3 columns) or masonry layout. Include platform icon for attribution. Optionally rotate/randomize a subset on each build. Keep testimonials curated — auto-importing all mentions leads to quality control issues.',
    a11y: 'Each testimonial: <blockquote> with <footer> for attribution. If using a carousel, provide prev/next buttons and pause auto-rotation. Avatar: alt="{Name}". Grid: ensure logical tab order. Do not use auto-playing animations or auto-scrolling.',
    docsUrl: null,
  },

  // --- Social Proof ---
  {
    name: 'Static Counter Display',
    category: 'social_proof',
    description: 'Displays follower counts, GitHub stars, download numbers, or user counts as formatted static numbers. Values are fetched at build time and baked into the HTML. No real-time counter widgets, no client-side API calls, no animated counting. Stale-while-revalidate is acceptable — exact real-time counts add complexity without meaningful UX benefit.',
    implementation: 'Fetch counts from APIs at build time (GitHub API, npm registry, social platform APIs). Format with Intl.NumberFormat or abbreviate (e.g., "12.3k"). Display with a label and icon. Layout: horizontal row of metric cards or inline badges. Refresh on each deploy. Cache API responses. Handle API failures by falling back to the last known value. Show "as of {date}" for transparency.',
    a11y: 'Each counter: <span aria-label="{count} {metric} on {Platform}">. Abbreviated numbers (12.3k) need the full number in aria-label. Do not use decorative animations (no counting-up effect unless prefers-reduced-motion is checked).',
    docsUrl: null,
  },
  {
    name: 'GitHub Star Badge',
    category: 'social_proof',
    description: 'A compact badge showing the GitHub star count for a repository. Links to the repo. Uses either a shields.io badge image (build-time snapshot) or a static count rendered in HTML. Avoids the official GitHub star button widget which loads external JS and tracks users.',
    implementation: 'Option A (shields.io): <img src="https://img.shields.io/github/stars/{owner}/{repo}?style=social" alt="{count} GitHub stars">. Build-time: fetch via GitHub API and render as static HTML with star icon + number. Link: <a href="https://github.com/{owner}/{repo}">. Style: pill-shaped badge with star icon. Self-host the shields.io image at build time for full privacy.',
    a11y: 'Badge image: alt="{repo} has {count} stars on GitHub". If using HTML: <a aria-label="{count} GitHub stars — view repository">. Star icon: aria-hidden="true". Ensure badge text meets minimum contrast ratio.',
    docsUrl: 'https://shields.io/',
  },
  {
    name: 'Testimonial Carousel',
    category: 'social_proof',
    description: 'A rotating display of customer testimonials or social media endorsements. Content is stored in a local data file — never fetched from social platforms at runtime. Shows one testimonial at a time with prev/next navigation and auto-rotation (with pause on hover/focus). Used in hero sections and above-the-fold social proof areas where space is limited.',
    implementation: 'Store testimonials in a data file (array of { quote, author, role, company, avatar }). Render a carousel with CSS scroll-snap or a minimal JS slider. Auto-rotation interval: 5-8 seconds. Pause on hover and focus. Include dot indicators + prev/next buttons. Show 1 item on mobile, optionally 2-3 on desktop. Preload adjacent testimonial images. No third-party carousel libraries (they add unnecessary JS and often include tracking).',
    a11y: 'role="region" aria-roledescription="carousel" aria-label="Customer testimonials". Each slide: role="group" aria-roledescription="slide" aria-label="{index} of {total}". Auto-rotation: must pause on focus and hover. Provide visible pause button. Prev/next: aria-label="Previous/Next testimonial". Dots: aria-label="Go to testimonial {index}".',
    docsUrl: 'https://www.w3.org/WAI/ARIA/apg/patterns/carousel/',
  },
  {
    name: 'User Count Banner',
    category: 'social_proof',
    description: '"Join 5,000+ developers" — a simple banner or inline element displaying the user/customer count. Placed above the fold, near primary CTAs, or in the site header. The count is updated manually or at build time. No live counter widget. Combined with a call-to-action, this is one of the highest-impact social proof patterns for conversion.',
    implementation: 'Display format: "Join {count}+ {audience}" or "Trusted by {count} teams". Use a round/floor number (5,000 not 5,127) for cleaner presentation. Update the count in a data file or environment variable. Placement: directly above or below the primary CTA button. Pair with small avatar stack (3-5 overlapping circular avatars) for visual reinforcement. Keep the banner text concise — one line maximum.',
    a11y: 'Text: plain HTML paragraph or heading. No special ARIA needed — it is regular content. If using an avatar stack, images should have alt="" (decorative) since the text carries the meaning. Ensure the count is not the only indication of value — pair with descriptive text.',
    docsUrl: null,
  },

  // --- Structured Identity ---
  {
    name: 'rel="me" Verification',
    category: 'identity',
    description: 'Bidirectional identity verification between your website and social profiles using the rel="me" HTML attribute. When your site links to a social profile with rel="me" AND that profile links back to your site, platforms like Mastodon display a verified checkmark. This is the IndieWeb standard for decentralized identity verification — no central authority required.',
    implementation: 'Add rel="me" to all social profile links on your site: <a href="https://mastodon.social/@you" rel="me">. Then add your website URL to each social profile\'s bio/website field. Mastodon verifies automatically by checking for the bidirectional link. GitHub: add your site URL to your profile. For maximum verification coverage, place rel="me" links on your homepage (not just a subpage). Combine with rel="noopener" for external links: rel="me noopener".',
    a11y: 'rel="me" is invisible to users — it is metadata for machines. No accessibility impact. The visible link text and aria-label should describe the destination, not the rel attribute.',
    docsUrl: 'https://indieweb.org/rel-me',
  },
  {
    name: 'Schema.org sameAs',
    category: 'identity',
    description: 'Lists all official social media profile URLs in the site\'s structured data (JSON-LD) using the Schema.org sameAs property. Search engines use this to connect your website identity with your social accounts, enabling Knowledge Panel population and entity disambiguation. AI agents also parse sameAs to identify official channels.',
    implementation: 'Add a JSON-LD block to the homepage (or every page) with Organization or Person type. Include sameAs as an array of URLs: "sameAs": ["https://twitter.com/you", "https://github.com/you", "https://linkedin.com/in/you", "https://mastodon.social/@you"]. Keep the list comprehensive — include all official accounts. Place in <head> via a <script type="application/ld+json"> tag. Validate with Google Rich Results Test.',
    a11y: 'JSON-LD is invisible to users and screen readers. No accessibility impact. It is purely machine-readable metadata.',
    docsUrl: 'https://schema.org/sameAs',
  },
  {
    name: 'Open Graph Profile Tags',
    category: 'identity',
    description: 'Specialized Open Graph meta tags for personal or team profile pages. Uses og:type="profile" with additional profile-specific properties: profile:first_name, profile:last_name, profile:username, and profile:gender. When a profile page is shared on social media, platforms display it with a person-specific card format rather than a generic article card.',
    implementation: 'Add to <head> on profile/about/team pages: <meta property="og:type" content="profile" />, <meta property="profile:first_name" content="{First}" />, <meta property="profile:last_name" content="{Last}" />, <meta property="profile:username" content="{handle}" />. Keep standard OG tags too (og:title, og:description, og:image). For team pages with multiple people, the page-level og:type should be "website" — use profile type only on individual profile pages.',
    a11y: 'OG tags are invisible metadata. No accessibility impact. They only affect how the page appears when shared on social platforms.',
    docsUrl: 'https://ogp.me/#type_profile',
  },
  {
    name: 'Fediverse Discovery (Webfinger)',
    category: 'identity',
    description: 'A .well-known/webfinger endpoint that enables ActivityPub/fediverse discovery from your domain. Users on Mastodon, Pixelfed, or other fediverse platforms can follow @you@yourdomain.com, which resolves to your actual fediverse account via the Webfinger protocol. Establishes your domain as your decentralized identity anchor.',
    implementation: 'Create a .well-known/webfinger endpoint that returns JSON. For static sites: create a static JSON file at /.well-known/webfinger with the appropriate response. The resource parameter should map your-domain to your fediverse account. Response: { "subject": "acct:user@yourdomain.com", "aliases": ["https://mastodon.social/@you"], "links": [{ "rel": "self", "type": "application/activity+json", "href": "https://mastodon.social/users/you" }] }. Add Content-Type: application/jrd+json header (or rely on file extension for static hosting). For dynamic sites, implement as an API route that handles the resource query parameter.',
    a11y: 'Webfinger is an invisible protocol endpoint. No user-facing UI required. No accessibility impact.',
    docsUrl: 'https://webfinger.net/',
  },
];
