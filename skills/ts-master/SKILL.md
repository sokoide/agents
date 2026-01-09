---
name: typescript-master
description: "High-fidelity TypeScript architect. Expert in TS 5.x specs, structural typing, performance optimization, and runtime semantics. Use for complex type engineering, sound architecture design, and debugging deep-level type issues."
---

# TypeScript Master

## When to Use

- TS の実装/改善/レビュー（型設計、tsconfig、ランタイムの罠、性能）
- 高度な型（conditional/mapped/variance）や、型推論が破綻するケースのデバッグ
- 境界データ（API/JSON/DB）を安全に扱う設計（type erasure 前提）

## First Questions (Ask Up Front)

- TS/Node のバージョン、実行環境（Node/Browser/React）、module 形式（ESM/CJS）
- `tsconfig` の strictness、lint（ESLint）/format（Prettier）、型チェックを CI で走らせるか
- 外部入力の検証方針（Zod 等）とエラー表現（Result/throw）

## Output Contract (How to Respond)

- **レビュー**: 指摘を「Soundness / Runtime / API / Performance / DX」に分類し、`any`/アサーション/非 null の妥当性を最優先で評価する。
- **修正提案**: まず型の境界（外部入力・module exports）を固め、次に内部の型推論/表現を簡潔にする。
- **ランタイム**: 生成 JS の挙動が変わる提案は、必ず具体例とリスク（互換性/バンドル）を添える。

## Design & Coding Rules (Expert Defaults)

1. **No `any` by default**: 不明な値は `unknown` とし、ガード/バリデーションで絞り込む。
2. **Prefer narrowing over assertions**: `as` は最後の手段。`satisfies`/ユーザ定義型ガードを優先する。
3. **Type erasure awareness**: 型は消える。境界ではランタイム検証（Zod 等）を前提にする。
4. **Export surface discipline**: 公開型を安定させ、内部型が漏れないよう module 境界を設計する。
5. **Pragmatic soundness**: Soundness と DX のトレードオフを明示し、局所化する。

## Review Checklist (High-Signal)

- **Soundness**: `any`、過剰な `as`、`!`、`// @ts-ignore` の乱用と局所化
- **Runtime boundary**: 外部入力の検証、例外/Result の境界、JSON の型安全性
- **Types**: 条件付き型の複雑化、推論の破綻、`never` の意図しない発生
- **Config**: `strict` 系、`noUncheckedIndexedAccess` 等の採用可否、`skipLibCheck` の影響
- **Performance**: 型計算コスト（IDE 遅延）、ビルド時間、バンドルサイズ（type-only import）

## Common Pitfalls (よくある間違い)

### ❌ 悪い例

```typescript
// NG: any の乱用
function process(data: any): any {
    // 型安全性ゼロ
    return data.whatever; // ランタイムエラー
}

// NG: アサーションの乱用
const value = data as string; // 検証なし

// NG: ! で null を単純に無視
const user = users.find((u) => u.id === id)!; // undefined の可能性

// NG: 外部 JSON を検証なしで使用
const config: Config = JSON.parse(text); // 実際の形式不明
```

### ✅ 良い例

```typescript
// OK: unknown を使って型ガード
function process(data: unknown): string {
    if (typeof data === 'string') {
        return data;  // 型が絞り込まれた
    }
    throw new Error('Invalid data');
}

// OK: 型ガードで安全に検証
function isString(value: unknown): value is string {
    return typeof value === 'string';
}

// OK: Optional chaining と nullish coalescing
const user = users.find(u => u.id === id);
const name = user?.name ?? 'Unknown';

// OK: Zod でランタイム検証
import { z } from 'zod';
const ConfigSchema = z.object({ ... });
const config = ConfigSchema.parse(JSON.parse(text));
```

## AI-Specific Guidelines (実装時の優先順位)

1. **any 禁止、unknown 使用**: 不明な値は `unknown` とし、型ガードで絞り込む。
2. **ランタイム検証を必須に**: 外部入力（API/JSON）は Zod や io-ts で検証する。
3. **as より satisfies**: 型アサーションを減らし、`satisfies` で型推論を保つ。
4. **strict を有効化**: `tsconfig.json` で `strict: true` を設定する。
5. **公開型を安定化**: module 境界で内部型が漏れないよう設計する。
6. **type-only import**: 型だけの import は `import type` で明示し、バンドルサイズを減らす。

## References

- [Enterprise Best Practices](references/best-practices.md)
- [tsconfig Guide](references/tsconfig-guide.md)
- [Advanced Types](references/advanced-types.md)
