---
name: mui-master
description: >
    Expert-level Material UI (MUI) architect. Master of component composition, styling
    (sx/styled), theme + TypeScript module augmentation, performance optimization, and
    Next.js (SSR/RSC) integration. Use for:
    (1) Building scalable design systems (Theme, TypeScript Module Augmentation).
    (2) High-performance MUI apps.
    (3) Advanced customization (slots, theme variants).
    (4) Next.js integration (SSR/RSC, hydration).
    (5) MUI component implementation/customization.
---

# MUI Master

This skill provides expert-level Material UI (MUI) guidance for building scalable design systems and high-performance MUI apps.

## Related Tools

This skill uses: Bash (for npm/yarn/pnx commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- MUI version (v5 / v6), React/Next.js version and routing (App/Pages Router).
- Next.js: SSR availability, RSC boundaries (placement of `'use client'`), CSS-in-JS injection method.
- Styling policy (priority on `sx` / priority on `styled` / centralized theme `variants`/`styleOverrides` / combined with Tailwind, etc.).
- TypeScript strictness level, particularly requirements for Theme extensions (Module Augmentation).
- Synchronization requirements with design tokens (e.g., Figma) and presence of multiple themes (Dark/Light/Custom).

## Output Contract (How to Respond)

- **Implementation/Review**: Classify points as "Composition / Styling / Theme+TS / Next.js(SSR/RSC) / Performance / Accessibility," providing brief rationale.
- **Design System**: Present a design that tracks dependencies from token → theme → component override, rather than just individual components.
- **Performance**: Be mindful of rendering costs and bundle sizes; avoid unnecessary DOM depth, unstable `sx` usage, and excessive Context re-renders.

## Design & Coding Rules (Expert Defaults)

1. **Theme-First Approach**: Avoid hard-coding; utilize `theme.spacing/palette/typography/breakpoints` thoroughly.
2. **Type-Safe Theme**: Define theme extensions with Module Augmentation and type `sx` using `Theme`.
3. **Composition Over Wrappers**: Use existing components' `slots`/`slotProps` and `component` first; add `styled()` or custom wrappers only when necessary.
4. **Stable Styling**: Limit `sx` usage (including inline object generation) tied to frequently changing values; prefer `styled()` + props, CSS variables, or theme `variants`.
5. **Pigment CSS Ready**: Be mindful of static style extraction to reduce runtime costs and prepare for future Pigment CSS migration.
6. **Grid v2**: Use the enhanced `Grid2` (`@mui/material/Grid2`) for layouts instead of the traditional `Grid`.
7. **Loading Strategy**: Place `<Skeleton />` during data fetching to prevent Cumulative Layout Shift (CLS).

## Review Checklist (High-Signal)

- **Theming**: Are values scattered without regard for semantic colors/typography/spacing?
- **TypeScript**: Is theme extension type-safe? Are `Theme` assumptions in `sx` intact?
- **Next.js**: Are SSR/RSC boundaries compromised? Any signs of FOUC (Flash of Unstyled Content) or hydration mismatches?
- **Efficiency**: Is DOM depth unnecessarily increased (e.g., overuse of Box/Stack/Container)?
- **Consistency**: Does the use of `sx`/`styled`/`styleOverrides`/`variants` align with team conventions?
- **Accessibility**: Contrast, `:focus-visible`, `aria-*`, labels/descriptions, and keyboard interaction.

## Common Pitfalls

### ❌ Bad Examples

```tsx
// NG: Hard-coded values
<Box sx={{ padding: "16px", color: "#1976d2" }}>Content</Box>;

// NG: Generating sx object on every render
function Component({ isActive }: Props) {
    return (
        <Button sx={{ bgcolor: isActive ? "primary.main" : "grey.500" }}>
        </Button>
    );
}

// NG: Unnecessary Box nesting
<Box>
    <Box>
        <Box>
            <Typography>Deep nesting</Typography>
        </Box>
    </Box>
</Box>;

// NG: No type extension for Theme
const theme = createTheme({
    custom: { brand: "#123456" }, // Ignores type error
});
```

### ✅ Good Examples

```tsx
// OK: Using the Theme
<Box sx={{ p: 2, color: "primary.main" }}>Content</Box>;

// OK: Stable component with styled
const StyledButton = styled(Button, {
    shouldForwardProp: (prop) => prop !== "isActive",
})<{ isActive: boolean }>(({ theme, isActive }) => ({
    backgroundColor: isActive
        ? theme.palette.primary.main
        : theme.palette.grey[500],
}));

// OK: Selecting the appropriate component
<Stack spacing={2}>
    <Typography>No unnecessary nesting</Typography>
</Stack>;

// OK: Type extension with Module Augmentation
declare module "@mui/material/styles" {
    interface Theme {
        custom: {
            brand: string;
        };
    }
    interface ThemeOptions {
        custom?: {
            brand?: string;
        };
    }
}

const theme = createTheme({
    custom: { brand: "#123456" }, // Type-safe
});
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Theme First**: All colors, spacing, and typography must go through the theme. No hard-coding.
2. **Type-Safe Theme**: Extend the theme with Module Augmentation so `sx` remains type-checked.
3. **Stable Styling**: Handle dynamic styles with `styled()` + props or CSS variables. Do not generate `sx` objects every time.
4. **Component Composition**: Prioritize `slots`/`slotProps`. Keep wrappers to a minimum.
5. **Next.js Integration**: Keep `'use client'` to a minimum. Use official EmotionCache/StyledRegistry patterns.
6. **Use Grid2**: Use the new `Grid2` component for layouts.

## Resources & Scripts

- [Code Check Script](scripts/check.sh)

## References

- [MUI Best Practices](references/best-practices.md)
- [MUI Theme & TypeScript Guide](references/theme-guide.md)
- [MUI + Next.js (SSR/RSC) Notes](references/nextjs-notes.md)
