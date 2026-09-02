---
description: Review the current stage with the review subagents before advancing.
argument-hint: [optional stage context]
---

Review the stage that just finished, before moving on.

1. Delegate to the `qa` subagent (always): quality, design, coverage.
2. If the stage touches auth, payments, sensitive data, webhooks, or external input,
   **also** delegate to the `security` subagent.
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

## Deliverables (when findings exist)

If the review produced findings worth acting on, also deliver:

- **Audit doc (HTML):** a self-contained HTML report explaining each finding in
  detail — what the bug is, where (`file:line`), why it matters (concrete failure
  scenario), and the possible fixes with trade-offs. Save it next to the feature
  docs (`docs/` of the repo if it will be committed, or `mauro-docs/mango/<feature>/`
  if it's personal) and show me the path.
- **Copy-paste block A — the audit for the PR:** a markdown block, ready to paste
  as a PR comment, summarizing the findings (severity, `file:line`, one-liner each,
  evidence marks). Concise: the HTML has the detail; this is the receipt.
- **Copy-paste block B — the fix response:** a markdown block, ready to paste as
  the reply, listing which findings will be fixed (and how, one line each), which
  become tracked debt, and which are declined with the reason. I decide the list;
  draft it from my decisions in the gate.

Additional context: $ARGUMENTS
