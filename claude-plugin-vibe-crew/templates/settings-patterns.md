# Settings & Preferences Pattern Reference

Agent-facing reference for settings pages, account management, billing, security, and privacy interfaces. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Settings must auto-save where possible, use clear two-column layouts, provide immediate feedback, and place destructive actions in visually distinct "Danger Zone" sections with multi-step confirmation.

## 1. Settings Layout

### Sidebar Settings Navigation
- **When:** Settings pages with 5+ categories that need deep-linking and scalability.
- **What:** Two-column grid: fixed sidebar (200-240px) + scrollable content. Active category highlighted with accent border. URL-based routing (/settings/profile). Mobile: collapse to category list with back navigation.
- **A11y:** <nav aria-label="Settings"> with aria-current="page" on active link. Focus moves to content heading on category change.
- **Anti-pattern:** Never use a dropdown for settings navigation on desktop — sidebar is more discoverable. Never hide the active category label.

### Tabbed Settings
- **When:** Settings pages with 3-7 categories. Beyond 7, prefer sidebar navigation.
- **What:** Horizontal tabs synced with URL. Manual activation mode (Enter/Space, not arrow auto-activate) for tabs that trigger data loading.
- **A11y:** role="tablist" with role="tab" and role="tabpanel". aria-selected on active tab. Arrow keys navigate, Enter activates.
- **Anti-pattern:** Never auto-activate tabs on arrow key in settings — each tab may trigger API calls. Never use more than 7 horizontal tabs.

### Grouped Settings Sections
- **When:** Organizing settings within a single scrollable page into logical groups.
- **What:** Sections with h3 headings, optional descriptions, dividers. Jump links with IntersectionObserver active highlight. Most-changed settings first.
- **A11y:** Each section: aria-labelledby pointing to heading. Jump links: <nav aria-label="On this page">.
- **Anti-pattern:** Never put all settings in a flat list without grouping. Never bury the most-used settings at the bottom.

### Two-Column Setting Row
- **When:** Individual settings displayed as label+control pairs.
- **What:** Flex row with label/description left, control right. Minimum 48px row height for touch. Hover background for interactive rows.
- **A11y:** <label for="..."> explicitly associated. Description: aria-describedby on control. Toggle: role="switch" aria-checked.
- **Anti-pattern:** Never make the entire row a click target — only the control and label should be interactive.

### Settings Search
- **When:** Complex settings pages with 50+ options.
- **What:** Search input with fuzzy matching against names + descriptions + categories. Highlight matches with <mark>. Debounce 150ms. Cmd+K shortcut.
- **A11y:** role="searchbox" aria-label="Search settings." Results count: aria-live="polite". Hidden settings: display:none (not visually hidden).
- **Anti-pattern:** Never search only setting names — include descriptions. Never show "No results" without a clear button.

## 2. Account Management

### Profile Editor
- **When:** Editing display name, email, bio, avatar.
- **What:** Form with pre-filled values, dirty-state tracking, disabled save until changed. Email changes require re-verification notice.
- **A11y:** <form aria-label="Edit profile">. All inputs labeled. Validation: aria-invalid + aria-describedby. Save: aria-disabled when clean.
- **Anti-pattern:** Never allow saving an unchanged form. Never change email without informing the user about re-verification.

### Avatar Upload
- **When:** Profile picture upload with crop functionality.
- **What:** Circular preview + crop modal with zoom slider. Validate type (JPEG/PNG/WebP) and size (5MB). Optimistic preview during upload.
- **A11y:** Upload button: aria-label="Upload new profile picture." Crop modal: role="dialog". Zoom: <input type="range">. Arrow keys for position.
- **Anti-pattern:** Never accept unlimited file sizes. Never skip the crop step — raw uploads rarely fit circular frames.

### Account Deletion
- **When:** Permanent account removal (Danger Zone).
- **What:** Red-bordered section at bottom. Typed confirmation ("DELETE" or account name). Password re-entry. 30-day grace period. Data export offer.
- **A11y:** Danger Zone visually distinct AND labeled. Confirmation: role="alertdialog". Typed input: aria-label="Type [name] to confirm deletion."
- **Anti-pattern:** Never allow one-click account deletion. Never skip the grace period. Never delete without offering data export first.

### Connected Accounts
- **When:** Managing OAuth-linked services (Google, GitHub, Slack).
- **What:** Provider cards with logo, linked email, connect/disconnect buttons. Warn if disconnecting the only login method.
- **A11y:** List: role="list" aria-label="Connected accounts." Status as text label. OAuth popup: announce "Connecting..." via aria-live.
- **Anti-pattern:** Never allow disconnecting the only authentication method without warning. Never show raw OAuth tokens.

### Username & Handle
- **When:** Changing a unique identifier that appears in URLs and @mentions.
- **What:** Real-time uniqueness validation (debounced 300ms). Character restrictions. Consequences warning. Password confirmation. 30-day redirect.
- **A11y:** Validation status: aria-live="polite". Format requirements: visible text (not placeholder-only). On error: aria-invalid="true".
- **Anti-pattern:** Never allow instant username changes without showing consequences. Never skip the uniqueness check.

