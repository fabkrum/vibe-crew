<script setup lang="ts">
import { reactive, computed, ref, watch, onMounted, onUnmounted } from "vue";
import type { ConfigData } from "../data/config.data";

// ── Props ─────────────────────────────────────────────────────────────────────

const props = defineProps<{ data: ConfigData }>();

// ── State ─────────────────────────────────────────────────────────────────────

const form = reactive<ConfigData>(structuredClone(props.data));
const saveStatus = ref<"idle" | "saving" | "saved" | "error">("idle");
const errorMessage = ref("");
const showCopyModal = ref(false);
let saveTimeout: ReturnType<typeof setTimeout> | null = null;

// Sync form when data prop changes (HMR / external edit)
watch(
  () => props.data,
  (newData) => {
    Object.assign(form, structuredClone(newData));
    saveStatus.value = "idle";
  },
  { deep: true },
);

// ── Dirty detection ──────────────────────────────────────────────────────────

const dirty = computed(() => {
  return JSON.stringify(form) !== JSON.stringify(props.data);
});

// ── Gamification sync ────────────────────────────────────────────────────────

watch(
  () => form.user_profile.gamification_preference,
  (pref) => {
    if (!pref) return;
    switch (pref) {
      case "disabled":
        form.gamification.enabled = false;
        form.gamification.show_xp_in_status = false;
        form.gamification.streak_reminders = false;
        break;
      case "score_only":
        form.gamification.enabled = true;
        form.gamification.show_xp_in_status = false;
        form.gamification.streak_reminders = false;
        break;
      case "light":
        form.gamification.enabled = true;
        form.gamification.show_xp_in_status = true;
        form.gamification.streak_reminders = false;
        break;
      case "full":
        form.gamification.enabled = true;
        form.gamification.show_xp_in_status = true;
        form.gamification.streak_reminders = true;
        break;
    }
  },
);

// ── Unsaved changes warning ──────────────────────────────────────────────────

function beforeUnload(e: BeforeUnloadEvent) {
  if (dirty.value) {
    e.preventDefault();
  }
}

onMounted(() => window.addEventListener("beforeunload", beforeUnload));
onUnmounted(() => window.removeEventListener("beforeunload", beforeUnload));

// ── Save / Reset ─────────────────────────────────────────────────────────────

async function save() {
  if (saveTimeout) clearTimeout(saveTimeout);
  saveStatus.value = "saving";

  // Mark profile as completed if any dimension is set
  const p = form.user_profile;
  if (p.code_literacy || p.autonomy || p.pr_review || p.verbosity || p.gamification_preference || p.learning || p.risk_tolerance) {
    form.user_profile.interview_completed = true;
    form.user_profile.updated_at = new Date().toISOString();
  }

  try {
    const res = await fetch("/api/save-config", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form),
    });

    if (!res.ok) {
      // Static build fallback — API doesn't exist
      if (res.status === 404 || res.status === 405) {
        showCopyModal.value = true;
        saveStatus.value = "idle";
        return;
      }
      const body = await res.json().catch(() => ({ error: "Save failed" }));
      throw new Error(body.error || `HTTP ${res.status}`);
    }

    saveStatus.value = "saved";
    saveTimeout = setTimeout(() => (saveStatus.value = "idle"), 2500);
  } catch (err: any) {
    // Network error likely means static build
    if (err.name === "TypeError" && err.message.includes("fetch")) {
      showCopyModal.value = true;
      saveStatus.value = "idle";
      return;
    }
    saveStatus.value = "error";
    errorMessage.value = err.message || "Save failed";
    saveTimeout = setTimeout(() => (saveStatus.value = "idle"), 4000);
  }
}

