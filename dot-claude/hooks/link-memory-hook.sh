#!/usr/bin/env bash
# SessionStart: garantiza que el memory/ de ESTE cwd apunte a la memoria compartida.
# Necesario porque Orca crea un git worktree nuevo por agente, y un path nuevo =
# un dir de proyecto nuevo = memoria vacía si nadie lo linkea.
# Nunca falla: siempre devuelve {} para no romper el arranque de la sesión.
exec "$HOME/Documents/GitHub/claude-devkit/bin/link-memory.sh" --hook
