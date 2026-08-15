---
description: Cargar el contexto full-stack de una feature de Mango (spec oficial + branches api↔app + engram) en cualquier repo.
argument-hint: "[nombre-feature] (default: mango-proyectos)"
---

Feature: **$ARGUMENTS** (si está vacío → usá `mango-proyectos`).

Sos el loader de contexto para trabajo full-stack en Mango. Corré esto al abrir una sesión
nueva en `mango-api` o `mango-app-v2` (o cualquier repo) para cargar todo el contexto de la
feature sin re-explicar nada. Rutas base: los repos viven en `/Users/mauro/Documents/GitHub/`.

## 1. Fuente de verdad del equipo (leé primero)

En `mango-engineering/specs/<feature>/` — la estructura real es
`specs/<feature>/NNN-<slug>/` (ej. `specs/mango-proyectos/001-mango-proyectos/`):

- `spec.md` — el PRD y el contrato (la sección de API/contrato es lo que ata front y back).
- `plan-v1.md` / `plan.md` y `waves.md` — alcance y entrega por olas.
- `olas/*/plan.md` — el plan de cada ola; **identificá cuál ola es la activa** (por el
  backlog o la memoria) y leé ese plan completo. Es la fuente de verdad del alcance.
- Si hay otros docs de decisión (`modelo-acceso.md`, etc.), hojealos por título y leé solo
  los que toquen la ola activa.

Si `specs/<feature>/` no existe, decilo y listá `mango-engineering/specs/` para ofrecer los
nombres válidos — no inventes.

## 2. El par de branches api↔app (estado real)

En `mango-api` y `mango-app-v2`, en paralelo:

- Branch actual + branches de la feature: `git branch -a --list "*<keyword>*"` (probá con el
  slug de la feature, ej. `proyectos`).
- PRs abiertas de la feature: `gh pr list --search "<keyword>"` (+ las mías:
  `gh pr list --author @me`), con estado de checks (`gh pr checks`).
- Qué hay sin commitear: `git status -s`.

## 3. Memoria

- engram: `mem_search "<feature>"` y `mem_context` (si el MCP responde; si no, seguí).
- Mi memoria durable de Claude (`MEMORY.md` del proyecto) si menciona la feature.
- Mi backlog: `mauro-docs/daily/backlog-mango.md` (pendientes y bloqueos).

## 4. Explicadores personales (opcional)

Si existe `mauro-docs/mango/<feature>/`, hojeá los HTML (son vistas de lectura; la fuente
de verdad sigue siendo la spec del equipo — si difieren, ganá la spec y avisame del drift).

## Salida: el brief (conciso, con evidencia)

1. **Dónde estoy parado** (3-5 líneas): feature, ola activa, mi entregable, deadline si hay.
2. **Backend**: branch/PR que sigue en `mango-api`, estado de CI, próximo paso concreto.
3. **Frontend**: ídem en `mango-app-v2`.
4. **El contrato que los ata**: endpoints/shapes relevantes de la spec (citá la sección).
5. **Bloqueos** conocidos.

Si estoy parado en `mango-api`, priorizá el detalle backend; en `mango-app-v2`, el frontend.

## Reglas de mi flujo (aplican siempre)

- TDD (test primero), un stage = un commit = una PR, Conventional Commits, **paro al cerrar
  cada stage** para revisar. `security-reviewer` en PRs que toquen auth/archivos/policy.
- Nada personal se pushea a repos de Mango. Mi organización diaria vive en `mauro-docs/daily/`
  (`/dia`); esto es solo carga de contexto, no escribe nada.
