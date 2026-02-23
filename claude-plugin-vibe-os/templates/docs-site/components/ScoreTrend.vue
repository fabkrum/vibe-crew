<script setup lang="ts">
import { computed } from "vue";
import { data } from "../data/scores.data";

const scores = computed(() => data.scores);
const trend = computed(() => data.trend);

const trendArrow = computed(() => {
  switch (trend.value.direction) {
    case "improving":
      return "\u2191";
    case "declining":
      return "\u2193";
    case "plateau":
      return "\u2192";
    case "volatile":
      return "\u2195";
    default:
      return "\u2014";
  }
});

const trendColor = computed(() => {
  switch (trend.value.direction) {
    case "improving":
      return "#22c55e";
    case "declining":
      return "#ef4444";
    case "plateau":
      return "#eab308";
    case "volatile":
      return "#f97316";
    default:
      return "#6b7280";
  }
});

const maxScore = 100;
const chartHeight = 200;
const chartWidth = 600;
const padding = 40;

const points = computed(() => {
  if (scores.value.length === 0) return "";
  const xStep =
    scores.value.length > 1
      ? (chartWidth - 2 * padding) / (scores.value.length - 1)
      : 0;
  return scores.value
    .map((s, i) => {
      const x = padding + i * xStep;
      const y =
        chartHeight - padding - ((s.score / maxScore) * (chartHeight - 2 * padding));
      return `${x},${y}`;
    })
    .join(" ");
});

const targetLine = computed(() => {
  const y =
    chartHeight - padding - ((80 / maxScore) * (chartHeight - 2 * padding));
  return y;
});
</script>

<template>
  <div class="score-trend">
    <div class="header">
      <h3>Vibe Score Trend</h3>
      <div class="trend-badge" :style="{ color: trendColor }">
        {{ trendArrow }} {{ trend.direction }} (avg {{ trend.average }})
      </div>
    </div>

    <div v-if="scores.length === 0" class="empty">
      No score data yet. Run <code>/wrap</code> to generate scores.
    </div>

    <svg
      v-else
      :viewBox="`0 0 ${chartWidth} ${chartHeight}`"
      class="chart"
      preserveAspectRatio="xMidYMid meet"
    >
      <!-- Target line at 80 -->
      <line
        :x1="padding"
        :y1="targetLine"
        :x2="chartWidth - padding"
        :y2="targetLine"
        stroke="#eab308"
        stroke-dasharray="5,5"
        stroke-width="1"
      />
      <text :x="chartWidth - padding + 5" :y="targetLine + 4" fill="#eab308" font-size="10">
        Target: 80
      </text>

      <!-- Score line -->
      <polyline
        :points="points"
        fill="none"
        stroke="#3b82f6"
        stroke-width="2"
        stroke-linejoin="round"
      />

      <!-- Score dots -->
      <circle
        v-for="(s, i) in scores"
        :key="i"
        :cx="padding + (scores.length > 1 ? i * ((chartWidth - 2 * padding) / (scores.length - 1)) : 0)"
        :cy="chartHeight - padding - ((s.score / maxScore) * (chartHeight - 2 * padding))"
        r="4"
        :fill="s.score >= 90 ? '#22c55e' : s.score >= 70 ? '#3b82f6' : s.score >= 50 ? '#eab308' : '#ef4444'"
      />

      <!-- Y axis labels -->
      <text :x="padding - 5" :y="chartHeight - padding + 4" fill="#6b7280" font-size="10" text-anchor="end">0</text>
      <text :x="padding - 5" :y="padding + 4" fill="#6b7280" font-size="10" text-anchor="end">100</text>
    </svg>

    <div class="session-count">{{ trend.count }} sessions</div>
  </div>
</template>

<style scoped>
.score-trend {
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 16px;
}
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}
.header h3 {
  margin: 0;
  font-size: 16px;
}
.trend-badge {
  font-weight: 600;
  font-size: 14px;
}
.chart {
  width: 100%;
  max-height: 200px;
}
.empty {
  text-align: center;
  color: var(--vp-c-text-2);
  padding: 40px 0;
}
.session-count {
  text-align: right;
  color: var(--vp-c-text-3);
  font-size: 12px;
  margin-top: 8px;
}
</style>
