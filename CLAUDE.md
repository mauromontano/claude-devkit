# Constitución de ingeniería

Instrucciones globales para trabajar conmigo en cualquier proyecto. Son principios de
*proceso*, no de un stack puntual. Si el repo tiene su propio `CLAUDE.md`, ese manda
sobre lo específico; esto queda como base.

## Cómo trabajás conmigo

- **Entendé antes de actuar.** Ante una tarea no trivial, primero clarificá alcance,
  supuestos y casos borde. Si algo es ambiguo y cambia el diseño, preguntá. No adivines
  requisitos importantes.
- **Planificá antes de escribir.** Para cualquier cosa con más de ~2 archivos o una
  decisión de diseño, usá plan mode y proponé un plan por etapas antes de tocar código.
- **Incremental, nunca big-bang.** Dividí el trabajo en etapas chicas y revisables.
  Cada etapa debe compilar, pasar tests y ser un punto de commit válido.
- **Mostrá el trade-off.** Cuando elijas un enfoque, nombrá la alternativa que
  descartaste y por qué. Un buen diseño se defiende explicando qué *no* se hizo.
- **Sé honesto con la incertidumbre.** Si no sabés algo o no lo puedo verificar,
  decilo. Preferí "no estoy seguro, lo verifico" antes que afirmar de más.

## TDD por defecto

- Escribí el test **primero**. Rojo → código mínimo → verde → refactor.
- No implementes lógica sin un test que la cubra. Los casos borde y de error también
  van testeados, no solo el happy path.
- Antes de dar una etapa por terminada, corré el suite y mostrá que está en verde.
- Si un cambio no es testeable, eso es señal de que el diseño necesita ajustarse.

## Arquitectura: capas con responsabilidades claras

Pensá toda feature como capas con un **contrato de API en el medio** que separa front
de back, para que ambos avancen en paralelo sin bloquearse.

**Front (Next.js / React):**
1. Componente UI — server component por default; `'use client'` solo si hay interactividad.
2. Estado — cliente (Zustand/useState) vs server-state (TanStack Query). Cada uno a lo suyo.
3. Capa de datos server-side — validación con Zod, manejo de lo sensible (tokens/auth).
4. Transporte — cliente de API tipado que habla el contrato.
5. Todo componente con sus 4 estados: loading / error / vacío / éxito.

**Back (Rails / Express / el que sea):**
1. Ruta → controller **fino** (recibe, autoriza, delega; sin lógica de negocio).
2. Autorización antes de tocar nada (policies / middleware).
3. Lógica de negocio en **service objects** (una responsabilidad por servicio).
4. Persistencia con validaciones; operaciones multi-tabla dentro de una **transacción**.
5. Serialización con formato consistente.
6. Trabajo pesado o diferido → **jobs en background**, nunca en el request.

**El patrón es el mismo en cualquier framework:** controller fino → validación →
service → modelo/ORM → serializer → jobs. Cambia el nombre, no la estructura.

## Contrato primero

Definí la forma del endpoint (request/response) y el modelo de datos **antes** de
implementar. Con el contrato fijo, back y front avanzan en paralelo. El contrato vive
en la doc de la feature.

## Documentación y diagramas como parte del trabajo

- Cada feature no trivial genera un `docs/<feature>.md` con: problema, decisiones,
  contrato de API, modelo de datos y las etapas del plan.
- Para algo con varias piezas o flujos, generá un diagrama con **archify** (arquitectura,
  secuencia o flujo). El diagrama es parte del entregable, no un extra.
- La doc se actualiza al cerrar cada etapa, no al final de todo.

## Calidad y seguridad

- Cada etapa pasa por el subagent `code-reviewer` antes de avanzar.
- Features que tocan auth, pagos, datos sensibles o input externo → también
  `security-reviewer`.
- Nada de secretos hardcodeados. Input externo siempre validado. Queries siempre
  parametrizadas.
- Antes de un commit/PR: lint limpio, tests en verde, doc actualizada.

## Gate humano por etapa (importante)

- Al terminar cada etapa, **PARÁ**. Mostrame un resumen (qué cambió, tests en verde,
  hallazgos del review) y **esperá mi OK explícito** antes de arrancar la siguiente.
- No encadenes varias etapas sin mi aprobación. Yo reviso, apruebo, y recién ahí seguís.
- Si un hallazgo del review cambia el diseño, no lo arregles a lo bruto: proponé el
  ajuste y esperá mi confirmación.

## Estrategia de branches y migraciones

- Si en el plan detectás que la feature es grande, proponé **partirla en varios
  branches/PRs** con un orden de merge claro, en vez de un PR gigante.
- Las **migraciones y cambios de schema van en su propio branch/PR**, mergeado y
  desplegado **antes** que el código que los usa. Nunca mezcles migración pesada con
  lógica de feature en el mismo PR.
- Cambios que se pueden desplegar y revertir de forma independiente = branches
  separados. Decilo en la fase de plan, no a mitad de la implementación.

## Manejo del contexto en tareas largas

- El estado vive en `docs/<feature>.md` (plan + checklist de etapas con su estado), no en
  tu memoria de contexto. Si hay que empezar una sesión nueva, leé ese doc y retomá.
- Delegá el trabajo ruidoso (leer muchos archivos, correr suites, reviews) a subagents
  para no llenar el contexto principal.
- Commit por etapa: el historial de git es estado recuperable.
- Si el contexto se llena, sugerí `/compact`; entre features, `/clear`.

## Estilo de comunicación conmigo

- Directo y conciso. Sin relleno ni disculpas de más.
- Cuando termines una etapa, resumí en 2-3 líneas qué cambió y qué sigue.
- Mostrá diffs y resultados de tests; no me pidas que confíe, mostrame la evidencia.

## Notas por stack

- **Node/Express:** servicios por dominio, validación con Zod, jobs con Bull/BullMQ,
  tests con Jest. Errores con un handler central, no try/catch disperso.
- **Next.js/React/TS:** App Router, server components por default, TanStack Query para
  server-state, Zustand para UI-state, patrón container/presentational.
- **Ruby on Rails:** controllers finos, Pundit para autorización, service objects,
  serializers, Sidekiq para jobs, RSpec para tests, RuboCop + Brakeman en CI.
- **Laravel / PHP:** el mapa es idéntico — controller fino → Form Request (validación) →
  service → Eloquent (modelo) → API Resource (serializer) → Queue/Jobs. TDD con Pest o
  PHPUnit, lint con Pint, análisis estático con Larastan/PHPStan, autorización con
  Policies/Gates. Conceptos iguales a Rails; me pongo productivo rápido.
