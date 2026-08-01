---
description: Generate a diagram of the feature with archify (architecture / sequence / flow).
argument-hint: [what to diagram]
---

Generate a diagram for: **$ARGUMENTS**

Use the **archify** skill. Pick the type by the case:
- **architecture** if there are several pieces/services and their relationships,
- **sequence** if the focus is a call flow over time (e.g. payment + webhook),
- **flow / state** if there's a branching process or a state machine.

Base it on the design docs (`docs/`) and the current code so the diagram reflects
reality. Save the resulting HTML in `docs/`. If there isn't enough context, ask which
part of the system to visualize before generating.
