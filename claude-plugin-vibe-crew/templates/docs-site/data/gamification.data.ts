import { readFileSync, existsSync, readdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const __dir = dirname(fileURLToPath(import.meta.url));

// ── Type Definitions ─────────────────────────────────────────────────────────

export interface Badge {
  id: string;
  category: "milestone" | "skill" | "special";
  name: string;
  description: string;
  earned: boolean;
  earned_at: string | null;
  /** 0–1 for locked badges; 1 for earned */
  progress: number;
  progress_label: string | null;
}

export interface Skill {
  name: string;
  level: number; // 0–5
  xp: number;
}

export interface Skills {
  clean_code: Skill;
  research_first: Skill;
  tdd: Skill;
  context_efficiency: Skill;
  documentation: Skill;
}

export interface Challenge {
  id: string;
  title: string;
  description: string;
  type: "daily" | "weekly" | "one-time";
  progress: number;
  target: number;
  expires_at: string | null;
  xp_reward: number;
}

export interface CalendarDay {
  date: string; // ISO date string YYYY-MM-DD
  score: number | null;
}

export interface ScoreSparklineEntry {
  session_id: string;
  timestamp: string;
  score: number;
}

export interface Profile {
  level: number;
  title: string;
  xp: number;
  xp_to_next_level: number;
  xp_total: number;
  current_streak: number;
  longest_streak: number;
  last_session_date: string | null;
  total_sessions: number;
  total_features: number;
  best_score: number;
}

export interface GamificationData {
  profile: Profile;
  badges: Badge[];
  skills: Skills;
  challenges: Challenge[];
  calendar: CalendarDay[]; // last 84 days (12 weeks)
  sparkline: ScoreSparklineEntry[]; // last 30 sessions
  scoreTrend: {
    direction: "improving" | "declining" | "stable" | "unknown";
    average: number;
  };
}

// ── Default values ────────────────────────────────────────────────────────────

const DEFAULT_BADGE_CATALOG: Omit<
  Badge,
  "earned" | "earned_at" | "progress" | "progress_label"
>[] = [
  // Milestones
  {
    id: "first-setup",
    category: "milestone",
    name: "First Steps",
    description: "Complete initial VibeCrew setup",
  },
  {
    id: "first-foundation",
    category: "milestone",
    name: "Architect",
    description: "Complete Tier 1 project foundation",
  },
  {
    id: "first-feature",
    category: "milestone",
    name: "Builder",
    description: "Ship your first feature end-to-end",
  },
  {
    id: "five-features",
    category: "milestone",
    name: "Momentum",
    description: "Ship 5 features",
  },
  {
    id: "first-tdr",
    category: "milestone",
    name: "Researcher",
    description: "Produce your first Technology Decision Record",
  },
  // Skills
  {
    id: "clean-session",
    category: "skill",
    name: "Clean Session",
    description: "Finish a session with a Vibe Score of 90+",
  },
  {
    id: "clean-streak-3",
    category: "skill",
    name: "On a Roll",
    description: "Score 90+ three sessions in a row",
  },
  {
    id: "clean-streak-10",
    category: "skill",
    name: "Unstoppable",
    description: "Score 90+ ten sessions in a row",
  },
  {
    id: "high-cache",
    category: "skill",
    name: "Cache King",
    description: "Achieve >80% cache utilization in a session",
  },
  {
    id: "zero-churn",
    category: "skill",
    name: "Zero Churn",
    description: "Complete a session with no prompt churn deductions",
  },
  {
    id: "tdd-warrior",
    category: "skill",
    name: "TDD Warrior",
    description: "Write spec tests before code in 5 consecutive features",
  },
  {
    id: "context-ninja",
    category: "skill",
    name: "Context Ninja",
    description: "Keep context below 50% for 10 sessions",
  },
  // Special
  {
    id: "perfect-100",
    category: "special",
    name: "Perfect Score",
    description: "Achieve a Vibe Score of 100",
  },
  {
    id: "comeback",
    category: "special",
    name: "Comeback Kid",
    description: "Improve score by 30+ points after a low session",
  },
  {
    id: "week-streak-7",
    category: "special",
    name: "Week Warrior",
    description: "Maintain a 7-day session streak",
  },
  {
    id: "month-streak-30",
    category: "special",
    name: "Iron Coder",
    description: "Maintain a 30-day session streak",
  },
];

const DEFAULT_SKILLS: Skills = {
  clean_code: { name: "Clean Code", level: 0, xp: 0 },
  research_first: { name: "Research First", level: 0, xp: 0 },
  tdd: { name: "TDD", level: 0, xp: 0 },
  context_efficiency: { name: "Context Efficiency", level: 0, xp: 0 },
  documentation: { name: "Documentation", level: 0, xp: 0 },
};

const DEFAULT_PROFILE: Profile = {
  level: 1,
  title: "Newcomer",
  xp: 0,
  xp_to_next_level: 100,
  xp_total: 0,
  current_streak: 0,
  longest_streak: 0,
  last_session_date: null,
  total_sessions: 0,
  total_features: 0,
  best_score: 0,
};

function defaultGamificationData(): GamificationData {
  const today = new Date();
  const calendar: CalendarDay[] = [];
  for (let i = 83; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    calendar.push({
      date: d.toISOString().slice(0, 10),
      score: null,
    });
  }

  return {
    profile: { ...DEFAULT_PROFILE },
    badges: DEFAULT_BADGE_CATALOG.map((b) => ({
      ...b,
      earned: false,
      earned_at: null,
      progress: 0,
      progress_label: null,
    })),
    skills: { ...DEFAULT_SKILLS },
    challenges: [],
    calendar,
    sparkline: [],
    scoreTrend: { direction: "unknown", average: 0 },
  };
}

// ── Score history helpers ─────────────────────────────────────────────────────

interface RawScoreEntry {
  session_id: string;
  timestamp: string;
  score: number;
}

function loadScoreHistory(scoresDir: string): RawScoreEntry[] {
  if (!existsSync(scoresDir)) return [];

  return readdirSync(scoresDir)
    .filter((f) => f.startsWith("score-") && f.endsWith(".json"))
    .sort()
    .map((f) => {
      try {
        const raw = readFileSync(resolve(scoresDir, f), "utf-8");
        const parsed = JSON.parse(raw);
        if (
          typeof parsed.score === "number" &&
          typeof parsed.timestamp === "string"
        ) {
          return {
            session_id: parsed.session_id ?? f.replace(/\.json$/, ""),
            timestamp: parsed.timestamp,
            score: parsed.score,
          } satisfies RawScoreEntry;
        }
        return null;
      } catch {
        return null;
      }
    })
    .filter((e): e is RawScoreEntry => e !== null);
}

function buildCalendar(
  scoreHistory: RawScoreEntry[],
): CalendarDay[] {
  // Index scores by ISO date; keep the highest score per day.
  const byDate = new Map<string, number>();
  for (const entry of scoreHistory) {
    const date = entry.timestamp.slice(0, 10);
    const existing = byDate.get(date) ?? -1;
    if (entry.score > existing) byDate.set(date, entry.score);
  }

  const today = new Date();
  const calendar: CalendarDay[] = [];
  for (let i = 83; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(d.getDate() - i);
    const dateStr = d.toISOString().slice(0, 10);
    calendar.push({ date: dateStr, score: byDate.get(dateStr) ?? null });
  }
  return calendar;
}

function computeTrend(
  sparkline: RawScoreEntry[],
): GamificationData["scoreTrend"] {
  const values = sparkline.map((e) => e.score);
  if (values.length < 3)
    return { direction: "unknown", average: values[0] ?? 0 };

  const average =
    Math.round((values.reduce((a, b) => a + b, 0) / values.length) * 10) / 10;

  const half = Math.floor(values.length / 2);
  const firstAvg =
    values.slice(0, half).reduce((a, b) => a + b, 0) / half;
  const secondAvg =
    values.slice(half).reduce((a, b) => a + b, 0) / (values.length - half);
  const diff = secondAvg - firstAvg;

  let direction: GamificationData["scoreTrend"]["direction"] = "stable";
  if (diff > 5) direction = "improving";
  else if (diff < -5) direction = "declining";

  return { direction, average };
}

// ── VitePress data loader ─────────────────────────────────────────────────────

export default {
  watch: [
    "../../.vibecrew/gamification.json",
    "../../.vibecrew/scores/*.json",
  ],

  load(): GamificationData {
    const projectRoot = resolve(__dir, "../..");
    const gamificationPath = resolve(
      projectRoot,
      ".vibecrew/gamification.json",
    );
    const scoresDir = resolve(projectRoot, ".vibecrew/scores");

    // Load score history (used to enrich data even when gamification.json is missing)
    const scoreHistory = loadScoreHistory(scoresDir);
    const last30 = scoreHistory.slice(-30);

    if (!existsSync(gamificationPath)) {
      const fallback = defaultGamificationData();
      fallback.calendar = buildCalendar(scoreHistory);
      fallback.sparkline = last30;
      fallback.scoreTrend = computeTrend(last30);
      // Derive basic profile stats from score history
      fallback.profile.total_sessions = scoreHistory.length;
      if (scoreHistory.length > 0) {
        fallback.profile.best_score = Math.max(
          ...scoreHistory.map((e) => e.score),
        );
      }
      return fallback;
    }

    let raw: GamificationData;
    try {
      raw = JSON.parse(
        readFileSync(gamificationPath, "utf-8"),
      ) as GamificationData;
    } catch {
      return defaultGamificationData();
    }

    // Ensure badge catalog entries always exist (merge missing badges as locked)
    const badgeMap = new Map<string, Badge>(
      (raw.badges ?? []).map((b) => [b.id, b]),
    );
    const mergedBadges: Badge[] = DEFAULT_BADGE_CATALOG.map((def) => {
      const existing = badgeMap.get(def.id);
      if (existing) return existing;
      return {
        ...def,
        earned: false,
        earned_at: null,
        progress: 0,
        progress_label: null,
      };
    });

    // Merge score-derived data
    const calendar = buildCalendar(scoreHistory);
    const sparkline =
      raw.sparkline && raw.sparkline.length > 0 ? raw.sparkline : last30;
    const scoreTrend = computeTrend(sparkline);

    return {
      profile: { ...DEFAULT_PROFILE, ...(raw.profile ?? {}) },
      badges: mergedBadges,
      skills: { ...DEFAULT_SKILLS, ...(raw.skills ?? {}) },
      challenges: raw.challenges ?? [],
      calendar,
      sparkline,
      scoreTrend,
    };
  },
};

export declare const data: GamificationData;
