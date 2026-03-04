<script setup>
import { computed } from "vue";

const props = defineProps({
  about: { type: Object, required: true },
  backlog: { type: Object, required: true },
  featureDocs: { type: Array, required: true },
});

const doneFeatures = computed(() => {
  if (!props.backlog?.features) return [];
  return props.backlog.features
    .filter((f) => f.column === "done" || f.column === "review")
    .sort((a, b) => (b.completed_at || "").localeCompare(a.completed_at || ""));
});

const hasFeatureDoc = computed(() => {
  const set = new Set(props.featureDocs || []);
  return (name) => {
    // Check if feature name matches any doc slug
    const slug = name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");
    return set.has(slug);
  };
});

const highlightedScripts = ["docs:dev", "docs:build", "docs:preview", "dev", "build", "start"];

const scriptEntries = computed(() => {
  const scripts = props.about?.dev_scripts || {};
  return Object.entries(scripts).sort((a, b) => {
    const aHighlight = highlightedScripts.includes(a[0]) ? 0 : 1;
    const bHighlight = highlightedScripts.includes(b[0]) ? 0 : 1;
    return aHighlight - bHighlight || a[0].localeCompare(b[0]);
  });
});

function renderMarkdown(text) {
  if (!text) return "";
  // Simple markdown: bold, inline code, line breaks
  return text
    .replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>")
    .replace(/`(.+?)`/g, "<code>$1</code>")
    .replace(/^[-*]\s+(.+)/gm, "<li>$1</li>")
    .replace(/(<li>.*<\/li>)/gs, "<ul>$1</ul>")
    .replace(/<\/ul>\s*<ul>/g, "")
    .replace(/\n\n/g, "</p><p>")
    .replace(/\n/g, "<br>");
}
</script>

<template>
  <div class="about-page">
    <!-- Hero -->
    <div class="about-card hero-card">
      <h2 class="hero-title">{{ about.vision.project_name }}</h2>
      <p v-if="about.vision.tagline" class="hero-tagline">{{ about.vision.tagline }}</p>
      <div
        v-if="about.vision.description"
        class="hero-desc"
        v-html="renderMarkdown(about.vision.description)"
      ></div>
      <p v-if="!about.has_vision" class="about-empty">
        Run <code>/new-project</code> to generate VISION.md
      </p>
    </div>

    <!-- Target Audience -->
    <div v-if="about.vision.target_audience" class="about-card">
      <h3 class="card-heading">Target Audience</h3>
      <div v-html="renderMarkdown(about.vision.target_audience)"></div>
    </div>

    <!-- Problems Solved -->
    <div v-if="about.vision.problems_solved" class="about-card">
      <h3 class="card-heading">Problems Solved</h3>
      <div v-html="renderMarkdown(about.vision.problems_solved)"></div>
    </div>

    <!-- Feature Showcase -->
    <div class="about-card">
      <h3 class="card-heading">Features</h3>
      <div v-if="doneFeatures.length > 0" class="feature-grid">
        <div v-for="f in doneFeatures" :key="f.id" class="feature-item">
          <div class="feature-name">{{ f.name }}</div>
          <p v-if="f.description" class="feature-desc">{{ f.description }}</p>
          <a
            v-if="hasFeatureDoc(f.name)"
            :href="`/features/${f.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '')}`"
            class="feature-link"
          >
            View docs
          </a>
        </div>
      </div>
      <p v-else class="about-empty">
        No completed features yet. Run <code>/new-feature "name"</code> to start building.
      </p>
    </div>

    <!-- Tech Stack -->
    <div v-if="about.tdr.tech_stack_summary" class="about-card">
      <h3 class="card-heading">Tech Stack</h3>
      <div v-html="renderMarkdown(about.tdr.tech_stack_summary)"></div>
    </div>
    <div v-else-if="!about.has_tdr" class="about-card">
      <h3 class="card-heading">Tech Stack</h3>
      <p class="about-empty">
        Run <code>/new-project</code> to generate the Technology Decision Record.
      </p>
    </div>

    <!-- Dev Server -->
    <div class="about-card">
      <h3 class="card-heading">Dev Server</h3>
      <div v-if="scriptEntries.length > 0" class="scripts-table-wrap">
        <table class="scripts-table">
          <thead>
            <tr>
              <th>Script</th>
              <th>Command</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="[name, cmd] in scriptEntries"
              :key="name"
              :class="{ highlighted: highlightedScripts.includes(name) }"
            >
              <td><code>npm run {{ name }}</code></td>
              <td class="cmd-cell">{{ cmd }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="dev-info">
        <p>
          Run <code>npm run docs:dev</code> to start the dashboard in dev mode.
          Data auto-updates when <code>.vibecrew/</code> files change via the file watcher.
        </p>
        <p>
          For a static preview: <code>npm run docs:build && npm run docs:preview</code>
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.about-page {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  padding: 1rem 0;
}

.about-card {
  background: var(--vp-c-bg-soft);
  border-radius: 8px;
  padding: 1.5rem;
}

.hero-card {
  text-align: center;
  padding: 2rem 1.5rem;
}

.hero-title {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 0 0.5rem;
  color: var(--vp-c-text-1);
}

.hero-tagline {
  font-size: 1rem;
  color: var(--vp-c-text-2);
  margin: 0 0 1rem;
}

.hero-desc {
  font-size: 0.9rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  max-width: 600px;
  margin: 0 auto;
}

.card-heading {
  font-size: 0.85rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--vp-c-text-2);
  margin: 0 0 0.75rem;
}

.about-empty {
  color: var(--vp-c-text-3);
  font-size: 0.85rem;
  margin: 0;
}

.about-empty code {
  color: var(--vp-c-brand-1);
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 0.75rem;
}

.feature-item {
  background: var(--vp-c-bg);
  border-radius: 6px;
  padding: 0.85rem;
}

.feature-name {
  font-weight: 600;
  font-size: 0.875rem;
  color: var(--vp-c-text-1);
  margin-bottom: 0.25rem;
}

.feature-desc {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  margin: 0 0 0.35rem;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.feature-link {
  font-size: 0.75rem;
  color: var(--vp-c-brand-1);
}

.scripts-table-wrap {
  overflow-x: auto;
  margin-bottom: 0.75rem;
}

.scripts-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.8rem;
}

.scripts-table th {
  text-align: left;
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--vp-c-text-3);
  padding: 0.5rem 0.75rem;
  border-bottom: 1px solid var(--vp-c-divider);
}

.scripts-table td {
  padding: 0.4rem 0.75rem;
  border-bottom: 1px solid var(--vp-c-divider);
  color: var(--vp-c-text-2);
}

.scripts-table tr.highlighted td {
  background: var(--vp-c-brand-soft);
}

.scripts-table code {
  font-size: 0.75rem;
  color: var(--vp-c-brand-1);
}

.cmd-cell {
  font-family: var(--vp-font-family-mono);
  font-size: 0.75rem;
}

.dev-info {
  font-size: 0.8rem;
  color: var(--vp-c-text-2);
  line-height: 1.5;
}

.dev-info p {
  margin: 0 0 0.5rem;
}

.dev-info code {
  font-size: 0.75rem;
  color: var(--vp-c-brand-1);
}

/* Markdown rendering */
.about-card :deep(p) {
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin: 0 0 0.5rem;
}

.about-card :deep(ul) {
  padding-left: 1.25rem;
  font-size: 0.85rem;
  color: var(--vp-c-text-2);
  line-height: 1.6;
  margin: 0 0 0.5rem;
}

.about-card :deep(code) {
  font-size: 0.8rem;
  color: var(--vp-c-brand-1);
}
</style>
