# Internationalization (i18n) Patterns

Agent-facing reference for locale-aware applications.
Each pattern: **When to apply / What to do / Pitfall to avoid**.

---

## 1. Text & Content

### Externalize all user-facing strings
- **When:** Every component rendering user-visible text.
- **Do:** Store strings in message catalogs keyed by locale. Load via i18n library (react-intl, next-intl, vue-i18n). Even "OK" and "Cancel" come from catalogs.
- **Pitfall:** Hardcoded strings in templates or JSX.

### ICU MessageFormat for interpolation
- **When:** Any string containing variable values.
- **Do:** Use ICU syntax so translators see the full sentence with placeholders:
```icu
{userName} added {count} items to the cart.
```
- **Pitfall:** Concatenating fragments (`"Added " + count + " items"`). Word order varies (English SVO, Japanese SOV, Arabic VSO).

### Text expansion buffer
- **When:** All layout decisions involving text containers.
- **Do:** Budget for expansion: German +30%, Finnish +40%, French +20%. Contraction: Chinese -30%, Korean -25%. Use flexible layouts (`min-width` not `width`).
- **Pitfall:** Fixed-width containers that truncate translations.

### Pluralization via CLDR rules
- **When:** Any quantity-dependent string.
- **Do:** Use ICU `{count, plural, one {# item} other {# items}}`. English: 2 forms. Arabic: 6 forms. Japanese: 0 distinct forms (always `other`).
- **Pitfall:** Assuming `count === 1` is the only special case.

### No text in images/SVGs
- **When:** Visual assets with readable text.
- **Do:** Overlay text via HTML/CSS. For SVGs, use `<text>` bound to translated strings.
- **Pitfall:** Baked text forces per-locale image variants and breaks screen readers.

### Language attributes
- **When:** Every HTML document; inline foreign-language text.
- **Do:** Set `lang` on `<html>`. Override with `lang` on elements in a different language:
```html
<html lang="de"><body><p lang="en">English section</p></body></html>
```
- **Pitfall:** Omitting `lang` breaks screen reader pronunciation and spell-checking.

---

## 2. Names

### Single full name field
- **When:** Registration, profile, checkout forms.
- **Do:** One "Full name" input. Optional "What should we call you?" for display name. Optional furigana field for Japanese users.
- **Pitfall:** First/last split fails for mononymous cultures, patronymics (Iceland), multi-part names.

### Cultural variations
- **When:** Storing or displaying personal names.
- **Do:** Support without validation errors: family-first (China), two family names (Spain), patronymic/no family name (Iceland), gender-inflected (Russia), mononymous (Indonesia).
- **Pitfall:** Validating `name.length >= 2` or requiring a space.

### Full Unicode support
- **When:** All name fields and storage.
- **Do:** Accept diacritics (n, u, o), CJK, Arabic, Devanagari. Use `utf8mb4` in databases.
- **Pitfall:** Restricting input to `[a-zA-Z]` or stripping non-ASCII.

---

## 3. Addresses

### Dynamic format per country
- **When:** All address forms.
- **Do:** Adapt field order and labels by country. US: number-street, city, state, ZIP. DE: street-number, PLZ, city. JP: prefecture, city, ward, block (largest-to-smallest). Use `libaddressinput` for format data.
- **Pitfall:** Single hardcoded layout for all countries.

### Postal code validation
- **When:** Forms collecting postal codes.
- **Do:** Validate per country: US `^\d{5}(-\d{4})?$`, UK alphanumeric, DE `^\d{5}$`, JP `^\d{3}-\d{4}$`, IE Eircode. Some countries have no postal codes.
- **Pitfall:** Applying US ZIP validation globally or making postal code universally required.

### Country pre-selection and postal lookup
- **When:** User's country is likely known.
- **Do:** Pre-select from `navigator.language`, `Accept-Language`, or IP geolocation. Offer postal-to-city auto-lookup where available.
- **Pitfall:** 200+ country dropdown with no pre-selection or search.

### State/province handling
- **When:** Address forms with administrative region field.
- **Do:** Required for US/CA/AU, optional for most EU, nonexistent in some countries. Adapt label: "State" (US), "Province" (CA), "Prefecture" (JP).
- **Pitfall:** Globally required state field with "State" as universal label.

---

## 4. Numbers, Currency & Dates

### Number formatting
- **When:** Every numeric value displayed to users.
- **Do:** Use `Intl.NumberFormat`. Store raw values server-side, format on display:
```js
new Intl.NumberFormat('de-DE').format(1234.5) // "1.234,5"
new Intl.NumberFormat('en-US').format(1234.5) // "1,234.5"
```
- **Pitfall:** Hardcoding `.` as decimal or `,` as grouping separator.

### Date and time formatting
- **When:** Every date/time displayed to users.
- **Do:** Use `Intl.DateTimeFormat`. Store ISO 8601/UTC server-side:
```js
new Intl.DateTimeFormat('en-US').format(d) // "3/5/2026"
new Intl.DateTimeFormat('de-DE').format(d) // "5.3.2026"
```
Respect 12h (US/UK) vs 24h (most of world) via locale defaults.
- **Pitfall:** Hardcoding MM/DD/YYYY. Displaying "13:00 PM".

