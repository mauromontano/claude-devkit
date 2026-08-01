---
description: Implement one stage of the plan with TDD (red → green → refactor).
argument-hint: <stage number or name>
---

Implement the stage: **$ARGUMENTS**

Follow strict TDD (Phase 3 of `~/.claude/skills/feature-workflow/references/phases.md`):

1. **Red** — write this stage's tests first. Confirm they run and fail for the right
   reason (real assertion failures, not import errors).
2. **Green** — the minimum code to make them pass. Nothing more.
3. **Refactor** — clean up with the tests as a safety net.
4. **Verify** — run the stage's suite and show it green.

Do not implement anything outside this stage's scope. When it's green, run `/review`
and then apply the human gate: stop, show the summary, and wait for explicit approval
before touching the next stage.
