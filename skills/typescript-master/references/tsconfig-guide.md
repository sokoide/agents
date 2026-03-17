# Advanced tsconfig Guide

Type safety and developer experience (DX) in TypeScript are largely determined by `tsconfig.json`. This guide summarizes recommendations prioritizing "robustness."

## 1) Strict Type Checking (The Strict Standard)

`strict: true` should be the foundation.

Additional flags to consider:

- **`noUncheckedIndexedAccess`**: Represent in the type system that `obj[key]` can be `undefined`, reducing runtime `cannot read property ...` errors.
- **`exactOptionalPropertyTypes`**: Enforce stricter assignment of `undefined` to optional properties to prevent unintended states.
- **`noImplicitReturns`**: Ensure that all branches return a value (particularly effective for APIs).

## 2) Module Resolution (Node/Bundler Prerequisites)

- **`moduleResolution: "NodeNext"`**: Align with Node's ESM resolution (especially critical for mixed CJS/ESM projects).
- **`verbatimModuleSyntax`**: Clarify the semantics of imports and exports to increase the predictability of the output JS.
- **`isolatedModules`**: Essential when assuming single-file transpilation by tools like Babel or SWC (Detects transpilation that depends on types).

## 3) App vs. Library (Distinguishing Public Assets)

### For Apps (The Executable Side)

- Use `noEmit: true` for type-checking only (leaving the build to a bundler).
- Align `lib` and `jsx` with your runtime environment (e.g., DOM, React, Node).

### For Libraries (The Distributable Side)

- Consider `declaration: true` and `declarationMap: true` (Decouple type definition distribution and improve the debugging experience).
- Combine with `stripInternal` and `exports` design to prevent the leakage of public types.

## 4) Build Performance

- **`incremental: true`**: Accelerate recompilation by generating `.tsbuildinfo`.
- **`skipLibCheck: true`**: A trade-off prioritizing speed. Consider setting to `false` in CI to detect type breakages in dependencies early.

## 5) Common Pitfalls

- Carelessly expanding `types` can cause global pollution and type collisions.
- While `paths` are convenient, things will break if they do not match runtime resolution (Node/bundler).
