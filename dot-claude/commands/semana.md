---
description: Cierre semanal — destila lo hecho y lo aprendido de la semana en mauro-docs/aprendizaje/ (la fuente de sabiduría).
argument-hint: "" | YYYY-Www (default: la semana actual)
---

Semana: **$ARGUMENTS** (si está vacío → la semana ISO actual, formato `YYYY-Www`, ej. `2026-W33`).

Sos el destilador de mi semana. El objetivo NO es un reporte de tareas (eso ya está en las
bitácoras): es **capturar lo que aprendí** — del negocio, del stack y del proceso — para que
se acumule semana a semana en `mauro-docs/aprendizaje/` (repo personal, permitido pushear).

## 1. Recolectá la semana (en paralelo)

- Las bitácoras de la semana: `mauro-docs/daily/YYYY-MM-DD.md` (lunes a hoy).
- engram: `mem_search` de los temas de la semana + los `mem_save` de cierre (`mm-…`).
- En `mango-api` y `mango-app-v2`: `git log --oneline --since="last monday"` con mis commits,
  y mis PRs cerradas/abiertas de la semana (`gh pr list --author @me --state all`).
- Mi memoria durable (`mauro-docs/claude-memory/mango/`) por si algo cambió.

## 2. Destilá — el doc `mauro-docs/aprendizaje/YYYY-Www.md`

Secciones fijas (si una queda vacía, escribí "—" y no rellenes con paja; **cosas concretas
de esta semana, no generalidades**):

1. **Negocio** — qué entendí nuevo del dominio (factoraje, STP/SPEI, SAT/CFDI, proyectos/obra,
   cómo gana plata Mango). Con el "antes pensaba / ahora sé".
2. **Laravel/PHP** — patrones del repo, trampas, decisiones (policies, validación, transacciones,
   colas…). Con snippet o referencia a archivo:línea cuando aplique.
3. **Next.js/React** — App Router, FSD, server actions, contrato de cookies, testing (Vitest/
   Storybook/Playwright)…
4. **Proceso/Claude** — qué funcionó del flujo (comandos, reviews, agentes), qué ajustar.
5. **Decisiones y por qué** — cada decisión de la semana con su razón y link (PR/spec/ADR).

Cerrá con una línea de "**la lección de la semana**" (una sola, la que más vale recordar).

## 3. Indexá y pusheá

- Actualizá (o creá) `mauro-docs/aprendizaje/README.md`: una línea por semana con link y
  la lección de la semana como hook.
- `git add aprendizaje/ && git commit` (Conventional Commits, ej.
  `docs(aprendizaje): distill week 2026-W33`) y **push a mauro-docs** (repo personal).
- Mostrame el doc renderizado en resumen (10-15 líneas) al final.

## Reglas

- **Cero secretos, cero datos reales de clientes** (RFCs, CLABEs, montos identificables).
- Fuente de verdad de lo técnico: el código y las specs — si una "lección" contradice la spec
  del equipo, marcala como duda a validar, no como verdad.
- Si la semana no tiene bitácoras (me lo salteé), reconstruí de git/engram y decime qué
  faltó registrar.
