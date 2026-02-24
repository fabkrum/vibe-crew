<script setup lang="ts">
import { computed, ref } from "vue";
import type {
  GamificationData,
  Badge,
  CalendarDay,
  ScoreSparklineEntry,
} from "../data/gamification.data";

// ── Props ─────────────────────────────────────────────────────────────────────

const props = defineProps<{ data: GamificationData }>();

// ── Level tier color ──────────────────────────────────────────────────────────

function tierColor(level: number): string {
  if (level <= 3) return "#6B7280";
  if (level <= 8) return "#3B82F6";
  if (level <= 18) return "#8B5CF6";
  if (level <= 35) return "#F59E0B";
  return "#EF4444";
}

const levelColor = computed(() => tierColor(props.data.profile.level));

// ── XP progress bar ───────────────────────────────────────────────────────────

const xpPercent = computed(() => {
  const { xp, xp_to_next_level } = props.data.profile;
  if (!xp_to_next_level) return 100;
  return Math.min(100, Math.round((xp / xp_to_next_level) * 100));
});

// ── Badge tabs ────────────────────────────────────────────────────────────────

type BadgeCategory = "milestone" | "skill" | "special";
const activeTab = ref<BadgeCategory>("milestone");

const badgesByCategory = computed(() => {
  const badges = props.data.badges ?? [];
  return {
    milestone: badges.filter((b) => b.category === "milestone"),
    skill: badges.filter((b) => b.category === "skill"),
    special: badges.filter((b) => b.category === "special"),
  };
});

const visibleBadges = computed(
  () => badgesByCategory.value[activeTab.value] ?? [],
);

function badgeEarnedDate(badge: Badge): string {
  if (!badge.earned_at) return "";
  try {
    return new Date(badge.earned_at).toLocaleDateString(undefined, {
      year: "numeric",
      month: "short",
      day: "numeric",
    });
  } catch {
    return badge.earned_at;
  }
}

// ── Skill radar ───────────────────────────────────────────────────────────────

const RADAR_SIZE = 220;
const RADAR_CENTER = RADAR_SIZE / 2;
const RADAR_RADIUS = 85;
const MAX_SKILL_LEVEL = 5;

const skillAxes = computed(() => {
  const skills = props.data.skills;
  return [
    { key: "clean_code", label: skills.clean_code?.name ?? "Clean Code", level: skills.clean_code?.level ?? 0 },
    { key: "research_first", label: skills.research_first?.name ?? "Research First", level: skills.research_first?.level ?? 0 },
    { key: "tdd", label: skills.tdd?.name ?? "TDD", level: skills.tdd?.level ?? 0 },
    { key: "context_efficiency", label: skills.context_efficiency?.name ?? "Context Efficiency", level: skills.context_efficiency?.level ?? 0 },
    { key: "documentation", label: skills.documentation?.name ?? "Documentation", level: skills.documentation?.level ?? 0 },
  ];
});

function radarPoint(
  axisIndex: number,
  totalAxes: number,
  value: number,
  max: number,
  radius: number,
  cx: number,
  cy: number,
): { x: number; y: number } {
  const angle = (Math.PI * 2 * axisIndex) / totalAxes - Math.PI / 2;
  const r = (value / max) * radius;
  return {
    x: cx + r * Math.cos(angle),
    y: cy + r * Math.sin(angle),
  };
}

const radarOuterPoints = computed(() => {
  const n = skillAxes.value.length;
  return skillAxes.value.map((_, i) =>
    radarPoint(i, n, MAX_SKILL_LEVEL, MAX_SKILL_LEVEL, RADAR_RADIUS, RADAR_CENTER, RADAR_CENTER),
  );
});

const radarValuePoints = computed(() => {
  const n = skillAxes.value.length;
  return skillAxes.value.map((axis, i) =>
    radarPoint(i, n, Math.max(axis.level, 0.05), MAX_SKILL_LEVEL, RADAR_RADIUS, RADAR_CENTER, RADAR_CENTER),
  );
});

