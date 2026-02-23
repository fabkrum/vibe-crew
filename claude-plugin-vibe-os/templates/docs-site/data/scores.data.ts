import { readFileSync, readdirSync, existsSync } from "node:fs";
import { resolve } from "node:path";

interface ScoreEntry {
  session_id: string;
  timestamp: string;
  score: number;
  rating: string;
  feature_id: string | null;
  deductions: Array<{ category: string; points: number; reason: string }>;
  bonuses: Array<{ category: string; points: number; reason: string }>;
  user_feedback: { rating: number | null; comment: string | null } | null;
  trend: {
    direction: string;
    window_size: number;
    average_score: number;
  } | null;
}

interface ScoresData {
  scores: ScoreEntry[];
  trend: {
    direction: string;
    average: number;
    count: number;
  };
  topDeductions: Array<{ category: string; count: number; totalPoints: number }>;
}

export default {
  watch: ["../../.vibeos/scores/*.json"],
  load(watchedFiles: string[]): ScoresData {
    const scoresDir = resolve(process.cwd(), ".vibeos/scores");

    if (!existsSync(scoresDir)) {
      return {
        scores: [],
        trend: { direction: "unknown", average: 0, count: 0 },
        topDeductions: [],
      };
    }

    const files = readdirSync(scoresDir)
      .filter((f) => f.startsWith("score-") && f.endsWith(".json"))
      .sort()
      .reverse()
      .slice(0, 20);

    const scores: ScoreEntry[] = files
      .map((f) => {
        try {
          const raw = readFileSync(resolve(scoresDir, f), "utf-8");
          return JSON.parse(raw) as ScoreEntry;
        } catch {
          return null;
        }
      })
      .filter((s): s is ScoreEntry => s !== null);

    // Calculate trend
    const scoreValues = scores.map((s) => s.score);
    const average =
      scoreValues.length > 0
        ? Math.round(
            (scoreValues.reduce((a, b) => a + b, 0) / scoreValues.length) * 10,
          ) / 10
        : 0;

    let direction = "unknown";
    if (scoreValues.length >= 3) {
      const half = Math.floor(scoreValues.length / 2);
      const firstHalf = scoreValues.slice(0, half);
      const secondHalf = scoreValues.slice(half);
      const firstAvg =
        firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
      const secondAvg =
        secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;
      const diff = secondAvg - firstAvg;
      if (diff > 5) direction = "improving";
      else if (diff < -5) direction = "declining";
      else direction = "plateau";
    }

    // Aggregate deductions
    const deductionMap = new Map<
      string,
      { count: number; totalPoints: number }
    >();
    for (const score of scores) {
      for (const d of score.deductions || []) {
        const existing = deductionMap.get(d.category) || {
          count: 0,
          totalPoints: 0,
        };
        existing.count++;
        existing.totalPoints += Math.abs(d.points);
        deductionMap.set(d.category, existing);
      }
    }

    const topDeductions = Array.from(deductionMap.entries())
      .map(([category, data]) => ({
        category,
        count: data.count,
        totalPoints: data.totalPoints,
      }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);

    return {
      scores: scores.reverse(), // chronological order for charts
      trend: { direction, average, count: scores.length },
      topDeductions,
    };
  },
};
