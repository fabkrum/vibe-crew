---
layout: page
title: Releases
---

<script setup>
import { data } from './data/releases.data'
import ReleasesTimeline from './components/ReleasesTimeline.vue'
</script>

# Releases

<ReleasesTimeline :releases="data" />