## 3. Preferences & Appearance

### Theme Selector
- **When:** Light/Dark/System color theme switching.
- **What:** Three-option segmented control or radio group. Instant application (no reload). localStorage for FOUC prevention. CSS custom properties.
- **A11y:** role="radiogroup" aria-label="Color theme." Announce change: aria-live="polite". Both themes must meet WCAG AA contrast. Avoid pure #000 in dark mode.
- **Anti-pattern:** Never force a reload on theme change. Never omit the "System" option. Never use pure black backgrounds (causes halation).

### Notification Preferences
- **When:** Granular control over notification channels and types.
- **What:** Table: rows=types, columns=channels. Per-cell toggle. Master toggle per channel. Auto-save each toggle. "Unsubscribe from all marketing" for compliance.
- **A11y:** <table> with <th scope="col/row">. Each switch: aria-label combining row + column context. Auto-save: aria-live="polite" feedback.
- **Anti-pattern:** Never require a "Save" button for individual toggle changes. Never hide the unsubscribe option.

### Language & Locale
- **When:** Language, timezone, date format, number format selection.
- **What:** Language shown in native script. Timezone auto-detected with manual override. Live format preview. Page reload for language change (if needed).
- **A11y:** Announce language change before reload. Format preview: aria-live="polite". Translated settings page for non-English speakers.
- **Anti-pattern:** Never show languages in English only ("German" instead of "Deutsch"). Never ignore browser timezone detection.

### Keyboard Shortcuts Settings
- **When:** Viewing and customizing keyboard shortcuts.
- **What:** Two-column list: action + <kbd> key binding. Search, categories, rebinding with conflict detection. "Restore defaults" option.
- **A11y:** <kbd> elements: aria-label spelling out keys ("Control plus K"). Rebind dialog: role="dialog". Conflict: aria-live="assertive".
- **Anti-pattern:** Never allow shortcuts that conflict with browser or screen reader shortcuts. Never make the shortcuts panel keyboard-inaccessible.

### Auto-Save Settings
- **When:** Settings that should save automatically without a "Save" button.
- **What:** Immediate API call on toggle/select change. Debounced for text inputs (500ms). Per-setting "Saved" indicator. Revert on failure with error toast.
- **A11y:** Save indicator: aria-live="polite". Failure: aria-live="assertive" with "Failed to save — reverted." Batch nearby saves in announcements.
- **Anti-pattern:** Never fire API on every keystroke for text inputs. Never show a global "Saved" indicator when saving per-setting.

## 4. Billing & Subscription

### Subscription Plan Selector
- **When:** Choosing or changing subscription tiers.
- **What:** 2-4 plan cards with monthly/annual toggle. "Most Popular" badge on recommended. Prorated pricing on upgrade. Lost features warning on downgrade.
- **A11y:** Cards: role="radiogroup" aria-label="Select a plan." Feature checkmarks: sr-only "Included:" text. Confirmation: role="alertdialog".
- **Anti-pattern:** Never default the annual toggle without showing the monthly price. Never hide what features are lost on downgrade.

### Payment Method Management
- **When:** Adding, viewing, removing credit cards and payment methods.
- **What:** Card list with brand logo + last 4 digits + expiry. Stripe Elements for PCI-compliant collection. Default indicator. Removal confirmation.
- **A11y:** Each entry: aria-label with full description. Remove: role="alertdialog." Processing: aria-live="polite."
- **Anti-pattern:** Never display or transmit full card numbers. Never allow removing the only payment method on an active subscription.

### Billing History
- **When:** Viewing past invoices and payment status.
- **What:** Table with date, description, amount, status badges, PDF download. Failed payment alert with CTA. Next billing date at top.
- **A11y:** <table> with <caption>. Status badges: text label (not color-only). Download: aria-label with invoice date and amount.
- **Anti-pattern:** Never hide failed payments. Never show status with color only (no text).

### Usage Meter
- **When:** Showing resource consumption against plan limits.
- **What:** Progress bar with percentage. Color thresholds: green (0-70%), yellow (70-90%), red (90%+). "Upgrade" CTA at 80%+. Reset date shown.
- **A11y:** role="progressbar" with aria-valuenow/min/max. Warning: aria-live="polite." Exceeded: role="alert." Color paired with text labels.
- **Anti-pattern:** Never show a percentage without the actual numbers. Never hide the upgrade path when limits are approached.

### Plan Comparison Table
- **When:** Feature-by-feature plan comparison during upgrade decisions.
- **What:** Table: plans as columns, features as rows. Checkmarks, dashes, values. Current plan highlighted. Mobile: stacked cards.
- **A11y:** Checkmarks: aria-label="Included." Dashes: aria-label="Not included." Current plan: "(Current plan)" text.
- **Anti-pattern:** Never rely on checkmark/dash icons without accessible labels. Never show more than 5 plans in a table.

