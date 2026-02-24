import { readFileSync, readdirSync, existsSync } from "node:fs";
import { resolve } from "node:path";

interface AgentActivity {
  agent: string;
  started_at: string;
  ended_at: string;
  worktree: string | null;
}

interface SessionAgentData {
  session_id: string;
  timestamp: string;
  agents: AgentActivity[];
  tokens: {
    input: number;
    cache_read: number;
    output: number;
    estimated_cost_usd: number;
  };
  context: {
    peak_usage_percent: number;
  };
  duration_seconds: number;
}

interface AgentsData {
  sessions: SessionAgentData[];
  agentSummary: Array<{
    agent: string;
    invocations: number;
    totalDuration: number;
    sessions: number;
  }>;
  totalTokens: {
    input: number;
    cache_read: number;
    output: number;
    cost: number;
  };
}

export default {
  watch: ["../../.vibecrew/sessions/*.json"],
  load(watchedFiles: string[]): AgentsData {
    const sessionsDir = resolve(process.cwd(), ".vibecrew/sessions");

    if (!existsSync(sessionsDir)) {
      return {
        sessions: [],
        agentSummary: [],
        totalTokens: { input: 0, cache_read: 0, output: 0, cost: 0 },
      };
    }

    const files = readdirSync(sessionsDir)
      .filter((f) => f.startsWith("session-") && f.endsWith(".json"))
      .sort()
      .reverse()
      .slice(0, 20);

    const sessions: SessionAgentData[] = files
      .map((f) => {
        try {
          const raw = readFileSync(resolve(sessionsDir, f), "utf-8");
          const data = JSON.parse(raw);
          return {
            session_id: data.session_id || f.replace(".json", ""),
            timestamp: data.started_at || data.ended_at || "",
            agents: data.agents || [],
            tokens: {
              input: data.tokens?.input || 0,
              cache_read: data.tokens?.cache_read || 0,
              output: data.tokens?.output || 0,
              estimated_cost_usd: data.tokens?.estimated_cost_usd || 0,
            },
            context: {
              peak_usage_percent: data.context?.peak_usage_percent || 0,
            },
            duration_seconds: data.duration_seconds || 0,
          } as SessionAgentData;
        } catch {
          return null;
        }
      })
      .filter((s): s is SessionAgentData => s !== null);

    // Aggregate agent activity
    const agentMap = new Map<
      string,
      { invocations: number; totalDuration: number; sessions: Set<string> }
    >();
    for (const session of sessions) {
      for (const agent of session.agents) {
        const existing = agentMap.get(agent.agent) || {
          invocations: 0,
          totalDuration: 0,
          sessions: new Set<string>(),
        };
        existing.invocations++;
        existing.sessions.add(session.session_id);
        if (agent.started_at && agent.ended_at) {
          const duration =
            new Date(agent.ended_at).getTime() -
            new Date(agent.started_at).getTime();
          existing.totalDuration += Math.max(0, duration / 1000);
        }
        agentMap.set(agent.agent, existing);
      }
    }

    const agentSummary = Array.from(agentMap.entries())
      .map(([agent, data]) => ({
        agent,
        invocations: data.invocations,
        totalDuration: Math.round(data.totalDuration),
        sessions: data.sessions.size,
      }))
      .sort((a, b) => b.invocations - a.invocations);

    // Total tokens
    const totalTokens = sessions.reduce(
      (acc, s) => ({
        input: acc.input + s.tokens.input,
        cache_read: acc.cache_read + s.tokens.cache_read,
        output: acc.output + s.tokens.output,
        cost:
          acc.cost +
          (s.tokens.estimated_cost_usd || 0),
      }),
      { input: 0, cache_read: 0, output: 0, cost: 0 },
    );

    return {
      sessions: sessions.reverse(), // chronological
      agentSummary,
      totalTokens,
    };
  },
};
