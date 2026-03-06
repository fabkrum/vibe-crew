# Authentication Pattern Reference

Agent-facing reference for authentication system design, security, and accessibility. The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Authentication must be secure without being hostile. Minimize friction for legitimate users while defending against automated attacks. Never reveal account existence through error messages. Always provide recovery paths.

## 1. Login

### Login Form
- **When:** Every app with user accounts. The default entry point.
- **What:** Single-column form, email + password. Show/hide password toggle. Labels above fields (not placeholders). "Forgot password?" near password field. Redirect to intended destination after login.
- **A11y:** `<form aria-label="Sign in">`. Visible `<label>` with `htmlFor`. Errors via `aria-describedby`. Focus first field on load. Announce errors via `aria-live`.
- **Anti-pattern:** Never use placeholder text as labels. Never redirect to a generic homepage — return to the intended destination.

### Social OAuth Login
- **When:** Consumer apps. 50-80% faster than email/password (Baymard). Limit to 3-4 providers.
- **What:** Provider buttons above email form with visual "or" divider. Official brand icons/colors. OAuth 2.0 / OIDC flow. Always support email/password as fallback.
- **A11y:** `aria-label="Sign in with Google"`. No popup windows (fail with screen readers). Return focus to app on callback.
- **Anti-pattern:** Never force social-only login. Never exceed 4 provider buttons.

### Single Sign-On (SSO)
- **When:** B2B/enterprise apps. SAML 2.0 or OIDC.
- **What:** Detect SSO domain on email field blur. Replace password field with "Continue with SSO" button. Support SP-initiated and IdP-initiated flows.
- **A11y:** Announce SSO detection via `aria-live="polite"`. SSO button keyboard-accessible. Clear error with fallback options if SSO fails.

### Remember Me
- **When:** Apps on personal devices. Default checked on mobile, unchecked on desktop.
- **What:** Session cookie (unchecked) vs persistent cookie with refresh token (checked). HttpOnly, Secure, SameSite=Strict. Rotate tokens. Re-authenticate for sensitive actions regardless.
- **A11y:** Visible label "Remember me" with `htmlFor`. Optional `aria-describedby` tooltip.
- **Anti-pattern:** Never auto-check on shared/public computer contexts.

### Login Error Handling
- **When:** Every login form. Security-critical.
- **What:** Generic "Invalid email or password" message (prevent enumeration). Progressive delay after 3+ failures. CAPTCHA after 5+. Account lockout after 10+.
- **A11y:** `aria-live="assertive"` for login errors. Focus the error Alert. Never rely on color alone.
- **Anti-pattern:** Never reveal whether email or password is incorrect separately.

## 2. Registration

### Signup Form
- **When:** Every app with user accounts. Minimal fields.
- **What:** Email + password minimum (NN/G). No "confirm password" field — use show/hide toggle. Password strength meter (zxcvbn). Real-time constraint checklist. Social signup buttons above form.
- **A11y:** Password strength: `role="meter"` with `aria-valuenow`. Constraint checklist: `aria-live="polite"`. Login link must be a real anchor.
- **Anti-pattern:** Never ask for more than email + password + name at registration.

### Email Verification
- **When:** After registration. Verify email ownership.
- **What:** One-time link (24h expiry). "Check your email" page with resend (throttled 60s). Allow limited app access while unverified. Persistent banner reminder.
- **A11y:** Clear email address display. "Resend" with `aria-label`. Success banner: `role="status"`.

### Progressive Registration
- **When:** Complex apps needing profile data. Collect post-signup.
- **What:** Email + password only at registration. Multi-step onboarding wizard after first login. Allow skipping. Profile completion indicator.
- **A11y:** Step progress: `aria-label="Step 2 of 4"`. `role="progressbar"`. "Skip" as prominent as "Continue".

### Terms & Consent
- **When:** Every app (ToS). GDPR apps (separate consent per purpose).
- **What:** Separate checkboxes per consent item. Links open in new tab. Store consent timestamp + version. Marketing always optional and unchecked.
- **A11y:** `aria-required="true"` on mandatory consent. Focus first unchecked required checkbox on submit error. Never combine multiple purposes in one checkbox (GDPR).

