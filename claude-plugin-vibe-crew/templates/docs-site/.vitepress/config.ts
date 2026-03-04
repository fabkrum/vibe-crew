import { defineConfig } from "vitepress";
import {
  readFileSync,
  writeFileSync,
  renameSync,
  existsSync,
  watch,
} from "node:fs";
import { resolve, dirname, basename } from "node:path";
import { fileURLToPath } from "node:url";
import { randomBytes } from "node:crypto";

const __dir = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(__dir, "../..");
const vibecrewDir = resolve(projectRoot, ".vibecrew");
const backlogPath = resolve(vibecrewDir, "backlog.json");

const VALID_COLUMNS = [
  "idea",
  "planning",
  "planned",
  "in-progress",
  "testing",
  "review",
  "done",
];

const WIP_LIMITS: Record<string, number | null> = {
  idea: null,
  planning: 2,
  planned: 5,
  "in-progress": 1,
  testing: 1,
  review: 2,
  done: null,
};

// --- Shared helpers ---

function readBody(req: any): Promise<string> {
  return new Promise((resolve, reject) => {
    let body = "";
    req.on("data", (chunk: Buffer) => {
      body += chunk.toString();
    });
    req.on("end", () => resolve(body));
    req.on("error", reject);
  });
}

function jsonResponse(res: any, status: number, data: any) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(data));
}

function readBacklog() {
  if (!existsSync(backlogPath)) return null;
  return JSON.parse(readFileSync(backlogPath, "utf-8"));
}

function writeBacklog(data: any) {
  const tmpPath = resolve(
    vibecrewDir,
    `.backlog-${randomBytes(4).toString("hex")}.tmp`,
  );
  writeFileSync(tmpPath, JSON.stringify(data, null, 2) + "\n");
  renameSync(tmpPath, backlogPath);
}

