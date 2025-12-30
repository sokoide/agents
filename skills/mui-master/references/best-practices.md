# Material UI Best Practices (Expert Edition)

## 1. Advanced Styling Strategy

### `sx` Prop: Use Cases & Limits

- **Best for**: Rapid prototyping, spacing (m/p), and theme-aware one-offs.
- **Caution**: `sx={{ ... }}` の inline object が毎 render 生成されると、prop 比較が効かず再レンダリング要因になる（特にメモ化コンポーネント）。
- **Optimization**: 重い/頻繁に変わる `sx` は `styled()` か CSS 変数へ寄せる。必要なら `useMemo` で `sx` を安定化する。

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

- 多くの MUI コンポーネントは `slots`/`slotProps` を提供する。まずこれで内部要素差し替え/props 注入を行い、不要な wrapper を増やさない。

### Compound Components

- Use React Context within a parent (e.g., `MyTable`) to share state with children (`MyTableHeader`, `MyTableRow`) for cleaner APIs.

### Layout Hierarchy

- **`Stack`**: 1D layout (gaps). Prefer over `Box` with margins.
- **Grid**: 2D layout。`Grid`/`Grid2` の import path と API は v5/v6 で差が出るため、プロジェクトの MUI バージョンに合わせて統一する。
- **`Container`**: Only for the outermost page constraints.

## 3. Performance & Bundle Size

### Tree Shaking

- 基本は bundler に任せてよいが、環境/設定次第で tree-shaking が効きにくいことがある。
- 症状（バンドル肥大）がある場合に限り、deep import（例: `@mui/material/Button`）を検討する。

### Reducing DOM Depth

- Avoid "Box Soup". Use `component` prop to merge elements: `<Typography component="div" ... />` instead of `<div><Typography ... /></div>`.

## 4. Next.js & RSC (App Router)

- **Client Components**: MUI は多くが Hook/Context を使う。`'use client'` は「MUI を使うコンポーネントの最小単位」に閉じて境界を増やしすぎない。
- **Style Injection**: SSR では公式の Next.js 統合パターン（`@mui/material-nextjs` 等）を優先し、FOUC と hydration mismatch を避ける。

## 5. Accessibility (a11y)

- **Contrast**: Use `theme.palette.getContrastText(color)` to dynamically determine text color.
- **Focus**: `outline: none` は原則禁止。`:focus-visible` か MUI の focus-visible クラスを前提に、視認できるフォーカス表現を維持する。
- **ARIA**: Use `IconButton` with `aria-label` and `Tooltip` for clarity.
