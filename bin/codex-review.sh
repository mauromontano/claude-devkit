#!/usr/bin/env bash
# Cross-model PR review with Codex (GPT-5.5), using the repo's own house rules as the
# rubric — the second-model leg that complements Claude's /review-deep.
#
# Usage:
#   codex-review.sh                 # review the current branch vs its base (auto-detected)
#   codex-review.sh <base-branch>   # review vs an explicit base (e.g. main, feat/x)
#   codex-review.sh --uncommitted   # review staged+unstaged+untracked changes
#
# Requires: codex CLI logged in (codex login → Sign in with ChatGPT).
# Reads .claude/rules/shared-*.md and eng-*.md from the current repo as the rubric.
set -euo pipefail

command -v codex >/dev/null 2>&1 || { echo "error: codex CLI not found (brew install --cask codex)"; exit 1; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "error: run this inside a git repo"; exit 1; }

# Build the rubric from the repo's house rules (if present).
RULES=""
if [ -d ".claude/rules" ]; then
  RULES="$(cat .claude/rules/shared-*.md .claude/rules/eng-*.md 2>/dev/null || true)"
fi

read -r -d '' INSTRUCTIONS <<'EOF' || true
Sos un revisor senior. Revisá los cambios contra las reglas de la casa que siguen.
Reportá hallazgos por severidad (🟠 bloquea / 🟡 media / 🔵 baja / proceso), cada uno con
archivo:línea, el impacto concreto y el fix propuesto. Sumá una sección "Lo que está bien".
No edites archivos: es un review de solo lectura. Nada de datos de clientes en la salida.
EOF

PROMPT="$INSTRUCTIONS"
[ -n "$RULES" ] && PROMPT="$PROMPT

=== Reglas de la casa (rubric) ===
$RULES"

# Decide what to review.
case "${1:-}" in
  --uncommitted) set -- ; SCOPE=(--uncommitted) ;;
  "") # auto-detect base: upstream, or main/master fallback
      BASE="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null | sed 's#^[^/]*/##' || true)"
      [ -n "$BASE" ] || BASE="$(git show-ref --verify --quiet refs/heads/main && echo main || echo master)"
      SCOPE=(--base "$BASE") ;;
  *) SCOPE=(--base "$1") ;;
esac

echo "→ codex review ${SCOPE[*]}  (rubric: $( [ -n "$RULES" ] && echo 'house rules' || echo 'default' ))"
printf '%s' "$PROMPT" | codex review "${SCOPE[@]}" -