function resetToDefaults() {
  const defaultConfig: ConfigData = {
    schema_version: form.schema_version,
    terminal: form.terminal,
    claude_command: "claude",
    notifications: { enabled: true, sound: "Submarine", on_permission_prompt: true, on_task_complete: true, on_failure: true },
    concurrency: { max_parallel_agents: 3 },
    mcp_servers: { context7: true, chrome_devtools: true, playwright: true, semgrep: false, sentry: false, supabase: false, stripe: false, vercel: false, figma: false },
    mcp_discovery: { auto_recommend: true, auto_add: false },
    formatting: { auto_format: true, formatter: "prettier" },
    context_warnings: { warn_at_percent: 60, critical_at_percent: 80 },
    cost_limits: { session_warn_usd: 2.0, session_max_usd: 5.0, daily_warn_usd: 20.0 },
    performance_coach: { enabled: true, min_sessions_for_trends: 3, min_sessions_for_mutations: 5 },
    doc_generator: { auto_changelog: true, auto_feature_docs: true, auto_sidebar_rebuild: true },
    onboarding: { show_hints: true, dismissed_hints: [] },
    audit: { auto_github_issues: false, severity_threshold: "high" },
    opponent_processor: { enabled: true, auto_invoke_after_tdr: true },
    ci_healing: { enabled: true, max_attempts: 3, auto_checkpoint: true },
    gamification: { enabled: true, streak_reminders: false, quiz_frequency: "weekly", show_xp_in_status: true },
    user_profile: { interview_completed: false, code_literacy: null, autonomy: null, pr_review: null, verbosity: null, gamification_preference: null, learning: null, risk_tolerance: null, updated_at: null },
  };
  Object.assign(form, structuredClone(defaultConfig));
}

// ── Copy modal ───────────────────────────────────────────────────────────────

const configJson = computed(() => JSON.stringify(form, null, 2));

function copyToClipboard() {
  navigator.clipboard.writeText(configJson.value);
}

// ── Profile dimension metadata ───────────────────────────────────────────────

const profileDimensions = [
  { key: "code_literacy", label: "Code Literacy", description: "How comfortable you are reading and writing code.", options: ["fluent", "conversational", "basic", "none"] },
  { key: "autonomy", label: "Autonomy", description: "How much VibeCrew should do without asking you.", options: ["full_auto", "checkpoints", "collaborative", "supervised"] },
  { key: "pr_review", label: "PR Review", description: "How pull requests should be handled.", options: ["auto_merge", "summary", "review", "walkthrough"] },
  { key: "verbosity", label: "Verbosity", description: "How much detail in agent output and status messages.", options: ["minimal", "standard", "detailed", "educational"] },
  { key: "gamification_preference", label: "Gamification", description: "How much gamification (scores, XP, badges) to show.", options: ["full", "light", "score_only", "disabled"] },
  { key: "learning", label: "Learning", description: "How much teaching and explanation to include.", options: ["none", "reference_docs", "inline", "teach"] },
  { key: "risk_tolerance", label: "Risk Tolerance", description: "Technology maturity preference for Stack Scout.", options: ["conservative", "balanced", "progressive", "experimental"] },
] as const;

// ── MCP server metadata ─────────────────────────────────────────────────────

const mcpServers = [
  { key: "context7", label: "Context7", description: "Library documentation lookup" },
  { key: "chrome_devtools", label: "Chrome DevTools", description: "Browser debugging and inspection" },
  { key: "playwright", label: "Playwright", description: "Browser automation and E2E testing" },
  { key: "semgrep", label: "Semgrep", description: "Static analysis security scanning" },
  { key: "sentry", label: "Sentry", description: "Error tracking and monitoring" },
  { key: "supabase", label: "Supabase", description: "Database and auth management" },
  { key: "stripe", label: "Stripe", description: "Payment integration" },
  { key: "vercel", label: "Vercel", description: "Deployment and hosting" },
  { key: "figma", label: "Figma", description: "Design file access" },
];

// ── Formatter options ────────────────────────────────────────────────────────

