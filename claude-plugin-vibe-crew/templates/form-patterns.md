# Form Pattern Reference

Agent-facing reference for form design decisions, validation strategy, input enhancement, and resilience.
The Builder reads this during the Design Phase; the Code Reviewer checks compliance during review.
**Principle:** Forms should be forgiving, accessible, and preserve user effort at every step.

## 1. Validation & Error Handling

### Inline Validation
- **When:** Every form field that can be validated on the client.
- **What:** Validate on blur (not on keystroke). Show success checkmark for valid fields. Show error message inline below the field.
- **A11y:** Error messages use `aria-describedby` linked to the field. Error state uses `aria-invalid="true"`.
- **Anti-pattern:** Never clear the field on error. Never validate on every keystroke (causes flicker and premature errors).

### Error Summary
- **When:** Form submission with multiple errors.
- **What:** Show a summary box at the top listing all errors. Use `role="alert"`. Focus the summary on submit failure.
- **A11y:** Each error in the summary links to the corresponding field. Use `aria-live="polite"` for dynamic updates.

### Focus on First Error
- **When:** Form submission fails validation.
- **What:** Focus the first invalid field automatically. Scroll it into view if needed.
- **Anti-pattern:** Never focus the submit button on error. Never show errors without focusing the relevant field.

### Action-First Messages
- **When:** Writing any error message.
- **What:** Lead with what to do, not what went wrong. "Enter a valid email address" not "Invalid email". Use blame-free language.
- **Anti-pattern:** Never say "Error:", "Invalid:", or "Wrong:". Never use technical jargon in user-facing messages.

### Debounced Async Validation
- **When:** Fields requiring server-side validation (username availability, email uniqueness).
- **What:** Debounce 300ms after typing stops. Show a loading indicator during the check. Cache results to avoid redundant requests.
- **Anti-pattern:** Never block form submission while async validation is in progress — queue it.

### Pre-Submit Constraint Hints
- **When:** Fields with specific format requirements (passwords, dates, codes).
- **What:** Show requirements before the user types. Update checkmarks as requirements are met. Use `aria-describedby` to link hints to the field.
- **Example:** Password: "8+ characters, one uppercase, one number" with live checkmarks.

## 2. Autocomplete & Autofill

### HTML Autocomplete Tokens
- **When:** Every form field with a standard value type.
- **What:** Set the `autocomplete` attribute: `name`, `email`, `tel`, `address-line1`, `address-line2`, `postal-code`, `country`, `cc-number`, `cc-exp`, `cc-csc`, `organization`.
- **Why:** Browsers auto-fill known values, reducing effort by 30-50%. Mobile keyboards adapt to `inputmode`.
- **Anti-pattern:** Never disable autocomplete on standard fields. Never use `autocomplete="off"` on login forms.

### Address Autocomplete
- **When:** Address entry forms (shipping, billing).
- **What:** Integrate Google Places API or similar. Auto-fill city/state/zip from partial input. Pre-select country from locale.
- **Fallback:** If no API, use a standard multi-field address form with `autocomplete` tokens.

### OTP Autocomplete
- **When:** Verification code inputs.
- **What:** Use `autocomplete="one-time-code"` + `inputmode="numeric"`. Support paste into the first field to auto-fill all boxes.
- **Anti-pattern:** Never block paste on OTP fields.

### Search Autocomplete
- **When:** Search inputs with predictable results.
- **What:** Show suggestions in a dropdown. Support keyboard navigation (arrows + Enter). Highlight matching text. Debounce 200ms.
- **A11y:** Use `role="combobox"` + `aria-expanded` + `aria-activedescendant`.

## 3. Input Enhancement

### Input Masking
- **When:** Formatted inputs (phone numbers, credit cards, dates).
- **What:** Format on blur, not during typing. Accept flexible input, normalize server-side.
- **Anti-pattern:** Never prevent the user from typing freely. Never block non-numeric input in phone fields (users paste).

### inputmode Attribute
- **When:** Inputs expecting specific character types on mobile.
- **What:** `inputmode="numeric"` for numbers, `inputmode="tel"` for phone, `inputmode="email"` for email, `inputmode="url"` for URLs.
- **Why:** Shows the appropriate mobile keyboard. Dramatically reduces errors on mobile.

### Character Counter
- **When:** Inputs with length limits (bios, descriptions, tweet-length fields).
- **What:** Show "42/280" below the field. Use `aria-describedby` to announce the count to screen readers.
- **Anti-pattern:** Never silently truncate input. Always warn before the limit.

### Password Strength Meter
- **When:** Password creation fields.
- **What:** Entropy-based strength calculation. Show as a colored bar (red to yellow to green). Show specific requirements as a checklist.
- **A11y:** `aria-live="polite"` region announcing strength changes.

### Password Reveal Toggle
- **When:** Every password field.
- **What:** Eye icon button toggles `type="password"` to `type="text"`. Button has `aria-label="Show password"`.
- **Anti-pattern:** Never omit reveal on mobile — autocorrect can corrupt passwords.

### Loose Validation
- **When:** Fields with flexible formats (phone numbers, postal codes).
- **What:** Accept flexible input from the user (spaces, dashes, parentheses). Normalize to standard format server-side.
- **Anti-pattern:** Never reject valid input because of formatting ("5551234567" and "(555) 123-4567" are both valid).

## 4. Form Structure

### Single-Column Layout
- **When:** All forms.
- **What:** Stack fields in a single column. Left-align labels above fields. Never use multi-column form layouts.
- **Why:** Single-column creates a clear vertical flow. Multi-column causes 28% more errors (Baymard Institute).

