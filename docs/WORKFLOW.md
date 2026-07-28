# El proceso de feature, punta a punta

Este es el flujo que sigo para construir cualquier feature con Claude Code. Está pensado
para ser **agnóstico del stack** y **escalable según complejidad**: una feature chica
recorre las mismas fases pero más liviano; una compleja se toma cada fase en serio.

El disparador es `/feature <descripción>`. A partir de ahí, el ciclo es:

```
Brainstorm → Plan → Docs+Diagrama → [ Etapa → Test → Código → Review ]×N → Cierre
```

Regla de oro: **no se avanza de etapa sin la anterior en verde y revisada.**

---

## Fase 0 — Brainstorm y encuadre

**Objetivo:** entender el problema real antes de escribir una línea.

Claude debe, según la complejidad del pedido:

- Reformular la tarea con sus palabras y confirmar el alcance.
- Hacer las preguntas que cambian el diseño (no las triviales). Ej.: ¿esto necesita ser
  transaccional? ¿hay concurrencia? ¿quién consume el endpoint? ¿qué pasa si falla a la mitad?
- Detectar riesgos, dependencias y casos borde temprano.
- Proponer 2-3 enfoques posibles con su trade-off cuando la decisión no es obvia.

**Escalado por complejidad:**

| Complejidad | Qué hace la fase 0 |
|-------------|--------------------|
| Trivial (1 archivo, sin diseño) | Confirma en una línea y arranca. |
| Media (varios archivos, un endpoint) | 2-4 preguntas de alcance + enfoque elegido. |
| Alta (nuevo módulo, datos, integraciones) | Brainstorm completo, alternativas, riesgos, y recién ahí plan. |

**Salida:** un entendimiento compartido del problema y el enfoque general.

---

## Fase 1 — Plan por capas y etapas

**Objetivo:** un plan incremental y revisable, no un chorro de código.

Se usa **plan mode** (Claude propone sin editar disco). El plan debe tener:

1. **Diseño por capas** — qué toca en cada capa (UI, estado, servidor, dominio, datos).
2. **Contrato de API** — forma de request/response y modelo de datos. Se fija acá.
3. **Etapas incrementales** — la feature partida en pasos chicos. Cada etapa:
   - es un incremento que compila y pasa tests,
   - tiene un criterio de "hecho" explícito,
   - es un punto de commit válido.
4. **Estrategia de test** — qué se testea en cada etapa y a qué nivel.
5. **Riesgos y rollback** — qué puede salir mal y cómo se revierte.
6. **Estrategia de entrega** — si la feature es grande, cómo se parte en varios
   branches/PRs y en qué orden se mergean. Las **migraciones/cambios de schema van en su
   propio branch/PR**, mergeado antes que el código que las usa.

Para el diseño de arquitectura y las alternativas se puede delegar al subagent
`architecture-planner`, que razona sobre trade-offs sin ensuciar el contexto principal.

**Salida:** un plan aprobado, dividido en etapas numeradas.

---

## Fase 2 — Documentación y diagrama

**Objetivo:** que el diseño quede escrito y visual antes de implementar.

- `/document` genera `docs/<feature>.md`: problema, decisiones, contrato de API, modelo
  de datos, y la lista de etapas del plan. Es la fuente de verdad del diseño.
- `/diagram` invoca **archify** para producir el diagrama que corresponda:
  - **arquitectura** si hay varias piezas/servicios,
  - **secuencia** si el foco es un flujo de llamadas (ej. un pago con webhook),
  - **flujo/estado** si hay una máquina de estados o un proceso con ramas.

El diagrama se guarda como HTML en `docs/` (tiene toggle dark/light y export a PNG/SVG).

**Salida:** doc de diseño + diagrama, commiteados antes de codear.

---

## Fase 3 — Implementación incremental con TDD

**Objetivo:** construir etapa por etapa, siempre en verde.

Para cada etapa (`/stage <n>`), el ciclo estricto es:

1. **Rojo** — escribir el/los test que describen el comportamiento de la etapa. Corren y fallan.
2. **Verde** — el código mínimo para que pasen. Nada de más.
3. **Refactor** — limpiar con los tests de red de seguridad.
4. **Verificar** — correr el suite completo de la etapa; mostrar el verde.

