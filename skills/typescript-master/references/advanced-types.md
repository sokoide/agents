# Advanced TypeScript Engineering

## Type-Level Logic

- **`satisfies` Operator:**
  Validate that a value satisfies a specific type without fixing (upcasting) the type. Ideal for ensuring type safety while preserving inferred literal types.
- **Variance:**
  Understand `In/Out` (contravariance/covariance/bivariance/invariance) in generics, particularly to ensure type safety in higher-order functions and class inheritance.
- **`const` Type Parameters:**
  Allow literals passed to functions to be inferred as constants without needing `as const` on the caller side.

## Structural Typing and Soundness

- **Nominal Identity (Branding):**
  Use `Branding` (e.g., `type ID = string & { __brand: "User" }`) where necessary to distinguish semantically different types that are structurally identical, preventing misuse at the type level.
- **Exhaustiveness Checks:**
  Enforce exhaustiveness in `switch` or `if` statements using the `never` type to detect bugs during future type extensions at compile time.

## Complex Type Transformations

- **Mapped Types:** Perform dynamic key transformations using `as` clauses (Key Remapping).
- **Conditional Types:** Extract types (e.g., Promise resolution types, function argument types) using `infer`.
- **Template Literal Types:** Define types through string pattern matching and concatenation.
