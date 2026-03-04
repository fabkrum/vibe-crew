import { readFileSync, existsSync, readdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dir = dirname(fileURLToPath(import.meta.url));

interface ReleaseEntry {
  version: string;
  date: string;
  sections: {
    features: string[];
    fixes: string[];
    refactors: string[];
    docs: string[];
    other: string[];
  };
  stats: {
    total_commits: number;
    files_changed: number;
    insertions: number;
    deletions: number;
  };
}

export default {
  watch: ["../../.vibecrew/releases/*.json"],

  load(): ReleaseEntry[] {
    const projectRoot = resolve(__dir, "../..");
    const releasesDir = resolve(projectRoot, ".vibecrew/releases");

    if (!existsSync(releasesDir)) {
      return [];
    }

    const files = readdirSync(releasesDir)
      .filter((f) => f.startsWith("release-") && f.endsWith(".json"))
      .sort()
      .reverse();

    return files
      .map((file) => {
        try {
          const raw = readFileSync(resolve(releasesDir, file), "utf-8");
          return JSON.parse(raw) as ReleaseEntry;
        } catch {
          return null;
        }
      })
      .filter((r): r is ReleaseEntry => r !== null);
  },
};

export declare const data: ReleaseEntry[];
