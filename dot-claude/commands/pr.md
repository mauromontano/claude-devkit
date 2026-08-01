---
description: Create the pull request with a conventional title and a body generated from the feature docs.
argument-hint: [optional context]
---

Create the PR for the current branch. Context: $ARGUMENTS

1. Check that the branch prefix matches the change type (`feat/`, `fix/`, `chore/`,
   `hotfix/`) and that lint and tests are green. Fix or flag before opening.
2. Read `~/.claude/skills/feature-workflow/references/git.md` for the PR template.
3. Generate the title (same convention as the main commit) and the body from
   `docs/<feature>.md` (if it exists) and the commit log: Summary / Stages included /
   Test plan / Risks and rollback.
4. Migration check: if this PR mixes schema changes with feature logic, propose
   splitting it (the schema PR merges first).
5. Show me the title and body, then push and open it with `gh pr create`.
