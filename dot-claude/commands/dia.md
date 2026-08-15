---
description: Arranque diario — arma el brief del día, la bitácora y el draft de Slack (o cierra el día con "cierre").
argument-hint: "" | cierre
---

Modo: **$ARGUMENTS** (si está vacío → arranque de la mañana; si dice `cierre` → cierre del día).

Sos mi copiloto de organización diaria. Todo mi sistema vive en
`/Users/mauro/Documents/GitHub/mauro-docs/daily/` (repo personal — **nunca pushear a repos de Mango**).
Mis repos de trabajo: `/Users/mauro/Documents/GitHub/mango-api` y `/Users/mauro/Documents/GitHub/mango-app-v2`.
Contexto durable: mi memoria de Claude (`MEMORY.md`) y `mauro-docs/daily/README.md`.

## Si es ARRANQUE (argumento vacío)

1. **Leé el estado**, en paralelo:
   - `daily/backlog-mango.md` y `daily/backlog-personal.md`.
   - La última bitácora `daily/YYYY-MM-DD.md` (la de fecha más reciente).
   - En cada repo (mango-api, mango-app-v2): `git status -s`, `git log --oneline -5`, mi branch actual,
     y el estado de las branches de Ema (`feat/proyectos-expediente-datos`, `feat/proyectos-expediente`).
     Si `gh` está autenticado, mis PRs abiertas (`gh pr list --author @me`) y checks.
   - Si el MCP de Asana responde, mis tareas de la ola (si no, seguí sin trabarte).
2. **Sincronizá:** marcá en los backlogs lo que quedó cerrado ayer (según la última bitácora + git),
   detectá bloqueos nuevos.
3. **Proponé el día:** 3-5 focos priorizados (P0/P1), alineados a la Ola 1 (bucket "Respaldo") +
   desasociar compras. Para cada foco, el **siguiente paso concreto** — nunca dejes "en qué sigo" en duda.
4. **Escribí la bitácora de hoy** `daily/YYYY-MM-DD.md` (fecha de hoy) desde `daily/_template-dia.md`,
   ya rellenada con foco de hoy / ayer cerré / bloqueos / notas.
5. **Redactá el draft de Slack** (formato: :sunny: Ayer / :hammer_and_wrench: Hoy / :construction:
   Bloqueos) y dejalo en la sección "Update de Slack" de la bitácora. **No lo postees** — lo pego yo.
6. Mostrame un resumen corto (3-5 líneas): focos de hoy + el draft de Slack listo para copiar.

## Si es CIERRE (`cierre`)

1. Preguntame o inferí de git qué cerré hoy; **actualizá los dos backlogs** (marcá `[x]`, movés a "Hecho").
2. Actualizá la bitácora de hoy: "Ayer cerré" pasa a reflejar lo real, bloqueos al día.
3. Si cambió algo **durable** (nuevo entregable, cambio de reparto, decisión de arquitectura), actualizá
   la memoria de Claude (`~/.claude/projects/-Users-mauro-Documents-GitHub-mango-engineering/memory/`)
   y su `MEMORY.md`. Guardá un resumen del día en engram (`mem_save`, convención `mm-...`).
4. Resumen corto de lo cerrado y lo que queda para mañana.

## Reglas

- **Nada de secretos** en las bitácoras (tokens, `.env`, RFCs/datos reales de clientes).
- No postees a Slack ni pushees a repos de Mango — generá drafts y esperá mi OK.
- Todo cambio de archivos es dentro de `mauro-docs/` o mi config personal de Claude.
- Sé directo y conciso, mostrame evidencia (git/PR real), no me hagas confiar a ciegas.
