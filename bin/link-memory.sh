#!/usr/bin/env bash
# Unifica la memoria durable de Claude en UN solo directorio versionado.
#
# Por qué: Claude Code guarda la memoria en ~/.claude/projects/<slug-del-cwd>/memory/,
# o sea una memoria distinta por directorio. Con Orca creando un git worktree por
# agente, cada worktree arrancaría con memoria vacía. Este script apunta el dir de
# memoria de cada proyecto (por symlink) a mauro-docs/claude-memory/shared/, así todos
# los repos y worktrees leen y escriben la MISMA memoria, y queda versionada en git.
#
# Uso:
#   link-memory.sh              # linkea todos los proyectos existentes
#   link-memory.sh <path>       # linkea el proyecto de ese cwd (lo crea si falta)
#   link-memory.sh --hook       # modo SessionStart: lee el cwd del JSON de stdin
#
# Idempotente. Migra al dir compartido lo que encuentre en un memory/ real antes de
# reemplazarlo; si un archivo ya existe allá con contenido distinto, lo guarda como
# *.dup-<stamp>.md en vez de sobrescribirlo.
set -euo pipefail

SHARED="${CLAUDE_SHARED_MEMORY:-$HOME/Documents/GitHub/mauro-docs/claude-memory/shared}"
CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
PROJECTS="$CFG/projects"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$SHARED"

# Claude Code deriva el nombre del dir de proyecto del cwd cambiando "/" por "-".
slug() { printf '%s' "$1" | sed 's#/#-#g'; }

link_one() {
  local pdir="$1" mem="$1/memory" f base
  mkdir -p "$pdir"

  if [ -L "$mem" ]; then
    if [ "$(readlink "$mem")" = "$SHARED" ]; then
      echo "  ya ok:   $mem"
      return 0
    fi
    rm -f "$mem"
  elif [ -d "$mem" ]; then
    for f in "$mem"/*; do
      [ -e "$f" ] || continue
      base="$(basename "$f")"
      if [ -e "$SHARED/$base" ]; then
        if cmp -s "$f" "$SHARED/$base"; then
          rm -f "$f"
        else
          mv "$f" "$SHARED/${base%.md}.dup-$STAMP.md"
          echo "  conflicto: $base guardado como ${base%.md}.dup-$STAMP.md"
        fi
      else
        mv "$f" "$SHARED/$base"
        echo "  migrado: $base -> shared/"
      fi
    done
    rmdir "$mem" 2>/dev/null || { mv "$mem" "$mem.bak-$STAMP"; echo "  backup:  $mem.bak-$STAMP"; }
  fi

  ln -sfn "$SHARED" "$mem"
  echo "  link:    $mem -> $SHARED"
}

case "${1-}" in
  --hook)
    # SessionStart: el cwd viene en el JSON de stdin. Nunca romper la sesión.
    cwd="$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null || true)"
    [ -n "$cwd" ] && link_one "$PROJECTS/$(slug "$cwd")" >/dev/null 2>&1 || true
    printf '{}\n'
    ;;
  "")
    echo "Unificando memoria en $SHARED"
    if [ -d "$PROJECTS" ]; then
      for pdir in "$PROJECTS"/*; do
        [ -d "$pdir" ] || continue
        link_one "$pdir"
      done
    else
      echo "  (todavía no hay proyectos en $PROJECTS)"
    fi
    echo ""
    echo "Archivos en la memoria compartida:"
    ls -1 "$SHARED" | sed 's/^/  /'
    ;;
  *)
    link_one "$PROJECTS/$(slug "$1")"
    ;;
esac
