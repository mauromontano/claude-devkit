---
description: Implementa una etapa del plan con TDD (rojo → verde → refactor).
argument-hint: <número o nombre de la etapa>
---

Implementá la etapa: **$ARGUMENTS**

Seguí TDD estricto (Fase 3 de `docs/WORKFLOW.md`):

1. **Rojo** — delegá al subagent `test-writer` para escribir los tests de esta etapa.
   Confirmá que corren y fallan por la razón correcta.
2. **Verde** — escribí el código mínimo para que los tests pasen. Nada de más.
3. **Refactor** — limpiá con los tests como red de seguridad.
4. **Verificar** — corré el suite de la etapa y mostrá el verde.

No implementes nada fuera del alcance de esta etapa. Cuando esté en verde, corré
`/review` y después **PARÁ**: mostrame el resumen y esperá mi OK explícito antes de
tocar la etapa siguiente. No encadenes etapas sin mi aprobación.
