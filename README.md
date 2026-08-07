# claude-devkit

My AI-first development setup on **Claude Code** — portable and stack-agnostic. Clone
this repo on any machine, run `./install.sh`, and my whole workflow is ready:
engineering principles, review subagents, commands, TDD/lint hooks, and an end-to-end,
staged feature process with documentation and diagrams generated along the way.

> Built for working in Node/Express, Next.js/React/TS, and Laravel, but
> the process doesn't depend on the stack: it defines *how* I work, not *with what*.

---

## Why it exists

Working well with an agent isn't "asking it to write code". It's having a **repeatable
process** where the agent:

1. **Understands before acting** — brainstorm and questions before touching a line.
2. **Plans by layers and stages** — no big-bang; reviewable increments.
3. **Documents and diagrams as it goes** — the design is written down, not in someone's
   head.
4. **Implements with TDD** — test first, red → green → refactor.
5. **Reviews itself** — every stage goes through a review subagent before moving on.

This repo packages all of that as versionable configuration.

---

## Structure

```
claude-devkit/
├── README.md                  # this file — the master blueprint
├── install.sh                 # symlinks everything into ~/.claude on a new machine
├── CLAUDE.md                  # about this repo itself (the constitution lives in dot-claude/)
├── .gitignore
├── docs/
│   ├── ECOSYSTEM.md           # recommended skills / plugins / MCPs and why
│   └── workflow.workflow.json # flow diagram source (regenerate HTML with /diagram)
└── dot-claude/                # symlinked to ~/.claude by install.sh
    ├── CLAUDE.md              # engineering constitution (global, loaded every session)
    ├── settings.json          # hooks (post-edit lint), statusline, model
    ├── agents/                # subagents: planner, code/security reviewers, spec verifier, test/docs writers
    ├── commands/              # /feature /task /onboard /spec /document /tasks /diagram /stage /review /refactor /bug /commit /pr
    ├── hooks/                 # hook scripts (post-edit, protect-paths, statusline)
    ├── rules/                 # global rules (context7: latest docs via the ctx7 CLI)
    └── skills/                # feature-workflow (+ references/), laravel, node-next, archify
```

> It's stored as `dot-claude/` (not `.claude/`) because this is a dotfiles repo:
> `install.sh` symlinks it to `~/.claude/`. Edit in the repo, `git push`, and on the
> other machine `git pull`.

---

## How it's used (the feature cycle)

Day-to-day usage and the full command reference are in
[`docs/USAGE.md`](docs/USAGE.md); the full phase detail lives in
[`dot-claude/skills/feature-workflow/references/phases.md`](dot-claude/skills/feature-workflow/references/phases.md).
One line per phase:

| Phase | What happens | How I trigger it |
|-------|--------------|------------------|
| **0. Brainstorm** | Claude asks questions, clarifies scope, spots risks. Scales with complexity. | `/feature <description>` |
| **1. Plan** | Plan mode: layered design + incremental stages, each with a "done" criterion. | plan mode (shift+tab) |
| **2. Spec + docs + diagram** | `docs/<feature>-spec.md`, `docs/<feature>.md`, task checklist, archify diagram. | `/spec`, `/document`, `/tasks`, `/diagram` |
| **3. Implementation** | Stage by stage, TDD: red test → code → green → refactor. | `/stage <n>` |
| **4. Per-stage review** | `code-reviewer` (plus `security-reviewer` and `spec-verifier` as needed) audit before advancing. | `/review` |
| **5. Close** | Docs updated, full suite run, conventional commit/PR, spec archived. | `/commit`, `/pr` |

Other entry points: `/task` (sizes a change and scales the depth, routing to
feature/bug/refactor), `/onboard` (inspects an unfamiliar repo → HTML overview +
architecture diagram), `/bug` (reproduce → red test → root cause → minimal fix) and
`/refactor` (behavior-preserving, tiny steps over a test net).

The golden rule: **never advance past a stage that isn't green and reviewed.**

---

## Installing on a new machine

```bash
git clone git@github.com:<your-user>/claude-devkit.git ~/claude-devkit
cd ~/claude-devkit
./install.sh
```

`install.sh` symlinks `CLAUDE.md`, `agents/`, `commands/`, `skills/`, `hooks/`,
`rules/`, and `settings.json` into `~/.claude/`, so **every project** on that machine
inherits the setup. It also runs `npm install` for the bundled **archify** skill (its
only dependency, `ajv`, is optional) and **bootstraps marketplace plugins** from the
official marketplace (see below). Edit once in the repo, `git push`, and on the other
machine `git pull` — no manual copying.

For project-specific configuration, copy what's needed into that repo's `.claude/`
(see "Global vs project" below).

### Bundled vs bootstrapped

- **Bundled** (vendored in the repo, travel via symlink): the workflow skills, the
  `archify` diagram skill, and the `context7` docs rule.
- **Bootstrapped** (reinstalled from the marketplace, not vendored — so they keep
  getting updates): the official plugins `frontend-design`, `code-review`,
  `code-simplifier`. Edit the list near the end of `install.sh` to taste.

> **Note on superpowers:** it's a full development methodology (TDD, plan-first,
> subagent-driven dev, code review) that overlaps this devkit's own workflow, so it's
> **disabled by default** to keep a single methodology. Re-enable it with
> `claude plugin enable superpowers` if you want its complementary subskills
> (`systematic-debugging`, `using-git-worktrees`, `verification-before-completion`).

---

## Global vs project

Claude Code loads configuration in cascade. This devkit lives at the **user** level
(`~/.claude/`) so everything is available in every project. When a repo needs its own
rules (that codebase's conventions, specific test commands), those go in the project's
`.claude/` and **win** over the globals.

- `~/.claude/` → my base setup (this repo). Always applies.
- `<project>/.claude/` → overrides and context for that repo. Committed with the project.
- `settings.local.json` → personal/secret stuff. **Never** committed.

---

## The five Claude Code building blocks (and how I use them)

| Block | What it is | What I use it for here |
|-------|------------|------------------------|
| **CLAUDE.md** | Persistent memory/instructions | Engineering principles that always apply |
| **Subagents** | Agents with isolated context and instructions | Specialized review, characterization tests, and planning without polluting the main context |
| **Commands** | Reusable prompts invoked with `/` | Triggering each phase of the process consistently |
| **Hooks** | Scripts running on agent events | Auto lint/format, protecting files, reinforcing TDD |
| **Skills** | Progressively loaded capabilities | Workflow + per-stack knowledge + diagrams on demand (feature-workflow, laravel, node-next, archify) |

---

## Philosophy in one sentence

> I design the feature in **layers with clear responsibilities** and a **contract in
> the middle**; I plan in **incremental stages**; I implement with **TDD**; and every
> stage is **documented, diagrammed, and reviewed** before moving on — whatever the
> stack.
