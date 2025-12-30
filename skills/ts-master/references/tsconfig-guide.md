# Advanced tsconfig Guide

TS の型安全性と DX は `tsconfig.json` でほぼ決まります。ここでは “堅牢さ” を優先する推奨をまとめます。

## 1) 厳格な型チェック（The Strict Standard）
基本は `strict: true`。

追加で有効化を検討するフラグ:
- **`noUncheckedIndexedAccess`**: `obj[key]` が `undefined` を含みうることを型で表現し、実行時の `cannot read ...` を減らす。
- **`exactOptionalPropertyTypes`**: optional の `undefined` 代入を厳格化し、意図しない状態を防ぐ。
- **`noImplicitReturns`**: 全分岐で戻り値があることを保証（API で特に有効）。

## 2) モジュール/解決（Node/バンドラ前提）
- **`moduleResolution: "NodeNext"`**: Node の ESM 解決に寄せる（CJS/ESM 混在プロジェクトで特に重要）。
- **`verbatimModuleSyntax`**: import/export の意味を明確化し、出力 JS の予測可能性を上げる。
- **`isolatedModules`**: Babel/SWC 等での単体変換を想定する場合に必須級（型に依存した変換を検知）。

## 3) アプリ vs ライブラリ（公開物で分ける）
**アプリ（実行する側）**
- `noEmit: true` を使い、型チェック専用にする（ビルドは bundler に任せる構成）。
- `lib`/`jsx` はランタイムに合わせる（DOM/React/Node）。

**ライブラリ（配布する側）**
- `declaration: true` と `declarationMap: true` を検討（型定義の配布とデバッグ体験）。
- `stripInternal` や `exports` 設計と合わせ、公開型の漏れを防ぐ。

## 4) ビルドパフォーマンス
- **`incremental: true`**: 再コンパイル短縮（`.tsbuildinfo` を生成する）。
- **`skipLibCheck: true`**: 速度優先のトレードオフ。CI では false を検討（依存の型破綻を早期検知）。

## 5) ありがちな落とし穴
- `types` を雑に増やすとグローバル汚染・型衝突の原因になる。
- `paths` は便利だが、実行時解決（Node/bundler）と一致しないと壊れる。