### Multi-Step Wizard
- **When:** Forms with 7+ fields or logically distinct sections.
- **What:** Break into 3-5 steps. Show progress indicator. Validate per step. Persist progress (localStorage or server). Allow back navigation.
- **Anti-pattern:** Never lose progress on back navigation. Never validate the entire form at the end.

### Progressive Disclosure
- **When:** Forms with optional advanced fields.
- **What:** Show essential fields first. Reveal advanced fields via "More options" link or checkbox. Use `aria-expanded` on the toggle.
- **Anti-pattern:** Never show all fields at once if some are rarely used.

### Conditional Logic
- **When:** Fields that depend on previous answers.
- **What:** Show/hide dependent fields based on selections. Use `aria-expanded` on the controlling field. Animate with collapse pattern.
- **Anti-pattern:** Never submit hidden field values. Clear hidden fields on parent change.

### Required/Optional Marking
- **When:** Every form with a mix of required and optional fields.
- **What:** Mark the minority — if most fields are required, mark optional ones as "(optional)". If most are optional, mark required ones with asterisk.
- **A11y:** Always use `required` attribute or `aria-required="true"` in addition to visual indicator.

### Fieldset Grouping
- **When:** Logically related field groups (address, payment, personal info).
- **What:** Wrap in `<fieldset>` with `<legend>`. Provides context for screen readers.
- **Anti-pattern:** Never use `<div>` for grouping form sections that have a shared label.

## 5. Specialized Inputs

### Date Input
- **When:** Date selection fields.
- **What:** Provide both a date picker (calendar popup) and free-text typing. Parse flexible formats ("3/15", "March 15", "2026-03-15").
- **A11y:** Calendar grid follows ARIA grid pattern. Keyboard: arrows navigate days, Enter selects, Escape closes.

### File Upload
- **When:** Document, image, or file uploads.
- **What:** Drag-and-drop zone with a fallback button. Show progress bar during upload. Preview images. Show accepted formats and size limits.
- **A11y:** `<input type="file">` with label. Progress via live region. Always provide a button — drag-and-drop is not keyboard-accessible.
- **Anti-pattern:** Never drag-and-drop only.

### Credit Card Input
- **When:** Payment forms.
- **What:** Auto-detect card type from first digits (Visa 4, MC 5, Amex 34/37). Format with spaces (4242 4242 4242 4242). Separate fields for number, expiry, CVC.
- **A11y:** Use `autocomplete="cc-number"`, `autocomplete="cc-exp"`, `autocomplete="cc-csc"`.

### Rating Input
- **When:** Star ratings, satisfaction scores.
- **What:** Stars or scale selector. `aria-valuenow`, `aria-valuemin`, `aria-valuemax`. Allow half-stars if the scale warrants it.
- **Keyboard:** Arrow keys to change value.

## 6. Resilience

### Auto-Save Draft
- **When:** Long forms, multi-step wizards, text editors.
- **What:** Save to localStorage or server on debounce (2-5 seconds). Show a "Saved" indicator. Restore on page reload.
- **A11y:** Announce save status via `aria-live="polite"` region.

### Form Recovery
- **When:** Any form where data loss is painful.
- **What:** Persist form state to localStorage on every change. Restore on page reload. Show "Recovered draft" banner with option to discard.
- **Anti-pattern:** Never silently lose form data on navigation or refresh.

### Undo
- **When:** Destructive form actions (delete, clear, reset).
- **What:** Show undo toast for 5 seconds. Support Cmd+Z. Actually reverse the action, don't just hide.

## 7. Form i18n

### Single Name Field
- **When:** Collecting user names.
- **What:** Use a single "Full name" field, not first/last. Cultural variations: Chinese family-first, Spain two family names, Iceland no family name. Offer a "What should we call you?" field for display name.
- **Anti-pattern:** Never assume first/last name structure. Never reject names with diacritics, CJK characters, or spaces.

### Dynamic Address Format
- **When:** Address forms for multiple countries.
- **What:** Format changes per country (US: number-street, DE: street-number PLZ-city, JP: largest to smallest). Pre-configure from locale.
- **Anti-pattern:** Never use a fixed US-style address form globally.

### Number and Date Formatting
- **When:** Displaying or inputting numbers and dates.
- **What:** Use `Intl.NumberFormat` and `Intl.DateTimeFormat`. Decimal: `.` (US/UK) vs `,` (DE/FR). Date: MM/DD (US) vs DD.MM (DE) vs YYYY-MM-DD (ISO). Store raw values server-side.

## 8. Form Accessibility

### Labels
- **Rule:** Every input has a `<label>` with `for`/`id` pairing. No exceptions.
- **Anti-pattern:** Never use placeholder as the only label. Never hide labels visually without `sr-only`.

### Error Announcement
- **Rule:** Error messages use `aria-invalid="true"` on the field, `aria-describedby` linking to the error text, and `aria-live="polite"` for dynamic errors.

### Keyboard Navigation
- **Rule:** Tab moves between fields. Enter submits single-line inputs. Escape closes dropdowns. All custom inputs are keyboard-operable.

### Group Labels
- **Rule:** Related fields use `<fieldset>` + `<legend>`. Radio groups, checkbox groups, and address sections all need group labels.

## Builder Agent Key Principle

1. **Validate on blur, never on keystroke** — premature errors frustrate users.
2. **Never lose user input** — preserve on error, auto-save drafts, recover on reload.
3. **Action-first error messages** — "Enter a valid email" not "Invalid email".
4. **autocomplete on every standard field** — saves 30-50% of user effort.
5. **Single-column layout** — multi-column causes 28% more errors.
6. **Mark the minority** — if most fields are required, mark optional ones.
7. **Single "Full name" field** — don't assume cultural name structure.
8. **Every input has a `<label>`** — no exceptions.
