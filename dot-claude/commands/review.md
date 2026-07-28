---
description: Revisa la etapa actual con los subagents de review antes de avanzar.
argument-hint: [contexto opcional de la etapa]
---

Revisá la etapa recién terminada antes de avanzar.

1. Delegá al subagent `code-reviewer` (siempre).
2. Si la etapa toca auth, pagos, datos sensibles, webhooks o input externo, delegá
   **además** al subagent `security-reviewer`.
3. Consolidá los hallazgos por severidad. **Resolvé todos los 🔴 bloqueantes/críticos
   antes de continuar.** Si un hallazgo cambia el diseño, volvé a la fase de plan para esa parte.
4. Cuando no queden bloqueantes: actualizá la doc de la feature (`docs-writer`), corré el
   suite completo, y preparé el commit con un mensaje que explique el *por qué*.
5. **PARÁ y esperá mi aprobación.** Mostrame un resumen (qué cambió, tests, hallazgos y
   cómo se resolvieron) y no avances a la etapa siguiente hasta que yo te dé el OK.

Contexto adicional: $ARGUMENTS
