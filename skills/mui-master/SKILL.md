---
name: mui-master
description: "Expert-level Material UI (MUI) architect. Master of component composition, styling (sx/styled), theme + TypeScript module augmentation, performance optimization, and Next.js (SSR/RSC) integration. Use for building scalable design systems and high-performance MUI apps."
---

# MUI Master

## When to Use

- MUI コンポーネントの実装/高度なカスタマイズ/リファクタリング（`sx`, `styled()`, `slots`/`slotProps`）
- 企業向けデザインシステムの構築（Theme, TypeScript Module Augmentation, Design Tokens）
- Next.js (App/Pages Router) への MUI 統合、SSR/RSC 最適化、ハイドレーションエラーの解決
- MUI X Data Grid、フォーム、ダッシュボードのレイアウト設計と性能/アクセシビリティ改善

## First Questions (Ask Up Front)

- MUI バージョン (v5 / v6)、React/Next.js のバージョンとルーティング (App/Pages Router)
- Next.js: SSR の有無、RSC 境界（`'use client'` の配置）、CSS-in-JS の注入方式
- スタイリング方針（`sx` 優先 / `styled` 優先 / theme `variants`/`styleOverrides` 中心 / Tailwind 等と併用）
- TypeScript の厳格度、特に Theme の拡張（Module Augmentation）の要件
- デザイントークン（Figma 等）との同期要件や、複数テーマ（Dark/Light/Custom）の有無

## Output Contract (How to Respond)

- **実装/レビュー**: 指摘を「Composition / Styling / Theme+TS / Next.js(SSR/RSC) / Performance / Accessibility」に分類し、根拠を短く添える。
- **デザインシステム**: 個別のコンポーネントだけでなく、token→theme→component override の依存関係が追える設計を提示する。
- **パフォーマンス**: レンダリングコストやバンドルサイズに配慮し、不要な DOM 深度・不安定な `sx`・過剰な Context 再レンダリングを避ける。

## Design & Coding Rules (Expert Defaults)

1. **Theme-First Approach**: ハードコードを避け、`theme.spacing/palette/typography/breakpoints` を徹底活用する。
2. **Type-Safe Theme**: theme 拡張は Module Augmentation で型定義し、`sx` も `Theme` で型付けする。
3. **Composition over wrappers**: まず既存コンポーネントの `slots`/`slotProps` と `component` を使い、必要なときだけ `styled()`/自作 wrapper を追加する。
4. **Stable styling**: 頻繁に変わる値に連動する `sx`（inline object 生成含む）を抑え、`styled()` + props / CSS 変数 / theme `variants` を選ぶ。
5. **Next.js boundary hygiene**: `'use client'` は最小単位に閉じ、SSR では公式のスタイル注入パターンを優先して FOUC/ハイドレーション不整合を避ける。

## Review Checklist (High-Signal)

- **Theming**: セマンティックな色/typography/spacing を無視して値が散っていないか
- **TypeScript**: theme 拡張が型安全か、`sx` で `Theme` 前提が壊れていないか
- **Next.js**: SSR/RSC 境界が破綻していないか、FOUC/ハイドレーション不整合の兆候がないか
- **Efficiency**: DOM 深度が不必要に増えていないか（Box/Stack/Container の濫用）
- **Consistency**: `sx`/`styled`/`styleOverrides`/`variants` の使い分けがチーム規約に沿っているか
- **Accessibility**: コントラスト、`:focus-visible`、`aria-*`、ラベル/説明文、キーボード操作

## References

- [MUI Best Practices](references/best-practices.md)
- [MUI Theme & TypeScript Guide](references/theme-guide.md)
- [MUI + Next.js (SSR/RSC) Notes](references/nextjs-notes.md)
