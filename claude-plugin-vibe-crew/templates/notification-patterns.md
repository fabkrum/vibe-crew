# Notification Pattern Reference

Agent-facing reference for notification system design, delivery channel selection, and accessibility. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Notifications must inform without interrupting. Use the least disruptive channel that ensures the message is received. Never steal focus. Always provide user control over frequency and channels.

## 1. Delivery Channels

### Toast / Snackbar
- **When:** Confirmations, success feedback, low-priority status updates. No user action required.
- **What:** shadcn Sonner. `toast.success()`, `toast.error()`, `toast.loading()`. Position bottom-right (desktop), bottom-center (mobile). Auto-dismiss 3-5s. Stack vertically.
- **A11y:** `role="status"` + `aria-live="polite"` by default. Error toasts use `role="alert"`. Never auto-dismiss errors.
- **Anti-pattern:** Never use toasts for errors requiring acknowledgment.

### In-App Banner
- **When:** System-wide announcements — maintenance, new features, billing alerts. Higher visibility than toasts.
- **What:** shadcn Alert. Fixed top or inline. Dismiss button + optional CTA. Persist dismissal in localStorage. Limit to one banner.
- **A11y:** `role="alert"` for urgent, `role="status"` for informational. Dismiss button keyboard-accessible.
- **Anti-pattern:** Multiple simultaneous banners cause banner blindness (NN/G).

### Push Notification (Web)
- **When:** Re-engagement when tab is inactive. Opt-in rates 7-12%.
- **What:** Push API + Service Worker + VAPID keys. Show custom pre-permission UI (soft ask) before browser prompt. Store subscription server-side.
- **A11y:** Pre-permission prompt must be keyboard-navigable. Never block content behind permission wall. Respect OS Do Not Disturb.
- **Anti-pattern:** Never show browser permission prompt on first page load.

### Push Notification (Mobile)
- **When:** Re-engagement for native apps. Opt-in 50-60%. Limit 2-5/day.
- **What:** APNs (iOS) / FCM (Android). Notification channels for category control. Deep-link on tap. Rich media for 25% higher CTR.
- **A11y:** VoiceOver/TalkBack read content automatically. Titles under 50 characters. Notification actions for quick interaction.

### Email Notification
- **When:** Events users must not miss — receipts, security alerts, digests. Batch low-priority into digests.
- **What:** Resend/SendGrid/Postmark. React Email templates. Background job queuing. Exponential backoff. Per-type preferences.
- **A11y:** Semantic HTML, alt text on images, 4.5:1 contrast, plain-text fallback. Unsubscribe link required (CAN-SPAM, GDPR).
- **Anti-pattern:** Never send individual emails for every low-priority event. Batch into digests.

### In-App Message / Interstitial
- **When:** High-value, low-frequency messages — onboarding, upgrade nudges, feature announcements.
- **What:** shadcn Dialog or Sheet. Trigger at natural transitions (route change, task completion). Queue to prevent stacking. Frequency caps.
- **A11y:** Focus trap + Escape dismiss. `aria-labelledby` on dialog title. Background inert. Never auto-dismiss.
- **Anti-pattern:** Never interrupt mid-task.

### Webhook / Real-Time Event
- **When:** Live updates — new messages, status changes. SSE for unidirectional; WebSocket for bidirectional.
- **What:** EventSource (SSE) or Socket.IO (WebSocket) with reconnection. Deduplicate by ID. Show connection status indicator.
- **A11y:** Announce via `aria-live="polite"`. Do not auto-focus/auto-scroll. Show "New items" button instead of disruptive injection.

## 2. Display Patterns

### Bell Icon + Badge
- **When:** Universal notification center entry point. Header/masthead placement.
- **What:** shadcn Popover + Button (Bell icon) + Badge overlay. Poll (30-60s) or real-time subscription. Dot or numeric badge (cap at "99+").
- **A11y:** `aria-label="Notifications, 3 unread"` (dynamic). Badge is decorative (`aria-hidden`). Announce arrivals via `aria-live`, not focus steal.

### Notification Center / Drawer
- **When:** Central hub for all notifications. Reverse chronological. Read/unread distinction.
- **What:** shadcn Sheet or Popover. Virtualize long lists. Group by time ("Today", "Earlier"). "Mark all as read" action.
- **A11y:** `role="log"` on list. Each item has descriptive `aria-label`. Never auto-focus the drawer.

### Notification Item
- **When:** Individual entry in notification list.
- **What:** Avatar + title + body (truncated) + relative timestamp + action buttons. Unread indicator (dot + bold + tinted bg). Deep-link on click.
- **A11y:** `role="listitem"` with descriptive label including unread state. Hover actions also available via keyboard.

### Inline Notification
- **When:** Contextual messages near related content — form validation, section alerts.
- **What:** shadcn Alert with icon. Place near related content. Left border accent. Dismissible or persistent.
- **A11y:** `role="alert"` for errors, `role="status"` for success/info. Associate with form field via `aria-describedby`.

### Progress Notification
- **When:** Ongoing operations — uploads, exports, background jobs.
- **What:** Sonner toast with Progress bar for short ops. Notification center entry for long ops. Completion transitions to success CTA.
- **A11y:** `role="progressbar"` with `aria-valuenow`. Announce milestones at 10-25% increments via `aria-live="polite"`.

