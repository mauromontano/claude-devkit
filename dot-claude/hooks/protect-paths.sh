#!/usr/bin/env bash
# PreToolUse hook: bloquea ediciones a archivos sensibles.
# Exit 2 => bloquea la acción y devuelve el motivo al agente por stderr.
# Ajustá la lista PROTECTED según el proyecto.

set -euo pipefail
input="$(cat)"
file="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -z "${file:-}" ] && exit 0

PROTECTED=(".env" ".env.production" "db/structure.sql" "db/schema.rb" "*.pem" "*.key")

base="$(basename "$file")"
for pat in "${PROTECTED[@]}"; do
  case "$base" in
    $pat)
      echo "Bloqueado: '$file' es un archivo protegido. Editalo a mano si es intencional, o ajustá dot-claude/hooks/protect-paths.sh." >&2
      exit 2
      ;;
  esac
done

exit 0
