# Enterprise Best Practices

## Anti-patterns and Workarounds

- **Avoid Enums:**
  Recommend `const object` + `Union Type`. Prioritize bundle size reduction, tree-shaking friendliness, and consistency with JS semantics.
- **Restrict Non-null Assertions (`!`):**
  Use `Optional Chaining` (`?.`) or explicit guard clauses for `null` checks as much as possible.
- **Prohibit `any` with rare exceptions:**
  Use `unknown` for ambiguous data like external API responses, and solidify types after validation (e.g., Zod).

## Performance and Optimization

- **Type-only Imports (`import type`):**
  Clarify runtime dependencies and improve dead-code elimination during builds.
- **Module Boundary Design:**
  Be mindful of the `package.json` `exports` field and ensure encapsulation such that internal types do not leak externally.

## React Patterns (TS-specific)

- **Component Props:** Use type aliases instead of interfaces and apply `Readonly` to prevent unintended side effects.
- **Generic Components:** Design components with appropriate propagation of type parameters for high reusability.

## Runtime Considerations

- **ES Private (#) vs TS private:**
  Consider the ES `#` syntax when true encapsulation is required; use TS's `private` if mere access restriction is sufficient (Be mindful of the performance impact).
- **Type Erasure:**
  Remember that TypeScript types are stripped away during transpilation; use classes or objects if you need features that exist at runtime.
