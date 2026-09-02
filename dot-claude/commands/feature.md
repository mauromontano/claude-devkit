---
description: Start the end-to-end feature flow (brainstorm → plan → docs → TDD → review).
argument-hint: <feature description>
---

I'm going to build this feature: **$ARGUMENTS**

Follow the process in `~/.claude/skills/feature-workflow/references/phases.md`. Do not
write code yet. Start with **Phase 0 (brainstorm)**:

1. Restate the feature in your own words and confirm the scope.
2. Assess complexity (trivial / medium / high) and adjust depth accordingly.
3. Ask only the questions that change the design (transactionality, concurrency,
   endpoint consumers, what happens on mid-failure, scope limits). No trivia.
4. If the design decision isn't obvious, sketch 2-3 approaches with their trade-offs.

Once the problem is clear, switch to **plan mode** and delegate the architecture design
to the `architect` subagent. Only with the plan approved do we move on to
docs and implementation. One stage at a time, green and reviewed before advancing.
