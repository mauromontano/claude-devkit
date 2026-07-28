---
name: laravel
description: Convenciones y patrones para desarrollar en Laravel / PHP siguiendo el mismo proceso por capas y TDD del devkit. Se activa cuando el proyecto usa Laravel/PHP (composer.json con laravel/framework, archivos .php, Eloquent, Artisan) o se menciona Laravel, Eloquent, Pest, Artisan o MySQL en ese contexto.
---

# Laravel / PHP

El mismo patrón por capas del resto del stack, con los nombres de Laravel. Controllers
finos, lógica en servicios, nada de negocio en el controller.

## Capas de una request

1. **Ruta → Controller fino.** Recibe, autoriza y delega. Sin lógica de negocio.
2. **Validación con Form Request.** Reglas de validación fuera del controller.
3. **Autorización con Policies / Gates.** Antes de tocar nada (equivalente a Pundit).
4. **Lógica en Service classes.** Una responsabilidad por servicio, testeable.
5. **Persistencia con Eloquent.** Validaciones en el modelo; operaciones multi-tabla
   dentro de `DB::transaction(...)`. Cuidado con N+1: usá eager loading (`with`).
6. **Serialización con API Resources.** Formato de respuesta consistente.
7. **Trabajo pesado a Queues/Jobs.** Nunca en el request. Config con Horizon/Redis.

## TDD en Laravel

- Framework: **Pest** (preferido) o **PHPUnit**. Test primero, rojo → verde → refactor.
- Feature tests para endpoints (HTTP + DB con `RefreshDatabase`), unit tests para servicios.
- Factories y seeders para datos de prueba. Testeá el borde y el error, no solo el happy path.
- Corré: `php artisan test` o `./vendor/bin/pest`.

## Calidad

- **Pint** para formato/lint (`vendor/bin/pint`). El hook post-edit ya lo corre en `.php`.
- **Larastan / PHPStan** para análisis estático.
- Migraciones: en su propio branch/PR, mergeadas antes del código que las usa.
  `php artisan migrate` reversible (definí `down()`).

## Notas de mapeo desde Rails/Node

| Concepto | Rails | Laravel |
|----------|-------|---------|
| Validación | strong params / validations | Form Request |
| Autorización | Pundit policy | Policy / Gate |
| Lógica de negocio | Service object | Service class |
| ORM | ActiveRecord | Eloquent |
| Serializer | JSON:API serializer | API Resource |
| Jobs | Sidekiq | Queue + Horizon |
| Tests | RSpec | Pest / PHPUnit |
| Lint | RuboCop | Pint |
| Static analysis | — / Sorbet | Larastan / PHPStan |

El motor de DB (MySQL en Laravel vs Postgres) no cambia los conceptos: transacciones,
índices, foreign keys, evitar N+1, normalización.
