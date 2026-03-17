# ASP.NET Core Review Guide (Local)

## 1) Web Layer / Middleware

- Controllers/endpoints should be thin (Limited to input conversion, authentication/authorization, use case calls, and output formatting).
- Keep model binding and validation responsibilities at the boundaries; avoid redundant validation internally.
- Capture exceptions globally to maintain consistent error formats (Do not return stack traces).

## 2) DI Lifetimes

- **Singleton**: For stateless or thread-safe components only. Dependencies like `DbContext` or `HttpContext` are prohibited.
- **Scoped**: Per-request dependencies (Used for most application services and `DbContext`).
- **Transient**: Lightweight and disposable. Avoid heavy initialization or external connections.

## 3) HTTP Client / Outbound Calls

- Manage `HttpClient` lifetime correctly (Avoid disposal/repeated instantiation).
- Fix the responsibility layer for timeouts, retries, and circuits to avoid overlapping configurations.

## 4) Operability

- Pass correlation IDs and enable searching via structured logs.
- Handle in-flight requests (including background processes) with graceful shutdown.
