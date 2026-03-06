# Onboarding & Tutorial Pattern Reference

Agent-facing reference for product tours, onboarding checklists, feature discovery, and user education flows. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Onboarding must be skippable, contextual, and progressive. Never force tours. Reward completion, respect dismissal, and make every element accessible later from a help menu.

## 1. Product Tours

### Multi-Step Product Tour
- **When:** First-time users need orientation across 3-7 key interface elements.
- **What:** Sequential tooltip walkthrough over a dimmed overlay. Step indicators (dots), Next + Skip buttons. Store progress in localStorage. Under 60 seconds total. First step orients ("Here's your dashboard"), doesn't instruct.
- **A11y:** role="dialog" aria-label="Product tour, step N of M." Focus trap per tooltip. Announce step changes via aria-live="polite." Return focus to trigger on dismiss.
- **Anti-pattern:** Never use 8+ steps (45% completion vs 72% for 3-5 steps). Never launch without a skip option.

### Segmented Tour Paths
- **When:** Users have different roles or goals requiring different introductions.
- **What:** Segmentation modal (2-4 cards) on first login routes to tailored tour configs. Store segment choice server-side for future personalization.
- **A11y:** Segmentation: role="radiogroup" with aria-checked. Require explicit confirmation button, no auto-advance on selection.
- **Anti-pattern:** Never show a generic one-size-fits-all tour to diverse user segments.

### Delayed Tour Trigger
- **When:** Always — tours should not fire on immediate page load.
- **What:** 3-5 second delay or first interaction trigger. "Would you like a tour?" prompt before starting (role="alertdialog"). If declined, accessible from help menu.
- **A11y:** Never auto-launch a focus-trapped tour without consent. Respect prefers-reduced-motion.
- **Anti-pattern:** Never start a tour immediately on page load. Never launch without user consent.

### Tour Resume & Replay
- **When:** Users abandon tours mid-way or want to re-access later.
- **What:** Persist {tourId, currentStep, lastSeen}. Non-blocking toast on next visit: "Continue your tour?" "Replay tour" in help menu. Clear stale state after 30 days.
- **A11y:** Resume prompt: role="status" aria-live="polite" — do not steal focus. Help menu replay: standard menu item.
- **Anti-pattern:** Never restart a tour from step 1 when the user abandoned at step 3.

### Guided Setup Wizard
- **When:** First-time configuration requires user input (workspace name, invites, integrations).
- **What:** Full-page or modal wizard, 3-5 steps, numbered stepper, Save progress server-side. "Skip for now" on optional steps. Final "Get Started" CTA.
- **A11y:** role="group" aria-label="Setup wizard, step N of M." aria-current="step" on active. Back/Next include step context in aria-label.
- **Anti-pattern:** Never make all wizard steps required. Never lose progress on page refresh.

## 2. Coachmarks & Spotlights

### Spotlight Coachmark
- **When:** Introducing a single critical feature post-action. Use sparingly (max 3 in sequence).
- **What:** Full-viewport semi-transparent overlay with CSS clip-path cutout around target. Tooltip adjacent. Target remains interactive. Dismiss on click outside, Escape, or CTA.
- **A11y:** role="dialog" aria-modal="true." Highlighted element stays keyboard-accessible. Escape dismisses. Focus returns to highlighted element.
- **Anti-pattern:** Never chain more than 3 spotlights (60% drop-off). Never block interaction with the highlighted element.

### Tooltip Hotspot
- **When:** Introducing secondary features without interrupting workflow.
- **What:** 8-12px pulsing dot near feature. Click reveals tooltip with title, description, "Got it" button. Auto-remove after user interacts with feature 2-3 times. Max 3 visible hotspots.
- **A11y:** button aria-label="Learn about [feature]" aria-expanded. Respect prefers-reduced-motion (static dot). Must work with click/keyboard, not hover-only.
- **Anti-pattern:** Never show more than 3 hotspots simultaneously. Never use hover-only activation.