function pointsString(pts: { x: number; y: number }[]): string {
  return pts.map((p) => `${p.x.toFixed(2)},${p.y.toFixed(2)}`).join(" ");
}

// Intermediate ring points (20%, 40%, 60%, 80% of radius)
const radarRings = computed(() => {
  const n = skillAxes.value.length;
  return [0.2, 0.4, 0.6, 0.8, 1.0].map((frac) =>
    skillAxes.value.map((_, i) =>
      radarPoint(i, n, frac * MAX_SKILL_LEVEL, MAX_SKILL_LEVEL, RADAR_RADIUS, RADAR_CENTER, RADAR_CENTER),
    ),
  );
});

// Label positions slightly outside the outer ring
const radarLabelPositions = computed(() => {
  const n = skillAxes.value.length;
  return skillAxes.value.map((axis, i) => {
    const pt = radarPoint(i, n, MAX_SKILL_LEVEL, MAX_SKILL_LEVEL, RADAR_RADIUS + 22, RADAR_CENTER, RADAR_CENTER);
    return { ...pt, label: axis.label, level: axis.level };
  });
});

// ── Streak calendar ───────────────────────────────────────────────────────────

function scoreToCalendarColor(score: number | null, isDark: boolean): string {
  if (score === null) return isDark ? "#1e1e1e" : "#f0f0f0";
  if (score >= 90) return isDark ? "#166534" : "#dcfce7";
  if (score >= 75) return isDark ? "#15803d" : "#86efac";
  if (score >= 60) return isDark ? "#16a34a" : "#4ade80";
  if (score >= 40) return isDark ? "#22c55e" : "#22c55e";
  return isDark ? "#bbf7d0" : "#bbf7d0";
}

// Group 84 days into 12 weeks of 7 days
const calendarWeeks = computed((): CalendarDay[][] => {
  const days = props.data.calendar ?? [];
  const weeks: CalendarDay[][] = [];
  for (let w = 0; w < 12; w++) {
    weeks.push(days.slice(w * 7, w * 7 + 7));
  }
  return weeks;
});

const DAY_LABELS = ["S", "M", "T", "W", "T", "F", "S"];

// ── Challenges ────────────────────────────────────────────────────────────────

function challengeProgress(challenge: { progress: number; target: number }): number {
  if (!challenge.target) return 0;
  return Math.min(100, Math.round((challenge.progress / challenge.target) * 100));
}

function timeRemaining(expiresAt: string | null): string {
  if (!expiresAt) return "";
  try {
    const diff = new Date(expiresAt).getTime() - Date.now();
    if (diff <= 0) return "Expired";
    const hours = Math.floor(diff / 3_600_000);
    if (hours < 24) return `${hours}h remaining`;
    return `${Math.floor(hours / 24)}d remaining`;
  } catch {
    return "";
  }
}

function challengeTypeColor(type: string): string {
  switch (type) {
    case "daily":
      return "#3B82F6";
    case "weekly":
      return "#8B5CF6";
    case "one-time":
      return "#F59E0B";
    default:
      return "#6B7280";
  }
}

// ── Score sparkline ───────────────────────────────────────────────────────────

const SPARK_W = 320;
const SPARK_H = 60;
const SPARK_PAD = 8;

const sparkline = computed(() => props.data.sparkline ?? []);

const sparkPoints = computed((): string => {
  const data = sparkline.value;
  if (data.length < 2) return "";
  const xStep = (SPARK_W - 2 * SPARK_PAD) / (data.length - 1);
  return data
    .map((entry: ScoreSparklineEntry, i: number) => {
      const x = SPARK_PAD + i * xStep;
      const y =
        SPARK_H -
        SPARK_PAD -
        ((entry.score / 100) * (SPARK_H - 2 * SPARK_PAD));
      return `${x.toFixed(1)},${y.toFixed(1)}`;
    })
    .join(" ");
});

