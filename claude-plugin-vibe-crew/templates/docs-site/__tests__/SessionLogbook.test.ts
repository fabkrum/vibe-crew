import { describe, it, expect } from "vitest";
import { mount } from "@vue/test-utils";
import SessionLogbook from "../components/SessionLogbook.vue";

function makeSession(overrides = {}) {
  return {
    session_id: "sess-001",
    started_at: "2026-02-15T10:30:00Z",
    feature_id: "feat-001",
    duration_minutes: 45,
    vibe_score: 85,
    task_summary: "Implemented login form",
    tokens: {
      input: 10000,
      cache_creation: 500,
      cache_read: 3000,
      output: 2000,
      estimated_cost_usd: 0.15,
    },
    agents_used: ["builder", "verifier"],
    ...overrides,
  };
}

function makeScores(scores = []) {
  return {
    scores,
    trend: { direction: "unknown", average: 0, count: 0 },
    topDeductions: [],
  };
}

function makeScoreEntry(overrides = {}) {
  return {
    session_id: "sess-001",
    timestamp: "2026-02-15T11:00:00Z",
    score: 85,
    rating: "good",
    feature_id: "feat-001",
    deductions: [{ category: "no-tests", points: -10, reason: "No tests" }],
    bonuses: [{ category: "clean-session", points: 5, reason: "Clean session" }],
    user_feedback: null,
    trend: null,
    ...overrides,
  };
}

describe("SessionLogbook", () => {
  it("shows empty state message when no sessions", () => {
    const wrapper = mount(SessionLogbook, {
      props: { sessions: [], scores: makeScores() },
    });
    expect(wrapper.text()).toContain("No sessions recorded yet");
    expect(wrapper.find(".logbook-list").exists()).toBe(false);
  });

  it("renders session rows with correct score colors", () => {
    const sessions = [
      makeSession({ session_id: "s1", vibe_score: 95 }),
      makeSession({ session_id: "s2", vibe_score: 75 }),
      makeSession({ session_id: "s3", vibe_score: 55 }),
      makeSession({ session_id: "s4", vibe_score: 30 }),
    ];
    const wrapper = mount(SessionLogbook, {
      props: { sessions, scores: makeScores() },
    });

    const badges = wrapper.findAll(".score-badge");
    expect(badges).toHaveLength(4);

    // Green for >= 90
    expect(badges[0].attributes("style")).toContain("rgb(34, 197, 94)");
    // Blue for >= 70
    expect(badges[1].attributes("style")).toContain("rgb(59, 130, 246)");
    // Yellow for >= 50
    expect(badges[2].attributes("style")).toContain("rgb(234, 179, 8)");
    // Red for < 50
    expect(badges[3].attributes("style")).toContain("rgb(239, 68, 68)");
  });

  it("expands and collapses on click", async () => {
    const sessions = [makeSession()];
    const scores = makeScores([makeScoreEntry()]);
    const wrapper = mount(SessionLogbook, {
      props: { sessions, scores },
    });

    // Initially collapsed
    expect(wrapper.find(".logbook-detail").exists()).toBe(false);

    // Click to expand
    await wrapper.find(".logbook-row").trigger("click");
    expect(wrapper.find(".logbook-detail").exists()).toBe(true);

    // Click again to collapse
    await wrapper.find(".logbook-row").trigger("click");
    expect(wrapper.find(".logbook-detail").exists()).toBe(false);
  });

  it("handles missing scores gracefully", async () => {
    const sessions = [makeSession({ session_id: "s-no-score" })];
    const scores = makeScores([]); // no matching score
    const wrapper = mount(SessionLogbook, {
      props: { sessions, scores },
    });

    // Expand
    await wrapper.find(".logbook-row").trigger("click");
    expect(wrapper.text()).toContain("Score unavailable");
  });

  it("joins scores with sessions by session_id", async () => {
    const sessions = [makeSession({ session_id: "s-matched" })];
    const scores = makeScores([
      makeScoreEntry({ session_id: "s-matched", score: 92, rating: "excellent" }),
    ]);
    const wrapper = mount(SessionLogbook, {
      props: { sessions, scores },
    });

    // Expand
    await wrapper.find(".logbook-row").trigger("click");
    expect(wrapper.text()).toContain("92");
    expect(wrapper.text()).toContain("excellent");
  });

  it("displays summary bar with session count and date range", () => {
    const sessions = [
      makeSession({ session_id: "s1", started_at: "2026-01-10T09:00:00Z" }),
      makeSession({ session_id: "s2", started_at: "2026-02-20T14:00:00Z" }),
    ];
    const wrapper = mount(SessionLogbook, {
      props: { sessions, scores: makeScores() },
    });
    expect(wrapper.text()).toContain("2 sessions");
    expect(wrapper.text()).toContain("Jan 10, 2026");
    expect(wrapper.text()).toContain("Feb 20, 2026");
  });

  it("sorts newest first by default", () => {
    const sessions = [
      makeSession({ session_id: "s-old", started_at: "2026-01-01T10:00:00Z" }),
      makeSession({ session_id: "s-new", started_at: "2026-03-01T10:00:00Z" }),
    ];
    const wrapper = mount(SessionLogbook, {
      props: { sessions, scores: makeScores() },
    });

    const rows = wrapper.findAll(".logbook-row");
    // Newest should be first
    expect(rows[0].text()).toContain("Mar 1, 2026");
    expect(rows[1].text()).toContain("Jan 1, 2026");
  });
});
