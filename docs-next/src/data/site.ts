export const SITE_VERSION = 'v1.8.0';
export const SITE_TITLE = 'VibeCrew Documentation';
export const SITE_DESCRIPTION = 'The autonomous vibe-coding operating system that turns Claude Code into a full development team.';
export const SITE_AUTHOR = 'Fabian Krumbholz';
export const SITE_DATE = 'February 2026';

/** Prepend base path to a local URL. Works in both dev and production. */
export function url(path: string): string {
  const base = import.meta.env.BASE_URL.replace(/\/$/, '');
  const p = path.startsWith('/') ? path : `/${path}`;
  return `${base}${p}`;
}