const trendArrow = computed(() => {
  switch (props.data.scoreTrend.direction) {
    case "improving":
      return "\u2191";
    case "declining":
      return "\u2193";
    case "stable":
      return "\u2192";
    default:
      return "\u2014";
  }
});

const trendColor = computed(() => {
  switch (props.data.scoreTrend.direction) {
    case "improving":
      return "#22c55e";
    case "declining":
      return "#ef4444";
    case "stable":
      return "#eab308";
    default:
      return "#6b7280";
  }
});

// ── Streak display ────────────────────────────────────────────────────────────

const streakActive = computed(() => {
  if (!props.data.profile.last_session_date) return false;
  const last = new Date(props.data.profile.last_session_date);
  const now = new Date();
  const diffDays = Math.floor(
    (now.getTime() - last.getTime()) / 86_400_000,
  );
  return diffDays <= 1;
});
</script>

<template>
  <div class="achievements-board">

    <!-- ── 1. Profile Header ──────────────────────────────────────────────── -->
    <section class="profile-header" aria-label="Player profile">
      <div
        class="level-badge"
        :style="{ background: levelColor }"
        :aria-label="`Level ${data.profile.level}`"
      >
        <span class="level-number">{{ data.profile.level }}</span>
        <span class="level-label">LVL</span>
      </div>

      <div class="profile-info">
        <h2 class="profile-title">{{ data.profile.title }}</h2>

        <div class="xp-bar-wrapper" :aria-label="`${data.profile.xp} of ${data.profile.xp_to_next_level} XP to next level`">
          <div class="xp-bar-track">
            <div
              class="xp-bar-fill"
              :style="{ width: xpPercent + '%', background: levelColor }"
            />
          </div>
          <span class="xp-label">
            {{ data.profile.xp }} / {{ data.profile.xp_to_next_level }} XP
          </span>
        </div>

        <div class="profile-stats">
          <div class="streak-display" :class="{ active: streakActive }">
            <span v-if="streakActive" aria-hidden="true">&#x1F525;</span>
            <span v-else aria-hidden="true">&#x1F4C5;</span>
            <strong>{{ data.profile.current_streak }}</strong>
            <span class="stat-detail">day streak</span>
            <span class="stat-separator">&bull;</span>
            <span class="stat-detail">best {{ data.profile.longest_streak }}</span>
          </div>
          <div class="profile-counters">
            <span class="counter-item">
              <strong>{{ data.profile.total_sessions }}</strong>
              <span class="counter-label">sessions</span>
            </span>
            <span class="counter-item">
              <strong>{{ data.profile.total_features }}</strong>
              <span class="counter-label">features</span>
            </span>
            <span class="counter-item">
              <strong>{{ data.profile.best_score }}</strong>
              <span class="counter-label">best score</span>
            </span>
          </div>
        </div>
      </div>
    </section>

    <!-- ── 2. Badge Gallery ───────────────────────────────────────────────── -->
    <section class="section" aria-label="Badge gallery">
      <h3 class="section-title">Badges</h3>

      <div class="badge-tabs" role="tablist">
        <button
          v-for="tab in (['milestone', 'skill', 'special'] as const)"
          :key="tab"
          role="tab"
          :aria-selected="activeTab === tab"
          :class="['tab-btn', { active: activeTab === tab }]"
          @click="activeTab = tab"
        >
          {{ tab.charAt(0).toUpperCase() + tab.slice(1) }}
          <span class="tab-count">
            {{ badgesByCategory[tab].filter(b => b.earned).length }}/{{ badgesByCategory[tab].length }}
          </span>
        </button>
      </div>

      <div class="badge-grid" role="tabpanel">
        <article
          v-for="badge in visibleBadges"
          :key="badge.id"
          :class="['badge-card', { earned: badge.earned, locked: !badge.earned }]"
          :aria-label="`${badge.name}: ${badge.description}${badge.earned ? ', earned' : ', locked'}`"
        >
          <div class="badge-icon" :class="badge.category">
            <span v-if="badge.category === 'milestone'" aria-hidden="true">&#x1F3C6;</span>
            <span v-else-if="badge.category === 'skill'" aria-hidden="true">&#x26A1;</span>
            <span v-else aria-hidden="true">&#x2B50;</span>
          </div>
          <div class="badge-body">
            <div class="badge-name">{{ badge.name }}</div>
            <div class="badge-desc">{{ badge.description }}</div>
            <div v-if="badge.earned && badge.earned_at" class="badge-date">
              Earned {{ badgeEarnedDate(badge) }}
            </div>
            <div v-else-if="!badge.earned" class="badge-progress-wrap">
              <div class="badge-progress-track">
                <div
                  class="badge-progress-fill"
                  :style="{ width: (badge.progress * 100).toFixed(0) + '%' }"
                />
              </div>
              <span v-if="badge.progress_label" class="badge-progress-label">
                {{ badge.progress_label }}
              </span>
              <span v-else class="badge-progress-label">
                {{ (badge.progress * 100).toFixed(0) }}%
              </span>
            </div>
          </div>
        </article>

        <p v-if="visibleBadges.length === 0" class="empty-state">
          No badges in this category yet.
        </p>
      </div>
    </section>

    <!-- ── 3. Skill Radar Chart ───────────────────────────────────────────── -->
    <section class="section" aria-label="Skill radar chart">
      <h3 class="section-title">Skill Radar</h3>
      <div class="radar-wrapper">
        <svg
          :viewBox="`0 0 ${RADAR_SIZE} ${RADAR_SIZE}`"
          class="radar-svg"
          aria-hidden="true"
          preserveAspectRatio="xMidYMid meet"
        >
          <!-- Grid rings -->
          <polygon
            v-for="(ring, ri) in radarRings"
            :key="ri"
            :points="pointsString(ring)"
            fill="none"
            stroke="var(--radar-grid, #e5e7eb)"
            stroke-width="1"
          />

          <!-- Axis lines -->
          <line
            v-for="(pt, i) in radarOuterPoints"
            :key="`axis-${i}`"
            :x1="RADAR_CENTER"
            :y1="RADAR_CENTER"
            :x2="pt.x"
            :y2="pt.y"
            stroke="var(--radar-grid, #e5e7eb)"
            stroke-width="1"
          />

          <!-- Filled skill polygon -->
          <polygon
            :points="pointsString(radarValuePoints)"
            fill="var(--radar-fill, rgba(59,130,246,0.25))"
            stroke="var(--radar-stroke, #3B82F6)"
            stroke-width="2"
            stroke-linejoin="round"
          />

          <!-- Skill vertex dots -->
          <circle
            v-for="(pt, i) in radarValuePoints"
            :key="`dot-${i}`"
            :cx="pt.x"
            :cy="pt.y"
            r="4"
            fill="var(--radar-stroke, #3B82F6)"
          />

          <!-- Axis labels -->
          <text
            v-for="lp in radarLabelPositions"
            :key="`lbl-${lp.label}`"
            :x="lp.x"
            :y="lp.y"
            text-anchor="middle"
            dominant-baseline="middle"
            class="radar-label"
            font-size="10"
          >
            {{ lp.label }}
          </text>

          <!-- Level indicators at each vertex -->
          <text
            v-for="(pt, i) in radarValuePoints"
            :key="`lvl-${i}`"
            :x="pt.x"
            :y="pt.y - 8"
            text-anchor="middle"
            class="radar-level"
            font-size="9"
          >
            {{ skillAxes[i].level }}/{{ MAX_SKILL_LEVEL }}
          </text>
        </svg>

        <ul class="radar-legend">
          <li v-for="axis in skillAxes" :key="axis.key" class="legend-item">
            <span class="legend-dot" />
            <span class="legend-name">{{ axis.label }}</span>
            <span class="legend-level">Lv {{ axis.level }}</span>
          </li>
        </ul>
      </div>
    </section>

    <!-- ── 4. Streak Calendar ─────────────────────────────────────────────── -->
    <section class="section" aria-label="Session streak calendar">
      <h3 class="section-title">
        Streak Calendar
        <span class="section-badge">
          {{ data.profile.current_streak }} day{{ data.profile.current_streak !== 1 ? 's' : '' }}
        </span>
      </h3>

      <div class="calendar-wrapper">
        <div class="calendar-day-labels" aria-hidden="true">
          <span v-for="(lbl, i) in DAY_LABELS" :key="i" class="day-label">{{ lbl }}</span>
        </div>

        <div class="calendar-grid" role="grid" aria-label="12-week activity heatmap">
          <div
            v-for="(week, wi) in calendarWeeks"
            :key="wi"
            class="calendar-week"
            role="row"
          >
            <div
              v-for="day in week"
              :key="day.date"
              class="calendar-cell"
              role="gridcell"
              :aria-label="`${day.date}: ${day.score !== null ? 'Vibe Score ' + day.score : 'no session'}`"
              :title="`${day.date}${day.score !== null ? ' — Score: ' + day.score : ''}`"
            >
              <!-- Color is applied via inline style; dark mode handled by CSS var trick -->
              <span
                class="calendar-dot"
                :style="{
                  background: day.score !== null
                    ? `hsl(142, 71%, ${Math.max(20, 65 - Math.round(day.score * 0.4))}%)`
                    : 'var(--cal-empty, #e5e7eb)',
                }"
              />
            </div>
          </div>
        </div>

        <div class="calendar-legend" aria-hidden="true">
          <span class="cal-legend-label">Less</span>
          <span v-for="n in 5" :key="n" class="cal-legend-dot"
            :style="{ background: `hsl(142, 71%, ${65 - (n - 1) * 11}%)` }" />
          <span class="cal-legend-label">More</span>
        </div>
      </div>
    </section>

    <!-- ── 5. Active Challenges ───────────────────────────────────────────── -->
    <section class="section" aria-label="Active challenges">
      <h3 class="section-title">Active Challenges</h3>

      <div v-if="data.challenges && data.challenges.length > 0" class="challenges-list">
        <article
          v-for="challenge in data.challenges"
          :key="challenge.id"
          class="challenge-card"
        >
          <header class="challenge-header">
            <span
              class="challenge-type-badge"
              :style="{ background: challengeTypeColor(challenge.type) }"
            >
              {{ challenge.type.charAt(0).toUpperCase() + challenge.type.slice(1) }}
            </span>
            <span class="challenge-xp">+{{ challenge.xp_reward }} XP</span>
          </header>

          <h4 class="challenge-title">{{ challenge.title }}</h4>
          <p class="challenge-desc">{{ challenge.description }}</p>

          <div class="challenge-progress-wrap">
            <div class="challenge-progress-track">
              <div
                class="challenge-progress-fill"
                :style="{
                  width: challengeProgress(challenge) + '%',
                  background: challengeTypeColor(challenge.type),
                }"
              />
            </div>
            <span class="challenge-progress-label">
              {{ challenge.progress }} / {{ challenge.target }}
            </span>
          </div>

          <footer v-if="challenge.expires_at" class="challenge-footer">
            {{ timeRemaining(challenge.expires_at) }}
          </footer>
        </article>
      </div>

      <p v-else class="empty-state">
        No active challenges. Run <code>/achievements</code> to generate new challenges.
      </p>
    </section>

    <!-- ── 6. Score Sparkline ─────────────────────────────────────────────── -->
    <section class="section" aria-label="Recent score trend">
      <h3 class="section-title">
        Last 30 Sessions
        <span class="trend-indicator" :style="{ color: trendColor }">
          {{ trendArrow }} {{ data.scoreTrend.direction }}
        </span>
      </h3>

      <div class="sparkline-wrapper">
        <div v-if="sparkline.length < 2" class="empty-state">
          Not enough sessions to display a trend. Complete more sessions with
          <code>/wrap</code>.
        </div>

        <template v-else>
          <svg
            :viewBox="`0 0 ${SPARK_W} ${SPARK_H}`"
            class="sparkline-svg"
            preserveAspectRatio="xMidYMid meet"
            aria-hidden="true"
          >
            <!-- Score area fill -->
            <defs>
              <linearGradient id="sparkGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stop-color="#3B82F6" stop-opacity="0.3" />
                <stop offset="100%" stop-color="#3B82F6" stop-opacity="0" />
              </linearGradient>
            </defs>

            <!-- Baseline grid -->
            <line
              v-for="score in [25, 50, 75]"
              :key="score"
              :x1="SPARK_PAD"
              :y1="SPARK_H - SPARK_PAD - ((score / 100) * (SPARK_H - 2 * SPARK_PAD))"
              :x2="SPARK_W - SPARK_PAD"
              :y2="SPARK_H - SPARK_PAD - ((score / 100) * (SPARK_H - 2 * SPARK_PAD))"
              stroke="var(--spark-grid, #e5e7eb)"
              stroke-width="0.5"
            />

            <!-- Polyline -->
            <polyline
              :points="sparkPoints"
              fill="none"
              stroke="#3B82F6"
              stroke-width="1.5"
              stroke-linejoin="round"
              stroke-linecap="round"
            />

            <!-- End dot -->
            <circle
              v-if="sparkline.length > 0"
              :cx="(SPARK_W - SPARK_PAD).toFixed(1)"
              :cy="(SPARK_H - SPARK_PAD - ((sparkline[sparkline.length - 1].score / 100) * (SPARK_H - 2 * SPARK_PAD))).toFixed(1)"
              r="3"
              fill="#3B82F6"
            />
          </svg>

          <div class="sparkline-meta">
            <span class="spark-avg">
              Avg <strong>{{ data.scoreTrend.average }}</strong>
            </span>
            <span class="spark-count">{{ sparkline.length }} sessions</span>
          </div>
        </template>
      </div>
    </section>

  </div>
