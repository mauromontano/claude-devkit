#!/usr/bin/env bash
# Health-check for the Claude working environment (read-only).
# Verifies the single Claude account (~/.claude, cuenta de Mango — el esquema
# multicuenta quedó retirado el 2026-08-23), the
# editor wiring, MCP registration, engram pin and config drift.
# Run it after install.sh / on a new machine / whenever something feels off.
set -uo pipefail

# ~/.local/bin no está en el PATH de un shell no-interactivo (vive en ~/.localrc),
# y ahí se instalan engram y las tools de uv. Sin esto el check de engram da un ❌ falso.
export PATH="$HOME/.local/bin:$PATH"

# Pin LOCAL de engram. Puede ir por delante del pin del repo de equipo
# (mango-agentic/mango-engineering) mientras se evalúa si vale la pena bumpearlo allá.
ENGRAM_PIN="1.20.0"
DEVKIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_DIR="$HOME/Documents/GitHub"
PASS=0; FAIL=0; WARN=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
bad()  { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }

check_account() { # <label> <dir>
  local label="$1" dir="$2" linked=0 missing=0
  echo "[$label] $dir"
  if [ ! -d "$dir" ]; then bad "config dir missing"; return; fi
  # Modelo COPIA (2026-09-02): nada de lo que Claude lee en runtime puede ser un
  # symlink hacia ~/Documents (TCC rompe bajo Orca). Un symlink acá = esquema viejo.
  for item in CLAUDE.md settings.json agents commands skills hooks rules; do
    local p="$dir/$item"
    if [ -L "$p" ]; then
      bad "$item: es symlink (esquema viejo — re-corré install.sh)"; linked=1
    elif [ ! -e "$p" ]; then
      missing=1
    fi
  done
  [ "$linked" -eq 0 ] && [ "$missing" -eq 0 ] && ok "devkit instalado por copia (sin symlinks)" \
    || { [ "$missing" -eq 1 ] && bad "devkit not fully installed (run install.sh with CLAUDE_CONFIG_DIR=$dir)"; }
  # Symlinks residuales del esquema viejo dentro de agents/skills
  if find "$dir/agents" "$dir/skills" -maxdepth 1 -type l 2>/dev/null | grep -q .; then
    warn "quedan symlinks del esquema viejo dentro de agents/ o skills/ (re-corré install.sh)"
  fi
  [ -x "$dir/hooks/link-memory.sh" ] && ok "link-memory.sh copiado junto a los hooks" \
    || bad "hooks/link-memory.sh ausente (el hook de memoria no puede correr; re-corré install.sh)"
  if [ -f "$dir/settings.json" ] && [ "$(tr -d '[:space:]{}' < "$dir/settings.json" | wc -c)" -gt 0 ]; then
    ok "settings.json non-empty"
  else
    bad "settings.json empty or missing"
  fi
  # El runtime de Claude Code lee el MCP user-scope de ~/.claude.json (home),
  # NO de $dir/.claude.json. `claude mcp add -s user` (sin CLAUDE_CONFIG_DIR forzado)
  # escribe ahí; mirar el archivo equivocado daba un ✅ falso.
  local runtime_json="$HOME/.claude.json"
  if [ -f "$runtime_json" ]; then
    local servers
    servers="$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(",".join(sorted(d.get("mcpServers",{}).keys())))' "$runtime_json" 2>/dev/null || echo "")"
    if [ -n "$servers" ]; then ok "user-scope MCP: $servers"; else warn "no user-scope MCP registered (corré mango-mcp-setup.sh)"; fi
  else
    warn "~/.claude.json missing (account never used?)"
  fi
}

echo "== Account (una sola: Mango) =="
check_account mango "$HOME/.claude"

echo "== Capa de equipo (mango-agentic) =="
# ~/.claude es la capa unificada: personal (devkit) + equipo (mango-agentic).
# agents/ y skills/ son dirs REALES (no symlinks de dir): personal por symlink
# por-archivo + equipo copiado por install-local --global.
AGENTIC_VER="$(cat "$HOME/.claude/.mango-agentic-version" 2>/dev/null || echo "")"
if [ -n "$AGENTIC_VER" ]; then ok "capa de equipo instalada (mango-agentic v$AGENTIC_VER)"; else bad "capa de equipo NO instalada (corré install.sh; falta ~/.claude/.mango-agentic-version)"; fi
[ -d "$HOME/.claude/agents" ] && [ ! -L "$HOME/.claude/agents" ] && ok "agents/ es dir real (capa unificada)" || bad "agents/ no es dir real (re-corré install.sh)"
[ -f "$HOME/.claude/agents/architect.agent.md" ] && ok "roles canónicos presentes (architect, …)" || bad "roles canónicos ausentes (falta la capa de equipo)"
[ -e "$HOME/.claude/skills/mango-brain/SKILL.md" ] && ok "skill mango-brain presente" || warn "mango-brain ausente (corré setup-brain.sh / install.sh)"

echo "== Editor (VS Code) =="
CODE="$(command -v code || true)"; [ -n "$CODE" ] || CODE="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
if [ -x "$CODE" ]; then
  "$CODE" --list-extensions 2>/dev/null | grep -q "^anthropic.claude-code$" \
    && ok "Claude Code extension installed" || bad "Claude Code extension missing"
else
  bad "code CLI not found"
fi
grep -q "code-mango" "$HOME/.localrc" 2>/dev/null && ok "code-mango alias in ~/.localrc" || bad "code-mango alias missing in ~/.localrc"
VSC_USER="$HOME/Library/Application Support/Code/User"
for f in settings.json keybindings.json; do
  if [ -L "$VSC_USER/$f" ] && [ -e "$VSC_USER/$f" ]; then ok "vscode $f symlinked"; else bad "vscode $f not symlinked (run vscode-config/install.sh)"; fi
done

echo "== engram =="
if command -v engram >/dev/null 2>&1; then
  V="$(engram --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  if [ "$V" = "$ENGRAM_PIN" ]; then ok "engram $V (matches team pin)"; else warn "engram $V != team pin $ENGRAM_PIN"; fi
else
  bad "engram binary not on PATH"
fi

echo "== Secrets hygiene =="
if grep -rq "PASTE_A_ROTATED" "$GH_DIR/zed-config" 2>/dev/null; then
  warn "placeholder token still in zed-config (rotate before deleting the repo)"
else
  ok "no placeholder tokens found"
fi

echo "== Team MCP drift (current repo) =="
CANON="${MANGO_AGENTIC_DIR:-$HOME/orca/mango-agentic}/mcp/mcp.claude.json"
if [ -f ".mcp.json" ] && [ -f "$CANON" ]; then
  if diff -q ".mcp.json" "$CANON" >/dev/null 2>&1; then
    ok ".mcp.json matches mango-agentic canonical (mcp.claude.json)"
  else
    warn ".mcp.json drifts from mango-agentic canonical"
  fi
else
  echo "  ➖ skipped (no .mcp.json here or mango-agentic not cloned)"
fi

echo ""
echo "Summary: $PASS ✅  $FAIL ❌  $WARN ⚠️"
[ "$FAIL" -eq 0 ]
