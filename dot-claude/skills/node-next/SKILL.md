---
name: node-next
description: Conventions and patterns for Node/Express APIs and Next.js/React/TypeScript front-ends following the devkit's layered process and TDD. Activates when the project uses Node or Next.js (package.json with express or next, tsconfig.json, .ts/.tsx files) or when Express, Next.js, React, Zod, or TanStack Query come up in that context.
---

# Node / Express and Next.js / React / TypeScript

The same layered pattern as the rest of the devkit, with the JS/TS ecosystem's names.

## Back (Node / Express)

1. **Route → thin handler.** Receives, authorizes (middleware), delegates.
2. **Validation with Zod** at the boundary; types inferred from schemas.
3. **Logic in domain services.** One responsibility per service, testable.
4. **Persistence via the ORM/query layer**; multi-table writes inside a transaction.
5. **Consistent serialization**; central error handler, not scattered try/catch.
6. **Heavy work to Bull/BullMQ jobs.** Never in the request.
- Tests with **Jest** (or Vitest): test first, red → green → refactor.

## Front (Next.js / React)

1. **UI component** — server component by default; `'use client'` only for
   interactivity. Container/presentational split.
2. **State** — UI state in Zustand/useState; server-state in TanStack Query. Each on
   its own.
3. **Server-side data layer** — Zod validation, secrets/tokens handled server-side.
4. **Transport** — typed API client speaking the contract.
- Every component handles its 4 states: loading / error / empty / success.
- App Router conventions.

## Quality

- ESLint + TypeScript strict (`npx tsc --noEmit`); the post-edit hook already runs
  eslint on `.ts/.tsx`.
- Schema/migration changes: own branch/PR, merged before the code that uses them.