</template>

<style scoped>
/* ── Design tokens ─────────────────────────────────────────────────────────── */
.achievements-board {
  --ab-bg: var(--vp-c-bg-soft, #f8fafc);
  --ab-border: var(--vp-c-divider, #e2e8f0);
  --ab-text-1: var(--vp-c-text-1, #1e293b);
  --ab-text-2: var(--vp-c-text-2, #64748b);
  --ab-text-3: var(--vp-c-text-3, #94a3b8);
  --ab-radius: 10px;
  --ab-gap: 1.5rem;

  --radar-grid: #e5e7eb;
  --radar-fill: rgba(59, 130, 246, 0.2);
  --radar-stroke: #3b82f6;
  --cal-empty: #e5e7eb;
  --spark-grid: #e5e7eb;

  display: flex;
  flex-direction: column;
  gap: var(--ab-gap);
  padding: 0.5rem 0;
  font-family: inherit;
  color: var(--ab-text-1);
}

@media (prefers-color-scheme: dark) {
  .achievements-board {
    --ab-bg: var(--vp-c-bg-soft, #1e293b);
    --ab-border: var(--vp-c-divider, #334155);
    --ab-text-1: var(--vp-c-text-1, #f1f5f9);
    --ab-text-2: var(--vp-c-text-2, #94a3b8);
    --ab-text-3: var(--vp-c-text-3, #64748b);
    --radar-grid: #334155;
    --radar-fill: rgba(59, 130, 246, 0.15);
    --cal-empty: #1e293b;
    --spark-grid: #334155;
  }
}

/* ── Section shell ─────────────────────────────────────────────────────────── */
.section {
  background: var(--ab-bg);
  border: 1px solid var(--ab-border);
  border-radius: var(--ab-radius);
  padding: 1.25rem 1.5rem;
}

.section-title {
  margin: 0 0 1rem;
  font-size: 1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--ab-text-1);
}

.section-badge {
  font-size: 0.75rem;
  font-weight: 700;
  background: #22c55e;
  color: #fff;
  border-radius: 999px;
  padding: 0.15em 0.6em;
}

/* ── Profile Header ─────────────────────────────────────────────────────────── */
.profile-header {
  background: var(--ab-bg);
  border: 1px solid var(--ab-border);
  border-radius: var(--ab-radius);
  padding: 1.25rem 1.5rem;
  display: flex;
  gap: 1.25rem;
  align-items: flex-start;
}

.level-badge {
  flex-shrink: 0;
  width: 72px;
  height: 72px;
  border-radius: 50%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.level-number {
  font-size: 1.75rem;
  font-weight: 800;
  color: #fff;
  line-height: 1;
}

.level-label {
  font-size: 0.6rem;
  font-weight: 700;
  color: rgba(255, 255, 255, 0.8);
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

.profile-info {
  flex: 1;
  min-width: 0;
}

.profile-title {
  margin: 0 0 0.5rem;
  font-size: 1.25rem;
  font-weight: 700;
  line-height: 1.2;
  color: var(--ab-text-1);
}

.xp-bar-wrapper {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.xp-bar-track {
  flex: 1;
  height: 8px;
  background: var(--ab-border);
  border-radius: 999px;
  overflow: hidden;
}

.xp-bar-fill {
  height: 100%;
  border-radius: 999px;
  transition: width 0.4s ease;
}

.xp-label {
  font-size: 0.75rem;
  color: var(--ab-text-2);
  white-space: nowrap;
}

.profile-stats {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.75rem;
  font-size: 0.875rem;
  color: var(--ab-text-2);
}

.streak-display {
  display: flex;
  align-items: center;
  gap: 0.3rem;
}

.streak-display.active {
  color: #f97316;
}

.streak-display strong {
  font-weight: 700;
  color: var(--ab-text-1);
}

.stat-separator {
  color: var(--ab-border);
}

.profile-counters {
  display: flex;
  gap: 1rem;
}

.counter-item {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.counter-item strong {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--ab-text-1);
}

.counter-label {
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--ab-text-3);
}

/* ── Badge tabs ─────────────────────────────────────────────────────────────── */
.badge-tabs {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.tab-btn {
  padding: 0.35em 0.85em;
  border-radius: 999px;
  border: 1px solid var(--ab-border);
  background: transparent;
  color: var(--ab-text-2);
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 0.4em;
  transition: background 0.15s, color 0.15s;
}

.tab-btn:hover {
  background: var(--ab-border);
}

.tab-btn.active {
  background: #3B82F6;
  border-color: #3B82F6;
  color: #fff;
}

.tab-count {
  font-size: 0.7rem;
  opacity: 0.75;
}

/* ── Badge grid ─────────────────────────────────────────────────────────────── */
.badge-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0.75rem;
}

@media (max-width: 600px) {
  .badge-grid {
    grid-template-columns: 1fr 1fr;
  }
}

.badge-card {
  border: 1px solid var(--ab-border);
  border-radius: 8px;
  padding: 0.75rem;
  display: flex;
  gap: 0.6rem;
  transition: box-shadow 0.15s;
}

.badge-card.earned {
  background: var(--ab-bg);
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
}

.badge-card.locked {
  opacity: 0.5;
  filter: grayscale(60%);
}

.badge-icon {
  flex-shrink: 0;
  font-size: 1.5rem;
  line-height: 1;
}

.badge-body {
  flex: 1;
  min-width: 0;
}

.badge-name {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--ab-text-1);
  margin-bottom: 0.15rem;
}

.badge-desc {
  font-size: 0.7rem;
  color: var(--ab-text-2);
  line-height: 1.3;
  margin-bottom: 0.35rem;
}

.badge-date {
  font-size: 0.65rem;
  color: #22c55e;
  font-weight: 500;
}

.badge-progress-wrap {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.badge-progress-track {
  flex: 1;
  height: 4px;
  background: var(--ab-border);
  border-radius: 999px;
  overflow: hidden;
}

.badge-progress-fill {
  height: 100%;
  background: #3B82F6;
  border-radius: 999px;
  transition: width 0.3s;
}

.badge-progress-label {
  font-size: 0.65rem;
  color: var(--ab-text-3);
  white-space: nowrap;
}

/* ── Radar chart ─────────────────────────────────────────────────────────────── */
.radar-wrapper {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
}

.radar-svg {
  width: 220px;
  height: 220px;
  flex-shrink: 0;
}

.radar-label {
  fill: var(--ab-text-2);
  font-size: 10px;
}

.radar-level {
  fill: var(--ab-text-2);
  font-size: 9px;
}

.radar-legend {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.8rem;
  color: var(--ab-text-2);
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #3B82F6;
  flex-shrink: 0;
}

.legend-name {
  flex: 1;
}

.legend-level {
  font-weight: 600;
  color: var(--ab-text-1);
}

/* ── Streak calendar ─────────────────────────────────────────────────────────── */
.calendar-wrapper {
  overflow-x: auto;
}

.calendar-day-labels {
  display: flex;
  margin-bottom: 4px;
  padding-left: 2px;
}

.day-label {
  width: 14px;
  text-align: center;
  font-size: 0.65rem;
  color: var(--ab-text-3);
  margin-right: 3px;
}

.calendar-grid {
  display: flex;
  gap: 3px;
}

.calendar-week {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.calendar-cell {
  width: 14px;
  height: 14px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.calendar-dot {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  display: block;
  transition: transform 0.1s;
}

.calendar-dot:hover {
  transform: scale(1.3);
}

.calendar-legend {
  display: flex;
  align-items: center;
  gap: 4px;
  margin-top: 8px;
  font-size: 0.65rem;
  color: var(--ab-text-3);
}

.cal-legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 2px;
  display: inline-block;
}

.cal-legend-label {
  margin: 0 2px;
}

/* ── Challenges ──────────────────────────────────────────────────────────────── */
.challenges-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.challenge-card {
  border: 1px solid var(--ab-border);
  border-radius: 8px;
  padding: 1rem;
  background: var(--ab-bg);
}

.challenge-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.4rem;
}

.challenge-type-badge {
  font-size: 0.65rem;
  font-weight: 700;
  color: #fff;
  padding: 0.15em 0.6em;
  border-radius: 999px;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.challenge-xp {
  font-size: 0.75rem;
  font-weight: 700;
  color: #F59E0B;
}

.challenge-title {
  margin: 0 0 0.2rem;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--ab-text-1);
}

.challenge-desc {
  margin: 0 0 0.6rem;
  font-size: 0.8rem;
  color: var(--ab-text-2);
  line-height: 1.4;
}

.challenge-progress-wrap {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.35rem;
}

.challenge-progress-track {
  flex: 1;
  height: 6px;
  background: var(--ab-border);
  border-radius: 999px;
  overflow: hidden;
}

.challenge-progress-fill {
  height: 100%;
  border-radius: 999px;
  transition: width 0.3s;
}

.challenge-progress-label {
  font-size: 0.7rem;
  color: var(--ab-text-3);
  white-space: nowrap;
}

.challenge-footer {
  font-size: 0.7rem;
  color: var(--ab-text-3);
}

/* ── Sparkline ───────────────────────────────────────────────────────────────── */
.sparkline-wrapper {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.sparkline-svg {
  width: 100%;
  max-height: 80px;
}

.sparkline-meta {
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  color: var(--ab-text-2);
}

.spark-avg strong {
  color: var(--ab-text-1);
}

.trend-indicator {
  font-size: 0.875rem;
  font-weight: 600;
}

/* ── Empty / misc ────────────────────────────────────────────────────────────── */
.empty-state {
  color: var(--ab-text-3);
  font-size: 0.875rem;
  text-align: center;
  padding: 1.5rem 0;
}

code {
  background: var(--ab-border);
  padding: 0.1em 0.4em;
  border-radius: 4px;
  font-size: 0.85em;
}
</style>
