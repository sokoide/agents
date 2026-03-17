# .NET Backend Review Guide (Local)

## 1) Language & API Design

- **Immutability**: Use `record` / init-only / private setters to prevent unintended changes.
- **Nullability**: Assume nullable reference types and do not suppress warnings (Overuse of `!` is a code smell).
- **Exceptions**: Convert/format exceptions at the "boundaries"; do not leak internal exceptions directly to the API.
- **Collections**: Do not return `null` for collections. Consider exposing read-only interfaces for public-facing APIs.

## 2) Async / Concurrency

- **Async All the Way**: Synchronous blocks like `.Result` or `.Wait()` cause deadlocks and thread pool exhaustion.
- **Thread Pool Hygiene**: Do not use `Task.Run` for I/O-bound tasks. Explicitly isolate CPU-bound tasks.
- **Cancellation**: Propagate `CancellationToken` from entry to end points and design for cleanup upon cancellation.

## 3) Reliability Boundaries

- **Timeouts**: Always set timeouts for external I/O (HTTP/DB/Queue) and establish fixed failure modes in the design.
- **Retries & Idempotency**: Pair retries with idempotency. Document deduplication keys and consistency requirements.
- **Logging**: Separate causes from inputs in exception logs; do not log tokens or PII (Personally Identifiable Information).

## 4) Testing Strategy (Default)

- **Unit**: Test pure logic rapidly (Using xUnit, NUnit, or MSTest).
- **Integration**: Focus on reproducibility for DB/External I/O (Limited to what is necessary).
- **Contract**: Consider contract testing for requests/responses if API compatibility is critical.