### Account Linking
- **When:** Multiple login methods for same account.
- **What:** Detect duplicate emails across providers. Require existing auth before linking. Show connected providers in settings. Prevent unlinking last auth method.
- **A11y:** Clear explanation of linking prompt. Descriptive button labels. Confirm before unlinking.
- **Anti-pattern:** Never auto-merge accounts without explicit user confirmation.

## 3. Multi-Factor Authentication

### TOTP Authenticator
- **When:** Consumer MFA gold standard. Phishing-resistant.
- **What:** QR code with manual entry fallback. 6-digit code, +-1 period tolerance. Generate backup codes on enrollment. Require re-auth before enabling.
- **A11y:** Text alternative for QR code (manual setup key). Input: `aria-label="Enter 6-digit verification code"`. `inputMode="numeric"`.

### SMS / Email OTP
- **When:** Fallback MFA. Lower security than TOTP (NIST discourages SMS as sole factor).
- **What:** shadcn InputOTP. 6-digit code, 5-10 min expiry. Resend after 30s. Max 3 resends. Invalidate after 3 wrong entries.
- **A11y:** `aria-label` includes masked contact info. Announce resend result. Timer: `aria-live="off"`.

### MFA Enrollment
- **When:** Setting up MFA for the first time.
- **What:** Multi-step: choose method → setup → verify → save backup codes. Allow multiple methods. Enterprise: enforce via org policy.
- **A11y:** Step progress via `aria-label`. Backup codes: "Copy all" and "Download" buttons.

### Backup Recovery Codes
- **When:** Emergency MFA fallback. Generated during enrollment.
- **What:** 8-10 single-use codes, 8-12 chars, stored hashed. Display once only. "Copy all" + "Download" buttons. Regeneration requires re-auth.
- **A11y:** Code grid: `role="list"`. Copy/download buttons with descriptive `aria-label`. Visible warning about one-time display.

## 4. Passwordless

### Magic Link
- **When:** Low-frequency apps. Simpler than passwords.
- **What:** Signed token (15-30 min expiry). Clear CTA button in email. "Check your email" page with resend. Deep-link for mobile.
- **A11y:** Clear email address display. Descriptive email CTA text. Announce result on link validation.

### Passkeys / WebAuthn
- **When:** Modern, phishing-resistant auth. Upgrade path from passwords.
- **What:** `navigator.credentials.create()` / `.get()`. Platform + roaming authenticators. @simplewebauthn/server. Manage registered passkeys in settings.
- **A11y:** Browser native dialogs are accessible. `aria-label="Sign in with passkey"`. Fallback for unsupported browsers.

### Biometric Authentication
- **When:** Fast repeat access. Device-level biometrics via WebAuthn.
- **What:** `authenticatorAttachment: "platform"`. Offer enrollment after first password login. Always provide PIN/password fallback.
- **A11y:** Enrollment prompt explains what data is used. Visible fallback button. Announce result via `aria-live`.

### One-Time Password (Email)
- **When:** Passwordless login via email code (no context switching needed).
- **What:** 6-digit code via email (large font, no links). InputOTP. Auto-submit on complete. 5-10 min expiry. Invalidate after 3 wrong attempts.
- **A11y:** Same as SMS/Email OTP. Partially mask email for privacy. Code in email must be selectable text (not image).

## 5. Session Management

### Session Timeout Warning
- **When:** Financial, healthcare, compliance apps. Before session expiry.
- **What:** AlertDialog 2-5 min before expiry. Countdown + "Stay signed in" (default focus) + "Sign out". Preserve return URL on expiry redirect.
- **A11y:** `role="alertdialog"`. Announce at key thresholds (2 min, 1 min, 30s). Default focus on "Stay signed in". WCAG 2.2.1: extendable time.

### Re-Authentication
- **When:** Sensitive actions — password change, billing, data export, security settings.
- **What:** Check `auth_time` freshness (5-10 min). Compact Dialog with password/passkey prompt. GitHub "sudo mode" pattern.
- **A11y:** Dialog: `aria-label="Confirm your identity"`. Explain why re-auth is needed. Focus returns to triggering action after success.

