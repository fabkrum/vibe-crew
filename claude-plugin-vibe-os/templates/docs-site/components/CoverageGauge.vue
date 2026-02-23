<script setup lang="ts">
import { computed } from "vue";
import { data } from "../data/scores.data";

const latestScore = computed(() => {
  const scores = data.scores;
  return scores.length > 0 ? scores[scores.length - 1] : null;
});

const coverage = computed(() => {
  return latestScore.value?.metrics?.quality?.coverage_percent ?? 0;
});

const gaugeColor = computed(() => {
  if (coverage.value >= 80) return "#22c55e";
  if (coverage.value >= 60) return "#eab308";
  if (coverage.value >= 40) return "#f97316";
  return "#ef4444";
});

const gaugeLabel = computed(() => {
  if (coverage.value >= 80) return "Excellent";
  if (coverage.value >= 60) return "Good";
  if (coverage.value >= 40) return "Fair";
  return "Low";
});

// SVG arc calculations for radial gauge
const radius = 70;
const circumference = 2 * Math.PI * radius;
const strokeDashoffset = computed(() => {
  const pct = Math.min(coverage.value, 100) / 100;
  return circumference * (1 - pct * 0.75); // 270 degree arc
});
</script>

<template>
  <div class="coverage-gauge">
    <h3>Test Coverage</h3>

    <div class="gauge-container">
      <svg viewBox="0 0 200 160" class="gauge-svg">
        <!-- Background arc -->
        <circle
          cx="100"
          cy="100"
          :r="radius"
          fill="none"
          stroke="var(--vp-c-bg-soft)"
          stroke-width="12"
          :stroke-dasharray="circumference"
          :stroke-dashoffset="circumference * 0.25"
          transform="rotate(135 100 100)"
          stroke-linecap="round"
        />
        <!-- Value arc -->
        <circle
          cx="100"
          cy="100"
          :r="radius"
          fill="none"
          :stroke="gaugeColor"
          stroke-width="12"
          :stroke-dasharray="circumference"
          :stroke-dashoffset="strokeDashoffset"
          transform="rotate(135 100 100)"
          stroke-linecap="round"
          class="value-arc"
        />
        <!-- Center text -->
        <text x="100" y="95" text-anchor="middle" :fill="gaugeColor" font-size="28" font-weight="700">
          {{ Math.round(coverage) }}%
        </text>
        <text x="100" y="115" text-anchor="middle" fill="var(--vp-c-text-2)" font-size="12">
          {{ gaugeLabel }}
        </text>
      </svg>
    </div>

    <div class="bands">
      <span class="band" style="color: #ef4444">0-39%</span>
      <span class="band" style="color: #f97316">40-59%</span>
      <span class="band" style="color: #eab308">60-79%</span>
      <span class="band" style="color: #22c55e">80-100%</span>
    </div>
  </div>
</template>

<style scoped>
.coverage-gauge {
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  padding: 16px;
  text-align: center;
}
.coverage-gauge h3 {
  margin: 0 0 8px 0;
  font-size: 16px;
}
.gauge-container {
  display: flex;
  justify-content: center;
}
.gauge-svg {
  width: 180px;
  height: 140px;
}
.value-arc {
  transition: stroke-dashoffset 0.6s ease;
}
.bands {
  display: flex;
  justify-content: center;
  gap: 12px;
  margin-top: 8px;
  font-size: 11px;
}
.band {
  font-weight: 500;
}
</style>