const formatterOptions = ["prettier", "biome", "eslint", "none"];
const quizFrequencyOptions = ["daily", "weekly", "monthly", "never"];
const severityOptions = ["critical", "high", "medium", "low"];
const soundOptions = ["Submarine", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Tink"];
</script>

<template>
  <div class="settings-panel">

    <!-- ── 1. User Profile ──────────────────────────────────────────────── -->
    <section class="section" aria-label="User profile settings">
      <h3 class="section-title">User Profile</h3>
      <p class="section-desc">These preferences shape how every agent communicates with you.</p>

      <div class="profile-grid">
        <div
          v-for="dim in profileDimensions"
          :key="dim.key"
          class="profile-row"
        >
          <div class="profile-label">
            <span class="label-text">{{ dim.label }}</span>
            <span class="label-desc">{{ dim.description }}</span>
          </div>
          <div class="pill-group" role="radiogroup" :aria-label="dim.label">
            <button
              v-for="opt in dim.options"
              :key="opt"
              :class="['pill', { active: form.user_profile[dim.key] === opt }]"
              :aria-pressed="form.user_profile[dim.key] === opt"
              @click="(form.user_profile as any)[dim.key] = form.user_profile[dim.key] === opt ? null : opt"
            >
              {{ opt.replace(/_/g, ' ') }}
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- ── 2. Terminal ─────────────────────────────────────────────────── -->
    <section class="section" aria-label="Terminal settings">
      <h3 class="section-title">Terminal</h3>
      <p class="section-desc">Configure the Claude Code command used in Warp launch configurations and startup scripts.</p>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Claude Command</span>
            <span class="label-desc">The command to launch Claude Code (e.g. <code>claude</code>, <code>claude-p</code>, <code>claude-w</code>)</span>
          </label>
          <input
            type="text"
            v-model="form.claude_command"
            placeholder="claude"
            class="text-input"
          >
        </div>
      </div>
    </section>

    <!-- ── 3. Notifications ─────────────────────────────────────────────── -->
    <section class="section" aria-label="Notification settings">
      <h3 class="section-title">Notifications</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Enabled</span>
            <span class="label-desc">Enable desktop notifications</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.notifications.enabled">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Sound</span>
            <span class="label-desc">macOS notification sound</span>
          </label>
          <select v-model="form.notifications.sound" class="select-input">
            <option v-for="s in soundOptions" :key="s" :value="s">{{ s }}</option>
          </select>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">On Permission Prompt</span>
            <span class="label-desc">Notify when agent needs approval</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.notifications.on_permission_prompt">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">On Task Complete</span>
            <span class="label-desc">Notify when a task finishes</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.notifications.on_task_complete">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">On Failure</span>
            <span class="label-desc">Notify on critical errors</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.notifications.on_failure">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>
      </div>
    </section>

    <!-- ── 3. Cost & Context ────────────────────────────────────────────── -->
    <section class="section" aria-label="Cost and context settings">
      <h3 class="section-title">Cost & Context Limits</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Session Warning</span>
            <span class="label-desc">Warn when session cost reaches this (USD)</span>
          </label>
          <div class="number-input-wrap">
            <span class="input-prefix">$</span>
            <input type="number" v-model.number="form.cost_limits.session_warn_usd" min="0" step="0.5" class="number-input">
          </div>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Session Max</span>
            <span class="label-desc">Hard stop at this session cost (USD)</span>
          </label>
          <div class="number-input-wrap">
            <span class="input-prefix">$</span>
            <input type="number" v-model.number="form.cost_limits.session_max_usd" min="0" step="0.5" class="number-input">
          </div>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Daily Warning</span>
            <span class="label-desc">Warn when daily spend reaches this (USD)</span>
          </label>
          <div class="number-input-wrap">
            <span class="input-prefix">$</span>
            <input type="number" v-model.number="form.cost_limits.daily_warn_usd" min="0" step="1" class="number-input">
          </div>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Context Warning</span>
            <span class="label-desc">Warn at this context window usage (%)</span>
          </label>
          <div class="number-input-wrap">
            <input type="number" v-model.number="form.context_warnings.warn_at_percent" min="10" max="100" step="5" class="number-input">
            <span class="input-suffix">%</span>
          </div>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Context Critical</span>
            <span class="label-desc">Critical warning at this usage (%)</span>
          </label>
          <div class="number-input-wrap">
            <input type="number" v-model.number="form.context_warnings.critical_at_percent" min="10" max="100" step="5" class="number-input">
            <span class="input-suffix">%</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ── 4. Agent Behavior ────────────────────────────────────────────── -->
    <section class="section" aria-label="Agent behavior settings">
      <h3 class="section-title">Agent Behavior</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Max Parallel Agents</span>
            <span class="label-desc">Maximum concurrent subagent sessions (1-5)</span>
          </label>
          <input type="number" v-model.number="form.concurrency.max_parallel_agents" min="1" max="5" step="1" class="number-input">
        </div>

        <h4 class="subsection-title">Performance Coach</h4>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Enabled</span>
            <span class="label-desc">Cross-session trend analysis and CLAUDE.md mutations</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.performance_coach.enabled">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Min Sessions for Trends</span>
            <span class="label-desc">Sessions needed before trend analysis</span>
          </label>
          <input type="number" v-model.number="form.performance_coach.min_sessions_for_trends" min="1" max="20" step="1" class="number-input">
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Min Sessions for Mutations</span>
            <span class="label-desc">Sessions needed before CLAUDE.md proposals</span>
          </label>
          <input type="number" v-model.number="form.performance_coach.min_sessions_for_mutations" min="1" max="20" step="1" class="number-input">
        </div>

        <h4 class="subsection-title">Opponent Processor</h4>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Enabled</span>
            <span class="label-desc">Devil's advocate analysis for decisions</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.opponent_processor.enabled">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto-invoke After TDR</span>
            <span class="label-desc">Run opponent analysis after every TDR</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.opponent_processor.auto_invoke_after_tdr">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <h4 class="subsection-title">CI Healing</h4>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Enabled</span>
            <span class="label-desc">Automatic CI failure diagnosis and repair</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.ci_healing.enabled">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Max Attempts</span>
            <span class="label-desc">Maximum repair attempts per failure</span>
          </label>
          <input type="number" v-model.number="form.ci_healing.max_attempts" min="1" max="10" step="1" class="number-input">
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto-checkpoint</span>
            <span class="label-desc">Create git checkpoint before repair</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.ci_healing.auto_checkpoint">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>
      </div>
    </section>

    <!-- ── 5. Code Quality ──────────────────────────────────────────────── -->
    <section class="section" aria-label="Code quality settings">
      <h3 class="section-title">Code Quality</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto-format</span>
            <span class="label-desc">Automatically format files after writing</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.formatting.auto_format">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Formatter</span>
            <span class="label-desc">Code formatting tool</span>
          </label>
          <div class="pill-group" role="radiogroup" aria-label="Formatter">
            <button
              v-for="opt in formatterOptions"
              :key="opt"
              :class="['pill', { active: form.formatting.formatter === opt }]"
              :aria-pressed="form.formatting.formatter === opt"
              @click="form.formatting.formatter = opt"
            >
              {{ opt }}
            </button>
          </div>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto-changelog</span>
            <span class="label-desc">Generate CHANGELOG entries on /wrap</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.doc_generator.auto_changelog">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto Feature Docs</span>
            <span class="label-desc">Generate feature documentation on /wrap</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.doc_generator.auto_feature_docs">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto Sidebar Rebuild</span>
            <span class="label-desc">Regenerate VitePress sidebar when docs change</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.doc_generator.auto_sidebar_rebuild">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>
      </div>
    </section>

    <!-- ── 6. MCP Servers ───────────────────────────────────────────────── -->
    <section class="section" aria-label="MCP server settings">
      <h3 class="section-title">MCP Servers</h3>
      <p class="section-desc">Enable or disable Model Context Protocol servers.</p>

      <div class="mcp-grid">
        <div
          v-for="server in mcpServers"
          :key="server.key"
          class="mcp-item"
        >
          <label class="toggle">
            <input type="checkbox" v-model="form.mcp_servers[server.key]">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
          <div class="mcp-info">
            <span class="label-text">{{ server.label }}</span>
            <span class="label-desc">{{ server.description }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ── 7. MCP Discovery ─────────────────────────────────────────────── -->
    <section class="section" aria-label="MCP discovery settings">
      <h3 class="section-title">MCP Discovery</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto-recommend</span>
            <span class="label-desc">Suggest MCP servers from TDR analysis</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.mcp_discovery.auto_recommend">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto-add</span>
            <span class="label-desc">Automatically add recommended servers</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.mcp_discovery.auto_add">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>
      </div>
    </section>

    <!-- ── 8. Gamification ──────────────────────────────────────────────── -->
    <section class="section" aria-label="Gamification settings">
      <h3 class="section-title">Gamification</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Enabled</span>
            <span class="label-desc">Enable Vibe Score gamification</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.gamification.enabled">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Streak Reminders</span>
            <span class="label-desc">Remind about daily session streaks</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.gamification.streak_reminders">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Quiz Frequency</span>
            <span class="label-desc">How often to offer code quizzes</span>
          </label>
          <div class="pill-group" role="radiogroup" aria-label="Quiz frequency">
            <button
              v-for="opt in quizFrequencyOptions"
              :key="opt"
              :class="['pill', { active: form.gamification.quiz_frequency === opt }]"
              :aria-pressed="form.gamification.quiz_frequency === opt"
              @click="form.gamification.quiz_frequency = opt"
            >
              {{ opt }}
            </button>
          </div>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Show XP in Status</span>
            <span class="label-desc">Display XP progress in session status</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.gamification.show_xp_in_status">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>
      </div>
    </section>

    <!-- ── 9. Onboarding & Audit ────────────────────────────────────────── -->
    <section class="section" aria-label="Onboarding and audit settings">
      <h3 class="section-title">Onboarding & Audit</h3>

      <div class="field-grid">
        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Show Hints</span>
            <span class="label-desc">Display onboarding hints for new users</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.onboarding.show_hints">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Auto GitHub Issues</span>
            <span class="label-desc">Create GitHub issues from audit findings</span>
          </label>
          <label class="toggle">
            <input type="checkbox" v-model="form.audit.auto_github_issues">
            <span class="toggle-track"><span class="toggle-knob" /></span>
          </label>
        </div>

        <div class="field-row">
          <label class="field-label">
            <span class="label-text">Severity Threshold</span>
            <span class="label-desc">Minimum severity to report</span>
          </label>
          <div class="pill-group" role="radiogroup" aria-label="Severity threshold">
            <button
              v-for="opt in severityOptions"
              :key="opt"
              :class="['pill', { active: form.audit.severity_threshold === opt }]"
              :aria-pressed="form.audit.severity_threshold === opt"
              @click="form.audit.severity_threshold = opt"
            >
              {{ opt }}
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- ── 10. Actions ──────────────────────────────────────────────────── -->
    <section class="actions-bar">
      <button class="btn btn-secondary" @click="resetToDefaults">
        Reset to Defaults
      </button>

      <div class="save-group">
        <span v-if="saveStatus === 'saved'" class="status-msg status-saved">Saved</span>
        <span v-else-if="saveStatus === 'error'" class="status-msg status-error">{{ errorMessage }}</span>

        <button
          class="btn btn-primary"
          :disabled="!dirty || saveStatus === 'saving'"
          @click="save"
        >
          <span v-if="saveStatus === 'saving'" class="spinner" />
          {{ saveStatus === 'saving' ? 'Saving...' : 'Save Changes' }}
        </button>
      </div>
    </section>

    <!-- ── Copy Modal (static build fallback) ───────────────────────────── -->
    <Teleport to="body">
      <div v-if="showCopyModal" class="modal-overlay" @click.self="showCopyModal = false">
        <div class="modal">
          <h3 class="modal-title">Save Unavailable in Static Mode</h3>
          <p class="modal-desc">
            The save API is only available during <code>vitepress dev</code>.
            Copy the configuration below and save it manually.
          </p>

          <div class="modal-code-wrap">
            <pre class="modal-code">{{ configJson }}</pre>
          </div>

          <div class="modal-actions">
            <button class="btn btn-secondary" @click="copyToClipboard">Copy JSON</button>
            <button class="btn btn-primary" @click="showCopyModal = false">Close</button>
          </div>

          <p class="modal-hint">
            Save to: <code>.vibecrew/config.json</code>
          </p>
        </div>
      </div>
    </Teleport>

  </div>
</template>

<style scoped>
/* ── Design tokens ─────────────────────────────────────────────────────────── */
.settings-panel {
  --sp-bg: var(--vp-c-bg-soft, #f8fafc);
  --sp-border: var(--vp-c-divider, #e2e8f0);
  --sp-text-1: var(--vp-c-text-1, #1e293b);
  --sp-text-2: var(--vp-c-text-2, #64748b);
  --sp-text-3: var(--vp-c-text-3, #94a3b8);
  --sp-accent: #3B82F6;
  --sp-accent-soft: rgba(59, 130, 246, 0.1);
  --sp-success: #22c55e;
  --sp-error: #ef4444;
  --sp-radius: 10px;

  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  padding: 0.5rem 0;
  font-family: inherit;
  color: var(--sp-text-1);
}

@media (prefers-color-scheme: dark) {
  .settings-panel {
    --sp-bg: var(--vp-c-bg-soft, #1e293b);
    --sp-border: var(--vp-c-divider, #334155);
    --sp-text-1: var(--vp-c-text-1, #f1f5f9);
    --sp-text-2: var(--vp-c-text-2, #94a3b8);
    --sp-text-3: var(--vp-c-text-3, #64748b);
    --sp-accent-soft: rgba(59, 130, 246, 0.15);
  }
}

/* ── Section ───────────────────────────────────────────────────────────────── */
.section {
  background: var(--sp-bg);
  border: 1px solid var(--sp-border);
  border-radius: var(--sp-radius);
  padding: 1.25rem 1.5rem;
}

.section-title {
  margin: 0 0 0.25rem;
  font-size: 1rem;
  font-weight: 600;
  color: var(--sp-text-1);
}

.section-desc {
  margin: 0 0 1rem;
  font-size: 0.8rem;
  color: var(--sp-text-2);
}

.subsection-title {
  margin: 0.75rem 0 0.25rem;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--sp-text-2);
  text-transform: uppercase;
  letter-spacing: 0.04em;
  padding-top: 0.5rem;
  border-top: 1px solid var(--sp-border);
}

/* ── Profile grid ──────────────────────────────────────────────────────────── */
.profile-grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.profile-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--sp-border);
}

.profile-row:last-child {
  padding-bottom: 0;
  border-bottom: none;
}

.profile-label {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
  min-width: 160px;
  flex-shrink: 0;
}

/* ── Field grid ────────────────────────────────────────────────────────────── */
.field-grid {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.field-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  min-height: 36px;
}

.field-label {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
  flex: 1;
  min-width: 0;
}

.label-text {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--sp-text-1);
}

.label-desc {
  font-size: 0.75rem;
  color: var(--sp-text-2);
  line-height: 1.3;
}

/* ── Pills ─────────────────────────────────────────────────────────────────── */
.pill-group {
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
}

.pill {
  padding: 0.3em 0.7em;
  border-radius: 999px;
  border: 1px solid var(--sp-border);
  background: transparent;
  color: var(--sp-text-2);
  cursor: pointer;
  font-size: 0.75rem;
  font-weight: 500;
  white-space: nowrap;
  transition: background 0.15s, color 0.15s, border-color 0.15s;
  text-transform: capitalize;
}

.pill:hover {
  background: var(--sp-border);
}

.pill.active {
  background: var(--sp-accent);
  border-color: var(--sp-accent);
  color: #fff;
}

/* ── Toggle switch ─────────────────────────────────────────────────────────── */
.toggle {
  position: relative;
  display: inline-flex;
  cursor: pointer;
  flex-shrink: 0;
}

.toggle input {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.toggle-track {
  width: 44px;
  height: 24px;
  border-radius: 12px;
  background: var(--sp-border);
  position: relative;
  transition: background 0.2s;
}

.toggle input:checked + .toggle-track {
  background: var(--sp-accent);
}

.toggle-knob {
  position: absolute;
  top: 3px;
  left: 3px;
  width: 18px;
  height: 18px;
  border-radius: 50%;
  background: #fff;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
  transition: transform 0.2s;
}

.toggle input:checked + .toggle-track .toggle-knob {
  transform: translateX(20px);
}

/* ── Number inputs ─────────────────────────────────────────────────────────── */
.number-input-wrap {
  display: flex;
  align-items: center;
  gap: 0;
  background: var(--sp-bg);
  border: 1px solid var(--sp-border);
  border-radius: 6px;
  overflow: hidden;
}

.number-input-wrap:focus-within {
  border-color: var(--sp-accent);
}

.input-prefix,
.input-suffix {
  padding: 0.3em 0.5em;
  font-size: 0.8rem;
  color: var(--sp-text-3);
  font-weight: 600;
}

.number-input {
  width: 80px;
  padding: 0.35em 0.5em;
  border: 1px solid var(--sp-border);
  border-radius: 6px;
  background: var(--sp-bg);
  color: var(--sp-text-1);
  font-family: ui-monospace, monospace;
  font-size: 0.85rem;
  text-align: right;
}

.number-input:focus {
  outline: none;
  border-color: var(--sp-accent);
}

.number-input-wrap .number-input {
  border: none;
  border-radius: 0;
}

.number-input-wrap .number-input:focus {
  outline: none;
}

/* ── Text input ───────────────────────────────────────────────────────────── */
.text-input {
  padding: 0.35em 0.6em;
  border: 1px solid var(--sp-border);
  border-radius: 6px;
  background: var(--sp-bg);
  color: var(--sp-text-1);
  font-family: ui-monospace, monospace;
  font-size: 0.85rem;
  min-width: 140px;
}

.text-input:focus {
  outline: none;
  border-color: var(--sp-accent);
}

/* ── Select input ──────────────────────────────────────────────────────────── */
.select-input {
  padding: 0.35em 1.8em 0.35em 0.6em;
  border: 1px solid var(--sp-border);
  border-radius: 6px;
  background: var(--sp-bg);
  color: var(--sp-text-1);
  font-size: 0.85rem;
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%2364748b' d='M6 8.5L1 3.5h10z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 0.5em center;
}

.select-input:focus {
  outline: none;
  border-color: var(--sp-accent);
}

/* ── MCP grid ──────────────────────────────────────────────────────────────── */
.mcp-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
}

@media (max-width: 600px) {
  .mcp-grid {
    grid-template-columns: 1fr;
  }
}

.mcp-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--sp-border);
  border-radius: 8px;
}

.mcp-info {
  display: flex;
  flex-direction: column;
  gap: 0.1rem;
  min-width: 0;
}

/* ── Actions bar ───────────────────────────────────────────────────────────── */
.actions-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
  border-top: 1px solid var(--sp-border);
}

.save-group {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.btn {
  padding: 0.5em 1.25em;
  border-radius: 8px;
  border: 1px solid var(--sp-border);
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s, opacity 0.15s;
  display: inline-flex;
  align-items: center;
  gap: 0.4em;
}

.btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.btn-primary {
  background: var(--sp-accent);
  border-color: var(--sp-accent);
  color: #fff;
}

.btn-primary:hover:not(:disabled) {
  opacity: 0.9;
}

.btn-secondary {
  background: transparent;
  color: var(--sp-text-2);
}

.btn-secondary:hover {
  background: var(--sp-border);
}

.status-msg {
  font-size: 0.8rem;
  font-weight: 600;
}

.status-saved {
  color: var(--sp-success);
}

.status-error {
  color: var(--sp-error);
}

.spinner {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.6s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* ── Modal ─────────────────────────────────────────────────────────────────── */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}

.modal {
  background: var(--vp-c-bg, #fff);
  border-radius: 12px;
  padding: 1.5rem;
  max-width: 600px;
  width: 100%;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.modal-title {
  margin: 0 0 0.5rem;
  font-size: 1.1rem;
  font-weight: 700;
  color: var(--sp-text-1);
}

.modal-desc {
  margin: 0 0 1rem;
  font-size: 0.85rem;
  color: var(--sp-text-2);
}

.modal-code-wrap {
  flex: 1;
  overflow: auto;
  margin-bottom: 1rem;
  border: 1px solid var(--sp-border);
  border-radius: 8px;
}

.modal-code {
  margin: 0;
  padding: 1rem;
  font-size: 0.75rem;
  font-family: ui-monospace, monospace;
  white-space: pre;
  color: var(--sp-text-1);
  background: var(--sp-bg);
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

.modal-hint {
  margin: 0.75rem 0 0;
  font-size: 0.75rem;
  color: var(--sp-text-3);
}

.modal-hint code {
  background: var(--sp-border);
  padding: 0.1em 0.4em;
  border-radius: 4px;
  font-size: 0.85em;
}

/* ── Responsive ────────────────────────────────────────────────────────────── */
@media (max-width: 768px) {
  .profile-row {
    flex-direction: column;
    align-items: flex-start;
  }

  .field-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }

  .actions-bar {
    flex-direction: column;
    gap: 0.75rem;
  }

  .save-group {
    width: 100%;
    justify-content: flex-end;
  }
}
</style>
