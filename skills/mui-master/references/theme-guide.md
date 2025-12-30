# MUI Theme & TypeScript Guide

## 1. Professional Theming Strategy

### Palette & Tokens

- **Semantic Colors**: Define custom colors in the palette (e.g., `success`, `warning`, `info`).
- **Contrast**: Always define `contrastText` for custom colors.
- **Dynamic Selection**: Use `theme.palette.mode === 'dark'` to adjust styles globally.

### Component Overrides (The "Dry" Principle)

- Use `styleOverrides` in the theme to define global styles for components (e.g., all Buttons should have a specific border radius).
- Use `defaultProps` to set project-wide defaults like `disableRipple` or `size="small"`.
- Prefer theme `variants` when the difference is a first-class “variant” of the component (e.g., size/style modes), and `styleOverrides` for global baseline tweaks.

```tsx
const theme = createTheme({
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 12,
        },
      },
    },
  },
});
```

## 2. TypeScript Module Augmentation

To add custom properties to the theme and keep it type-safe:

```tsx
declare module '@mui/material/styles' {
  interface Palette {
    customAction: Palette['primary'];
  }
  interface PaletteOptions {
    customAction?: PaletteOptions['primary'];
  }
  interface Theme {
    status: {
      danger: string;
    };
  }
  interface ThemeOptions {
    status?: {
      danger?: string;
    };
  }
}
```

When using `sx` heavily, consider typing reusable style objects as `SxProps<Theme>` to keep inference stable.

## 3. Responsive Design

- **Breakpoints**: Customize keys if the standard `sm`/`md`/`lg` don't match the design system.
- **`sx` Object Syntax**: Prefer `<Box sx={{ display: { xs: 'none', md: 'block' } }} />`.

## 4. Typography Mastery

- **Fluid Typography**: Use `theme.typography.pxToRem` for consistent scaling.
- **Custom Variants**: Augment the `Typography` variants if you need specific types like `poster` or `helperText`.

## 5. Shadow & Spacing

- **Shadows**: Replace the 25-level array if your design system uses a different shadow set.
- **Spacing**: Use a function if you need a non-linear spacing scale: `spacing: (factor: number) => [0, 4, 8, 16, 32][factor]`.
