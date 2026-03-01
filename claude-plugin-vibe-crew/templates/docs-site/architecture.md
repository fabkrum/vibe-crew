---
layout: page
title: Architecture
---

<script setup>
import { data } from './data/architecture.data'
import ArchitectureOverview from './components/ArchitectureOverview.vue'
</script>

# Architecture Overview

Visual diagrams of your project's architecture, generated during the Tier 1 foundation phase. These 5 diagrams cover infrastructure topology, database schema, user flows, API sequences, and component hierarchy.

<ArchitectureOverview :diagrams="data" />
