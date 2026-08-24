#!/usr/bin/env bash
# Installs the devkit by symlinking dot-claude/* into the Claude config dir.
# Default target is ~/.claude; set CLAUDE_CONFIG_DIR to install into another
# account (e.g. CLAUDE_CONFIG_DIR="$HOME/.claude-mango" ./install.sh).
# Idempotent: safe to run multiple times. Backs up whatever it replaces.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$REPO/dot-claude"
DST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
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

# settings.json is COPIED, not symlinked. Tools like Orca write machine-local
# hooks into ~/.claude/settings.json at runtime; with a symlink those per-machine
# edits leak back into the versioned repo file. Copying keeps the repo copy clean
# and canonical while the local file absorbs whatever Orca (or the machine) adds.
# Re-run install.sh to push a genuine settings change to the local file (it backs
# up the previous one first).
copy_file() {
  local from="$1" to="$2"
  if [ -L "$to" ]; then
    rm -f "$to"
    echo "  unlink: $to (was a symlink; settings.json is a copy now)"
  elif [ -e "$to" ]; then
    cp "$to" "$to.bak-$STAMP"
    echo "  backup: $to -> $to.bak-$STAMP"
  fi
  cp "$from" "$to"
  echo "  copy:   $to <- $from"
}

echo "Installing claude-devkit into $DST ..."

# Single files
link      "$SRC/CLAUDE.md"      "$DST/CLAUDE.md"
copy_file "$SRC/settings.json"  "$DST/settings.json"

# Whole directories
for d in agents commands skills hooks rules; do
  if [ -d "$SRC/$d" ]; then
    link "$SRC/$d" "$DST/$d"
  fi
done

# Execute permission for the hooks
chmod +x "$SRC"/hooks/*.sh 2>/dev/null || true

# Repo router: ancestor CLAUDE.md loaded by every session under ~/Documents/GitHub.
# Canonical file lives in this repo (workspace/CLAUDE.github.md).
if [ -d "$HOME/Documents/GitHub" ]; then
  link "$REPO/workspace/CLAUDE.github.md" "$HOME/Documents/GitHub/CLAUDE.md"
fi

# Ops scripts on PATH-less invocation: make bin/ executable.
chmod +x "$REPO"/bin/*.sh 2>/dev/null || true

# Install archify's optional dependency (ajv, for schema validation).
# Without npm, archify still renders — it just skips schema validation.
if [ -d "$SRC/skills/archify" ] && command -v npm >/dev/null 2>&1; then
  echo "  archify: installing dependencies ..."
  (cd "$SRC/skills/archify" && npm install --silent) || true
fi

# Bootstrap marketplace plugins (reinstalled from the official marketplace,
# not vendored — so they keep receiving updates). Edit the list to taste.
# Guarded: no-ops if the claude CLI isn't on PATH or a plugin is already installed.
if command -v claude >/dev/null 2>&1; then
  echo "  plugins: bootstrapping from claude-plugins-official ..."
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
  for p in frontend-design code-review code-simplifier; do
    claude plugin install "$p@claude-plugins-official" >/dev/null 2>&1 || true
  done
fi

# Bootstrap graphify (code knowledge graph) — installed per machine, not vendored.
# Optional: no-ops if no Python installer is available. The /graphify skill files
# land in ~/.claude/skills/graphify (gitignored); reinstalls are idempotent.
export PATH="$HOME/.local/bin:$PATH"  # where uv/pipx place the graphify binary
if ! command -v graphify >/dev/null 2>&1; then
  if command -v uv >/dev/null 2>&1; then
    echo "  graphify: installing via uv ..."
    uv tool install graphifyy >/dev/null 2>&1 || true
  elif command -v pipx >/dev/null 2>&1; then
    echo "  graphify: installing via pipx ..."
    pipx install graphifyy >/dev/null 2>&1 || true
  else
    echo "  graphify: skipped (install uv or pipx to enable the /graphify skill)"
  fi
fi
if command -v graphify >/dev/null 2>&1; then
  echo "  graphify: registering the /graphify skill ..."
  graphify install --platform claude >/dev/null 2>&1 || true
fi

# Memoria durable compartida: apunta el memory/ de cada proyecto a un único dir
# versionado en mauro-docs, así todos los repos y los worktrees de Orca comparten
# la misma memoria. Ver bin/link-memory.sh.
if [ -x "$REPO/bin/link-memory.sh" ]; then
  echo "  memoria: unificando en mauro-docs/claude-memory/shared ..."
  CLAUDE_CONFIG_DIR="$DST" "$REPO/bin/link-memory.sh" >/dev/null 2>&1 || \
    echo "    (saltado: revisar con $REPO/bin/link-memory.sh)"
fi

echo ""
echo "Done. Verify with:  ls -la $DST"
echo "Changes made in $REPO apply immediately (they're symlinks) —"
echo "except settings.json, which is a copy: re-run ./install.sh to sync it."
echo "To update on another machine:  cd $REPO && git pull && ./install.sh"
