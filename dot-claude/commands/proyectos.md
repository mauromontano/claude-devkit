---
description: Cargar el contexto de mango-proyectos (quién soy, mi entregable, el estado) en cualquier repo.
---

Este comando es el atajo de **`/contexto mango-proyectos`**: seguí las instrucciones de
`contexto.md` con la feature `mango-proyectos`, y sumá este contexto durable mío:

## Quién soy y qué hago (resumen durable)

- Soy **Mauro**, Senior SWE en Mango, reporto a **Matías Ríos**. Compañero de equipo: **Ema**
  (owna el vertical crítico, olas 0·2·3).
- Mi entregable MVP (deadline **20-ago**, piso 23-ago): **Ola 1 = el bucket "Respaldo"** —
  subir/consultar/borrar archivos de obra end-to-end en `mango-api` + `mango-app-v2`.
  Tabla índice `project_files`, subida por Server Action, descarga por Route Handler,
  policy (`denyAsNotFound()` → 404), validación PDF/XLS por contenido, 7 PRs apiladas.
- Me apoyo en las branches de Ema: `feat/proyectos-expediente-datos` (api) y
  `feat/proyectos-expediente` (app).
- Acceso a Proyectos = por **rol** (admin-customer / customer ven; supplier no), scopeado
  por `owner_id`.
- Bloqueo conocido: **R2 dev nunca funcionó** → los tests van con `Storage::fake()`; el
  upload real local no anda hasta resolverlo con Mati.

Si estoy en `mango-api`, arrancá pensando en las PRs 1-3 (backend). Si estoy en
`mango-app-v2`, las PRs 4-7 (frontend).
