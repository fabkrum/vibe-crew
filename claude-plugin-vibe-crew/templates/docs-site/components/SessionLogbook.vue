<script setup>
import { ref, computed } from "vue";
import SessionLogbookEntry from "./SessionLogbookEntry.vue";

const props = defineProps({
  sessions: { type: Array, required: true },
  scores: { type: Object, required: true },
});

const sortOrder = ref("newest");
const featureFilter = ref("");
const visibleCount = ref(50);

// Build a map of session_id → score entry
const scoreMap = computed(() => {
  const map = new Map();
  for (const s of props.scores?.scores || []) {
    map.set(s.session_id, s);
  }
  return map;
});

// Unique feature IDs for filter dropdown
const featureIds = computed(() => {
  const ids = new Set();
  for (const s of props.sessions) {
    if (s.feature_id) ids.add(s.feature_id);
  }
  return Array.from(ids).sort();
});

const sortedSessions = computed(() => {
  let list = [...props.sessions];

  if (featureFilter.value) {
    list = list.filter((s) => s.feature_id === featureFilter.value);
  }

  list.sort((a, b) => {
    const ta = a.started_at || a.timestamp || "";
    const tb = b.started_at || b.timestamp || "";
    return sortOrder.value === "newest"
      ? tb.localeCompare(ta)
      : ta.localeCompare(tb);
  });

  return list;
});

const visibleSessions = computed(() =>
  sortedSessions.value.slice(0, visibleCount.value),
);

const dateRange = computed(() => {
  if (props.sessions.length === 0) return "";
  const dates = props.sessions
    .map((s) => s.started_at || s.timestamp || "")
    .filter(Boolean)
    .sort();
  if (dates.length === 0) return "";
  const first = formatDate(dates[0]);
  const last = formatDate(dates[dates.length - 1]);
  return first === last ? first : `${first} - ${last}`;
});

const expandedId = ref(null);

function toggleExpand(id) {
  expandedId.value = expandedId.value === id ? null : id;
}

function scoreForSession(session) {
  return scoreMap.value.get(session.session_id) || null;
}

function vibeScore(session) {
  const s = scoreForSession(session);
  if (s) return s.score;
  if (session.vibe_score != null) return session.vibe_score;
  return null;
}

function scoreColor(score) {
  if (score == null) return "var(--vp-c-text-3)";
  if (score >= 90) return "#22c55e";
  if (score >= 70) return "#3b82f6";
  if (score >= 50) return "#eab308";
  return "#ef4444";
}

function scoreBg(score) {
  if (score == null) return "var(--vp-c-bg-soft)";
  if (score >= 90) return "rgba(34, 197, 94, 0.1)";
  if (score >= 70) return "rgba(59, 130, 246, 0.1)";
  if (score >= 50) return "rgba(234, 179, 8, 0.1)";
  return "rgba(239, 68, 68, 0.1)";
}

function formatDate(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleDateString("en-US", {
    month: "short",
    day: "numeric",
    year: "numeric",
  });
}

function formatTime(iso) {
  if (!iso) return "";
  const d = new Date(iso);
  return d.toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
  });
}

function formatDuration(session) {
  const dur = session.duration_minutes || session.duration;
  if (!dur) return "";
  if (dur < 60) return `${Math.round(dur)}m`;
  const h = Math.floor(dur / 60);
  const m = Math.round(dur % 60);
  return m > 0 ? `${h}h ${m}m` : `${h}h`;
}

function loadMore() {
  visibleCount.value += 50;
}
</script>

