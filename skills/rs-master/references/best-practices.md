# Rust Safety & Performance Idioms

## 1. Ownership & Borrowing

- Leverage the Borrow Checker to ensure memory safety without a GC.
- Prefer borrowing (`&T`, `&mut T`) over cloning (`.clone()`) unless ownership is necessary.
- Use `Copy` types for small, stack-allocated data.
- Minimize `RefCell` and `Mutex` usage by designing clear ownership boundaries.

## 2. Type System & Pattern Matching

- Use `Option<T>` and `Result<T, E>` for error handling. Never use `unwrap()` in production code.
- Exhaustive `match` and `if let` for clean control flow.
- Use the Newtype pattern for type safety and domain modeling.
- Implement standard traits (`Debug`, `Clone`, `Default`, `PartialEq`, etc.) using `#[derive]`.

## 3. Concurrency

- `Send` and `Sync` traits ensure thread safety at compile-time.
- Prefer channels (`std::sync::mpsc` or `crossbeam`) for communication.
- Use `Arc<Mutex<T>>` or `Arc<RwLock<T>>` only when shared mutable state is unavoidable.
- Utilize `tokio` or `async-std` for efficient asynchronous I/O.

## 4. Modern Rust (Idioms)

- Use `Iterators` and functional patterns (`map`, `filter`, `collect`) for expressive code.
- Leverage `Zero-Sized Types` (ZST) for state-machine enforcement.
- Use `Traits` for polymorphism and abstraction.
- Prefer `Cargo.toml` workspace for multi-crate projects.
