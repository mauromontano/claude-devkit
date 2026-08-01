---
name: rails
description: Conventions and patterns for Ruby on Rails following the devkit's layered process and TDD. Activates when the project uses Rails (Gemfile with rails, .rb files, ActiveRecord, config/routes.rb) or when Rails, RSpec, Sidekiq, or Pundit come up in that context.
---

# Ruby on Rails

The same layered pattern as the rest of the devkit, with Rails' names. Thin
controllers, logic in services, no business logic in the controller.

## Layers of a request

1. **Route → thin controller.** Receives, authorizes, delegates. No business logic.
2. **Validation.** Strong params at the boundary; model validations for invariants.
3. **Authorization with Pundit policies.** Before touching anything.
4. **Logic in service objects.** One responsibility per service, testable in isolation.
5. **Persistence with ActiveRecord.** Multi-table operations inside a transaction.
   Watch for N+1: use `includes`/`preload`.
6. **Serialization** with a consistent serializer (JSON:API or equivalent).
7. **Heavy work to Sidekiq jobs.** Never in the request.

## TDD in Rails

- Framework: **RSpec**. Test first, red → green → refactor.
- Request specs for endpoints, unit specs for services and models.
- FactoryBot for test data. Test the edges and errors, not just the happy path.
- Run: `bundle exec rspec`.

## Quality

- **RuboCop** for style/lint (`bundle exec rubocop`); **Brakeman** for security in CI.
- Migrations: own branch/PR, merged before the code that uses them. Keep them
  reversible (`down` or reversible `change`).
