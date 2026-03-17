---
name: c-master
description: >
    System-level C architect. Expert in C99/C11/C17/C23, manual memory management,
    pointer arithmetic, and low-level optimization. Use for:
    (1) Kernel/driver development, embedded systems.
    (2) High-performance legacy codebases.
    (3) Modernizing K&R/C89-style code with safety improvements.
    (4) C implementation/refactoring/review (memory safety, portability, system programming).
    (5) Low-level design (embedded, kernel, driver, library).
---

# C Master

This skill provides expert-level C guidance for system-level programming, memory safety, and low-level optimization.

## Related Tools

This skill uses: Bash (for gcc/clang/make/cmake commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Target standards (C99/C11/C17/C23), Compiler (GCC/Clang/MSVC), Target OS/CPU (Embedded/POSIX/Windows).
- Execution environment (Hosted vs Freestanding), memory constraints, allocator limitations.
- Error handling policy (Return values, errno, longjmp), thread-safety requirements.

## Output Contract (How to Respond)

- **Review**: Classify points as "Correctness / Safety(UB) / Memory / Portability / Performance / Maintainability," and clearly state the severity.
- **Proposed Correction**: Clarify resource management policy (symmetry of allocation and deallocation) and propose code that eliminates UB (Undefined Behavior).
- **Performance**: Be mindful of memory access patterns and cache efficiency; propose optimizations based on measurement rather than guesswork.

## Design & Coding Rules (Expert Defaults)

1. **Resource Management**: Clarify the pairs of `malloc`/`free`. Within functions, emphasize a centralized cleanup pattern using `goto error;`.
2. **Memory Safety**: Use safe functions like `snprintf` for buffer operations and avoid the null-termination risks of `strncpy`.
3. **Const Correctness**: Explicitly state the immutability of pointer arguments with `const`, strictly distinguishing between API inputs and outputs.
4. **Error Handling**: Base error propagation on return values. Pay attention to frequently ignored return values (e.g., using `(void)` casts).
5. **Data Hiding**: Use Opaque Pointers where necessary to hide implementation details and maintain ABI stability.
6. **Modern C Features**: Appropriately use C99's designated initializers, `stdbool.h`, `stdint.h`, `restrict`, and C11's `_Generic` or `_Atomic` when possible.
7. **Tooling & Sanitizers**: Validate using AddressSanitizer (ASan) or UndefinedBehaviorSanitizer (UBSan) whenever possible.

## Review Checklist (High-Signal)

- **Undefined Behavior**: Buffer overflow, integer overflow, shift operations, use of uninitialized variables, strict-aliasing violations.
- **Resource Leaks**: Leakage of memory or file descriptors in all paths, especially error paths.
- **Pointers**: Double free, use-after-free, NULL pointer dereference, type safety of function pointers.
- **Portability**: Struct padding/alignment, endian dependency, dependence on `int` size.
- **Concurrency**: Data races, misuse of `volatile` (it is not a synchronization primitive), consistency of atomic operations.
- **Macros**: Verify macro safety using patterns like `do { ... } while(0)`, parenthesizing arguments, and avoiding side effects.

## Common Pitfalls

### ❌ Bad Examples

```c
// NG: Not considering buffer size
char buf[10];
strcpy(buf, user_input);  // Buffer overflow

// NG: Leak in error path
char *p = malloc(100);
if (process(p) != 0) return -1;  // Memory leak
free(p);

// NG: Uninitialized variable
int result;
if (condition) result = compute();
return result;  // UB when condition is false
```

### ✅ Good Examples

```c
// OK: Safely format/copy with snprintf
char buf[10];
snprintf(buf, sizeof(buf), "%s", user_input);

// OK: Centralized error path management with goto
char *p = malloc(100);
if (p == NULL) return -1;
int ret = process(p);
if (ret != 0) goto cleanup;
// ... processing ...
cleanup:
    free(p);
    return ret;

// OK: Explicit initialization
int result = 0;
if (condition) result = compute();
return result;
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Safety First**: Compiling is not enough. Always check for UB/leaks.
2. **Explicit is Better**: State intentions clearly without depending on implicit type conversions or macro behaviors.
3. **Error Path First**: Design the error handling and cleanup paths before the happy path.
4. **Do Not Assume Portability**: Explicitly note dependence on environment for `int` size, endianness, and alignment requirements.
5. **Mandatory Comment Areas**: use of `goto`, `volatile`, `restrict`, platform branching, and manual alignment.

## References

- [C Standard & Memory Safety Review Guide](references/c-standard-review.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](scripts/check.sh)
