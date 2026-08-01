---
name: laravel
description: Conventions and patterns for Laravel / PHP following the devkit's layered process and TDD. Activates when the project uses Laravel/PHP (composer.json with laravel/framework, .php files, Eloquent, Artisan) or when Laravel, Eloquent, Pest, Artisan, or MySQL come up in that context.
---

# Laravel / PHP

The same layered pattern as the rest of the devkit, with Laravel's names. Thin
controllers, logic in services, no business logic in the controller.

## Layers of a request

1. **Route → thin controller.** Receives, authorizes, delegates. No business logic.
2. **Validation via Form Request.** Validation rules out of the controller.
3. **Authorization via Policies / Gates.** Before touching anything (Pundit equivalent).
4. **Logic in Service classes.** One responsibility per service, testable.
5. **Persistence with Eloquent.** Model validations; multi-table operations inside
   `DB::transaction(...)`. Watch for N+1: use eager loading (`with`).
6. **Serialization with API Resources.** Consistent response shape.
7. **Heavy work to Queues/Jobs.** Never in the request. Configure with Horizon/Redis.

## TDD in Laravel

- Framework: **Pest** (preferred) or **PHPUnit**. Test first, red → green → refactor.
- Feature tests for endpoints (HTTP + DB with `RefreshDatabase`), unit tests for
  services.
- Factories and seeders for test data. Test the edges and errors, not just the happy
  path.
- Run: `php artisan test` or `./vendor/bin/pest`.

## Quality

- **Pint** for format/lint (`vendor/bin/pint`). The post-edit hook already runs it on
  `.php`.
- **Larastan / PHPStan** for static analysis.
- Migrations: own branch/PR, merged before the code that uses them. Keep
  `php artisan migrate` reversible (define `down()`).

## Mapping from Rails/Node

| Concept | Rails | Laravel |
|---------|-------|---------|
| Validation | strong params / validations | Form Request |
| Authorization | Pundit policy | Policy / Gate |
| Business logic | Service object | Service class |
| ORM | ActiveRecord | Eloquent |
| Serializer | JSON:API serializer | API Resource |
| Jobs | Sidekiq | Queue + Horizon |
| Tests | RSpec | Pest / PHPUnit |
| Lint | RuboCop | Pint |
| Static analysis | — / Sorbet | Larastan / PHPStan |

The DB engine (MySQL vs Postgres) doesn't change the concepts: transactions, indexes,
foreign keys, avoiding N+1, normalization.
