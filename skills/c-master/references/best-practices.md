# C Best Practices & Idioms

- **Types**: Use `stdint.h` types (`int32_t`, `uint64_t`) for explicit sizing across platforms. Use `stdbool.h` for boolean logic.
- **Const Correctness**: Prefer `const` for pointer arguments that are input-only.
- **Initialization**: Always initialize variables. Use C99 designated initializers for structs (`.field = value`).
- **Scope**: Use `static` for functions and global variables limited to the file scope to prevent namespace pollution.
- **Macros**: Avoid function-like macros where `static inline` functions suffice. If macros are needed, wrap in `do { ... } while(0)` and parenthesize arguments.
- **Arrays**: Prefer array indexing or `memcpy` over raw pointer arithmetic for readability, unless strictly optimizing a hot loop.
