#!/usr/bin/env bash
# Instala el devkit symlinkeando dot-claude/* dentro de ~/.claude.
# Idempotente: se puede correr varias veces. Hace backup de lo que reemplaza.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/dot-claude"
DST="$HOME/.claude"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$DST"

link() {
  local from="$1" to="$2"
  if [ -e "$to" ] && [ ! -L "$to" ]; then
    mv "$to" "$to.bak-$STAMP"
    echo "  backup: $to -> $to.bak-$STAMP"
  fi
  ln -sfn "$from" "$to"
  echo "  link:   $to -> $from"
}

echo "Instalando claude-devkit en $DST ..."

# Archivos sueltos
link "$SRC/CLAUDE.md"      "$DST/CLAUDE.md"
link "$SRC/settings.json"  "$DST/settings.json"

# Carpetas completas
for d in agents commands skills hooks output-styles; do
  [ -d "$SRC/$d" ] && link "$SRC/$d" "$DST/$d"
done

# Permisos de ejecución para los hooks
chmod +x "$SRC"/hooks/*.sh 2>/dev/null || true

echo ""
echo "Listo. Verificá con:  ls -la $DST"
echo "Los cambios que hagas en $REPO se reflejan solos (son symlinks)."
echo "Para actualizar en otra máquina:  cd $REPO && git pull"
