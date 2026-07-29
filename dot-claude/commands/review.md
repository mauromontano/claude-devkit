---
description: Revisa la etapa actual con los subagents de review antes de avanzar.
argument-hint: [contexto opcional de la etapa]
---

Revisá la etapa recién terminada antes de avanzar.

1. Delegá al subagent `code-reviewer` (siempre): calidad, diseño, cobertura.
2. Si la etapa toca auth, pagos, datos sensibles, webhooks o input externo, delegá
   **además** al subagent `security-reviewer`.
3. Delegá al subagent `spec-verifier` (verify): confirmá que la etapa **cumple los
   scenarios del spec** (`docs/<feature>-spec.md`), scenario por scenario. Un scenario
   sin cobertura es bloqueante.
4. Consolidá los hallazgos por severidad. **Resolvé todos los 🔴 bloqueantes/críticos
   antes de continuar.** Si un hallazgo cambia el diseño, volvé a la fase de plan para esa parte.
5. Cuando no queden bloqueantes: tildá la etapa en `docs/<feature>-tasks.md`, actualizá la
   doc (`docs-writer`), corré el suite completo, y preparé el commit explicando el *por qué*.
6. **PARÁ y esperá mi aprobación.** Mostrame un resumen (qué cambió, tests, scenarios
   verificados y hallazgos) y no avances a la etapa siguiente hasta que yo te dé el OK.

Contexto adicional: $ARGUMENTS
