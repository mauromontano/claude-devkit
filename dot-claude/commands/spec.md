---
description: Generate the feature spec with requirements and acceptance scenarios (Given/When/Then).
argument-hint: [feature name]
---

Generate or update `docs/$ARGUMENTS-spec.md` with the feature spec. Delegate to
`docs-writer` if convenient. Structure:

## Requirements
What the feature must do, in business language (not implementation language).

## Acceptance scenarios
One per observable behavior, in **Given / When / Then** format. Cover the happy path,
the edges, and the error cases. Shape:

- **Scenario: <observable behavior>**
  - Given <initial state>
  - When <action>
  - Then <verifiable outcome, including the error/rejection cases>

Rules:
- Every scenario must be **objectively verifiable** — it is, essentially, a test.
- No implementation details (no tables, no classes): those belong in
  `docs/<feature>.md`.
- These scenarios are what the `spec-verifier` subagent later validates against the
  code.
