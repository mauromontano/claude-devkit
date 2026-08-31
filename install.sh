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

# Capa de equipo (canónica): mango-agentic. install.sh orquesta las DOS fuentes en
# un solo ~/.claude — personal (este devkit) + equipo (mango-agentic). Lo personal
# NUNCA se propaga a la flota; acá solo consumimos la capa de equipo.
MANGO_AGENTIC_DIR="${MANGO_AGENTIC_DIR:-$HOME/orca/mango-agentic}"
# Skills del devkit superseded por la capa de equipo (mango-agentic es canónico para
# stacks): no se enlazan globalmente; en los repos de stack llegan por sync.sh.
DEVKIT_SKILL_SKIP=(laravel node-next)

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

# settings.json: en vez de pisar el archivo vivo (que borraría los hooks machine-local
# que Orca inyecta en runtime — UserPromptSubmit/Stop/SubagentStart/…), MERGEA:
# el devkit es canónico para sus claves y sus hooks, y se preservan los hooks que
# referencian a Orca. Backup del vivo antes de escribir. Si no hay vivo, copia base.
merge_settings() {
  local base="$1" live="$2"
  if [ -L "$live" ]; then rm -f "$live"; echo "  unlink: $live (settings.json es copia mergeada, no symlink)"; fi
  if [ ! -e "$live" ]; then cp "$base" "$live"; echo "  copy:   $live <- $base (no había vivo)"; return; fi
  cp "$live" "$live.bak-$STAMP"; echo "  backup: $live -> $live.bak-$STAMP"
  python3 - "$base" "$live" <<'PY'
import json, sys
base=json.load(open(sys.argv[1])); live=json.load(open(sys.argv[2]))
def is_orca(x): return 'orca' in json.dumps(x).lower()
merged=dict(live)
for k,v in base.items():
    if k!='hooks': merged[k]=v            # devkit canónico para sus claves
bh=base.get('hooks',{}); lh=live.get('hooks',{}); out={}
for ev in (set(bh)|set(lh)):
    groups=list(bh.get(ev,[]))            # hooks del devkit
    for g in lh.get(ev,[]):               # + hooks machine-local de Orca
        if is_orca(g) and g not in groups: groups.append(g)
    if groups: out[ev]=groups
merged['hooks']=out
json.dump(merged, open(sys.argv[2],'w'), indent=2)
PY
  echo "  merge:  $live (devkit + hooks machine-local de Orca preservados)"
}

# Convierte $1 en un dir REAL: si era symlink de dir completo lo quita (pasamos a
# capa unificada de dos fuentes); si era un dir real ajeno lo respalda una vez.
ensure_real_dir() {
  local p="$1"
  if [ -L "$p" ]; then
    rm -f "$p"; echo "  unlink: $p (ahora dir real: capa unificada personal+equipo)"
  elif [ -e "$p" ] && [ ! -d "$p" ]; then
    mv "$p" "$p.bak-$STAMP"; echo "  backup: $p -> $p.bak-$STAMP"
  fi
  mkdir -p "$p"
}

echo "Installing claude-devkit into $DST ..."

# Single files
link          "$SRC/CLAUDE.md"      "$DST/CLAUDE.md"
merge_settings "$SRC/settings.json" "$DST/settings.json"

# Dirs de fuente única (personal) → symlink de dir completo.
for d in commands hooks rules; do
  [ -d "$SRC/$d" ] && link "$SRC/$d" "$DST/$d"
done

# agents/ y skills/ = CAPA UNIFICADA. Personal (devkit) por symlink por-archivo
# (editable en vivo); equipo (mango-agentic) copiado abajo por install-local --global.
ensure_real_dir "$DST/agents"
for f in "$SRC"/agents/*.md; do
  [ -f "$f" ] && ln -sfn "$f" "$DST/agents/$(basename "$f")"
done
echo "  agents personales (devkit) enlazados en $DST/agents"

ensure_real_dir "$DST/skills"
for s in "$SRC"/skills/*; do
  # incluye dirs y symlinks (incluidos los que Orca puebla en runtime, hoy sin target)
  [ -d "$s" ] || [ -L "$s" ] || continue
  n="$(basename "$s")"
  skip=false; for x in "${DEVKIT_SKILL_SKIP[@]}"; do [ "$n" = "$x" ] && skip=true; done
  if $skip; then echo "  skip skill (superseded por mango-agentic): $n"; continue; fi
  ln -sfn "$s" "$DST/skills/$n"
done
echo "  skills personales (devkit) enlazados en $DST/skills"

# Capa de equipo canónica: agents por rol + skills de equipo (shared, mango-brain,
# planning) copiados por el instalador de mango-agentic. No hay choque de nombres
# con lo personal (agents de equipo usan *.agent.md; skills tienen nombres distintos).
if [ -x "$MANGO_AGENTIC_DIR/scripts/install-local.sh" ]; then
  echo "  mango-agentic: instalando capa de equipo (--global) ..."
  "$MANGO_AGENTIC_DIR/scripts/install-local.sh" --global || \
    echo "    (falló install-local de mango-agentic; revisar $MANGO_AGENTIC_DIR)"
else
  echo "  ⚠️  mango-agentic no encontrado en $MANGO_AGENTIC_DIR (seteá MANGO_AGENTIC_DIR); capa de equipo NO instalada"
fi

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
