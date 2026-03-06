export interface PatternRef {
  name: string;
  page: string;
  anchor: string;
}

export interface PageZone {
  name: string;
  required: boolean;
  purpose: string;
  patternRefs: PatternRef[];
  placement: string;
}

export interface PageVariation {
  name: string;
  description: string;
}

export interface PageMistake {
  mistake: string;
  fix: string;
}

export interface PageCompositionGuide {
  name: string;
  category: 'conversion' | 'content' | 'commerce' | 'trust' | 'utility';
  purpose: string;
  essentialZones: PageZone[];
  recommendedZones: PageZone[];
  research: string;
  mistakes: PageMistake[];
  variations: PageVariation[];
  source: string;
}

export const categoryLabels: Record<PageCompositionGuide['category'], string> = {
  conversion: 'Conversion Pages',
  content: 'Content Pages',
  commerce: 'Commerce Pages',
  trust: 'Trust & Company Pages',
  utility: 'Utility Pages',
};

export const categoryOrder: PageCompositionGuide['category'][] = [
  'conversion', 'content', 'commerce', 'trust', 'utility',
];

function anchor(name: string): string {
  return name.toLowerCase().replace(/[\s\/()&+@"=.,:']+/g, '-').replace(/-+/g, '-').replace(/-$/, '');
}

function ref(name: string, page: string): PatternRef {
  return { name, page, anchor: anchor(name) };
}

export const pageCompositionGuides: PageCompositionGuide[] = [

  // ═══════════════════════════════════════════
  // CONVERSION PAGES
  // ═══════════════════════════════════════════

  {
    name: 'Landing Page',
    category: 'conversion',
    purpose: 'Convert visitor attention into a single, specific action by presenting a focused value proposition, removing decision friction, and building trust before the page ends.',
    essentialZones: [
      {
        name: 'Hero Section',
        required: true,
        purpose: 'Answers what this is, what the visitor can do, and why they should care — with the primary CTA above the fold.',
        placement: 'Top of page, entirely visible without scrolling',
        patternRefs: [
          ref('Hero Section Formula', 'business-patterns'),
          ref('Above-the-Fold Framework', 'business-patterns'),
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Open Graph Tags', 'seo-patterns'),
          ref('Fade', 'animation-patterns'),
        ],
      },
      {
        name: 'Social Proof Bar',
        required: true,
        purpose: 'Provides instant credibility by showing recognizable customer logos before the visitor scrolls into deeper content.',
        placement: 'Directly below the hero section',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Trust Signal Placement', 'business-patterns'),
          ref('Lazy Loading Media', 'media-patterns'),
        ],
      },
      {
        name: 'Problem Statement',
        required: true,
        purpose: 'Names the pain the visitor recognizes in themselves, creating the emotional hook that makes the solution feel personally relevant.',
        placement: 'After the social proof bar, before features',
        patternRefs: [
          ref('Hero Section Formula', 'business-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
        ],
      },
      {
        name: 'Feature Showcase',
        required: true,
        purpose: 'Translates capabilities into visitor-centric outcomes — what changes in their life, not product specifications.',
        placement: 'Mid-page, after the problem statement',
        patternRefs: [
          ref('F-Pattern Scanning', 'business-patterns'),
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
          ref('Staggered List', 'animation-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
        ],
      },
      {
        name: 'Testimonials',
        required: true,
        purpose: 'Provides specific, attributed third-party validation that shifts the visitor from "sounds good" to "works for people like me."',
        placement: 'After features, before the final CTA',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Social Proof by Commitment Level', 'business-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
        ],
      },
      {
        name: 'Primary Conversion Zone',
        required: true,
        purpose: 'Delivers the commitment action — signup, trial, or purchase — surrounded by risk-reversing trust signals.',
        placement: 'After testimonials; repeated at bottom on long pages',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Risk Reversal', 'business-patterns'),
          ref('Trust Signal Placement', 'business-patterns'),
          ref('Form', 'form-patterns'),
          ref('Hover Feedback', 'animation-patterns'),
          ref('Press Feedback', 'animation-patterns'),
        ],
      },
    ],
    recommendedZones: [
      {
        name: 'How It Works',
        required: false,
        purpose: 'Makes the path from signup to value visible and short, reducing cognitive friction for products with non-obvious workflows.',
        placement: 'Between problem statement and features',
        patternRefs: [
          ref('Activation Moment', 'business-patterns'),
          ref('Staggered List', 'animation-patterns'),
          ref('HowTo Schema', 'seo-patterns'),
        ],
      },
      {
        name: 'FAQ Section',
        required: false,
        purpose: 'Eliminates final friction by addressing security, cancellation, and compatibility concerns at the decision point.',
        placement: 'Above the final CTA',
        patternRefs: [
          ref('FAQ Structure', 'business-patterns'),
          ref('FAQ Schema', 'seo-patterns'),
          ref('Collapse', 'animation-patterns'),
        ],
      },
      {
        name: 'Product Demo',
        required: false,
        purpose: 'Provides a visceral preview of the product in use — especially effective when the UI itself is the primary selling point.',
        placement: 'Within or after the hero section',
        patternRefs: [
          ref('Video Embed', 'media-patterns'),
          ref('Video Player Controls', 'media-patterns'),
          ref('Shimmer Loading', 'animation-patterns'),
        ],
      },
    ],
    research: 'NNGroup eye-tracking across 57,453 fixations shows users spend 57% of page-viewing time above the fold. Landing pages with social proof convert 34% better than those without (Unbounce 2024, 41,000+ pages). Baymard Institute finds 21% of users abandon due to unanswered questions about security, pricing, or cancellation.',
    mistakes: [
      {
        mistake: 'Headline leads with a feature ("Advanced analytics dashboard") instead of an outcome',
        fix: 'Rewrite as the transformation: "Know exactly why users drop off, in under a minute." Features belong in the feature showcase, not the hero.',
      },
      {
        mistake: 'Social proof placed only in the footer where high-intent visitors never see it',
        fix: 'Place a logo rail below the hero and at least one attributed testimonial within 300px of the primary CTA.',
      },
      {
        mistake: 'Full site navigation with dropdowns gives visitors 12 escape routes before they understand the value',
        fix: 'Strip nav to logo + single ghost CTA. Conversion pages are not discovery pages.',
      },
      {
        mistake: 'Wall of text with no visual hierarchy forces everyone to read everything before orienting',
        fix: 'Alternate full-width narrative and grid layouts. Use section headers that are scannable standalone sentences.',
      },
    ],
    variations: [
      {
        name: 'Short-Form Focused',
        description: 'For high-intent traffic (paid search, retargeting) with low-commitment asks — hero, CTA, logo rail, one social proof element.',
      },
      {
        name: 'Long-Form Narrative',
        description: 'For complex or expensive products — walk through problem, solution, features, proof, pricing, FAQ, and final CTA using scroll-triggered animations.',
      },
      {
        name: 'Problem-Agitate-Solve (PAS)',
        description: 'Open with the problem, agitate with consequences, introduce the product as the fix — used by Basecamp and early Shopify.',
      },
    ],
    source: 'NNGroup, Baymard Institute, CXL Institute, Unbounce 2024 Benchmark',
  },

  {
    name: 'Pricing Page',
    category: 'conversion',
    purpose: 'Convert evaluation-stage prospects into paying customers by resolving value uncertainty, pre-empting purchase objections, and guiding visitors toward the plan that best fits their use case.',
    essentialZones: [
      {
        name: 'Value Hook Header',
        required: true,
        purpose: 'Anchors context — confirms the visitor is on the right page and restates the core value proposition.',
        placement: 'Above the fold, before plan cards',
        patternRefs: [
          ref('Hero Section Formula', 'business-patterns'),
          ref('Above-the-Fold Framework', 'business-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Meta Description', 'seo-patterns'),
        ],
      },
      {
        name: 'Plan Comparison Cards',
        required: true,
        purpose: 'Presents the structured choice set — plan names, prices, and key differentiators — enabling self-selection without a sales conversation.',
        placement: 'Primary viewport, dominant page element',
        patternRefs: [
          ref('Three-Tier Structure', 'business-patterns'),
          ref('Recommended Tier Highlighting', 'business-patterns'),
          ref('Pricing Page Psychology', 'business-patterns'),
          ref('Annual/Monthly Toggle', 'business-patterns'),
          ref('Hover Feedback', 'animation-patterns'),
        ],
      },
      {
        name: 'CTA per Plan',
        required: true,
        purpose: 'Provides a distinct, unambiguous action for each plan so visitors can act at peak intent.',
        placement: 'Inside each plan card, below the price',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Risk Reversal', 'business-patterns'),
          ref('Press Feedback', 'animation-patterns'),
        ],
      },
      {
        name: 'Trust Signals Bar',
        required: true,
        purpose: 'Reduces purchase anxiety by showing customer logos, security badges, and ratings at the commitment moment.',
        placement: 'Below the value hook, above or between plan cards',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Trust Signal Placement', 'business-patterns'),
          ref('Security Indicators', 'business-patterns'),
          ref('Trust Signals Near Payment', 'business-patterns'),
        ],
      },
      {
        name: 'Objection-Handling FAQ',
        required: true,
        purpose: 'Eliminates common non-conversion reasons — cancellation, data security, seat definitions — without requiring support contact.',
        placement: 'Below plan cards, above footer',
        patternRefs: [
          ref('FAQ Structure', 'business-patterns'),
          ref('Transparency Patterns', 'business-patterns'),
          ref('FAQ Schema', 'seo-patterns'),
          ref('Collapse', 'animation-patterns'),
        ],
      },
    ],
    recommendedZones: [
      {
        name: 'Feature Comparison Table',
        required: false,
        purpose: 'Serves power users and evaluation committees who need to verify specific capability availability.',
        placement: 'Below plan cards, expandable or anchored via "Compare all features"',
        patternRefs: [
          ref('Pricing Page Psychology', 'business-patterns'),
          ref('Transparency Patterns', 'business-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
        ],
      },
      {
        name: 'Enterprise Tier CTA',
        required: false,
        purpose: 'Captures high-value prospects who need custom contracts, SSO, or procurement workflows.',
        placement: 'Fourth column or standalone band below plan cards',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Authority Signals', 'business-patterns'),
          ref('Multi-Step Form', 'form-patterns'),
        ],
      },
      {
        name: 'Tier-Matched Testimonials',
        required: false,
        purpose: 'Provides social validation contextually relevant to each plan tier.',
        placement: 'Between plan cards and FAQ',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Social Proof by Commitment Level', 'business-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
        ],
      },
    ],
    research: 'CXL Institute A/B testing shows highlighting the recommended plan with a "Most Popular" badge increases selection by 25–40%. Dan Ariely\'s decoy research demonstrates adding a third tier increases midrange selection by up to 85%. Baymard finds 21% abandon when key questions go unanswered; a visible 30-day guarantee lifts paid conversions by 21%.',
    mistakes: [
      {
        mistake: 'More than four plan tiers creating decision paralysis',
        fix: 'Limit to three named tiers (Good/Better/Best) plus one enterprise contact row. Hick\'s Law and Baymard studies confirm 4+ options increase abandonment.',
      },
      {
        mistake: 'Hiding prices behind "Contact Sales" for all tiers, even self-serve segments',
        fix: 'Show transparent pricing for all self-serve plans. Reserve "Contact Sales" for the enterprise tier where procurement complexity justifies it.',
      },
      {
        mistake: 'Feature comparison table buried with no anchor link from plan cards',
        fix: 'Add a visible "Compare all features" link inside each plan card that deep-links to the comparison table.',
      },
      {
        mistake: 'Trust signals and security badges placed only in the site footer, far from CTAs',
        fix: 'Place at least one trust signal within one viewport of each plan card\'s CTA button.',
      },
    ],
    variations: [
      {
        name: 'Card-First (Self-Serve SaaS)',
        description: 'Lead with plan cards above the fold — no hero preamble. For high-intent branded traffic (Linear, Vercel, GitHub).',
      },
      {
        name: 'Value-First (Horizontal Funnel)',
        description: 'Open with benefit headline and trust bar before plan cards. For pricing pages that also serve cold search traffic (Notion, Shopify).',
      },
      {
        name: 'Segment-Gated (Persona Routing)',
        description: 'Show Individual/Team/Enterprise selector before revealing plans. For products with significantly different feature sets per segment (Stripe, Salesforce).',
      },
    ],
    source: 'CXL Institute, Dan Ariely, Baymard Institute, NNGroup',
  },

  {
    name: 'Product / Service Detail',
    category: 'conversion',
    purpose: 'Give visitors the precise information, trust signals, and decision-making context to confidently add to cart, start a trial, or contact sales — without seeking information elsewhere.',
    essentialZones: [
      {
        name: 'Product Hero / Buy Box',
        required: true,
        purpose: 'Establishes what the product is, what it costs, and what the primary action is — above the fold.',
        placement: 'Top of page. Desktop: image gallery left, buy box right. Mobile: image stack top, buy box below.',
        patternRefs: [
          ref('Hero Section Formula', 'business-patterns'),
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Product Schema', 'seo-patterns'),
          ref('Responsive Images', 'media-patterns'),
        ],
      },
      {
        name: 'Social Proof Band',
        required: true,
        purpose: 'Surfaces star ratings, review count, or user count immediately adjacent to the primary CTA to reduce purchase hesitation.',
        placement: 'Within or directly below the buy box',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Trust Signal Placement', 'business-patterns'),
        ],
      },
      {
        name: 'Media Gallery',
        required: true,
        purpose: 'Answers visual questions text cannot — scale, finish, context of use — reducing uncertainty that causes abandonment.',
        placement: 'Left column on desktop, full-width carousel on mobile. Thumbnails always visible.',
        patternRefs: [
          ref('Image Gallery Grid', 'media-patterns'),
          ref('Image Zoom', 'media-patterns'),
          ref('Responsive Images', 'media-patterns'),
          ref('Shimmer Loading', 'animation-patterns'),
        ],
      },
      {
        name: 'Feature Summary',
        required: true,
        purpose: 'Communicates what the product does in scannable form, answering "Is this right for me?" without walls of prose.',
        placement: 'Below buy box on desktop, below media on mobile',
        patternRefs: [
          ref('Hero Section Formula', 'business-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
        ],
      },
      {
        name: 'Trust & Reassurance Zone',
        required: true,
        purpose: 'Neutralizes top purchase objections (returns, security, delivery) at the moment of decision.',
        placement: 'Within or directly below the buy box, adjacent to the primary CTA',
        patternRefs: [
          ref('Trust Signal Placement', 'business-patterns'),
          ref('Risk Reversal', 'business-patterns'),
          ref('Security Indicators', 'business-patterns'),
        ],
      },
      {
        name: 'Customer Reviews',
        required: true,
        purpose: 'Provides peer validation with sortable, filterable specificity — users find reviews from people like themselves.',
        placement: 'Below specifications. Show aggregate rating summary with star histogram.',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Social Proof by Commitment Level', 'business-patterns'),
        ],
      },
    ],
    recommendedZones: [
      {
        name: 'Detailed Specifications',
        required: false,
        purpose: 'Serves late-stage evaluators who need precise technical details to make a final decision.',
        placement: 'Below hero zone as collapsed accordion sections — never horizontal tabs (27% miss rate per Baymard)',
        patternRefs: [
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Collapse', 'animation-patterns'),
        ],
      },
      {
        name: 'Feature Deep-Dive Sections',
        required: false,
        purpose: 'Shows each major feature in context with visuals and use cases for users who need more than bullets.',
        placement: 'Below initial description, alternating image-text layout',
        patternRefs: [
          ref('Scroll Reveal', 'animation-patterns'),
          ref('Image Gallery Grid', 'media-patterns'),
        ],
      },
      {
        name: 'FAQ / Objection Handler',
        required: false,
        purpose: 'Pre-empts buying objections with direct answers, reducing support load and abandonment.',
        placement: 'After reviews, before cross-sells',
        patternRefs: [
          ref('FAQ Structure', 'business-patterns'),
          ref('FAQ Schema', 'seo-patterns'),
          ref('Collapse', 'animation-patterns'),
        ],
      },
      {
        name: 'Cross-Sell / Related Products',
        required: false,
        purpose: 'Captures users who didn\'t convert on the primary product and increases average order value for those who did.',
        placement: 'After reviews — never before the buy box',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Lazy Loading Media', 'media-patterns'),
        ],
      },
    ],
    research: 'Baymard Institute\'s 236-subject study found 82% of e-commerce sites have mediocre-to-poor product page UX. Products with 50+ reviews convert at 4.6x the rate of those with none (Spiegel Research). 56% of users\' first action on a product page is exploring the image gallery.',
    mistakes: [
      {
        mistake: 'Using horizontal tabs to organize specs, FAQs, and reviews',
        fix: 'Replace with vertically collapsed accordions or a sticky TOC long page. 27% of users overlook horizontal tab content (Baymard).',
      },
      {
        mistake: 'Trust signals (guarantee, return policy, secure checkout) placed only in footer',
        fix: 'Move trust signals into or directly below the buy box, within the same visual container as the CTA button.',
      },
      {
        mistake: 'Truncating the image gallery to 1–2 images with no visible thumbnails',
        fix: 'Always show thumbnail navigation. Truncating causes 50–80% of users to overlook additional images.',
      },
      {
        mistake: 'Cross-sell carousels placed before or within the primary buy zone',
        fix: 'Place all cross-sells after reviews and FAQ. The primary conversion path must be unobstructed.',
      },
    ],
    variations: [
      {
        name: 'Buy-Box Split Layout',
        description: 'Two-column desktop layout (media left, buy box right) for physical or visible-deliverable products — the highest-performing layout per Baymard benchmarks.',
      },
      {
        name: 'Hero + Feature Scroll (SaaS)',
        description: 'Single-column long page with hero screenshot, social proof, alternating feature sections, pricing, FAQ — for software products (Stripe, Linear, Vercel).',
      },
      {
        name: 'Long Page with Sticky TOC',
        description: 'Full-width sections with persistent table-of-contents navigation for complex/technical products where users jump between specs and comparisons (Apple Mac Pro).',
      },
    ],
    source: 'Baymard Institute, NNGroup, CXL Institute, Spiegel Research Center',
  },

  // ═══════════════════════════════════════════
  // CONTENT PAGES
  // ═══════════════════════════════════════════

  {
    name: 'Blog / Article',
    category: 'content',
    purpose: 'Deliver long-form content to readers with specific information needs while establishing authority, maximizing engagement, and converting engaged readers into subscribers or leads.',
    essentialZones: [
      {
        name: 'Article Header',
        required: true,
        purpose: 'Establishes the topic, author credibility, and time investment before the reader commits to scrolling.',
        placement: 'Full-width top of page, above body text',
        patternRefs: [
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Open Graph Tags', 'seo-patterns'),
          ref('Article Schema', 'seo-patterns'),
          ref('Authority Signals', 'business-patterns'),
          ref('Responsive Images', 'media-patterns'),
        ],
      },
      {
        name: 'Reading Context Strip',
        required: true,
        purpose: 'Sets reader expectations with category, reading time, and publish date — reduces bounce from uncertain visitors.',
        placement: 'Below headline, before body copy. Single horizontal row.',
        patternRefs: [
          ref('Article Schema', 'seo-patterns'),
          ref('BreadcrumbList Schema', 'seo-patterns'),
          ref('Progress Indicators', 'business-patterns'),
        ],
      },
      {
        name: 'Article Body',
        required: true,
        purpose: 'Delivers the content in a scannable, comprehension-optimized format respecting F-shaped and layer-cake scanning patterns.',
        placement: 'Center column, 60–75ch line width',
        patternRefs: [
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('F-Pattern Scanning', 'business-patterns'),
          ref('Image Gallery Grid', 'media-patterns'),
        ],
      },
      {
        name: 'Author Attribution',
        required: true,
        purpose: 'Provides E-E-A-T signals (Experience, Expertise, Authoritativeness, Trustworthiness) required by both readers and Google quality raters.',
        placement: 'After article body, before related content',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Article Schema', 'seo-patterns'),
        ],
      },
      {
        name: 'In-Article Conversion CTA',
        required: true,
        purpose: 'Captures highest-intent readers at peak relevance. Inline contextual CTAs convert 121% higher than banner CTAs (HubSpot).',
        placement: 'End of article (primary), optionally mid-article at ~50–60% scroll depth',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Form', 'form-patterns'),
          ref('Fade', 'animation-patterns'),
        ],
      },
    ],
    recommendedZones: [
      {
        name: 'Sticky Table of Contents',
        required: false,
        purpose: 'Gives readers a persistent mental map and allows non-linear navigation through long articles.',
        placement: 'Left sidebar on wide viewports, collapsible block on mobile',
        patternRefs: [
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Progress Indicators', 'business-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
        ],
      },
      {
        name: 'Social Sharing Bar',
        required: false,
        purpose: 'Reduces friction for readers who want to share by surfacing platform-specific share actions.',
        placement: 'Floating left sidebar on wide viewports, static block at top/bottom on narrow',
        patternRefs: [
          ref('Open Graph Tags', 'seo-patterns'),
          ref('Canonical URL Tag', 'seo-patterns'),
        ],
      },
      {
        name: 'Related Articles',
        required: false,
        purpose: 'Reduces exit rate and deepens topic authority by routing engaged readers to semantically related content.',
        placement: 'Below author block and primary CTA, before footer',
        patternRefs: [
          ref('Internal Linking Strategy', 'seo-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
          ref('Responsive Images', 'media-patterns'),
        ],
      },
      {
        name: 'Reading Progress Indicator',
        required: false,
        purpose: 'Provides continuous visual orientation for long-form articles, encouraging completion over abandonment.',
        placement: 'Thin progress bar fixed to top of viewport',
        patternRefs: [
          ref('Progress Indicators', 'business-patterns'),
        ],
      },
    ],
    research: 'NNGroup eyetracking finds content above the fold receives 57% of viewing time, each subsequent screen getting ~33% less attention. Adding estimated reading time increases engagement by up to 40% (Simpleview) and time on site by 13.8%. Layer-cake scanning means subheadings determine whether body content gets read at all.',
    mistakes: [
      {
        mistake: 'No author identity — publishing under "Admin" or with no byline removes all E-E-A-T signals',
        fix: 'Every article needs a named author with photo, role, and link to an author page. Include Person schema in Article structured data.',
      },
      {
        mistake: 'Wall of text with no subheadings, pull quotes, or whitespace',
        fix: 'H2/H3 every 200–300 words, opening sentences that stand alone as scannable summaries, bullets for lists, 65–75ch max paragraph width.',
      },
      {
        mistake: 'Newsletter CTA placed only in sidebar or at very bottom of page',
        fix: 'Use two placements: one inline CTA after section 2–3, and one end-of-article CTA. Limit to 1–2 total to avoid overload.',
      },
      {
        mistake: 'Missing Article structured data (no datePublished, dateModified, or author Person)',
        fix: 'Implement full Article JSON-LD with headline, image, dates, author (Person + sameAs), publisher, and wordCount.',
      },
    ],
    variations: [
      {
        name: 'Distraction-Free Reading',
        description: 'Removes sidebar nav, collapses header on scroll, centers text in a narrow column — for publications where completion rate is the metric (Medium, Substack).',
      },
      {
        name: 'Technical / Developer Blog',
        description: 'Prioritizes syntax-highlighted code blocks, persistent sticky TOC, wide code column, and "copy to clipboard" — for audiences scanning for implementation details (Vercel Blog, Stripe Blog).',
      },
      {
        name: 'Commercial Content Marketing',
        description: 'Multiple inline CTAs for gated assets, right sidebar offers, sticky bottom bar CTA — for high-traffic informational articles where lead generation is the goal (HubSpot, CXL).',
      },
    ],
    source: 'NNGroup, Simpleview, HubSpot, CXL Institute',
  },

  // ═══════════════════════════════════════════
  // TRUST & COMPANY PAGES
  // ═══════════════════════════════════════════

  {
    name: 'About / Team',
    category: 'trust',
    purpose: 'Convert skeptical evaluators into confident buyers by establishing organizational credibility, humanizing the people behind the product, and proving the company can be trusted.',
    essentialZones: [
      {
        name: 'Company Story',
        required: true,
        purpose: 'Answers "why does this company exist?" and creates an emotional hook that builds rapid trust through shared values.',
        placement: 'First section below the hero statement',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Heading Hierarchy', 'seo-patterns'),
          ref('Organization Schema', 'seo-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
        ],
      },
      {
        name: 'Mission & Values',
        required: true,
        purpose: 'Lets evaluators self-select — visitors who align with stated values self-qualify as better-fit customers.',
        placement: 'Below or integrated into the company story',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Organization Schema', 'seo-patterns'),
          ref('Staggered List', 'animation-patterns'),
        ],
      },
      {
        name: 'Traction Stats',
        required: true,
        purpose: 'Establishes proof-of-scale with specific, credible numbers that answer the implicit "are you for real?" question.',
        placement: 'Horizontal strip below hero/mission or as a divider between story and team',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Authority Signals', 'business-patterns'),
          ref('Organization Schema', 'seo-patterns'),
        ],
      },
      {
        name: 'Team Grid',
        required: true,
        purpose: 'Humanizes the organization — faces reduce perceived risk of dealing with an abstract entity.',
        placement: 'Below traction metrics. Small teams: show everyone. Large: founders + leadership.',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Staggered List', 'animation-patterns'),
          ref('Responsive Images', 'media-patterns'),
        ],
      },
      {
        name: 'Backer / Partner Logos',
        required: true,
        purpose: 'Third-party institutional validation borrows credibility at zero cost — someone credible already vetted this company.',
        placement: 'Compact logo row below team or in traction area',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Trust Signal Placement', 'business-patterns'),
        ],
      },
      {
        name: 'Closing CTA',
        required: true,
        purpose: 'Captures intent from high-intent evaluators. About page visitors are verifying credibility, not browsing.',
        placement: 'Final section, below all trust content',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Form', 'form-patterns'),
          ref('Fade', 'animation-patterns'),
        ],
      },
    ],
    recommendedZones: [
      {
        name: 'Press Coverage ("As Seen In")',
        required: false,
        purpose: 'Earned media logos signal newsworthiness and third-party validation without the company saying anything about itself.',
        placement: 'Horizontal strip above or below traction metrics',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('Authority Signals', 'business-patterns'),
        ],
      },
      {
        name: 'Company Timeline',
        required: false,
        purpose: 'Demonstrates longevity, momentum, and shipping history — countering "will this company still exist next year?"',
        placement: 'Within or below the company story section',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Scroll Reveal', 'animation-patterns'),
        ],
      },
      {
        name: 'Careers Teaser',
        required: false,
        purpose: 'Signals active growth while capturing talent interest. A growing team is itself a trust signal.',
        placement: 'Near-bottom, before or after closing CTA',
        patternRefs: [
          ref('Social Proof Placement', 'business-patterns'),
          ref('CTA Hierarchy', 'business-patterns'),
        ],
      },
    ],
    research: 'NNGroup finds About page visitors are in credibility-verification mode — they leave quickly if questions go unanswered. CXL research shows trust signals near CTAs increase conversions by 11–42%. Sprout Social data shows 57% of consumers spend more with brands they feel connected to, and 76% choose them over competitors.',
    mistakes: [
      {
        mistake: 'Generic jargon mission statement ("We\'re passionate about empowering teams to reach their potential")',
        fix: 'Replace with concrete specifics — name the problem, the user, and what the company does differently. NNGroup shows users perceive vague language as evasion.',
      },
      {
        mistake: 'Stock photography or overly staged team photos that don\'t show real people',
        fix: 'Use authentic headshots with consistent lighting and background. The fusiform face area triggers automatic attention to faces — fake ones signal inauthenticity.',
      },
      {
        mistake: 'No CTA at the end — treating the About page as a dead end',
        fix: 'Place a contextual CTA at the close (start trial, contact sales, or view careers). About visitors are high-intent evaluators.',
      },
      {
        mistake: 'About page buried in footer navigation, hard to find from primary nav',
        fix: 'Make accessible from primary navigation. It\'s typically a top-5 visited page on B2B/SaaS sites (96% of prospects self-research per HubSpot).',
      },
    ],
    variations: [
      {
        name: 'Founder-Led / Early-Stage',
        description: 'Lead with founder story and personal photo. Team is a single founder bio. Focus on why-I-built-this narrative when the founder\'s credibility is the primary trust asset (<15 people).',
      },
      {
        name: 'Institution / Scale-First',
        description: 'Open with traction stats and customer logos before narrative, then mission and large team grid — for 100+ customer companies where institutional proof outweighs origin story (Linear, Stripe, Notion).',
      },
      {
        name: 'Mission-Centered / Community',
        description: 'Structure around a singular cause or POV with diversity of thought and a values manifesto — for developer tools, open-source, or philosophy-differentiated companies (GitLab, Vercel).',
      },
    ],
    source: 'NNGroup, CXL Institute, Sprout Social, HubSpot',
  },

  {
    name: 'Contact',
    category: 'trust',
    purpose: 'Convert visitor intent into a direct communication channel by providing multiple contact methods, routing to the correct team, and building trust that makes someone willing to reach out.',
    essentialZones: [
      {
        name: 'Channel Selector',
        required: true,
        purpose: 'Routes users to the correct team (Sales, Support, Partnerships) before they reach a form, reducing abandonment and misroutes.',
        placement: 'Top of page, above the fold — never make users scroll to find how to contact you',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Fade', 'animation-patterns'),
        ],
      },
      {
        name: 'Contact Form',
        required: true,
        purpose: 'Captures structured inquiry data and routes it to the right team with validated, actionable information.',
        placement: 'Center of page, below channel selector or conditionally shown after intent selection',
        patternRefs: [
          ref('Form', 'form-patterns'),
          ref('Inline Validation', 'form-patterns'),
          ref('Single-Column Layout', 'form-patterns'),
          ref('Required/Optional Marking', 'form-patterns'),
          ref('Autocomplete Tokens', 'form-patterns'),
          ref('Shimmer Loading', 'animation-patterns'),
        ],
      },
      {
        name: 'Direct Contact Details',
        required: true,
        purpose: 'Provides phone, email, and address for users who distrust forms or whose needs are urgent.',
        placement: 'Sidebar alongside form, or directly above it — never below the fold',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Trust Signal Placement', 'business-patterns'),
          ref('Organization Schema', 'seo-patterns'),
        ],
      },
      {
        name: 'Response Time Expectation',
        required: true,
        purpose: 'Eliminates uncertainty that causes abandonment by stating exactly when and how someone will respond.',
        placement: 'Below or adjacent to the submit button',
        patternRefs: [
          ref('Trust Signal Placement', 'business-patterns'),
          ref('Inline Validation', 'form-patterns'),
        ],
      },
    ],
    recommendedZones: [
      {
        name: 'FAQ / Self-Serve Deflection',
        required: false,
        purpose: 'Resolves common queries before submission, reducing support volume while improving user confidence.',
        placement: 'Below form or in sidebar',
        patternRefs: [
          ref('FAQ Structure', 'business-patterns'),
          ref('FAQ Schema', 'seo-patterns'),
          ref('Collapse', 'animation-patterns'),
        ],
      },
      {
        name: 'Office Location & Map',
        required: false,
        purpose: 'Provides physical legitimacy and supports local SEO for businesses with walk-in locations.',
        placement: 'Lower section, below primary contact form',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Organization Schema', 'seo-patterns'),
        ],
      },
      {
        name: 'Team Presence Signal',
        required: false,
        purpose: 'Humanizes the contact experience by showing who will actually respond, reducing fear of a void.',
        placement: 'Alongside the form',
        patternRefs: [
          ref('Authority Signals', 'business-patterns'),
          ref('Responsive Images', 'media-patterns'),
        ],
      },
      {
        name: 'Meeting Scheduler',
        required: false,
        purpose: 'Lets high-intent visitors book a call immediately without waiting for email response.',
        placement: 'Alternative tab or secondary section when "Talk to Sales" is selected',
        patternRefs: [
          ref('CTA Hierarchy', 'business-patterns'),
          ref('Multi-Step Form', 'form-patterns'),
        ],
      },
    ],
    research: 'NNGroup research across 40 sites found users actively distrust pages with only a form and no phone number — "suspicious" was the word used. Baymard Institute found sites with full validation achieve 78% one-try submissions vs 42% without. CXL shows reducing a form from 11 to 4 fields produces 160% more submissions.',
    mistakes: [
      {
        mistake: 'Form-only page with no phone number, email, or physical address',
        fix: 'Always display direct contact details alongside the form. Removing phone numbers erodes trust (NNGroup). The form supplements real contact, not replaces it.',
      },
      {
        mistake: 'Not setting response time expectations — users submit and hear nothing for days',
        fix: 'State a specific SLA below the submit button ("We respond within 1 business day") and repeat in the confirmation message.',
      },
      {
        mistake: 'Requiring account creation before allowing contact',
        fix: 'Contact access must be unconditional. Account walls on contact pages are a highest-friction failure pattern (NNGroup).',
      },
      {
        mistake: 'Routing all inquiry types to a single generic inbox via one undifferentiated form',
        fix: 'Implement a channel selector or intent router at the top (Sales / Support / Press). Card-based routing directs to the appropriate team and form variant.',
      },
    ],
    variations: [
      {
        name: 'Single-Form with Channel Dropdown',
        description: 'One form with a "What can we help with?" dropdown that conditionally reveals fields — best for small teams or low contact volume.',
      },
      {
        name: 'Intent Card Router (Multi-Path)',
        description: 'Grid of labeled cards (Sales, Support, Press) each linking to a distinct form — best for B2B SaaS with distinct personas and routing (Calendly, Stripe, HubSpot).',
      },
      {
        name: 'Embedded Scheduler with Qualification',
        description: 'Minimal 3-field form that reveals a calendar embed on completion — best for sales pages where the goal is booking demos (reduces time-to-meeting from days to seconds).',
      },
    ],
    source: 'NNGroup, Baymard Institute, CXL Institute, Smashing Magazine',
  },
];
