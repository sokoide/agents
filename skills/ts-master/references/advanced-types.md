# Advanced TypeScript Engineering

## 型レベル・ロジック

- **`satisfies` 演算子:**
  型を固定（Upcast）せずに、値が特定の型を満たしているか検証する。推論されたリテラル型を保持しつつ、型安全性を確保したい場合に最適。
- **変位 (Variance):**
  Generics における `In/Out`（反変/共変/双変/不変）を理解し、特に高階関数やクラス継承における型安全性を確保する。
- **`const` 型パラメータ:**
  関数に渡されたリテラルを、呼び出し側で `as const` せずに定数として推論させる。

## 構造的部分型と健全性 (Soundness)

- **Nominal Identity (Branding):**
  必要に応じて `Branding`（例: `type ID = string & { __brand: "User" }`）を用い、構造的に同じでも意味的に異なる型を区別し、型レベルでの誤用を防ぐ。
- **網羅性チェック (Exhaustive Checks):**
  `never` 型を用いた `switch` や `if` の網羅性チェックにより、将来的な型拡張時のバグをコンパイル時に検知する。

## 複雑な型変換

- **Mapped Types:** `as` 節（Key Remapping）を用いた動的なキー変換。
- **Conditional Types:** `infer` を駆使した型の抽出（Promise の解決型、関数の引数型など）。
- **Template Literal Types:** 文字列のパターンマッチングと結合による型定義。
