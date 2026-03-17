# Spring Boot Review Guide (Local)

## 1) DI / Configuration

- Use **Constructor Injection** as a foundation and avoid field injection.
- Type certifications using `@ConfigurationProperties` to enable fail-fast at startup.
- Keep Beans small and focused on specific responsibilities; avoid creating a "God Service."

## 2) Web Layer (MVC / WebFlux)

- **Controllers Should Be Thin**: Limited to transformation, authentication, input validation, UseCase calling, and response formatting.
- **Validation**: Place `@Valid` and Bean Validation at the boundaries; avoid redundant validation in internal logic.
- **Error Handling**: Use `@ControllerAdvice` for consistent error formats (Do not return exceptions directly).
- **WebFlux Caution**: Do not mix blocking I/O (e.g., JDBC) into the event loop.

## 3) Transactions

- Apply `@Transactional` at the "boundaries" (Service/UseCase).
- Avoid cases where self-calls cannot cross proxies (Solve via design or partitioning).
- Decide `readOnly` and isolation levels based on "requirements" (Do not strengthen based on guesswork).

## 4) Data (JPA / JDBC)

- **N+1**: Monitor SQL execution first and consider fetch strategies (e.g., join fetch or entity graphs).
- **Entities**: Separate from API DTOs; do not leak persistence details.
- **Pagination + Join**: Be cautious as results can break easily (Watch out for count queries and duplicate rows).

## 5) Security

- Decide on authentication/authorization at the boundaries; do not scatter arbitrary `if` statements throughout the Service layer.
- Assume secrets come from environment variables or secret managers; never leave them in code or logs.

## 6) Operability

- Design with health checks, metrics, and log correlation (request ID) in mind.
- Fix the responsibility layer for timeouts, retries, and circuit breakers.
