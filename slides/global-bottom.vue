<script setup>
import { computed } from 'vue'
import { useNav } from '@slidev/client'

const nav = useNav()

const page = computed(() => nav.currentPage?.value ?? nav.currentSlideNo?.value ?? 0)
const total = computed(() => nav.total?.value ?? nav.total ?? 0)

// current section = the `section:` frontmatter of the nearest slide at/above us
const section = computed(() => {
  const p = page.value
  const slides = nav.slides?.value ?? nav.slides ?? []
  let title = ''
  for (const r of slides) {
    const no = typeof r?.no === 'number' ? r.no : undefined
    const sec = r?.meta?.slide?.frontmatter?.section
    if (sec && no !== undefined && no <= p) title = sec
  }
  return title
})

const pad = (n) => String(n).padStart(2, '0')
</script>

<template>
  <div v-if="page > 1 && page < total" class="deck-footer">
    <div class="sec"><span class="tick">▚</span> {{ section }}</div>
    <div class="brand">dbt · brutalist blueprint</div>
    <div class="pg">{{ pad(page) }} <span class="sep">/</span> {{ pad(total) }}</div>
  </div>
</template>

<style scoped>
.deck-footer {
  position: absolute;
  left: 0; right: 0; bottom: 0;
  height: 26px;
  padding: 0 18px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: #8b8f96;
  border-top: 2px solid #33363c;
  background: rgba(10, 10, 10, 0.82);
  z-index: 20;
  pointer-events: none;
}
.deck-footer .sec { color: #12d3c8; }
.deck-footer .tick { color: #12d3c8; margin-right: 6px; }
.deck-footer .brand { color: #45484f; }
.deck-footer .pg { color: #e9e9e6; }
.deck-footer .sep { color: #33363c; margin: 0 3px; }
</style>
