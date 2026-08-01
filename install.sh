#!/usr/bin/env bash
# Installs the devkit by symlinking dot-claude/* into ~/.claude.
# Idempotent: safe to run multiple times. Backs up whatever it replaces.
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

echo "Installing claude-devkit into $DST ..."

# Single files
link "$SRC/CLAUDE.md"      "$DST/CLAUDE.md"
link "$SRC/settings.json"  "$DST/settings.json"

# Whole directories
for d in agents commands skills hooks; do
  if [ -d "$SRC/$d" ]; then
    link "$SRC/$d" "$DST/$d"
  fi
done

# Execute permission for the hooks
chmod +x "$SRC"/hooks/*.sh 2>/dev/null || true

echo ""
echo "Done. Verify with:  ls -la $DST"
echo "Changes made in $REPO apply immediately (they're symlinks)."
echo "To update on another machine:  cd $REPO && git pull"
