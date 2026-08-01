---
description: Generate or update the stage checklist (the feature's durable state).
argument-hint: [feature name]
---

Generate or update `docs/$ARGUMENTS-tasks.md`: the plan's **stage checklist**. It's the
feature's durable state — the source of truth for what's left.

Format:

```markdown
# Tasks — <feature>

- [ ] Stage 1: <what> — done criterion: <...>
- [ ] Stage 2: <what> — done criterion: <...>
- [ ] Stage 3: <what> — done criterion: <...>
```

Rules:
- One checkbox per stage, with its "done" criterion.
- When closing each stage (after review + verify), **tick the box** and note the
  commit/branch if applicable.
- This file is the first thing read when resuming in a new window: it says exactly
  which stage you're on. Keep it always up to date.