## 3. Notification Management

### Read / Unread State
- **When:** Every notification list needs read/unread tracking.
- **What:** `read_at` timestamp. Mark on click or explicit action. Batch "Mark all as read". Optimistic UI.
- **A11y:** More than color alone — bold + dot + tinted background. Include "unread" in `aria-label`.

### Notification Grouping
- **When:** Multiple related events — "3 people liked your post".
- **What:** Server-side aggregation by entity_id + type within time window. Avatar stack (up to 3). Expand on click.
- **A11y:** `aria-expanded` on group header. `role="group"` for expanded items. Announce count changes.

### Smart Batching / Digest
- **When:** Reducing notification fatigue. User-controlled cadence: immediate, hourly, daily, weekly.
- **What:** Queue in batch table. Cron/scheduled function for delivery. Summary card: "12 new since last visit".
- **A11y:** Digest summary with clear structure. Navigate via headings. Semantic HTML in email digests.

### Snooze & Remind Later
- **When:** Temporarily dismiss without losing the notification.
- **What:** `snoozed_until` timestamp. Preset options (1h, 3h, tomorrow, next week) + custom picker. Resurface with "snoozed" badge.
- **A11y:** Announce snooze confirmation. Menu keyboard-navigable. Announce resurfaced notification as new.

### Notification Actions
- **When:** Let users act without navigating away — Accept, Decline, Reply.
- **What:** Inline buttons (max 2-3). Each maps to API endpoint. Optimistic UI. Push notification action buttons.
- **A11y:** Descriptive `aria-label` in context: "Accept invitation from Alice". Announce action result. Confirm destructive actions.

## 4. Preferences & Control

### Notification Preferences Matrix
- **When:** Multiple notification types x multiple channels.
- **What:** Grid with Switch toggles. Group rows by category. Auto-save or submit. "Reset to defaults".
- **A11y:** Proper `<th>` headers. Each Switch: `aria-label="Email notifications for new comments"`. Arrow key grid navigation.

### Frequency Controls
- **When:** Users control notification cadence per type.
- **What:** Per-type frequency (immediate, hourly, daily, weekly, off). Preset modes ("Calm", "Regular", "Power User").
- **A11y:** `role="radiogroup"` with `aria-label`. Preset buttons with `aria-describedby` for description.

### Do Not Disturb / Quiet Hours
- **When:** Schedule-based silencing. Queue suppressed notifications. Critical alerts bypass.
- **What:** Time range picker + day checkboxes + timezone. Separate "critical" types that break through.
- **A11y:** Keyboard-accessible time pickers. DND status in header. Announce toggle.

### Channel-Specific Opt-Out
- **When:** Users disable entire channels — "stop all emails", "turn off push".
- **What:** Global channel toggles. Email: `List-Unsubscribe` + `List-Unsubscribe-Post` headers. One-click unsubscribe endpoint.
- **A11y:** Descriptive toggle labels. No login required to unsubscribe (use signed tokens).
- **Anti-pattern:** Never hide unsubscribe behind multiple clicks.

## 5. Accessibility

### ARIA Live Region
- **When:** Announcing dynamic content to screen readers without focus change.
- **What:** Pre-render empty container with `aria-live="polite"`. Insert full message in one DOM mutation. `role="alert"` only for critical errors.
- **A11y:** Test NVDA, JAWS, VoiceOver. `aria-relevant="additions"`. `aria-atomic="true"`. No `aria-live` on rapidly updating regions.
- **Anti-pattern:** Never double up `role="alert"` + `aria-live="assertive"` (announces twice).

### Focus Management
- **When:** Every notification type — ensure focus is not stolen.
- **What:** Toasts/banners: inject into `aria-live` region, no `.focus()`. Modals: `FocusTrap` + restore `activeElement` on close.
- **A11y:** WCAG 3.2.1 (no focus change on input). WCAG 2.4.3 (logical focus order). Test keyboard-only navigation.

### Screen Reader Announcements
- **When:** Crafting announcement text for screen readers.
- **What:** Format: "[Actor] [action] [object] — [time]". Batch rapid updates into summaries. `role="log"` for lists, `role="status"` for updates.
- **A11y:** Test announcement timing across screen readers. Use visually-hidden text if visual and announced text differ.

### Keyboard Navigation
- **When:** All notification interactions.
- **What:** Tab to bell, Enter/Space to open, arrow keys to navigate items, Enter to activate, Escape to close. Roving tabindex.
- **A11y:** WCAG 2.1.1 (keyboard-operable). Visible focus indicators. `aria-setsize` + `aria-posinset`. No focus trap in notification list.

### Reduced Motion
- **When:** Toast slide-ins, badge bounces, drawer transitions.
- **What:** `@media (prefers-reduced-motion: reduce)` — replace with instant/opacity fade. `useReducedMotion()` hook for React.
- **A11y:** WCAG 2.3.3 (AAA) / 2.3.1 (AA). Sonner respects this by default.

### High Contrast
- **When:** All notification UI in forced-colors mode.
- **What:** `@media (forced-colors: active)` — use borders and text weight, not background fills. Unread indicator visible without color.
- **A11y:** WCAG 1.4.3 (4.5:1 text), 1.4.11 (3:1 UI components). Severity colors must pass contrast against background.
