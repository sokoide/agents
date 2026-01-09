# SEI CERT C Coding Standard Summary

- **PRE (Preprocessor)**: Avoid unsafe macros; ensure header guards.
- **DCL (Declarations)**: Declare objects with appropriate storage durations; limit scope.
- **EXP (Expressions)**: Ensure execution order; avoid side effects in `sizeof` or macro arguments.
- **INT (Integers)**: Handle integer overflow, wraparound, and truncation explicitly.
- **FLP (Floating Point)**: Prevent floating-point exceptions and precision errors.
- **ARR (Arrays)**: guarantee bounds checking; avoid decay of array pointers where size is needed.
- **STR (Strings)**: Guarantee null-termination; use safer alternatives to `strcpy`/`strcat`.
- **MEM (Memory)**: Detect and prevent leaks, double-frees, and use-after-free errors.
- **FIO (File I/O)**: Check file operation results; close files properly.
- **CON (Concurrency)**: Prevent data races; use atomics or mutexes correctly.
