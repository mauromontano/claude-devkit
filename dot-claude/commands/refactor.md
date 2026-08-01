---
description: Safe refactor of existing code (understand → test net → tiny steps → verify behavior).
argument-hint: <what to refactor / file>
---

We're refactoring: **$ARGUMENTS**. Absolute rule: **no observable behavior changes**.
Refactoring and feature changes are separate things (the "two hats").

Follow these phases and **stop between each one waiting for my OK**. One move at a
time; I review every diff.

Lean on the rest of the setup when it helps (without asking permission for the obvious):
- The **language/framework skill** matching the project's stack.
- The **`test-writer`** subagent to write the characterization tests of Phase 2.
- The **`code-reviewer`** and **`spec-verifier`** subagents in Phase 4, to confirm
  quality and that behavior didn't change.
- **archify** if a before/after diagram of the structure helps explain the refactor.
- A **docs** skill if you need a library's real API.
Still: I'm in control. Never delegate the whole refactor to a subagent; use them as
targeted tools, not to skip the tiny steps.

## Phase 1 — Understand (no code changes)
- Read the target code and its tests. Explain what it does and what behavior the tests
  cover.
- List the code smells (long function, type-based conditional, computation mixed with
  formatting, temps).

## Phase 2 — Secure the net
- Run the tests (and coverage, if the project has it). Identify which cases are **not**
  covered.
- If coverage is missing, add **characterization tests**: they pin CURRENT behavior
  (self-checking). Don't touch existing tests that already pin behavior.

## Phase 3 — Refactor in tiny steps
- **One refactor move at a time**, and name it (Extract Function, Replace Temp with
  Query, Split Loop, Split Phase, Replace Conditional with Polymorphism, etc.).
- After **every** step: run the tests (they must stay green) and propose a commit.
  If something goes red, revert that step and say so.
- Never mix a refactor with a behavior change in the same step.

## Phase 4 — Verify
- Confirm **all** tests are still green and observable behavior didn't change.
- Run static analysis and style at the end (not on every step).

If a new feature needs to be **added** on top of the now-clean code, that's the hat
switch: it gets its own test (red → green), separate from the refactor.
