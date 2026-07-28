# claude-devkit

Mi setup de desarrollo AI-first sobre **Claude Code**, portable y agnóstico del stack.
Clono este repo en cualquier máquina, corro `./install.sh`, y tengo todo mi flujo de
trabajo listo: principios de ingeniería, subagents de review, comandos, hooks de
TDD/lint, y un proceso de feature punta a punta por etapas con documentación y
diagramas generados sobre la marcha.

> Pensado para trabajar en Node/Express, Next.js/React/TS y Ruby on Rails, pero el
> proceso no depende del stack: define *cómo* trabajo, no *con qué*.

---

## Por qué existe

Trabajar bien con un agente no es "pedirle que escriba código". Es tener un **proceso
repetible** en el que el agente:

1. **Entiende antes de actuar** — brainstorm y preguntas antes de tocar una línea.
2. **Planifica por capas y etapas** — nada de big-bang; incrementos revisables.
3. **Documenta y diagrama mientras avanza** — el diseño queda escrito, no en la cabeza.
4. **Implementa con TDD** — test primero, rojo → verde → refactor.
5. **Se revisa a sí mismo** — cada etapa pasa por un subagent de review antes de seguir.

Este repo empaqueta todo eso como configuración versionable.

---

## Estructura

```
claude-devkit/
├── README.md                  # este archivo — el blueprint maestro
├── install.sh                 # symlinkea todo a ~/.claude en una máquina nueva
├── CLAUDE.md                  # constitución de ingeniería (principios globales)
├── .gitignore
├── docs/
│   ├── WORKFLOW.md            # el proceso de feature punta a punta, por etapas
│   ├── ECOSYSTEM.md           # skills / plugins / MCPs recomendados y por qué
│   └── workflow-diagram.html  # diagrama del flujo (archify) — abrir en el navegador
└── dot-claude/                # se symlinkea a ~/.claude al correr install.sh
    ├── settings.json          # hooks (lint/test post-edit), statusline
    ├── agents/                # subagents: planner, reviewer, test-writer, security, docs
    ├── commands/              # /feature, /stage, /review, /diagram, /document
    ├── hooks/                 # scripts de los hooks (post-edit, protect-paths, statusline)
    └── skills/                # skills propias (workflow) además de las que ya tengo
```

> Se guarda como `dot-claude/` (no `.claude/`) porque es un repo de dotfiles: `install.sh`
> lo symlinkea a `~/.claude/`. Editás en el repo, `git push`, y en otra máquina `git pull`.

---

## Cómo se usa (el ciclo de una feature)

El proceso completo está en [`docs/WORKFLOW.md`](docs/WORKFLOW.md). En una línea por fase:

| Fase | Qué pasa | Cómo lo disparo |
|------|----------|-----------------|
| **0. Brainstorm** | Claude hace preguntas, aclara alcance, detecta riesgos. Escala según complejidad. | `/feature <descripción>` |
| **1. Plan** | Plan mode: diseño por capas + etapas incrementales, cada una con criterio de "hecho". | plan mode (shift+tab) |
| **2. Docs + diagrama** | Se genera `docs/<feature>.md` (decisiones, contrato de API) y un diagrama con archify. | `/document`, `/diagram` |
| **3. Implementación** | Etapa por etapa, TDD: test rojo → código → verde → refactor. | `/stage <n>` |
| **4. Review por etapa** | El subagent `code-reviewer` (y `security-reviewer` si aplica) audita antes de avanzar. | `/review` |
| **5. Cierre** | Se actualiza la doc, se corre el suite completo, se arma el commit/PR. | `/review`, commit |

La regla de oro: **no se pasa de etapa sin que la anterior esté en verde y revisada.**

---

## Instalación en una máquina nueva

```bash
git clone git@github.com:<tu-usuario>/claude-devkit.git ~/claude-devkit
cd ~/claude-devkit
./install.sh
```

`install.sh` symlinkea `CLAUDE.md`, `agents/`, `commands/`, `skills/` y `settings.json`
a `~/.claude/`, de modo que **cualquier proyecto** en esa máquina hereda el setup.
Editás una vez en el repo, `git push`, y en la otra compu `git pull` — sin copiar a mano.

Para configuración específica de un proyecto, se copia lo que haga falta a
`.claude/` dentro de ese repo (ver "Global vs proyecto" abajo).

---

## Global vs proyecto

Claude Code carga configuración en cascada. Este devkit vive a nivel **usuario**
(`~/.claude/`) para que todo esté disponible en todos los proyectos. Cuando un repo
necesita reglas propias (convenciones de ese código, comandos de test específicos),
esas van en el `.claude/` del proyecto y **ganan** sobre las globales.

- `~/.claude/` → mi setup base (este repo). Aplica siempre.
- `<proyecto>/.claude/` → overrides y contexto de ese repo. Se commitea con el proyecto.
- `settings.local.json` → cosas personales/secretos. **Nunca** se commitea.

---

## Los cuatro building blocks de Claude Code (y cómo los uso)

| Bloque | Qué es | Para qué lo uso acá |
|--------|--------|---------------------|
| **CLAUDE.md** | Memoria/instrucciones persistentes | Principios de ingeniería que aplican siempre |
| **Subagents** | Agentes con contexto e instrucciones aislados | Review, tests y planning especializados y sin ensuciar el contexto principal |
| **Commands** | Prompts reutilizables invocables con `/` | Disparar cada fase del proceso de forma consistente |
| **Hooks** | Scripts que corren en eventos del agente | Correr lint/tests automáticamente, proteger archivos, reforzar TDD |
| **Skills** | Capacidades cargadas progresivamente | Conocimiento de dominio/framework bajo demanda (archify, docs, etc.) |

Detalle de cada uno en los archivos correspondientes dentro de `.claude/`.

---

## Filosofía en una frase

> Diseño la feature en **capas con responsabilidades claras** y un **contrato en el
> medio**; planifico por **etapas incrementales**; implemento con **TDD**; y cada
> etapa se **documenta, diagrama y revisa** antes de avanzar — sin importar el stack.
