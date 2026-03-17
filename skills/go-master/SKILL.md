---
name: go-master
description: >
    Expert-level Go architect. Master of Effective Go, idiomatic patterns,
    concurrency, and performance optimization. Use for:
    (1) Writing/reviewing/refactoring Go code (error handling, API design, concurrency, performance).
    (2) Improving "Go-ness" (naming, package structure, interface design).
    (3) Safety checks for goroutines/channels/context.Context usage.
---

# Go Master

This skill provides expert-level Go architecture guidance for writing, reviewing, or refactoring Go code to ensure production-grade quality.

## Related Tools

This skill uses: Bash (for go commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Go version, presence of `go.mod`, target execution environment (CLI/HTTP/gRPC/Job).
- Failure requirements (Retries, idempotency, timeouts, cancellations).
- Performance requirements (p99 latency, allocation suppression, parallelism, external I/O constraints).

## Output Contract (How to Respond)

- **Review**: Classify points as "Correctness / API / Concurrency / Errors / Performance / Style," providing brief rationale based on Effective Go or Review Comments.
- **Proposed Correction**: First organize naming, `gofmt`, and boundaries (package/interface), then fix logic or concurrency with minimal diffs.
- **Concurrency**: Always specify the start points and termination conditions (cancellation, close, wait) for goroutines.

## Design & Coding Rules (Expert Defaults)

1. **Simplicity Wins**: Apply abstraction only when necessary. Do not generalize upfront.
2. **Errors are Values**: Return `error`. Limit `panic` to unrecoverable cases (like initialization failures).
3. **Context Propagation**: `context.Context` should always be the first argument; do not hold it in struct fields.
4. **Interfaces at the Consumer**: Define interfaces on the consuming side and return concrete types (Accept interfaces, return structs).
5. **Concurrency is Owned**: The side that starts a goroutine has the responsibility for stopping or collecting it (No leaks).
6. **Table-Driven Tests**: Use table-driven tests by default; leverage `t.Helper()` and `t.Parallel()` to balance maintainability and execution speed.
7. **Error Inspection**: Use `errors.Is` or `errors.As` for error checks; avoid type assertions.
8. **Structured Logging**: Use the standard `log/slog` for logging, recording in a structured key-value format.
9. **Generics Hygiene**: Limit generics to general containers or algorithms; avoid overusing them in business logic.
10. **File Naming**: Use the `snake_case.go` format for filenames (e.g., `user_handler.go`). Avoid hyphens and choose words that are as short as possible. Suffix test files with `_test.go`.

## Review Checklist (High-Signal)

- **Errors**: Message format, wrap/unwrap, swallowing errors, discarding with `_`, retry boundaries.
- **Context**: Timeout/cancellation propagation, application to I/O boundaries, prohibition of struct holding.
- **Concurrency**: Goroutine leaks, close races, data races, appropriate use of `sync` vs channels.
- **API**: Package responsibility, use of `internal/`, export scope, interface granularity.
- **Data**: `nil` vs empty slices/maps, copy existence, proper assignment of `append` return values.
- **Performance**: Redundant allocations, `make`/`reserve` (specifying capacity), use of `fmt` or reflection in hot paths.

## Common Pitfalls

Refer to [Common Pitfalls](references/pitfalls.md) for detailed case studies.

### ❌ Bad Examples

```go
// NG: Goroutine leak (no way to stop)
func process() {
    go func() {
        for {
            doWork()  // Runs forever
        }
    }()
}

// NG: Holding context in a struct
type Client struct {
    ctx context.Context  // NG
}

// NG: Swallowing an error
data, _ := fetchData()  // No error check

// NG: Ignoring return value of append
slice := []int{1, 2, 3}
append(slice, 4)  // Meaningless without using the return value
```

### ✅ Good Examples

```go
// OK: Cancellable via context
func process(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return  // Exit upon cancellation
            default:
                doWork()
            }
        }
    }()
}

// OK: Context received as argument
func (c *Client) Fetch(ctx context.Context, id string) error {
    // ...
}

// OK: Always check errors
data, err := fetchData()
if err != nil {
    return fmt.Errorf("fetch failed: %w", err)
}

// OK: Assign return value of append
slice := []int{1, 2, 3}
slice = append(slice, 4)
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Errors are Values**: Confirm all `error` returns and wrap them appropriately. Do not ignore with `_`.
2. **Context as First Argument**: Receive `context.Context` in all functions involving I/O.
3. **Zero Goroutine Leaks**: Always establish termination conditions (Done channel or context) for started goroutines.
4. **Thin Interfaces**: Define small interfaces (1-3 methods) on the consuming side.
5. **Measure Before Optimizing**: Do not optimize based on guesswork. Provide evidence via `pprof` or `benchstat`.
6. **Mandatory gofmt**: Always format code with `gofmt` after generation.
7. **Table-Driven Logic**: Generate table-driven tests alongside logic implementation to cover boundary conditions for both happy and error paths.

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Anti-patterns and specific solutions.
- **[Check Script](scripts/check.sh)**: Automation for static analysis (`go vet`, `staticcheck`) and formatting checks.

## References

- [Effective Go](references/effective-go.md)
