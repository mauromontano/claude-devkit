---
description: Consultar las DBs de Mango (local / dev / prod read-only) con túnel automático — sin re-explicar nada.
argument-hint: [local|dev|prod] [qué querés consultar]
allowed-tools: Bash(mango-db.sh:*), Bash(~/Documents/GitHub/claude-devkit/bin/mango-db.sh:*), Bash(mysql --login-path=mango-dev:*), Bash(mysql --login-path=mango-local:*), Bash(nc -z:*)
---

Consulta a la DB de Mango. Pedido: $ARGUMENTS

## Matriz de conexión (no la re-derives — es esta)

| Entorno | Túnel | Conexión | Notas |
|---|---|---|---|
| **local** (Docker de mango-api) | no necesita | `127.0.0.1:3309`, DB `mango_local` | creds en `mango-api/.env.local` |
| **dev** (DigitalOcean managed) | `mango-db.sh tunnel dev` | `127.0.0.1:3309` vía login-path `mango-dev` | ⚠ comparte 3309 con local |
| **prod (read-only)** | `mango-db.sh tunnel prod` | `127.0.0.1:3308`, DB `mang_mango`, login-path `mango-prod-ro` | usuario GRANT SELECT |

Script: `~/Documents/GitHub/claude-devkit/bin/mango-db.sh` (status | tunnel dev|prod | down).
Runbook completo: `mauro-docs/guides/accesos-mango.md`.

## Flujo

1. `mango-db.sh status` — mirá qué hay arriba. **3309 es compartido**: si lo tiene el
   MySQL local de Docker y necesitás dev (o viceversa), avisame el conflicto — no bajes
   nada por tu cuenta.
2. Si falta el túnel: `mango-db.sh tunnel dev` (o `prod`).
3. Query:
   - **local/dev:** directo — `mysql --login-path=mango-dev -e "SELECT ..."` (o el MCP
     `mysql-local` si está en la sesión; ojo: el MCP apunta a 3309, o sea consulta
     **dev si el túnel está arriba, local si no** — verificá cuál es con `status`).
   - **prod:** SOLO lectura. **Mostrame el SQL exacto y explicá qué busca ANTES de
     ejecutar** — el permission prompt de `mango-prod-ro` es el gate a propósito, no
     lo esquives. Nunca más de un `SELECT` por aprobación.

## Reglas

- **Jamás** tocar `.env`/`.env.local` para apuntar la app a otra DB.
- Passwords nunca en argv ni en el historial: login-paths (`~/.mylogin.cnf`) o `-p`
  interactivo. Si un login-path no existe, decime que corra el setup de
  `accesos-mango.md` § login-paths — no improvises credenciales.
- Prod: solo `SELECT` (el usuario es GRANT SELECT igual, pero no lo intentes).
- Diagnóstico si falla la conexión (escalera de `mango/mango-api/setup-y-accesos.html`):
  `communications link failure`/timeout → túnel caído (paso 2); error SSL → falta
  `--ssl-mode` requerido por DO; `Access denied` → credencial/usuario mal.
- Al terminar una sesión de trabajo con dev/prod, ofrecé `mango-db.sh down`.
