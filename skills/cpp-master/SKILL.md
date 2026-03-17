---
name: cpp-master
description: >
    High-performance C++ architect. Expert in C++11/14/17/20/23, RAII, memory management,
    and Template Meta-programming. Use for:
    (1) Systems programming, low-latency applications.
    (2) Modernizing legacy C++ codebases with modern standards.
    (3) Implementation/refactoring/review (ownership, exception safety, low latency).
    (4) Template/generic design (Concepts, error readability).
---

# C++ Master

This skill provides expert-level C++ guidance for systems programming, low-latency applications, and modernizing legacy C++ codebases.

## Related Tools

This skill uses: Bash (for g++/clang++/cmake commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Target standards (C++17/20/23), Compiler/Standard library, Target OS/CPU, Exception policy (Enabled/Disabled).
- Performance constraints (Latency/Throughput, allocation-prohibited sections, real-time requirements).
- Stability requirements for ABI/Public API, Build constraints (Header dependencies, compilation time).

## Output Contract (How to Respond)

- **Review**: Classify points as "Correctness / Safety(UB) / Concurrency / API / Performance / Maintainability," and clearly state the severity.
- **Proposed Correction**: Fix the ownership/lifetime policy first, then propose incremental refactoring with minimal diffs.
- **Performance**: Do not state conclusions based on guesswork. For optimizations assuming hit paths, include a "measurement plan (benchmark/profile)."

## Design & Coding Rules (Expert Defaults)

1. **RAII + Rule of Zero**: Represent owned resources as types; do not write `new`/`delete` directly.
2. **Ownership is Explicit**:
   - Single ownership: `std::unique_ptr`
   - Shared ownership: `std::shared_ptr` (Only when necessity can be justified)
   - Non-owning views: `T&` / `T*` (When representing nullability) / `std::span` / `std::string_view`
3. **Exception Safety**: If using exceptions, specify the guarantee (basic/strong/nothrow) and do not throw in destructors. Add `noexcept` where appropriate.
4. **Zero-cost Abstractions**: Evaluate trade-offs (readability, binary size, branch prediction) including templates/`std::variant`/`std::function` over virtual functions.
5. **Performance Hygiene**: Avoid redundant copies/allocations (`reserve`, move, `emplace`). However, optimizations that compromise readability should only be done after measurement.
6. **No C-style Casts**: Strictly adhere to C++ casts like `static_cast` to make intentions explicit.
7. **Header Hygiene**: Follow Include What You Use (IWYU) and leverage forward declarations to reduce build times.

## Review Checklist (High-Signal)

- **Undefined Behavior**: Dangling references, OOB (Out-Of-Bounds), uninitialized variables, strict-aliasing, data races.
- **Lifetime/Ownership**: Is the owner unique? Is the deallocation responsibility clear? Are returned references/pointers safe?
- **Move/Copy**: Rules (Zero/Three/Five), misuse of `std::move`, code assuming copy elision.
- **API**: Choice between value/reference/pointer, representation of nullability, `const` correctness, readability of overloads/templates.
- **Exceptions**: Exception boundaries, `noexcept`, resource leaks, areas needing strong guarantees.
- **Concurrency**: Lock granularity, atomic memory ordering, isolation of shared mutable state.
- **Build/ODR**: Header bloat, circular dependencies, `inline`/template definition placement, applicability of PIMPL.

## Common Pitfalls

### ❌ Bad Examples

```cpp
// NG: Ownership unclear with raw pointer
Widget* makeWidget() { return new Widget(); }  // Who will delete it?

// NG: Misuse of std::move
std::string s = "hello";
process(std::move(s));
std::cout << s;  // s is valid but in an unspecified state (dangerous, though not UB)

// NG: Dangling reference
const std::string& getName() {
    std::string name = "temp";
    return name;  // Returning a reference to a local variable
}

// NG: Storm of copies
std::vector<std::string> filter(std::vector<std::string> items) {  // Copy
    std::vector<std::string> result;  // No reserve
    for (auto item : items) {  // Another copy
        if (predicate(item)) result.push_back(item);  // Yet another copy
    }
    return result;
}
```

### ✅ Good Examples

```cpp
// OK: Explicit ownership
std::unique_ptr<Widget> makeWidget() { return std::make_unique<Widget>(); }

// OK: Do not use after move, or check state
std::string s = "hello";
process(std::move(s));
// Do not use s, or re-initialize with s.clear(), etc.

// OK: Return by value or return views
std::string getName() { return "temp"; }  // RVO/NRVO
std::string_view getNameView() { return "literal"; }  // Literal only

// OK: Receive by reference, reserve, emplace
std::vector<std::string> filter(const std::vector<std::string>& items) {
    std::vector<std::string> result;
    result.reserve(items.size());  // Assume worst case
    for (const auto& item : items) {  // Reference
        if (predicate(item)) result.push_back(item);
    }
    return result;  // RVO
}
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Ownership First**: Decide "who owns it" before writing code. Use `unique_ptr` if in doubt.
2. **Rule of Zero Principle**: Avoid writing special member functions. Leave resource management to RAII types.
3. **Const Correctness**: Specify `const` eligibility for all function arguments and member functions.
4. **Reference vs Pointer**: Use `T*` if nullable, `T&` if non-null. After C++20, consider `std::optional<std::reference_wrapper<T>>` as well.
5. **Declare Exception Safety**: Explicitly state which guarantee (basic/strong/nothrow) is provided, especially in public APIs.
6. **Prevent Template Errors**: Indicate constraints early using `static_assert` or Concepts.
7. **Modern Loops**: For C++20, prefer `<ranges>` and pipelines. Otherwise, use range-based for loops.

## References

- [C++ Core Guidelines](references/cpp-core-guidelines-summary.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](scripts/check.sh)
