---
layout: page
title: Session Statistics
---

<script setup>
import { data } from './data/sessions.data'
import StatsPage from './components/StatsPage.vue'
</script>

# Session Statistics

Aggregate metrics across all VibeOS development sessions.

<StatsPage :sessions="data" />

::: tip
Session data is recorded each time you run `/wrap` to close a development session.
:::
