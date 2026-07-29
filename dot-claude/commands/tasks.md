---
description: Genera o actualiza el checklist de etapas (estado durable de la feature).
argument-hint: [nombre de la feature]
---

Generá o actualizá `docs/$ARGUMENTS-tasks.md`: el **checklist de etapas** del plan. Es el
estado durable de la feature — la fuente de verdad de qué falta.

Formato:

```markdown
# Tareas — <feature>

- [ ] Etapa 1: <qué> — criterio de hecho: <...>
- [ ] Etapa 2: <qué> — criterio de hecho: <...>
- [ ] Etapa 3: <qué> — criterio de hecho: <...>
```

Reglas:
- Una casilla por etapa, con su criterio de "hecho".
- Al cerrar cada etapa (después del review + verify), **tildá la casilla** y anotá el
  commit/branch si aplica.
- Este archivo es lo primero que se lee al retomar en una ventana nueva: dice exactamente
  en qué etapa estás. Mantenelo siempre al día.