### Feature Callout Banner
- **When:** Announcing incremental improvements near the relevant feature.
- **What:** Inline div with accent background, left border, icon, text, "Learn more" link, close button. Dismiss persisted by ID. Max 14 days. Slide-down + fade-in animation.
- **A11y:** role="status" aria-label="New feature announcement." Close: aria-label="Dismiss announcement."
- **Anti-pattern:** Never show callout banners for features older than 14 days. Never use for critical alerts (use alert role instead).

### Contextual Tip
- **When:** User encounters a feature for the first time; teaching efficiency shortcuts.
- **What:** Small card (max 280px) with info icon, tip text, "Got it" button. One tip per page view. Auto-retire after user demonstrates proficiency (3 uses). Priority queue: activation > efficiency > nice-to-know.
- **A11y:** role="note." No auto-focus. Keyboard shortcuts in <kbd> elements. Do not overlap interactive elements.
- **Anti-pattern:** Never show multiple tips simultaneously. Never show tips for features the user already uses regularly.

### Beacon Pulse Animation
- **When:** Drawing attention to nav items or settings that need configuration or have new content.
- **What:** CSS ::before pseudo-element with scale + opacity keyframes. 8-10px dot, 1.5-2s animation. Remove after click or 30 days. Max 2 simultaneous beacons.
- **A11y:** Respect prefers-reduced-motion (static dot). Add text to parent aria-label: "Settings (new)." Use aria-live="polite" for dynamic beacons.
- **Anti-pattern:** Never use more than 2 simultaneous beacons. Never rely solely on animation to convey information.

## 3. Checklists & Milestones

### Onboarding Checklist
- **When:** 4-7 setup tasks needed for activation. Increases activation by 30% vs tours alone.
- **What:** Card with progress bar, task list with checkmarks and action links. Auto-detect completion from app events. Celebration at 100%. Hide 3 days after completion. Bottom-right floating panel or dashboard widget.
- **A11y:** role="group" aria-label="Getting started checklist, N of M complete." Tasks: role="checkbox" aria-checked. Progress: role="progressbar." Celebration: aria-live="assertive."
- **Anti-pattern:** Never use more than 7 tasks (overwhelm). Never require manual check-off for automatically detectable actions.

### Progress Milestone Bar
- **When:** Onboarding spans multiple sessions and needs visual progress encouragement.
- **What:** Segmented progress bar with milestone markers (25%, 50%, 75%, 100%). Icons transition from gray to accent with bounce animation. Labels below each milestone.
- **A11y:** role="progressbar" with aria-valuenow. Milestones: role="list" with aria-labels for reached/unreached. Celebrate via aria-live="polite."
- **Anti-pattern:** Never place milestones too far apart (discouragement). Never skip the celebration micro-animation.

### Gamified Task Completion
- **When:** Onboarding requires 5+ actions across multiple sessions. Opt-out available.
- **What:** Points (5-25 per action), badges (SVG with earned/locked states), streak tracking. Confetti on milestone. Respect gamification_preference from user profile.
- **A11y:** Points: aria-label="You have N points." Badges: aria-label includes earned/locked. Sounds: off by default. Respect prefers-reduced-motion.
- **Anti-pattern:** Never force gamification on users who find it patronizing. Never reward trivial actions equally with meaningful ones.

### Persistent Sidebar Checklist
- **When:** Multi-session onboarding that needs continuous visibility across page navigations.
- **What:** Fixed-position panel (320px) with collapse/expand toggle. Collapsed: 48px strip with progress circle. Auto-collapse after 3+ tasks complete. Mobile: bottom sheet.
- **A11y:** role="complementary" aria-label="Setup tasks." Toggle: aria-expanded. Focus management on expand/collapse.
- **Anti-pattern:** Never let the sidebar overlap content needed for completing tasks.

### Quick Win Task
- **When:** Always — the first checklist task must be completable in under 30 seconds.
- **What:** Minimal input (single field, toggle, or click). Pre-fill with smart defaults. Embed inline (no navigation). Immediate feedback. Users who complete one task are 3x more likely to finish the checklist.
- **A11y:** Standard form controls. Auto-focus only if checklist is primary content. Completion: aria-live="polite." Auto-advance: provide "Continue" button fallback.
- **Anti-pattern:** Never make the first task require complex input or navigation to another page.

