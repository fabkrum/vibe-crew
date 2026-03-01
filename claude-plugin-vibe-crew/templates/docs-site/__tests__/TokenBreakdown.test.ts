import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'

vi.mock('../data/agents.data', () => ({
  data: {
    sessions: [],
    agentSummary: [],
    totalTokens: { input: 0, cache_read: 0, output: 0, cost: 0 },
  },
}))

import TokenBreakdown from '../components/TokenBreakdown.vue'
import { data } from '../data/agents.data'

describe('TokenBreakdown', () => {
  it('shows empty state with no sessions', () => {
    ;(data as any).sessions = []
    ;(data as any).totalTokens = { input: 0, cache_read: 0, output: 0, cost: 0 }
    const wrapper = mount(TokenBreakdown)
    expect(wrapper.text()).toContain('No session data yet.')
  })

  it('displays total token sum and cost', () => {
    ;(data as any).sessions = [
      {
        session_id: 'session-abc123',
        tokens: { input: 50_000, cache_read: 20_000, output: 10_000, estimated_cost_usd: 0.50 },
      },
    ]
    ;(data as any).totalTokens = { input: 50_000, cache_read: 20_000, output: 10_000, cost: 0.50 }
    const wrapper = mount(TokenBreakdown)
    // 50000+20000+10000 = 80000 = 80.0K
    expect(wrapper.find('.total-cost').text()).toContain('80.0K')
    expect(wrapper.find('.total-cost').text()).toContain('$0.50')
  })

  it('formatTokens: K suffix', () => {
    ;(data as any).sessions = [
      {
        session_id: 'session-test',
        tokens: { input: 1500, cache_read: 0, output: 0, estimated_cost_usd: 0 },
      },
    ]
    ;(data as any).totalTokens = { input: 1500, cache_read: 0, output: 0, cost: 0 }
    const wrapper = mount(TokenBreakdown)
    expect(wrapper.find('.total-cost').text()).toContain('1.5K')
  })

  it('formatTokens: M suffix', () => {
    ;(data as any).sessions = []
    ;(data as any).totalTokens = { input: 2_500_000, cache_read: 0, output: 0, cost: 5.00 }
    const wrapper = mount(TokenBreakdown)
    expect(wrapper.find('.total-cost').text()).toContain('2.5M')
  })

  it('formatCost: proper dollar formatting', () => {
    ;(data as any).sessions = []
    ;(data as any).totalTokens = { input: 0, cache_read: 0, output: 0, cost: 12.3456 }
    const wrapper = mount(TokenBreakdown)
    expect(wrapper.find('.total-cost').text()).toContain('$12.35')
  })
})
