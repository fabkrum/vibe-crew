export interface AuthPattern {
  name: string;
  category: 'login' | 'registration' | 'mfa' | 'passwordless' | 'session' | 'recovery' | 'security';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<AuthPattern['category'], string> = {
  login: 'Login',
  registration: 'Registration',
  mfa: 'Multi-Factor Authentication',
  passwordless: 'Passwordless',
  session: 'Session Management',
  recovery: 'Account Recovery',
  security: 'Security',
};

export const categoryOrder: AuthPattern['category'][] = [
  'login', 'registration', 'mfa', 'passwordless', 'session', 'recovery', 'security',
];

export const authPatterns: AuthPattern[] = [
  // --- Login ---
  {
    name: 'Login Form',
    category: 'login',
    description: 'The standard email/password login form. Single-column layout, labels above fields, email field with type="email" for mobile keyboard optimization. Show password constraints on the login page only when an error occurs — not proactively (unlike registration). Include "Forgot password?" link positioned near the password field, not buried in footer. NN/G: entering a password on mobile takes nearly twice as long as desktop, so minimize friction.',
    implementation: 'shadcn: Card + Form (react-hook-form + zod). Input type="email" + Input type="password". Show/hide password toggle via Eye/EyeOff icon button. Submit with Button type="submit". Display server errors via Alert above the form. Use FormMessage for field-level validation. Redirect to intended destination after login (store in URL param or session).',
    a11y: 'Form must use <form> element with aria-label="Sign in". Each input needs a visible <label> with htmlFor. Error messages linked via aria-describedby. Do not use placeholder text as labels. Focus the first field on page load. Announce errors via aria-live="polite" region.',
    docsUrl: null,
  },
  {
    name: 'Social OAuth Login',
    category: 'login',
    description: 'Sign in with third-party identity providers — Google, GitHub, Apple, Microsoft. Reduces registration friction: 50-80% faster than email/password (Baymard). Place social buttons above or alongside the email form with a visual divider ("or"). Use branded button styles per provider guidelines. Limit to 3-4 providers to avoid choice overload. Always support email/password as fallback.',
    implementation: 'OAuth 2.0 / OpenID Connect flow. Use NextAuth.js, Auth.js, Clerk, or Supabase Auth providers. Display provider buttons with official brand icons and colors (Google branding guidelines are strict). Backend: exchange authorization code for tokens, create or link user account. Store provider_id + provider_type for account linking.',
    a11y: 'Each social button: aria-label="Sign in with Google" (not just the icon). Buttons must be keyboard-accessible. Redirect to provider opens in same window (not popup — popups fail with screen readers and popup blockers). Return focus to the app on callback.',
    docsUrl: null,
  },
  {
    name: 'Single Sign-On (SSO)',
    category: 'login',
    description: 'Enterprise authentication via SAML 2.0 or OpenID Connect. The user enters their work email, the app detects the SSO-enabled domain, and redirects to their organization\'s identity provider (Okta, Entra ID, OneLogin). SP-initiated flow: user starts at the app. IdP-initiated flow: user starts at the IdP dashboard. Dynamically hide the password field when an SSO domain is detected for a cleaner UX.',
    implementation: 'Detect SSO domain on email field blur or keypress. If the domain matches an SSO-enabled org, replace password field with "Continue with SSO" button. Use WorkOS, Auth0, or Clerk for SAML/OIDC integration. Store SSO configuration per organization (entity_id, acs_url, certificate). Support both SP-initiated and IdP-initiated flows.',
    a11y: 'Announce SSO detection: "Single sign-on enabled for your organization" via aria-live="polite". The SSO redirect button must be keyboard-accessible and clearly labeled. On return from IdP, focus the main content area. If SSO fails, provide a clear error message with fallback options.',
    docsUrl: null,
  },
  {
    name: 'Remember Me',
    category: 'login',
    description: 'A checkbox on the login form that extends the session beyond the browser session. When unchecked, authentication lives in a session cookie (deleted on browser close). When checked, a persistent cookie with a long-lived token keeps the user signed in for days or weeks. Protects users on shared/public computers who forget to log out. NN/G: check it by default on mobile (personal devices), uncheck by default on desktop.',
    implementation: 'Session cookie (unchecked) vs persistent cookie with refresh token (checked). Set cookie with HttpOnly, Secure, SameSite=Strict. Rotate refresh tokens on each use. Store token series identifier to detect theft (if a valid series + invalid token appears, revoke all sessions for that user). Re-authenticate for sensitive actions regardless of remember-me status.',
    a11y: 'Checkbox must have a visible label "Remember me" associated via htmlFor. Include aria-describedby with tooltip explaining the behavior: "Keep me signed in on this device." On shared devices, add a visible warning about the security implications of staying signed in.',
    docsUrl: null,
  },
  {
    name: 'Login Error Handling',
    category: 'login',
    description: 'Security-conscious error messages for failed login attempts. Never reveal whether the email or password is incorrect — use a generic "Invalid email or password" message to prevent account enumeration. After 3-5 failed attempts, show CAPTCHA or introduce progressive delays. After 10+ attempts, temporarily lock the account or require email verification. Log failed attempts for security monitoring.',
    implementation: 'Backend: return identical error codes for "user not found" and "wrong password". Frontend: display Alert with generic error above the form. Implement progressive delay: 1s after 3rd attempt, 5s after 5th, 30s after 8th. Show remaining attempts counter after 3 failures. Rate limit by IP + email combination. Store failed_attempts and locked_until in the user record.',
    a11y: 'Announce error message via aria-live="assertive" since login errors require immediate attention. Focus the error Alert so screen readers read it. Include the generic error text — never rely on color alone. If the account is locked, provide a clear message with the lockout duration and link to account recovery.',
    docsUrl: null,
  },

  // --- Registration ---
  {
    name: 'Signup Form',
    category: 'registration',
    description: 'The registration form. NN/G research: ask for the minimum — email and password should be enough. Do not include a "confirm password" field; instead, provide a show/hide toggle to verify. Single-column layout. Disclose password constraints upfront (not after submission). Social signup buttons above the form reduce friction by 50-80%. Link to login page: "Already have an account? Sign in."',
    implementation: 'shadcn: Card + Form (react-hook-form + zod). Minimal fields: email + password (+ name if needed). Password strength meter below the field (zxcvbn library). Show constraints as a checklist that updates in real-time (green check for met, gray for unmet). Submit creates account + sends verification email. Redirect to onboarding or email verification pending page.',
    a11y: 'Same form accessibility as Login Form. Password constraint checklist uses aria-live="polite" to announce changes. Strength meter: role="meter" with aria-valuenow, aria-valuemin, aria-valuemax, and aria-label="Password strength: strong". Link between login/signup forms must be a real anchor, not just a button.',
    docsUrl: null,
  },
  {
    name: 'Email Verification',
    category: 'registration',
    description: 'Verify email ownership after registration. Send a verification email with a one-time link (expires in 24h). Show a "Check your email" page with the email address and a "Resend" button (throttled to once per 60s). Allow the user to access limited app functionality while unverified (don\'t block entirely). Remind them with a persistent banner until verified.',
    implementation: 'Generate a signed token (JWT or random + DB lookup). Send via transactional email (Resend, SendGrid). Verification endpoint validates token, marks email_verified=true. Show a Banner/Alert on all pages: "Please verify your email. Resend verification." Rate-limit resend to 1/minute. Token expires after 24h; expired tokens show a "Request new link" page.',
    a11y: 'Verification pending page must clearly state which email was sent to and what action is needed. "Resend" button has aria-label="Resend verification email". Success banner after verification: role="status" with aria-live="polite". Focus the banner on state change. Verification link in email must have descriptive text, not "Click here."',
    docsUrl: null,
  },
  {
    name: 'Progressive Registration',
    category: 'registration',
    description: 'Delay non-essential data collection until after account creation. Start with only email + password, then collect profile details (name, avatar, preferences) during onboarding steps or naturally during product usage. Baymard Institute: 18% of users abandon forms that ask too much upfront. Each additional field reduces completion rate by ~5%. Collect data when the user has context for why it is needed.',
    implementation: 'Registration: email + password only. After first login, show a multi-step onboarding wizard (shadcn: Dialog or full-page). Each step collects one category of data. Track completion state in user.onboarding_step. Allow skipping any step. Show a profile completion indicator (Progress bar) to encourage filling in optional data over time.',
    a11y: 'Multi-step onboarding uses aria-label="Step 2 of 4: Profile Details". Progress indicator: role="progressbar" with aria-valuenow. "Skip" button must be as prominent as "Continue". Each step\'s form fields properly labeled. Announce step transitions via aria-live="polite".',
    docsUrl: null,
  },
  {
    name: 'Terms & Consent',
    category: 'registration',
    description: 'Legal acceptance during registration — terms of service, privacy policy, marketing consent. GDPR requires separate, specific consent for each purpose (no pre-checked boxes for marketing). Link to full terms document (opens in new tab to preserve form state). Keep consent text concise: "I agree to the Terms of Service and Privacy Policy." Marketing consent is always optional and unchecked by default.',
    implementation: 'shadcn: Checkbox for each consent item. Terms/Privacy links open in new tab (target="_blank" rel="noopener"). Store consent timestamp and version per user (consent_accepted_at, terms_version). Required consent (ToS) blocks submission; optional consent (marketing) does not. GDPR: provide a mechanism to withdraw consent later in account settings.',
    a11y: 'Each Checkbox has a visible label with linked text. aria-required="true" on mandatory consent. Link text must be descriptive: "Terms of Service" not "here." If consent is missing on submit, focus the first unchecked required checkbox and announce the error via aria-live. Do not use a single checkbox for multiple consent purposes (GDPR violation).',
    docsUrl: null,
  },
  {
    name: 'Account Linking',
    category: 'registration',
    description: 'Connect multiple login methods to one account — e.g., a user signs up with email, then later wants to also sign in with Google. Detect duplicate emails across providers and prompt to link: "An account with this email already exists. Sign in with your password to link your Google account." Never auto-merge without explicit user confirmation. Show connected providers in account settings with ability to unlink.',
    implementation: 'Database: user has many auth_providers (provider, provider_id, email). On OAuth callback, check if email already exists. If so, redirect to a linking flow that requires authentication with the existing method first. Account settings: list connected providers with "Connect" / "Disconnect" buttons. Prevent unlinking the last remaining auth method.',
    a11y: 'Linking prompt must clearly explain what is happening: "An account exists with this email." The linking flow buttons must have descriptive labels: "Sign in with password to link Google." Connected providers list uses aria-label on each provider item. Confirm before unlinking with a Dialog.',
    docsUrl: null,
  },

  // --- MFA ---
  {
    name: 'TOTP Authenticator',
    category: 'mfa',
    description: 'Time-based One-Time Password using authenticator apps (Google Authenticator, Authy, 1Password). The gold standard for consumer MFA — phishing-resistant when combined with app verification. Setup: display a QR code encoding the shared secret, with a manual entry fallback (the secret key as text). Verify by asking the user to enter a 6-digit code from their app. Always generate backup codes during enrollment.',
    implementation: 'Backend: generate shared secret (otpauth:// URI), store encrypted. Display QR code via qrcode library. Verification: validate 6-digit code with a time window of +-1 period (30s). Use speakeasy, otplib, or @simplewebauthn/server. After successful setup, show backup recovery codes (one-time display). Require re-authentication before enabling MFA.',
    a11y: 'QR code must have a text alternative: "Manual setup key: XXXX-XXXX-XXXX-XXXX" displayed below. Code input: 6 separate digit inputs with auto-advance or a single Input with inputMode="numeric" and maxLength="6". aria-label="Enter 6-digit verification code". Announce verification result via aria-live.',
    docsUrl: null,
  },
  {
    name: 'SMS / Email OTP',
    category: 'mfa',
    description: 'One-time passcode sent via SMS or email. Lower security than TOTP (vulnerable to SIM-swapping and SS7 attacks) but higher adoption due to familiarity. NIST SP 800-63B discourages SMS as a sole second factor. Use as a fallback option alongside stronger methods. Include a countdown timer for code expiry (typically 5-10 minutes). Rate-limit resend requests.',
    implementation: 'Backend: generate 6-digit code, store hashed with expiry timestamp. Send via Twilio (SMS) or transactional email. Frontend: shadcn InputOTP component with auto-advance digits. Show countdown timer. "Resend code" button appears after 30s delay. Code expires after 5-10 minutes. Rate limit: max 3 resends per verification attempt. Invalidate code after 3 wrong entries.',
    a11y: 'Input OTP: aria-label="Enter verification code sent to +1***456". Auto-advance between inputs must not confuse screen readers — announce current field position. "Resend code" button: aria-label="Resend verification code to your phone". Announce resend success/failure via aria-live="polite". Countdown timer: aria-live="off" (do not announce every second).',
    docsUrl: 'https://ui.shadcn.com/docs/components/radix/input-otp',
  },
  {
    name: 'MFA Enrollment',
    category: 'mfa',
    description: 'The setup flow for enabling multi-factor authentication. Present available methods (TOTP, SMS, passkeys, security keys) with brief explanations. Walk through setup step-by-step. Always generate and display backup recovery codes on completion. Do not force MFA on all users immediately — offer it during onboarding and nudge with periodic prompts. For enterprise: enforce via organization policy.',
    implementation: 'Multi-step flow: 1) Choose method, 2) Setup (QR code / phone number / register key), 3) Verify (enter code), 4) Save backup codes. Store MFA method and enrollment timestamp per user. Allow multiple methods. Show enrollment status in account security settings. For enterprise enforcement: check org policy on login, redirect to enrollment if required.',
    a11y: 'Step progress: "Step 2 of 4: Scan QR code" via aria-label. Each method option has a descriptive label and brief explanation. Backup codes page: provide a "Copy all" button and "Download as text file" option. Announce successful enrollment via aria-live="polite": "Two-factor authentication enabled."',
    docsUrl: null,
  },
  {
    name: 'Backup Recovery Codes',
    category: 'mfa',
    description: 'A set of 8-10 single-use codes generated during MFA enrollment. Emergency fallback when the user loses access to their authenticator app, phone, or security key. Display codes only once during setup — never retrievable again (but can regenerate a new set). Each code is 8-12 characters, alphanumeric, cryptographically random. Products typically recommend printing codes rather than storing digitally.',
    implementation: 'Generate 10 codes using crypto.randomBytes(). Store hashed (bcrypt) in recovery_codes table. Display in a grid with "Copy all" and "Download" buttons. Mark used codes as consumed. When a code is used, show remaining count and prompt to generate new codes. Regenerating codes requires re-authentication and invalidates all previous codes.',
    a11y: 'Code grid: use role="list" with each code as a list item. "Copy all codes" button has aria-label="Copy all backup codes to clipboard". Announce copy success. Download button: aria-label="Download backup codes as text file". Add a visible warning: "Save these codes in a safe place. You will not be able to see them again."',
    docsUrl: null,
  },

  // --- Passwordless ---
  {
    name: 'Magic Link',
    category: 'passwordless',
    description: 'A login method that sends a one-time, time-limited link to the user\'s email. Clicking the link authenticates the user without a password. NN/G: passwordless accounts shift the security burden from the user to the email provider. Simpler than passwords but adds friction (switching to email app). Link expires in 15-30 minutes. Use for low-frequency apps where users forget passwords.',
    implementation: 'Generate a signed token (JWT with short expiry or random token + DB lookup). Send via transactional email with a clear CTA button: "Sign in to [AppName]." Verification endpoint validates token, creates session, redirects to app. Invalidate token after use. Show "Check your email" page with resend option (throttled). Deep-link: if opened on mobile, open the app directly.',
    a11y: '"Check your email" page must state the email address clearly and what action to take. "Resend link" button: aria-label="Resend sign-in link". Email CTA button: descriptive text "Sign in to AppName" not "Click here." Announce success/error on link validation page via aria-live. Focus main content after successful authentication.',
    docsUrl: null,
  },
  {
    name: 'Passkeys / WebAuthn',
    category: 'passwordless',
    description: 'FIDO2/WebAuthn credentials stored on the user\'s device — biometric (fingerprint, Face ID) or device PIN. Phishing-resistant by design: credentials are bound to the domain origin. NN/G: passkeys are the most secure and convenient auth method but adoption is still growing. Support passkeys as an upgrade path alongside passwords. Synced passkeys (iCloud Keychain, Google Password Manager) work across devices.',
    implementation: 'Registration: navigator.credentials.create() with PublicKeyCredentialCreationOptions. Store credential public key, credential ID, and counter server-side. Login: navigator.credentials.get() with challenge. Verify assertion server-side using @simplewebauthn/server. Support platform authenticators (biometric) and roaming (USB security keys). Display registered passkeys in security settings.',
    a11y: 'Browser native WebAuthn dialogs are accessible by default. The "Sign in with passkey" button must have aria-label="Sign in with passkey or security key". Provide a fallback for users without passkey support. Announce authentication result via aria-live. Passkey management list in settings: each entry shows device name, creation date, last used, with "Remove" action.',
    docsUrl: null,
  },
  {
    name: 'Biometric Authentication',
    category: 'passwordless',
    description: 'Authentication using fingerprint, face recognition, or iris scan — typically via the device\'s built-in biometric sensor. On web, this is implemented through WebAuthn with platform authenticators (Touch ID, Windows Hello, Android biometric prompt). Fast and convenient for repeat access. Always provide a PIN/password fallback — biometrics can fail (wet fingers, poor lighting, injuries).',
    implementation: 'WebAuthn with authenticatorAttachment: "platform" to prefer built-in biometric sensors. The browser handles the biometric prompt natively. For mobile apps: expo-local-authentication or react-native-biometrics. Store the biometric credential as a passkey. Offer biometric enrollment after first successful password login: "Enable Face ID for faster sign-in?"',
    a11y: 'Biometric prompts are OS-level and inherit system accessibility. The enrollment prompt must clearly explain what biometric data is used and that it stays on-device. "Enable biometric sign-in" button with aria-describedby explaining the feature. Always show a visible PIN/password fallback button during biometric prompt. Announce result via aria-live.',
    docsUrl: null,
  },
  {
    name: 'One-Time Password (Email)',
    category: 'passwordless',
    description: 'A passwordless login flow where a short numeric code (6 digits) is sent to the user\'s email instead of a magic link. The user enters the code in the app without switching context. Faster than magic links on desktop (no email app switching needed if the code is visible in a notification preview). Code expires in 5-10 minutes. Common in banking and fintech.',
    implementation: 'Backend: generate 6-digit code, store hashed with expiry. Send via transactional email with the code prominently displayed (large font, no surrounding links to click). Frontend: shadcn InputOTP component. Auto-submit on complete entry. Show email address the code was sent to. "Resend code" after 30s. Invalidate after 3 wrong attempts.',
    a11y: 'Same accessibility requirements as SMS/Email OTP pattern. aria-label="Enter 6-digit code sent to j***@email.com". Partially mask the email address for privacy but keep enough to identify which email. Announce auto-submission result. Ensure the code in the email is selectable and copyable (not an image).',
    docsUrl: 'https://ui.shadcn.com/docs/components/radix/input-otp',
  },

  // --- Session Management ---
  {
    name: 'Session Timeout Warning',
    category: 'session',
    description: 'A modal dialog that warns users before their session expires due to inactivity. Show 2-5 minutes before expiry with a countdown and options to extend or sign out. Required for financial and healthcare apps (HIPAA, PCI-DSS). Do not silently expire — users lose unsaved work. The dialog should pause the countdown while the user is interacting with it.',
    implementation: 'Track last activity timestamp (mousemove, keypress, click). Set a warning timer (e.g., 25 minutes of inactivity) and an expiry timer (30 minutes). Show shadcn AlertDialog with countdown. "Stay signed in" button resets both timers and pings a session-extend endpoint. "Sign out" button clears session. On expiry: redirect to login with a "Session expired" message, preserving the return URL.',
    a11y: 'AlertDialog must trap focus and be announced by screen readers immediately: role="alertdialog" with aria-label="Session expiring". Countdown must not be announced every second — announce at key thresholds (2 min, 1 min, 30s). "Stay signed in" button should be focused by default. WCAG 2.2.1: provide a way to extend the time limit.',
    docsUrl: null,
  },
  {
    name: 'Re-Authentication',
    category: 'session',
    description: 'Require the user to verify their identity again before performing sensitive actions — changing password, accessing billing, downloading data exports, modifying security settings. Even if the user is logged in (including via "Remember Me"), sensitive operations need fresh authentication. Show a compact password/biometric prompt inline or in a modal, not a full login page redirect.',
    implementation: 'Backend: track auth_time in the session token. For sensitive endpoints, check if auth_time is within the last 5-10 minutes. If stale, return 401 with a "re-auth required" flag. Frontend: show a compact Dialog with password input or passkey prompt. On success, update auth_time and proceed. GitHub-style "sudo mode" pattern.',
    a11y: 'Re-auth Dialog: aria-label="Confirm your identity". Explain why re-authentication is needed: "Enter your password to change security settings." Password input properly labeled. Announce success/failure via aria-live. Focus returns to the triggering action after successful re-auth.',
    docsUrl: null,
  },
  {
    name: 'Active Sessions / Device Management',
    category: 'session',
    description: 'A settings page showing all active sessions — device name, browser, IP address (approximate location), and last active timestamp. Users can revoke individual sessions ("Sign out this device") or all other sessions ("Sign out everywhere else"). Shows current session with a "This device" indicator. Critical for detecting unauthorized access.',
    implementation: 'Store session records: device_name (user-agent parsed), ip_address, created_at, last_active_at, is_current. Settings page: list sessions in a Card grid. Each card shows browser icon, device name, location, relative last-active time. "Revoke" button per session (with confirmation Dialog). "Revoke all other sessions" bulk action. Update last_active_at on each request.',
    a11y: 'Session list: role="list" with descriptive aria-label="Active sessions". Each item: aria-label combining device and location ("Chrome on MacOS, San Francisco, active 2 hours ago"). Current session: visually marked and announced as "This device" in aria-label. Revoke confirmation dialog must be accessible. Announce revocation result via aria-live.',
    docsUrl: null,
  },
  {
    name: 'Trusted Devices',
    category: 'session',
    description: 'Allow users to mark a device as "trusted" to skip MFA on future logins from that device. Remember the device for 30-90 days via a secure device cookie. Show a checkbox after successful MFA: "Trust this device for 30 days." Display trusted devices in security settings with the ability to revoke trust. Only offer on personal devices — never on shared/public computers.',
    implementation: 'After successful MFA, offer "Trust this device" checkbox. Store a signed device token (device_id, user_id, trusted_until) in a persistent HttpOnly cookie. On login, check for valid device token before prompting MFA. Settings: list trusted devices with name, trusted date, expiry. "Remove trust" per device. Auto-expire after configured period.',
    a11y: 'Trust checkbox: aria-label="Remember this device for 30 days and skip verification next time." Include aria-describedby with warning: "Only trust personal devices." Trusted devices list in settings: each item has descriptive label. "Remove trust" button: aria-label="Remove trust from Chrome on MacOS." Announce trust changes via aria-live.',
    docsUrl: null,
  },

  // --- Account Recovery ---
  {
    name: 'Password Reset Flow',
    category: 'recovery',
    description: 'The "Forgot password?" flow. Step 1: enter email. Step 2: receive email with reset link (expires in 1h). Step 3: enter new password. Always show the same confirmation message regardless of whether the email exists (prevent enumeration). Invalidate reset token after use. Invalidate all existing sessions on password change. NN/G: include "Forgot password?" link near the password field, not in the footer.',
    implementation: 'Step 1: email input form. Backend: generate signed token, send email. Always respond with "If an account exists, we sent a link." Step 2: email with reset CTA button (no URL as plain text for security). Step 3: new password form with strength meter and constraint checklist. On submit: hash new password, invalidate token, revoke all sessions, redirect to login with success message.',
    a11y: 'Each step has a clear heading: "Reset your password" (not "Forgot password?" — that\'s a question, not an instruction). Email input: aria-label="Email address for password reset". New password form: same accessibility as signup. Announce step transitions via aria-live. Success message: role="status" with focus.',
    docsUrl: null,
  },
  {
    name: 'Account Recovery Options',
    category: 'recovery',
    description: 'Multiple recovery methods beyond password reset — backup codes, recovery email, trusted device, phone number, identity verification. Display available options on the recovery page: "Try another way." Prioritize by security: backup codes > recovery email > phone > support contact. Never use security questions as a recovery method — they are easily guessable and a known anti-pattern (NIST SP 800-63B).',
    implementation: 'Recovery page: list available methods based on what the user has configured. Each method as a card with icon, title, and brief description. "Use a backup code" → InputOTP for code entry. "Send to recovery email" → email flow. "Contact support" → support ticket with identity verification. Store recovery method enrollment status per user.',
    a11y: 'Recovery options page: aria-label="Account recovery options". Each option card has a descriptive aria-label. If the user cannot access any recovery method, provide a visible "Contact support" option as last resort. Announce selected method transition via aria-live. Do not time-limit the recovery options page.',
    docsUrl: null,
  },
  {
    name: 'Account Lockout',
    category: 'recovery',
    description: 'Temporary or permanent account lockout after repeated failed login attempts. Temporary lockout: 15-30 minutes after 10 failed attempts (prevents brute force while allowing legitimate users to retry). Permanent lockout: require email/identity verification to unlock. Always show the lockout duration and provide a path to recovery. Never reveal the exact threshold to attackers.',
    implementation: 'Backend: track failed_attempts and locked_until per user. After threshold (e.g., 10 attempts): set locked_until = now + 30min. Return generic "Account temporarily locked" error with remaining time. Provide "Unlock via email" option that sends a verification link. On successful unlock, reset failed_attempts. Alert the user via email about the lockout event.',
    a11y: 'Lockout message: role="alert" with clear text: "Your account is temporarily locked. Try again in 28 minutes, or unlock via email." Include link to email unlock. Countdown uses aria-live="polite" to announce at key intervals (not every second). Ensure the lockout page is navigable with keyboard.',
    docsUrl: null,
  },
  {
    name: 'Password Change',
    category: 'recovery',
    description: 'Changing the password from within the app (while logged in). Require current password before accepting a new one (prevents attackers with session access from locking out the real user). Show password strength meter for the new password. Do not require the user to enter the new password twice — provide a show/hide toggle instead (NN/G). Invalidate all other sessions after password change.',
    implementation: 'Form: current password + new password + strength meter. Validate current password server-side before accepting change. On success: update password hash, revoke all other sessions, send email notification "Your password was changed." If the user cannot remember current password, redirect to "Forgot password?" flow. Show success toast after change.',
    a11y: 'Form: aria-label="Change password". Current password input: aria-label="Current password". New password: same accessibility as signup password field (strength meter, constraint checklist). Announce password change success via toast with aria-live="polite". Email notification is the secondary confirmation channel.',
    docsUrl: null,
  },

  // --- Security ---
  {
    name: 'Rate Limiting Feedback',
    category: 'security',
    description: 'Inform users when rate limiting is active without revealing implementation details. Show a friendly message: "Too many attempts. Please wait a moment and try again." Display a countdown or simply ask users to wait. Never expose the exact rate limit threshold (e.g., "5 requests per minute") — this helps attackers calibrate their attacks. Log rate-limited requests for security monitoring.',
    implementation: 'Backend: rate limiter (express-rate-limit, upstash-ratelimit) returns 429 with Retry-After header. Frontend: catch 429, show Alert with message and countdown based on Retry-After. Disable the submit button during the wait period. On expiry, re-enable and clear the message. Log rate-limited IPs for abuse detection.',
    a11y: 'Rate limit message: role="alert" so it is immediately announced. "Too many attempts. Please try again in 45 seconds." Disabled submit button: aria-disabled="true" with aria-describedby explaining why. Countdown: announce only at completion ("You can try again now") via aria-live="polite". Never use CAPTCHA as the sole rate-limit response without a text alternative.',
    docsUrl: null,
  },
  {
    name: 'CAPTCHA / Bot Detection',
    category: 'security',
    description: 'Distinguish human users from bots during login, registration, and password reset. Invisible CAPTCHA (reCAPTCHA v3, Cloudflare Turnstile) scores requests without user interaction — preferred UX. Visual CAPTCHA (reCAPTCHA v2, hCaptcha) is a fallback for low-confidence scores. Never use CAPTCHA on every login — only after failed attempts or suspicious behavior. Turnstile is the most accessible modern option.',
    implementation: 'Primary: Cloudflare Turnstile (invisible, privacy-respecting, accessible). Fallback: reCAPTCHA v2 challenge for low-confidence scores. Integrate on registration, password reset, and after 3+ failed login attempts. Backend validates the token server-side. Do not block legitimate users — use CAPTCHA as one signal among many (IP reputation, device fingerprint, behavior analysis).',
    a11y: 'WCAG requires CAPTCHA alternatives for users with disabilities. Turnstile provides an accessible managed challenge by default. Visual CAPTCHAs must include an audio alternative. Place CAPTCHA near the submit button, not at the top of the form. aria-label="Security verification". If CAPTCHA fails, provide a "Contact support" fallback. Never use CAPTCHA that is impossible for screen reader users.',
    docsUrl: null,
  },
  {
    name: 'Security Event Notifications',
    category: 'security',
    description: 'Email or push notifications for security-relevant account events — new device login, password change, MFA change, unusual location login, failed login attempts. These are mandatory notifications that cannot be unsubscribed from (unlike marketing emails). Include details: device, location, time. Provide a "This wasn\'t me" action link that immediately locks the account and triggers recovery.',
    implementation: 'Trigger notifications for: new_device_login, password_changed, mfa_enabled, mfa_disabled, email_changed, account_locked, unusual_location. Email template: clear subject line ("New sign-in to your account"), event details (device, location, time), and prominent "This wasn\'t me" CTA that locks the account. Store security events in an audit log table.',
    a11y: 'Email notifications: semantic HTML, 4.5:1 contrast, plain-text fallback. "This wasn\'t me" link: large tap target, descriptive text. Account activity log page in settings: accessible table with sortable columns. Each event row: date, event type, device, location. Filter by event type. aria-label on the table: "Security activity log."',
    docsUrl: null,
  },
  {
    name: 'Credential Stuffing Defense',
    category: 'security',
    description: 'Protect against automated attacks using stolen credentials from other breaches. Layer multiple defenses: rate limiting per IP, account lockout after failed attempts, device fingerprinting to detect automated clients, breach database checks (Have I Been Pwned API) during registration and password change. Show a warning if the chosen password has appeared in known breaches.',
    implementation: 'Registration/password change: check password against HIBP Pwned Passwords API (k-anonymity model — only send first 5 chars of SHA-1 hash). If found: "This password has appeared in a data breach. Choose a different password." Login defense: rate limit by IP + fingerprint, progressive delays, CAPTCHA after failures. Monitor for distributed attacks (many IPs, same target account).',
    a11y: 'Breach warning: role="alert" with descriptive text and guidance. Do not just say "password is compromised" — explain: "This password was found in a public data breach and may be unsafe. Please choose a different password." Link to more information. Password field retains the entered value so the user can modify rather than retype. Announce the warning immediately.',
    docsUrl: null,
  },
  {
    name: 'Security Settings Page',
    category: 'security',
    description: 'A dedicated security section in account settings — password change, MFA management, active sessions, trusted devices, security activity log, connected apps. Group related controls visually. Use a "danger zone" pattern for destructive actions (delete account, disable MFA) with red styling and confirmation dialogs. Link to security recommendations (enable MFA, check for breached passwords).',
    implementation: 'shadcn: Tabs or accordion sections for each security category. Sections: Password, Two-Factor Authentication, Active Sessions, Trusted Devices, Security Log, Connected Apps, Danger Zone. Each section is independently collapsible. Danger zone: red border, destructive Button variant, AlertDialog confirmation with typed confirmation ("type DELETE to confirm").',
    a11y: 'Page heading: "Security Settings" with h1. Each section has h2 heading. Danger zone: aria-label="Danger zone — irreversible actions". Typed confirmation input: aria-label="Type DELETE to confirm account deletion". AlertDialog for destructive actions properly traps focus. Ensure all toggle switches and buttons have descriptive labels in context, not just "Enable" or "Disable."',
    docsUrl: null,
  },
];
