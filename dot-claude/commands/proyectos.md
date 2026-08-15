---
description: Cargar el contexto de mango-proyectos (quién soy, mi entregable, el estado) en cualquier repo.
---

Bootstrapeá el contexto de mi trabajo en **mango-proyectos**. Corré esto al abrir una sesión nueva en
`mango-api` o `mango-app-v2` para no re-explicar nada. Leé estos archivos (rutas absolutas, andan desde
cualquier repo) y después dame un resumen de 5 líneas de "dónde estoy parado":

1. `/Users/mauro/Documents/GitHub/mauro-docs/mango/mango-proyectos/ola-1.html` — mi entregable (bucket "Respaldo").
2. `/Users/mauro/Documents/GitHub/mauro-docs/mango/mango-proyectos/ola-0.html` — la Ola 0 de Ema + acceso/roles.
3. `/Users/mauro/Documents/GitHub/mauro-docs/daily/backlog-mango.md` — mis pendientes de trabajo.
4. `/Users/mauro/Documents/GitHub/mango-engineering/specs/mango-proyectos/001-mango-proyectos/olas/1-bucket/plan.md`
   — el plan oficial de la Ola 1 (fuente de verdad del alcance).

## Quién soy y qué hago (resumen durable)

- Soy **Mauro**, Senior SWE en Mango, reporto a **Matías Ríos**. Compañero de equipo: **Ema** (owna el
  vertical crítico, olas 0·2·3).
- Mi entregable MVP (deadline **20-ago**, piso 23-ago): **Ola 1 = el bucket "Respaldo"** — subir/consultar/
  borrar archivos de obra end-to-end en `mango-api` + `mango-app-v2`. Tabla índice `project_files`,
  subida por Server Action, descarga por Route Handler, policy, validación PDF/XLS por contenido, 7 PRs apiladas.
- Me apoyo en las branches de Ema: `feat/proyectos-expediente-datos` (api) y `feat/proyectos-expediente` (app).
- Acceso a Proyectos = por **rol** (admin-customer / customer ven; supplier no), scopeado por `owner_id`.
- Bloqueo conocido: **R2 dev nunca funcionó** → los tests van con `Storage::fake()`; el upload real local
  no anda hasta resolverlo con Mati.

## Reglas de mi flujo

- Trabajo con TDD (test primero), un stage = un commit = una PR, Conventional Commits, y **paro al cerrar
  cada stage** para revisar. `security-reviewer` en las PRs de upload/download/policy.
- Nada personal se pushea a repos de Mango. Mi organización diaria vive en `mauro-docs/daily/` (comando `/dia`).

Si estoy en `mango-api`, arrancá pensando en las PRs 1-3 (backend). Si estoy en `mango-app-v2`, las PRs 4-7 (frontend).