## 5. Security & Access

### Password Change
- **When:** Changing password with current password verification.
- **What:** Three fields: current, new, confirm. Strength meter (zxcvbn). Visibility toggles. Optional "log out other sessions." Email notification.
- **A11y:** Visibility toggle: aria-label + aria-pressed. Strength: role="meter" aria-valuenow. Validation: aria-invalid + aria-describedby.
- **Anti-pattern:** Never use regex-only strength estimation — use zxcvbn. Never skip the current password verification step.

### Two-Factor Authentication Setup
- **When:** Enabling TOTP-based 2FA with authenticator app.
- **What:** QR code + manual secret text + 6-digit verification + recovery codes (8-10). "I have saved my codes" checkbox before enabling.
- **A11y:** QR: <img alt="Scan QR code"> with manual key as alternative. OTP input: inputmode="numeric" autocomplete="one-time-code." Recovery codes: aria-label.
- **Anti-pattern:** Never enable 2FA without generating and confirming recovery codes. Never store TOTP secrets unencrypted.

### Active Sessions
- **When:** Viewing and managing logged-in devices.
- **What:** Session cards with device/browser/OS/location/last-active. "This device" badge. "Revoke" per session. "Revoke all" with confirmation.
- **A11y:** Each entry: aria-label with full description. Revoke: aria-label per session. Revoke all: role="alertdialog."
- **Anti-pattern:** Never show raw IP addresses without geolocation context. Never allow revoking the current session without warning.

### API Key Management
- **When:** Creating and managing programmatic access keys.
- **What:** Key list with prefix only. Full key shown once on creation with copy + warning. Scope checkboxes. Expiration options. Revoke with confirmation.
- **A11y:** Created key: aria-live="assertive" warning. Copy: aria-label + confirmation. Revoke: role="alertdialog" with consequences.
- **Anti-pattern:** Never display full API keys after creation. Never allow key creation without scope selection.

### Security Log
- **When:** Viewing security-relevant account events.
- **What:** Chronological event feed: logins, failed attempts, password changes, 2FA events. Suspicious activity highlighted. Filter by event type. 90-day retention.
- **A11y:** Feed: role="feed" or role="list." Suspicious events: "(Unusual activity)" label + aria-live="assertive." Timestamp: <time datetime>.
- **Anti-pattern:** Never show security events without timestamps and location context. Never auto-dismiss suspicious activity alerts.

## 6. Data & Privacy

### Data Export
- **When:** GDPR Article 20 data portability and self-service export.
- **What:** Checkbox list of data categories + format selector (JSON/CSV). Async processing for large exports. Email with download link (48h expiry). Rate limit: 1/24h.
- **A11y:** Checkboxes: role="group" aria-label="Data to export." Status: aria-live="polite." Expired link: clear error message.
- **Anti-pattern:** Never process large exports synchronously. Never create non-expiring download links.

### Privacy Controls
- **When:** Granular data collection, sharing, and visibility preferences.
- **What:** Grouped toggles: collection, communications, visibility, sharing. Privacy-preserving defaults (off for non-essential). "Do Not Sell" for CCPA.
- **A11y:** Switches: role="switch" + aria-describedby for explanatory text. Changes: aria-live="polite." 44x44px minimum touch targets.
- **Anti-pattern:** Never default non-essential data collection to "on." Never use dark patterns (pre-checked, double negatives).

### Cookie Consent Manager
- **When:** Managing cookie preferences beyond initial consent banner.
- **What:** Categories: Necessary (always on), Functional, Analytics, Marketing. Toggle per category. "Accept All" / "Reject Non-Essential" / "Save." Delete rejected cookies immediately.
- **A11y:** Necessary: aria-disabled="true" with explanation. "Accept All" and "Reject" visually equal (no dark pattern). Announce save: aria-live="polite."
- **Anti-pattern:** Never make "Reject" harder to find than "Accept All." Never keep cookies from rejected categories.

### Account Data Deletion
- **When:** GDPR Article 17 right to erasure — selective or full.
- **What:** Two paths: selective (checkbox list) or full (Danger Zone). Retention notices for legally required data. Async processing. Email confirmation on completion.
- **A11y:** Disabled categories: aria-disabled with retention explanation. Confirmation: role="alertdialog." Completion: aria-live and email.
- **Anti-pattern:** Never delete data that has legal retention requirements. Never skip the confirmation dialog for destructive deletion.

### Import & Migration
- **When:** Importing data from another service or file.
- **What:** Step wizard: Source → Upload → Field Mapping → Review → Import. Drag-and-drop upload. Preview first 5 rows. Async progress. Results summary with error report.
- **A11y:** Steps: <ol> with aria-current="step." File upload: accessible fallback. Progress: role="progressbar." Results: clear text summary.
- **Anti-pattern:** Never skip the field mapping step — automatic mapping should be reviewable. Never lose partial import progress on error.
