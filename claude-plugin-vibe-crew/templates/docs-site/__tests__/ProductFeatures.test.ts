import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProductFeatures from '../components/ProductFeatures.vue'

function makeFeature(overrides: Record<string, unknown> = {}) {
  return {
    id: 'feat-1',
    name: 'Test Feature',
    column: 'done',
    labels: ['core'],
    description: '',
    spec: {},
    completed_at: '2026-01-15T00:00:00Z',
    updated_at: '2026-01-14T00:00:00Z',
    ...overrides,
  }
}

describe('ProductFeatures', () => {
  it('renders empty state when no features', () => {
    const wrapper = mount(ProductFeatures, {
      props: { data: { features: [] }, featureDocs: [] },
    })
    expect(wrapper.text()).toContain('No completed features yet.')
  })

  it('only shows done and review features', () => {
    const features = [
      makeFeature({ id: 'a', column: 'done', name: 'Done One' }),
      makeFeature({ id: 'b', column: 'review', name: 'Review One' }),
      makeFeature({ id: 'c', column: 'in-progress', name: 'WIP' }),
      makeFeature({ id: 'd', column: 'idea', name: 'Idea' }),
      makeFeature({ id: 'e', column: 'planning', name: 'Planning' }),
    ]
    const wrapper = mount(ProductFeatures, {
      props: { data: { features }, featureDocs: [] },
    })
    expect(wrapper.text()).toContain('Done One')
    expect(wrapper.text()).toContain('Review One')
    expect(wrapper.text()).not.toContain('WIP')
    expect(wrapper.text()).not.toContain('Idea')
    expect(wrapper.text()).not.toContain('Planning')
  })

  it('sorts by completed_at descending (most recent first)', () => {
    const features = [
      makeFeature({ id: 'old', name: 'Old', completed_at: '2025-01-01T00:00:00Z', labels: ['A'] }),
      makeFeature({ id: 'new', name: 'New', completed_at: '2026-06-01T00:00:00Z', labels: ['A'] }),
      makeFeature({ id: 'mid', name: 'Mid', completed_at: '2026-03-01T00:00:00Z', labels: ['A'] }),
    ]
    const wrapper = mount(ProductFeatures, {
      props: { data: { features }, featureDocs: [] },
    })
    const titles = wrapper.findAll('.pf-card-title').map(el => el.text())
    expect(titles).toEqual(['New', 'Mid', 'Old'])
  })

  it('groups by first label with Uncategorized last', () => {
    const features = [
      makeFeature({ id: 'a', name: 'A', labels: ['Beta'] }),
      makeFeature({ id: 'b', name: 'B', labels: ['Alpha'] }),
      makeFeature({ id: 'c', name: 'C', labels: [] }),
    ]
    const wrapper = mount(ProductFeatures, {
      props: { data: { features }, featureDocs: [] },
    })
    const groupTitles = wrapper.findAll('.pf-group-title').map(el => el.text())
    expect(groupTitles).toEqual(['Alpha', 'Beta', 'Uncategorized'])
  })

  it('cascades description: description → spec.ui_description → spec.problem_statement → empty', () => {
    const features = [
      makeFeature({ id: 'a', name: 'A', description: 'Direct desc', labels: ['T'] }),
      makeFeature({ id: 'b', name: 'B', description: '', spec: { ui_description: 'UI desc' }, labels: ['T'] }),
      makeFeature({ id: 'c', name: 'C', description: '', spec: { problem_statement: 'Problem' }, labels: ['T'] }),
      makeFeature({ id: 'd', name: 'D', description: '', spec: {}, labels: ['T'] }),
    ]
    const wrapper = mount(ProductFeatures, {
      props: { data: { features }, featureDocs: [] },
    })
    const descs = wrapper.findAll('.pf-card-desc').map(el => el.text())
    expect(descs).toContain('Direct desc')
    expect(descs).toContain('UI desc')
    expect(descs).toContain('Problem')
    // Feature D has no description so no .pf-card-desc element
    expect(descs.length).toBe(3)
  })

  it('shows Details link only when featureDocs includes the feature id', () => {
    const features = [
      makeFeature({ id: 'has-doc', name: 'Has Doc', labels: ['X'] }),
      makeFeature({ id: 'no-doc', name: 'No Doc', labels: ['X'] }),
    ]
    const wrapper = mount(ProductFeatures, {
      props: { data: { features }, featureDocs: ['has-doc'] },
    })
    const links = wrapper.findAll('.pf-details-link')
    expect(links.length).toBe(1)
    expect(links[0].attributes('href')).toBe('/features/has-doc')
  })

  it('shows correct summary count with singular/plural', () => {
    const single = mount(ProductFeatures, {
      props: {
        data: { features: [makeFeature()] },
        featureDocs: [],
      },
    })
    expect(single.find('.pf-summary').text()).toContain('1')
    expect(single.find('.pf-summary').text()).toContain('feature shipped')

    const plural = mount(ProductFeatures, {
      props: {
        data: {
          features: [
            makeFeature({ id: 'a' }),
            makeFeature({ id: 'b' }),
          ],
        },
        featureDocs: [],
      },
    })
    expect(plural.find('.pf-summary').text()).toContain('2')
    expect(plural.find('.pf-summary').text()).toContain('features shipped')
  })
})
