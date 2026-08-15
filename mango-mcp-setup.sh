#!/usr/bin/env bash
# Wires Mango's team MCP servers into a Claude Code account (user scope).
# Source of truth: mango-engineering/mcp/mcp.json (the team's canonical config).
# Target account: set CLAUDE_CONFIG_DIR (e.g. "$HOME/.claude-mango"); defaults to ~/.claude.
#
# Adds: engram (local stdio), asana + notion (remote; OAuth happens in-session via /mcp).
# Skips by design: sentry + slack (tokens pending in 1Password) and github (token pending).
# Idempotent: re-adding replaces the existing entry.
set -euo pipefail

MANGO_ENG_DIR="${MANGO_ENG_DIR:-$HOME/Documents/GitHub/mango-engineering}"
MCP_JSON="$MANGO_ENG_DIR/mcp/mcp.json"
export CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

[ -f "$MCP_JSON" ] || { echo "error: $MCP_JSON not found (clone mango-engineering or set MANGO_ENG_DIR)"; exit 1; }
command -v claude >/dev/null 2>&1 || { echo "error: claude CLI not on PATH"; exit 1; }

url_of() {
  python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["servers"].get(sys.argv[2], {}).get("url", ""))' "$MCP_JSON" "$1"
}

add() { # add <name> [claude mcp add args...]
  local name="$1"; shift
  claude mcp remove "$name" -s user >/dev/null 2>&1 || true
  claude mcp add "$name" -s user "$@"
  echo "  added: $name"
}

echo "Wiring Mango MCP servers into $CLAUDE_CONFIG_DIR (user scope) ..."

# engram — the team's local memory server (binary pinned by the team; must be on PATH)
if command -v engram >/dev/null 2>&1; then
  add engram -- engram mcp
else
  echo "  skip: engram (binary not on PATH — install the team-pinned release first)"
fi

# notion — remote server, URL taken from the canonical mcp.json.
# asana is NOT added here: the canonical workers.dev SSE endpoint fails Claude Code's
# OAuth protected-resource check, and the Mango org already ships a claude.ai-level
# Asana connector (mcp.asana.com) that covers it — authenticate it in-session via /mcp.
for name in notion; do
  url="$(url_of "$name")"
  if [ -n "$url" ]; then
    case "$url" in
      */sse) transport=sse ;;
      *)     transport=http ;;
    esac
    add "$name" --transport "$transport" "$url"
  else
    echo "  skip: $name (no url in mcp.json)"
  fi
done

echo ""
echo "Skipped by design: sentry, slack (tokens pending in 1Password), github (token pending)."
echo "Verify with:   CLAUDE_CONFIG_DIR=\"$CLAUDE_CONFIG_DIR\" claude mcp list"
echo "Authenticate asana/notion inside a session with /mcp."
