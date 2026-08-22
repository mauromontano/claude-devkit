#!/usr/bin/env bash
# mango-db.sh — túneles y acceso rápido a las DBs de Mango (dev / prod read-only).
#
# Versión versionada de las funciones que vivían en ~/.zshrc.local (que ahora
# puede quedar con aliases finos a este script). Runbook completo:
# mauro-docs/guides/accesos-mango.md
#
# Uso:
#   mango-db.sh status          # qué túneles están arriba y quién ocupa 3308/3309
#   mango-db.sh tunnel dev      # asegura el túnel dev (3309) — no abre mysql (para agentes)
#   mango-db.sh tunnel prod     # asegura el túnel prod (3308) — no abre mysql
#   mango-db.sh dev  [user]     # túnel dev + mysql interactivo (humano)
#   mango-db.sh prod [user]     # túnel prod + mysql interactivo a mang_mango (read-only)
#   mango-db.sh down            # cierra los túneles en background
#
# Usuarios (no secretos): argumento > $MANGO_DB_DEV_USER / $MANGO_DB_PROD_USER > prompt.
# Passwords: SIEMPRE interactivos (-p sin valor) o vía mysql login-path — nunca en argv.
# Invariante clave: local (Docker) y dev COMPARTEN el puerto 3309 — si el puerto está
# ocupado por otra cosa que no sea el túnel correcto, se aborta (nunca conectar a la
# DB equivocada).

set -euo pipefail

ensure_tunnel() { # $1 = ssh host (mango-dev|mango-prod), $2 = puerto local
  local host="$1" port="$2"
  if nc -z 127.0.0.1 "$port" 2>/dev/null; then
    if pgrep -f "ssh.*-N.*$host" >/dev/null 2>&1; then
      echo "✓ túnel $host ya arriba (puerto $port)"
    else
      echo "⚠ puerto $port ocupado pero NO por el túnel $host (¿MySQL local de Docker?). Abortando." >&2
      echo "  (local y dev comparten el 3309: bajá uno antes de levantar el otro)" >&2
      return 1
    fi
  else
    echo "… levantando túnel $host (puerto $port)"
    ssh -f -N "$host"
  fi
}

ask_user() { # $1 = prompt
  local u
  read -r -p "$1" u
  echo "$u"
}

cmd="${1:-status}"

case "$cmd" in
  status)
    for pair in "mango-dev 3309" "mango-prod 3308"; do
      set -- $pair
      host="$1" port="$2"
      if pgrep -f "ssh.*-N.*$host" >/dev/null 2>&1; then
        echo "✓ túnel $host arriba (puerto $port)"
      elif nc -z 127.0.0.1 "$port" 2>/dev/null; then
        echo "⚠ puerto $port ocupado por OTRA cosa (no es el túnel $host) — típico: MySQL local de Docker"
      else
        echo "· túnel $host abajo (puerto $port libre)"
      fi
    done
    ;;
  tunnel)
    env="${2:?uso: mango-db.sh tunnel dev|prod}"
    case "$env" in
      dev)  ensure_tunnel mango-dev 3309 ;;
      prod) ensure_tunnel mango-prod 3308 ;;
      *)    echo "entorno desconocido: $env (dev|prod)" >&2; exit 1 ;;
    esac
    ;;
  dev)
    user="${2:-${MANGO_DB_DEV_USER:-}}"
    [[ -z "$user" ]] && user="$(ask_user "usuario dev (1Password 'Tech - Dev'): ")"
    ensure_tunnel mango-dev 3309
    mysql -h 127.0.0.1 -P 3309 -u "$user" -p
    ;;
  prod)
    user="${2:-${MANGO_DB_PROD_USER:-}}"
    [[ -z "$user" ]] && user="$(ask_user "usuario prod read-only (1Password): ")"
    ensure_tunnel mango-prod 3308
    mysql -h 127.0.0.1 -P 3308 -u "$user" -p mang_mango
    ;;
  down)
    pkill -f "ssh.*-N.*mango-dev" 2>/dev/null && echo "✓ túnel dev cerrado" || true
    pkill -f "ssh.*-N.*mango-prod" 2>/dev/null && echo "✓ túnel prod cerrado" || true
    ;;
  *)
    echo "uso: mango-db.sh status | tunnel dev|prod | dev [user] | prod [user] | down" >&2
    exit 1
    ;;
esac
