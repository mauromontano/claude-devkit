#!/usr/bin/env bash
# Installs the devkit by COPYING dot-claude/* into the Claude config dir.
# Default target is ~/.claude; set CLAUDE_CONFIG_DIR to install into another
# account (e.g. CLAUDE_CONFIG_DIR="$HOME/.claude-mango" ./install.sh).
# Idempotent: safe to run multiple times. Backs up whatever it replaces.
#
# POR QUÉ COPIA Y NO SYMLINK (2026-09-02): ~/Documents es carpeta protegida de
# macOS (TCC). Cuando Claude Code corre bajo una app sin ese permiso (Orca), los
# symlinks hacia ~/Documents/GitHub/claude-devkit dan "Operation not permitted":
# los comandos, hooks y agents personales desaparecen en silencio. Regla: todo lo
# que Claude Code lee en runtime tiene que ser un ARCHIVO REAL bajo ~/.claude.
# El costo es re-correr ./install.sh después de editar el devkit.
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
# stacks): no se instalan globalmente; en los repos de stack llegan por sync.sh.
DEVKIT_SKILL_SKIP=(laravel node-next)

mkdir -p "$DST"

# Copia un archivo suelto. Si el destino era symlink (esquema viejo) lo quita;
# si era un archivo real distinto, lo respalda una vez.
copy_file() {
  local from="$1" to="$2"
  if [ -L "$to" ]; then
    rm -f "$to"
    echo "  unlink: $to (esquema viejo por symlink; ahora es copia)"
  elif [ -e "$to" ] && ! cmp -s "$from" "$to"; then
    cp "$to" "$to.bak-$STAMP"
    echo "  backup: $to -> $to.bak-$STAMP"
  fi
  mkdir -p "$(dirname "$to")"
  cp "$from" "$to"
  echo "  copy:   $to <- $from"
}

# Reemplaza el dir destino COMPLETO con una copia del origen (para dirs 100%
# propiedad del devkit: commands/, hooks/, rules/). Así los archivos borrados en
# el repo también desaparecen del destino (sin copias huérfanas).
copy_tree_owned() {
  local from="$1" to="$2"
  if [ -L "$to" ]; then
    rm -f "$to"
    echo "  unlink: $to (esquema viejo por symlink; ahora es copia)"
  elif [ -d "$to" ]; then
    rm -rf "$to"
  fi
  mkdir -p "$to"
  (cd "$from" && find . -type f ! -path "*/node_modules/*" -print0) | \
    while IFS= read -r -d '' f; do
      mkdir -p "$to/$(dirname "$f")"
      cp "$from/$f" "$to/$f"
    done
  echo "  copy:   $to/ <- $from/ ($(cd "$from" && find . -type f ! -path '*/node_modules/*' | wc -l | tr -d ' ') archivos)"
}

# settings.json: en vez de pisar el archivo vivo (que borraría los hooks machine-local
# que Orca inyecta en runtime — UserPromptSubmit/Stop/SubagentStart/…), MERGEA:
# - hooks: los del devkit + los que referencian a Orca (preservados).
# - permissions.allow/deny: UNIÓN devkit ∪ vivo (lo permitido acumulado en la máquina
#   no se pierde por un re-install).
# - resto de claves: el devkit es canónico para las suyas; las demás quedan del vivo.
# Backup del vivo antes de escribir. Si no hay vivo, copia base.
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
    if k not in ('hooks','permissions'): merged[k]=v   # devkit canónico para sus claves
bp=base.get('permissions',{}); lp=live.get('permissions',{}); perms={}
for key in set(bp)|set(lp):
    b=bp.get(key); l=lp.get(key)
    if isinstance(b,list) or isinstance(l,list):
        seen=list(b or [])
        for x in (l or []):
            if x not in seen: seen.append(x)
        perms[key]=seen
    else:
        perms[key]=b if b is not None else l
