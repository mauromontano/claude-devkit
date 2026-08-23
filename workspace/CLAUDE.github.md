# Router de repos — ~/Documents/GitHub

Mapa para agentes: qué repo es qué y adónde ir. Se carga en toda sesión bajo este
directorio (es CLAUDE.md ancestro). Fuente canónica: `claude-devkit/workspace/`.

**Regla de ruteo: si no es obvio en qué repo va un cambio o dónde buscar algo,
PREGUNTÁ antes de tocar o explorar a ciegas.**

## Mango — core (trabajo diario)

| Repo | Qué es |
|---|---|
| `mango-api` | Backend Laravel (core API). Usa **AGENTS.md** (leerlo al entrar) |
| `mango-app-v2` | Cliente Next.js. Usa **AGENTS.md** |
| `mango-admin` | Panel admin Laravel. Tiene CLAUDE.md propio |
| `mango-engineering` | Governance: specs de features (`specs/`), `mcp/mcp.json` canónico, reglas. Usa **AGENTS.md** |
| `mango-ops` | Artefactos de TL + **tooling en `tools/`** (`mangxo-deploy`, la CLI de deploy) |

## Mango — servicios y satélites (una línea c/u)

`mango-cobros` (collections) · `mango-transactions` · `mango-reminders` (Laravel) ·
`mango-directorio` · `mango-monitors` (CLAUDE.md propio) · `mango-shared-infra`
(CLAUDE.md propio) · `mango-capo` (prompt optimizer, CLAUDE.md propio) ·
`mango-landing` (Astro) · `mango-branding` · `mango-docs` (docs publicadas) ·
`money-makers` (onboarding comercial + riesgo).

## Personales — activos

| Repo | Qué es |
|---|---|
| `mauro-docs` | Estado personal: `guides/` (accesos, setup), `mango/` (docs por repo + proyecto activo), `daily/` (bitácoras + backlogs), `learning/` |
| `claude-devkit` | El motor: constitución, comandos, hooks, skills, este router. Cambios de proceso van acá |
| `vscode-config` | Config del editor (symlinks + extensiones) |

Otros directorios personales (side projects, katas, hw-*) — solo si la tarea los nombra.

## Para X andá a Y

| Necesitás | Andá a |
|---|---|
| Spec/contrato de una feature | `mango-engineering/specs/` (o `/contexto <feature>`) |
| Conectarte a la DB (local/dev/prod) | comando `/db` (túneles: `claude-devkit/bin/mango-db.sh`); runbook `mauro-docs/guides/accesos-mango.md` |
| Deploy | `mangxo-deploy` (`mango-ops/tools/`); guía en `mauro-docs/mango/` |
| Accesos, 1Password, SSH | `mauro-docs/guides/accesos-mango.md` (solo punteros, sin secretos) |
| Estado del proyecto activo / qué estoy haciendo | `mauro-docs/mango/mango-proyectos/` + `mauro-docs/daily/` |
| Cómo se documenta/trabaja un repo de Mango | su `AGENTS.md` o `CLAUDE.md` + `mauro-docs/mango/<repo>/` |

## Cuentas y límites

- **Una sola cuenta de Claude**: la de Mango, en `~/.claude`. No hay cuenta personal ni `claude-personal` (retirado el 2026-08-23).
- **Nada de secretos ni datos personales en repos de Mango** — solo punteros a 1Password.
- Cambios cross-repo: un commit/PR por repo, nunca mezclar Mango con personal.
