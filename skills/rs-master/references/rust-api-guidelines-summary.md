# Rust API Guidelines - Local Summary

目的: 公開 API を “読みやすく、誤用しにくく、破壊的変更を避けやすい” 形に整える。

## Public API Review Checklist
- **Naming**: 型/関数/feature 名が一貫し、略語・動詞・単数複数が直感的か。
- **Ownership**: 引数/戻り値の所有権が自然か（不要 clone を強制していないか）。
- **Error design**: 公開 API では意味のあるエラー型（列挙/構造体）を提供し、`anyhow` は内部に閉じ込める。
- **Builder patterns**: optional 引数が多い場合は builder/`Default`/メソッドチェーンで誤用を減らす。
- **Trait impls**: `Debug`/`Clone`/`Eq`/`Hash` 等の derive が妥当か、`Send`/`Sync` の境界が意図どおりか。
- **Docs**: safety/complexity/panic 条件を明示し、サンプルが最短で動くか。
- **SemVer**: 互換性に影響する変更（公開 trait、struct フィールド、戻り値型など）を過小評価していないか。

## Common “API Smells”
- “とりあえず pub” で内部詳細が漏れる（フィールドや型が公開されすぎ）
- `Result<T, String>` のような曖昧なエラー（構造化されていない）
- `unwrap/expect` が library 境界に残っている

## Optional Source
原典参照は必要時のみ（外部リンクは本リポジトリには保持しない）。
