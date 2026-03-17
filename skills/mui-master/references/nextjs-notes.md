# MUI + Next.js (SSR/RSC) Notes

This collection of points aims to reduce layout shifts or breakage that frequently occur when using MUI with Next.js.

## 1. Initial Checks

- **Router**: App Router or Pages Router? (Affects the boundaries between SSR and RSC).
- **Injection Method**: Are you using the official integration for CSS-in-JS, or a custom CacheProvider?
- **Hydration Mismatch**: What are the conditions for reproduction? (Dev only, production as well, or only on specific pages?)

## 2. Common Causes

- `'use client'` boundaries are too broad, negating the benefits of Server Components; or conversely, they are too narrow, causing components with Hooks to leak onto the Server side.
- Unstable style injection order during SSR (Causes FOUC or className mismatches).
- Hydration breaks because theme generation changes per request (Due to random values, `Date.now()`, or non-deterministic ordering).
- Rendering instability due to fonts or locales (Noticeable as layout shifts in Typography measurements or line-heights).

## 3. Practical Rules (Recommended)

- **Stabilize Your Theme**: Ensure `createTheme()` is stable via module scope or explicit memoization; avoid generation during setiap render.
- **Fix Provider Order**: Consistently order `ThemeProvider`, `CssBaseline`, and (if necessary) `CacheProvider` at the root.
- **Minimize Client Boundaries**: Keep MUI to "leaf UI" components as much as possible, while handling data fetching and formatting on the Server side.
- **Prioritize Official Integration for SSR**: In App Router, stick to the patterns provided by official Next.js integrations like `@mui/material-nextjs`.

## 4. Typical Symptoms & Troubleshooting

- **FOUC**: First, verify if styles are being output during SSR (Check if it reproduces in a production build).
- **Hydration Mismatch**: Inspect mismatch logs and DOM diffs to see if the issue is with `className` or attributes (`style`, `dir`, `data-*`).
- **Theme Not Applied**: Check if the component is outside the `ThemeProvider` scope or if multiple themes are mixed.
