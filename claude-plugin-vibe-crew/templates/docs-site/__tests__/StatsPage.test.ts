import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import StatsPage from '../components/StatsPage.vue'

describe('StatsPage', () => {
  it('shows zeros and empty message for no sessions', () => {
    const wrapper = mount(StatsPage, { props: { sessions: [] } })
    const values = wrapper.findAll('.stat-value').map(el => el.text())
    expect(values[0]).toBe('0')           // Total Sessions
    expect(values[1]).toContain('0')       // Average Vibe Score
    expect(values[2]).toBe('0')            // Total Tokens
    expect(values[3]).toBe('$0.00')        // Cost
    expect(wrapper.text()).toContain('No sessions recorded yet.')
  })

  it('aggregates tokens across all categories', () => {
    const sessions = [
      {
        vibe_score: 80,
        tokens: { input: 1000, cache_creation: 200, cache_read: 300, output: 500, estimated_cost_usd: 0.10 },
      },
      {
        vibe_score: 90,
        tokens: { input: 2000, cache_creation: 100, cache_read: 400, output: 600, estimated_cost_usd: 0.20 },
      },
    ]
    const wrapper = mount(StatsPage, { props: { sessions } })
    // Total = (1000+200+300+500) + (2000+100+400+600) = 2000 + 3100 = 5100 → 5.1K
    const tokenValue = wrapper.findAll('.stat-value')[2].text()
    expect(tokenValue).toBe('5.1K')
  })

  it('computes average vibe score with rounding and null handling', () => {
    const sessions = [
      { vibe_score: 83, tokens: {} },
      { vibe_score: 77, tokens: {} },
      { vibe_score: null, tokens: {} },
    ]
    const wrapper = mount(StatsPage, { props: { sessions } })
    // (83+77)/2 = 80
    expect(wrapper.findAll('.stat-value')[1].text()).toContain('80')
  })

  it('formatTokens: K suffix for thousands', () => {
    const sessions = [
      { vibe_score: 50, tokens: { input: 1500, cache_creation: 0, cache_read: 0, output: 0, estimated_cost_usd: 0 } },
    ]
    const wrapper = mount(StatsPage, { props: { sessions } })
    expect(wrapper.findAll('.stat-value')[2].text()).toBe('1.5K')
  })

  it('formatTokens: M suffix for millions', () => {
    const sessions = [
      { vibe_score: 50, tokens: { input: 1_500_000, cache_creation: 0, cache_read: 0, output: 0, estimated_cost_usd: 0 } },
    ]
    const wrapper = mount(StatsPage, { props: { sessions } })
    expect(wrapper.findAll('.stat-value')[2].text()).toBe('1.5M')
  })

  it('formatCost: dollar formatting', () => {
    const sessions = [
      { vibe_score: 50, tokens: { input: 0, cache_creation: 0, cache_read: 0, output: 0, estimated_cost_usd: 3.456 } },
    ]
    const wrapper = mount(StatsPage, { props: { sessions } })
    expect(wrapper.findAll('.stat-value')[3].text()).toBe('$3.46')
  })
})
