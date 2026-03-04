import { readFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dir = dirname(fileURLToPath(import.meta.url));

interface AboutData {
  vision: {
    project_name: string;
    tagline: string;
    description: string;
    target_audience: string;
    problems_solved: string;
    raw: string;
  };
  tdr: {
    tech_stack_summary: string;
    raw: string;
  };
  dev_scripts: Record<string, string>;
  has_vision: boolean;
  has_tdr: boolean;
}

function extractSection(markdown: string, heading: string): string {
  const regex = new RegExp(
    `^##\\s+${heading.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\s*\\n([\\s\\S]*?)(?=^##\\s|$)`,
    "m",
  );
  const match = markdown.match(regex);
  return match ? match[1].trim() : "";
}

export default {
  watch: ["../../VISION.md", "../../TDR.md", "../../package.json"],

  load(): AboutData {
    const projectRoot = resolve(__dir, "../..");
    const visionPath = resolve(projectRoot, "VISION.md");
    const tdrPath = resolve(projectRoot, "TDR.md");
    const pkgPath = resolve(projectRoot, "package.json");

    const has_vision = existsSync(visionPath);
    const has_tdr = existsSync(tdrPath);

    // Parse VISION.md
    let vision = {
      project_name: "{{PROJECT_NAME}}",
      tagline: "",
      description: "",
      target_audience: "",
      problems_solved: "",
      raw: "",
    };

    if (has_vision) {
      const raw = readFileSync(visionPath, "utf-8");
      vision.raw = raw;

      // Extract project name from first H1
      const h1 = raw.match(/^#\s+(.+)/m);
      if (h1) vision.project_name = h1[1].trim();

      // Extract tagline from first non-empty line after H1
      const afterH1 = raw.match(/^#\s+.+\n+(.+)/m);
      if (afterH1) {
        const line = afterH1[1].trim();
        if (!line.startsWith("#")) vision.tagline = line;
      }

      vision.description = extractSection(raw, "Description") ||
        extractSection(raw, "Overview") ||
        extractSection(raw, "Vision");
      vision.target_audience = extractSection(raw, "Target Audience") ||
        extractSection(raw, "Users") ||
        extractSection(raw, "Personas");
      vision.problems_solved = extractSection(raw, "Problems Solved") ||
        extractSection(raw, "Problem Statement") ||
        extractSection(raw, "Problems");
    }

    // Parse TDR.md
    let tdr = { tech_stack_summary: "", raw: "" };

    if (has_tdr) {
      const raw = readFileSync(tdrPath, "utf-8");
      tdr.raw = raw;
      tdr.tech_stack_summary = extractSection(raw, "Technology Stack") ||
        extractSection(raw, "Tech Stack") ||
        extractSection(raw, "Stack Summary") ||
        extractSection(raw, "Chosen Stack");
    }

    // Parse package.json scripts
    let dev_scripts: Record<string, string> = {};

    if (existsSync(pkgPath)) {
      try {
        const pkg = JSON.parse(readFileSync(pkgPath, "utf-8"));
        dev_scripts = pkg.scripts || {};
      } catch {
        // ignore parse errors
      }
    }

    return { vision, tdr, dev_scripts, has_vision, has_tdr };
  },
};

export declare const data: AboutData;
