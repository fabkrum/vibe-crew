---
layout: page
title: Kanban Board
---

<script setup>
import { data } from './data/backlog.data'
import KanbanBoard from './components/KanbanBoard.vue'
</script>

# Project Kanban Board

Interactive view of your feature backlog. Add ideas, drag cards between columns, click to edit specs, and launch Warp sessions with action buttons.

<LiveSessionPanel />

<KanbanBoard :data="data" />

::: tip
Add ideas via the **+** button, drag cards to move them, and click any card to view or edit details. Action buttons launch Warp terminal sessions with the right command pre-filled. Interactive features require the dev server (`npm run docs:dev`).
:::
