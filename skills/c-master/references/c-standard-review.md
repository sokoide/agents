# C Standard & Memory Safety Review Guide

## Memory Management

### Allocation & Deallocation

- **Matching**: Every `malloc`/`calloc`/`realloc` must have a corresponding `free`.
- **Zero-ing**: Use `calloc` or `memset` to avoid reading uninitialized memory.
- **Error Checking**: Always check if the returned pointer is `NULL`.
- **Dangling Pointers**: Set pointers to `NULL` after `free()` to prevent Use-After-Free.

### Buffer Safety

- **Avoid unsafe functions**: Use `snprintf` instead of `sprintf`, `fgets` instead of `gets`.
- **Boundary Checks**: Explicitly check array indices against size.
- **Null Termination**: Ensure strings are properly null-terminated, especially after `strncpy`.

## Undefined Behavior (UB) Avoidance

- **Strict Aliasing**: Do not access an object of one type through a pointer of a different type (except `char *`).
- **Integer Overflow**: Signed integer overflow is UB. Use unsigned for wrap-around arithmetic or check bounds.
- **Pointer Arithmetic**: Do not perform arithmetic that results in a pointer outside the allocated block (except one-past-the-end).
- **Sequence Points**: Avoid expressions like `i = i++` which have unsequenced side effects.

## Portability & Standards

- **Standard Headers**: Use `<stdint.h>` for fixed-width types (`int32_t`, `uint64_t`) and `<stdbool.h>` for `bool`.
- **Alignment**: Use `_Alignof` and `_Alignas` (C11) for manual alignment requirements.
- **Endianness**: Be explicit about byte order when dealing with network I/O or binary file formats.
- **Type Sizes**: Do not assume `int` is 32-bit or `long` is 64-bit. Use `sizeof`.

## Modern C Features (C11/C17/C23)

- **Static Assert**: Use `static_assert` for compile-time checks.
- **Generic Selection**: Use `_Generic` for type-based dispatch.
- **Atomic Operations**: Use `<stdatomic.h>` for lock-free concurrency.
- **Anonymous Structs/Unions**: Useful for cleaner data structures.
