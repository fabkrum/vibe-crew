export interface NotificationPattern {
  name: string;
  category: 'delivery' | 'display' | 'management' | 'preferences' | 'accessibility';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<NotificationPattern['category'], string> = {
  delivery: 'Delivery Channels',
  display: 'Display Patterns',
  management: 'Notification Management',
  preferences: 'Preferences & Control',
  accessibility: 'Accessibility',
};

export const categoryOrder: NotificationPattern['category'][] = [
  'delivery', 'display', 'management', 'preferences', 'accessibility',
];

export const notificationPatterns: NotificationPattern[] = [
  // --- Delivery Channels ---
  {
    name: 'Toast / Snackbar',
    category: 'delivery',
    description: 'Ephemeral, non-blocking messages that appear briefly (3-5 seconds) and auto-dismiss. Use for confirmations, success feedback, and low-priority status updates that do not require user action. Position bottom-center (mobile) or bottom-right (desktop). Never use for errors that require acknowledgment.',
    implementation: 'shadcn: Sonner (recommended, replaces deprecated Toast). Call toast() with message string. Use toast.success(), toast.error(), toast.loading() for semantic variants. Position via <Toaster position="bottom-right" />. Stack multiple toasts vertically with gap.',
    a11y: 'Sonner uses role="status" and aria-live="polite" by default. For error toasts, use toast.error() which applies role="alert". Never auto-dismiss error messages — use dismissible persistent toasts instead. Ensure sufficient color contrast on toast backgrounds.',
    docsUrl: 'https://ui.shadcn.com/docs/components/radix/sonner',
  },
  {
    name: 'In-App Banner',
    category: 'delivery',
    description: 'A persistent or dismissible strip across the top of the page for system-wide announcements — maintenance windows, new feature launches, billing alerts. Higher visibility than toasts, lower disruption than modals. Use sparingly: more than one banner creates "banner blindness" (NN/G).',
    implementation: 'shadcn: Alert component with variant="default" or "destructive". Position fixed at viewport top or inline above main content. Include a dismiss button (X) and optional CTA link. Animate entrance with slide-down. Persist dismissal in localStorage to avoid re-showing.',
    a11y: 'Use role="alert" for urgent banners (outages, security). Use role="status" for informational. Add aria-label describing the banner purpose. Dismiss button must be keyboard-accessible with visible focus ring. Do not auto-dismiss important banners.',
    docsUrl: 'https://ui.shadcn.com/docs/components/radix/alert',
  },
  {
    name: 'Push Notification (Web)',
    category: 'delivery',
    description: 'Browser-level notifications delivered via the Push API + Service Worker, even when the tab is inactive. Opt-in rates average 7-12% on web. Never show the browser permission prompt on first page load — pre-prompt with a custom UI explaining the value first (Smashing Magazine). Personalize content; generic blasts see <1% CTR vs 10%+ for behavioral triggers.',
    implementation: 'Register a Service Worker, subscribe via PushManager.subscribe() with VAPID keys. Backend sends payloads via web-push library. Show custom pre-permission UI (soft ask) before navigator.permissions.query(). Store subscription endpoint server-side. Handle push event in SW with self.registration.showNotification().',
    a11y: 'Push notifications are OS-level and inherit system accessibility settings. The pre-permission prompt (soft ask) must be keyboard-navigable and screen-reader-announced. Never block page content behind a permission wall. Respect OS-level Do Not Disturb settings.',
    docsUrl: null,
  },
  {
    name: 'Push Notification (Mobile)',
    category: 'delivery',
    description: 'Platform-native notifications via APNs (iOS) or FCM (Android). Higher engagement than web push — average opt-in rates 50-60% (iOS asks explicitly; Android opts in by default). Delay permission request until the user has experienced value (NN/G). Limit to 2-5 per day for most apps. Include rich media (images, GIFs) for 25% higher click rates.',
    implementation: 'React Native: expo-notifications or react-native-push-notification. iOS: request authorization via UNUserNotificationCenter. Android: FCM via google-services. Use notification channels (Android 8+) for category-based control. Deep-link to relevant in-app screens on tap.',
    a11y: 'iOS VoiceOver and Android TalkBack read notification content automatically. Keep titles under 50 characters. Use notification actions (reply, mark read) for quick interaction without opening the app. Respect platform quiet hours.',
    docsUrl: null,
  },
  {
    name: 'Email Notification',
    category: 'delivery',
    description: 'Transactional and digest emails for events the user should not miss — order confirmations, security alerts, weekly summaries. NN/G distinguishes transactional (triggered by user action) from system-generated. Always include an unsubscribe link (legally required: CAN-SPAM, GDPR). Batch low-priority events into daily/weekly digests rather than sending individual emails.',
    implementation: 'Use transactional email services (Resend, SendGrid, Postmark). React Email for templating. Queue emails via background jobs (BullMQ, Inngest). Implement exponential backoff for delivery failures. Store email preferences per notification type in the user profile. Include plain-text fallback.',
    a11y: 'Use semantic HTML in emails (<h1>, <p>, <table>) for screen reader compatibility. Provide alt text on all images. Ensure minimum 4.5:1 contrast ratio. Include a plain-text version. Unsubscribe link must be prominent and functional.',
    docsUrl: null,
  },
  {
    name: 'In-App Message / Interstitial',
    category: 'delivery',
    description: 'Full-screen or modal overlays triggered by context — onboarding prompts, upgrade nudges, feature announcements. Higher engagement than banners but more disruptive. Use for high-value, low-frequency messages. Never interrupt a user mid-task. Show only when idle or at natural transition points (page navigation, task completion).',
    implementation: 'shadcn: Dialog for modal, Sheet for slide-over. Trigger on route change or after idle timeout. Track impression and dismissal in analytics. Use a queue to prevent stacking multiple interstitials. Respect frequency caps (e.g., once per session, once per week).',
    a11y: 'Dialog must trap focus and return it on close. Include visible close button and Escape key dismiss. Announce dialog title to screen readers via aria-labelledby. Never auto-dismiss — let the user control timing. Background content must be inert (aria-hidden).',
    docsUrl: null,
  },
  {
    name: 'Webhook / Real-Time Event',
    category: 'delivery',
    description: 'Server-to-client delivery for real-time events — new messages, status changes, live updates. WebSockets for persistent bidirectional connections; Server-Sent Events (SSE) for unidirectional server push. Use SSE for simple notification feeds; WebSockets when the client also sends data (chat, collaboration).',
    implementation: 'SSE: EventSource API on client, text/event-stream endpoint on server. WebSocket: ws library or Socket.IO with reconnection and heartbeat. Merge real-time events with notification center state. Deduplicate events by ID. Show connection status indicator when disconnected.',
    a11y: 'Announce new real-time notifications via aria-live="polite" region. Do not auto-focus or auto-scroll to new items — let the user opt in. Provide a visual indicator (badge count, "New items" button) instead of disruptive injection.',
    docsUrl: null,
  },

  // --- Display Patterns ---
  {
    name: 'Bell Icon + Badge',
    category: 'display',
    description: 'The universal entry point to a notification center. A bell icon in the header/masthead with a numeric or dot badge indicating unread count. Clicking toggles a notification drawer or popover. The badge color communicates urgency: blue/default for unread, red for critical. Hide the badge (not the bell) when all are read.',
    implementation: 'shadcn: Popover triggered by Button with Bell icon (lucide-react). Badge component overlaid via absolute positioning. Fetch unread count via polling (30-60s) or real-time subscription. Use a dot badge for "has unread" or numeric badge for exact count (cap at "99+").',
    a11y: 'Bell button: aria-label="Notifications, 3 unread" (dynamic count). Badge is decorative — do not add separate aria-label. Popover must be keyboard-navigable. Announce new notification arrival via aria-live region, not by stealing focus to the bell.',
    docsUrl: null,
  },
  {
    name: 'Notification Center / Drawer',
    category: 'display',
    description: 'A dedicated panel (popover, drawer, or full page) listing all notifications in reverse chronological order. The central hub where every notification channel converges. Visually distinguish read vs unread (background color or font weight). Group by time ("Today", "This week", "Earlier") or by type. Include "Mark all as read" action.',
    implementation: 'shadcn: Sheet (side drawer) or Popover for compact view. Full page for complex apps. Virtualize long lists (react-window or tanstack-virtual). Each item: avatar, title, description, timestamp, read/unread indicator, action button. Infinite scroll with "Load more" or cursor-based pagination.',
    a11y: 'Use role="log" on the notification list for screen readers. Each notification is a list item with aria-label combining sender, message, and time. "Mark all as read" button must be keyboard-accessible. Announce list updates via aria-live="polite" — never auto-focus the drawer.',
    docsUrl: null,
  },
  {
    name: 'Notification Item',
    category: 'display',
    description: 'The individual notification entry in a list. Includes: avatar/icon, title, body text (truncated), timestamp (relative: "2m ago"), and optional action buttons. Unread items have a visual indicator (dot, bold text, tinted background). Clicking navigates to the relevant resource. Swipe actions on mobile (mark read, delete).',
    implementation: 'Compose from shadcn: Avatar + text + Badge (unread dot). Render relative timestamps with date-fns formatDistanceToNow(). Add hover actions (mark read, delete) in a dropdown menu. On mobile, use swipe gestures via react-swipeable. Deep-link onClick to the source entity.',
    a11y: 'Each item: role="listitem" with descriptive aria-label. Unread state: aria-label includes "unread". Hover actions must also be available via keyboard (context menu or visible buttons). Relative timestamps should have title attribute with absolute date-time for screen readers.',
    docsUrl: null,
  },
  {
    name: 'Inline Notification',
    category: 'display',
    description: 'Contextual notifications embedded within the page content, near the element they relate to — form validation results, section-specific alerts, feature deprecation warnings. Unlike toasts, they persist and are part of the page flow. Use for information that is relevant only in context.',
    implementation: 'shadcn: Alert with icon (CheckCircle, AlertTriangle, Info, XCircle). Place immediately above or below the related content. Use callout styling (left border accent). For form validation, place below the input or in a summary above the form. Support dismissible and persistent variants.',
    a11y: 'Use role="alert" for errors requiring attention, role="status" for success/info. Associate with related form field via aria-describedby. Do not use aria-live on persistent inline notifications — they are read in normal document flow. Ensure icon meaning is conveyed via aria-hidden + visible text label.',
    docsUrl: 'https://ui.shadcn.com/docs/components/radix/alert',
  },
  {
    name: 'Floating Action Badge',
    category: 'display',
    description: 'A badge on navigation items, tabs, or icons indicating pending activity — unread messages on a chat tab, new items in a feed, pending approvals on an admin link. Source-anchored badges (Facebook-style) let users see the category of notification at a glance without opening the notification center.',
    implementation: 'shadcn: Badge component positioned absolutely on the parent icon/tab. Use a dot for binary state (has/no activity) or number for count. Animate entrance with scale-in. Clear badge on navigation to that section. Sync with notification center read state.',
    a11y: 'Badge count must be included in the parent element\'s aria-label: "Messages, 5 unread". Badge itself should be aria-hidden="true" since it is visually redundant with the label. Do not rely on color alone — include the count or dot shape as a secondary indicator.',
    docsUrl: null,
  },
  {
    name: 'Progress Notification',
    category: 'display',
    description: 'Shows ongoing operation status — file uploads, data exports, background job progress. Use a toast with a progress bar for short operations (<30s). For long-running tasks, show a persistent indicator in the notification center with percentage or step count. Allow users to navigate away without losing progress.',
    implementation: 'Sonner: toast() with custom JSX including a Progress component. For background tasks, store progress server-side and poll or stream via SSE. Show in notification center with progress bar. On completion, transition to a success notification with download link or result CTA.',
    a11y: 'Use role="progressbar" with aria-valuenow, aria-valuemin, aria-valuemax. Announce major milestones ("50% complete", "Upload finished") via aria-live="polite". Do not announce every percentage tick — batch updates to 10-25% increments. Include text percentage alongside the visual bar.',
    docsUrl: null,
  },

  // --- Notification Management ---
  {
    name: 'Read / Unread State',
    category: 'management',
    description: 'Binary state tracking for each notification. Unread items are visually distinct (bold text, tinted background, dot indicator). Mark as read on click/navigation, or provide explicit "mark as read" action. Batch action: "Mark all as read". Allow marking items as unread for follow-up. Unread count drives the bell badge.',
    implementation: 'Store read_at timestamp per notification per user. null = unread. API: PATCH /notifications/:id { read: true }. Batch: PATCH /notifications/mark-all-read. Compute unread count with COUNT WHERE read_at IS NULL. Optimistic UI: update state immediately, revert on error.',
    a11y: 'Announce state change: "Notification marked as read" via aria-live="polite". Visually, use more than color alone — combine bold text + dot indicator + background tint. Screen readers should include "unread" in the item label for unread notifications.',
    docsUrl: null,
  },
  {
    name: 'Notification Grouping',
    category: 'management',
    description: 'Collapse related notifications into a single grouped entry — "3 people liked your post", "5 new comments on Project X". Reduces notification fatigue and list length. Group by entity (same post, same thread), by type (all likes together), or by sender. Expand to show individual items on click.',
    implementation: 'Server-side: aggregate notifications with same entity_id and type within a time window (e.g., 1 hour). Store group_id and member_count. Client: render collapsed view with avatar stack (up to 3 faces) and summary text. Expand inline or navigate to detail view. Update group when new events arrive.',
    a11y: 'Group summary aria-label: "3 people liked your post, expandable". Use aria-expanded on the group header. Expanded items use role="group" with aria-label. Announce group count changes via aria-live="polite" to avoid overwhelming announcements.',
    docsUrl: null,
  },
  {
    name: 'Smart Batching / Digest',
    category: 'management',
    description: 'Instead of delivering every event immediately, batch notifications into periodic summaries — daily digest email, hourly in-app summary. Reduces interruption frequency dramatically. Let users choose cadence: immediate, hourly, daily, weekly. Facebook and LinkedIn use gradual grouping, releasing notification blocks at appropriate intervals.',
    implementation: 'Backend: queue notifications in a batch table with scheduled delivery time. Cron job or scheduled function processes batches and sends digests. Per-user cadence stored in notification preferences. In-app: show "You have 12 new notifications since your last visit" summary card at the top of the center.',
    a11y: 'Digest summary must be screen-reader-friendly with clear structure: "Daily summary: 5 messages, 3 mentions, 2 updates". Each section within the digest should be navigable via headings. Email digests: use semantic HTML with proper heading hierarchy.',
    docsUrl: null,
  },
  {
    name: 'Snooze & Remind Later',
    category: 'management',
    description: 'Let users temporarily dismiss a notification and have it resurface at a chosen time — "Remind me in 1 hour", "Tomorrow morning", "Next week". Prevents notification from being lost while reducing immediate noise. Common in email (Gmail snooze) and task management apps.',
    implementation: 'Store snoozed_until timestamp on the notification. Backend scheduler resurfaces at that time. UI: dropdown with preset options (1h, 3h, tomorrow 9am, next Monday) plus custom date/time picker. Snoozed items disappear from the active list and reappear with a "snoozed" badge when due.',
    a11y: 'Announce snooze confirmation: "Notification snoozed until tomorrow 9:00 AM" via aria-live="polite". The snooze action menu must be keyboard-navigable. When the notification resurfaces, announce it as a new notification — do not silently inject it.',
    docsUrl: null,
  },
  {
    name: 'Notification Actions',
    category: 'management',
    description: 'Actionable buttons within the notification itself — "Accept", "Decline", "Reply", "View", "Archive". Let users act without navigating away. Limit to 2-3 actions maximum. Primary action should be prominent; secondary actions in a menu. Push notifications support up to 3 action buttons on both iOS and Android.',
    implementation: 'Render action buttons inline in the notification item. API: each action maps to a specific endpoint (e.g., POST /invitations/:id/accept). Optimistic UI: immediately reflect action result. For push notifications: define actions in the notification payload with action identifiers. Handle action responses in the Service Worker.',
    a11y: 'Each action button must have a descriptive aria-label in context: "Accept invitation from Alice" not just "Accept". Buttons must be keyboard-accessible. Announce action result: "Invitation accepted" via aria-live="polite". Destructive actions (delete, decline) should use a confirmation step.',
    docsUrl: null,
  },
  {
    name: 'Notification History & Archive',
    category: 'management',
    description: 'A searchable, filterable archive of past notifications that users can revisit. Not all notifications need to persist — auto-delete ephemeral ones (toast confirmations) after 30 days. Keep important ones (security alerts, receipts) indefinitely. Provide search and filter by type, date range, and read status.',
    implementation: 'Database: notifications table with soft-delete (archived_at). Pagination with cursor-based queries for performance. UI: full-page view with search bar, type filter dropdown, date range picker. Auto-archive read notifications older than 30 days via cron. Provide "Delete all" with confirmation.',
    a11y: 'Search and filter controls must be keyboard-accessible and labeled. Results list uses role="log" or role="feed" with aria-label. Announce search result count: "12 notifications found" via aria-live="polite". Each archived item remains navigable.',
    docsUrl: null,
  },

  // --- Preferences & Control ---
  {
    name: 'Notification Preferences Matrix',
    category: 'preferences',
    description: 'A grid of notification types (rows) vs delivery channels (columns: in-app, email, push, SMS). Users toggle each cell to control exactly which events reach them on which channel. The HubSpot pattern — research showed this matrix format helps users set preferences faster than separate pages per channel.',
    implementation: 'Data model: notification_preferences table with user_id, notification_type, channel, enabled. UI: table with Switch toggles in each cell. Group rows by category (e.g., "Activity", "Marketing", "Security"). Save on change (auto-save) or via a submit button. Provide "Reset to defaults" action.',
    a11y: 'Table must use proper <th> headers for both rows (type) and columns (channel). Each Switch needs aria-label: "Email notifications for new comments". Announce toggle state change via aria-live="polite". Provide keyboard navigation between cells (arrow keys within the grid).',
    docsUrl: null,
  },
  {
    name: 'Frequency Controls',
    category: 'preferences',
    description: 'Let users control how often they receive notifications — immediate, hourly digest, daily digest, weekly summary, or none. Basecamp offers "Always On" and "Work Can Wait" presets. Smashing Magazine recommends offering predefined modes: "Calm" (low frequency), "Regular" (medium), and "Power User" (high) as starting points.',
    implementation: 'Per notification type: frequency enum (immediate, hourly, daily, weekly, off). Store in notification_preferences. UI: radio group or select dropdown per type. For presets: segmented control at top ("Calm / Regular / Power User") that bulk-sets frequencies. Override individual types after selecting a preset.',
    a11y: 'Radio groups must be properly grouped with role="radiogroup" and aria-label. Announce frequency change confirmation. Preset selector must explain what each mode does via tooltips or inline descriptions. Provide aria-describedby linking the preset button to its description.',
    docsUrl: null,
  },
  {
    name: 'Do Not Disturb / Quiet Hours',
    category: 'preferences',
    description: 'A schedule-based silencing mode — suppress all non-critical notifications during set hours (e.g., 10 PM - 8 AM) or specific days (weekends). Slack popularized "Do Not Disturb" mode. Queue suppressed notifications and deliver them when quiet hours end. Always allow critical notifications (security alerts) to break through.',
    implementation: 'Store quiet_hours_start, quiet_hours_end, quiet_days, timezone in user preferences. Backend: check quiet hours before sending push/email notifications. Queue suppressed notifications. Separate "critical" notification types that bypass DND. UI: time range picker + day checkboxes + timezone selector.',
    a11y: 'Time pickers must be keyboard-accessible. Clearly indicate current DND status in the notification center header: "Do Not Disturb until 8:00 AM". Announce DND toggle: "Do Not Disturb enabled" via aria-live="polite". Critical notification bypass must be explained to the user.',
    docsUrl: null,
  },
  {
    name: 'Channel-Specific Opt-Out',
    category: 'preferences',
    description: 'Allow users to disable specific delivery channels entirely — "Stop all emails but keep in-app" or "Turn off push notifications". Simpler than the full preferences matrix for users who want broad control. Must include legally required email unsubscribe (CAN-SPAM, GDPR). One-click unsubscribe in email headers (RFC 8058, required by Gmail/Yahoo since 2024).',
    implementation: 'Global channel toggles in notification settings: in_app_enabled, email_enabled, push_enabled, sms_enabled. Email: List-Unsubscribe and List-Unsubscribe-Post headers in every transactional email. One-click unsubscribe endpoint. Provide in-email link to preferences page for granular control.',
    a11y: 'Channel toggles must have descriptive labels: "Receive email notifications" not just "Email". Announce toggle result. Unsubscribe landing page must be accessible and confirm the action clearly. Do not require login to unsubscribe — use signed tokens in the URL.',
    docsUrl: null,
  },
  {
    name: 'Notification Onboarding',
    category: 'preferences',
    description: 'A first-run experience that helps users configure their notification preferences before the defaults kick in. Ask during onboarding or after the user has experienced value (NN/G recommends delaying). Show 2-3 simple questions: preferred channels, frequency level, quiet hours. Provide sane defaults for users who skip.',
    implementation: 'Show notification preferences step in the onboarding wizard or as a post-signup prompt after the 3rd session. Use a stepped card UI with progressive disclosure. Default to conservative settings (digest mode, in-app only). Store completion flag to avoid re-showing. Allow "Set up later" to skip.',
    a11y: 'Onboarding flow must be keyboard-navigable with clear step indicators. Each preference control properly labeled. "Skip" action must be equally prominent as "Continue". Announce step progress: "Step 2 of 3: Notification preferences" via aria-live="polite".',
    docsUrl: null,
  },

  // --- Accessibility ---
  {
    name: 'ARIA Live Region',
    category: 'accessibility',
    description: 'The foundation of accessible notifications. An aria-live region announces dynamic content changes to screen readers without stealing focus. Use aria-live="polite" for most notifications (waits for idle). Use aria-live="assertive" or role="alert" only for critical errors or security warnings. Never double up: role="alert" already implies assertive.',
    implementation: 'Pre-render an empty container with aria-live="polite" in the DOM. Insert notification text into it when events occur. Compose the full message before insertion — do not make multiple DOM mutations for one notification. Remove content after a delay to avoid re-announcement. Sonner handles this automatically.',
    a11y: 'Test across NVDA, JAWS, and VoiceOver — live region behavior varies. Do not use aria-live on containers with many updates (chat feeds) — announce summaries instead ("3 new messages"). Set aria-relevant="additions" to avoid announcing removals. Set aria-atomic="true" to read the entire region on change.',
    docsUrl: null,
  },
  {
    name: 'Focus Management',
    category: 'accessibility',
    description: 'Notifications must never steal focus from the user\'s current task. Toasts, banners, and real-time updates should be announced via aria-live regions without moving focus. Only modal dialogs (critical alerts requiring acknowledgment) may trap focus — and must return it to the trigger element on dismissal.',
    implementation: 'For toasts/banners: inject into aria-live region, do not call .focus(). For modal notifications: use Dialog with FocusTrap (radix-ui). Store document.activeElement before opening, restore on close. For notification center drawer: focus the first item when opened, return focus to bell icon on close.',
    a11y: 'WCAG 2.1 SC 3.2.1: No focus change on input. WCAG 2.4.3: Focus order must be logical. Test with keyboard-only navigation: can the user complete their task without interruption when notifications arrive? Modal notifications must implement full focus trap per WAI-ARIA dialog pattern.',
    docsUrl: null,
  },
  {
    name: 'Screen Reader Announcements',
    category: 'accessibility',
    description: 'Craft notification text for screen reader comprehension. Include: what happened, who triggered it, and what action (if any) is needed. Keep announcements concise — screen reader users often navigate quickly. Batch rapid-fire updates into summaries rather than announcing each one. Test with multiple screen readers.',
    implementation: 'Compose announcement strings: "[Actor] [action] [object] — [time]". Example: "Alice commented on your pull request — 2 minutes ago". For grouped notifications: "3 new comments on Project X". Insert into aria-live region as a single text node. Use visually-hidden text if the visual and announced text should differ.',
    a11y: 'Use role="log" for notification lists (implies aria-live="polite"). Use role="status" for non-critical updates. Use role="alert" only for errors/security. Test announcement timing — polite waits for idle, assertive interrupts. Avoid aria-live on rapidly updating regions; use a summary approach instead.',
    docsUrl: null,
  },
  {
    name: 'Keyboard Navigation',
    category: 'accessibility',
    description: 'All notification interactions must be fully keyboard-accessible. Tab to the bell icon, Enter/Space to open the center, arrow keys to navigate items, Enter to activate, Escape to close. Notification actions (mark read, delete, snooze) must be reachable without a mouse. Swipe gestures on mobile must have keyboard equivalents.',
    implementation: 'Bell icon: standard button semantics. Notification center: roving tabindex on list items (arrow up/down). Each item: Enter to navigate, context menu via Shift+F10 or dedicated action buttons. Dismiss drawer: Escape key handler. Focus visible indicators on all interactive elements. Tab order: bell → list → actions → close.',
    a11y: 'WCAG 2.1 SC 2.1.1: All functionality keyboard-operable. Notification items must show visible focus indicators (outline, ring). Action menus must support arrow key navigation. Announce current position: "Notification 3 of 12" via aria-setsize and aria-posinset. Do not trap focus in the notification list.',
    docsUrl: null,
  },
  {
    name: 'Reduced Motion Support',
    category: 'accessibility',
    description: 'Toast slide-ins, banner animations, badge bounces, and drawer transitions must respect the user\'s prefers-reduced-motion setting. Replace animations with instant appearance or gentle opacity fades. Some users experience motion sickness from sliding/bouncing notification animations.',
    implementation: 'CSS: @media (prefers-reduced-motion: reduce) { .toast, .notification-badge { animation: none; transition: opacity 0.15s; } }. In React: useReducedMotion() hook to conditionally set Sonner duration and animation props. Framer Motion: set layout={false} when reduced motion is active.',
    a11y: 'WCAG 2.3.3 (AAA): Animation from interactions can be disabled. At minimum, target WCAG 2.3.1 (AA): no content flashes more than 3 times per second. Sonner respects prefers-reduced-motion by default. Test with macOS "Reduce motion" and Windows "Show animations" settings.',
    docsUrl: null,
  },
  {
    name: 'Sound & Haptic Accessibility',
    category: 'accessibility',
    description: 'Notification sounds and vibration patterns provide additional sensory channels but must never be the sole indicator. Always pair audio/haptic with visual feedback. Provide controls to adjust or disable notification sounds independently of system volume. Haptic patterns can differentiate notification types (short buzz = message, long = alert).',
    implementation: 'Web: Audio API for notification sounds with user preference toggle. Mobile: Haptics API (iOS) or Vibration API. Store sound_enabled and haptic_enabled in user preferences. Provide per-type sound customization. Play sounds only when the app is in the foreground (background = push notification default sound).',
    a11y: 'WCAG 1.4.2: Audio control — provide a mechanism to pause, stop, or adjust volume. Never auto-play sounds on page load. Deaf users must have equivalent visual notifications. Provide visual pulse or flash as an alternative to sound (not a substitute for — in addition to). Test with assistive hearing devices.',
    docsUrl: null,
  },
  {
    name: 'High Contrast Notifications',
    category: 'accessibility',
    description: 'Ensure notification UI meets contrast requirements in both light and dark modes and under Windows High Contrast / forced-colors mode. Notification badges, toast backgrounds, read/unread indicators, and action buttons must all maintain WCAG AA contrast ratios (4.5:1 for text, 3:1 for UI components).',
    implementation: 'Use CSS custom properties (design tokens) for all notification colors. Test with forced-colors media query: @media (forced-colors: active) { .notification-badge { border: 2px solid ButtonText; } }. Ensure unread indicator is visible without color: use a filled circle + bold text, not just a tinted background.',
    a11y: 'WCAG 1.4.3: Contrast minimum 4.5:1 for normal text, 3:1 for large text. WCAG 1.4.11: Non-text contrast 3:1 for UI components. Notification severity colors (green/yellow/red) must pass contrast against their background. In high contrast mode, rely on borders and text weight, not background fills.',
    docsUrl: null,
  },
];
