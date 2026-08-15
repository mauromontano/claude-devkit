---
description: Review profundo multi-agente de una PR/branch — dimensiones en paralelo, verificación adversarial y recibo con evidencia.
argument-hint: "[PR número | branch | vacío = diff actual contra la base]"
---

Target: **$ARGUMENTS** (vacío → el diff de la branch actual contra su base).

Sos el orquestador de un review profundo estilo "9 agentes" (el formato que ya se usa en el
equipo). Es caro en tokens y tiempo: se usa al **cerrar una PR**, no en stages intermedios
(para eso está `/review`). Usá la orquestación de workflows/subagentes en paralelo.

## 1. Preparación

- Resolvé el diff completo del target (`gh pr diff <n>` o `git diff <base>...HEAD`) y la lista
  de archivos tocados.
- Cargá el rubric: las rules del repo (`.claude/rules/shared-*.md`, `eng-*`) y, si aplica, el
  `plan.md` de la spec de la feature en `mango-engineering`.

## 2. Dimensiones en paralelo (6 finders, subagentes read-only)

Cada finder recibe el diff + el rubric de su dimensión y devuelve hallazgos estructurados
(`archivo:línea`, qué, impacto, fix propuesto, severidad tentativa):

1. **Seguridad/robustez** — authz/IDOR, input externo, secretos, inyección, manejo de errores.
2. **Datos/schema** — migraciones, índices, soft-deletes, scopes, transacciones, realidad de
   los datos (verificá contra `mysql-local` read-only si está; prod read-only solo si hace falta).
3. **Arquitectura/reuso** — duplicación, capas, patrones del repo (¿ya existe un servicio/scope
   que hace esto?).
4. **Convenciones** — rules `eng-*`/`shared-*` literalmente (type hints, naming, ubicación de
   tests, commits).
5. **Tests/TDD** — cobertura de lo cambiado, tests que no pueden fallar, evidencia del
   `## Testing` reproducible (rule shared-11).
6. **Alineación plan↔código** — el diff contra el plan/spec: scope creep, faltantes, decisiones
   no documentadas.

Complementos cuando aporten: **Context7** (`ctx7`) para verificar comportamiento del framework
(Laravel 9.x / Next.js) en vez de asumir de memoria; **Codex** como cross-review de otro modelo
si está disponible (la divergencia entre modelos = señal para mirar más fino).

## 3. Verificación adversarial

Cada hallazgo pasa por un verificador independiente que **intenta refutarlo** (leyendo el
código real, corriendo el test, consultando la DB). Solo sobreviven los confirmados.
Marcas de evidencia en el reporte: **✓** = ejecutado/verificado contra código o datos reales,
**~** = plausible sin reproducción. Nunca presentes un ~ como ✓.

## 4. Síntesis: el reporte y sus 3 entregables

- Severidades: **🟠 media-alta (bloquea)** · **🟡 media (decisión de diseño)** · **🔵 baja** ·
  **proceso/evidencia**. Cada hallazgo: `archivo:línea` + impacto concreto + fix propuesto + marca.
- Sección **"Lo que está bien"** (obligatoria — el review también confirma).

Entregables, siempre los tres:

1. **Doc HTML del audit** (con lujo de detalle): un HTML autocontenido con cada bug explicado —
   qué es, dónde (`archivo:línea` con el snippet), el escenario concreto de falla, por qué
   importa, y los **fixes posibles con sus trade-offs** (cuál recomendás y por qué). Incluí la
   metodología (dimensiones, verificación adversarial, marcas ✓/~) y "Lo que está bien".
   Guardalo en `mauro-docs/mango/<feature>/<pr>-auditoria.html` (o `docs/` del repo si se va a
   commitear) y publicalo como artifact si conviene compartirlo.
2. **Bloque copiable A — el audit para el PR**: markdown listo para pegar como comentario del
   PR. Formato: metodología en 1 línea + tabla/lista de hallazgos por severidad
   (`archivo:línea`, una línea cada uno, marca ✓/~) + link al doc/artifact. Es el recibo.
3. **Bloque copiable B — la respuesta con los fixes**: markdown listo para pegar como respuesta
   al audit, con qué se va a atacar y cómo (una línea por hallazgo: fix ahora / deuda `TD-###` /
   declinado con razón). Lo drafteás desde MIS decisiones en el gate — mostrame los hallazgos,
   yo decido hallazgo por hallazgo, y ahí lo armás.

## Reglas

- Read-only sobre el código (los fixes los decido yo después, hallazgo por hallazgo).
- Evidencia antes que narración: si no lo verificaste, marcalo ~.
- Nada de datos reales de clientes en el reporte (RFCs, CLABEs, montos identificables).