El hook `PostToolUse` corre lint (y opcionalmente tests) automáticamente después de cada
edición, así los errores se ven al instante, no al final.

**Regla:** una etapa no está "hecha" hasta rojo→verde→refactor + suite en verde.

---

## Fase 4 — Review por etapa

**Objetivo:** cada incremento se audita antes de construir sobre él.

Al cerrar una etapa, `/review` delega a los subagents de review:

- **`code-reviewer`** (siempre): calidad, estilo vs CLAUDE.md, cobertura de tests,
  N+1, manejo de errores, complejidad innecesaria.
- **`security-reviewer`** (si la etapa toca auth, pagos, datos sensibles o input externo):
  inyección, XSS/CSRF, manejo de secretos, autorización, validación de entrada.

Los reviewers corren en contexto aislado y devuelven feedback accionable. Los hallazgos
se resuelven **antes** de pasar a la etapa siguiente. Si un hallazgo cambia el diseño,
se vuelve a la fase 1 para esa parte.

**Gate humano (obligatorio).** Después del review automático, Claude **PARA** y te muestra
un resumen: qué cambió, tests en verde, hallazgos y cómo se resolvieron. **No avanza a la
etapa siguiente sin tu OK explícito.** El review de los subagents no reemplaza tu revisión:
la prepara. Vos aprobás etapa por etapa.

**Salida:** etapa aprobada por vos, lista para commit.

---

## Fase 5 — Cierre

**Objetivo:** dejar todo consistente y listo para integrar.

- Actualizar `docs/<feature>.md` con lo que se aprendió o cambió respecto del plan.
- Correr el suite **completo** del proyecto (no solo el de la feature).
- Regenerar el diagrama si la arquitectura cambió.
- Armar el commit / PR con un mensaje que explique el *por qué*, no solo el *qué*.

---

## Mapa de fase → herramienta

| Fase | Comando | Subagent | Hook | Skill |
|------|---------|----------|------|-------|
| 0 Brainstorm | `/feature` | — | — | — |
| 1 Plan | plan mode | `architecture-planner` | — | — |
| 2 Docs+diagrama | `/document`, `/diagram` | `docs-writer` | — | archify |
| 3 Implementación | `/stage` | `test-writer` | PostToolUse (lint/test) | por framework |
| 4 Review | `/review` | `code-reviewer`, `security-reviewer` | — | — |
| 5 Cierre | commit/PR | — | PreToolUse (protege archivos) | — |

---

## Manejo del contexto en tareas grandes

El enemigo de una tarea larga es llenar la ventana de contexto y perder el plan. La
solución es **no usar el contexto como memoria** — externalizar el estado a disco:

- **El plan vive en `docs/<feature>.md`**, con el checklist de etapas y su estado. Esa es
  la fuente de verdad. Si tenés que abrir una ventana nueva (o `/clear`), la sesión
  siguiente lee ese doc y retoma exactamente donde quedaste. El plan no se pierde porque
  nunca vivió solo en el chat.
- **Los subagents aíslan el ruido.** Leer muchos archivos, correr suites y hacer reviews
  pasa en la ventana del subagent, no en la principal. El contexto principal queda liviano.
- **Commit por etapa.** El historial de git es estado recuperable: podés reconstruir dónde
  estás con `git log`.
- **Higiene de contexto.** `/compact` cuando la ventana se llena; `/clear` entre features;
  CLAUDE.md corto. Si una etapa se vuelve enorme, es señal de que hay que partirla más.

Regla práctica: si al terminar una etapa el `docs/<feature>.md` está actualizado y el
código commiteado, podés cerrar la ventana sin miedo — todo lo necesario para seguir está
en disco.

## Por qué este orden importa

- **Brainstorm antes de plan** evita planificar la cosa equivocada.
- **Plan antes de docs** evita documentar un diseño que va a cambiar.
- **Docs antes de código** hace que el contrato sea explícito y front/back paralelicen.
- **Test antes de código** hace que el código nazca cubierto.
- **Review antes de avanzar** evita construir sobre una base con deuda.

Cada fase existe para que la siguiente no se apoye en algo frágil.
