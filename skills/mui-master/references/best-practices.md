# Material UI Best Practices (Expert Edition)

## 1. Advanced Styling Strategy

### `sx` Prop: Use Cases & Limits

- **Best for**: Rapid prototyping, spacing (m/p), and theme-aware one-offs.
- **Caution**: Inline objects in `sx` can cause unnecessary re-renders if they depend on unstable values.
- **Optimization**: Use the function form `sx={(theme) => ({ ... })}` when accessing the theme to ensure consistency.

### `styled()` API: The Professional Way

- Use for reusable UI atoms.
- **`shouldForwardProp`**: Always use this to prevent custom props from leaking to the DOM.
- **Stateless vs Stateful**: Prefer passing props to `styled` rather than using complex logic inside the component body for styling.

```tsx
const StyledButton = styled(Button, {
  shouldForwardProp: (prop) => prop !== 'isSpecial',
})<{ isSpecial?: boolean }>(({ theme, isSpecial }) => ({
  backgroundColor: isSpecial ? theme.palette.secondary.main : theme.palette.primary.main,
}));
```

## 2. Component Architecture

### The "Slot" Pattern

- For complex components, expose "slots" to allow users to override sub-components without breaking the internal logic. This mirrors MUI's own internal architecture.

### Compound Components

- Use React Context within a parent (e.g., `MyTable`) to share state with children (`MyTableHeader`, `MyTableRow`) for cleaner APIs.

### Layout Hierarchy

- **`Stack`**: 1D layout (gaps). Prefer over `Box` with margins.
- **`Grid2`**: 2D layout. Ensure you use the latest `Grid2` from `@mui/material`.
- **`Container`**: Only for the outermost page constraints.

## 3. Performance & Bundle Size

### Tree Shaking

- Avoid top-level `import { ... } from '@mui/material'`. While modern bundlers handle it, `import Button from '@mui/material/Button'` is safer in some environments.

### Reducing DOM Depth

- Avoid "Box Soup". Use `component` prop to merge elements: `<Typography component="div" ... />` instead of `<div><Typography ... /></div>`.

## 4. Next.js & RSC (App Router)

- **Client Components**: Mark only the leaf nodes as `'use client'` if they use MUI (since most MUI components use Context/Hooks).
- **Style Injection**: Ensure `@mui/material-nextjs` is used for proper SSR style injection to avoid FOUC (Flash of Unstyled Content).

## 5. Accessibility (a11y)

- **Contrast**: Use `theme.palette.getContrastText(color)` to dynamically determine text color.
- **Focus**: Never remove `outline: none` without providing a `theme.focusVisible` alternative.
- **ARIA**: Use `IconButton` with `aria-label` and `Tooltip` for clarity.