### Currency display
- **When:** Any monetary value.
- **Do:** Use `Intl.NumberFormat` with `style: "currency"`:
```js
new Intl.NumberFormat('en-US', {style:'currency', currency:'USD'}).format(100) // "$100.00"
new Intl.NumberFormat('de-DE', {style:'currency', currency:'EUR'}).format(100) // "100,00 €"
```
- **Pitfall:** Manually prepending `$`. Symbol position, spacing, and decimals vary by locale.

---

## 5. RTL Layout

### Document direction
- **When:** Active locale is Arabic, Hebrew, Farsi, or Urdu.
- **Do:** Set `dir="rtl"` on `<html>` (not just `<body>`).
- **Pitfall:** Setting on `<body>` only -- scrollbar and browser defaults depend on `<html>`.

### CSS logical properties
- **When:** All spacing, alignment, and positioning.
- **Do:** Replace physical with logical properties:
```css
/* Instead of margin-left / padding-right / text-align: left */
margin-inline-start: 1rem;
padding-inline-end: 0.5rem;
text-align: start;
border-inline-start: 2px solid;
```
- **Pitfall:** A single `margin-left` in an otherwise logical stylesheet breaks RTL.

### Layout mirroring
- **When:** Sidebars, navigation, breadcrumbs, progress indicators.
- **Do:** Logical properties auto-mirror most layout. Test with `dir="rtl"` during development even if RTL is not a launch target.
- **Pitfall:** Forgetting to verify mirrored layout.

### LTR within RTL
- **When:** Numbers, code, URLs, email addresses in RTL text.
- **Do:** Numbers and Latin script stay LTR (Unicode BiDi Algorithm handles this). Use `dir="auto"` on user-input fields.
- **Pitfall:** Forcing RTL on numeric or mixed-script inputs.

### Directional icons
- **When:** Arrows, chevrons, progress indicators.
- **Do:** Flip via `transform: scaleX(-1)` or mirrored SVGs for RTL.
- **Pitfall:** Flipping universal icons (search, home, play/pause, checkmarks) -- these stay the same.

---

## 6. Phone Numbers

### Input
- **When:** All phone number fields.
- **Do:** Use `type="tel" inputmode="tel" autocomplete="tel"`. Accept flexible input (spaces, dashes, dots, parens). Provide country code dropdown pre-selected from user locale.
- **Pitfall:** `type="number"` strips leading zeros and adds spinners. Defaulting to `+1` for all users.

### Storage
- **When:** Persisting phone numbers.
- **Do:** E.164 format: `+` country code + subscriber number, no separators (`+14155550123`). Parse on input, format on display.
- **Pitfall:** Storing formatted numbers with spaces/dashes creates inconsistent data.

### Validation
- **When:** Client or server phone validation.
- **Do:** Use `libphonenumber` or `libphonenumber-js` for per-country format, length, and type validation.
- **Pitfall:** Regex-only validation. Formats vary wildly and change over time.

### Display
- **When:** Showing stored numbers to users.
- **Do:** National format for local users (`(415) 555-0123`), international for cross-border (`+1 415-555-0123`).
- **Pitfall:** Displaying raw E.164 (`+14155550123`) to end users.

---

## 7. i18n Testing

### Pseudo-localization
- **When:** During development, before real translations.
- **Do:** Replace ASCII with accented equivalents (`a`->`a`, `e`->`e`) and pad strings to simulate expansion. Reveals hardcoded strings, truncation, and encoding issues.
- **Pitfall:** Waiting for real translations to discover layout problems.

### Extreme language testing
- **When:** Before every release with UI changes.
- **Do:** Test with: German (de-DE, +30% expansion, truncation), Arabic (ar-SA, RTL + alternate numerals), Japanese (ja-JP, CJK, no word spacing), English (en-US, baseline).
- **Pitfall:** Testing only in English.

### Intl API verification
- **When:** After implementing number/date/currency formatting.
- **Do:** Assert `Intl.NumberFormat`/`DateTimeFormat` output for at least en-US, de-DE, ja-JP, ar-SA:
```js
expect(new Intl.NumberFormat('de-DE').format(1234.5)).toBe('1.234,5');
```
- **Pitfall:** Assuming identical Intl output across JS runtimes. Pin to production runtime.

### Form input testing
- **When:** Forms accepting locale-sensitive data.
- **Do:** Test with: German postal codes (`10115`), UK postcodes (`SW1A 1AA`), Japanese phones (`03-1234-5678`), names with diacritics, Arabic RTL input.
- **Pitfall:** Only testing ASCII input in LTR layout.

### Overflow and truncation
- **When:** UI elements with bounded dimensions (buttons, cells, cards, tooltips).
- **Do:** Load longest translations. Use `overflow-wrap: break-word` and `hyphens: auto`.
- **Pitfall:** `text-overflow: ellipsis` without tooltip -- truncated translations hide critical info.

### CI integration
- **When:** All projects with i18n.
- **Do:** Run pseudo-locale build in CI. Fail if any string key is missing (indicates hardcoded string).
- **Pitfall:** Treating i18n testing as manual pre-release activity.
