export interface SettingsPattern {
  name: string;
  category: 'layout' | 'account' | 'preferences' | 'billing' | 'security' | 'data';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<SettingsPattern['category'], string> = {
  layout: 'Settings Layout',
  account: 'Account Management',
  preferences: 'Preferences & Appearance',
  billing: 'Billing & Subscription',
  security: 'Security & Access',
  data: 'Data & Privacy',
};

export const categoryOrder: SettingsPattern['category'][] = [
  'layout', 'account', 'preferences', 'billing', 'security', 'data',
];

export const settingsPatterns: SettingsPattern[] = [
  // --- Layout ---
  {
    name: 'Sidebar Settings Navigation',
    category: 'layout',
    description: 'A two-column layout with a vertical navigation sidebar on the left and the active settings panel on the right. The sidebar lists all settings categories (Profile, Notifications, Billing, Security, etc.) as links, with the active category highlighted. Popularized by GitHub, Stripe, and Linear. On mobile, the sidebar collapses into a full-width category list that navigates to individual setting panels. This pattern scales well — new categories are added to the sidebar without redesigning the page.',
    implementation: 'Use a two-column CSS grid: sidebar (200-240px fixed) + content (1fr). Sidebar: vertical nav with links styled as list items, active state with accent background + left border indicator. Content area: scrollable with a heading matching the active category. URL-based routing: /settings/profile, /settings/billing — enables deep-linking and browser back/forward. On mobile (< 768px): hide the sidebar, show a full-width list of categories; selecting one navigates to the settings panel with a back button.',
    a11y: 'Sidebar: <nav aria-label="Settings"> with <ul role="list">. Active link: aria-current="page". Content area: <main> or role="main" with heading matching the active category. Mobile: back button aria-label="Back to settings categories." Keyboard: Tab navigates sidebar links, Enter activates. Ensure focus moves to the content heading when a category is selected (manage focus on route change).',
    docsUrl: null,
  },
  {
    name: 'Tabbed Settings',
    category: 'layout',
    description: 'Horizontal tabs at the top of the settings page, each tab representing a settings category. The active tab\'s content panel is displayed below. Best for settings pages with 3-7 categories — beyond that, tabs overflow and require scrolling or a "More" dropdown. Vercel, Notion, and Supabase use this pattern. Tabs can be combined with sub-sections within each panel for deeper organization. URL routing maps each tab to a path segment for deep-linking.',
    implementation: 'Use a Tabs component (Radix UI, shadcn/ui) with each TabsTrigger as a category name and TabsContent as the settings panel. Route-based tabs: sync the active tab with the URL path (e.g., /settings?tab=notifications). Each panel contains form groups with headings. For overflow (>6 tabs): add horizontal scroll with fade indicators or a "More" dropdown. Mobile: tabs can stack vertically or switch to a select dropdown. Persist tab state across page reloads via URL.',
    a11y: 'Tabs: role="tablist" with role="tab" on each trigger and role="tabpanel" on content. aria-selected="true" on the active tab. Keyboard: Arrow Left/Right moves between tabs, Enter/Space activates. Tab panels: aria-labelledby pointing to the corresponding tab. Do not auto-activate tabs on arrow key — require Enter/Space (manual activation mode) for settings pages where each tab may trigger data loading.',
    docsUrl: null,
  },
  {
    name: 'Grouped Settings Sections',
    category: 'layout',
    description: 'Organizing settings within a single scrollable page into visually distinct groups separated by headings, descriptions, and dividers. Each group contains related settings (e.g., "Notifications" group has email, push, and in-app toggles). A sticky table-of-contents or jump links at the top allows quick navigation to any group. Used by Tailwind UI, Stripe Dashboard, and most SaaS admin panels. Best when combined with sidebar navigation — the sidebar selects the category, and the content area uses grouped sections.',
    implementation: 'Each group: a <section> with an <h3> heading, optional description paragraph, and the settings controls. Separate groups with 2rem+ gap or a horizontal divider. Jump links: render a list of anchor links at the top of the page, each linking to the section ID. Use IntersectionObserver to highlight the active section in the jump links as the user scrolls. Group order: most frequently changed settings first (analytics show 80% of users only change 2-3 settings).',
    a11y: 'Each section: aria-labelledby pointing to its heading. Jump links: <nav aria-label="On this page">. Active jump link: aria-current="true". Headings: proper hierarchy (h2 for page title, h3 for groups, h4 for sub-groups). Dividers: <hr> with role="separator" or purely visual (aria-hidden). Ensure the page is navigable by heading level for screen reader users (common navigation method).',
    docsUrl: null,
  },
  {
    name: 'Two-Column Setting Row',
    category: 'layout',
    description: 'Each individual setting is displayed as a horizontal row with the label and description on the left and the control (toggle, select, input) on the right. This two-column layout creates a consistent visual rhythm that scales well across many settings. The left column explains what the setting does; the right column provides the interaction. Used extensively in iOS Settings, Android Settings, GitHub, and Linear. The pattern works for toggles, selects, text inputs, and even small inline forms.',
    implementation: 'Flex row with justify-content: space-between. Left side: label (<label> or <span>) + optional description text (muted, smaller font). Right side: the control (Switch, Select, Input). Vertical alignment: center the control with the label. For text inputs or multi-field settings, stack the control below the description (full-width). Group multiple rows in a card or bordered section. Row height: minimum 48px for touch targets. Add a subtle hover background for interactive rows.',
    a11y: 'Label: <label for="setting-id"> explicitly associated with the control. Description: aria-describedby on the control pointing to the description element. Toggle: role="switch" aria-checked. Select: native <select> or custom with role="listbox". Ensure the entire row is not clickable — only the control is interactive (clicking the label is fine as it\'s associated). Tab order: sequential through controls, skip decorative elements.',
    docsUrl: null,
  },
  {
    name: 'Settings Search',
    category: 'layout',
    description: 'A search input at the top of the settings page that filters settings by keyword — essential for complex settings pages with 50+ options. As the user types, settings that don\'t match are hidden and matching settings are highlighted. Search covers setting names, descriptions, and category names. macOS System Preferences, Chrome settings (chrome://settings), and VS Code settings all use this pattern. Dramatically reduces time-to-setting for power users.',
    implementation: 'Search input pinned at the top of the settings page (or in the sidebar header). On input: filter all settings by matching the query against name + description + category. Use a lightweight fuzzy matcher (fuse.js) or simple substring matching. Highlight matching text with <mark>. Show results grouped by category. If no results: show "No settings found for [query]" with a suggestion to clear the search. Debounce input at 150ms. Clear button (X) to reset. Keyboard shortcut: Cmd+K or Ctrl+K to focus search.',
    a11y: 'Search input: role="searchbox" aria-label="Search settings." Results count: aria-live="polite" region announcing "5 settings found" or "No results." Highlight: <mark> element is accessible by default. Clear button: aria-label="Clear search." Keyboard: Escape clears search and restores full settings view. Ensure filtered-out settings are truly hidden (display: none, not just visually hidden) so screen readers only encounter matching results.',
    docsUrl: null,
  },

  // --- Account ---
  {
    name: 'Profile Editor',
    category: 'account',
    description: 'A form for editing the user\'s profile information — display name, username/handle, email, bio, and avatar. The avatar upload is typically a circular preview with a "Change" button or click-to-upload overlay. Show the current values pre-filled in the form. Validate email format and username uniqueness on blur. A "Save" button at the bottom submits changes. Some fields (like email) may require re-verification after change. Used in every SaaS application with user accounts.',
    implementation: 'Form with labeled inputs for each profile field. Avatar: circular <img> with an overlaid "Change" button that opens a file picker (accept="image/*"). Preview the selected image immediately (URL.createObjectURL). Name/Username: text inputs with max length. Email: input type="email" with blur validation. Bio: <textarea> with character count. Save button: disabled until changes are detected (dirty form tracking). Show a success toast on save. For email changes, show an inline notice: "A verification email will be sent to your new address."',
    a11y: 'Form: <form aria-label="Edit profile">. All inputs: <label> elements with for attributes. Avatar upload: the "Change" button must be keyboard-accessible with aria-label="Change profile picture." File input: visually hidden but accessible (sr-only class, not display:none). Validation errors: aria-describedby on the input pointing to the error message, aria-invalid="true". Save button: aria-disabled when no changes. Success feedback: aria-live="polite" toast.',
    docsUrl: null,
  },
  {
    name: 'Avatar Upload',
    category: 'account',
    description: 'A dedicated interaction for uploading and cropping a profile avatar image. Shows the current avatar as a circular preview. Clicking or dropping an image opens a crop modal with a circular mask. The user adjusts position and zoom, then confirms. Supports drag-and-drop, click-to-browse, and paste from clipboard. Validate file type (JPEG, PNG, WebP) and size (max 5MB). Generate multiple sizes server-side (32px, 64px, 128px, 256px) for different contexts (thumbnails, headers, profiles).',
    implementation: 'Preview: circular container with object-fit: cover. Upload trigger: click on the avatar or a "Change photo" button. File input: accept="image/jpeg,image/png,image/webp" with 5MB max size validation. Crop modal: use react-image-crop or cropperjs with a circular mask overlay. Zoom slider (1x-3x). "Save" and "Cancel" buttons. On save: upload the cropped image (canvas.toBlob) to the server. Show a loading spinner during upload. Optimistic: display the cropped preview immediately while uploading.',
    a11y: 'Upload button: aria-label="Upload new profile picture." Crop modal: role="dialog" aria-label="Crop profile picture." Zoom slider: <input type="range" aria-label="Zoom level" min="1" max="3" step="0.1">. Save/Cancel buttons: standard labels. Loading state: aria-live="polite" announcing "Uploading profile picture." Success: "Profile picture updated." Drag target: aria-label="Drop image here to upload." Ensure crop area is operable via keyboard (arrow keys for position).',
    docsUrl: null,
  },
  {
    name: 'Account Deletion',
    category: 'account',
    description: 'A destructive action flow for permanently deleting a user\'s account and all associated data. Placed in a visually distinct "Danger Zone" section at the bottom of account settings — red border, warning icon, clear explanation of consequences. Requires explicit confirmation: type the account name or "DELETE" to proceed. May require password re-entry. Shows what will be deleted (projects, data, integrations). Offers data export before deletion. Grace period (14-30 days) before permanent deletion. GitHub, Vercel, and Heroku all use this pattern.',
    implementation: 'Danger Zone section: red/destructive border, warning heading "Delete Account." Description lists consequences: "This will permanently delete your account, all projects, and all data. This action cannot be undone." "Delete account" button (destructive variant). Confirmation dialog: "Type [account-name] to confirm" input + password input. Disable the confirm button until the typed name matches exactly. On confirm: soft-delete server-side with a 30-day grace period. Send confirmation email with a cancel link. Show a countdown banner if the user logs back in during the grace period.',
    a11y: 'Danger Zone heading: visually distinct with red color AND a warning icon + text label "Danger Zone." Delete button: aria-label="Delete account permanently." Confirmation dialog: role="alertdialog" aria-label="Confirm account deletion." Typed confirmation input: aria-label="Type [account-name] to confirm deletion." Announce validation inline: "Name matches — you can confirm." Password input: standard accessible label. Success: redirect to a "Account scheduled for deletion" page with clear messaging.',
    docsUrl: null,
  },
  {
    name: 'Connected Accounts',
    category: 'account',
    description: 'Managing OAuth-linked third-party accounts — Google, GitHub, Slack, Figma, etc. Shows a list of available providers with their logo, name, and connection status (connected/not connected). Connected accounts show the linked email/username and a "Disconnect" button. Not-connected accounts show a "Connect" button that initiates the OAuth flow. Warn before disconnecting if the account is the only login method. Used in Vercel, Notion, Linear, and most SaaS tools that support SSO or third-party integrations.',
    implementation: 'List of provider cards. Each card: provider logo (32px) + name + status. Connected: show linked email, "Connected" badge, "Disconnect" button. Not connected: "Connect" button that opens a new window for OAuth. On successful OAuth callback: update the card to show connected state. Disconnect: confirmation dialog if it\'s the only auth method ("You won\'t be able to log in without another method"). Store connections in a user_connections table: {provider, provider_user_id, email, access_token, refresh_token}.',
    a11y: 'Provider list: role="list" aria-label="Connected accounts." Each card: role="listitem." Connection status: text label (not icon-only). Connect button: aria-label="Connect Google account." Disconnect button: aria-label="Disconnect GitHub account." Confirmation dialog: role="alertdialog" warning about login method loss. OAuth popup: announce "Connecting to Google..." via aria-live when the popup opens. On success: "Google account connected" via aria-live="polite".',
    docsUrl: null,
  },
  {
    name: 'Username & Handle',
    category: 'account',
    description: 'A settings field for changing the user\'s unique handle or username — displayed in URLs, @mentions, and public profiles. Validate uniqueness in real-time (debounced API check on input). Show availability status inline: green check for available, red X for taken. Enforce character restrictions (lowercase, alphanumeric, hyphens only). Warn about consequences: changing the username may break existing links, @mentions, and integrations. GitHub shows: "Renaming may take a few minutes to complete." Cooldown period (e.g., once per 30 days) prevents abuse.',
    implementation: 'Text input with real-time validation. On input (debounced 300ms): API call to check uniqueness. Show status: spinner (checking), green check + "Available" (available), red X + "Taken" (unavailable), format error (invalid characters). Character rules: /^[a-z0-9-]+$/, 3-39 characters, no leading/trailing hyphens. Consequences warning: "Your profile URL, @mentions, and API endpoints will change." Require password confirmation to finalize. After change: set up a redirect from the old URL for 30 days.',
    a11y: 'Input: <label for="username">Username</label> with aria-describedby pointing to the validation status and character requirements. Validation status: aria-live="polite" region that announces "username-abc is available" or "username-abc is taken." Format requirements: visible text below the input (not just placeholder). On error: aria-invalid="true" on the input. Character count: "12 of 39 characters" in a live region. Save confirmation: role="alertdialog" explaining consequences.',
    docsUrl: null,
  },

  // --- Preferences ---
  {
    name: 'Theme Selector',
    category: 'preferences',
    description: 'A control for switching between Light, Dark, and System (auto) color themes. The "System" option follows the OS preference via prefers-color-scheme. Typically rendered as a three-option segmented control or radio group with visual previews of each theme. Applying the theme should be instant (no page reload). Store the preference in localStorage for instant application on page load (prevents flash of wrong theme). GitHub, Linear, and Tailwind UI all provide this three-way selector.',
    implementation: 'Three options: Light (sun icon), Dark (moon icon), System (monitor icon). Use a segmented control or radio group. On selection: set a data-theme attribute on <html> ("light" | "dark"), save to localStorage, and sync to user profile API. System mode: listen to window.matchMedia("(prefers-color-scheme: dark)") and update dynamically. Prevent FOUC: inline <script> in <head> reads localStorage and sets data-theme before render. CSS: define color tokens as CSS custom properties scoped to [data-theme="light"] and [data-theme="dark"].',
    a11y: 'Control: role="radiogroup" aria-label="Color theme" with role="radio" options. Each option: aria-label="Light theme" / "Dark theme" / "System theme (follows your operating system)." Announce change: aria-live="polite" with "Theme changed to Dark." Ensure both themes meet WCAG 2.1 AA contrast ratios (4.5:1 for text). Dark mode: avoid pure black (#000) backgrounds — use #121212 or similar to prevent halation for users with astigmatism. Test all interactive states (focus, hover, active) in both themes.',
    docsUrl: null,
  },
  {
    name: 'Notification Preferences',
    category: 'preferences',
    description: 'A matrix or grouped toggle interface letting users control which notifications they receive and through which channels (email, push, in-app, SMS). Typically a table with notification types as rows (Comments, Mentions, Updates, Marketing) and channels as columns (Email, Push, In-App). Each cell is a toggle. Include a "master" toggle per channel to enable/disable all notifications for that channel. Some apps group by urgency: Critical (always on, cannot disable), Important (on by default), Optional (off by default). Slack, GitHub, Linear, and Notion all have detailed notification preferences.',
    implementation: 'Render as a table: rows = notification types, columns = channels. Each cell: <Switch> component. Header row: channel names with optional "all on/off" toggle. Group rows by category (Activity, Marketing, System). Auto-save each toggle change immediately (no "Save" button needed for individual toggles). API: PATCH /preferences/notifications with { type, channel, enabled }. Show a brief toast on save: "Notification preference updated." Include an "Unsubscribe from all marketing" one-click option for compliance (CAN-SPAM, GDPR).',
    a11y: 'Table: <table> with <thead> (channel headers as <th scope="col">) and notification types as <th scope="row">. Each switch: aria-label="Email notifications for Comments" (combining row and column context). Master toggles: aria-label="Enable all Email notifications." Auto-save feedback: aria-live="polite" announcing "Saved." Group headings: <th scope="rowgroup"> with colspan. Ensure the table is navigable with arrow keys (grid pattern) or via standard Tab through cells.',
    docsUrl: null,
  },
  {
    name: 'Language & Locale',
    category: 'preferences',
    description: 'Settings for the user\'s preferred language, date format, time zone, number format, and first day of week. Language selection should show options in their native script (e.g., "Deutsch" not "German") for recognition. Time zone: auto-detect from the browser (Intl.DateTimeFormat().resolvedOptions().timeZone) but allow manual override. Preview the selected format inline: "Dates will appear as: March 6, 2026" or "06/03/2026." Separate UI language from content language if the app has user-generated content.',
    implementation: 'Language: <select> or searchable Combobox with flag icons + native language names. Sort by: current language first, then alphabetically. Time zone: searchable select (300+ zones) with the auto-detected zone pre-selected and labeled "(Detected)." Date format: radio group with live preview. Number format: follows locale automatically. First day of week: radio (Sunday/Monday). Auto-save on change. Require page reload for language changes (or use i18n framework with runtime switching). Store as locale code: "en-US", "de-DE".',
    a11y: 'Language selector: aria-label="Interface language." Each option: text in native script (screen readers will attempt to pronounce it). Time zone selector: aria-label="Time zone" with autocomplete. Format preview: aria-live="polite" updating as selections change. If the language change triggers a page reload, announce before reloading: "Switching language to Deutsch. The page will reload." Ensure the settings page itself is translated — don\'t show an English-only settings page for non-English speakers.',
    docsUrl: null,
  },
  {
    name: 'Keyboard Shortcuts Settings',
    category: 'preferences',
    description: 'A reference and customization panel for keyboard shortcuts — listing all available shortcuts with their current key bindings, search/filter capability, and optional rebinding. Display as a two-column list: action name on the left, key binding (rendered as keyboard key caps) on the right. Support rebinding: click a shortcut, press the new key combination, confirm. Detect and warn about conflicts with existing bindings or browser/OS shortcuts. VS Code, Figma, Linear, and Notion all have keyboard shortcut panels.',
    implementation: 'Table or list: Action (text) + Key binding (rendered as <kbd> elements). Search: filter by action name. Categories: group by context (Global, Editor, Navigation). Rebind: click the key binding → show "Press new shortcut..." → capture keydown → validate no conflicts → save. Store custom bindings in user preferences (or localStorage for local-only). Reset button: "Restore defaults" per shortcut or globally. Show a "Conflicts with [action]" warning if the chosen binding is already used.',
    a11y: 'Shortcut list: <table> or <dl> (description list) with action/binding pairs. Key bindings: <kbd> elements with aria-label spelling out the shortcut: "Control plus K" not "Ctrl+K". Rebind button: aria-label="Change shortcut for [action name]." Capture mode: role="dialog" aria-label="Press new keyboard shortcut." Conflict warning: aria-live="assertive." Reset: confirmation dialog. Ensure the shortcut panel itself is fully keyboard-navigable (ironic but critical).',
    docsUrl: null,
  },
  {
    name: 'Auto-Save Settings',
    category: 'preferences',
    description: 'Settings that save automatically when changed — no explicit "Save" button required. Each control change triggers an immediate API call. Show brief, non-intrusive feedback: a checkmark animation, a "Saved" label that fades in and out, or a small spinner while saving. If the save fails, revert the control to its previous state and show an error toast. Best for simple toggle/select settings. For complex forms (profile editor, billing), use an explicit save button instead. Linear, Notion, and most modern SaaS tools use auto-save for settings.',
    implementation: 'On each control change: (1) optimistically update the UI, (2) call the API (debounced 500ms for text inputs, immediate for toggles/selects), (3) show "Saving..." spinner, (4) on success: show "Saved" checkmark that fades after 2s, (5) on failure: revert the control value, show error toast. Use a per-setting save indicator (not a global one) so users know which setting was saved. For text inputs: auto-save on blur or after 1s of inactivity (not on every keystroke). Track unsaved changes for page navigation warnings (beforeunload).',
    a11y: 'Save indicator: aria-live="polite" region per setting group announcing "Saved" or "Failed to save." Do not announce every individual toggle save — group nearby changes within 2 seconds. Saving spinner: aria-label="Saving..." on the indicator element. Reverted change: aria-live="assertive" announcing "Failed to save — reverted to previous value." For text inputs with debounced save: announce "Saving..." during the debounce delay, "Saved" on completion.',
    docsUrl: null,
  },

  // --- Billing ---
  {
    name: 'Subscription Plan Selector',
    category: 'billing',
    description: 'A plan comparison UI for selecting or changing a subscription tier. Shows 2-4 plan cards side by side with: plan name, price (monthly/annual toggle), feature list with checkmarks, and a CTA button ("Current Plan" / "Upgrade" / "Downgrade"). Highlight the recommended plan with a "Most Popular" badge and visual emphasis. The annual toggle shows savings: "Save 20%." Stripe, Vercel, and most SaaS pricing pages use this pattern. During upgrade: show a prorated price and immediate access. During downgrade: show what features will be lost and when the change takes effect (end of billing period).',
    implementation: 'Card grid: 2-4 cards with equal height (CSS grid or flex). Each card: plan name, price (dynamic based on monthly/annual toggle), feature list, CTA button. Recommended plan: accent border, "Popular" badge, slightly larger or elevated. Monthly/Annual toggle: segmented control above the cards with savings callout. Upgrade flow: confirmation dialog showing prorated charge + "You\'ll be charged $X today." Downgrade flow: show lost features + "Changes take effect on [date]." Current plan: disabled button with "Current Plan" label.',
    a11y: 'Plan cards: role="radiogroup" aria-label="Select a plan" with each card as role="radio". Feature list: <ul> with checkmark (aria-hidden on the icon, include "Included:" or "Not included:" as sr-only text). Price toggle: role="radiogroup" aria-label="Billing period." Recommended badge: text is sufficient (no aria-label needed as it\'s visible). CTA: clear button labels ("Upgrade to Pro" not just "Select"). Confirmation dialog: role="alertdialog" with price and consequences.',
    docsUrl: null,
  },
  {
    name: 'Payment Method Management',
    category: 'billing',
    description: 'Viewing, adding, updating, and removing payment methods — credit/debit cards, bank accounts, or digital wallets. Show a list of saved payment methods with: card brand logo, last 4 digits, expiration date, and a default indicator. "Add payment method" opens a secure form (Stripe Elements, Braintree Drop-In). Mark one method as default. Remove methods with a confirmation dialog (warn if it\'s the only method). PCI compliance: never display or store full card numbers client-side. Stripe, Paddle, and Chargebee all follow this pattern.',
    implementation: 'List of payment method cards. Each card: brand logo (Visa, Mastercard, Amex) + "•••• 4242" + "Expires 12/27" + default badge. Actions: "Set as default" (if not default), "Remove" (with confirmation). "Add payment method" button opens a modal with Stripe Elements (CardElement or PaymentElement) for PCI-compliant card collection. On add: tokenize client-side, send token to server. Never transmit raw card data through your server. Show processing spinner during tokenization and API call.',
    a11y: 'Payment list: role="list" aria-label="Payment methods." Each entry: aria-label="Visa ending in 4242, expires December 2027, default payment method." Default badge: visible text label. Set default: aria-label="Set Visa ending in 4242 as default." Remove: aria-label="Remove Visa ending in 4242" with confirmation dialog (role="alertdialog"). Add form: Stripe Elements handles its own a11y (label, error messaging). Processing state: aria-live="polite" with "Processing payment method."',
    docsUrl: 'https://docs.stripe.com/payments/elements',
  },
  {
    name: 'Billing History',
    category: 'billing',
    description: 'A table or list of past invoices and payments — date, description, amount, status (paid, pending, failed, refunded), and a download/view link for the invoice PDF. Sortable by date (newest first by default). Filter by status or date range. Show the next billing date and amount at the top. For failed payments: show a prominent alert with a "Update payment method" CTA. Stripe Dashboard, Vercel, and Paddle all display billing history in this format.',
    implementation: 'Table with columns: Date, Description, Amount, Status, Invoice. Status badges: green (Paid), yellow (Pending), red (Failed), gray (Refunded). Each row has a "Download PDF" or "View Invoice" link. Pagination: show 10-20 per page. At the top: card showing "Next payment: $29.00 on April 6, 2026." Failed payment alert: red banner with "Payment failed — update your payment method" + CTA button. Link to Stripe Customer Portal for detailed billing management if using Stripe Billing.',
    a11y: 'Table: <table> with <caption>"Billing history"</caption>, <th scope="col"> headers. Status badges: text label (not color-only). Download link: aria-label="Download invoice for March 2026, $29.00." Failed payment alert: role="alert" with clear CTA. Next payment card: regular text content, no special ARIA needed. Pagination: standard accessible pagination with aria-label="Billing history pages." Filter controls: labeled form elements.',
    docsUrl: null,
  },
  {
    name: 'Usage Meter',
    category: 'billing',
    description: 'A visual indicator showing resource consumption against plan limits — API calls, storage, bandwidth, team seats, etc. Displayed as a progress bar with current usage / limit text (e.g., "8,432 / 10,000 API calls"). Color transitions: green (0-70%), yellow (70-90%), red (90-100%). Show a warning when approaching the limit and an alert when exceeded. Include an "Upgrade" CTA when usage exceeds 80%. Vercel, Supabase, and most usage-based SaaS products display these meters in settings or dashboard views.',
    implementation: 'Progress bar container with the filled portion reflecting percentage. Label: "8,432 / 10,000 API calls (84%)." Color: CSS custom properties transitioning through green → yellow → red based on thresholds. Warning state (80%+): yellow bar + "Approaching limit" text + "Upgrade" link. Exceeded (100%+): red bar + "Limit exceeded" alert. Multiple meters: stack vertically in a card grid. Reset date: "Resets on April 1, 2026." Historical trend: optional sparkline chart showing last 30 days.',
    a11y: 'Progress bar: <div role="progressbar" aria-valuenow="8432" aria-valuemin="0" aria-valuemax="10000" aria-label="API calls used: 8,432 of 10,000">. Text label: visible alongside the bar (not inside it). Warning: aria-live="polite" announcing "API call usage at 84% — approaching plan limit." Exceeded: role="alert" with "API call limit exceeded." Color must not be the sole indicator — pair with text labels and icons. Upgrade CTA: clear link text "Upgrade plan to increase API call limit."',
    docsUrl: null,
  },
  {
    name: 'Plan Comparison Table',
    category: 'billing',
    description: 'A detailed feature-by-feature comparison of all subscription plans — rendered as a table with plans as columns and features as rows. Each cell shows a checkmark (included), a dash (not included), or a specific value (e.g., "100GB", "Unlimited"). Group features by category (Core, Advanced, Enterprise). Highlight the user\'s current plan column. Used on pricing pages and in the settings upgrade flow. Stripe, Vercel, and most B2B SaaS products provide this for plan comparison during upgrade decisions.',
    implementation: 'HTML <table> with sticky header row (plan names + prices). Feature rows grouped with <tbody> per category and category headings as full-width rows. Current plan column: accent background or border. Checkmark: SVG icon. Dash: "—" character. Values: plain text. Mobile: convert to stacked cards (one card per plan showing its features) or use horizontal scroll with the plan names sticky. "Upgrade" button in the column header for each plan above the current.',
    a11y: 'Table: <table> with <caption>"Plan comparison"</caption>. Plan headers: <th scope="col">. Feature names: <th scope="row">. Checkmarks: aria-label="Included" (not just an icon). Dashes: aria-label="Not included." Values: plain text is self-describing. Current plan: visually highlighted AND labeled with "(Current plan)" text. Category group headings: <th scope="rowgroup" colspan="...">. Mobile card view: maintain the same information hierarchy. Column highlight: do not rely on background color alone.',
    docsUrl: null,
  },

  // --- Security ---
  {
    name: 'Password Change',
    category: 'security',
    description: 'A form for changing the user\'s password — requiring the current password for verification plus the new password entered twice (new + confirm). Show a password strength meter for the new password. Real-time validation: minimum 8 characters, at least one uppercase, one lowercase, one number (or whatever the policy requires). Toggle password visibility (eye icon). On success: invalidate all other sessions (optional, with checkbox). Send a confirmation email. Never log or store passwords in plaintext.',
    implementation: 'Form with three fields: Current Password, New Password, Confirm New Password. Each with a visibility toggle (eye icon button). Strength meter below New Password: visual bar (red/yellow/green) + text label (Weak/Fair/Strong). Use zxcvbn for realistic strength estimation (not just regex rules). Validation: match check between new + confirm, minimum requirements, not same as current. Submit: verify current password server-side, hash new password (bcrypt/argon2), update. Option: "Log out of all other sessions" checkbox. Success toast + email notification.',
    a11y: 'All inputs: <label> elements with for attributes. Visibility toggle: aria-label="Show password" / "Hide password" with aria-pressed. Strength meter: role="meter" aria-valuenow (0-4) aria-valuemin="0" aria-valuemax="4" aria-label="Password strength: Strong." Validation errors: aria-describedby on inputs, aria-invalid="true." Confirm mismatch: "Passwords do not match" as inline error. Submit: aria-disabled when validation fails. Success: aria-live="polite" toast.',
    docsUrl: null,
  },
  {
    name: 'Two-Factor Authentication Setup',
    category: 'security',
    description: 'An enrollment flow for enabling TOTP-based two-factor authentication. Shows a QR code that the user scans with an authenticator app (Google Authenticator, Authy, 1Password). Also provides the secret key as text for manual entry. After scanning, the user enters a 6-digit verification code to confirm setup. Generate and display backup recovery codes (8-10 codes) that the user must save. Allow managing multiple 2FA methods (TOTP, SMS, security keys). GitHub, Stripe, and AWS all use this pattern.',
    implementation: 'Setup flow: (1) Generate TOTP secret server-side, (2) Render QR code (otpauth:// URI) using qrcode library, (3) Show "Can\'t scan? Enter this code manually: XXXX-XXXX-XXXX-XXXX", (4) Verification input (6-digit OTP), (5) On success: generate 8-10 recovery codes, (6) Display recovery codes with "Copy" and "Download" buttons, (7) Confirm: "I have saved my recovery codes" checkbox before enabling. Store TOTP secret encrypted. Display current 2FA status: enabled methods, last used date.',
    a11y: 'QR code: <img alt="Scan this QR code with your authenticator app"> with the manual secret key as accessible alternative text. Manual key: selectable text with "Copy" button. OTP input: aria-label="Enter 6-digit verification code" with inputmode="numeric" autocomplete="one-time-code." Recovery codes: <pre> or <code> block with aria-label="Recovery codes — save these in a secure location." Copy button: aria-label="Copy recovery codes." Download: aria-label="Download recovery codes as text file." Checkbox: accessible label.',
    docsUrl: null,
  },
  {
    name: 'Active Sessions',
    category: 'security',
    description: 'A list of all devices and sessions where the user is currently logged in. Each entry shows: device type (desktop/mobile/tablet), browser, operating system, IP address (partially masked), location (city, country from IP geolocation), and last active time. The current session is labeled "This device." Each other session has a "Revoke" button to remotely log out. A "Revoke all other sessions" button at the top for emergency use (password compromised). GitHub, Google, and Notion all show active sessions in security settings.',
    implementation: 'List of session cards. Each card: device icon (desktop/mobile/tablet) + browser name + OS + location + "Last active: 2 hours ago." Current session: "This device" badge, no revoke button. Other sessions: "Revoke" button. Revoke all: button at the top with confirmation dialog ("This will log you out of all devices except this one"). Data: from a sessions table with user_agent parsing (ua-parser-js), IP geolocation (MaxMind GeoLite2). Show "Unknown device" for unrecognized user agents. Auto-remove sessions inactive for 30+ days.',
    a11y: 'Session list: role="list" aria-label="Active sessions." Each entry: aria-label="Chrome on macOS, San Francisco, US, last active 2 hours ago." Current device: "(This device)" in the text label. Revoke button: aria-label="Revoke session — Chrome on macOS." Revoke all: confirmation dialog role="alertdialog" with warning text. Location: include country name (not just code). Announce revocation: "Session revoked" via aria-live="polite."',
    docsUrl: null,
  },
  {
    name: 'API Key Management',
    category: 'security',
    description: 'An interface for creating, viewing, and revoking API keys used for programmatic access. Each key shows: name/label, prefix (first 8 characters), creation date, last used date, and permissions/scopes. The full key is shown only once on creation (never stored in full). Creating a key: name input + scope/permission checkboxes + optional expiration date. Revoking: confirmation dialog. Support multiple keys per user for different integrations. Stripe, OpenAI, Supabase, and GitHub all follow this pattern.',
    implementation: 'Key list: table with columns Name, Key (prefix only: "sk_live_Ax8f..."), Created, Last Used, Actions. Create dialog: name input + scope checkboxes (Read, Write, Admin) + expiration select (Never, 30 days, 90 days, 1 year). On create: server generates the key, returns it once. Show in a modal with a "Copy" button and warning: "This key will not be shown again." Revoke: confirmation dialog ("Revoking this key will immediately break any integrations using it"). Store only the key hash server-side. Rate limit key creation.',
    a11y: 'Key table: standard accessible table with <th scope="col"> headers. Key prefix: display as text, not in an input. Create dialog: role="dialog" aria-label="Create API key." Scope checkboxes: role="group" aria-label="Key permissions." Created key display: aria-live="assertive" announcing "API key created — copy it now, it won\'t be shown again." Copy button: aria-label="Copy API key to clipboard" with confirmation "Copied." Revoke: role="alertdialog" with consequences. Last used: relative time with title attribute for exact timestamp.',
    docsUrl: null,
  },
  {
    name: 'Security Log',
    category: 'security',
    description: 'A chronological feed of security-relevant events on the user\'s account — logins, failed login attempts, password changes, 2FA events, session revocations, and API key usage. Each entry shows: event type icon, description, timestamp, IP address, and location. Filter by event type. Alert on suspicious events: login from a new device/location, multiple failed attempts, password changed. Google\'s "Security activity" and GitHub\'s "Security log" are canonical examples.',
    implementation: 'Append-only event list rendered as a vertical timeline or simple table. Event types: login_success, login_failed, password_changed, 2fa_enabled, 2fa_disabled, session_revoked, api_key_created, api_key_revoked. Each entry: icon + description + relative timestamp + IP + location. Filter: checkboxes per event type. Suspicious activity: highlighted with a yellow/orange background + alert icon. Real-time: new events prepended via polling (every 60s) or WebSocket. Pagination: "Load more" or infinite scroll. Retain for 90 days minimum.',
    a11y: 'Event list: role="feed" or role="list" aria-label="Security log." Each entry: role="article" with aria-label summarizing the event: "Successful login from Chrome on macOS, San Francisco, 2 hours ago." Suspicious events: additional text "(Unusual activity)" appended to the label, plus aria-live="assertive" for new suspicious events. Filter controls: standard checkbox accessibility. Timestamp: <time datetime="...">. Load more: aria-label="Load older events."',
    docsUrl: null,
  },

  // --- Data ---
  {
    name: 'Data Export',
    category: 'data',
    description: 'A self-service tool for exporting all of the user\'s data in a machine-readable format — required by GDPR Article 20 (Right to Data Portability) and CCPA. Options: select data categories to export (profile, content, activity, settings), choose format (JSON, CSV, ZIP archive). Large exports are processed asynchronously — the user submits a request and receives an email with a download link when ready. The download link expires after 48 hours. Google Takeout is the canonical reference implementation.',
    implementation: 'UI: checkbox list of data categories (Profile, Posts, Comments, Files, Activity Log, Settings) + format selector (JSON, CSV). "Request Export" button. On submit: create an async job, show "Your export is being prepared. We\'ll email you when it\'s ready." Email: download link valid for 48 hours. Status in settings: "Export requested on [date] — processing / ready / expired." Rate limit: one export per 24 hours. For small accounts (<1MB): generate immediately and offer direct download. Compress to ZIP for multi-file exports.',
    a11y: 'Category checkboxes: role="group" aria-label="Data to export." Each checkbox: standard <input type="checkbox"> with <label>. Format selector: <select> or radio group with label. Submit: "Request data export" button. Status: aria-live="polite" region showing current export status. Email notification: accessible HTML email with prominent download button. Expired link: clear error message "This download link has expired. Request a new export." Progress (if shown): role="progressbar" with aria-valuenow.',
    docsUrl: null,
  },
  {
    name: 'Privacy Controls',
    category: 'data',
    description: 'Granular controls for managing data collection, sharing, and visibility preferences. Includes: analytics opt-in/out, marketing email consent, public profile visibility, search engine indexing, third-party data sharing, cookie preferences. Each control should clearly explain what data is affected and who can see it. GDPR and CCPA require that opt-out must be as easy as opt-in. "Do Not Sell My Personal Information" link required for CCPA compliance. Present defaults as the privacy-preserving option (privacy by default).',
    implementation: 'Grouped toggles organized by category: Data Collection (analytics, crash reports), Communications (marketing emails, product updates), Visibility (public profile, search engine indexing), Sharing (third-party integrations, advertising). Each toggle: label + clear description of what it controls. Default: off for non-essential collection (privacy by default). "Do Not Sell" toggle or link for CCPA. Cookie preferences: link to cookie consent manager. Last updated date shown. Auto-save each toggle with confirmation.',
    a11y: 'Each toggle: role="switch" with aria-checked and associated <label>. Description: aria-describedby on the switch pointing to the explanatory text. Groups: role="group" aria-label="Data Collection preferences." Changes: aria-live="polite" announcing "Analytics tracking disabled." "Do Not Sell" link: prominent, keyboard-accessible, labeled clearly. Ensure toggles are large enough for touch (44x44px minimum). Do not use dark patterns (pre-checked boxes, confusing double negatives like "Don\'t not send me emails").',
    docsUrl: null,
  },
  {
    name: 'Cookie Consent Manager',
    category: 'data',
    description: 'A settings panel for managing cookie preferences beyond the initial consent banner — accessible from privacy settings at any time. Shows cookie categories (Necessary, Functional, Analytics, Marketing) with toggles for each. Necessary cookies are always on and disabled (cannot be toggled off). Each category: name, description, list of specific cookies, their purposes, and expiration times. Changes take effect immediately — unwanted cookies are deleted. Required by GDPR ePrivacy Directive and enforced by EU regulators.',
    implementation: 'Accordion or grouped sections per cookie category. Each section: name, description, toggle (except Necessary — always on), expandable list of individual cookies with name, purpose, and expiry. "Accept All" / "Reject Non-Essential" / "Save Preferences" buttons. On save: update cookie consent state (stored in a first-party cookie), delete cookies from rejected categories (document.cookie = "name=; expires=..."), and update any third-party scripts (disable/enable Google Analytics, marketing pixels, etc.). Link from the footer and privacy settings.',
    a11y: 'Category toggles: role="switch" with aria-checked. Necessary: aria-disabled="true" with aria-describedby explaining "Required for the website to function." Accordion: role="region" with aria-expanded. Cookie list: <table> with Name, Purpose, Expiry columns. Action buttons: clear labels. "Accept All" must not be visually dominant over "Reject" (no dark pattern of making reject small/hidden). Announce preference save: "Cookie preferences saved" via aria-live="polite".',
    docsUrl: null,
  },
  {
    name: 'Account Data Deletion',
    category: 'data',
    description: 'A self-service mechanism for requesting deletion of specific data or the entire account — required by GDPR Article 17 (Right to Erasure). Separate from account deletion: this allows deleting specific data categories (posts, comments, files, activity history) while keeping the account. Shows what will be deleted and what will be retained. Some data may have legal retention requirements (financial records) and cannot be deleted — explain why. Provide a 30-day grace period for full account deletion with an undo option.',
    implementation: 'Two paths: (1) Selective data deletion — checkbox list of data categories + "Delete Selected Data" button + confirmation dialog listing exactly what will be removed. (2) Full account deletion — redirects to the Account Deletion pattern with a Danger Zone. For selective deletion: async processing for large datasets, email confirmation when complete. Retention notices: "Financial records must be retained for 7 years per regulatory requirements" — these categories have disabled checkboxes with explanatory text. Audit log entry for every deletion request.',
    a11y: 'Category checkboxes: standard accessible checkboxes. Disabled categories: aria-disabled="true" with aria-describedby explaining retention requirements. Confirmation dialog: role="alertdialog" with clear description of what will be deleted and what will be retained. Processing status: aria-live="polite" region. Completion notification: "Your data has been deleted" via email and in-app notification. Undo option (during grace period): prominent "Cancel deletion" button with aria-label.',
    docsUrl: null,
  },
  {
    name: 'Import & Migration',
    category: 'data',
    description: 'A tool for importing data from another service or from a backup export — CSV uploads, API-based imports, or direct service-to-service migration. The flow: (1) select source (another service, CSV file, JSON file), (2) upload or authorize, (3) preview/map the data (match imported fields to local fields), (4) confirm and import, (5) show progress and results. Notify on completion with a summary: "Imported 247 items, 3 skipped, 1 failed." Notion, Linear, and Trello all provide import tools for competitive switching.',
    implementation: 'Step wizard: Source Selection → Upload/Connect → Field Mapping → Review → Import. Source: card grid of supported services + "Upload file" option. Upload: drag-and-drop zone for CSV/JSON. Field mapping: two-column table — Source Field → Destination Field with <select> dropdowns per row. Preview: show first 5 rows of mapped data. Import: async with progress bar. Results page: "247 imported, 3 skipped (duplicate), 1 failed (invalid email)" with downloadable error report. Rate limit: one import per hour.',
    a11y: 'Step wizard: <ol> with aria-current="step" on the active step. File upload: accessible drag-and-drop with <input type="file"> fallback. Field mapping: <table> with <th scope="row"> for source fields. Select dropdowns: standard accessible <select>. Preview: accessible data table. Progress: role="progressbar" aria-valuenow aria-valuemin aria-valuemax aria-label="Import progress." Results: clear text summary with "Download error report" link (aria-label). Step navigation: "Back" and "Next" buttons with step context.',
    docsUrl: null,
  },
];
