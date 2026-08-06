---
description: Handle a work item that isn't a feature/bug/refactor — scale the depth to its real size (organic routing).
argument-hint: <what to change>
---

We're handling this work item: **$ARGUMENTS**

This is the middle path between `/feature`, `/bug` and `/refactor`: a change, update, or
maintenance task — a config tweak, a dependency bump, a copy change, a small behavior
update. **Guiding principle: start with the smallest useful path and only scale up when
the evidence says you must.** Don't fire up the whole feature ritual "just in case".

## 1. Understand and size

Restate the work item, locate the code involved, and assign a size: **trivial / medium /
large**. Ask only the questions that change the approach — no trivia.

## 2. Route before working (the important part)

Inspecting the item may reveal it's really something else. If so, **stop and hand off**:

- **A real feature** (new API contract, new data model, several coordinated pieces) →
  switch to **`/feature`** and follow that loop instead.
- **Behavior-preserving cleanup** of existing code → switch to **`/refactor`** (the "two
  hats" rule: never mix it with a behavior change here).
- **A defect** (something is broken) → switch to **`/bug`** (reproduce → red test first).

If none apply, continue here as a lightweight change.

## 3. Change with a test net

- If the change touches **logic**: write the test **first** (red → green), per the TDD
  rule in the constitution. No logic without a covering test.
- If it's **config / deps / docs / copy** with no testable logic: say so explicitly and
  skip the test — don't invent empty tests. When bumping a dependency, run the existing
  suite to catch regressions.

## 4. Scale the depth to the size

- **trivial** → the minimal change, run the full suite green, propose the commit.
- **medium** → a short plan first (no full spec/diagram), then the `code-reviewer`
  subagent, then the **human gate** (stop and wait for my OK), then commit. Add
  `security-reviewer` if it touches auth, payments, sensitive data, or external input.

## 5. Commit

Conventional Commits with the type that fits the change — usually `chore`, `docs`,
`build`, or `perf` (or `feat` / `fix` if you routed). Branch named for the type
(`chore/<slug>`, etc.). Body explains the **why**.
