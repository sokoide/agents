---
name: csharp-master
description: >
    C# + .NET expert. Master of modern C# (10/11/12), ASP.NET Core, dependency
    injection, async/await, EF Core data access, testing, and production-grade
    review/design for backend services. Use for:
    (1) C#/.NET implementation/review (API design, DI, exceptions, logging, observability).
    (2) EF Core data access (N+1, transactions, connection pool, consistency).
    (3) async/await, threads/thread pool, background processing, reliability.
    (4) Building production-grade backend services.
---

# C# Master

This skill provides expert-level C# and .NET guidance for production-grade backend services.

## Related Tools

This skill uses: Bash (for dotnet commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- .NET / C# version, Hosting (K8s/IIS/VM), Build/CI (dotnet/SDK).
- Web stack (Minimal APIs / MVC / gRPC), Authentication (JWT/OIDC), presence of Caching/Messaging.
- DB type, usage range of EF Core, transaction boundaries, migration management.
- Non-functional requirements (p95/p99, throughput, timeouts, retries/idempotency, SLO).

## Output Contract (How to Respond)

- **Review**: Classify points as "Correctness / API / DI / Async / Data(EF) / Security / Performance / Operability," clearly stating the severity and correction policy.
- **Proposal**: First solidify the "boundaries" (API/Exceptions/DI/DB), then improve internal implementations incrementally with minimal diffs.
- **async**: Always verbalize "where to await" vs "where it blocks" and specify risks like deadlock or thread pool exhaustion.

## Design & Coding Rules (Expert Defaults)

1. **Constructor Injection**: Explicitly state dependencies in the constructor and avoid Service Locator.
2. **Separation of Concerns**: Limit the Web layer to I/O, the Domain/Service layer to use cases, and the Data layer to persistence.
3. **DTO vs Entity**: Do not mix API DTOs and EF Entities; perform mapping at the boundaries.
4. **Async All the Way**: Use async for I/O; synchronous blocking calls like `.Result` or `.Wait()` are prohibited.
5. **Cancellation & Timeouts**: Propagate `CancellationToken` from boundaries and set timeouts for external I/O.
6. **Observability by Default**: Design with structured logging, correlation IDs, and metrics in mind (do not log sensitive information).
7. **Global Exception Handling**: For ASP.NET Core 8+, implement `IExceptionHandler` to centralize exception handling.
8. **Nullable Reference Types**: Assume `<Nullable>enable</Nullable>` and aim for zero null warnings.

## Review Checklist (High-Signal)

- **API**: Input validation, consistency of error responses, versioning, avoidance of breaking changes.
- **DI**: Lifetime errors (Singleton/Scoped/Transient), circular dependencies, massive services, non-testable statics.
- **Async**: `.Result`/`.Wait()`, unnecessary `Task.Run`, thread pool exhaustion, ignored cancellations.
- **Data / EF Core**: N+1 queries, tracking/no-tracking, bloated queries, transaction boundaries, connection exhaustion.
- **Security**: Authorization boundaries, trust boundaries for input, leakage of secrets/PII, sensitive info in logs.
- **Performance**: Redundant allocations, excessive LINQ, synchronous I/O, massive JSON, GC pressure.
- **Operability**: Timeout/Retry/Idempotency, graceful shutdown, proper cleanup of background processes.

## Common Pitfalls

### ❌ Bad Examples

```csharp
// NG: Using synchronous blocking in async
public async Task<User> GetUserAsync(int id) {
    return db.Users.Find(id);  // Synchronous method
}

// NG: Deadlock danger with .Result
public void Process() {
    var result = GetDataAsync().Result;  // Risk of deadlock
}

// NG: N+1 with EF Core
foreach (var user in users) {
    var orders = db.Orders.Where(o => o.UserId == user.Id).ToList();  // N+1
}

// NG: Incorrect DI lifetime
services.AddSingleton<DbContext>();  // DbContext should be Scoped
```

### ✅ Good Examples

```csharp
// OK: Consistent use of async
public async Task<User> GetUserAsync(int id, CancellationToken ct) {
    return await db.Users.FindAsync(id, ct);
}

// OK: Use await
public async Task ProcessAsync() {
    var result = await GetDataAsync();
}

// OK: Batch fetch with Include
var users = await db.Users
    .Include(u => u.Orders)
    .ToListAsync(ct);

// OK: Appropriate DI lifetime
services.AddScoped<DbContext>();
services.AddScoped<IUserService, UserService>();
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Async All the Way**: Always use async for I/O; never use `.Result`/`.Wait()`.
2. **Propagate CancellationToken**: Receive `CancellationToken` in all async methods and pass it to external I/O.
3. **Correct DI Lifetime**: DbContext should be Scoped, stateless services should be Scoped or Transient, and cache should be Singleton.
4. **EF Core via Include**: Explicitly use Include for necessary navigation properties to avoid N+1.
5. **Separate DTOs and Entities**: Do not mix API DTOs and EF Entities; map them at boundaries (using AutoMapper or Mapster).
6. **Structured Logging**: Use `ILogger<T>` for structured logs; never output sensitive info to logs.
7. **Resilience**: Apply retry policies with `Microsoft.Extensions.Http.Resilience` (Polly) for HTTP requests and DB connections.
8. **LINQ Hygiene**: Be mindful of deferred execution and use `.ToListAsync()` at appropriate times to avoid multiple enumerations.

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Common mistakes and best practices.
- **[Check Script](scripts/check.sh)**: Automated checks (`dotnet build`, `test`, `format`).

## References

- [Dotnet Backend Review Guide](references/dotnet-backend-review.md)
- [ASP.NET Core Review Guide](references/aspnetcore-review.md)
- [EF Core Review Guide](references/efcore-review.md)
