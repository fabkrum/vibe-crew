import { defineConfig } from "vitepress";

export default defineConfig({
  title: "{{PROJECT_NAME}} Docs",
  description: "Project documentation powered by VibeCrew",
  lastUpdated: true,

  themeConfig: {
    nav: [
      { text: "Guide", link: "/system/getting-started" },
      { text: "Kanban", link: "/kanban" },
      { text: "Stats", link: "/stats" },
      { text: "Trends", link: "/trends" },
      { text: "Coverage", link: "/coverage" },
      { text: "Achievements", link: "/achievements" },
    ],

    sidebar: {
      "/system/": [
        {
          text: "System",
          items: [
            { text: "Getting Started", link: "/system/getting-started" },
            { text: "Commands", link: "/system/commands" },
          ],
        },
      ],
    },

    search: {
      provider: "local",
    },

    footer: {
      message: "Built with VibeCrew",
    },
  },

  markdown: {
    lineNumbers: true,
  },
});
