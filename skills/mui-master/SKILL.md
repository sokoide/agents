---
name: mui-master
description: "Expert-level Material UI (MUI) architect. Master of component composition, theme design (v5/v6), performance optimization, and RSC/Next.js integration. Use for building scalable design systems and high-performance MUI applications."
---

# MUI Master

## When to Use

- MUI コンポーネントの実装/高度なカスタマイズ/リファクタリング（sx, styled, Slot pattern）
- 企業向けデザインシステムの構築（Theme, Module Augmentation, Design Tokens）
- Next.js (App/Pages Router) への MUI 統合、SSR/RSC 最適化、ハイドレーションエラーの解決
- 複雑なデータグリッド、フォーム、ダッシュボードのレイアウト設計

## First Questions (Ask Up Front)

- MUI バージョン (v5 / v6)、React/Next.js のバージョンとアーキテクチャ (App/Pages Router)
- スタイリングの主方針（`sx` 優先, `styled` 優先, または Pigment CSS / Tailwind 等の併用）
- TypeScript の厳格度、特に Theme の拡張（Module Augmentation）の要件
- デザイントークン（Figma 等）との同期要件や、複数テーマ（Dark/Light/Custom）の有無

## Output Contract (How to Respond)

- **実装提供**: 型安全でレスポンシブ、かつアクセシビリティ (WAI-ARIA) を遵守したコードを提供する。
- **デザインシステム**: 個別のコンポーネントだけでなく、テーマ変数への依存関係を明示した設計を提示する。
- **パフォーマンス**: レンダリングコストやバンドルサイズに配慮し、不要な `Box` ネストやインライン `sx` の計算を避ける提案をする。

## Design & Coding Rules (Expert Defaults)

1. **Theme-First Approach**: ハードコードを禁止し、`theme.spacing`, `theme.palette`, `theme.breakpoints` を徹底活用する。
2. **Type-Safe Theme**: カスタムプロパティ追加時は必ず Module Augmentation で型を定義し、IDE の補完を効かせる。
3. **Smart Composition**: `Stack`/`Grid2` を使い分け、複雑な CSS は `styled()` でカプセル化しつつ、Slot パターンで拡張性を確保する。
4. **Performance by Default**: 頻繁に更新されるプロップに連動する `sx` は避け、CSS 変数や `styled` の `shouldForwardProp` を活用する。
5. **RSC Strategy**: `'use client'` の境界を最小化し、サーバーサイドでのスタイルのシリアライズコストを抑える。

## Review Checklist (High-Signal)

- **Theming**: `theme.palette.text.primary` 等のセマンティックな色指定を無視していないか
- **TypeScript**: `sx` プロップ内の型推論が壊れていないか、テーマ拡張が型安全か
- **Efficiency**: 無駄な `Box` や `Container` のネストによる DOM 肥大化がないか
- **Consistency**: コンポーネントごとにスタイル定義手法（sx vs styled）が混在しすぎていないか
- **Accessibility**: コントラスト比、フォーカス管理、スクリーンリーダー対応（aria-属性）の欠如

## References

- [MUI Best Practices](references/best-practices.md)
- [MUI Theme & TypeScript Guide](references/theme-guide.md)
