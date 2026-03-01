import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'

// Mock the data import used by FeatureProgress
vi.mock('../data/backlog.data', () => ({
  data: { features: [] },
}))

import FeatureProgress from '../components/FeatureProgress.vue'
import { data } from '../data/backlog.data'

describe('FeatureProgress', () => {
  it('shows empty message when backlog is empty', () => {
    ;(data as any).features = []
    const wrapper = mount(FeatureProgress)
    expect(wrapper.text()).toContain('No features in backlog')
  })

  it('shows correct column counts matching feature distribution', () => {
    ;(data as any).features = [
      { id: '1', name: 'A', column: 'idea', priority: 1 },
      { id: '2', name: 'B', column: 'idea', priority: 2 },
      { id: '3', name: 'C', column: 'in-progress', priority: 1 },
      { id: '4', name: 'D', column: 'done', priority: 1 },
      { id: '5', name: 'E', column: 'done', priority: 2 },
      { id: '6', name: 'F', column: 'done', priority: 3 },
    ]
    const wrapper = mount(FeatureProgress)
    const counts = wrapper.findAll('.count').map(el => el.text())
    // Order: idea, planning, planned, in-progress, testing, review, done
    expect(counts).toEqual(['2', '0', '0', '1', '0', '0', '3'])
  })

  it('shows velocity as done/total percentage', () => {
    ;(data as any).features = [
      { id: '1', name: 'A', column: 'done', priority: 1 },
      { id: '2', name: 'B', column: 'idea', priority: 1 },
      { id: '3', name: 'C', column: 'idea', priority: 1 },
      { id: '4', name: 'D', column: 'idea', priority: 1 },
    ]
    const wrapper = mount(FeatureProgress)
    // 1/4 = 25%
    expect(wrapper.find('.velocity').text()).toContain('1/4 done (25%)')
  })
})
