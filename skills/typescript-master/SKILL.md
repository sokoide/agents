---
name: typescript-master
description: >
    High-fidelity TypeScript architect. Expert in TS 5.x specs, structural typing,
    performance optimization, and runtime semantics. Use for:
    (1) Complex type engineering, sound architecture design.
    (2) Debugging deep-level type issues (conditional/mapped/variance).
    (3) Safe boundary data handling (API/JSON/DB with type erasure awareness).
    (4) TS implementation/improvement/review (type design, tsconfig, runtime pitfalls).
---

# TypeScript Master

This skill provides expert-level TypeScript guidance for complex type engineering, sound architecture design, and debugging deep-level type issues.

## Related Tools

This skill uses: Bash (for npm/yarn/pnpm/tsc commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- TS/Node version, execution environment (Node/Browser/React), module format (ESM/CJS).
- `tsconfig` strictness, linting (ESLint)/formatting (Prettier), and whether type checks run in CI.
- Validation policy for external inputs (e.g., Zod) and error representation (Result/throw).

## Output Contract (How to Respond)

- **Review**: Classify points as "Soundness / Runtime / API / Performance / DX," prioritizing evaluations of `any`, assertions, and non-nullability.
- **Proposed Correction**: First solidify type boundaries (external inputs, module exports), then simplify internal type inference and representation.
- **Runtime**: For proposals that change the behavior of generated JS, always include specific examples and risks (compatibility/bundling).

## Design & Coding Rules (Expert Defaults)

1. **No `any` by default**: Treat unknown values as `unknown` and narrow them down using guards or validation.
2. **Prefer Narrowing Over Assertions**: Use `as` only as a last resort; prioritize `satisfies` and user-defined type guards.
3. **Type Erasure Awareness**: Remember that types disappear at runtime. Assume runtime validation (e.g., Zod) at boundaries.
4. **Export Surface Discipline**: Stabilize public types and design module boundaries to prevent internal types from leaking.
5. **Prefer Union Over Enum**: Avoid TypeScript-specific `enum`s; use Union types with `as const` objects instead.
6. **Monorepo Strategy**: In large-scale projects, leverage Project References (`tsc --build`) to shorten build times.

## Review Checklist (High-Signal)

- **Soundness**: Misuse or localization of `any`, excessive `as`, `!`, and `// @ts-ignore`.
- **Runtime Boundary**: Validation of external inputs, exception/Result boundaries, and JSON type safety.
- **Types**: Complexity of conditional types, breakdown of inference, and unintended emergence of `never`.
- **Config**: Adoption of `strict` mode, `noUncheckedIndexedAccess`, etc., and the impact of `skipLibCheck`.
- **Performance**: Type calculation costs (IDE lag), build times, and bundle sizes (use type-only imports).

## Common Pitfalls

### ❌ Bad Examples

```typescript
// NG: Overuse of any
function process(data: any): any {
    // Zero type safety
    return data.whatever; // Potential runtime error
}

// NG: Overuse of assertions
const value = data as string; // No validation

// NG: Ignoring null with !
const user = users.find((u) => u.id === id)!; // Possible undefined
```

### ✅ Good Examples

```typescript
// OK: Narrowing with unknown and type guards
function process(data: unknown): string {
    if (typeof data === 'string') {
        return data;  // Type is narrowed
    }
    throw new Error('Invalid data');
}

// OK: Safe validation with type guards
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

// OK: Optional chaining and nullish coalescing
const user = users.find(u => u.id === id);
const name = user?.name ?? 'Unknown';

// OK: Runtime validation with Zod
import { z } from 'zod';
const ConfigSchema = z.object({ ... });
const config = ConfigSchema.parse(JSON.parse(text));
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Prohibit any, use unknown**: Treat mystery values as `unknown` and narrow them with type guards.
2. **Mandatory Runtime Validation**: Validate external inputs (API/JSON) using Zod or io-ts.
3. **satisfies Over as**: Minimize type assertions and maintain type inference with `satisfies`.
4. **Enable strict**: Set `strict: true` in `tsconfig.json`.
5. **Stabilize Public Types**: Design boundaries to prevent internal types from leaking out of modules.
6. **Type-only Imports**: Explicitly use `import type` for type-only imports to reduce bundle size.
7. **Const Assertions**: Leverage `as const` for literal type inference and prioritize object maps over `enum`s.

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Common mistakes and best practices.
- **[Check Script](scripts/check.sh)**: Automated checks (`tsc`, `eslint`).

## References

- [Enterprise Best Practices](references/best-practices.md)
- [tsconfig Guide](references/tsconfig-guide.md)
- [Advanced Types](references/advanced-types.md)
