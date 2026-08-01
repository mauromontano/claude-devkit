#!/usr/bin/env bash
# PreToolUse hook: blocks edits to sensitive files.
# Exit 2 => blocks the action and returns the reason to the agent via stderr.
# Adjust the PROTECTED list per project.

set -euo pipefail
input="$(cat)"
file="$(printf '%s' "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -z "${file:-}" ] && exit 0

PROTECTED=(".env" ".env.production" "db/structure.sql" "db/schema.rb" "*.pem" "*.key")

base="$(basename "$file")"
for pat in "${PROTECTED[@]}"; do
  case "$base" in
    $pat)
      echo "Blocked: '$file' is a protected file. Edit it by hand if intentional, or adjust dot-claude/hooks/protect-paths.sh." >&2
      exit 2
      ;;
  esac
done

exit 0
