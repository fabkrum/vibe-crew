---
layout: page
title: Kanban Board
---

<script setup>
import { data } from './data/backlog.data'
import KanbanBoard from './components/KanbanBoard.vue'
</script>

# Project Kanban Board

Real-time view of your feature backlog. Features are organized by workflow stage and sorted by priority within each column.

<KanbanBoard :data="data" />

::: tip
This board is read-only. Use `/new-feature`, `/plan-features`, and `/run-backlog` to move features through the pipeline.
:::
