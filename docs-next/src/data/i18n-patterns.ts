export interface I18nPattern {
  name: string;
  category: 'text' | 'names' | 'addresses' | 'formatting' | 'rtl' | 'testing';
  description: string;
  pitfall: string;
  implementation: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<I18nPattern['category'], string> = {
  text: 'Text & Content',
  names: 'Names & Identity',
  addresses: 'Addresses & Geography',
  formatting: 'Number, Date & Currency',
  rtl: 'Right-to-Left',
  testing: 'Testing & QA',
};

export const categoryOrder: I18nPattern['category'][] = [
  'text', 'names', 'addresses', 'formatting', 'rtl', 'testing',
];

export const i18nPatterns: I18nPattern[] = [
  // --- Text & Content ---
  {
    name: 'Text Expansion Buffer',
    category: 'text',
    description: 'Design UI to accommodate 30-40% longer text in German/Finnish translations. Fixed-width containers will truncate or break with translated strings.',
    pitfall: 'Fixed-width containers truncate or break with translated strings. "Shopping Cart" (13 chars) becomes "Einkaufswagen" (13 chars in German but wider) or "Ostoskori" in Finnish. Button text, nav labels, and table headers are the most common casualties.',
    implementation: 'Use flexible layouts (flex, grid, min-width instead of fixed width). Test with pseudo-localization — pad every string with 35% extra characters. Avoid fixed heights on text containers. Set overflow-wrap: break-word as a safety net.',
    docsUrl: null,
  },
  {
    name: 'Pluralization Rules',
    category: 'text',
    description: 'Use CLDR plural categories, not simple if/else. Different languages have vastly different plural rules — English has 2 forms, Arabic has 6, Japanese has 0 distinct forms.',
    pitfall: 'Writing `count === 1 ? "item" : "items"` only works for English. Arabic has singular, dual, and 4 plural forms. Polish has different rules for 2-4 vs 5-21. Japanese uses no plural distinctions at all.',
    implementation: 'Use ICU MessageFormat: `{count, plural, one {# item} other {# items}}`. Libraries like i18next, FormatJS, or Intl.PluralRules handle CLDR rules automatically. Never hand-roll plural logic.',
    docsUrl: null,
  },

  // --- Names & Identity ---
  {
    name: 'Single Full Name Field',
    category: 'names',
    description: 'Use one "Full name" field instead of splitting into first/last name. Name structures vary wildly across cultures — mononymous names, patronymics, multi-part family names, and name order all break the first/last assumption.',
    pitfall: 'Splitting names fails for mononymous names (Sukarno), patronymic systems (Icelandic), multi-part family names (van der Berg), and cultures where family name comes first (Chinese, Japanese, Korean, Hungarian).',
    implementation: 'Single "Full name" input field. Add an optional "Display name" or "Preferred name" field for how the user wants to be addressed. Store the full string as-is — never try to programmatically split or reorder.',
    docsUrl: 'https://www.w3.org/International/questions/qa-personal-names',
  },
  {
    name: 'Phone Number Format',
    category: 'names',
    description: 'Accept flexible phone input, store in E.164 format, and display in locale-appropriate format. International phone numbers have wildly different lengths, groupings, and prefix rules.',
    pitfall: 'Validating against US format (xxx-xxx-xxxx) rejects valid international numbers. UK numbers have variable length, Indian numbers are 10 digits, and some countries share country codes. Stripping the + prefix corrupts international numbers.',
    implementation: 'Use `inputmode="tel"` for mobile keyboard. Provide a country code dropdown. Store all numbers in E.164 format (+14155551234). Use libphonenumber for validation and display formatting. Never enforce a single country\'s format.',
    docsUrl: null,
  },

  // --- Addresses & Geography ---
  {
    name: 'Dynamic Address Form',
    category: 'addresses',
    description: 'Render address fields dynamically based on the selected country. Address formats vary dramatically — field names, order, required fields, and postal code formats all change by country.',
    pitfall: 'US address format (Street, City, State, ZIP) doesn\'t work for Germany (PLZ before city), Japan (largest to smallest: prefecture, city, ward, block), UK (no state equivalent), or countries without postal codes (Ireland until 2015).',
    implementation: 'Start with a country selector. Load country-specific field order and labels from locale data (Google\'s Address Data Service or libaddressinput). Show/hide fields dynamically — not all countries need state/province, postal code, or apartment fields.',
    docsUrl: 'https://www.w3.org/International/wiki/Address_Formats',
  },

  // --- Number, Date & Currency ---
  {
    name: 'Locale Number Format',
    category: 'formatting',
    description: 'Use Intl.NumberFormat for all displayed numbers. Thousands separators and decimal marks vary by locale and mixing them up causes data entry errors or misreading.',
    pitfall: '1,000.50 (US) vs 1.000,50 (DE) vs 1 000,50 (FR) vs 1\'000.50 (CH). Using the wrong separator can turn 1.234 into "one point two three four" or "one thousand two hundred thirty-four" depending on locale.',
    implementation: '`new Intl.NumberFormat(locale).format(number)` for display. For inputs, parse with locale awareness — accept both comma and period as decimal separators based on locale. Never format numbers with string concatenation.',
    docsUrl: null,
  },
  {
    name: 'Locale Date Format',
    category: 'formatting',
    description: 'Use Intl.DateTimeFormat for all displayed dates. The ambiguity of numeric date formats causes real-world confusion — 03/05/2026 means March 5 in the US but May 3 in most of Europe.',
    pitfall: '03/05/2026 means March 5 (US), May 3 (UK/EU), or could be read as 2026-05-03 in ISO contexts. MM/DD vs DD/MM ambiguity causes booking errors, incorrect deadlines, and data corruption when parsing user input.',
    implementation: '`new Intl.DateTimeFormat(locale, { year: "numeric", month: "short", day: "numeric" }).format(date)`. Use named months ("5 Mar 2026") to eliminate ambiguity in mixed-locale contexts. Store dates as ISO 8601 internally.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat',
  },
  {
    name: 'Currency Formatting',
    category: 'formatting',
    description: 'Use Intl.NumberFormat with style: "currency" for all monetary values. Symbol position, spacing, decimal rules, and symbol itself all vary by locale.',
    pitfall: '$100.00 (US) vs 100,00 € (DE) vs 100 € (FR) vs ¥100 (JP, no decimals) vs Fr. 100.00 (CH). The currency symbol can appear before or after the number, with or without a space, and decimal precision varies.',
    implementation: '`new Intl.NumberFormat(locale, { style: "currency", currency: currencyCode }).format(amount)`. Always pass the ISO 4217 currency code (USD, EUR, JPY) separately from the locale. Never hardcode currency symbols or decimal places.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat',
  },

  // --- Right-to-Left ---
  {
    name: 'RTL Layout Support',
    category: 'rtl',
    description: 'Use CSS logical properties and dir="rtl" for Arabic, Hebrew, and Farsi layouts. Physical CSS properties create broken layouts when content direction is reversed.',
    pitfall: 'Physical CSS properties (margin-left, padding-right, text-align: left, float: left) break in RTL layouts. Icons with directional meaning (arrows, progress indicators) need to be mirrored. Mixing LTR and RTL content in one page creates visual chaos.',
    implementation: 'Replace all physical properties: margin-inline-start instead of margin-left, padding-inline-end instead of padding-right, inset-inline-start instead of left. Set dir="auto" on user-input fields. Use logical values (start/end) for text-align and float.',
    docsUrl: null,
  },

  // --- Testing & QA ---
  {
    name: 'Locale Switcher',
    category: 'testing',
    description: 'Provide a visible language/locale switcher that persists the user\'s choice across navigation. The switcher should be easy to find and respect browser language preferences for the initial selection.',
    pitfall: 'Hiding the locale switcher in deep settings makes it unfindable. Losing the language preference on navigation forces users to re-select every page. Using flags for languages is inaccurate — Spanish is spoken in 20+ countries, English in 60+.',
    implementation: 'Place a dropdown in the header or footer using language names in their own script (Deutsch, not German). Persist choice to localStorage + URL parameter (?lang=de). Respect Accept-Language header for initial selection. Use ISO 639-1 language codes.',
    docsUrl: null,
  },
];
