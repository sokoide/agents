# Rust Common Pitfalls & Best Practices

## 1. `unwrap()` in Production

- **Problem**: `unwrap()` causes panics on failure, effectively crashing the thread/program.
- **Fix**: Use `match`, `if let`, or `?` operator (error propagation). Only use `unwrap()` in tests or when mathematically impossible to fail (and document why with `expect()`).

## 2. Excessive `clone()`

- **Problem**: Calling `.clone()` everywhere to satisfy the borrow checker.
- **Fix**: Use references (`&T`) where possible. Use `Arc<T>` or `Rc<T>` for shared ownership if lifetime management is too complex.

## 3. Lifetime Misconceptions

- **Problem**: Trying to return a reference to a stack-allocated variable.
- **Fix**: Return an owned type (`String` instead of `&str`) or pass the output buffer as an argument.

## 4. Interior Mutability Abuse

- **Problem**: Overusing `RefCell<T>` or `Mutex<T>` to bypass borrow rules.
- **Fix**: Re-architect to respect ownership. Use channels for communication between threads instead of shared state when possible.

## 5. `match` Exhaustiveness

- **Guideline**: When matching on enums from external crates, use `_ =>` only if you really want to ignore future variants. Otherwise, handle all known cases to catch breaking changes.

## 6. String vs &str

- **Guideline**:
- Function arguments: Use `&str` (allows passing `String` and `&str`).
- Struct fields: Use `String` (owns the data).
- Return values: Use `String` (transfer ownership).