## 4. Announcements & Changelog

### What's New Modal
- **When:** Major feature launches (max once every 2 weeks). Track by announcementId.
- **What:** Modal carousel: image, heading, description, CTA per item. Max 4 items. 1s delay after login. "Don't show again" option. Auto-dismiss after 30 days.
- **A11y:** role="dialog" aria-modal="true." Focus trap. Carousel: aria-roledescription="carousel." Pause auto-advance on focus. Images: alt text. Escape dismisses.
- **Anti-pattern:** Never show more than once every 2 weeks (70% instant dismissal rate). Never auto-play without pause controls.

### Changelog Feed
- **When:** Always — permanent, browsable record of product updates.
- **What:** Reverse-chronological entries with date, category badge (New/Improved/Fixed), title, description. Filter by category. Unread badge on nav item. RSS feed.
- **A11y:** Entries as <article> with <time>. Category badges: aria-label="Category: New." Unread badge on nav: aria-label includes count.
- **Anti-pattern:** Never use a changelog as the only announcement channel — pair with in-app notifications.

### In-App Release Banner
- **When:** Contextual announcements affecting the current page/section.
- **What:** Full-width banner below header or inline. Accent background by type (blue=feature, amber=deprecation). Icon, text, "Learn more," close button. Dismiss by bannerId. Max 14 days. Max 2 stacked.
- **A11y:** role="status" (non-urgent) or role="alert" (breaking). Close: aria-label="Dismiss." Icons + labels (not just color) differentiate types.
- **Anti-pattern:** Never show global banners for section-specific updates. Never stack more than 2 banners.

### Announcement Badge
- **When:** Non-intrusive notification of new/updated content on navigation items.
- **What:** Absolute-positioned 8px dot or count pill. Scale-in entrance animation. Clear on visit/interaction. Limit count to 99+.
- **A11y:** Parent aria-label includes new/count info. Badge itself: aria-hidden="true." No continuous animation.
- **Anti-pattern:** Never rely on badge alone — parent label must convey the information for screen readers.

### Release Notes Page
- **When:** Public-facing documentation of product changes by version.
- **What:** Semver headings, categorized changes (Breaking/Added/Changed/Fixed/Deprecated, Keep a Changelog format). Code examples for API changes. TOC with version links. RSS subscribe.
- **A11y:** Proper heading hierarchy. Code blocks: <pre><code>. Breaking changes: label for screen readers. Anchor links per version.
- **Anti-pattern:** Never omit migration guides for breaking changes. Never skip version numbering.

## 5. Guidance & Empty States

### Empty State Onboarding
- **When:** Every empty section (no projects, no data, no activity) — every empty state is an onboarding moment.
- **What:** Centered: illustration (max 300px), heading, description (1-2 sentences), primary CTA, optional secondary action. Different content per section. Track first-item creation.
- **A11y:** Illustration: decorative alt="". CTA: clear label ("Create your first project" not "Get started"). Maintain landmarks consistent with populated state.
- **Anti-pattern:** Never show "No items yet" without a CTA. Never use generic empty states across all sections.

### Interactive Demo Sandbox
- **When:** Complex products where users need to "feel" the workflow before committing their own data.
- **What:** Seed sample data on first login. Visible "Sample data" banner + "Start fresh" button (with confirmation). Different background/pattern for sandbox mode. Auto-delete samples when user creates 5th real item.
- **A11y:** Sandbox banner: role="status." "Start fresh": confirmation dialog (role="alertdialog"). Items: aria-label includes "sample."
- **Anti-pattern:** Never mix sample and real data without clear labeling. Never count sample data in billing.

### Video Walkthrough
- **When:** Visual/spatial features hard to explain with text (drag-and-drop, canvas editors).
- **What:** Lightweight player with thumbnail + play button (no auto-play). Lazy-load. Captions default on. Chapter markers for 60s+. Playback speed controls. Text transcript always available.
- **A11y:** Accessible player controls (keyboard). <track kind="captions"> default on. Transcript linked/below. Never auto-play. prefers-reduced-motion: no hover previews. Min 44x44px touch targets.
- **Anti-pattern:** Never auto-play. Never provide video without text alternative. Never use video for content that's simpler as text.