<template>
  <div class="session-logbook">
    <!-- Empty state -->
    <div v-if="sessions.length === 0" class="logbook-empty">
      <p>No sessions recorded yet. Run <code>/wrap</code> to save your first session.</p>
    </div>

    <template v-else>
      <!-- Summary bar -->
      <div class="logbook-summary">
        <span class="summary-stat">{{ sessions.length }} sessions</span>
        <span v-if="dateRange" class="summary-date">{{ dateRange }}</span>
      </div>

      <!-- Controls -->
      <div class="logbook-controls">
        <button
          class="sort-btn"
          :class="{ active: sortOrder === 'newest' }"
          @click="sortOrder = 'newest'"
        >
          Newest
        </button>
        <button
          class="sort-btn"
          :class="{ active: sortOrder === 'oldest' }"
          @click="sortOrder = 'oldest'"
        >
          Oldest
        </button>
        <select
          v-if="featureIds.length > 0"
          v-model="featureFilter"
          class="feature-select"
        >
          <option value="">All features</option>
          <option v-for="fid in featureIds" :key="fid" :value="fid">
            {{ fid }}
          </option>
        </select>
      </div>

      <!-- Session list -->
      <div class="logbook-list">
        <div
          v-for="session in visibleSessions"
          :key="session.session_id"
          class="logbook-item"
          :class="{ expanded: expandedId === session.session_id }"
        >
          <!-- Collapsed row -->
          <div class="logbook-row" @click="toggleExpand(session.session_id)">
            <div class="row-left">
              <span class="row-date">
                {{ formatDate(session.started_at || session.timestamp) }}
              </span>
              <span class="row-time">
                {{ formatTime(session.started_at || session.timestamp) }}
              </span>
              <span v-if="session.feature_id" class="row-feature">
                {{ session.feature_id }}
              </span>
              <span v-if="formatDuration(session)" class="row-duration">
                {{ formatDuration(session) }}
              </span>
            </div>
            <div class="row-right">
              <span
                v-if="vibeScore(session) != null"
                class="score-badge"
                :style="{
                  color: scoreColor(vibeScore(session)),
                  background: scoreBg(vibeScore(session)),
                }"
              >
                {{ vibeScore(session) }}
              </span>
              <span v-else class="score-badge score-na">--</span>
              <span class="expand-icon">{{ expandedId === session.session_id ? '−' : '+' }}</span>
            </div>
          </div>

          <!-- Expanded detail -->
          <div v-if="expandedId === session.session_id" class="logbook-detail">
            <SessionLogbookEntry
              :session="session"
              :score="scoreForSession(session)"
            />
          </div>
        </div>
      </div>

      <!-- Load more -->
      <div v-if="visibleCount < sortedSessions.length" class="logbook-more">
        <button class="load-more-btn" @click="loadMore">
          Load more ({{ sortedSessions.length - visibleCount }} remaining)
        </button>
      </div>
    </template>
  </div>
</template>

<style scoped>
.session-logbook {
  padding: 1rem 0;
}

.logbook-empty {
  text-align: center;
  color: var(--vp-c-text-3);
  padding: 3rem 1rem;
}

.logbook-empty code {
  color: var(--vp-c-brand-1);
}

.logbook-summary {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.summary-stat {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.summary-date {
  font-size: 0.8rem;
  color: var(--vp-c-text-3);
}

.logbook-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.sort-btn {
  font-size: 0.75rem;
  padding: 0.3rem 0.6rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-2);
  cursor: pointer;
  transition: all 0.15s;
}

.sort-btn.active {
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  border-color: var(--vp-c-brand-1);
}

.feature-select {
  font-size: 0.75rem;
  padding: 0.3rem 0.5rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 4px;
  background: var(--vp-c-bg);
  color: var(--vp-c-text-1);
  margin-left: auto;
}

.logbook-list {
  display: flex;
  flex-direction: column;
  gap: 0.35rem;
}

.logbook-item {
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  overflow: hidden;
  transition: border-color 0.15s;
}

.logbook-item.expanded {
  border-color: var(--vp-c-brand-1);
}

.logbook-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0.65rem 0.85rem;
  cursor: pointer;
  background: var(--vp-c-bg);
  transition: background 0.1s;
}

.logbook-row:hover {
  background: var(--vp-c-bg-soft);
}

.row-left {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  flex-wrap: wrap;
}

.row-date {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--vp-c-text-1);
}

.row-time {
  font-size: 0.75rem;
  color: var(--vp-c-text-3);
}

.row-feature {
  font-size: 0.7rem;
  background: var(--vp-c-brand-soft);
  color: var(--vp-c-brand-1);
  padding: 0.1rem 0.4rem;
  border-radius: 4px;
  font-weight: 500;
}

.row-duration {
  font-size: 0.7rem;
  color: var(--vp-c-text-3);
}

.row-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.score-badge {
  font-size: 0.8rem;
  font-weight: 700;
  padding: 0.15rem 0.5rem;
  border-radius: 6px;
  min-width: 2rem;
  text-align: center;
}

.score-na {
  color: var(--vp-c-text-3);
  background: var(--vp-c-bg-soft);
}

.expand-icon {
  font-size: 1rem;
  color: var(--vp-c-text-3);
  width: 1.25rem;
  text-align: center;
}

.logbook-detail {
  padding: 0.75rem 0.85rem 1rem;
  border-top: 1px solid var(--vp-c-divider);
  background: var(--vp-c-bg-soft);
}

.logbook-more {
  text-align: center;
  padding: 1rem;
}

.load-more-btn {
  font-size: 0.8rem;
  padding: 0.4rem 1rem;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg);
  color: var(--vp-c-brand-1);
  cursor: pointer;
  transition: background 0.15s;
}

.load-more-btn:hover {
  background: var(--vp-c-brand-soft);
}
</style>
