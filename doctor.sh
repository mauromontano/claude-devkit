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

ENGRAM_PIN="1.15.11"
DEVKIT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GH_DIR="$HOME/Documents/GitHub"
PASS=0; FAIL=0; WARN=0

ok()   { echo "  ✅ $1"; PASS=$((PASS+1)); }
bad()  { echo "  ❌ $1"; FAIL=$((FAIL+1)); }
warn() { echo "  ⚠️  $1"; WARN=$((WARN+1)); }

check_account() { # <label> <dir>
  local label="$1" dir="$2" broken=0 missing=0
  echo "[$label] $dir"
  if [ ! -d "$dir" ]; then bad "config dir missing"; return; fi
  for item in CLAUDE.md settings.json agents commands skills hooks rules; do
    local p="$dir/$item"
    if [ -L "$p" ]; then
      [ -e "$p" ] || { bad "$item: broken symlink"; broken=1; }
    elif [ ! -e "$p" ]; then
      missing=1
    fi
  done
  [ "$broken" -eq 0 ] && [ "$missing" -eq 0 ] && ok "devkit symlinks in place" \
    || { [ "$missing" -eq 1 ] && bad "devkit not fully installed (run install.sh with CLAUDE_CONFIG_DIR=$dir)"; }
  if [ -f "$dir/settings.json" ] && [ "$(tr -d '[:space:]{}' < "$dir/settings.json" | wc -c)" -gt 0 ]; then
    ok "settings.json non-empty"
  else
    bad "settings.json empty or missing"
  fi
  if [ -f "$dir/.claude.json" ]; then
    local servers
    servers="$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(",".join(sorted(d.get("mcpServers",{}).keys())))' "$dir/.claude.json" 2>/dev/null || echo "")"
    if [ -n "$servers" ]; then ok "user-scope MCP: $servers"; else warn "no user-scope MCP registered"; fi
  else
    warn ".claude.json missing (account never used?)"
  fi
}

echo "== Account (una sola: Mango) =="
check_account mango "$HOME/.claude"

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
CANON="$GH_DIR/mango-engineering/mcp/mcp.json"
if [ -f ".vscode/mcp.json" ] && [ -f "$CANON" ]; then
  if diff -q ".vscode/mcp.json" "$CANON" >/dev/null 2>&1; then
    ok ".vscode/mcp.json matches the canonical mcp.json"
  else
    warn ".vscode/mcp.json drifts from mango-engineering canonical"
  fi
else
  echo "  ➖ skipped (no .vscode/mcp.json here or canonical not cloned)"
fi

echo ""
echo "Summary: $PASS ✅  $FAIL ❌  $WARN ⚠️"
[ "$FAIL" -eq 0 ]
