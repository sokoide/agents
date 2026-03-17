---
name: java-master
description: >
    Java + Spring expert. Master of modern Java (11/17/21), Spring Boot, dependency
    injection, transactions, testing, and production-grade design/review for backend
    services. Use for:
    (1) Spring Boot implementation/review (DI, transactions, exception design, API design).
    (2) Performance/reliability (N+1, connection pool, threads/async, observability).
    (3) Java + Spring Boot backend development guidance.
---

# Java Master

This skill provides expert-level Java and Spring Boot guidance for production-grade backend services.

## Related Tools

This skill uses: Bash (for mvn/gradle/java commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Java / Spring Boot / Spring Framework version, Build (Maven/Gradle), Execution Environment (K8s/VM).
- Primary technologies (Spring MVC/WebFlux, Spring Data JPA/Jdbc, Security, Messaging).
- Failure requirements (Retries/Idempotency/Timeouts/Consistency), SLO (p95/p99, Throughput).
- Data model (RDB/NoSQL), Transaction boundaries (Distributed or not), Migration management.

## Output Contract (How to Respond)

- **Review**: Classify points as "Correctness / API / DI / Transactions / Data(JPA) / Security / Performance / Operability," clearly stating the severity and correction policy.
- **Proposal**: Prioritize "safe, minimal diffs" and provide incremental refactoring steps (Boundaries first, then internal).
- **Spring-Specific**: Always verbalize pitfalls related to Dependency Injection, Bean boundaries, and Proxy/`@Transactional`.

## Design & Coding Rules (Expert Defaults)

1. **Constructor Injection**: Avoid field injection and explicitly state dependencies in the constructor.
2. **Layering**: Controllers focus on I/O, Services on use cases, and Repositories on persistence (Do not leak domain decisions to the DB side).
3. **DTO vs Entity**: Do not mix API DTOs and JPA Entities; fix mapping responsibilities.
4. **Transactions are Explicit**: Specify `@Transactional` boundaries and intentionally choose read/write and propagation settings.
5. **Null is a Bug Source**: Use `Optional` only for "return values" and do not overuse it as fields.
6. **Observability by Default**: Design with boundaries (External I/O, slow SQL) in mind for logs, metrics, and traces.
7. **Modern Data Structures**: For Java 14+, use `record` for DTOs to achieve both immutability and elimination of boilerplate.
8. **Testing with Realism**: Use Testcontainers instead of H2 for DB integration tests to eliminate differences from production environments.

## Review Checklist (High-Signal)

- **DI/Beans**: Circular dependencies, incorrect scope, bloated Bean boundaries, non-testable static/Singleton.
- **Transactions**: Self-calls bypassing proxies, `readOnly` intent, long-running transactions, rollback conditions.
- **Data/JPA**: N+1 queries, fetch strategies, lazy initialization exceptions, paging with joins, connection exhaustion.
- **API**: Validation (`@Valid`), error responses (`@ControllerAdvice`), compatibility (avoiding breaking changes).
- **Security**: Authorization boundaries, trust boundaries for input, secret handling, sensitive info in logs.
- **Performance**: Redundant object creation, excessive synchronization, mixing in blocking I/O (especially in WebFlux).
- **Operability**: Timeouts, retry policies, circuits/backpressure, graceful shutdown.

## Common Pitfalls

### ❌ Bad Examples

```java
// NG: Field injection
@Autowired
private UserService userService;  // Difficult to test

// NG: Self-calling @Transactional
@Transactional
public void outer() {
    inner();  // Transaction does not take effect
}
private void inner() { ... }

// NG: N+1 in JPA
List<User> users = userRepository.findAll();
for (User user : users) {
    user.getOrders().size();  // N+1 due to lazy loading
}

// NG: Misuse of Optional
public Optional<User> getUser(Long id) {
    return Optional.of(userRepository.findById(id).orElse(null));  // Wrapping null
}
```

### ✅ Good Examples

```java
// OK: Constructor injection
private final UserService userService;
public UserController(UserService userService) {
    this.userService = userService;
}

// OK: Apply transaction by separating into another class
@Transactional
public void outer() {
    anotherService.inner();  // Via proxy
}

// OK: Batch fetch with fetch join
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders")
List<User> findAllWithOrders();

// OK: Use Optional only for return values
public Optional<User> getUser(Long id) {
    return userRepository.findById(id);
}
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Constructor Injection**: Avoid field injection, explicitly state dependencies in the constructor, and make them final.
2. **@Transactional Boundaries**: Apply in the Service layer and be mindful of proxies. Self-calls do not work.
3. **JPA via Fetch Join**: Use `JOIN FETCH` to gather necessary associations in a single query and avoid N+1.
4. **Separate DTOs and Entities**: Use DTOs in the Controller and Entities in the persistence layer, mapping at the boundary.
5. **Optional Only for Returns**: Do not use in fields or arguments. Use null where it is more natural.
6. **Logging and Exceptions**: Handle exceptions centrally with `@ControllerAdvice` and keep sensitive information out of logs.
7. **Resilience**: Apply Resilience4j for external communications, implementing retries and circuit breakers.

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Common mistakes and best practices.
- **[Check Script](scripts/check.sh)**: Automated checks (`mvn`, `gradle`).

## References

- [Java Backend Review Guide](references/java-backend-review.md)
- [Spring Boot Review Guide](references/spring-boot-review.md)
