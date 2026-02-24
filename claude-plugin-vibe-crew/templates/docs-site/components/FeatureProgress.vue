<script setup lang="ts">
import { computed } from "vue";
import { data } from "../data/backlog.data";

interface Feature {
  id: string;
  name: string;
  column: string;
  priority: string;
}

const features = computed(() => (data.features || []) as Feature[]);

const columnOrder = [
  "idea",
  "planned",
  "ready",
  "in-progress",
  "testing",
  "review",
  "done",
];

const columnColors: Record<string, string> = {
  idea: "#6b7280",
  planned: "#8b5cf6",
  ready: "#3b82f6",
  "in-progress": "#f97316",
  testing: "#eab308",
  review: "#06b6d4",
  done: "#22c55e",
};

const columnCounts = computed(() => {
  const counts: Record<string, number> = {};
  for (const col of columnOrder) {
    counts[col] = features.value.filter((f) => f.column === col).length;
  }
  return counts;
});

const totalFeatures = computed(() => features.value.length);
const doneCount = computed(() => columnCounts.value.done || 0);

const velocity = computed(() => {
  if (totalFeatures.value === 0) return "0%";
  return `${Math.round((doneCount.value / totalFeatures.value) * 100)}%`;
});

const maxCount = computed(() => {
  return Math.max(...Object.values(columnCounts.value), 1);
});
</script>

<template>
  <div class="feature-progress">
    <div class="header">
      <h3>Feature Progress</h3>
      <div class="velocity">
        {{ doneCount }}/{{ totalFeatures }} done ({{ velocity }})
      </div>
    </div>

    <div v-if="totalFeatures === 0" class="empty">
      No features in backlog. Run <code>/plan-features</code> to get started.
    </div>

    <div v-else class="bars">
      <div
        v-for="col in columnOrder"
        :key="col"
        class="bar-row"
      >
        <div class="label">{{ col }}</div>
        <div class="bar-container">
          <div
            class="bar"
            :style="{
              width: `${(columnCounts[col] / maxCount) * 100}%`,
              backgroundColor: columnColors[col],
            }"
          />
        </div>
        <div class="count">{{ columnCounts[col] }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.feature-progress {
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
.velocity {
  font-size: 13px;
  color: var(--vp-c-text-2);
  font-weight: 600;
}
.bars {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.bar-row {
  display: flex;
  align-items: center;
  gap: 8px;
}
.label {
  width: 80px;
  font-size: 12px;
  color: var(--vp-c-text-2);
  text-align: right;
  flex-shrink: 0;
}
.bar-container {
  flex: 1;
  height: 20px;
  background: var(--vp-c-bg-soft);
  border-radius: 4px;
  overflow: hidden;
}
.bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
  min-width: 2px;
}
.count {
  width: 24px;
  font-size: 12px;
  color: var(--vp-c-text-3);
  text-align: right;
  flex-shrink: 0;
}
.empty {
  text-align: center;
  color: var(--vp-c-text-2);
  padding: 40px 0;
}
</style>
