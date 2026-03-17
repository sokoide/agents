# Java Backend Review Guide (Local)

## 1) Language & API Design

- **Immutability First**: Use `record` or immutable classes where possible to minimize shared mutable state.
- **Exceptions**: Decide "recoverability" at the boundaries; separate application exceptions (meaningful runtime exceptions) from infrastructure exceptions.
- **Collections**: Fundamentally return empty collections (Avoid returning `null`). Judge whether defensive copies are needed for arguments.
- **Time**: Use `java.time` and fix time zones, rounding, and representations (Instant/LocalDateTime) in the design.

## 2) Concurrency & Async

- **Threading Model**: Decide "which layer owns concurrency" (Do not scatter `CompletableFuture.supplyAsync` arbitrarily).
- **Executors**: Reuse thread pools and avoid unlimited creation. Do not mix blocking I/O with CPU-bound tasks.
- **Shared State**: Use `synchronized` or locks only as a last resort; solve first with immutability, partitioning, or messaging.

## 3) Reliability & Boundaries

- **Timeouts**: Always set timeouts for external I/O and consider retries alongside idempotency.
- **Idempotency**: Design retryable APIs inclusive of key design and deduplication.
- **Logging**: Do not output sensitive information (tokens/PII) to logs. Separate causes from inputs in exception logs.

## 4) Testing Strategy (Default)

- **Unit**: Rapidly test pure logic using JUnit.
- **Slice**: Focus on boundaries with `@WebMvcTest` for MVC and `@DataJpaTest` for JPA.
- **Integration**: Ensure reproducibility for external dependencies with Testcontainers (Limited to what is necessary).
