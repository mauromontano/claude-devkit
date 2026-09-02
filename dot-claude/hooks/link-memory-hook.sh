#!/usr/bin/env bash
# SessionStart: garantiza que el memory/ de ESTE cwd apunte a la memoria compartida.
# Necesario porque Orca crea un git worktree nuevo por agente, y un path nuevo =
# un dir de proyecto nuevo = memoria vacía si nadie lo linkea.
# Ejecuta link-memory.sh como VECINO (instalado por copia en ~/.claude/hooks) — nunca
# un path hacia ~/Documents, que puede no ser legible (TCC) según la app que corra.
# Nunca falla: siempre devuelve {} para no romper el arranque de la sesión.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "$HERE/link-memory.sh" ]; then
  exec "$HERE/link-memory.sh" --hook
fi
printf '{}\n'