### Active Sessions / Device Management
- **When:** Apps with multiple device access.
- **What:** List: device, browser, IP/location, last active. "Revoke" per session. "Revoke all others" bulk action. Current session indicator.
- **A11y:** `role="list"` with descriptive `aria-label`. Current session: "This device" in label. Announce revocation via `aria-live`.

### Trusted Devices
- **When:** Reduce MFA friction on personal devices.
- **What:** Checkbox after MFA: "Trust this device for 30 days." Device cookie (HttpOnly, signed). List trusted devices in settings. Auto-expire.
- **A11y:** Checkbox: `aria-label` includes duration and behavior. Warning: "Only trust personal devices."
- **Anti-pattern:** Never auto-trust without explicit user consent.

## 6. Account Recovery

### Password Reset Flow
- **When:** "Forgot password?" — every app with passwords.
- **What:** 3 steps: enter email → receive link (1h expiry) → set new password. Same confirmation regardless of email existence. Invalidate all sessions on change.
- **A11y:** Clear headings per step ("Reset your password"). Same password field a11y as signup. Announce step transitions.
- **Anti-pattern:** Never reveal whether an email exists. Never show the reset link as plain text.

### Account Recovery Options
- **When:** Multiple recovery methods available.
- **What:** List available methods: backup codes > recovery email > phone > support. Each as a card with icon + description. Never use security questions (NIST).
- **A11y:** `aria-label="Account recovery options"`. Visible "Contact support" fallback. Announce method transitions.
- **Anti-pattern:** Never use security questions — they are easily guessable.

### Account Lockout
- **When:** After repeated failed login attempts.
- **What:** Temporary (15-30 min) after 10 failures. "Unlock via email" option. Email alert on lockout. Show remaining time.
- **A11y:** `role="alert"` with clear lockout message and duration. Countdown at key intervals. Email unlock link.

### Password Change
- **When:** Changing password while authenticated.
- **What:** Require current password. Strength meter for new password. No "confirm password" field (use show/hide). Revoke other sessions. Send email notification.
- **A11y:** Form: `aria-label="Change password"`. Same password a11y as signup. Announce success via toast.

## 7. Security

### Rate Limiting Feedback
- **When:** After too many requests. Do not reveal thresholds.
- **What:** Friendly message + countdown based on Retry-After header. Disable submit during wait. Log for monitoring.
- **A11y:** `role="alert"`. Disabled button: `aria-disabled="true"` + `aria-describedby`. Announce re-enablement.
- **Anti-pattern:** Never expose exact rate limit numbers.

### CAPTCHA / Bot Detection
- **When:** After failed attempts or suspicious behavior. Not on every login.
- **What:** Primary: Cloudflare Turnstile (invisible, accessible). Fallback: reCAPTCHA v2 challenge. Validate server-side. One signal among many.
- **A11y:** WCAG requires CAPTCHA alternatives. Turnstile provides managed accessible challenge. Audio alternative for visual CAPTCHAs. "Contact support" fallback.
- **Anti-pattern:** Never use CAPTCHA that blocks screen reader users.

### Security Event Notifications
- **When:** Security-relevant events — new device login, password/MFA changes, unusual location.
- **What:** Mandatory notifications (non-unsubscribable). Email with event details + "This wasn't me" CTA. Audit log table.
- **A11y:** Email: semantic HTML, 4.5:1 contrast. "This wasn't me" large tap target. Activity log: accessible table with sortable columns.

### Credential Stuffing Defense
- **When:** Registration and password change. Login defense layers.
- **What:** HIBP Pwned Passwords API (k-anonymity). Rate limit by IP + fingerprint. Progressive delays + CAPTCHA.
- **A11y:** Breach warning: `role="alert"`. Explain the issue and guidance. Retain entered password for modification. Announce immediately.

### Security Settings Page
- **When:** Every app with user accounts.
- **What:** Grouped sections: Password, MFA, Sessions, Trusted Devices, Security Log, Danger Zone. Red styling for destructive actions. Typed confirmation for account deletion.
- **A11y:** Page heading h1. Section headings h2. Danger zone: `aria-label`. Typed confirmation: `aria-label`. All toggles with descriptive labels in context.
