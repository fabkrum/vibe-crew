---
layout: page
title: Settings
---

<script setup>
import { data } from './data/config.data'
import SettingsPanel from './components/SettingsPanel.vue'
</script>

# Settings

Manage your VibeCrew configuration. Changes are saved directly to `.vibecrew/config.json`.

<SettingsPanel :data="data" />

::: tip
During `vitepress dev`, changes save directly to disk. In static builds, a copyable JSON is provided instead.
:::
