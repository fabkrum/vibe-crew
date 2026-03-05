import { readFileSync, readdirSync, existsSync } from "node:fs";
import { resolve } from "node:path";

interface AgentMetrics {
  total_tool_calls: number;
  progress_calls: number;
  exploration_calls: number;
  neutral_calls: number;
  failed_calls: number;
  efficiency_ratio: number;
  files_touched: string[];
  files_created: number;
  files_modified: number;
  tools_used: Record<string, number>;
  repeated_reads: number;
}

interface AgentSessionEntry {
  agent: string;
  session_id: string;
  metrics: AgentMetrics;
}

interface AgentSummary {
  agent: string;
  sessions: number;
  avgEfficiency: number;
  avgTotalCalls: number;
  trend: "improving" | "declining" | "stable" | "insufficient_data";
  flags: string[];
  toolBreakdown: Record<string, number>;
}

interface ToolCallEntry {
  ts: string;
  agent: string;
  tool: string;
  target: string;
  exit: number;
  class: string;
  phase: string;
  feat: string;
}

interface AgentLogsData {
  agentSummaries: AgentSummary[];
  recentToolCalls: ToolCallEntry[];
  inefficiencyPatterns: Array<{
    agent: string;
    pattern: string;
    description: string;
    sessions_detected: number;
  }>;
  heatmap: Array<{ agent: string; tools: Record<string, number> }>;
}

export default {
  watch: [
    "../../.vibecrew/agent-logs/*.jsonl",
    "../../.vibecrew/sessions/*.json",
  ],
  load(): AgentLogsData {
    const projectRoot = resolve(process.cwd());
    const agentLogDir = resolve(projectRoot, ".vibecrew/agent-logs");
    const sessionsDir = resolve(projectRoot, ".vibecrew/sessions");

    const empty: AgentLogsData = {
      agentSummaries: [],
      recentToolCalls: [],
      inefficiencyPatterns: [],
      heatmap: [],
    };

    // --- Collect agent metrics from session logs ---
    const agentEntries: AgentSessionEntry[] = [];

    if (existsSync(sessionsDir)) {
      const sessionFiles = readdirSync(sessionsDir)
        .filter((f) => f.startsWith("session-") && f.endsWith(".json"))
        .sort()
        .reverse()
        .slice(0, 20);

      for (const file of sessionFiles) {
        try {
          const raw = readFileSync(resolve(sessionsDir, file), "utf-8");
          const data = JSON.parse(raw);
          const sessionId = data.session_id || file.replace(".json", "");

          for (const agent of data.agents || []) {
            if (agent.metrics) {
              agentEntries.push({
                agent: agent.agent,
                session_id: sessionId,
                metrics: agent.metrics,
              });
            }
          }
        } catch {
          // skip malformed files
        }
      }
    }

    if (agentEntries.length === 0) return empty;

    // --- Build per-agent summaries ---
    const agentMap = new Map<string, AgentSessionEntry[]>();
    for (const entry of agentEntries) {
      const existing = agentMap.get(entry.agent) || [];
      existing.push(entry);
      agentMap.set(entry.agent, existing);
    }

    const WRITE_AGENTS = ["builder", "verifier", "ci-healer"];
    const WRITE_THRESHOLD = 0.20;

    const agentSummaries: AgentSummary[] = Array.from(agentMap.entries()).map(
      ([agent, entries]) => {
        const efficiencies = entries.map((e) => e.metrics.efficiency_ratio);
        const avgEfficiency =
          efficiencies.reduce((a, b) => a + b, 0) / efficiencies.length;
        const avgCalls =
          entries.reduce((a, e) => a + e.metrics.total_tool_calls, 0) /
          entries.length;

        // Compute trend from last 2 entries
        let trend: AgentSummary["trend"] = "insufficient_data";
        if (entries.length >= 2) {
          const last = efficiencies[efficiencies.length - 1];
          const prev = efficiencies[efficiencies.length - 2];
          trend = last > prev ? "improving" : last < prev ? "declining" : "stable";
        }

        // Detect flags
        const flags: string[] = [];
        const repeatedReads = entries.filter(
          (e) => e.metrics.repeated_reads > 2
        );
        if (repeatedReads.length >= 3) flags.push("repeated_reads");

        if (WRITE_AGENTS.includes(agent)) {
          const lowEff = entries.filter(
            (e) => e.metrics.efficiency_ratio < WRITE_THRESHOLD
          );
          if (lowEff.length >= 3) flags.push("excessive_exploration");
        }

        const highFail = entries.filter((e) => {
          const total = e.metrics.total_tool_calls || 1;
          return e.metrics.failed_calls / total > 0.15;
        });
        if (highFail.length >= 3) flags.push("high_failure_rate");

        // Aggregate tool breakdown
        const toolBreakdown: Record<string, number> = {};
        for (const entry of entries) {
          for (const [tool, count] of Object.entries(
            entry.metrics.tools_used || {}
          )) {
            toolBreakdown[tool] = (toolBreakdown[tool] || 0) + count;
          }
        }

        return {
          agent,
          sessions: entries.length,
          avgEfficiency: Math.round(avgEfficiency * 100) / 100,
          avgTotalCalls: Math.round(avgCalls),
          trend,
          flags,
          toolBreakdown,
        };
      }
    );

    // --- Build heatmap data ---
    const heatmap = agentSummaries.map((s) => ({
      agent: s.agent,
      tools: s.toolBreakdown,
    }));

    // --- Build inefficiency patterns ---
    const inefficiencyPatterns = agentSummaries
      .filter((s) => s.flags.length > 0)
      .flatMap((s) =>
        s.flags.map((flag) => ({
          agent: s.agent,
          pattern: flag,
          description: `${s.agent}: ${flag.replace(/_/g, " ")} (avg efficiency: ${s.avgEfficiency})`,
          sessions_detected: s.sessions,
        }))
      );

    // --- Read recent tool calls from JSONL ---
    const recentToolCalls: ToolCallEntry[] = [];
    if (existsSync(agentLogDir)) {
      const jsonlFiles = readdirSync(agentLogDir)
        .filter((f) => f.endsWith(".jsonl"))
        .sort()
        .reverse()
        .slice(0, 3); // last 3 sessions

      for (const file of jsonlFiles) {
        try {
          const lines = readFileSync(resolve(agentLogDir, file), "utf-8")
            .trim()
            .split("\n")
            .slice(-50); // last 50 entries per file
          for (const line of lines) {
            if (line.trim()) {
              recentToolCalls.push(JSON.parse(line));
            }
          }
        } catch {
          // skip
        }
      }
    }

    return {
      agentSummaries: agentSummaries.sort(
        (a, b) => b.sessions - a.sessions
      ),
      recentToolCalls: recentToolCalls.slice(-100),
      inefficiencyPatterns,
      heatmap,
    };
  },
};
