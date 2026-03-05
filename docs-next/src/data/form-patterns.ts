export interface FormPattern {
  name: string;
  category: 'validation' | 'autocomplete' | 'enhancement' | 'structure' | 'specialized' | 'resilience' | 'accessibility';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<FormPattern['category'], string> = {
  validation: 'Validation & Error Handling',
  autocomplete: 'Autocomplete & Autofill',
  enhancement: 'Input Enhancement',
  structure: 'Form Structure',
  specialized: 'Specialized Inputs',
  resilience: 'Resilience',
  accessibility: 'Form Accessibility',
};

export const categoryOrder: FormPattern['category'][] = [
  'validation', 'autocomplete', 'enhancement', 'structure', 'specialized', 'resilience', 'accessibility',
];

export const formPatterns: FormPattern[] = [
  // --- Validation & Error Handling ---
  {
    name: 'Inline Validation',
    category: 'validation',
    description: 'Validate on blur (not on keystroke). Show success checkmarks for valid fields and error messages inline below the field. Never clear the field on error.',
    implementation: 'Attach onBlur handler to each field. Show error via aria-describedby. Use aria-invalid="true" on the field. Success: green checkmark icon.',
    a11y: 'Error messages linked via aria-describedby. aria-invalid="true" on the field. Never color-only indicators.',
    docsUrl: null,
  },
  {
    name: 'Error Summary',
    category: 'validation',
    description: 'Show a summary box at the top of the form listing all errors on failed submission. Each error links to the corresponding field.',
    implementation: 'role="alert" container. Focus the summary on submit failure. Each item is an anchor to the field ID.',
    a11y: 'role="alert" or aria-live="polite". Focus management on submit failure.',
    docsUrl: null,
  },
  {
    name: 'Focus on First Error',
    category: 'validation',
    description: 'On submission failure, automatically focus the first invalid field and scroll it into view. Never focus the submit button on error.',
    implementation: 'After validation, find first invalid field, call .focus() and .scrollIntoView({ behavior: "smooth", block: "center" }).',
    a11y: 'Ensures keyboard users are positioned at the first problem without manual searching.',
    docsUrl: null,
  },

  // --- Autocomplete & Autofill ---
  {
    name: 'Autocomplete Tokens',
    category: 'autocomplete',
    description: 'Set the autocomplete attribute on every standard form field (name, email, tel, address, cc-number). Browsers auto-fill known values, reducing effort by 30-50%.',
    implementation: 'Add autocomplete="name|email|tel|address-line1|postal-code|country|cc-number|cc-exp|cc-csc" to inputs.',
    a11y: 'Autocomplete helps motor-impaired users avoid retyping. Never disable autocomplete on standard fields.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete',
  },
  {
    name: 'Address Autocomplete',
    category: 'autocomplete',
    description: 'Integrate address lookup (Google Places API or similar) to auto-fill city, state, and zip from partial address input. Pre-select country from locale.',
    implementation: 'Attach Places Autocomplete to the first address field. On selection, populate all address fields. Fallback to standard fields with autocomplete tokens.',
    a11y: 'Autocomplete dropdown must be keyboard-navigable. aria-expanded on the input. aria-activedescendant for selection.',
    docsUrl: null,
  },

  // --- Input Enhancement ---
  {
    name: 'Password Strength',
    category: 'enhancement',
    description: 'Entropy-based strength meter for password creation. Show as a colored bar (red → yellow → green) with a specific requirements checklist.',
    implementation: 'Calculate entropy from character set diversity and length. Show requirements as checkmarks. aria-live="polite" for strength changes.',
    a11y: 'Strength meter uses aria-valuenow/min/max. Requirements list uses aria-live="polite" for updates.',
    docsUrl: null,
  },
  {
    name: 'Password Reveal',
    category: 'enhancement',
    description: 'Eye icon toggle that switches between type="password" and type="text". Essential on mobile where autocorrect can corrupt hidden passwords.',
    implementation: 'Button with aria-label="Show password" / "Hide password". Toggles input type attribute. Preserves cursor position.',
    a11y: 'aria-label updates on toggle. Button is focusable and keyboard-operable.',
    docsUrl: null,
  },
  {
    name: 'Character Counter',
    category: 'enhancement',
    description: 'Show remaining or used characters as "42/280" below the field. Warn when approaching the limit. Never silently truncate input.',
    implementation: 'Live counter tied to input event. aria-describedby links the counter to the field. Warn at 90% of limit.',
    a11y: 'Counter announced via aria-describedby. Warning state via aria-live="polite".',
    docsUrl: null,
  },
  {
    name: 'Input Masking',
    category: 'enhancement',
    description: 'Format inputs like phone numbers and credit cards on blur, not during typing. Accept flexible user input and normalize server-side.',
    implementation: 'Format on blur event. Store raw value internally. Display formatted value. Never prevent free typing.',
    a11y: 'Formatted value must remain readable by screen readers. aria-label describes the expected format.',
    docsUrl: null,
  },

  // --- Form Structure ---
  {
    name: 'Multi-Step Form',
    category: 'structure',
    description: 'Break forms with 7+ fields into 3-5 logical steps. Show progress indicator. Validate per step. Persist progress. Allow back navigation.',
    implementation: 'Step indicator at top. Validate current step on "Next". Save to localStorage on every step. Enable back without losing data.',
    a11y: 'Progress indicator has aria-label. Current step announced. Focus moves to first field of new step.',
    docsUrl: null,
  },
  {
    name: 'Conditional Fields',
    category: 'structure',
    description: 'Show or hide fields based on previous answers. Use the collapse/expand animation pattern. Clear hidden field values on parent change.',
    implementation: 'aria-expanded on the controlling field. Animate with grid-template-rows: 0fr/1fr. Remove hidden fields from form data on submit.',
    a11y: 'aria-expanded indicates state. Conditional fields are removed from tab order when hidden.',
    docsUrl: null,
  },
  {
    name: 'Fieldset Grouping',
    category: 'structure',
    description: 'Wrap related field groups (address, payment, personal info) in <fieldset> with <legend>. Provides context for screen readers.',
    implementation: '<fieldset> with <legend>. Never use <div> for groups that have a shared label.',
    a11y: 'Screen readers announce the legend when entering the fieldset, providing group context.',
    docsUrl: 'https://developer.mozilla.org/en-US/docs/Web/HTML/Element/fieldset',
  },
  {
    name: 'Required/Optional Marking',
    category: 'structure',
    description: 'Mark the minority: if most fields are required, mark optional ones as "(optional)". If most are optional, mark required ones with an asterisk.',
    implementation: 'required attribute or aria-required="true" on required fields. Visual indicator matches the minority pattern.',
    a11y: 'required attribute is the primary mechanism. Visual indicators supplement, never replace.',
    docsUrl: null,
  },

  // --- Specialized ---
  // (no specialized entries for now — covered in the template)

  // --- Resilience ---
  {
    name: 'Auto-Save Draft',
    category: 'resilience',
    description: 'Save form state to localStorage on debounce (2-5 seconds). Show a "Saved" indicator. Restore on page reload. Essential for long forms.',
    implementation: 'Debounce form change events (2s). Save serialized form data to localStorage. Show "Saved" via aria-live="polite" region.',
    a11y: 'Save status announced via aria-live="polite". Recovery banner on reload is focusable.',
    docsUrl: null,
  },
  {
    name: 'Form Recovery',
    category: 'resilience',
    description: 'Persist form state to localStorage on every change. Restore on page reload. Show a "Recovered draft" banner with option to discard.',
    implementation: 'Listen to beforeunload to save. On load, check for saved state. Show banner: "We recovered your draft. Continue or discard?"',
    a11y: 'Recovery banner uses role="alert". Discard button is keyboard-accessible.',
    docsUrl: null,
  },

  // --- Accessibility ---
  // (accessibility rules are covered in each pattern's a11y field)
];
