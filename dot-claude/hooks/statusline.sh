#!/usr/bin/env bash
# StatusLine: una línea con rama de git, estado sucio/limpio y modelo.
# Claude Code pasa contexto de sesión como JSON por stdin.
set -euo pipefail
input="$(cat 2>/dev/null || true)"

model="$(printf '%s' "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -z "${model:-}" ] && model="claude"

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '-')"
dirty=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  [ -n "$(git status --porcelain 2>/dev/null)" ] && dirty="✱"
fi

dir="$(basename "$(pwd)")"
printf '%s ⎇ %s%s · %s' "$dir" "$branch" "$dirty" "$model"
