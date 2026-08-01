# claude-devkit

Este repo ES el devkit: todo lo que vive en `dot-claude/` se symlinkea a `~/.claude`
vía `./install.sh` (idempotente). Editá los archivos acá y los cambios se reflejan
solos en todas las sesiones; en otra máquina alcanza con `git pull`.

- `dot-claude/CLAUDE.md` — la constitución de ingeniería (global, se carga en toda sesión).
- `dot-claude/commands|agents|skills|hooks` — building blocks del workflow.
- `docs/` — documentación *de este repo*, no se instala.

Al editar el devkit: mantené el español rioplatense, cuidá el gasto de tokens (todo lo
que se carga siempre debe ser mínimo; el detalle va en skills con `references/`), y no
dupliques contenido entre constitución, skills y comandos.
