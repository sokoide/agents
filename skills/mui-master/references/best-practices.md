# Material UI Best Practices (Expert Edition)

## 1. Advanced Styling Strategy

### `sx` Prop: Use Cases & Limits

- **Best for**: Rapid prototyping, spacing (m/p), and theme-aware one-offs.
- **Caution**: Generating an inline object for `sx={{ ... }}` on every render prevents prop comparison and becomes a cause for re-rendering (especially in memoized components).
- **Optimization**: Move heavy or frequently changing `sx` styles to `styled()` or CSS variables. Use `useMemo` to stabilize `sx` if necessary.

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

### `slots` / `slotProps` (Slot Pattern)

- Many MUI components provide `slots`/`slotProps`. Use these first for internal element replacement or prop injection to avoid adding unnecessary wrappers.

### Compound Components

- Use React Context within a parent (e.g., `MyTable`) to share state with children (e.g., `MyTableHeader`, `MyTableRow`) for cleaner APIs.

### Layout Hierarchy

- **`Stack`**: 1D layout (gaps). Prefer over `Box` with margins.
- **Grid**: 2D layout. Standardize based on the project's MUI version, as import paths and APIs for `Grid`/`Grid2` differ between v5 and v6.
- **`Container`**: Only for the outermost page constraints.

## 3. Performance & Bundle Size

### Tree Shaking

- Generally, this can be left to the bundler, but tree-shaking might be less effective depending on the environment/configuration.
- Consider deep imports (e.g., `@mui/material/Button`) only when symptoms like bundle bloat occur.

### Reducing DOM Depth

- Avoid "Box Soup." Use the `component` prop to merge elements: e.g., `<Typography component="div" ... />` instead of `<div><Typography ... /></div>`.

## 4. Next.js & RSC (App Router)

- **Client Components**: Most of MUI uses Hooks/Context. Keep `'use client'` within the "smallest unit of components using MUI" to avoid over-expanding boundaries.
- **Style Injection**: Prioritize official Next.js integration patterns (e.g., `@mui/material-nextjs`) in SSR to avoid FOUC (Flash of Unstyled Content) and hydration mismatches.

## 5. Accessibility (a11y)

- **Contrast**: Use `theme.palette.getContrastText(color)` to dynamically determine text color.
- **Focus**: `outline: none` is prohibited in principle. Maintain visible focus representations based on `:focus-visible` or MUI's focus-visible class.
- **ARIA**: Use `IconButton` with `aria-label` and `Tooltip` for clarity.
