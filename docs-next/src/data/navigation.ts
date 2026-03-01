export interface NavLink {
  title: string;
  slug: string;
}

export interface NavGroup {
  label: string;
  collapsed?: boolean;
  links: NavLink[];
}

export const navigation: NavGroup[] = [
  {
    label: 'Intro',
    links: [
      { title: 'Why VibeCrew', slug: 'why' },
      { title: 'Comparison', slug: 'comparison' },
    ],
  },
  {
    label: 'Getting Started',
    links: [
      { title: 'Quick Start', slug: 'quick-start' },
      { title: 'Setup', slug: 'setup' },
      { title: 'New Project', slug: 'new-project' },
      { title: 'Design Discovery', slug: 'design-discovery' },
      { title: 'Existing Project', slug: 'existing-project' },
      { title: 'Warp', slug: 'warp' },
    ],
  },
  {
    label: 'Workflows',
    collapsed: true,
    links: [
      { title: 'Core Workflow', slug: 'workflow' },
      { title: 'Advanced Features', slug: 'advanced-features' },
      { title: 'Personalization', slug: 'personalization' },
      { title: 'Tips & Troubleshooting', slug: 'tips' },
      { title: 'Example Session', slug: 'example-session' },
    ],
  },
  {
    label: 'Architecture',
    collapsed: true,
    links: [
      { title: 'Overview', slug: 'architecture' },
      { title: 'System Deep Dive', slug: 'arch-system' },
      { title: 'Runtime Systems', slug: 'arch-runtime' },
      { title: 'Commands & State', slug: 'arch-reference' },
      { title: 'Design & Operations', slug: 'arch-design' },
      { title: 'Vibe Dashboard', slug: 'dashboard' },
    ],
  },
  {
    label: 'Reference',
    collapsed: true,
    links: [
      { title: 'Slash Commands', slug: 'commands' },
      { title: 'Glossary', slug: 'glossary' },
      { title: 'FAQ', slug: 'faq' },
    ],
  },
  {
    label: 'Releases',
    collapsed: true,
    links: [
      { title: 'Release Notes', slug: 'releases' },
    ],
  },
];

/** Flat ordered list of all pages (for prev/next navigation) */
export const pageOrder: NavLink[] = navigation.flatMap((g) => g.links);

/** Look up section label for a given slug */
export function getSectionLabel(slug: string): string | undefined {
  const group = navigation.find((g) => g.links.some((l) => l.slug === slug));
  return group?.label;
}

/** Get prev/next pages for a given slug */
export function getPrevNext(slug: string): { prev?: NavLink; next?: NavLink } {
  const idx = pageOrder.findIndex((p) => p.slug === slug);
  return {
    prev: idx > 0 ? pageOrder[idx - 1] : undefined,
    next: idx < pageOrder.length - 1 ? pageOrder[idx + 1] : undefined,
  };
}
