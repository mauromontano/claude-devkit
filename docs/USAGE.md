# Usage guide

How to drive the devkit day to day. For the philosophy and the full phase detail, see
the constitution (`dot-claude/CLAUDE.md`) and the `feature-workflow` skill
(`dot-claude/skills/feature-workflow/references/phases.md`).

## The feature loop

Building a non-trivial feature follows one loop. The golden rule holds throughout:
**never advance past a stage that isn't green and reviewed.**

1. **`/feature <description>`** — brainstorm and framing. Claude restates the scope, asks
   only the questions that change the design, and sketches 2-3 approaches when the
   decision isn't obvious. No code yet.
2. **plan mode** (shift+tab) — a layered plan with the **API contract first**, split into
   small, committable stages. The `architecture-planner` agent designs the trade-offs.
3. **`/spec` · `/document` · `/tasks` · `/diagram`** — write the spec (Given/When/Then
   scenarios), the design doc, the stage checklist, and a diagram. Commit before coding.
4. **`/stage <n>`** — implement one stage with TDD: red → green → refactor → verify.
5. **`/review`** — `code-reviewer` (always), plus `security-reviewer` and `spec-verifier`
   as needed. Resolve blockers, then the **human gate**: Claude stops and waits for your
   OK before the next stage.
6. **`/commit` · `/pr`** — close out with a conventional commit and a PR built from the
   feature docs.

State lives on disk (`docs/<feature>-spec.md`, `docs/<feature>.md`,
`docs/<feature>-tasks.md`), so you can `/clear` or switch machines and resume.

## Which command when

- **New feature or capability** → `/feature` (full loop above).
- **A change, update, or maintenance task** (config tweak, dependency bump, small
  behavior update) → `/task`: the middle path. It sizes the item and scales the depth,
  routing to `/feature`, `/bug`, or `/refactor` if it turns out to be one of those.
- **Something is broken** → `/bug`: reproduce → red test that captures it → root cause →
  minimal fix → green suite. No design phase.
- **Improve existing code without changing behavior** → `/refactor`: understand → test
  net → tiny steps → verify. The "two hats" — never mix a refactor with a feature.
- **Landing on an unfamiliar project** → `/onboard`: inspects the repo and writes an HTML
  overview + architecture diagram so you can get up to speed fast. On a large repo it
  indexes with **graphify** first; you can then keep querying the graph during the work
  (`graphify query "what connects X to Y"`, `graphify path A B`, `graphify explain Node`)
  instead of grepping.
- **Wrap up** → `/commit` (conventional message) and `/pr` (PR from the docs).

## Command reference

| Command | What it does | When |
|---------|--------------|------|
| `/feature <desc>` | Starts the end-to-end feature loop at brainstorm | New, non-trivial work |
| `/task <desc>` | Sizes a change and scales the depth; routes to feature/bug/refactor | Updates, changes, maintenance |
| `/onboard [path]` | Inspects a project → HTML overview + architecture diagram | Landing on an unfamiliar repo |
| `/spec [name]` | Writes requirements + Given/When/Then acceptance scenarios | Phase 2, before coding |
| `/document [name]` | Writes/updates the design doc (decisions, contract, data model) | Phase 2 and on close |
| `/tasks [name]` | Writes/updates the stage checklist (durable state) | Phase 2, ticked per stage |
| `/diagram [what]` | Generates an archify diagram (architecture/sequence/flow) | When structure needs a picture |
| `/stage <n>` | Implements one stage with strict TDD | Phase 3, one at a time |
| `/review [ctx]` | Runs the review agents + human gate | Closing each stage |
| `/refactor <what>` | Behavior-preserving refactor in tiny steps over a test net | Cleaning existing code |
| `/bug <desc>` | Reproduce → red test → root cause → minimal fix | Fixing a defect |
| `/commit [ctx]` | Commits with the conventional format, splitting mixed changes | Any commit |
| `/pr [ctx]` | Opens a PR with title + body from the feature docs | Shipping a branch |

## Agents (subagents)

Run in isolated context so the main window stays light. Delegated automatically by the
commands, or on request.

| Agent | Role |
|-------|------|
| `architecture-planner` | Designs the layered plan and trade-offs (plan phase) |
| `code-reviewer` | Audits each stage's diff for quality, coverage, design |
| `security-reviewer` | Audits stages touching auth/payments/sensitive data/external input |
| `spec-verifier` | Checks the implementation against the spec scenarios, one by one |
| `docs-writer` | Generates and maintains the feature's docs |
| `test-writer` | Writes characterization tests for `/refactor`'s safety net |

## Hooks, rules, skills

- **Hooks:** `post-edit` (lint/format after every edit), `protect-paths` (blocks editing
  `.env`, keys, schema), `statusline` (branch · dirty · model).
- **Rules:** `context7` — fetch current library docs via the `ctx7` CLI instead of
  relying on training data.
- **Skills:** `feature-workflow` (the process), `laravel` and `node-next` (per-stack
  conventions), `archify` (diagrams). They load on demand when relevant.

## Git conventions

Commits follow **Conventional Commits**:
`<type>(<scope>): <imperative summary>` with the **why** in the body. Types: `feat`,
`fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`. Branches: `feat/<slug>`,
`fix/<slug>`, `chore/<slug>`, `hotfix/<slug>`; migrations get their own
`feat/<slug>-schema` branch, merged first. One commit per stage; never mix refactor and
feature. Full detail (PR template, when to split PRs):
`dot-claude/skills/feature-workflow/references/git.md`.
