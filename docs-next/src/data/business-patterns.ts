export interface BusinessPattern {
  name: string;
  category: 'landing' | 'onboarding' | 'trust' | 'pricing' |
             'empty-states' | 'retention' | 'navigation' | 'feedback';
  description: string;
  whyItWorks: string;
  example: string;
  source: string | null;
}

export const categoryLabels: Record<BusinessPattern['category'], string> = {
  landing: 'Landing & Marketing Pages',
  onboarding: 'Onboarding & Activation',
  trust: 'Trust & Credibility Signals',
  pricing: 'Pricing & Payment',
  'empty-states': 'Empty States & First Use',
  retention: 'Retention & Engagement',
  navigation: 'Navigation & Information Architecture',
  feedback: 'Feedback & Completion',
};

export const categoryOrder: BusinessPattern['category'][] = [
  'landing', 'onboarding', 'trust', 'pricing',
  'empty-states', 'retention', 'navigation', 'feedback',
];

export const businessPatterns: BusinessPattern[] = [
  // --- Landing & Marketing Pages ---
  {
    name: 'Hero Section Formula',
    category: 'landing',
    description: 'Structure the hero as: headline (outcome, not feature) + subheadline (how it works) + primary CTA + supporting visual. Keep above the fold.',
    whyItWorks: 'Users form opinions in 50ms (Lindgaard et al.). StoryBrand framework: lead with the transformation. CXL research shows outcome-focused headlines outperform feature-focused by 28%.',
    example: 'Stripe — "Financial infrastructure for the internet" + clear CTA.',
    source: 'StoryBrand / CXL Institute',
  },
  {
    name: 'Social Proof Placement',
    category: 'landing',
    description: 'Place social proof (logos, testimonials, user counts) directly above or below the primary CTA. Use real numbers. Show recognizable customer logos in a row.',
    whyItWorks: 'Cialdini\'s social proof principle. Baymard Institute: 60% of users actively look for reviews/trust signals before committing.',
    example: 'Notion — customer logos bar between hero and features.',
    source: 'Baymard Institute / Cialdini',
  },
  {
    name: 'CTA Hierarchy',
    category: 'landing',
    description: 'One primary CTA per viewport. Primary button for main action, secondary/ghost for alternatives. Repeat CTA after every 2-3 content sections on long pages.',
    whyItWorks: 'Hick\'s Law — more choices increase decision time. CXL research: pages with a single clear CTA convert 13-28% better.',
    example: 'Linear — single "Start building" CTA, repeated at hero and page bottom.',
    source: 'CXL Institute',
  },
  {
    name: 'Pricing Page Psychology',
    category: 'landing',
    description: 'Show 3 tiers (decoy effect). Highlight the recommended tier visually with "Most Popular" badge and center position. Show annual/monthly toggle with savings percentage.',
    whyItWorks: 'Von Restorff isolation effect for the highlighted tier. Decoy effect (Ariely): the third option makes the target look better. Unbounce: showing savings percentage increases annual plan adoption 20-30%.',
    example: 'Vercel — 3 tiers, Pro highlighted center, annual savings shown.',
    source: 'Dan Ariely / Unbounce',
  },
  {
    name: 'FAQ Structure',
    category: 'landing',
    description: 'Use accordion components. Lead with objection-handling questions ("Is my data secure?", "Can I cancel anytime?"). Order by frequency of user concerns.',
    whyItWorks: 'Addresses buying objections at the decision point. Baymard: 21% of users abandon due to unanswered questions. Accordion reduces cognitive load.',
    example: 'Stripe — FAQ section addresses security and compliance concerns first.',
    source: 'Baymard Institute',
  },
  {
    name: 'Above-the-Fold Framework',
    category: 'landing',
    description: 'Above the fold must answer: (1) What is this? (2) What can I do here? (3) Why should I care? No scrolling required to understand the value proposition.',
    whyItWorks: 'NNGroup: users spend 57% of viewing time above the fold. Krug\'s "Don\'t Make Me Think" — if users can\'t understand the purpose instantly, they leave.',
    example: 'Slack — headline, subheadline, and CTA all visible without scrolling.',
    source: 'NNGroup / Steve Krug',
  },

  // --- Onboarding & Activation ---
  {
    name: 'First-Run Experience',
    category: 'onboarding',
    description: 'Show a guided first action, not a feature tour. Lead the user to their activation moment within 3 clicks. Use a progress checklist (3-5 items) that persists across sessions.',
    whyItWorks: 'Fogg Behavior Model: motivation is highest at signup — reduce friction to capitalize. Chameleon research: onboarding checklists increase activation rates by 30-40%.',
    example: 'Notion — immediately prompts creating a first page, not a product tour.',
    source: 'Fogg Behavior Model / Chameleon',
  },
  {
    name: 'Activation Moment',
    category: 'onboarding',
    description: 'Design the shortest path from signup to the user experiencing core value. Remove every unnecessary step between signup and activation.',
    whyItWorks: 'Product-led growth: time-to-value is the #1 predictor of free-to-paid conversion. Every extra step loses ~20% of users (Heap Analytics).',
    example: 'Canva — users create their first design within 60 seconds of signing up.',
    source: 'Wes Bush / Heap Analytics',
  },
  {
    name: 'Progressive Profiling',
    category: 'onboarding',
    description: 'Ask only email (or OAuth) at signup. Collect additional profile data after the user has experienced value, spread across natural touchpoints.',
    whyItWorks: 'Baymard Institute: every additional form field reduces conversion by ~3%. Collect data when users have motivation to continue (post-activation).',
    example: 'Spotify — signs up with email only, asks genre preferences after first play.',
    source: 'Baymard Institute',
  },
  {
    name: 'Contextual Help',
    category: 'onboarding',
    description: 'Prefer contextual tooltips and inline hints over modal tutorials. Show help at the moment of need, not upfront.',
    whyItWorks: 'Krug: users don\'t read instructions. NNGroup: contextual help is 3x more effective than upfront tutorials because it arrives at the moment of relevance.',
    example: 'Figma — contextual tooltips appear on first interaction with each tool.',
    source: 'NNGroup / Steve Krug',
  },

  // --- Trust & Credibility Signals ---
  {
    name: 'Trust Signal Placement',
    category: 'trust',
    description: 'Place trust signals within visual proximity (200px) of the commitment action. Stack trust elements vertically below or beside the CTA button.',
    whyItWorks: 'CXL Institute: trust signals placed near CTAs increase conversions by 11-42%. Proximity creates an implicit association between action and reassurance.',
    example: 'Shopify — trust badges directly below the "Start free trial" button.',
    source: 'CXL Institute',
  },
  {
    name: 'Social Proof by Commitment Level',
    category: 'trust',
    description: 'Match proof type to commitment level: low (user count, logos), medium (testimonials with photos), high (case studies, security badges).',
    whyItWorks: 'Cialdini: proof must be relevant and proportional to the ask. A user count suffices for a newsletter; payment needs explicit security assurance.',
    example: 'Basecamp — named testimonials with photos for signup, generic count for homepage.',
    source: 'Cialdini',
  },
  {
    name: 'Risk Reversal',
    category: 'trust',
    description: 'State the guarantee explicitly near the payment CTA: "30-day money-back guarantee", "Cancel anytime", "No credit card required".',
    whyItWorks: 'Risk reversal is the #1 conversion lever for SaaS. Baymard: 18% of users abandon checkout due to unclear return/refund policy.',
    example: 'Basecamp — "Cancel anytime. No questions asked." directly below CTA.',
    source: 'Baymard Institute / Pedro Cortes',
  },
  {
    name: 'Security Indicators',
    category: 'trust',
    description: 'Show lock icon + "Secure" text near sensitive fields. Display SSL/encryption badges near payment forms. Show "Your data is encrypted" near data collection.',
    whyItWorks: 'Baymard: 18% of users abandon checkout due to security concerns. Visual security indicators reduce perceived risk even when underlying security is identical.',
    example: 'Stripe Checkout — lock icon and "Powered by Stripe" near card fields.',
    source: 'Baymard Institute',
  },
  {
    name: 'Transparency Patterns',
    category: 'trust',
    description: 'Show pricing without hidden fees. Display data usage clearly. Provide easy access to privacy policy. Show "what we do with your data" summaries near data collection.',
    whyItWorks: 'NNGroup: transparency builds long-term trust. Users who understand what happens with their data are 2x more likely to complete forms.',
    example: 'Apple — plain-language privacy labels on every product page.',
    source: 'NNGroup',
  },

  // --- Pricing & Payment ---
  {
    name: 'Three-Tier Structure',
    category: 'pricing',
    description: 'Offer exactly 3 tiers. The middle tier should be the target. Include a clear feature comparison table below tier cards.',
    whyItWorks: 'Decoy effect (Dan Ariely): the lowest tier makes the middle look better value. Three options satisfy comparison shoppers without choice paralysis.',
    example: 'Vercel — Hobby / Pro / Enterprise. Pro is visually highlighted.',
    source: 'Dan Ariely / CXL Institute',
  },
  {
    name: 'Recommended Tier Highlighting',
    category: 'pricing',
    description: 'Visually distinguish the recommended tier: "Most Popular" badge, contrasting border, optionally scaled larger. Place in center position.',
    whyItWorks: 'Von Restorff isolation effect — visually distinct items receive disproportionate attention. Center position bias (Rodway et al.): people prefer center-positioned items.',
    example: 'GitHub — Pro plan has "Most popular" badge and distinct border.',
    source: 'Von Restorff Effect',
  },
  {
    name: 'Annual/Monthly Toggle',
    category: 'pricing',
    description: 'Show both billing options with a toggle. Display savings percentage for annual. Default to annual to anchor on the lower per-month price.',
    whyItWorks: 'Anchoring effect — seeing the annual price first makes monthly feel expensive. Showing savings as percentage is more persuasive for lower price points (CXL).',
    example: 'Notion — toggle defaults to annual, shows "Save 20%" badge.',
    source: 'CXL Institute',
  },
  {
    name: 'Trust Signals Near Payment',
    category: 'pricing',
    description: 'Place security badges, guarantee text, and payment provider logos directly adjacent to payment form fields.',
    whyItWorks: 'Baymard: 17% of users have abandoned a checkout in the last 3 months solely due to not trusting the site with credit card info.',
    example: 'Stripe — "Powered by Stripe" badge and lock icon inline with card fields.',
    source: 'Baymard Institute',
  },

  // --- Empty States & First Use ---
  {
    name: 'Value Explanation',
    category: 'empty-states',
    description: 'Never show a blank page. Show: illustration/icon, brief explanation of what will appear, and a primary action button to create the first item.',
    whyItWorks: 'Krug: blank screens create uncertainty — users don\'t know if it\'s broken or empty. Guided empty states increase feature adoption by 25% (Chameleon).',
    example: 'Notion — empty page shows "Press Enter to start writing" with template suggestions.',
    source: 'Steve Krug / Chameleon',
  },
  {
    name: 'Guided First Action',
    category: 'empty-states',
    description: 'Make the first-action CTA the most prominent element on the page. Use primary button, large size. Pre-fill or scaffold the first item to reduce effort.',
    whyItWorks: 'Fogg Behavior Model: B = MAP (Behavior = Motivation + Ability + Prompt). The empty state IS the prompt — make the action easy and obvious.',
    example: 'Trello — empty board shows "Add a list" prompt, pre-creates a starter list.',
    source: 'Fogg Behavior Model',
  },
  {
    name: 'Sample Data',
    category: 'empty-states',
    description: 'Show realistic sample data with a "This is sample data" banner for features where value is hard to visualize (dashboards, analytics, reports).',
    whyItWorks: 'NNGroup: users understand features 3x faster with real-looking data. Removes the chicken-and-egg problem of needing data to see value.',
    example: 'Plausible Analytics — shows demo dashboard with real traffic data before signup.',
    source: 'NNGroup',
  },

  // --- Retention & Engagement ---
  {
    name: 'Habit Loops',
    category: 'retention',
    description: 'Design for Cue, Routine, Reward. Make the trigger visible (badge, counter), the action effortless (one-click), and the reward immediate (progress, confirmation).',
    whyItWorks: 'Nir Eyal\'s Hook Model. Products with daily habits have 2.5x higher retention (Mixpanel benchmark).',
    example: 'Duolingo — streak counter (cue), daily lesson (routine), XP animation (reward).',
    source: 'Nir Eyal / Mixpanel',
  },
  {
    name: 'Progress Mechanics',
    category: 'retention',
    description: 'Show progress visually (bar, step counter, checklist). Use the endowed progress effect: start the bar at 20% instead of 0%.',
    whyItWorks: 'Endowed progress effect (Nunes & Dreze): artificial advancement increases persistence. Progress bars increase completion by 40% (CXL).',
    example: 'LinkedIn — profile completeness bar starts at 25% (photo counts as progress).',
    source: 'Nunes & Dreze / CXL Institute',
  },
  {
    name: 'Re-engagement',
    category: 'retention',
    description: 'Design re-entry points that show what changed since last visit. Use "Welcome back" state with new content or pending items, not a stale page.',
    whyItWorks: 'NNGroup: returning users need context restoration, not repetition. Showing "what\'s new" reduces re-learning friction and creates curiosity.',
    example: 'GitHub — "You missed X notifications" on return, not a blank dashboard.',
    source: 'NNGroup',
  },
  {
    name: 'Streak/Progress Mechanics',
    category: 'retention',
    description: 'Track consecutive usage streaks. Show streak count prominently. Use loss aversion to motivate continued engagement ("Don\'t break your streak!").',
    whyItWorks: 'Loss aversion (Kahneman & Tversky): losing a streak hurts 2x more than gaining a new one feels good. Streaks increase daily active usage by 30-50%.',
    example: 'Duolingo — streak freeze mechanic and streak celebration animations.',
    source: 'Kahneman & Tversky',
  },
  {
    name: 'Variable Rewards',
    category: 'retention',
    description: 'Introduce unpredictability in rewards — random achievements, surprise bonuses, or varied content. Avoid making every reward predictable.',
    whyItWorks: 'Variable ratio reinforcement schedule (Skinner): unpredictable rewards create the strongest behavioral patterns. Used ethically, it drives exploration.',
    example: 'Product Hunt — daily featured products create a variable reward for returning.',
    source: 'B.F. Skinner / Nir Eyal',
  },

  // --- Navigation & Information Architecture ---
  {
    name: '5-7 Navigation Items',
    category: 'navigation',
    description: 'Limit top-level navigation to 5-7 items. Group secondary items under parents. Audit items that can move to settings or contextual menus.',
    whyItWorks: 'Miller\'s Law — working memory holds 7±2 items. NNGroup: navigation with 5-7 items has the fastest task completion times.',
    example: 'Linear — 6 top-level nav items, everything else in contextual menus.',
    source: 'Miller\'s Law / NNGroup',
  },
  {
    name: 'Trunk Test',
    category: 'navigation',
    description: 'If a user lands on any page without context, can they identify: what site, what page, main sections, what to do? If unclear, improve navigation cues.',
    whyItWorks: 'Krug\'s "Don\'t Make Me Think" — users arrive from search, links, and bookmarks. Every page must be self-orienting.',
    example: 'Every page has: logo (identity), breadcrumb or title (location), persistent nav (sections).',
    source: 'Steve Krug',
  },
  {
    name: 'F-Pattern Scanning',
    category: 'navigation',
    description: 'Place the most important content top-left. Use strong left-aligned headings. Place CTAs in the natural scan path.',
    whyItWorks: 'NNGroup eye-tracking: users scan in an F-pattern. Content outside this pattern gets 60% less attention.',
    example: 'Medium articles — title and author at top-left, content follows the F-pattern.',
    source: 'NNGroup',
  },
  {
    name: 'Persistent Navigation',
    category: 'navigation',
    description: 'Keep primary navigation visible across all pages. Don\'t hide navigation behind hamburger menus on desktop. Mobile: use bottom tab bar or hamburger.',
    whyItWorks: 'NNGroup: hidden navigation reduces content discoverability by 21%. Users can\'t navigate to what they can\'t see.',
    example: 'Slack — persistent sidebar on desktop, bottom tab bar on mobile.',
    source: 'NNGroup',
  },
  {
    name: 'Breadcrumbs for Depth',
    category: 'navigation',
    description: 'Add breadcrumbs when navigation hierarchy exceeds 2 levels. Show the full path. Make each level clickable.',
    whyItWorks: 'Baymard: breadcrumbs reduce back-button usage by 25% and help users understand site structure. Essential for e-commerce and content-heavy sites.',
    example: 'Amazon — breadcrumb trail on every product page showing category hierarchy.',
    source: 'Baymard Institute',
  },

  // --- Feedback & Completion ---
  {
    name: 'Peak-End Rule',
    category: 'feedback',
    description: 'Design the peak moment and ending of multi-step flows to be emotionally positive. Use animations and congratulatory copy at completion.',
    whyItWorks: 'Kahneman\'s Peak-End Rule: people judge experiences by peak intensity and ending, not the average. A great completion moment colors the entire experience.',
    example: 'Stripe — successful payment shows a satisfying checkmark animation.',
    source: 'Daniel Kahneman',
  },
  {
    name: 'Success Celebrations',
    category: 'feedback',
    description: 'Minor actions: toast with checkmark. Major milestones: full-screen moment with animation, congratulatory copy, and next-step suggestion.',
    whyItWorks: 'Positive feedback after action strengthens the habit loop (Fogg). Dopamine release from visual reward increases likelihood of repeat behavior.',
    example: 'Duolingo — lesson complete shows confetti + XP animation + streak update.',
    source: 'B.J. Fogg',
  },
  {
    name: 'Next-Step Suggestions',
    category: 'feedback',
    description: 'After any completed action, suggest the logical next action. Never show a dead-end success screen.',
    whyItWorks: 'Zeigarnik effect — people remember incomplete tasks. Providing the next step keeps momentum and reduces drop-off between features.',
    example: 'Notion — after creating a page, suggests adding content blocks or sharing.',
    source: 'Zeigarnik Effect',
  },
  {
    name: 'Progress Indicators',
    category: 'feedback',
    description: 'Show a step indicator at the top of multi-step processes. Show current step, completed steps, and remaining steps.',
    whyItWorks: 'NNGroup: progress indicators reduce abandonment by up to 28% in multi-step forms. Users need to know how much effort remains.',
    example: 'Stripe Checkout — step indicator shows "Shipping → Payment → Review".',
    source: 'NNGroup',
  },
  {
    name: 'Micro-interactions',
    category: 'feedback',
    description: 'Add subtle animations for state changes: button press feedback, toggle transitions, loading spinners, hover effects. Keep animations under 300ms.',
    whyItWorks: 'NNGroup: micro-interactions create a sense of direct manipulation and responsiveness. Users perceive animated interfaces as 20% faster than static ones.',
    example: 'iOS toggle switch — smooth animation with haptic feedback on state change.',
    source: 'NNGroup',
  },
];
