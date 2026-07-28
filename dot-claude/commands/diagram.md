---
description: Genera un diagrama de la feature con archify (arquitectura / secuencia / flujo).
argument-hint: [qué diagramar]
---

Generá un diagrama para: **$ARGUMENTS**

Usá la skill **archify**. Elegí el tipo según el caso:
- **arquitectura** si hay varias piezas/servicios y sus relaciones,
- **secuencia** si el foco es un flujo de llamadas en el tiempo (ej. pago + webhook),
- **flujo / estado** si hay un proceso con ramas o una máquina de estados.

Basate en la doc de diseño (`docs/`) y en el código actual para que el diagrama refleje
la realidad. Guardá el HTML resultante en `docs/`. Si no hay suficiente contexto,
preguntá qué parte del sistema querés visualizar antes de generar.
