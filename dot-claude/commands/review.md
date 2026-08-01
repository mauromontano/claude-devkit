---
description: Review the current stage with the review subagents before advancing.
argument-hint: [optional stage context]
---

Review the stage that just finished, before moving on.

1. Delegate to the `code-reviewer` subagent (always): quality, design, coverage.
2. If the stage touches auth, payments, sensitive data, webhooks, or external input,
   **also** delegate to the `security-reviewer` subagent.
3. Delegate to the `spec-verifier` subagent (verify): confirm the stage **meets the
   spec scenarios** (`docs/<feature>-spec.md`), scenario by scenario. An uncovered
   scenario is blocking.
4. Consolidate findings by severity. **Resolve every 🔴 blocking/critical finding
   before continuing.** If a finding changes the design, go back to the plan phase for
   that part.
5. When no blockers remain: tick the stage in `docs/<feature>-tasks.md`, update the doc
   (`docs-writer`), run the full suite, and prepare the commit explaining the *why*.
6. **Apply the human gate:** show me a summary (what changed, tests, verified
   scenarios, findings) and don't advance to the next stage until I give the OK.

Additional context: $ARGUMENTS
