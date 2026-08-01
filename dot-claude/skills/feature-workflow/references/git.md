# Git strategy

Single source of truth for branching, migrations, and delivery. The constitution and
`architecture-planner` reference this file instead of repeating it.

## Branching and delivery

- Large feature → split into **several branches/PRs** with an explicit merge order,
  never one giant PR. Decide the split at plan time, not mid-implementation.
- **Migrations and schema changes go in their own branch/PR**, merged and deployed
  **before** the code that uses them. Never mix a heavy migration with feature logic in
  the same PR.
- Changes that can be deployed and reverted independently = separate branches.
- One commit per stage of the plan; git history is recoverable state.
- Commit messages explain the **why**, not just the what — the diff already shows the what.
