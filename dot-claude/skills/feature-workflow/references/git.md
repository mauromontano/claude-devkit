# Git conventions

Single source of truth for commits, branches, PRs, and delivery. The constitution
carries the essential block; this file has the detail. Referenced by `/pr`, `/feature`
(plan phase), and `architecture-planner`.

## Commit messages (Conventional Commits)

```
<type>(<optional scope>): <imperative summary, lowercase, ≤72 chars>

<body: the WHY of the change — context, trade-off, root cause.
 The diff already shows the what.>
```

- **Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`.
- **Scope:** the affected module/domain (`auth`, `billing`, `orders`), not the file.
- One commit per stage of the plan; git history is recoverable state.
- Never mix refactor and feature changes in the same commit (the "two hats" rule).
- Examples:
  - `feat(auth): add refresh token rotation`
  - `fix(billing): handle null invoice on webhook`
  - `refactor(orders): extract pricing service`

## Branches

| Prefix | Use |
|--------|-----|
| `feat/<slug>` | New feature or capability |
| `fix/<slug>` | Bug fix |
| `chore/<slug>` | Tooling, deps, config — no production behavior change |
| `hotfix/<slug>` | Urgent production fix (fast-tracked, regression test mandatory) |
| `feat/<slug>-schema` | Migrations/schema only — own PR, merged and deployed first |

Slugs: short, kebab-case, descriptive (`feat/auth-refresh-tokens`).

## Pull requests

- **Title:** same convention as the main commit (`feat(auth): add refresh token rotation`).
- **Body** (generated from `docs/<feature>.md` and the commit log):

  ```
  ## Summary
  What this delivers and why (link to docs/<feature>.md if it exists).

  ## Stages included
  The plan stages this PR covers.

  ## Test plan
  What was tested and how; suite results.

  ## Risks and rollback
  What could go wrong and how to revert.
  ```

- Before opening: clean lint, green tests, updated docs, branch prefix matches the
  change type.

## Splitting and delivery

- Large feature → **several branches/PRs** with an explicit merge order, never one
  giant PR. Decide the split at plan time, not mid-implementation.
- **Migrations and schema changes go in their own branch/PR**, merged and deployed
  **before** the code that uses them. Never mix a heavy migration with feature logic
  in the same PR.
- Changes that can be deployed and reverted independently = separate branches.
