# Advanced tsconfig Guide

## 厳格な型チェック (The Strict Standard)
常に `strict: true` を前提とし、以下のフラグでさらに堅牢にする。

- **`noUncheckedIndexedAccess`:**
  インデックスアクセス時に自動で `undefined` を付与し、実行時エラーを未然に防ぐ。
- **`exactOptionalPropertyTypes`:**
  オプショナルなプロパティへの `undefined` 代入を厳格化し、V8 の Hidden Class 最適化を助ける。
- **`noImplicitReturns`:**
  関数のすべての実行パスで戻り値があることを保証。

## モダン・モジュール仕様
- **`verbatimModuleSyntax`:**
  ESM と CommonJS の混在による複雑なモジュール解釈問題を解決し、出力される JS の予測可能性を高める。
- **`moduleResolution: "NodeNext"`:**
  最新の Node.js エコシステムに合わせた正確なモジュール解決を行う。

## ビルドパフォーマンス
- **`incremental`: true:** 増分ビルドを有効化し、再コンパイル時間を短縮。
- **`skipLibCheck`: true:** 依存ライブラリの型チェックをスキップし、ビルド速度を向上（ただし CI では false を検討）。
- **`declarationMap`: true:** `d.ts` ファイルからソースコードへのジャンプを可能にし、開発体験を向上。