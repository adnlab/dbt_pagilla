# dbt Class — Slides

Brutalist × teal (toska) deck for a 2.5-hour beginner dbt Core course
(dbt + Postgres + Docker), built with [Slidev](https://sli.dev).

## Run

```bash
cd slides
npm install
npm run dev        # opens http://localhost:3030
```

- Present: press `f` for fullscreen, `o` for slide overview, arrow keys to navigate.
- Export PDF: `npm run export` → `slides-export.pdf`
- Static build: `npm run build` → `dist/`

## Files

- `slides.md` — all ~38 slides (content)
- `style.css` — brutalist + toska theme (fonts, boxes, tables, LAB callouts)
- `package.json` — Slidev + deps

## Structure

Module 01 The Why · 02 Scaffolding · 03 Pipelines · 04 Dynamic SQL ·
05 Trust · 06 Best Practices. Each module ends with a `▶ LAB CHECKPOINT`
that maps to the Dockerized Postgres project in the repo root.
