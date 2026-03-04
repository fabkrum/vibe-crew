import DefaultTheme from "vitepress/theme";
import KanbanBoard from "../../components/KanbanBoard.vue";
import FeatureProgress from "../../components/FeatureProgress.vue";
import CoverageGauge from "../../components/CoverageGauge.vue";
import ScoreTrend from "../../components/ScoreTrend.vue";
import AgentActivityPanel from "../../components/AgentActivityPanel.vue";
import StatsPage from "../../components/StatsPage.vue";
import TokenBreakdown from "../../components/TokenBreakdown.vue";
import AchievementsBoard from "../../components/AchievementsBoard.vue";
import SettingsPanel from "../../components/SettingsPanel.vue";
import LiveSessionPanel from "../../components/LiveSessionPanel.vue";
import ArchitectureOverview from "../../components/ArchitectureOverview.vue";
import ProductFeatures from "../../components/ProductFeatures.vue";
import AboutPage from "../../components/AboutPage.vue";
import ReleasesTimeline from "../../components/ReleasesTimeline.vue";
import SessionLogbook from "../../components/SessionLogbook.vue";
import SessionLogbookEntry from "../../components/SessionLogbookEntry.vue";

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
    app.component("SettingsPanel", SettingsPanel);
    app.component("LiveSessionPanel", LiveSessionPanel);
    app.component("ArchitectureOverview", ArchitectureOverview);
    app.component("ProductFeatures", ProductFeatures);
    app.component("AboutPage", AboutPage);
    app.component("ReleasesTimeline", ReleasesTimeline);
    app.component("SessionLogbook", SessionLogbook);
    app.component("SessionLogbookEntry", SessionLogbookEntry);
  },
};