if perms: merged['permissions']=perms
bh=base.get('hooks',{}); lh=live.get('hooks',{}); out={}
for ev in (set(bh)|set(lh)):
    groups=list(bh.get(ev,[]))            # hooks del devkit
    for g in lh.get(ev,[]):               # + hooks machine-local de Orca
        if is_orca(g) and g not in groups: groups.append(g)
    if groups: out[ev]=groups
merged['hooks']=out
json.dump(merged, open(sys.argv[2],'w'), indent=2)
PY
  echo "  merge:  $live (devkit + hooks de Orca preservados + permisos unidos)"
}

# Convierte $1 en un dir REAL: si era symlink de dir completo lo quita (capa
# unificada de dos fuentes); si era un archivo suelto ajeno lo respalda una vez.
ensure_real_dir() {
  local p="$1"
  if [ -L "$p" ]; then
    rm -f "$p"; echo "  unlink: $p (ahora dir real: capa unificada personal+equipo)"
  elif [ -e "$p" ] && [ ! -d "$p" ]; then
    mv "$p" "$p.bak-$STAMP"; echo "  backup: $p -> $p.bak-$STAMP"
  fi
  mkdir -p "$p"
}

# Limpia del dir destino los symlinks del esquema viejo que apuntan a este devkit
# (rotos o no): los reemplazan las copias de abajo, y los de archivos ya borrados
# del repo no deben sobrevivir.
prune_devkit_links() {
  local dir="$1" e target
  [ -d "$dir" ] || return 0
  for e in "$dir"/*; do
    [ -L "$e" ] || continue
    target="$(readlink "$e")"
    case "$target" in
      *claude-devkit*) rm -f "$e"; echo "  prune:  $e (symlink del esquema viejo)" ;;
    esac
  done
}

echo "Installing claude-devkit into $DST ..."

# Single files
copy_file      "$SRC/CLAUDE.md"      "$DST/CLAUDE.md"
merge_settings "$SRC/settings.json"  "$DST/settings.json"

# Dirs de fuente única (personal) → copia completa del dir.
for d in hooks rules; do
  [ -d "$SRC/$d" ] && copy_tree_owned "$SRC/$d" "$DST/$d"
done

# commands/ tiene DOS fuentes personales: el devkit (dueño del dir) y los extras de
# mauro-docs/commands (p. ej. /tarea, cuya fuente vive junto a sus datos en mauro-docs).
# Regla de durabilidad: un extra ya instalado NUNCA se pierde en un reinstall, aunque
# mauro-docs no esté legible (TCC) o no esté al día; si commands/ de mauro-docs es
# legible, además se refresca desde ahí.
MAURO_DOCS_DIR="${MAURO_DOCS_DIR:-$HOME/Documents/GitHub/mauro-docs}"
tmp_extras="$(mktemp -d)"
if [ -d "$DST/commands" ]; then
  for f in "$DST"/commands/*.md; do
    { [ -f "$f" ] && [ ! -L "$f" ]; } || continue
    b="$(basename "$f")"
    [ -f "$SRC/commands/$b" ] || cp "$f" "$tmp_extras/$b"
  done
fi
copy_tree_owned "$SRC/commands" "$DST/commands"
for f in "$tmp_extras"/*.md; do
  [ -f "$f" ] || continue
  cp "$f" "$DST/commands/$(basename "$f")"
  echo "  keep:   $DST/commands/$(basename "$f") (extra personal, fuera del devkit)"
done
rm -rf "$tmp_extras"
if ls "$MAURO_DOCS_DIR"/commands/*.md >/dev/null 2>&1; then
  for f in "$MAURO_DOCS_DIR"/commands/*.md; do
    cp "$f" "$DST/commands/$(basename "$f")"
    echo "  overlay: $DST/commands/$(basename "$f") <- mauro-docs/commands"
  done
fi

# El hook de memoria ejecuta link-memory.sh como VECINO en $DST/hooks (nunca un
# path hacia ~/Documents): se copia junto a los hooks.
copy_file "$REPO/bin/link-memory.sh" "$DST/hooks/link-memory.sh"
chmod +x "$DST"/hooks/*.sh 2>/dev/null || true

# agents/ y skills/ = CAPA UNIFICADA en dirs reales. Personal (devkit) copiado acá;
# equipo (mango-agentic) copiado abajo por install-local --global.
ensure_real_dir "$DST/agents"
prune_devkit_links "$DST/agents"
for f in "$SRC"/agents/*.md; do
  [ -f "$f" ] && copy_file "$f" "$DST/agents/$(basename "$f")"
done
echo "  agents personales (devkit) copiados en $DST/agents"

ensure_real_dir "$DST/skills"
prune_devkit_links "$DST/skills"
for s in "$SRC"/skills/*/; do
  [ -d "$s" ] || continue
  n="$(basename "$s")"
  skip=false; for x in "${DEVKIT_SKILL_SKIP[@]}"; do [ "$n" = "$x" ] && skip=true; done
  if $skip; then echo "  skip skill (superseded por mango-agentic): $n"; continue; fi
  copy_tree_owned "$SRC/skills/$n" "$DST/skills/$n"
done
echo "  skills personales (devkit) copiados en $DST/skills"

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

# Repo router: ancestor CLAUDE.md loaded by every session under ~/Documents/GitHub.
# Copia (no symlink); puede fallar bajo una app sin permiso de Documents — se avisa.
if [ -d "$HOME/Documents/GitHub" ] 2>/dev/null; then
  cp "$REPO/workspace/CLAUDE.github.md" "$HOME/Documents/GitHub/CLAUDE.md" 2>/dev/null \
    && echo "  copy:   ~/Documents/GitHub/CLAUDE.md (router)" \
    || echo "  ⚠️  no se pudo escribir ~/Documents/GitHub/CLAUDE.md (permiso de Documents); corrélo desde Terminal"
else
  echo "  ➖ router ~/Documents/GitHub/CLAUDE.md saltado (sin acceso a ~/Documents desde acá)"
fi

# Ops scripts on PATH-less invocation: make bin/ executable.
chmod +x "$REPO"/bin/*.sh 2>/dev/null || true

# archify's optional dependency (ajv) se instala en la COPIA (el runtime lee $DST).
if [ -d "$DST/skills/archify" ] && command -v npm >/dev/null 2>&1; then
  echo "  archify: installing dependencies ..."
  (cd "$DST/skills/archify" && npm install --silent) || true
fi

# Bootstrap marketplace plugins (reinstalled from the official marketplace,
# not vendored — so they keep receiving updates). Edit the list to taste.
# Guarded: no-ops if the claude CLI isn't on PATH or a plugin is already installed.
# frontend-design NO se bootstrappea: lo provee mango-agentic como skill de equipo.
if command -v claude >/dev/null 2>&1; then
  echo "  plugins: bootstrapping from claude-plugins-official ..."
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
  for p in code-review code-simplifier; do
    claude plugin install "$p@claude-plugins-official" >/dev/null 2>&1 || true
  done
fi

# Bootstrap graphify (code knowledge graph) — installed per machine, not vendored.
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
# la misma memoria. Corre la COPIA instalada (no la del repo).
if [ -x "$DST/hooks/link-memory.sh" ]; then
  echo "  memoria: unificando en mauro-docs/claude-memory/shared ..."
  CLAUDE_CONFIG_DIR="$DST" "$DST/hooks/link-memory.sh" >/dev/null 2>&1 || \
    echo "    (saltado: revisar con $DST/hooks/link-memory.sh)"
fi

echo ""
echo "Done. Verify with:  ls -la $DST   (y ./doctor.sh)"
echo "Todo es COPIA: después de editar el devkit, re-corré ./install.sh."
echo "To update on another machine:  cd $REPO && git pull && ./install.sh"
