---
description: Genera o actualiza la doc de diseño de la feature en docs/<feature>.md.
argument-hint: [nombre de la feature]
---

Delegá al subagent `docs-writer` para generar o actualizar `docs/$ARGUMENTS.md` con el
estado actual del diseño: problema, decisiones (con alternativas descartadas), contrato
de API, modelo de datos, etapas con su criterio de hecho y estado, y riesgos/rollback.

Si ya existe, actualizalo para reflejar lo que realmente se construyó, no lo planeado.
