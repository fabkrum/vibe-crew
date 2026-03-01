import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  output: 'static',
  build: {
    format: 'file',
  },
  trailingSlash: 'never',
  integrations: [sitemap()],
  site: 'https://fabkrum.github.io',
  base: '/vibe-crew',
  outDir: '../docs',
});
