# MUI + Next.js (SSR/RSC) Notes

このメモは「Next.js で MUI を使うときに起きやすい崩れ」を減らすための観点集です。

## 1. まず確認すること

- App Router か Pages Router か（SSR と RSC の境界が変わる）
- CSS-in-JS の注入方式（公式の統合を使っているか / 独自 CacheProvider か）
- Hydration mismatch の再現条件（開発のみか、本番でも起きるか、特定ページのみか）

## 2. よくある原因

- `'use client'` 境界が広すぎて Server Component のメリットが消えている / 逆に狭すぎて Hook を含むコンポーネントが Server 側に混入している
- SSR 時のスタイル注入順序が不安定（FOUC、className mismatch）
- theme の生成が request ごとに変わる（ランダム値、`Date.now()`、非決定的な順序）ことで hydration が壊れる
- font/locale 等でレンダリングが揺れる（Typography の計測や line-height で崩れが目立つ）

## 3. 実務ルール（おすすめ）

- **Theme は安定化**: `createTheme()` はモジュールスコープ or 明示的な memo で安定させ、render ごとの生成を避ける。
- **Provider の順序を固定**: `ThemeProvider` / `CssBaseline` /（必要なら）`CacheProvider` をルートで一貫させる。
- **Client boundary は最小単位に**: MUI を使う “leaf UI” に寄せ、データ取得・整形はできるだけ Server 側へ。
- **SSR は公式統合を優先**: App Router では公式の Next.js 統合（`@mui/material-nextjs` 等）が提供するパターンに寄せる。

## 4. 典型的な症状と切り分け

- **FOUC**: まず「SSR 時にスタイルが出ているか」を確認（production build で再現するか）。
- **Hydration mismatch**: mismatch のログと DOM 差分を見て、`className` か属性（`style`/`dir`/`data-*`）かを特定する。
- **Theme が効かない**: `ThemeProvider` のスコープ外にコンポーネントが出ていないか、複数 theme が混在していないかを確認する。
