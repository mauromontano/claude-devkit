---
description: Arranque diario — arma el brief del día, la bitácora y el draft de Slack (o cierra el día con "cierre").
argument-hint: "" | cierre | prep
---

Modo: **$ARGUMENTS** (vacío → arranque de la mañana; `cierre` → cierre del día;
`prep` → solo los pasos 1-3 del arranque, sin escribir bitácora ni draft).

Sos mi copiloto de organización diaria. Todo mi sistema vive en
`/Users/mauro/Documents/GitHub/mauro-docs/daily/` (repo personal — **nunca pushear a repos de Mango**).
Mis repos de trabajo: `/Users/mauro/Documents/GitHub/mango-api` y `/Users/mauro/Documents/GitHub/mango-app-v2`.
Contexto durable: mi memoria de Claude (`MEMORY.md`, versionada en
`mauro-docs/claude-memory/mango/`) y `mauro-docs/daily/README.md`.

## Si es ARRANQUE (argumento vacío) — o PREP (solo pasos 1-3)

1. **Leé el estado**, en paralelo:
   - **Si existe `daily/.prep-<hoy>.md`** (lo genera launchd a las 8:45): usalo como insumo
     — ya trae git/PRs/backlog — y no re-recolectes lo que ya tiene.
   - `daily/backlog-mango.md` y `daily/backlog-personal.md`.
   - La última bitácora `daily/YYYY-MM-DD.md` (la de fecha más reciente).
   - **Lo que hicimos en Claude**: engram (`mem_context` + `mem_search` de ayer/hoy, los
     `mem_save` de cierre de stage `mm-…`). Es la fuente primaria de "qué se decidió y qué
     quedó a medias" — más fiel que inferir de git.
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
7. **Ofrecé el DM de Slack:** preguntame si querés que te mande el brief (los 3-5 focos P0/P1 +
   bloqueos, texto corto) como **mensaje directo de Slack a vos mismo** vía el MCP de Slack
   (mi user id es `U0BQ2K3FEJU`). **Esperá mi OK antes de enviar** — es un aviso privado, no un
   post a un canal. Si el MCP de Slack no está disponible en la sesión, decímelo y seguí. (Esto
   es distinto del "draft de Slack" del paso 5, que es el update para el equipo que pego yo.)

**Si el modo es `prep`:** frenás acá — mostrás el resumen del estado (paso 3) y NO escribís
la bitácora ni el draft. Es el modo del job automatizado / vistazo rápido.

## Si es CIERRE (`cierre`)

1. **Reconstruí el día desde lo que registramos en Claude**: engram (`mem_search` del día,
   los `mem_save` de cierre de stage) + git/PRs. Preguntame solo lo que no surja de ahí.
   **Actualizá los dos backlogs** (marcá `[x]`, movés a "Hecho").
2. Actualizá la bitácora de hoy: "Ayer cerré" pasa a reflejar lo real, bloqueos al día.
3. Si cambió algo **durable** (nuevo entregable, cambio de reparto, decisión de arquitectura), actualizá
   la memoria de Claude (versionada: `mauro-docs/claude-memory/mango/` — ambas cuentas
   symlinkean ahí) y su `MEMORY.md`. Guardá un resumen del día en engram (`mem_save`,
   convención `mm-...`).
4. Resumen corto de lo cerrado y lo que queda para mañana.
5. Si es **viernes**, recordame correr `/semana` (la fuente de sabiduría).

## Reglas

- **Nada de secretos** en las bitácoras (tokens, `.env`, RFCs/datos reales de clientes).
- No postees a Slack ni pushees a repos de Mango — generá drafts y esperá mi OK.
- Todo cambio de archivos es dentro de `mauro-docs/` o mi config personal de Claude.
- Sé directo y conciso, mostrame evidencia (git/PR real), no me hagas confiar a ciegas.
