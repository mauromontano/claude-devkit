# claude-devkit

This repo IS the devkit: everything under `dot-claude/` gets symlinked into `~/.claude`
by `./install.sh` (idempotent). Edit files here and the changes apply to every session
immediately; on another machine just `git pull`.

- `dot-claude/CLAUDE.md` — the engineering constitution (global, loaded in every session).
- `dot-claude/commands|agents|skills|hooks` — the workflow building blocks.
- `docs/` — documentation about this repo itself; not installed.

When editing the devkit: write everything in English, keep always-loaded content minimal
(details belong in skills under `references/`), and never duplicate content across the
constitution, skills, and commands.
