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
    label: 'Workflows',
    links: [
      { title: 'Core Workflow', slug: 'workflow' },
      { title: 'Advanced Features', slug: 'advanced-features' },
      { title: 'Personalization', slug: 'personalization' },
      { title: 'Warp Tips & Tricks', slug: 'warp' },
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
      { title: 'UI Pattern Guide', slug: 'ui-patterns' },
      { title: 'Business Patterns', slug: 'business-patterns' },
      { title: 'Glossary', slug: 'glossary' },
      { title: 'FAQ', slug: 'faq' },
      { title: 'Changelog', slug: 'releases' },
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
