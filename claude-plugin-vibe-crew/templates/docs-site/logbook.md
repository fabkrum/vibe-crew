---
layout: page
title: Session Logbook
---

<script setup>
import { data as sessions } from './data/sessions.data'
import { data as scores } from './data/scores.data'
import SessionLogbook from './components/SessionLogbook.vue'
</script>

# Session Logbook

<SessionLogbook :sessions="sessions" :scores="scores" />
