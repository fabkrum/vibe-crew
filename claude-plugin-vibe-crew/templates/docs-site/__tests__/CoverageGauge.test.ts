import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'

// Mock the scores data import
vi.mock('../data/scores.data', () => ({
  data: {
    scores: [],
    trend: { direction: 'unknown', average: 0, count: 0 },
    topDeductions: [],
  },
}))

import CoverageGauge from '../components/CoverageGauge.vue'
import { data } from '../data/scores.data'

function setScores(scores: Array<{ metrics?: { quality?: { coverage_percent?: number } } }>) {
  ;(data as any).scores = scores
}

describe('CoverageGauge', () => {
  it('shows red (#ef4444) and "Low" for 0-39%', () => {
    setScores([{ metrics: { quality: { coverage_percent: 25 } } }])
    const wrapper = mount(CoverageGauge)
    expect(wrapper.text()).toContain('Low')
    expect(wrapper.text()).toContain('25%')
    expect(wrapper.html()).toContain('#ef4444')
  })

  it('shows orange (#f97316) and "Fair" for 40-59%', () => {
    setScores([{ metrics: { quality: { coverage_percent: 45 } } }])
    const wrapper = mount(CoverageGauge)
    expect(wrapper.text()).toContain('Fair')
    expect(wrapper.html()).toContain('#f97316')
  })

  it('shows yellow (#eab308) and "Good" for 60-79%', () => {
    setScores([{ metrics: { quality: { coverage_percent: 72 } } }])
    const wrapper = mount(CoverageGauge)
    expect(wrapper.text()).toContain('Good')
    expect(wrapper.html()).toContain('#eab308')
  })

  it('shows green (#22c55e) and "Excellent" for 80+%', () => {
    setScores([{ metrics: { quality: { coverage_percent: 95 } } }])
    const wrapper = mount(CoverageGauge)
    expect(wrapper.text()).toContain('Excellent')
    expect(wrapper.html()).toContain('#22c55e')
  })

  it('defaults to 0% coverage when no metrics', () => {
    setScores([{}])
    const wrapper = mount(CoverageGauge)
    expect(wrapper.text()).toContain('0%')
    expect(wrapper.text()).toContain('Low')
  })

  it('defaults to 0% coverage when scores is empty', () => {
    setScores([])
    const wrapper = mount(CoverageGauge)
    expect(wrapper.text()).toContain('0%')
    expect(wrapper.text()).toContain('Low')
  })
})
