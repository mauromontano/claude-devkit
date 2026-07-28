#!/usr/bin/env bash
# PostToolUse hook: corre lint/format sobre el archivo recién editado.
# Es INFORMATIVO — nunca bloquea (exit 0 siempre). Devuelve el resultado como
# additionalContext para que el agente vea los problemas al instante.
#
# Claude Code pasa el evento como JSON por stdin. Extraemos el path editado.

set -euo pipefail
input="$(cat)"

# file_path del tool_input (Edit/Write/MultiEdit). Sin jq para no depender de nada.
file="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"

[ -z "${file:-}" ] && exit 0
[ ! -f "$file" ] && exit 0

out=""
case "$file" in
  *.ts|*.tsx|*.js|*.jsx)
    if command -v npx >/dev/null 2>&1 && [ -f package.json ]; then
      out="$(npx --no-install eslint --fix "$file" 2>&1 || true)"
    fi
    ;;
  *.rb)
    if command -v rubocop >/dev/null 2>&1; then
      out="$(rubocop -a "$file" 2>&1 || true)"
    elif command -v bundle >/dev/null 2>&1 && [ -f Gemfile ]; then
      out="$(bundle exec rubocop -a "$file" 2>&1 || true)"
    fi
    ;;
  *.php)
    if [ -x vendor/bin/pint ]; then
      out="$(vendor/bin/pint "$file" 2>&1 || true)"
    elif command -v pint >/dev/null 2>&1; then
      out="$(pint "$file" 2>&1 || true)"
    fi
    ;;
esac

if [ -n "$out" ]; then
  # Emitimos JSON para inyectar el resultado como contexto adicional.
  esc="$(printf '%s' "$out" | tail -30 | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' 2>/dev/null || printf '""')"
  printf '{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":%s}}\n' "$esc"
fi

exit 0
