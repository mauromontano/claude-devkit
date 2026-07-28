# Ecosistema: skills, plugins, MCPs y hooks a sumar

Recomendaciones para completar el setup, ordenadas por impacto para mi stack
(Node/Express, Next.js/React/TS, Rails) y mi flujo (plan-first, TDD, review por etapa).

> El ecosistema de Claude Code se mueve rápido. Antes de instalar algo, verificá que esté
> mantenido (último commit, issues abiertos) y probalo en un proyecto de juguete.

## Lo que ya tengo

- **superpowers** — marketplace/plugin con skills y workflow. Ya instalado.
- **context** (docs) y **archify** (diagramas) — skills. Ya instaladas.
- Skills por framework/lenguaje. Ya instaladas.

## 1. Enforcement de TDD (lo más alineado con mi proceso)

- **tdd-guard** — hook que bloquea escribir implementación si no hay un test que falle
  primero. Es exactamente la Fase 3 del workflow, automatizada a nivel hook (no depende
  de que yo o el agente "se acuerden"). Soporta varios runners (Jest/Vitest, RSpec, etc.).
  → El candidato más fuerte para sumar. Verificá el estado del repo antes de adoptarlo.

Alternativa casera si no querés una dependencia: un hook `PreToolUse` propio que, cuando
se edita un archivo de código no-test, chequee que exista y falle su test asociado. Más
frágil, pero cero dependencias.

## 2. MCP servers a conectar

Los MCP le dan al agente acceso a herramientas reales. Los que más rinden para mi stack:

| MCP | Para qué | Por qué me sirve |
|-----|----------|------------------|
| **context7** | Docs actualizadas de librerías | Evita que el agente alucine APIs de Next/React/Rails; trae la doc real de la versión. |
| **Playwright MCP** | Manejar un browser real | Tapa el hueco de e2e que hoy no tengo. Flujos críticos: login, checkout. |
| **GitHub MCP** | Issues, PRs, code review | Cierra el loop del proceso: abrir PR, leer reviews, iterar sin salir de la terminal. |
| **Postgres/MySQL MCP** | Introspección de schema y queries | El agente entiende el modelo de datos real en vez de adivinarlo. |
| **Sentry / APM MCP** | Errores de producción | Traer un stack trace real al contexto para debuggear. |

Empezá por **context7** y **Playwright**: son los que más mueven la aguja para mi combo
front-heavy + hueco de e2e.

## 3. Subagents que ya incluye este devkit

`architecture-planner`, `code-reviewer`, `test-writer`, `security-reviewer`, `docs-writer`.
Cubren planning, TDD y review por etapa sin ensuciar el contexto principal. Si aparece una
necesidad recurrente (ej. un `migration-reviewer` para cambios de schema, o un
`perf-auditor`), se agrega un `.md` más en `dot-claude/agents/`.

## 4. Plugins/marketplaces a mirar

- **superpowers** (ya lo tengo) — mantenelo actualizado; suele traer skills y comandos nuevos.
- Listas tipo **"awesome-claude-code"** — buen radar de skills/plugins/hooks de la
  comunidad. Útil para descubrir, no para instalar a ciegas.
- **Mi propio marketplace** — cuando este devkit madure, puedo empaquetarlo como plugin y
  publicar un `marketplace.json` en un repo privado. Así lo instalo con `/plugin` en vez de
  symlinks, y puedo versionarlo. Es el paso natural después de los dotfiles.

## 5. Hooks adicionales a considerar

- **PostToolUse (ya incluido)** — lint/format tras cada edición.
- **PreToolUse protect-paths (ya incluido)** — bloquea editar `.env`, schema, claves.
- **Stop / SubagentStop** — correr el suite completo cuando el agente "termina", para que
  no cierre una etapa en rojo.
- **SessionStart** — cargar contexto del proyecto (rama actual, últimos cambios) al abrir.

## Orden de adopción sugerido

1. Usar este devkit tal cual (agents + commands + hooks) en un proyecto real una semana.
2. Sumar **context7** MCP.
3. Sumar **tdd-guard** (o el hook casero de TDD).
4. Sumar **Playwright MCP** para e2e de los flujos críticos.
5. Empaquetar todo como plugin + marketplace privado cuando esté estable.

No instales todo de una: cada pieza cambia cómo trabajás, y conviene sentir el efecto de
una antes de sumar la siguiente.
