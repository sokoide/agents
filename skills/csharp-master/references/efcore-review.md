# EF Core Review Guide (Local)

## 1) Query Performance

- **N+1**: Monitor the number of queries before optimization; consider `Include`, projections, or explicit joins.
- **Tracking**: Consider `AsNoTracking()` for read operations; however, tracking is default if updates are needed.
- **Projection**: Save network and memory by projecting to DTOs instead of fetching entire Entities.

## 2) Transactions & Consistency

- Fix transaction boundaries at the UseCase level; avoid nested or long-running transactions.
- Design retries in alignment with consistency requirements (Especially the impact of possible re-execution).

## 3) DbContext Lifetime

- `DbContext` is typically Scoped. Do not inject into Singletons.
- Parallel use of the same `DbContext` instance is prohibited (It is not thread-safe).

## 4) Migrations & Schema

- Fix migration application order and rollback policy in operational standards.
- Perform breaking changes (e.g., column deletion or type changes) incrementally, allowing for a compatibility period.
