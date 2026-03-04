---
layout: page
title: About
---

<script setup>
import { data as about } from './data/about.data'
import { data as backlog } from './data/backlog.data'
import { data as featureDocs } from './data/feature-docs.data'
import AboutPage from './components/AboutPage.vue'
</script>

# About This Project

<AboutPage :about="about" :backlog="backlog" :feature-docs="featureDocs" />
