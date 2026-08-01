---
name: feature-workflow
description: End-to-end process for building features (brainstorm → layered plan → docs + diagram → incremental TDD → per-stage review). Activates when starting a feature, module, or non-trivial change, or when "plan", "TDD", "stages", or "end-to-end" come up.
---

# Feature workflow

Trigger: `/feature <description>`. Golden rule: **never advance to the next stage until
the previous one is green and reviewed.** Scale depth to complexity (trivial / medium /
high). Full per-phase detail lives in `references/phases.md` — read it when running the
process.

0. **Brainstorm** — understand the problem first; ask only the questions that change the
   design; sketch 2-3 approaches with trade-offs when the decision isn't obvious.
1. **Plan** — plan mode; **API contract first**; layered design; incremental stages,
   each committable with an explicit "done" criterion. Delegate to `architecture-planner`.
2. **Spec + docs + diagram** — `/spec`, `/document`, `/tasks`, `/diagram` (archify).
   Commit before coding.
3. **Incremental TDD** — per stage (`/stage`): red → green → refactor → verify.
4. **Review** — `/review` per stage: `code-reviewer` always, `security-reviewer` when the
   stage touches auth/payments/sensitive data/external input, `spec-verifier` against the
   spec. Then the human gate applies (see constitution).
5. **Close** — update docs, run the full suite, commit/PR, archive the spec to
   `docs/archive/<feature>-spec.md`.

Branching, migrations, and delivery strategy: `references/git.md`.
