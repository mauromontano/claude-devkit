# Engineering constitution

Global instructions for working with me on any project. These are *process* principles,
not stack-specific ones. If the repo has its own `CLAUDE.md`, it wins on specifics;
this remains the baseline.

## How you work with me

- **Understand before acting.** For any non-trivial task, clarify scope, assumptions,
  and edge cases first. If something ambiguous changes the design, ask. Don't guess
  important requirements.
- **Plan before writing.** For anything touching more than ~2 files or involving a
  design decision, use plan mode and propose a staged plan before touching code.
- **Incremental, never big-bang.** Split work into small, reviewable stages. Each stage
  must compile, pass tests, and be a valid commit point.
- **Show the trade-off.** When choosing an approach, name the alternative you discarded
  and why. Good design defends itself by explaining what was *not* done.
- **Be honest about uncertainty.** Prefer "I'm not sure, let me verify" over
  overclaiming.

## TDD by default

- Write the test **first**. Red → minimal code → green → refactor.
- No logic without a covering test. Edge and error cases get tested too, not just the
  happy path.
- Before calling a stage done, run the suite and show it green.
- If a change isn't testable, that's a signal the design needs adjusting.

## Architecture: layers with clear responsibilities

Think of every feature as layers with an **API contract in the middle** separating
front from back, so both move in parallel. The pattern is the same in any framework —
the names change, not the structure:

- **Back:** route → thin controller (receive, authorize, delegate — no business logic)
  → validation → service objects (one responsibility each) → model/ORM (multi-table
  writes inside a transaction) → serializer → background jobs for heavy or deferred
  work, never in the request.
- **Front:** UI component → state (client state vs server-state, each on its own) →
  server-side data layer (validation, secrets/auth) → typed API client speaking the
  contract. Every component handles its 4 states: loading / error / empty / success.

Framework specifics live in the stack skills (laravel, node-next).

## Contract first

Define the endpoint shape (request/response) and the data model **before**
implementing. With the contract fixed, back and front move in parallel. The contract
lives in the feature's doc.

## Docs and diagrams are part of the work

- Every non-trivial feature gets a `docs/<feature>.md`: problem, decisions, API
  contract, data model, plan stages. Updated as each stage closes, not at the end.
- Anything with several pieces or flows gets an **archify** diagram (architecture,
  sequence, or flow). The diagram is part of the deliverable, not an extra.

## Quality and security

- Every stage goes through the `code-reviewer` subagent before advancing. Features
  touching auth, payments, sensitive data, or external input also go through
  `security-reviewer`.
- No hardcoded secrets. External input always validated. Queries always parameterized.
- Before a commit/PR: clean lint, green tests, updated docs.

## Human gate per stage (important)

- When a stage ends, **STOP**. Show me a summary (what changed, green tests, review
  findings) and **wait for my explicit OK** before starting the next one.
- Never chain stages without my approval. I review, I approve, then you continue.
- If a review finding changes the design, don't brute-force the fix: propose the
  adjustment and wait for my confirmation.

## Git

- Commits follow **Conventional Commits**:
  `<type>(<optional scope>): <imperative summary, lowercase, ≤72 chars>`, body
  explaining the **why** (the diff already shows the what). Types: `feat`, `fix`,
  `refactor`, `test`, `docs`, `chore`, `perf`, `build`.
- Branches: `feat/<slug>`, `fix/<slug>`, `chore/<slug>`, `hotfix/<slug>`;
  migrations get their own `feat/<slug>-schema` branch/PR, merged first.
- One commit per stage. Never mix refactor and feature changes in the same commit.
- PR templates, when to split PRs, and migration strategy:
  `~/.claude/skills/feature-workflow/references/git.md`. Read it before creating a PR
  or planning anything that touches the schema.

## Context management in long tasks

- State lives in `docs/<feature>.md` (plan + stage checklist), not in your context
  memory. A new session reads that doc and resumes.
- Delegate noisy work (reading many files, running suites, reviews) to subagents to
  keep the main context light.
- Commit per stage: git history is recoverable state.
- Suggest `/compact` when context fills up; `/clear` between features.

## Communication style

- Direct and concise. No filler, no excess apologies.
- When a stage ends, summarize in 2-3 lines what changed and what's next.
- Show diffs and test results — don't ask me to trust, show me the evidence.
