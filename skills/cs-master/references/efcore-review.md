# EF Core Review Guide (Local)

## 1) Query Performance

- **N+1**: クエリ回数を観測してから対処（`Include`/projection/明示的 join を検討）。
- **Tracking**: 読み取りは `AsNoTracking()` を検討（ただし変更が必要なら追跡が前提）。
- **Projection**: Entity 全部を取らず DTO へ投影し、ネットワーク/メモリを節約する。

## 2) Transactions & Consistency

- トランザクション境界はユースケースで固定し、ネスト/長時間 TX を避ける。
- リトライは整合性要件と合わせて設計する（特に “二重実行” の影響）。

## 3) DbContext Lifetime

- `DbContext` は通常 Scoped。Singleton に入れない。
- 同一 `DbContext` の並列利用は禁止（スレッドセーフではない）。

## 4) Migrations & Schema

- マイグレーションの適用順/ロールバック方針を運用で固定する。
- 破壊的変更（カラム削除/型変更）は段階的に行う（互換性期間を持つ）。
