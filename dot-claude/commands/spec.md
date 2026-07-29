---
description: Genera el spec de la feature con requisitos y scenarios de aceptación (Given/When/Then).
argument-hint: [nombre de la feature]
---

Generá o actualizá `docs/$ARGUMENTS-spec.md` con el spec de la feature. Delegá a
`docs-writer` si conviene. Estructura:

## Requisitos
Lista de lo que la feature tiene que hacer, en lenguaje de negocio (no de implementación).

## Scenarios de aceptación
Uno por comportamiento observable, en formato **Given / When / Then**. Cubrí el happy
path, los bordes y los casos de error. Ejemplo:

- **Scenario: giro dentro del disponible**
  - Given una línea con disponible 1000
  - When se registra un giro de 400
  - Then el giro queda en el ledger y el disponible pasa a 600

- **Scenario: giro que excede el disponible**
  - Given una línea con disponible 300
  - When se registra un giro de 500
  - Then se rechaza con 422 y el ledger no cambia

Reglas:
- Cada scenario tiene que ser **objetivamente verificable** — es, básicamente, un test.
- No metas detalles de implementación (ni tablas, ni clases): eso va en `docs/<feature>.md`.
- Estos scenarios son lo que después valida el subagent `spec-verifier` contra el código.
