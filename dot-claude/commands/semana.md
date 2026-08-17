---
description: Cierre semanal — destila lo hecho y lo aprendido de la semana en mauro-docs/learning/ (la fuente de sabiduría).
argument-hint: "" | YYYY-Www (default: la semana actual)
---

Semana: **$ARGUMENTS** (si está vacío → la semana ISO actual, formato `YYYY-Www`, ej. `2026-W33`).

Sos el destilador de mi semana. El objetivo NO es un reporte de tareas (eso ya está en las
bitácoras): es **capturar lo que aprendí** — del negocio, del stack y del proceso — para que
se acumule semana a semana en `mauro-docs/learning/` (repo personal, permitido pushear).

## 1. Recolectá la semana (en paralelo)

- Las bitácoras de la semana: `mauro-docs/daily/YYYY-MM-DD.md` (lunes a hoy).
- engram: `mem_search` de los temas de la semana + los `mem_save` de cierre (`mm-…`).
- En `mango-api` y `mango-app-v2`: `git log --oneline --since="last monday"` con mis commits,
  y mis PRs cerradas/abiertas de la semana (`gh pr list --author @me --state all`).
- Mi memoria durable (`mauro-docs/claude-memory/mango/`) por si algo cambió.

## 2. Destilá — el doc `mauro-docs/learning/weekly/YYYY-Www.md`

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

6. **Qué sistematizar** — patrones o toil que se repitieron esta semana y podrían volverse un
   **skill o comando** del devkit (o un hook, un script). Para cada uno: qué automatizaría y por qué.
7. **Producto** — ideas que valdría la pena **proponer a Mango** (mejora de proceso, herramienta,
   gap del equipo). Concretas, con el problema que atacan.
8. **Brain / skills** — qué conviene **incorporar al devkit o a engram** (una regla nueva, un
   dato durable, una skill). Distinguir "ya lo hago, formalizarlo" de "idea a probar".

Cerrá con una línea de "**la lección de la semana**" (una sola, la que más vale recordar).

## 3. Generá el HTML resumen

Además del `.md`, escribí un **HTML resumen** en `mauro-docs/learning/summaries/YYYY-Www.html`
— versión linda tipo sumario ejecutivo
(las secciones + la lección + los candidatos a sistematizar/producto/skill), con el mismo CSS
con toggle de tema que los explicadores de `mauro-docs/mango/` (podés copiar el patrón de
`learning/concepts/laravel-nextjs.html`). Es lo que se comparte de un vistazo.

## 4. Indexá, pusheá y avisá

- Actualizá `mauro-docs/learning/README.md`: la fila de la semana con link al `.md` (weekly/) y
  al `.html` (summaries/) + la lección como hook.
- `git add learning/ && git commit` (Conventional Commits, ej.
  `docs(learning): distill week 2026-W33`) y **push a mauro-docs** (repo personal).
- **DM de Slack:** ofrecé mandarme el resumen (la lección + los 2-3 candidatos a sistematizar/
  producto/skill) como mensaje directo a mí mismo con el MCP de Slack (user id `U0BQ2K3FEJU`).
  **Esperá mi OK antes de enviar.** Si el MCP no está disponible, decímelo y seguí.
- Mostrame el doc renderizado en resumen (10-15 líneas) al final.

## Reglas

- **Cero secretos, cero datos reales de clientes** (RFCs, CLABEs, montos identificables).
- Fuente de verdad de lo técnico: el código y las specs — si una "lección" contradice la spec
  del equipo, marcala como duda a validar, no como verdad.
- Si la semana no tiene bitácoras (me lo salteé), reconstruí de git/engram y decime qué
  faltó registrar.
