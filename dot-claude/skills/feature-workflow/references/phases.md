# The feature process, end to end

Stack-agnostic and complexity-scaled: a small feature goes through the same phases but
lighter; a complex one takes each phase seriously.

Trigger: `/feature <description>`. The cycle:

```
Brainstorm → Plan → Spec + Docs + Diagram → Tasks → [ Stage: Test → Code → Review + Verify ]×N → Close + Archive
```

Golden rule: **never advance to the next stage until the previous one is green and reviewed.**

---

## Phase 0 — Brainstorm and framing

**Goal:** understand the real problem before writing a single line.

- Restate the task in your own words and confirm scope.
- Ask the questions that change the design (not the trivial ones). E.g.: does this need
  to be transactional? Is there concurrency? Who consumes the endpoint? What happens if
  it fails halfway?
- Surface risks, dependencies, and edge cases early.
- Propose 2-3 possible approaches with trade-offs when the decision isn't obvious.

**Scaling by complexity:**

| Complexity | What Phase 0 does |
|------------|-------------------|
| Trivial (1 file, no design) | Confirm in one line and start. |
| Medium (several files, one endpoint) | 2-4 scoping questions + chosen approach. |
| High (new module, data, integrations) | Full brainstorm, alternatives, risks — only then plan. |

**Output:** a shared understanding of the problem and the general approach.

---

## Phase 1 — Layered plan in stages

**Goal:** an incremental, reviewable plan — not a code dump.

Use **plan mode** (propose without touching disk). The plan must include:

1. **Layered design** — what changes in each layer (UI, state, server, domain, data).
2. **API contract** — request/response shape and data model. Fixed here.
3. **Incremental stages** — the feature split into small steps. Each stage compiles,
   passes tests, has an explicit "done" criterion, and is a valid commit point.
4. **Test strategy** — what gets tested per stage and at which level.
5. **Risks and rollback** — what can go wrong and how to revert.
6. **Delivery strategy** — apply the branching/migration rules in `git.md` (own PR for
   schema changes, merge order, independently deployable parts).

Delegate architecture design and alternatives to the `architect` subagent,
which reasons about trade-offs without polluting the main context.

**Output:** an approved plan, split into numbered stages.

---

## Phase 2 — Spec, documentation, and diagram

**Goal:** the design written down, verifiable, and visual before implementing.

- `/spec` generates `docs/<feature>-spec.md`: **requirements** + **acceptance scenarios**
  in Given/When/Then. Scenarios are objective "this is correct" criteria — each scenario
  ≈ one test. This is what gets **verified** against the implementation (Phase 4).
- `/document` generates `docs/<feature>.md`: problem, decisions (with discarded
  alternatives), API contract, and data model. The design's source of truth.
- `/tasks` generates `docs/<feature>-tasks.md`: a **stage checklist** ticked as work
  progresses. It's the **durable state**: if you switch windows, this file says exactly
  what's left.
- `/diagram` invokes **archify** for the right diagram (architecture, sequence, or
  flow/state). Saved as HTML in `docs/`.

**Output:** spec + scenarios + tasks + doc + diagram, committed before coding.

---

## Phase 3 — Incremental implementation with TDD

**Goal:** build stage by stage, always green.

For each stage (`/stage <n>`), the strict cycle is:

1. **Red** — write the test(s) describing this stage's behavior. They run and fail.
2. **Green** — the minimum code to make them pass. Nothing more.
3. **Refactor** — clean up with the tests as a safety net.
4. **Verify** — run the stage's full suite; show it green.

The `PostToolUse` hook runs lint (and optionally tests) automatically after every edit,
so errors surface immediately, not at the end.

**Rule:** a stage isn't "done" until red→green→refactor + green suite.

---

## Phase 4 — Per-stage review

**Goal:** every increment is audited before building on top of it.

When closing a stage, `/review` delegates to the review subagents:

- **`qa`** (always): quality, style vs CLAUDE.md, test coverage, N+1,
  error handling, unnecessary complexity.
- **`security`** (if the stage touches auth, payments, sensitive data, or
  external input): injection, XSS/CSRF, secrets handling, authorization, input validation.
- **`spec-verifier`** (verify): checks the implementation **meets the spec scenarios**
  (Phase 2), one by one, and ticks the stage in `docs/<feature>-tasks.md`. Not the same
  as "code review passed" — this checks acceptance criteria.

Reviewers run in isolated context and return actionable feedback. Findings are resolved
**before** moving to the next stage. If a finding changes the design, go back to Phase 1
for that part.

**Human gate (mandatory).** After the automated review, apply the human gate defined in
the constitution: stop, summarize, and wait for explicit approval. The subagents'
review doesn't replace the human review — it prepares it.

**Output:** a stage approved by the human, ready to commit.

---

## Phase 5 — Close

**Goal:** leave everything consistent and ready to integrate.

- Update `docs/<feature>.md` with what was learned or changed vs the plan.
- Run the project's **full** suite (not just the feature's).
- Regenerate the diagram if the architecture changed.
- Build the commit/PR per the conventions in `git.md` — the message explains the *why*,
  not just the *what*.
- **Archive:** move the closed spec to `docs/archive/<feature>-spec.md`. It remains as a
  decision log (ADR-style): why it was built this way and what was discarded.

---

## Phase → tool map

| Phase | Command | Subagent | Hook | Skill |
|-------|---------|----------|------|-------|
| 0 Brainstorm | `/feature` | — | — | — |
| 1 Plan | plan mode | `architect` | — | — |
| 2 Spec+docs+diagram | `/spec`, `/document`, `/tasks`, `/diagram` | `docs-writer` | — | archify |
| 3 Implementation | `/stage` | — | PostToolUse (lint/test) | per stack |
| 4 Review + Verify | `/review` | `qa`, `security`, `spec-verifier` | — | — |
| 5 Close + Archive | commit/PR | — | PreToolUse (protects files) | — |

---

## Context management in large tasks

The enemy of a long task is filling the context window and losing the plan. The fix is
**not using context as memory** — externalize state to disk:

- **Durable state lives on disk**: `docs/<feature>-spec.md` (what to achieve),
  `docs/<feature>.md` (decisions/design), `docs/<feature>-tasks.md` (what's left). A new
  window (or `/clear`) reads those files and resumes exactly where you left off.
- **Subagents isolate noise.** Reading many files, running suites, and reviews happen in
  the subagent's window, keeping the main context light.
- **Commit per stage.** Git history is recoverable state (`git log`).
- **Context hygiene.** `/compact` when the window fills up; `/clear` between features.
  If a stage grows huge, that's a signal to split it further.

Rule of thumb: if `docs/<feature>.md` is up to date and the code is committed when a
stage ends, you can close the window safely — everything needed to continue is on disk.

## Why this order matters

- **Brainstorm before plan** avoids planning the wrong thing.
- **Plan before docs** avoids documenting a design that will change.
- **Docs before code** makes the contract explicit so front/back parallelize.
- **Tests before code** means code is born covered.
- **Review before advancing** avoids building on a base with debt.

Each phase exists so the next one doesn't rest on something fragile.
