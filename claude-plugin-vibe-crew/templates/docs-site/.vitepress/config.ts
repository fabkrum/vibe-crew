import { defineConfig } from "vitepress";
import { readFileSync, writeFileSync, renameSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { randomBytes } from "node:crypto";

const __dir = dirname(fileURLToPath(import.meta.url));

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
      { text: "Settings", link: "/settings" },
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

  vite: {
    plugins: [
      {
        name: "vibecrew-settings-api",
        configureServer(server) {
          server.middlewares.use("/api/save-config", (req, res) => {
            if (req.method !== "POST") {
              res.writeHead(405, { "Content-Type": "application/json" });
              res.end(JSON.stringify({ error: "Method not allowed" }));
              return;
            }

            let body = "";
            req.on("data", (chunk: Buffer) => {
              body += chunk.toString();
            });
            req.on("end", () => {
              try {
                const config = JSON.parse(body);

                if (!config.schema_version) {
                  res.writeHead(400, { "Content-Type": "application/json" });
                  res.end(
                    JSON.stringify({ error: "Missing schema_version" }),
                  );
                  return;
                }

                const projectRoot = resolve(__dir, "../..");
                const configPath = resolve(
                  projectRoot,
                  ".vibecrew/config.json",
                );
                const tmpPath = resolve(
                  projectRoot,
                  `.vibecrew/.config-${randomBytes(4).toString("hex")}.tmp`,
                );

                writeFileSync(tmpPath, JSON.stringify(config, null, 2) + "\n");
                renameSync(tmpPath, configPath);

                res.writeHead(200, { "Content-Type": "application/json" });
                res.end(JSON.stringify({ success: true }));
              } catch (err: any) {
                res.writeHead(500, { "Content-Type": "application/json" });
                res.end(
                  JSON.stringify({ error: err.message || "Write failed" }),
                );
              }
            });
          });
        },
      },
    ],
  },
});
