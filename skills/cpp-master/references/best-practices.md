# C++ Core Guidelines & Modern Idioms

## 1. Safety & Efficiency

- Use `std::unique_ptr` and `std::shared_ptr` for memory management. Avoid raw `new`/`delete`.
- Follow RAII (Resource Acquisition Is Initialization) strictly.
- Use `const` and `constexpr` everywhere possible.
- Prefer `std::string_view` and `std::span` for non-owning views.

## 2. Modern C++ (C++17/20/23)

- Use `auto` for type deduction when it improves readability.
- Prefer `using` over `typedef`.
- Use structured bindings `auto [a, b] = ...`.
- Utilize Concepts (C++20) for template constraints.

## 3. Performance

- Pass large objects by `const&`.
- Avoid unnecessary copies (Rule of Zero/Three/Five).
- Understand Move Semantics and `std::move`.
- Use `reserve()` for containers when the size is known.

## 4. Design Patterns in C++

- PIMPL (Pointer to Implementation) for ABI stability.
- CRTP (Curiously Recurring Template Pattern) for static polymorphism.
- Strategy pattern using `std::function` or lambdas.