### Inline Help Panel
- **When:** Complex features where users need documentation without leaving context.
- **What:** Slide-out panel (400px, right side) triggered by "?" button. Context-aware content mapped from current route. Search within panel. Z-index above content, below modals. Close on Escape.
- **A11y:** role="complementary" aria-label="Help panel." Trigger: aria-expanded aria-controls. Focus to heading on open. Escape closes. Don't trap focus — allow tabbing to main content.
- **Anti-pattern:** Never show generic help — content must match the current page context.

### Sample Data Seeding
- **When:** Showing users a populated interface instead of empty states on first use.
- **What:** Seed 3-10 sample items per entity. "[Sample]" prefix or metadata flag. Dismissible banner + "Clear all" action. Don't count in billing. Auto-delete when user creates 5th real item.
- **A11y:** Include "(sample)" in text labels for screen readers. Banner: role="status." "Clear all": confirmation dialog.
- **Anti-pattern:** Never seed sample data that persists indefinitely. Never confuse sample data with real data in search/exports.

## 6. Tracking & Re-engagement

### Skip & Dismiss Behavior
- **When:** Every onboarding element must have a clear exit. Forced tours cause 3x more product abandonment.
- **What:** Three levels: "Skip this step," "Skip tour," "Remind me later." Permanent, session, or timed dismissal. All dismissed content accessible from Help menu. Track dismissal rates per step.
- **A11y:** Skip buttons always visible, keyboard-accessible, clearly labeled ("Skip tour" not "X"). After dismiss: aria-live="polite" — "Dismissed. Replay from Help menu." Focus moves to logical next element.
- **Anti-pattern:** Never show dismissed content again without explicit user request. Never hide the skip/dismiss option.

### Completion Persistence
- **When:** Always — onboarding state must survive device switches and cache clears.
- **What:** Server-side model: {tourCompleted, checklistTasks: [{id, completed, completedVia}], setupWizardStep, lastActiveAt}. Sync to localStorage for fast reads. Debounce rapid completions.
- **A11y:** Reflect completion in UI: checkmarks with aria-checked. Organic auto-completion: aria-live="polite" — "Task auto-completed: [name]."
- **Anti-pattern:** Never store onboarding state only in localStorage. Never lose progress on device switch.

### Re-Engagement Tour
- **When:** Users return after 14-30 days of inactivity. Max once per return visit, once per 7 days.
- **What:** Welcome-back modal: activity summary since they left, quick link to last-used feature, "What's new" link. Do not show same session as What's New modal.
- **A11y:** role="dialog" aria-label="Welcome back." Focus trap. Escape dismisses. Links include descriptive aria-labels.
- **Anti-pattern:** Never auto-navigate returning users. Never overwhelm with combined re-engagement + what's new.

### Progressive Onboarding
- **When:** Revealing advanced features after users demonstrate basic proficiency.
- **What:** Feature dependency graph: {featureId, prerequisites, triggerAfter: N uses}. Surface tip on next session after threshold. One progressive tip per session. Keyboard shortcuts always discoverable in shortcuts panel regardless.
- **A11y:** Tips follow Contextual Tip a11y. Hidden features still accessible via menus/search. Shortcuts in <kbd> elements.
- **Anti-pattern:** Never hide features entirely — progressive onboarding controls tip visibility, not feature availability.

### Onboarding Analytics Dashboard
- **When:** Always — internal tool for measuring and optimizing onboarding flows.
- **What:** Track: step_started, step_completed, step_skipped, tour_completed, tour_dismissed. Dashboard: funnel visualization, time-to-activation histogram, cohort comparison, dismissal heatmap. Alert on activation rate drops.
- **A11y:** Standard data visualization accessibility. Keyboard-navigable charts. Text alternatives for visual data.
- **Anti-pattern:** Never launch onboarding without analytics. Never optimize without cohort analysis.
