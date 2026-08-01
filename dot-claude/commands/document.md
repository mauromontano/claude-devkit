---
description: Generate or update the feature's design doc in docs/<feature>.md.
argument-hint: [feature name]
---

Delegate to the `docs-writer` subagent to generate or update `docs/$ARGUMENTS.md` with
the current state of the design: problem, decisions (with discarded alternatives), API
contract, data model, stages with their done criterion and status, and risks/rollback.

If it already exists, update it to reflect what was actually built, not what was
planned.