export default defineConfig({
  title: "{{PROJECT_NAME}} Docs",
  description: "Project documentation powered by VibeCrew",
  lastUpdated: true,

  themeConfig: {
    nav: [
      { text: "About", link: "/about" },
      { text: "Guide", link: "/system/getting-started" },
      { text: "Features", link: "/features" },
      { text: "Kanban", link: "/kanban" },
      { text: "Stats", link: "/stats" },
      { text: "Trends", link: "/trends" },
      { text: "Logbook", link: "/logbook" },
      { text: "Coverage", link: "/coverage" },
      { text: "Achievements", link: "/achievements" },
      { text: "Releases", link: "/releases" },
      { text: "Architecture", link: "/architecture" },
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
      "/features/": [
        {
          text: "Features",
          items: [
            { text: "Overview", link: "/features" },
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
      // --- Settings API (existing) ---
      {
        name: "vibecrew-settings-api",
        configureServer(server) {
          server.middlewares.use("/api/save-config", async (req, res) => {
            if (req.method !== "POST") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }

            try {
              const body = await readBody(req);
              const config = JSON.parse(body);

              if (!config.schema_version) {
                jsonResponse(res, 400, { error: "Missing schema_version" });
                return;
              }

              const configPath = resolve(vibecrewDir, "config.json");
              const tmpPath = resolve(
                vibecrewDir,
                `.config-${randomBytes(4).toString("hex")}.tmp`,
              );

              writeFileSync(tmpPath, JSON.stringify(config, null, 2) + "\n");
              renameSync(tmpPath, configPath);

              jsonResponse(res, 200, { success: true });
            } catch (err: any) {
              jsonResponse(res, 500, { error: err.message || "Write failed" });
            }
          });
        },
      },

      // --- Backlog API ---
      {
        name: "vibecrew-backlog-api",
        configureServer(server) {
          // GET /api/backlog — return full backlog.json
          server.middlewares.use("/api/backlog", async (req, res, next) => {
            // Skip sub-routes handled below
            if (req.url && req.url !== "/" && req.url !== "") {
              next();
              return;
            }
            if (req.method !== "GET") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }
            try {
              const backlog = readBacklog();
              if (!backlog) {
                jsonResponse(res, 404, {
                  error: "backlog.json not found",
                });
                return;
              }
              jsonResponse(res, 200, backlog);
            } catch (err: any) {
              jsonResponse(res, 500, { error: err.message || "Read failed" });
            }
          });

          // POST /api/backlog/add-idea
          server.middlewares.use("/api/backlog/add-idea", async (req, res) => {
            if (req.method !== "POST") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }
            try {
              const body = await readBody(req);
              const { name, description, labels, priority } = JSON.parse(body);

              // Validate name
              if (!name || typeof name !== "string" || name.length > 200) {
                jsonResponse(res, 400, {
                  error: "name is required (string, max 200 chars)",
                });
                return;
              }
              // Validate description
              if (
                description !== undefined &&
                (typeof description !== "string" || description.length > 5000)
              ) {
                jsonResponse(res, 400, {
                  error: "description must be a string (max 5000 chars)",
                });
                return;
              }
              // Validate labels
              if (labels !== undefined) {
                if (
                  !Array.isArray(labels) ||
                  labels.length > 20 ||
                  labels.some(
                    (l: any) =>
                      typeof l !== "string" || l.length > 50,
                  )
                ) {
                  jsonResponse(res, 400, {
                    error:
                      "labels must be an array of strings (max 20 items, 50 chars each)",
                  });
                  return;
                }
              }
              // Validate priority
              if (
                priority !== undefined &&
                (typeof priority !== "number" || priority < 1 || !Number.isInteger(priority))
              ) {
                jsonResponse(res, 400, {
                  error: "priority must be a positive integer",
                });
                return;
              }

              const backlog = readBacklog();
              if (!backlog) {
                jsonResponse(res, 404, {
                  error: "backlog.json not found",
                });
                return;
              }

              // Auto-generate ID
              const maxId = (backlog.features || []).reduce(
                (max: number, f: any) => {
                  const num = parseInt(f.id?.replace("feat-", "") || "0", 10);
                  return num > max ? num : max;
                },
                0,
              );
              const newId = `feat-${String(maxId + 1).padStart(3, "0")}`;
              const now = new Date().toISOString().replace(/\.\d{3}Z$/, "Z");

              const feature = {
                id: newId,
                name,
                description: description || "",
                column: "idea",
                priority: priority || 999,
                labels: labels || [],
                spec: {
                  acceptance_criteria: [],
                  ui_description: null,
                  business_logic: [],
                  technical_notes: null,
                },
                worktree: null,
                phases_completed: [],
                sessions: [],
                created_at: now,
                updated_at: now,
                completed_at: null,
              };

              backlog.features = backlog.features || [];
              backlog.features.push(feature);
              writeBacklog(backlog);

              jsonResponse(res, 201, { success: true, feature });
            } catch (err: any) {
              jsonResponse(res, 500, { error: err.message || "Write failed" });
            }
          });

          // POST /api/backlog/move
          server.middlewares.use("/api/backlog/move", async (req, res) => {
            if (req.method !== "POST") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }
            try {
              const body = await readBody(req);
              const { id, column } = JSON.parse(body);

              // Validate ID
              if (!id || !/^feat-\d{3,}$/.test(id)) {
                jsonResponse(res, 400, {
                  error: "id must match feat-NNN format",
                });
                return;
              }
              // Validate column
              if (!VALID_COLUMNS.includes(column)) {
                jsonResponse(res, 400, {
                  error: `column must be one of: ${VALID_COLUMNS.join(", ")}`,
                });
                return;
              }

              const backlog = readBacklog();
              if (!backlog) {
                jsonResponse(res, 404, {
                  error: "backlog.json not found",
                });
                return;
              }

              const featureIdx = (backlog.features || []).findIndex(
                (f: any) => f.id === id,
              );
              if (featureIdx === -1) {
                jsonResponse(res, 404, {
                  error: `Feature ${id} not found`,
                });
                return;
              }

              // Check WIP limits
              const wipLimit = WIP_LIMITS[column];
              if (wipLimit !== null) {
                const currentCount = (backlog.features || []).filter(
                  (f: any) => f.column === column && f.id !== id,
                ).length;
                if (currentCount >= wipLimit) {
                  jsonResponse(res, 409, {
                    error: `WIP limit reached for ${column} (max ${wipLimit})`,
                  });
                  return;
                }
              }

              const now = new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
              backlog.features[featureIdx].column = column;
              backlog.features[featureIdx].updated_at = now;
              if (column === "done") {
                backlog.features[featureIdx].completed_at = now;
              }

              writeBacklog(backlog);
              jsonResponse(res, 200, {
                success: true,
                feature: backlog.features[featureIdx],
              });
            } catch (err: any) {
              jsonResponse(res, 500, { error: err.message || "Write failed" });
            }
          });

          // POST /api/backlog/update
          server.middlewares.use("/api/backlog/update", async (req, res) => {
            if (req.method !== "POST") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }
            try {
              const body = await readBody(req);
              const { id, name, description, priority, labels, spec } =
                JSON.parse(body);

              // Validate ID
              if (!id || !/^feat-\d{3,}$/.test(id)) {
                jsonResponse(res, 400, {
                  error: "id must match feat-NNN format",
                });
                return;
              }
              if (name !== undefined && (typeof name !== "string" || name.length > 200)) {
                jsonResponse(res, 400, { error: "name max 200 chars" });
                return;
              }
              if (
                description !== undefined &&
                (typeof description !== "string" || description.length > 5000)
              ) {
                jsonResponse(res, 400, { error: "description max 5000 chars" });
                return;
              }
              if (
                priority !== undefined &&
                (typeof priority !== "number" || priority < 1 || !Number.isInteger(priority))
              ) {
                jsonResponse(res, 400, {
                  error: "priority must be a positive integer",
                });
                return;
              }
              if (labels !== undefined) {
                if (
                  !Array.isArray(labels) ||
                  labels.length > 20 ||
                  labels.some(
                    (l: any) =>
                      typeof l !== "string" || l.length > 50,
                  )
                ) {
                  jsonResponse(res, 400, {
                    error: "labels: array of strings, max 20 items, 50 chars each",
                  });
                  return;
                }
              }

              const backlog = readBacklog();
              if (!backlog) {
                jsonResponse(res, 404, {
                  error: "backlog.json not found",
                });
                return;
              }

              const featureIdx = (backlog.features || []).findIndex(
                (f: any) => f.id === id,
              );
              if (featureIdx === -1) {
                jsonResponse(res, 404, {
                  error: `Feature ${id} not found`,
                });
                return;
              }

              const now = new Date().toISOString().replace(/\.\d{3}Z$/, "Z");
              const feature = backlog.features[featureIdx];

              if (name !== undefined) feature.name = name;
              if (description !== undefined) feature.description = description;
              if (priority !== undefined) feature.priority = priority;
              if (labels !== undefined) feature.labels = labels;
              if (spec !== undefined) {
                feature.spec = { ...feature.spec, ...spec };
              }
              feature.updated_at = now;

              writeBacklog(backlog);
              jsonResponse(res, 200, { success: true, feature });
            } catch (err: any) {
              jsonResponse(res, 500, { error: err.message || "Write failed" });
            }
          });
        },
      },

      // --- Launch API ---
      {
        name: "vibecrew-launch-api",
        configureServer(server) {
          server.middlewares.use("/api/launch-warp", async (req, res) => {
            if (req.method !== "POST") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }
            try {
              const body = await readBody(req);
              const { feature_id, command } = JSON.parse(body);

              let commandText = command || "";
              let featureName = "";

              if (feature_id && !command) {
                const backlog = readBacklog();
                if (backlog) {
                  const feature = (backlog.features || []).find(
                    (f: any) => f.id === feature_id,
                  );
                  if (feature) {
                    featureName = feature.name;
                    switch (feature.column) {
                      case "idea":
                      case "planning":
                        commandText = "/plan-features";
                        break;
                      case "planned":
                        commandText = `/new-feature "${feature.name}"`;
                        break;
                      case "in-progress":
                        commandText = `/status`;
                        break;
                      case "testing":
                        commandText = "/check";
                        break;
                      case "review":
                        commandText = "/review";
                        break;
                      default:
                        commandText = "/status";
                    }
                  }
                }
              }

              const warpUrl = `warp://action/new_tab?path=${encodeURIComponent(projectRoot)}`;

              jsonResponse(res, 200, {
                warp_url: warpUrl,
                command_text: commandText,
                feature_name: featureName,
              });
            } catch (err: any) {
              jsonResponse(res, 500, { error: err.message || "Failed" });
            }
          });
        },
      },

      // --- Live Session API ---
      {
        name: "vibecrew-live-api",
        configureServer(server) {
          server.middlewares.use("/api/live-session", async (req, res) => {
            if (req.method !== "GET") {
              jsonResponse(res, 405, { error: "Method not allowed" });
              return;
            }
            try {
              const livePath = resolve(vibecrewDir, "live-session.json");
              if (!existsSync(livePath)) {
                jsonResponse(res, 200, { active: false });
                return;
              }
              const data = JSON.parse(readFileSync(livePath, "utf-8"));
              jsonResponse(res, 200, { active: true, ...data });
            } catch {
              jsonResponse(res, 200, { active: false });
            }
          });
        },
      },

      // --- File Watcher for WebSocket Push ---
      {
        name: "vibecrew-file-watcher",
        configureServer(server) {
          if (!existsSync(vibecrewDir)) return;

          let debounceTimer: ReturnType<typeof setTimeout> | null = null;

          const watcher = watch(
            vibecrewDir,
            { recursive: true },
            (_eventType, filename) => {
              if (!filename || filename.endsWith(".tmp") || filename.endsWith(".bak")) return;

              if (debounceTimer) clearTimeout(debounceTimer);
              debounceTimer = setTimeout(() => {
                const fname = basename(String(filename));
                let updateType = "state_changed";

                if (fname === "backlog.json" || fname.startsWith("backlog")) {
                  updateType = "backlog_changed";
                } else if (fname === "live-session.json") {
                  updateType = "live_session_changed";
                } else if (fname === "config.json") {
                  updateType = "config_changed";
                } else if (fname.startsWith("session-")) {
                  updateType = "session_changed";
                } else if (fname.startsWith("score-")) {
                  updateType = "score_changed";
                } else if (fname.startsWith("release-")) {
                  updateType = "release_changed";
                }

                server.ws.send({
                  type: "custom",
                  event: "vibecrew:update",
                  data: { updateType, filename: String(filename), timestamp: Date.now() },
                });
              }, 100);
            },
          );

          // Cleanup on server close
          server.httpServer?.on("close", () => {
            watcher.close();
            if (debounceTimer) clearTimeout(debounceTimer);
          });
        },
      },
    ],
  },
});
