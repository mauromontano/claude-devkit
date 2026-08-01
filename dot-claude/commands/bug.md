---
description: Fix a bug (reproduce → red test capturing it → root cause → minimal fix → green suite).
argument-hint: <bug description>
---

We're fixing this bug: **$ARGUMENTS**

Follow this flow strictly — no fixing before reproducing:

1. **Reproduce and locate.** Understand the symptom, find the code involved, and state
   your hypothesis of the cause.
2. **Red test.** Write a test that captures the bug and fails for the right reason.
   Don't touch production code yet.
3. **Root cause.** Diagnose the real cause, not the symptom. If the fix implies a
   design change, stop and apply the human gate before continuing.
4. **Minimal fix.** The smallest change that makes the test green. Then run the full
   suite — everything green, no regressions.
5. **Commit** as `fix(<scope>): <summary>` with the root cause in the body. Branch
   `fix/<slug>` — or `hotfix/<slug>` if it's an urgent production fix (the regression
   test is still mandatory).
