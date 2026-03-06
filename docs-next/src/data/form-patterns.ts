export interface FormPattern {
  name: string;
  category: 'components' | 'validation' | 'autocomplete' | 'enhancement' | 'structure' | 'specialized' | 'resilience' | 'accessibility';
  description: string;
  implementation: string;
  a11y: string;
  docsUrl: string | null;
}

export const categoryLabels: Record<FormPattern['category'], string> = {
  components: 'Form Components',
  validation: 'Validation & Error Handling',
  autocomplete: 'Autocomplete & Autofill',
  enhancement: 'Input Enhancement',
  structure: 'Form Structure',
  specialized: 'Specialized Inputs',
  resilience: 'Resilience',
  accessibility: 'Form Accessibility',
};

export const categoryOrder: FormPattern['category'][] = [
  'components', 'validation', 'autocomplete', 'enhancement', 'structure', 'specialized', 'resilience', 'accessibility',
];

export const formPatterns: FormPattern[] = [
  // --- Form Components ---
  { name: 'Button', category: 'components', description: 'A clickable element that triggers an action. Use for primary actions, form submissions, and confirmations.', implementation: 'shadcn: button. Primary for main action, secondary/ghost for alternatives. One primary per viewport.', a11y: 'Must be focusable and respond to Enter/Space. Use <button> not <div>.', docsUrl: 'https://ui.shadcn.com/docs/components/button' },
  { name: 'Checkbox', category: 'components', description: 'A box you tick to turn an option on or off. Use for multiple selections from a list or boolean toggles.', implementation: 'shadcn: checkbox. Group with fieldset/legend for related options.', a11y: 'Linked <label>. aria-checked state. Group with role="group" and aria-labelledby.', docsUrl: 'https://ui.shadcn.com/docs/components/checkbox' },
  { name: 'Combobox', category: 'components', description: 'A search box that filters and suggests options as you type. Use for selecting from large lists (10+ items) like countries or tags.', implementation: 'shadcn: command + popover. Debounce input (300ms). Show loading state for async options.', a11y: 'aria-expanded, aria-activedescendant for selection. Full keyboard navigation (arrows, Enter, Escape).', docsUrl: 'https://ui.shadcn.com/docs/components/combobox' },
  { name: 'Date Picker', category: 'components', description: 'A calendar popup for picking dates. Use for date selection, date ranges, and scheduling.', implementation: 'shadcn: calendar + popover. Allow manual typing alongside calendar selection. Locale-aware formatting.', a11y: 'Keyboard navigation within calendar grid. aria-label on day cells. Support manual date entry.', docsUrl: 'https://ui.shadcn.com/docs/components/date-picker' },
  { name: 'Form', category: 'components', description: 'A group of fields the user fills in and submits. The foundation for any structured data collection.', implementation: 'shadcn: form. Single-column layout. Validate on blur. Autocomplete attributes on all standard fields.', a11y: 'Every input needs a <label>. Error messages via aria-describedby. Focus first error on submit failure.', docsUrl: 'https://ui.shadcn.com/docs/components/form' },
  { name: 'Input', category: 'components', description: 'A text field where users type short text like names, emails, or search queries.', implementation: 'shadcn: input. Set inputmode (numeric, email, tel). Set autocomplete attribute.', a11y: 'Linked <label for>. aria-describedby for helper text. aria-invalid on error.', docsUrl: 'https://ui.shadcn.com/docs/components/input' },
  { name: 'Input OTP', category: 'components', description: 'Separate boxes for entering a verification code. Auto-advances on digit entry and supports paste.', implementation: 'shadcn: input-otp. autocomplete="one-time-code", inputmode="numeric". Auto-advance on digit entry.', a11y: 'Single logical input with aria-label. Support full-code paste. Focus management between boxes.', docsUrl: 'https://ui.shadcn.com/docs/components/input-otp' },
  { name: 'Label', category: 'components', description: 'Text that describes what a form field is for. Every input must have one.', implementation: 'shadcn: label. Always use <label for="id"> linking to the input. Show required/optional marking.', a11y: 'Programmatic association via for/id. Never use placeholder as a label substitute.', docsUrl: 'https://ui.shadcn.com/docs/components/label' },
  { name: 'Radio Group', category: 'components', description: 'A set of options where you pick exactly one. Use for mutually exclusive choices with 2–5 visible options.', implementation: 'shadcn: radio-group. Use radio over select when options ≤5 — all options are visible without interaction.', a11y: 'Wrap in fieldset/legend. Arrow keys move selection. Role="radiogroup".', docsUrl: 'https://ui.shadcn.com/docs/components/radio-group' },
  { name: 'Select', category: 'components', description: 'A dropdown list for picking one option from 3–10 choices where space is limited.', implementation: 'shadcn: select. Use for 3-10 options. For 10+ options, prefer Combobox with search.', a11y: 'aria-expanded on trigger. Keyboard: arrows to navigate, Enter to select, Escape to close.', docsUrl: 'https://ui.shadcn.com/docs/components/select' },
  { name: 'Slider', category: 'components', description: 'A draggable handle for picking a value within a range, like price or volume.', implementation: 'shadcn: slider. Show current value label. Snap to meaningful increments.', a11y: 'role="slider" with aria-valuenow/min/max/valuetext. Arrow keys for fine control.', docsUrl: 'https://ui.shadcn.com/docs/components/slider' },
  { name: 'Switch', category: 'components', description: 'An on/off toggle that takes effect immediately. Use for settings like dark mode or notifications.', implementation: 'shadcn: switch. Applies instantly (no save button needed). Show on/off label alongside.', a11y: 'role="switch" with aria-checked. Linked label. Space toggles state.', docsUrl: 'https://ui.shadcn.com/docs/components/switch' },
  { name: 'Textarea', category: 'components', description: 'A larger text box for writing longer content like descriptions, comments, or messages.', implementation: 'shadcn: textarea. Pair with Character Counter for length limits. Resizable handle optional.', a11y: 'Linked <label>. aria-describedby for character count. Never silently truncate input.', docsUrl: 'https://ui.shadcn.com/docs/components/textarea' },
  { name: 'Toggle', category: 'components', description: 'A button that stays pressed or released. Use for formatting tools like bold/italic or view mode switching.', implementation: 'shadcn: toggle. Visual pressed state via aria-pressed. Not for binary settings (use Switch instead).', a11y: 'aria-pressed indicates state. Keyboard-operable via Enter/Space.', docsUrl: 'https://ui.shadcn.com/docs/components/toggle' },
  { name: 'Toggle Group', category: 'components', description: 'A row of buttons where you pick one (or multiple). Use for view switchers or filter groups.', implementation: 'shadcn: toggle-group. Single-select by default. Multi-select when choices are independent.', a11y: 'role="group" with aria-label. Roving tabindex for arrow key navigation within group.', docsUrl: 'https://ui.shadcn.com/docs/components/toggle-group' },
  { name: 'File Upload', category: 'components', description: 'A button or drop zone for uploading files. Always provide a button alternative alongside drag-and-drop.', implementation: 'Drag-and-drop zone with click fallback. Show file type/size limits. Progress indicator during upload.', a11y: 'Button fallback is essential — drag-and-drop alone excludes keyboard users. aria-describedby for limits.', docsUrl: null },

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

  // --- Conversion ---
  {
    name: 'Single-Column Layout',
    category: 'structure',
    description: 'Stack all fields in a single column. Left-align labels above fields. Never use multi-column form layouts — they cause 28% more errors.',
    implementation: 'Use a single <form> with max-width constraint. Labels above fields with display: block. No CSS grid/flex row layouts for form fields.',
    a11y: 'Single-column layout creates a clear tab order. Labels above fields improve screen reader flow.',
    docsUrl: null,
  },
  {
    name: 'Smart Defaults',
    category: 'autocomplete',
    description: 'Pre-fill fields with the most common or contextually relevant values. Use browser autofill attributes. Default to the most popular option in select fields.',
    implementation: 'Auto-detect country from IP or locale. Pre-select currency. Use autocomplete attributes. Set default <option selected> on selects.',
    a11y: 'Pre-filled values must be screen-reader-accessible. Users must be able to override defaults.',
    docsUrl: null,
  },
  {
    name: 'Error Message Clarity',
    category: 'validation',
    description: 'Error messages must say what went wrong AND how to fix it. Use specific language, not generic. Red color + icon, not color alone.',
    implementation: 'Template: "Enter a valid [field] (e.g., [example])". Always pair color with an icon. Link via aria-describedby.',
    a11y: '8% of men are colorblind — never use color alone. Icon + color + text triple redundancy.',
    docsUrl: null,
  },
  {
    name: 'Field Count Optimization',
    category: 'structure',
    description: 'Audit every field — remove any not strictly required. If a field can be derived later, skip it. Target 3-5 fields for signup forms.',
    implementation: 'Review each field: can it be derived? deferred? removed? Reducing 11 → 4 fields increased conversions 120% (Unbounce).',
    a11y: 'Fewer fields reduce cognitive load for all users, especially those using assistive technology.',
    docsUrl: null,
  },
  {
    name: 'Guest Checkout',
    category: 'structure',
    description: 'Never require account creation to complete a purchase. Offer guest checkout as the default, with optional account creation after payment.',
    implementation: 'Guest checkout button as primary CTA. "Sign in" as secondary. Offer account creation post-payment with pre-filled data.',
    a11y: 'Guest checkout path must be fully keyboard-navigable and clearly labeled.',
    docsUrl: null,
  },

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
