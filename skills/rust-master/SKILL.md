---
name: rust-master
description: >
    High-integrity Rust architect. Master of ownership, borrowing, lifetimes, and zero-cost abstractions.
    Use for:
    (1) Rust implementation, improvement, and review (ownership, lifetimes, unsafe, concurrency, API design).
    (2) Designing high-reliability services/tools involving async/await.
    (3) Migration from C/C++ or refactoring requiring balance of safety and performance.
    (4) Building memory-safe systems and reliable concurrent applications.
---

# Rust Master

This skill provides expert-level Rust guidance for building memory-safe systems, high-performance web services, and reliable concurrent applications.

## Related Tools

This skill uses: Bash (for cargo/build commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Edition (e.g., 2021/2024) and MSRV, target (std/no_std).
- Async runtime (e.g., Tokio) and I/O model, error representation policy (Public API vs Internal).
- Tolerance for `unsafe` (Zero / Limited / Allowed) and performance constraints (Allocation, copying, locks).

## Output Contract (How to Respond)

- **Review**: Classify points as "Safety / Correctness / API / Async / Concurrency / Performance," and provide explanations by diagramming ownership and borrowing models.
- **Proposed Correction**: Prioritize relocating ownership, shortening borrow lifetimes, and type design (newtype/enum) before increasing `clone()` calls.
- **unsafe**: Use only when necessity can be proven. Always include invariants (safety conditions) and methods for testing/debugging.

## Design & Coding Rules (Expert Defaults)

1. **Make Illegal States Unrepresentable**: Eliminate invalid states using `enum` and types.
2. **No Panics in Libraries**: Avoid `unwrap/expect` in public APIs; instead, return `Result` (Consider panics only at application boundaries).
3. **Error Boundaries**: Use distinct error strategies: stable error types (e.g., `thiserror`) for public APIs and flexible ones (e.g., `anyhow`) for internal application logic.
4. **Async Correctness**: Constantly check for `Send`/`Sync` compliance, cancellation, backpressure, and the intrusion of blocking calls.
5. **Observability**: In async environments, use `tracing` instead of `log` to track context with spans and structured logs.
6. **Clippy Compliance**: Adhere to `cargo clippy`; if ignoring a warning, add a comment explaining the reason with `#[allow(...)]`.
7. **Typestate Pattern**: For complex state transitions, consider the Typestate Pattern to enforce ordering at compile time.

## Review Checklist (High-Signal)

- **Ownership**: Is the borrowing scope minimal? Are references held too long? Is there overuse of `Rc/Arc/Mutex`?
- **Errors**: Does the `Result` type carry meaning? Check the boundary of `?` and chains of `From`/`source`.
- **Async**: Order of `await`s, cancellation with `select!`, collection of `spawn` tasks, and blocking I/O.
- **unsafe**: Boundary minimization, documentation of invariants, and safe wrappers that encapsulate unsafe code.
- **Performance**: Redundant clones, allocations, `Vec` reallocations, and memory layout.
- **Tooling**: Are pointers addressable via `rustfmt`/`clippy`? Is the rationale for suppressing lints valid?

## Common Pitfalls

### ❌ Bad Examples

```rust
// NG: Redundant clone
fn process(data: Vec<String>) -> Vec<String> {
    data.clone()  // Cloning despite having ownership
}

// NG: Overuse of unwrap
let value = map.get("key").unwrap();  // Panic

// NG: Multiple mutable references
let mut v = vec![1, 2, 3];
let r1 = &mut v;
let r2 = &mut v;  // Compile error

// NG: Lifetime misuse
fn longest(x: &str, y: &str) -> &str {  // Compile error
    if x.len() > y.len() { x } else { y }
}
```

### ✅ Good Examples

```rust
// OK: Move ownership
fn process(data: Vec<String>) -> Vec<String> {
    data  // Return as is
}

// OK: Handle safely with Result/Option
let value = map.get("key").ok_or("not found")?;

// OK: Separate borrowing scopes
let mut v = vec![1, 2, 3];
{
    let r1 = &mut v;
    r1.push(4);
}  // r1 scope ends
let r2 = &mut v;

// OK: Explicit lifetimes
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Eliminate Invalid States with Types**: Represent state transitions with `enum` to exclude illegal combinations at compile time.
2. **Avoid unwrap/expect**: Return `Result` in libraries and propagate with `?` in apps.
3. **Clone as a Last Resort**: First consider if borrowing can solve the issue or if ownership design can be adjusted.
4. **Explicit Error Types**: Use `thiserror` for custom error types in public APIs and `anyhow` internally.
5. **Be Mindful of Send/Sync in Async**: Do not hold `!Send` data across `.await` points.
6. **Minimize unsafe**: Document invariants in comments and encapsulate with safe wrappers.
7. **Iterators over Loops**: Prioritize iterator chains over index access to favor boundary check avoidance and readability.

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Common mistakes and best practices.
- **[Check Script](scripts/check.sh)**: Automated checks (`cargo fmt`, `check`, `clippy`).

## References

- [Rust API Guidelines](references/rust-api-guidelines-summary.md)
