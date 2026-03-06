export interface OnboardingPattern {
  name: string;
  category: 'tours' | 'highlights' | 'checklists' | 'announcements' | 'guidance' | 'tracking';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<OnboardingPattern['category'], string> = {
  tours: 'Product Tours',
  highlights: 'Coachmarks & Spotlights',
  checklists: 'Checklists & Milestones',
  announcements: 'Announcements & Changelog',
  guidance: 'Guidance & Empty States',
  tracking: 'Tracking & Re-engagement',
};

export const categoryOrder: OnboardingPattern['category'][] = [
  'tours', 'highlights', 'checklists', 'announcements', 'guidance', 'tracking',
];

export const onboardingPatterns: OnboardingPattern[] = [
  // --- Tours ---
  {
    name: 'Multi-Step Product Tour',
    category: 'tours',
    description: 'A sequential walkthrough that guides new users through 3-7 key interface elements. Each step highlights a UI element with a tooltip explaining its purpose. Effective tours are short (under 60 seconds), focused on the activation moment, and allow skipping at any step. Research from Appcues shows tours with 3-5 steps have 72% completion rates versus 45% for tours with 8+ steps. The first step should orient the user ("Here\'s your dashboard"), not instruct ("Click this button").',
    implementation: 'Render an overlay layer (z-index: 9999) with a backdrop that dims everything except the active element. Position tooltips using floating-ui/popper.js relative to the target. Each step: {target: CSS selector, title, content, placement}. Store tour state in localStorage (currentStep, dismissed). Use requestAnimationFrame to reposition on scroll/resize. Step transitions: smooth opacity + translateY animation (200ms). On last step, show a congratulatory micro-animation. Navigation: "Next" primary button, "Skip tour" text link, step indicators (dots).',
    a11y: 'Tour overlay: role="dialog" aria-label="Product tour, step N of M". Each tooltip: aria-describedby for content. Focus trap within active tooltip — Tab cycles between Next, Skip, and close button. When advancing steps, move focus to the new tooltip. Skip button: aria-label="Skip remaining tour steps." On tour completion or skip, return focus to the element that triggered the tour (or first interactive element). Announce step changes via aria-live="polite": "Step 2 of 5: Your project dashboard."',
    docsUrl: null,
  },
  {
    name: 'Segmented Tour Paths',
    category: 'tours',
    description: 'Different tour sequences based on user role, plan, or stated goal. Instead of one generic tour, a segmentation question ("What brings you here? Building a project / Managing a team / Exploring") routes users to a tailored 3-5 step tour highlighting the features most relevant to them. Pendo research shows segmented tours have 40% higher completion and 25% higher activation than one-size-fits-all tours. Store the segment choice for future personalization.',
    implementation: 'Show a segmentation modal on first login with 2-4 options (cards or large buttons, not a dropdown). Map each choice to a tour config: {segment: string, steps: Step[]}. Store segment in user profile (server-side) and localStorage (client-side). Load the matching tour config on selection. Allow switching segments later from settings. Each segment can share common steps (e.g., "here\'s your profile") while differing on domain-specific steps. Track segment distribution in analytics for product insights.',
    a11y: 'Segmentation modal: role="dialog" aria-label="Choose your path." Options: role="radiogroup" with role="radio" for each choice. Keyboard: arrow keys between options, Enter to confirm. Focus starts on the first option. Selected state: aria-checked="true". Do not auto-advance on selection — require explicit confirmation button.',
    docsUrl: null,
  },
  {
    name: 'Delayed Tour Trigger',
    category: 'tours',
    description: 'Launching the product tour after the user has had a moment to orient, rather than immediately on first page load. Research from UserGuiding shows tours triggered after a 3-5 second delay or after a first interaction (scroll, click) have 30% higher engagement than immediate tours. The principle: let users absorb the interface before overlaying instructions. Exception: if the first action is completely non-obvious, an immediate coachmark on the primary CTA is acceptable.',
    implementation: 'Use a combination of delay timer and interaction detection. On first visit: set a 3-5s setTimeout that checks if the user has already interacted (scroll, click, keypress). If they have, trigger the tour immediately. If the timer fires without interaction, trigger then. Use IntersectionObserver on key elements to verify they are visible before starting. Cancel the tour trigger if the user has already navigated away from the landing page. Store trigger state in sessionStorage to avoid re-triggering on page refresh.',
    a11y: 'Do not surprise users — provide a brief "Would you like a quick tour?" prompt before starting (role="alertdialog"). Never auto-launch a tour with focus trap without user consent. The prompt: two buttons ("Show me around" primary, "No thanks" secondary). If declined, offer tour access from a help menu. Respect prefers-reduced-motion: skip entrance animations but keep content.',
    docsUrl: null,
  },
  {
    name: 'Tour Resume & Replay',
    category: 'tours',
    description: 'Allowing users to resume an interrupted tour from where they left off, and replay completed tours from a help menu. Users frequently abandon tours mid-way (page navigation, accidental close, distraction). Offering a gentle "Continue your tour?" prompt on their next visit recovers 20-30% of abandoned tours. A "Replay tour" option in the help menu serves users who dismissed prematurely and later want guidance.',
    implementation: 'Persist tour progress: {tourId, currentStep, totalSteps, lastSeen: timestamp} in localStorage or user profile. On page load, check for incomplete tours. If found and <7 days old, show a non-blocking toast: "Continue your tour? (Step 3 of 5)" with Resume and Dismiss buttons. For replay: add a "Product tour" item in the help/support menu that resets tour state and relaunches. Track resume vs. dismiss rates in analytics. Clear stale tour state after 30 days.',
    a11y: 'Resume prompt: role="status" with aria-live="polite" — do not steal focus. Dismiss button: aria-label="Dismiss tour reminder." Help menu replay item: standard menu item, no special roles needed. When resuming, announce: "Resuming product tour at step 3 of 5" via aria-live.',
    docsUrl: null,
  },
  {
    name: 'Guided Setup Wizard',
    category: 'tours',
    description: 'A focused multi-step flow that walks users through essential first-time configuration (workspace name, invite teammates, connect integrations, choose preferences). Unlike product tours that show existing UI, setup wizards collect input and configure the product. Keep it to 3-5 steps. Offering a "Skip for now" link on non-critical steps prevents abandonment. Notion, Linear, and Vercel use this pattern effectively — each step creates tangible value the user sees immediately after completion.',
    implementation: 'Full-page or modal wizard with step indicator (numbered stepper or progress bar). Each step: isolated form with validation. Navigation: Back, Next (disabled until valid), Skip (on optional steps). Final step: "Get Started" CTA that redirects to the configured workspace. Save progress server-side after each step so refreshing does not lose data. If abandoned, offer to resume on next login. Use optimistic transitions — show the next step immediately while saving in background.',
    a11y: 'Wizard container: role="group" aria-label="Setup wizard, step N of M." Step indicator: aria-current="step" on active step, aria-disabled on future steps. Form inputs: standard label/input associations. Back/Next: aria-label includes step context ("Go to step 2: Invite team"). Progress: announce step changes via aria-live="polite". Skip link: aria-label="Skip this step, you can configure later in settings."',
    docsUrl: null,
  },

  // --- Highlights ---
  {
    name: 'Spotlight Coachmark',
    category: 'highlights',
    description: 'A dark overlay that dims the entire interface except for a single highlighted element, drawing the user\'s attention with a "spotlight" effect. A tooltip adjacent to the highlighted element explains its purpose. This is the most common coachmark pattern. Effective for introducing a single critical feature. Use sparingly — research from Chameleon shows that more than 3 spotlights in sequence causes 60% drop-off. Best for post-action moments: "You just created a project. Here\'s where you\'ll find it."',
    implementation: 'Create a full-viewport overlay (position: fixed, inset: 0) with a semi-transparent background. Cut out the target element using CSS clip-path (polygon or inset with border-radius), SVG mask, or box-shadow with a large spread. Use floating-ui to position the tooltip relative to the cutout. The highlighted element should remain interactive (pointer-events: auto on the element, none on surrounding overlay). Animate the cutout appearing with a scale transition from the element center. Dismiss on: clicking outside, pressing Escape, or clicking the CTA.',
    a11y: 'Overlay: role="dialog" aria-modal="true" aria-label="Feature highlight." The highlighted element must remain keyboard-accessible through the overlay. Tooltip: aria-describedby linked to tooltip content. Close button: visible and keyboard-accessible. Escape key dismisses. On dismiss, focus returns to the highlighted element. For screen readers, announce: "[Feature name]: [description]" via aria-live. Do not trap focus if the goal is for the user to interact with the highlighted element.',
    docsUrl: null,
  },
  {
    name: 'Tooltip Hotspot',
    category: 'highlights',
    description: 'A small pulsing dot or beacon placed next to a feature, indicating there is contextual information available. Clicking or hovering the hotspot reveals a tooltip with guidance. Unlike spotlights, hotspots are non-blocking — the user can ignore them and continue working. Effective for introducing secondary features without interrupting the primary flow. Slack and Figma use hotspots for gradual feature discovery. Hotspots should auto-dismiss after the user has interacted with the associated feature 2-3 times.',
    implementation: 'Render a small circle (8-12px) with a CSS pulse animation (scale + opacity keyframes, 2s infinite). Position absolutely relative to the target element. On click: show a tooltip (floating-ui) with title, description, optional CTA, and "Got it" dismiss button. Track hotspot interactions: {featureId, seen: boolean, interacted: boolean, dismissedAt: timestamp}. Auto-remove after the user has used the feature (check via feature-specific event). Limit to 3 visible hotspots at once to avoid clutter.',
    a11y: 'Hotspot: <button aria-label="Learn about [feature name]" aria-expanded="false/true">. Pulse animation: respect prefers-reduced-motion (static dot instead). Tooltip: role="tooltip" with aria-describedby. Dismiss: Escape key or "Got it" button. Do not use hover-only activation — must work with click/keyboard. Announce tooltip content on open: aria-live="polite". Hotspot should be in the tab order near the feature it describes.',
    docsUrl: null,
  },
  {
    name: 'Feature Callout Banner',
    category: 'highlights',
    description: 'An inline banner or card placed near a feature to highlight what is new or changed. Unlike overlays, callout banners are part of the page flow and do not obscure other content. Effective for announcing incremental improvements to existing features ("New: You can now filter by date range"). Include a dismiss button and a link to learn more. Callouts are less disruptive than modals and have higher read rates (Intercom reports 3x the engagement of modal announcements for incremental updates).',
    implementation: 'Render an inline div with a distinct background (accent-bg), left border accent, icon (sparkle/new badge), text, "Learn more" link, and close button. Position within the page flow near the relevant feature (above the feature section, or as a first item in a list). Store dismissal in localStorage: {calloutId: dismissedAt}. Show for a maximum of 14 days after feature launch, then auto-remove. Use CSS animation: slide-down + fade-in on first render. Collapse smoothly on dismiss (height transition).',
    a11y: 'Container: role="status" aria-label="New feature announcement." Close button: aria-label="Dismiss announcement." Link: standard anchor with descriptive text (not "Click here"). Do not use aria-live for static banners — they are already in the page flow. Ensure sufficient contrast between banner background and text. If banner contains an action button, it should be keyboard-focusable.',
    docsUrl: null,
  },
  {
    name: 'Contextual Tip',
    category: 'highlights',
    description: 'A brief, non-modal tip that appears inline when the user encounters a feature for the first time. Unlike tooltips (which appear on hover), contextual tips are visible by default and persist until dismissed. They educate during the natural workflow: "Pro tip: Use Cmd+K to search anything." Show at most one contextual tip per page view. Dismiss permanently on close, and stop showing tips for a feature once the user demonstrates proficiency (e.g., used the keyboard shortcut 3 times).',
    implementation: 'Render as a small card (max-width: 280px) with an info icon, tip text, and "Got it" button. Position inline or adjacent to the relevant feature. Track tips per user: {tipId, shown: boolean, dismissed: boolean, proficiencyCount: number}. Show tip only when: not dismissed AND proficiencyCount < 3 AND no other tip is visible on the page. Use a tip queue — if multiple tips qualify, show the highest priority one. Priority: activation-critical > efficiency > nice-to-know. Fade in with 300ms delay after page load.',
    a11y: 'Tip container: role="note" aria-label="Tip." Dismiss button: aria-label="Dismiss tip." Content should be concise (under 100 characters). Do not use role="alert" — tips are not urgent. If the tip references a keyboard shortcut, use <kbd> elements. Ensure tip does not overlap interactive elements. Tip should not receive focus automatically — let the user discover it naturally.',
    docsUrl: null,
  },
  {
    name: 'Beacon Pulse Animation',
    category: 'highlights',
    description: 'A subtle pulsing animation (expanding rings or glowing dot) attached to a navigation item, button, or icon to signal that something requires attention or is new. Used by Slack (new messages), GitHub (new notifications), and Intercom (unread updates). Unlike badges that show counts, beacons signal "look here" without quantifying. Effective for drawing attention to settings the user should configure, or features they haven\'t explored yet. Should disappear after the user visits the indicated area.',
    implementation: 'CSS-only animation: a ::before pseudo-element on the target with border-radius: 50%, scale keyframes (1 to 2.5), and opacity keyframes (0.6 to 0). Duration: 1.5-2s, infinite repeat. Color: accent color at 40% opacity. Size: 8-10px dot with expanding rings reaching 24px. Use will-change: transform, opacity for GPU acceleration. Track beacon state: show until the user clicks the associated element, then remove. Limit to 2 simultaneous beacons app-wide. Remove after 30 days regardless of interaction.',
    a11y: 'Respect prefers-reduced-motion: replace animation with a static colored dot. Add aria-label to the parent element: "Settings (new)" or equivalent. Do not rely solely on animation to convey information — pair with a text indicator for screen readers. Beacon should not interfere with the click target of the element it\'s attached to. Use aria-live="polite" to announce the presence of new items if the beacon appears dynamically.',
    docsUrl: null,
  },

  // --- Checklists ---
  {
    name: 'Onboarding Checklist',
    category: 'checklists',
    description: 'A persistent list of 4-7 setup tasks that new users should complete to get value from the product. Each task has a clear label, an action link, and a completion state. Checklists leverage the Zeigarnik Effect (people remember incomplete tasks) and create a sense of progress. Appcues research shows checklists increase activation rates by 30% compared to tours alone. Position as a sidebar widget, dashboard card, or slide-out panel. Mark tasks complete automatically when the user performs the action.',
    implementation: 'Data model: {tasks: [{id, title, description, actionUrl, completed, completedAt, autoDetect: eventName}], progress: number}. Render as a card with a progress bar (completedCount/totalCount), task list with checkmarks, and action buttons. Auto-detect completion by subscribing to app events (e.g., "project_created", "teammate_invited"). Manual override: allow checking off tasks. Persist in user profile (server-side). Show celebration animation (confetti or checkmark burst) at 100%. Hide checklist 3 days after full completion. Position: bottom-right floating panel or dashboard widget.',
    a11y: 'Checklist container: role="group" aria-label="Getting started checklist, N of M complete." Each task: role="listitem" with a checkbox (role="checkbox" aria-checked). Completed tasks: aria-label includes "completed." Progress bar: role="progressbar" aria-valuenow aria-valuemin aria-valuemax aria-label="Setup progress." Celebration: use aria-live="assertive" to announce "All tasks complete! You\'re all set." Action links: standard anchors, open in same tab (not new window).',
    docsUrl: null,
  },
  {
    name: 'Progress Milestone Bar',
    category: 'checklists',
    description: 'A visual progress indicator showing how far the user has come in their onboarding journey. Unlike simple progress bars, milestone bars mark key achievements (first project, first collaboration, first publish) with icons or labels. Reaching a milestone triggers a celebration moment and optionally unlocks a feature or reward. Duolingo and GitHub (contribution graph) use milestone patterns to sustain engagement. Best placed at the top of the dashboard or in a dedicated "Getting Started" section.',
    implementation: 'Render a horizontal segmented progress bar with milestone markers at specific percentages (e.g., 25%, 50%, 75%, 100%). Each segment fills with accent color as tasks complete. Milestone markers: circular icons that transition from gray to accent-colored with a scale bounce animation on completion. Below the bar: labels for each milestone ("Profile set up", "First project", "Team invited", "First deploy"). Store milestone state: {milestoneId, reached: boolean, reachedAt: timestamp, celebrated: boolean}. Show micro-animation on milestone reach (only once).',
    a11y: 'Progress bar: role="progressbar" aria-valuenow aria-valuemin="0" aria-valuemax="100" aria-label="Onboarding progress." Milestones: role="listitem" within a role="list" aria-label="Milestones." Reached milestones: aria-label="[name], completed." Unreached: aria-label="[name], not yet reached." Celebration animation: announce via aria-live="polite" — "Milestone reached: [name]." Respect prefers-reduced-motion for animations.',
    docsUrl: null,
  },
  {
    name: 'Gamified Task Completion',
    category: 'checklists',
    description: 'Adding game mechanics (points, badges, streaks, celebrations) to onboarding tasks to increase motivation and completion rates. Effective when the onboarding requires 5+ actions spread across multiple sessions. Duolingo, GitHub, and Notion use gamification to sustain engagement. Key principle: reward the behavior you want to encourage, not just task completion. Award points for quality actions (complete profile vs. minimal profile). Offer opt-out — some users find gamification patronizing.',
    implementation: 'Points system: assign point values to each onboarding action (5-25 points based on effort). Running total displayed in checklist header. Badges: unlock on milestone achievements (SVG icons with earned/locked states). Streak tracking: consecutive days with at least one onboarding action. Celebration animations: confetti (canvas-confetti library), trophy icon scale-in, or success sound (opt-in). Leaderboard: only for team contexts. Store in user profile: {points, badges: [{id, earnedAt}], streak: {current, longest, lastActionDate}}. Respect gamification_preference from user profile.',
    a11y: 'Points display: aria-label="You have N points." Badges: aria-label="[Badge name], [earned/locked]." Earned badge announcement: aria-live="assertive" — "Badge earned: [name]." Confetti: purely decorative, no aria needed, but respect prefers-reduced-motion. Sound effects: off by default, opt-in via settings. Streak: aria-label="N day streak." Leaderboard: role="table" with proper headers.',
    docsUrl: null,
  },
  {
    name: 'Persistent Sidebar Checklist',
    category: 'checklists',
    description: 'A collapsible checklist panel docked to the side of the interface that remains accessible as users navigate between pages. Unlike dashboard-only checklists, the sidebar variant provides continuous visibility into onboarding progress. The panel shows a compact progress indicator when collapsed and the full task list when expanded. Auto-collapses after the first 2-3 tasks to avoid being intrusive. Intercom and HubSpot use this pattern for multi-session onboarding flows.',
    implementation: 'Fixed-position panel (right side, 320px wide) with collapse/expand toggle. Collapsed state: narrow strip (48px) showing a circular progress indicator and expand button. Expanded: full task list with progress bar. Use CSS transform: translateX for smooth slide animation. Z-index below modals but above page content. Store collapsed/expanded preference in localStorage. Auto-collapse after user dismisses or completes 3+ tasks. On task completion in expanded state: animate the checkmark, then auto-collapse after 2s. Mobile: bottom sheet instead of sidebar.',
    a11y: 'Panel: role="complementary" aria-label="Setup tasks." Toggle button: aria-expanded="true/false" aria-label="Toggle setup checklist." When expanding, move focus to the panel heading. When collapsing, return focus to toggle button. Tasks: same as Onboarding Checklist pattern. Collapsed progress indicator: aria-label="Setup progress, N of M complete." Ensure panel does not overlap or obscure page content needed for completing tasks.',
    docsUrl: null,
  },
  {
    name: 'Quick Win Task',
    category: 'checklists',
    description: 'The first onboarding task is deliberately designed to be completable in under 30 seconds, giving the user an immediate sense of accomplishment. Based on the Fogg Behavior Model: high motivation (just signed up) + low difficulty = action. Examples: "Name your workspace", "Choose a theme", "Star your first item." The quick win creates momentum — users who complete one task are 3x more likely to complete the full checklist (Appcues data). Place the quick win first in the checklist, pre-selected or auto-focused.',
    implementation: 'Design the first checklist task to require minimal input: a single text field, a toggle, or a click. Pre-fill with smart defaults (e.g., workspace name from signup data). Show inline completion feedback immediately (green check, confetti micro-animation). Auto-advance to the next task after 1s delay. The quick win form should be embedded directly in the checklist panel or dashboard card (not behind a navigation link) — removing friction is critical. Track time-to-first-completion in analytics.',
    a11y: 'Inline form: standard form controls with labels. Auto-focus on the input when the checklist first renders (only if the checklist is the page\'s primary content — do not steal focus from main content). Completion feedback: aria-live="polite" — "Task complete: [name]." Auto-advance: provide a "Continue" button as fallback, do not rely solely on timer-based advance. Pre-filled defaults: announce via aria-describedby — "Pre-filled with your account name."',
    docsUrl: null,
  },

  // --- Announcements ---
  {
    name: 'What\'s New Modal',
    category: 'announcements',
    description: 'A modal dialog shown on login that highlights 2-4 recent product updates. Effective for major feature launches that users need to know about. Use sparingly — Pendo research shows "What\'s New" modals shown more than once every two weeks are dismissed within 2 seconds by 70% of users. Include visuals (screenshots, illustrations), brief descriptions, a "Try it" CTA, and a "Dismiss" button. Show only for users who have not seen this specific announcement (track by announcement ID, not date).',
    implementation: 'Modal with a carousel or stacked card layout. Each announcement: image/illustration (16:9 aspect ratio), heading, 1-2 sentence description, optional CTA button. Navigation: dots or arrows for multi-item. Show once per announcement set (track by announcementId in user profile). Trigger on first page load after login, with a 1s delay (let the page settle). "Don\'t show again" checkbox for users who never want announcements. Max 4 items per modal. Auto-dismiss after 30 days if not shown. Carousel: auto-advance every 5s with pause on hover.',
    a11y: 'Modal: role="dialog" aria-modal="true" aria-label="What\'s new." Focus trap within modal. First focus: close button or first CTA. Carousel: role="region" aria-label="Announcements, item N of M" aria-roledescription="carousel." Each slide: role="group" aria-roledescription="slide." Pause auto-advance on focus within carousel. Navigation arrows: aria-label="Previous/Next announcement." Images: alt text describing the feature. Escape dismisses.',
    docsUrl: null,
  },
  {
    name: 'Changelog Feed',
    category: 'announcements',
    description: 'A chronological, always-accessible feed of product updates organized by date or version. Unlike one-time modals, the changelog is a permanent resource users can browse at any time. Best practice: categorize entries (New, Improved, Fixed), include screenshots for visual changes, and link to documentation for details. Position access via a "What\'s New" nav item with an unread badge. Notion, Linear, and Vercel maintain exemplary changelogs that also serve as marketing content.',
    implementation: 'Dedicated page with reverse-chronological entries. Each entry: date, version tag (optional), category badge (New/Improved/Fixed/Removed), title, description, optional image. Filter by category. Unread indicator: compare user\'s lastSeenChangelogDate with the latest entry date. Badge on nav item when unread entries exist. Markdown-rendered descriptions for formatting. Pagination or infinite scroll for history. RSS feed link for power users. Store lastSeenChangelogDate in user profile, update on page visit.',
    a11y: 'Feed: <main> with entries as <article> elements. Each entry: <time datetime="..."> for the date. Category badges: aria-label="Category: New" (not just color). Filter controls: role="group" aria-label="Filter by category" with toggle buttons (aria-pressed). Unread badge on nav: aria-label="What\'s New, N unread updates." Infinite scroll: announce "Loading more entries" via aria-live. RSS link: aria-label="Subscribe to changelog RSS feed."',
    docsUrl: null,
  },
  {
    name: 'In-App Release Banner',
    category: 'announcements',
    description: 'A dismissible banner at the top of the page or within specific sections announcing a single important update. Less disruptive than modals, banners fit into the page flow and respect the user\'s current task. Effective for announcing breaking changes, deprecations, or critical new features that affect the current page. Stripe and AWS use this pattern for API version updates and service announcements. Show contextually — a billing page banner for pricing changes, not a global banner.',
    implementation: 'Full-width banner below the header or inline within the relevant section. Accent background (info blue for features, warning amber for deprecations, success green for improvements). Content: icon, concise text (one line), optional "Learn more" link, close button. Persist dismissal by bannerId in localStorage. Show for a maximum of 14 days or until the user interacts with the announced feature. Stack multiple banners vertically if needed (max 2 visible). Smooth collapse animation on dismiss.',
    a11y: 'Banner: role="banner" or role="status" (for non-urgent) / role="alert" (for breaking changes). Close button: aria-label="Dismiss announcement." Link: descriptive text, not "Click here." Ensure banner does not push content below the fold on small screens. If stacking multiple banners, each should be independently dismissible. Color is not the only differentiator — use icons and labels to distinguish banner types.',
    docsUrl: null,
  },
  {
    name: 'Announcement Badge',
    category: 'announcements',
    description: 'A small visual indicator (dot or count) on navigation items, menu entries, or feature icons signaling that something is new or updated. Badges create curiosity without interrupting workflow. Use a colored dot for "something new" (no count) and a numbered badge for quantified updates (3 new messages). Remove the badge once the user visits the associated page or feature. GitHub, Slack, and most SaaS products rely heavily on badges as a non-intrusive notification mechanism.',
    implementation: 'Absolute-positioned element (top-right of parent, offset -4px). Dot: 8px circle, accent color. Count: min-width 18px pill shape, white text on accent background. Animate appearance with a scale-in (0 to 1) transition. Track new/unseen state per feature: {featureId, hasNew: boolean, count: number, lastSeenAt: timestamp}. Clear badge on page visit or feature interaction. For nav items: render badge within the <a> or <button>, positioned with CSS. Limit count display to 99+ for large numbers.',
    a11y: 'Badge must not be the only way to convey information — add text to aria-label of the parent element: "Messages (3 new)" or "Settings (new)." Badge itself: aria-hidden="true" (since the parent label conveys the info). Do not animate continuously — a one-time entrance animation is sufficient. For count badges, screen readers should hear the count as part of the parent label, not as a separate element.',
    docsUrl: null,
  },
  {
    name: 'Release Notes Page',
    category: 'announcements',
    description: 'A dedicated, public-facing page documenting product changes organized by version number or date. Serves both as user communication and SEO content. Unlike in-app changelogs, release notes pages are accessible without authentication and follow a more formal structure (version number, date, categorized changes, migration guides for breaking changes). Useful for developer tools, APIs, and products with external integrations. Link to release notes from in-app announcements for full details.',
    implementation: 'Static or server-rendered page with version entries. Each version: semver heading (h2), date, categorized changes (Breaking, Added, Changed, Fixed, Deprecated — following Keep a Changelog format). Breaking changes: highlighted with warning styling and migration instructions. Code examples for API changes. Auto-generate from git tags and conventional commits where possible. Table of contents with version links for quick navigation. "Subscribe to updates" option (email or RSS). Anchor links per version for direct sharing.',
    a11y: 'Page structure: proper heading hierarchy (h1: Release Notes, h2: version, h3: category). Code blocks: <pre><code> with language class for syntax highlighting. Breaking changes: visually distinct AND preceded by a screen-reader-friendly label ("Breaking change:"). Table of contents: <nav aria-label="Version navigation">. Anchor links: focus-visible on target section. Long pages: "Back to top" link after each version section.',
    docsUrl: null,
  },

  // --- Guidance ---
  {
    name: 'Empty State Onboarding',
    category: 'guidance',
    description: 'Transforming empty states (no projects, no data, no activity) into onboarding opportunities with clear calls to action. Instead of showing "No items yet" with a blank page, empty states explain what the section is for, show what it will look like with data (illustration or screenshot), and provide a primary action button to create the first item. Research from NN/g shows that instructional empty states reduce time-to-first-action by 50% compared to blank states. Every empty state is an onboarding moment.',
    implementation: 'Centered layout with: illustration or screenshot (max 300px wide, shows the populated state), heading ("No projects yet"), description (1-2 sentences explaining the value), primary CTA button ("Create your first project"), optional secondary action ("Import from existing"). Different empty states per section — tailor the message and illustration. Track first-item creation from empty state in analytics. After the user creates their first item, the empty state never appears again for that section. Use the same illustration style across all empty states for consistency.',
    a11y: 'Container: role="status" or no special role (it\'s part of the page flow). Illustration: decorative (alt="") or descriptive alt text. CTA button: standard <button> or <a> with clear label — "Create your first project" not "Get started." If the empty state replaces a data table, maintain the same landmarks and headings so screen reader navigation is consistent. Do not auto-focus the CTA — let the user discover it naturally through tab order.',
    docsUrl: null,
  },
  {
    name: 'Interactive Demo Sandbox',
    category: 'guidance',
    description: 'A pre-populated environment with sample data that lets users explore the product without consequences. Users can click around, create test items, and see how features work with realistic data. Effective for complex products where users need to "feel" the workflow before committing their own data. Figma\'s starter files, Notion\'s template gallery, and Airtable\'s sample bases are exemplary. Offer a "Clear sample data" action when the user is ready to start fresh. Sandbox mode should be visually distinct from production.',
    implementation: 'Seed the account with sample data on first login: sample projects, sample team members (bots), sample content. Add a visible "Sample data" badge or banner at the top. Include a "Start fresh" button that deletes all sample data (with confirmation). Sample data should demonstrate key features: filled dashboards, example reports, sample notifications. Use a different background color or subtle pattern for sandbox mode. Track which sample items users interact with to understand feature interest. Allow switching between sandbox and real data during onboarding.',
    a11y: 'Sandbox banner: role="status" aria-label="You are viewing sample data." "Start fresh" button: triggers a confirmation dialog (role="alertdialog") — "This will delete all sample data. Continue?" Sample data badge on items: aria-label includes "sample" — "Project: Acme Corp (sample data)." Ensure sandbox interactions are fully accessible — sample data should not disable any accessibility features. Screen readers should announce sandbox mode once on page load.',
    docsUrl: null,
  },
  {
    name: 'Video Walkthrough',
    category: 'guidance',
    description: 'Short (60-90 second) embedded videos demonstrating how to use specific features. Effective for visual/spatial features that are hard to explain with text (drag-and-drop, canvas editors, complex forms). Place videos contextually near the feature they explain, not in a separate help center. Auto-play is almost always wrong — let users choose to watch. Provide both video and text alternatives, as Wistia research shows 40% of users prefer reading to watching. Include chapter markers for videos over 60 seconds.',
    implementation: 'Embed using a lightweight player (lite-youtube-embed for YouTube, or native <video> with custom controls). Thumbnail with a play button overlay — do not auto-play. Lazy-load the video player (intersection observer). Position: inline within the page near the relevant feature, or in a modal triggered by a "Watch how" link. Captions: always on by default. Chapter markers for longer videos (using the <track> element with chapters kind). Track video engagement: play, pause, completion percentage. Offer playback speed controls (1x, 1.5x, 2x).',
    a11y: 'Video player: accessible controls (play/pause, volume, progress, fullscreen, captions, playback speed) all keyboard-operable. Captions: <track kind="captions"> always available, default on. Transcript: provide a text transcript below or linked from the video. Auto-play: never. Respect prefers-reduced-motion: do not auto-play even hover previews. Player controls: sufficient color contrast, min 44x44px touch targets. Video description: aria-label="Video walkthrough: [feature name], [duration]."',
    docsUrl: null,
  },
  {
    name: 'Inline Help Panel',
    category: 'guidance',
    description: 'A slide-out panel (typically from the right) providing contextual documentation and guidance without leaving the current page. Triggered by a "?" help button or a "Learn more" link. The panel shows content relevant to the current page or feature, not generic help center content. Stripe Dashboard and AWS Console use this pattern extensively — it preserves the user\'s work context while providing detailed guidance. The panel should support search and navigation between related help topics.',
    implementation: 'Fixed-position panel (right side, 400px wide) that slides in on trigger. Content: Markdown-rendered help articles loaded from a help API or static JSON. Context detection: map current route to relevant help articles automatically. Search within the panel (fuzzy match on titles and content). Navigation: breadcrumb back to topic list, related articles at bottom. Z-index above page content but below modals. Close on Escape, close button, or clicking outside. Transition: transform translateX with 250ms ease. Remember open/closed state in sessionStorage.',
    a11y: 'Panel: role="complementary" aria-label="Help panel." Open trigger: aria-expanded="true/false" aria-controls="help-panel." Focus moves to panel heading on open. Close: Escape key and visible close button. On close, return focus to the trigger element. Panel content: proper heading hierarchy, links, and code blocks. Search input: role="searchbox" aria-label="Search help." Links to external docs: indicate they open in a new tab (aria-label includes "opens in new tab"). Do not trap focus — allow tabbing back to main content.',
    docsUrl: null,
  },
  {
    name: 'Sample Data Seeding',
    category: 'guidance',
    description: 'Automatically populating the user\'s account with realistic sample data on first use so they see a populated interface instead of empty states. Unlike the Interactive Demo Sandbox (which is an explicit mode), sample data seeding is implicit — the data appears as if the user created it, with clear labels marking it as sample. Airtable seeds sample rows, Notion adds starter pages, and Linear creates a sample project. The user can delete sample items individually or "clear all samples" from a banner.',
    implementation: 'On account creation or first workspace setup: run a seeder that creates 3-10 sample items per major entity (projects, tasks, documents). Label each with a "[Sample]" prefix or a "sample: true" metadata flag. Show a dismissible banner: "We added some sample data to help you get started. Remove anytime." Provide bulk "Clear all sample data" action. Sample data should cover realistic scenarios (varied statuses, dates, assigned members). Do not count sample data in billing or usage metrics. Delete sample data automatically when the user creates their 5th real item.',
    a11y: 'Sample items: include "(sample)" in text labels for screen reader clarity, not just visual badges. Banner: role="status" aria-label="Sample data notice." "Clear all" button: triggers confirmation dialog. Removing individual sample items: same interaction as deleting real items (no special affordance needed). Ensure sample data does not confuse navigation — if sample items appear in search results, label them clearly.',
    docsUrl: null,
  },

  // --- Tracking ---
  {
    name: 'Skip & Dismiss Behavior',
    category: 'tracking',
    description: 'Design patterns for allowing users to skip, dismiss, or postpone onboarding flows without penalty. Every onboarding element must have a clear exit. Research from NN/g shows that forced tours (no skip option) have 3x higher abandonment of the entire product compared to skippable tours. Provide three levels: "Skip this step" (skip one), "Skip tour" (skip all), and "Remind me later" (postpone). Dismissed content should be accessible later from a help menu. Never show the same dismissed content again unless the user explicitly requests it.',
    implementation: 'Each onboarding element needs a dismiss config: {dismissType: "permanent" | "session" | "timed", showAgainAfter?: days, accessFrom: "help-menu" | "settings"}. Permanent dismissal: stored in user profile, never shown again. Session dismissal: sessionStorage, shows again next login. Timed: shows again after N days. All dismissed tours/checklists accessible from Help > "Product tours" or Settings > "Onboarding." Track dismissal rates per step to identify friction points. "Remind me later" option: re-triggers on next login or after 24 hours.',
    a11y: 'Skip/dismiss buttons: always visible (not hidden behind hover), keyboard-accessible, clearly labeled. "Skip tour" not "X." aria-label="Skip remaining tour steps" or "Dismiss this tip." "Remind me later": aria-label="Postpone, will show again tomorrow." After dismissal, announce: "Tour dismissed. You can replay it from the Help menu" via aria-live="polite." Focus after dismiss: move to the most logical next element (usually the element behind the overlay).',
    docsUrl: null,
  },
  {
    name: 'Completion Persistence',
    category: 'tracking',
    description: 'Reliably tracking which onboarding steps, tours, and checklists a user has completed across sessions, devices, and browsers. Completion state must be server-side (not just localStorage) to survive device switches and cache clears. Track not just binary completion but timestamps, duration, and whether the step was completed organically or via the onboarding flow. This data powers re-engagement decisions: users who completed setup but never activated get different treatment than users who never started.',
    implementation: 'Server-side model: {userId, onboardingState: {tourCompleted, tourCompletedAt, checklistTasks: [{id, completed, completedAt, completedVia: "checklist" | "organic"}], setupWizardStep, lastActiveAt}}. Sync to localStorage for offline/fast reads. On each completion event, POST to API and update localStorage optimistically. Debounce rapid completions (e.g., clicking through a tour quickly). Expose onboarding state in user API for analytics tools. Track completion rates by cohort (signup date, plan, segment) for product insights.',
    a11y: 'Completion state should be reflected in UI: completed tasks show checkmarks with aria-checked="true." Progress indicators update in real time: aria-valuenow reflects current state. If completion is detected organically (user performed the action outside the checklist), update the checklist UI with an animation and announce: "Task auto-completed: [name]" via aria-live="polite." No special accessibility considerations for the persistence mechanism itself — it\'s backend infrastructure.',
    docsUrl: null,
  },
  {
    name: 'Re-Engagement Tour',
    category: 'tracking',
    description: 'A targeted tour or prompt shown to users who return after a period of inactivity, highlighting what has changed and re-orienting them in the product. Different from "What\'s New" — re-engagement tours focus on reminding users of existing value, not announcing new features. Trigger after 14-30 days of inactivity. Keep it to 2-3 steps maximum: "Welcome back! Here\'s where you left off" > "Here\'s what your team has been up to" > "Ready to pick up where you left off?" Pendo data shows re-engagement tours reduce 30-day churn by 15%.',
    implementation: 'Track lastActiveAt timestamp in user profile. On login, calculate days since last activity. If > threshold (configurable, default 14 days): show a welcome-back modal with personalized content. Content strategy: 1) Summary of activity since they left (team updates, new content), 2) Quick link to their last-used feature, 3) Optional: "Here\'s what\'s new since [date]" link. Do not show re-engagement tour on the same session as "What\'s New" — space them out. Frequency cap: once per return visit, max once per 7 days. Track re-engagement: {shown, clicked, feature_resumed}.',
    a11y: 'Re-engagement modal: role="dialog" aria-label="Welcome back." Focus trap within modal. Dismiss on Escape. Content should not overwhelm — keep to 2-3 short sections. "Pick up where you left off" link: descriptive aria-label including the feature name. Do not auto-navigate the user — let them choose. After dismissal, focus returns to the main content. Announce modal via aria-live if it appears with delay after page load.',
    docsUrl: null,
  },
  {
    name: 'Progressive Onboarding',
    category: 'tracking',
    description: 'Revealing advanced features gradually as the user demonstrates proficiency with basic ones, instead of exposing everything at once. Based on progressive disclosure — users who have not used basic search do not need to see advanced filters. Track feature usage depth: {featureId, usageCount, lastUsed}. When a user reaches a threshold (e.g., 5 uses of basic search), surface a tip about advanced search. Slack, Figma, and VS Code use this pattern — keyboard shortcuts are taught after mouse usage is established.',
    implementation: 'Define a feature dependency graph: {featureId, prerequisites: [featureId], triggerAfter: N uses of prerequisites}. Track usage events per user. When prerequisites are met, surface the advanced feature via contextual tip, hotspot, or inline suggestion. Timing: show the tip on the next session after the threshold is met (not immediately — give the user a fresh context). Examples: after 5 manual saves, suggest Cmd+S; after 3 list-view uses, suggest keyboard shortcuts; after creating 3 projects, suggest templates. Cap at one progressive tip per session.',
    a11y: 'Progressive tips follow the Contextual Tip pattern accessibility. Hidden features should still be accessible via menus and search — progressive onboarding controls visibility of tips, not feature availability. Keyboard shortcuts: always discoverable in a shortcuts panel (Cmd+/), regardless of progressive onboarding state. Tips about keyboard shortcuts must include <kbd> elements. Announce new tip availability: aria-live="polite" — "Tip: Try Cmd+K for quick search."',
    docsUrl: null,
  },
  {
    name: 'Onboarding Analytics Dashboard',
    category: 'tracking',
    description: 'An internal dashboard (for product teams, not end users) tracking onboarding funnel metrics: signup-to-activation rate, time-to-first-value, checklist completion rates, tour drop-off points, and feature adoption curves. Essential for iterating on the onboarding flow. Key metrics: activation rate (% who reach the "aha moment"), median time to activation, step-by-step completion funnel, dismissal rates per onboarding element, and cohort analysis (do newer cohorts activate faster?). The dashboard itself is a standard data visualization page.',
    implementation: 'Track events: onboarding_step_started, onboarding_step_completed, onboarding_step_skipped, tour_started, tour_completed, tour_dismissed, checklist_task_completed, setup_wizard_step_completed. Store with userId, timestamp, sessionId, and metadata (step name, time spent). Dashboard queries: funnel visualization (step completion %), time-to-activation histogram, cohort comparison line chart, dismissal heatmap by step. Alerting: notify if activation rate drops below threshold. A/B testing support: segment by experiment variant. Use existing analytics infrastructure (Mixpanel, Amplitude, PostHog) rather than building custom.',
    a11y: 'This is an internal tool — follow standard Data Visualization Patterns for chart accessibility. Dashboard should be keyboard-navigable. Charts need text alternatives. Filters and date pickers follow form accessibility standards. This pattern describes what to track, not end-user-facing UI.',
    docsUrl: null,
  },
];
