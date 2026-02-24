import DefaultTheme from "vitepress/theme";
import KanbanBoard from "../../components/KanbanBoard.vue";
import FeatureProgress from "../../components/FeatureProgress.vue";
import CoverageGauge from "../../components/CoverageGauge.vue";
import ScoreTrend from "../../components/ScoreTrend.vue";
import AgentActivityPanel from "../../components/AgentActivityPanel.vue";
import StatsPage from "../../components/StatsPage.vue";
import TokenBreakdown from "../../components/TokenBreakdown.vue";
import AchievementsBoard from "../../components/AchievementsBoard.vue";

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component("KanbanBoard", KanbanBoard);
    app.component("FeatureProgress", FeatureProgress);
    app.component("CoverageGauge", CoverageGauge);
    app.component("ScoreTrend", ScoreTrend);
    app.component("AgentActivityPanel", AgentActivityPanel);
    app.component("StatsPage", StatsPage);
    app.component("TokenBreakdown", TokenBreakdown);
    app.component("AchievementsBoard", AchievementsBoard);
  },
};
