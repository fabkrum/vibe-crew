<script setup>
import { computed } from "vue";

const props = defineProps({
  releases: { type: Array, required: true },
});

const latestVersion = computed(() => {
  if (props.releases.length === 0) return null;
  return props.releases[0]?.version || null;
});

function formatDate(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

const SECTION_CONFIG = [
  { key: "features", label: "Features", color: "#22c55e" },
  { key: "fixes", label: "Fixes", color: "#ef4444" },
  { key: "refactors", label: "Refactors", color: "#3b82f6" },
  { key: "docs", label: "Docs", color: "#eab308" },
  { key: "other", label: "Other", color: "#6b7280" },
];

function visibleSections(release) {
  if (!release.sections) return [];
  return SECTION_CONFIG.filter(
    (s) => release.sections[s.key]?.length > 0,
  );
}
</script>

<template>
  <div class="releases-timeline">
    <!-- Empty state -->
    <div v-if="releases.length === 0" class="releases-empty">
      <p>No releases yet. Run <code>/release</code> to create your first release.</p>
    </div>

    <template v-else>
      <!-- Summary bar -->
      <div class="releases-summary">
        <span class="summary-stat">{{ releases.length }} releases</span>
        <span v-if="latestVersion" class="version-badge">{{ latestVersion }}</span>
      </div>

      <!-- Timeline -->
      <div class="timeline">
        <div
          v-for="(release, idx) in releases"
          :key="release.version || idx"
          class="timeline-entry"
        >
          <div class="timeline-marker">
            <div class="timeline-dot" :class="{ latest: idx === 0 }"></div>
            <div v-if="idx < releases.length - 1" class="timeline-line"></div>
          </div>

          <div class="timeline-content">
            <div class="release-header">
              <span class="release-version">{{ release.version }}</span>
              <span class="release-date">{{ formatDate(release.date) }}</span>
            </div>

            <!-- Change sections -->
            <div class="release-sections">
              <div
                v-for="sec in visibleSections(release)"
                :key="sec.key"
                class="change-section"
              >
                <span class="section-label" :style="{ color: sec.color }">
                  {{ sec.label }}
                </span>
                <ul class="change-list">
                  <li v-for="(item, i) in release.sections[sec.key]" :key="i">
                    {{ item }}
                  </li>
                </ul>
              </div>
            </div>

            <!-- Stats row -->
            <div v-if="release.stats" class="release-stats">
              <span v-if="release.stats.total_commits" class="stat-item">
                {{ release.stats.total_commits }} commits
              </span>
              <span v-if="release.stats.files_changed" class="stat-item">
                {{ release.stats.files_changed }} files
              </span>
              <span v-if="release.stats.insertions" class="stat-item stat-add">
                +{{ release.stats.insertions }}
              </span>
              <span v-if="release.stats.deletions" class="stat-item stat-del">
                -{{ release.stats.deletions }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<style scoped>
.releases-timeline {
  padding: 1rem 0;
}

.releases-empty {
  text-align: center;
  color: var(--vp-c-text-3);
  padding: 3rem 1rem;
}

.releases-empty code {
  color: var(--vp-c-brand-1);
}

.releases-summary {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.summary-stat {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.version-badge {
  font-size: 0.75rem;
  font-weight: 600;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  padding: 0.15rem 0.5rem;
  border-radius: 9999px;
}

.timeline {
  display: flex;
  flex-direction: column;
}

.timeline-entry {
  display: flex;
  gap: 1rem;
}

.timeline-marker {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 1.25rem;
  flex-shrink: 0;
}

.timeline-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--vp-c-divider);
  margin-top: 0.4rem;
  flex-shrink: 0;
}

.timeline-dot.latest {
  background: var(--vp-c-brand-1);
  box-shadow: 0 0 0 3px var(--vp-c-brand-soft);
}

.timeline-line {
  width: 2px;
  flex: 1;
  background: var(--vp-c-divider);
  min-height: 1rem;
}

.timeline-content {
  flex: 1;
  padding-bottom: 1.5rem;
}

.release-header {
  display: flex;
  align-items: baseline;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.release-version {
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--vp-c-text-1);
}

.release-date {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
}

.release-sections {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.change-section {
  margin-bottom: 0.25rem;
}

.section-label {
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.change-list {
  margin: 0.25rem 0 0;
  padding-left: 1.25rem;
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
}

.release-stats {
  display: flex;
  gap: 0.75rem;
  margin-top: 0.5rem;
  font-size: 0.7rem;
  color: var(--vp-c-text-3);
}

.stat-add { color: #22c55e; }
.stat-del { color: #ef4444; }
</style>
