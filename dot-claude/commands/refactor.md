---
description: Refactor seguro sobre código existente (entender → red de tests → pasos chiquitos → verificar comportamiento).
argument-hint: <qué refactorizar / archivo>
---

Vamos a refactorizar: **$ARGUMENTS**. Regla absoluta: **no cambiar el comportamiento
observable**. Refactor y cambio de funcionalidad son cosas separadas (los "dos sombreros").

Seguí estas fases y **pará entre cada una esperando mi OK**. Un movimiento por vez; yo
reviso cada diff.

Apoyate en el resto del setup cuando sume (sin pedir permiso para lo obvio):
- La **skill del lenguaje/framework** que corresponda al stack del proyecto.
- El subagente **`test-writer`** para escribir los characterization tests de la Fase 2.
- Los subagentes **`code-reviewer`** y **`spec-verifier`** en la Fase 4, para confirmar
  calidad y que el comportamiento no cambió.
- **archify** si un diagrama antes/después de la estructura ayuda a explicar el refactor.
- Una skill de **docs** si necesitás la API real de una librería.
Igual: el control es mío. Nada de delegar el refactor entero a un subagente; los usás como
herramientas puntuales, no para saltearte los pasos chiquitos.

## Fase 1 — Entender (sin tocar código)
- Leé el código objetivo y sus tests. Explicame qué hace y qué comportamiento cubren los tests.
- Listá los code smells (función larga, condicional por tipo, cálculo mezclado con formato, temporales).

## Fase 2 — Asegurar la red
- Corré los tests (y la cobertura, si el proyecto la tiene). Identificá qué casos **no** están cubiertos.
- Si falta cobertura, agregá **characterization tests**: fijan el comportamiento ACTUAL
  (self-checking). No toques los tests existentes que ya pinnean comportamiento.

## Fase 3 — Refactor en pasos chiquitos
- **Un movimiento de refactor por vez** y nombralo (Extract Function, Replace Temp with Query,
  Split Loop, Split Phase, Replace Conditional with Polymorphism, etc.).
- Después de **cada** paso: corré los tests (tienen que quedar verdes) y proponé un commit.
  Si algo se pone rojo, revertí ese paso y avisá.
- Nunca mezcles un refactor con un cambio de comportamiento en el mismo paso.

## Fase 4 — Verificar
- Confirmá que **todos** los tests siguen verdes y que el comportamiento observable no cambió.
- Corré análisis estático y estilo al final (no en cada paso).

Si al final hay que **agregar** una feature nueva sobre el código ya limpio, ahí sí cambiamos
de sombrero: eso va con su propio test (rojo → verde), separado del refactor.
