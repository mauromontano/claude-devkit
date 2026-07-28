---
name: feature-workflow
description: El proceso end-to-end para construir features (brainstorm → plan por capas → docs+diagrama → implementación incremental TDD → review por etapa). Se activa cuando se empieza una feature, módulo o cambio no trivial, o se menciona "plan", "TDD", "por etapas" o "punta a punta".
---

# Proceso de feature punta a punta

Cuando arranques una feature o cambio no trivial, seguí estas fases. Escalá la
profundidad según la complejidad (trivial / media / alta). Nunca saltes de una etapa de
implementación a la siguiente sin que la anterior esté en verde y revisada.

## Fase 0 — Brainstorm
Entendé antes de actuar. Reformulá el alcance, evaluá complejidad, hacé solo las
preguntas que cambian el diseño, y esbozá 2-3 enfoques con trade-off si no es obvio.

## Fase 1 — Plan por capas y etapas
Usá plan mode. Definí el **contrato de API primero**. Diseñá por capas (UI → estado →
servidor → dominio → datos → jobs). Partí en **etapas incrementales**, cada una
commiteable y con criterio de "hecho". Para el diseño, delegá a `architecture-planner`.

## Fase 2 — Docs + diagrama
Generá `docs/<feature>.md` (delegá a `docs-writer`) con problema, decisiones, contrato,
modelo de datos, etapas y riesgos. Generá un diagrama con **archify** (arquitectura /
secuencia / flujo según el caso). Commiteá antes de codear.

## Fase 3 — Implementación incremental con TDD
Por cada etapa: **rojo** (tests primero, delegá a `test-writer`) → **verde** (código
mínimo) → **refactor** → **verificar** (suite en verde). El hook PostToolUse corre
lint/format automáticamente tras cada edición.

## Fase 4 — Review por etapa
Delegá a `code-reviewer` (siempre) y a `security-reviewer` (si toca auth/pagos/datos
sensibles/input externo). Resolvé los bloqueantes antes de avanzar.

## Fase 5 — Cierre
Actualizá la doc, regenerá el diagrama si cambió la arquitectura, corré el suite
completo, y armá el commit/PR explicando el *por qué*.

Ver `docs/WORKFLOW.md` del devkit para el detalle completo.
