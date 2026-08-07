---
description: Inspect a new or inherited project and generate an HTML overview + architecture diagram to understand it fast.
argument-hint: [path or note about the project]
---

We're getting up to speed on this project: **$ARGUMENTS** (default: the current repo).

Goal: understand an unfamiliar codebase quickly and leave a durable, human-readable
**HTML overview** plus an **architecture diagram**. This is read-only inspection — do not
change project code or its `CLAUDE.md`.

## 1. Map the codebase

First gauge the size: `git ls-files | wc -l` (or a quick file count).

**Large or unfamiliar repo (hundreds+ of files) and `graphify` is available** → build a
knowledge graph instead of grepping blind. Index locally with `graphify . --code-only`
(no API cost, code never leaves the machine; add `--no-viz` above ~5000 nodes), then read
`graphify-out/GRAPH_REPORT.md` (god nodes, cross-file links) and query
`graphify-out/graph.json` (`graphify explain "X"`, `graphify path "A" "B"`) to fill the
*Architecture*, *Flows*, and *Data model* sections. **Cite the confidence tags** — trust
`EXTRACTED` edges, treat `INFERRED` as a hypothesis to confirm in the source.

**Small repo, or graphify not installed** → launch 1–3 `Explore` subagents (fan out, keep
the main context light). Either way, map:

- **Stack & tooling** — languages, framework, package manager, key dependencies
  (`package.json`, `composer.json`, `pyproject.toml`, etc.), scripts, CI.
- **Structure & entry points** — top-level layout, where execution starts (routes,
  controllers, `main`, CLI, server bootstrap).
- **Data model** — migrations / schema / ORM entities, the key tables and relationships.
- **Flows** — the main request or process flows, background jobs, external integrations.
- **Conventions & tests** — naming, layering, test framework, how to run and test.

## 2. Write the HTML overview

Write **`docs/overview.html`**: a **self-contained** page (no external dependencies) with
a dark/light toggle in the `archify` style (respect `prefers-color-scheme`, persist in
`localStorage`), responsive. Follow the prose discipline of the `docs-writer` agent —
clear, no filler, tables for structured data. Sections:

1. **Stack & tooling**
2. **Architecture** — components and how they relate
3. **Data model** — key tables/entities in a table
4. **Flows & entry points**
5. **Conventions**
6. **How to run / test**
7. **Risks & tech debt** noticed while reading

## 3. Architecture diagram

Use the **`archify`** skill (`architecture` mode) to generate **`docs/architecture.html`**
from the real code map, and **link it** from the overview.

## 4. Close

Call out assumptions and anything you couldn't confirm from the code (mark it clearly as
inferred). Offer to regenerate any section or go deeper on a specific area.
