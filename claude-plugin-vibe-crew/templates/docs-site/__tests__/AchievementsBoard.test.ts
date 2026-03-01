import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { mount } from '@vue/test-utils'
import AchievementsBoard from '../components/AchievementsBoard.vue'
import type { GamificationData } from '../data/gamification.data'

function makeData(overrides: Partial<GamificationData> = {}): GamificationData {
  return {
    profile: {
      level: 5,
      title: 'Builder',
      xp: 150,
      xp_to_next_level: 300,
      xp_total: 550,
      current_streak: 3,
      longest_streak: 7,
      last_session_date: new Date().toISOString().slice(0, 10),
      total_sessions: 10,
      total_features: 4,
      best_score: 92,
    },
    badges: [
      { id: 'b1', category: 'milestone', name: 'First Steps', description: 'Setup', earned: true, earned_at: '2026-01-01', progress: 1, progress_label: null },
      { id: 'b2', category: 'milestone', name: 'Architect', description: 'Foundation', earned: false, earned_at: null, progress: 0.5, progress_label: '50%' },
      { id: 'b3', category: 'skill', name: 'Clean Session', description: 'Score 90+', earned: true, earned_at: '2026-02-01', progress: 1, progress_label: null },
      { id: 'b4', category: 'special', name: 'Perfect', description: 'Score 100', earned: false, earned_at: null, progress: 0, progress_label: null },
    ],
    skills: {
      clean_code: { name: 'Clean Code', level: 3, xp: 200 },
      research_first: { name: 'Research First', level: 2, xp: 100 },
      tdd: { name: 'TDD', level: 1, xp: 50 },
      context_efficiency: { name: 'Context Efficiency', level: 4, xp: 300 },
      documentation: { name: 'Documentation', level: 2, xp: 120 },
    },
    challenges: [],
    calendar: [],
    sparkline: [],
    scoreTrend: { direction: 'stable', average: 82 },
    ...overrides,
  }
}

