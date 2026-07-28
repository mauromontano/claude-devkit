---
description: Arranca el flujo de una feature punta a punta (brainstorm → plan → docs → TDD → review).
argument-hint: <descripción de la feature>
---

Voy a construir esta feature: **$ARGUMENTS**

Seguí el proceso de `docs/WORKFLOW.md`. No escribas código todavía. Empezá por la **Fase 0
(brainstorm)**:

1. Reformulá la feature con tus palabras y confirmá el alcance.
2. Evaluá la complejidad (trivial / media / alta) y ajustá la profundidad en consecuencia.
3. Hacé solo las preguntas que cambian el diseño (transaccionalidad, concurrencia,
   consumidores del endpoint, qué pasa si falla a la mitad, límites de alcance). No
   preguntes trivialidades.
4. Si la decisión de diseño no es obvia, esbozá 2-3 enfoques con su trade-off.

Cuando tengamos el problema claro, pasá a **plan mode** y delegá el diseño de arquitectura
al subagent `architecture-planner`. Recién con el plan aprobado seguimos a docs e
implementación. Una etapa a la vez, en verde y revisada antes de avanzar.
