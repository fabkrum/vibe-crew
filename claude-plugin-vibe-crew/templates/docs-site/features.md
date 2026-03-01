---
layout: page
title: Features
---

<script setup>
import { data as backlog } from './data/backlog.data'
import { data as featureDocs } from './data/feature-docs.data'
import ProductFeatures from './components/ProductFeatures.vue'
</script>

# Product Features

An overview of completed features in this project, automatically populated from the backlog.

<ProductFeatures :data="backlog" :feature-docs="featureDocs" />

::: tip
Features appear here once they reach the **Review** or **Done** stage in the Kanban board. Each card shows the feature description, completion date, and labels. If a detailed feature doc exists in `docs/features/`, a "Details" link is provided.
:::