describe('AchievementsBoard', () => {
  describe('tierColor', () => {
    it('returns correct colors for level ranges', () => {
      // Levels 1-3: gray
      const l1 = mount(AchievementsBoard, { props: { data: makeData({ profile: { ...makeData().profile, level: 1 } }) } })
      expect(l1.find('.level-badge').attributes('style')).toContain('rgb(107, 114, 128)')

      // Levels 4-8: blue
      const l5 = mount(AchievementsBoard, { props: { data: makeData({ profile: { ...makeData().profile, level: 5 } }) } })
      expect(l5.find('.level-badge').attributes('style')).toContain('rgb(59, 130, 246)')

      // Levels 9-18: purple
      const l10 = mount(AchievementsBoard, { props: { data: makeData({ profile: { ...makeData().profile, level: 10 } }) } })
      expect(l10.find('.level-badge').attributes('style')).toContain('rgb(139, 92, 246)')

      // Levels 19-35: amber
      const l20 = mount(AchievementsBoard, { props: { data: makeData({ profile: { ...makeData().profile, level: 20 } }) } })
      expect(l20.find('.level-badge').attributes('style')).toContain('rgb(245, 158, 11)')

      // Level 36+: red
      const l50 = mount(AchievementsBoard, { props: { data: makeData({ profile: { ...makeData().profile, level: 50 } }) } })
      expect(l50.find('.level-badge').attributes('style')).toContain('rgb(239, 68, 68)')
    })
  })

  describe('xpPercent', () => {
    it('computes percentage and caps at 100', () => {
      // 150/300 = 50%
      const w1 = mount(AchievementsBoard, { props: { data: makeData() } })
      expect(w1.find('.xp-bar-fill').attributes('style')).toContain('width: 50%')

      // xp exceeds target → capped at 100
      const w2 = mount(AchievementsBoard, {
        props: { data: makeData({ profile: { ...makeData().profile, xp: 500, xp_to_next_level: 300 } }) },
      })
      expect(w2.find('.xp-bar-fill').attributes('style')).toContain('width: 100%')

      // xp_to_next_level = 0 → 100%
      const w3 = mount(AchievementsBoard, {
        props: { data: makeData({ profile: { ...makeData().profile, xp: 50, xp_to_next_level: 0 } }) },
      })
      expect(w3.find('.xp-bar-fill').attributes('style')).toContain('width: 100%')
    })
  })

  describe('badge category filtering and tab switching', () => {
    it('shows milestone badges by default', () => {
      const wrapper = mount(AchievementsBoard, { props: { data: makeData() } })
      const badgeNames = wrapper.findAll('.badge-name').map(el => el.text())
      expect(badgeNames).toContain('First Steps')
      expect(badgeNames).toContain('Architect')
      expect(badgeNames).not.toContain('Clean Session')
      expect(badgeNames).not.toContain('Perfect')
    })

    it('switches to skill tab', async () => {
      const wrapper = mount(AchievementsBoard, { props: { data: makeData() } })
      const skillTab = wrapper.findAll('.tab-btn').find(btn => btn.text().includes('Skill'))!
      await skillTab.trigger('click')
      const badgeNames = wrapper.findAll('.badge-name').map(el => el.text())
      expect(badgeNames).toContain('Clean Session')
      expect(badgeNames).not.toContain('First Steps')
    })

    it('switches to special tab', async () => {
      const wrapper = mount(AchievementsBoard, { props: { data: makeData() } })
      const specialTab = wrapper.findAll('.tab-btn').find(btn => btn.text().includes('Special'))!
      await specialTab.trigger('click')
      const badgeNames = wrapper.findAll('.badge-name').map(el => el.text())
      expect(badgeNames).toContain('Perfect')
    })
  })

  describe('challengeProgress', () => {
    it('calculates percentage and caps at 100', () => {
      const data = makeData({
        challenges: [
          { id: 'c1', title: 'Test', description: 'Desc', type: 'daily', progress: 3, target: 5, expires_at: null, xp_reward: 50 },
          { id: 'c2', title: 'Over', description: 'Desc', type: 'weekly', progress: 10, target: 5, expires_at: null, xp_reward: 100 },
        ],
      })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      const fills = wrapper.findAll('.challenge-progress-fill')
      expect(fills[0].attributes('style')).toContain('width: 60%')
      expect(fills[1].attributes('style')).toContain('width: 100%')
    })
  })

  describe('timeRemaining', () => {
    beforeEach(() => {
      vi.useFakeTimers()
      vi.setSystemTime(new Date('2026-03-02T12:00:00Z'))
    })

    afterEach(() => {
      vi.useRealTimers()
    })

    it('shows "Expired" for past dates', () => {
      const data = makeData({
        challenges: [
          { id: 'c1', title: 'Expired', description: 'D', type: 'daily', progress: 0, target: 1, expires_at: '2026-03-01T00:00:00Z', xp_reward: 10 },
        ],
      })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      expect(wrapper.text()).toContain('Expired')
    })

    it('shows hours remaining when less than 24h', () => {
      const data = makeData({
        challenges: [
          { id: 'c1', title: 'Soon', description: 'D', type: 'daily', progress: 0, target: 1, expires_at: '2026-03-02T20:00:00Z', xp_reward: 10 },
        ],
      })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      expect(wrapper.text()).toContain('8h remaining')
    })

    it('shows days remaining when 24h+', () => {
      const data = makeData({
        challenges: [
          { id: 'c1', title: 'Later', description: 'D', type: 'weekly', progress: 0, target: 1, expires_at: '2026-03-05T12:00:00Z', xp_reward: 10 },
        ],
      })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      expect(wrapper.text()).toContain('3d remaining')
    })
  })

  describe('streakActive', () => {
    beforeEach(() => {
      vi.useFakeTimers()
      vi.setSystemTime(new Date('2026-03-02T12:00:00Z'))
    })

    afterEach(() => {
      vi.useRealTimers()
    })

    it('is active when last session is today or yesterday', () => {
      const data = makeData({ profile: { ...makeData().profile, last_session_date: '2026-03-02' } })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      expect(wrapper.find('.streak-display.active').exists()).toBe(true)
    })

    it('is inactive when last session is 2+ days ago', () => {
      const data = makeData({ profile: { ...makeData().profile, last_session_date: '2026-02-28' } })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      expect(wrapper.find('.streak-display.active').exists()).toBe(false)
    })

    it('is inactive when last_session_date is null', () => {
      const data = makeData({ profile: { ...makeData().profile, last_session_date: null } })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      expect(wrapper.find('.streak-display.active').exists()).toBe(false)
    })
  })

  describe('trend arrow and color', () => {
    it('shows up arrow and green for improving', () => {
      const data = makeData({ scoreTrend: { direction: 'improving', average: 85 } })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      const indicator = wrapper.find('.trend-indicator')
      expect(indicator.text()).toContain('\u2191')
      expect(indicator.attributes('style')).toContain('rgb(34, 197, 94)')
    })

    it('shows down arrow and red for declining', () => {
      const data = makeData({ scoreTrend: { direction: 'declining', average: 60 } })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      const indicator = wrapper.find('.trend-indicator')
      expect(indicator.text()).toContain('\u2193')
      expect(indicator.attributes('style')).toContain('rgb(239, 68, 68)')
    })

    it('shows right arrow and yellow for stable', () => {
      const data = makeData({ scoreTrend: { direction: 'stable', average: 75 } })
      const wrapper = mount(AchievementsBoard, { props: { data } })
      const indicator = wrapper.find('.trend-indicator')
      expect(indicator.text()).toContain('\u2192')
      expect(indicator.attributes('style')).toContain('rgb(234, 179, 8)')
    })
  })
})
