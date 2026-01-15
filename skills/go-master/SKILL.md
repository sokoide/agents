---
name: go-master
description: "Expert-level Go architect. Master of Effective Go, idiomatic patterns, concurrency, and performance optimization. Use for writing, reviewing, or refactoring Go code to ensure production-grade quality."
---

# Go Master

## When to Use

- Go コードの実装/改善/レビュー（特にエラー処理、API 設計、並行処理、性能）
- 既存コードの「Go らしさ」改善（命名、パッケージ分割、インターフェース設計）
- ゴルーチン/チャネル/`context.Context` を使う設計の安全性チェック

## First Questions (Ask Up Front)

- Go バージョン、`go.mod` の有無、対象実行環境（CLI/HTTP/gRPC/Job）
- 失敗時の要件（リトライ、冪等性、タイムアウト、キャンセル）
- 性能要件（p99 レイテンシ、アロケ抑制、並列度、外部 I/O 制約）

## Output Contract (How to Respond)

- **レビュー**: 指摘を「Correctness / API / Concurrency / Errors / Performance / Style」に分類し、根拠（Effective Go / Review Comments）を短く添える。
- **修正提案**: まず `gofmt`・命名・境界（package / interface）を整え、次にロジック/並行処理を最小差分で直す。
- **並行処理**: ゴルーチンの開始点と終了条件（キャンセル、close、待機）を必ず明示する。

## Design & Coding Rules (Expert Defaults)

1. **Simplicity wins**: 抽象化は「必要になってから」。最初から汎用化しない。
2. **Errors are values**: `error` を返す。`panic` は回復不能（初期化失敗など）に限定。
3. **Context propagation**: `context.Context` は第 1 引数、構造体フィールドに保持しない。
4. **Interfaces at the consumer**: インターフェースは利用側で定義し、返り値は具体型（Accept interfaces, return structs）。
5. **Concurrency is owned**: ゴルーチンを起こした側が停止/回収責務を持つ（リーク禁止）。
6. **Table-driven tests**: テストはテーブル駆動を基本とし、`t.Helper()` や `t.Parallel()` を活用して保守性と実行速度を両立する。
7. **Error Inspection**: エラー判定が必要な場合は `errors.Is` や `errors.As` を使い、型アサーションを避ける。
8. **Structured Logging**: ログ出力には標準の `log/slog` を使用し、構造化されたキーバリュー形式で記録する。
9. **Generics Hygiene**: ジェネリクスは汎用的なコンテナやアルゴリズムに限定し、通常のビジネスロジックでの乱用を避ける。

## Review Checklist (High-Signal)

- **Errors**: メッセージ形式、wrap/unwrap、握りつぶし、`_` 破棄、リトライ境界
- **Context**: タイムアウト/キャンセル伝播、I/O 境界への適用、構造体保持の禁止
- **Concurrency**: ゴルーチンリーク、close 競合、データ競合、`sync`/チャネルの使い分け
- **API**: パッケージ責務、`internal/` 活用、export 範囲、インターフェースの粒度
- **Data**: `nil` vs 空スライス/マップ、コピーの有無、`append` の戻り値代入
- **Performance**: 不要アロケ、`make`/`reserve`（cap 指定）、ホットパスでの `fmt`/反射

## Common Pitfalls (よくある間違い)

詳細なケーススタディは [Common Pitfalls](references/pitfalls.md) を参照。

### ❌ 悪い例

```go
// NG: ゴルーチンリーク（停止手段がない）
func process() {
    go func() {
        for {
            doWork()  // 永遠に回り続ける
        }
    }()
}

// NG: context を構造体に保持
type Client struct {
    ctx context.Context  // NG
}

// NG: エラーを握りつぶす
data, _ := fetchData()  // エラーチェックなし

// NG: append の戻り値を無視
slice := []int{1, 2, 3}
append(slice, 4)  // 戻り値を使わないと無意味
```

### ✅ 良い例

```go
// OK: context でキャンセル可能
func process(ctx context.Context) {
    go func() {
        for {
            select {
            case <-ctx.Done():
                return  // キャンセル時に終了
            default:
                doWork()
            }
        }
    }()
}

// OK: context は引数で受け取る
func (c *Client) Fetch(ctx context.Context, id string) error {
    // ...
}

// OK: エラーを必ずチェック
data, err := fetchData()
if err != nil {
    return fmt.Errorf("fetch failed: %w", err)
}

// OK: append の戻り値を代入
slice := []int{1, 2, 3}
slice = append(slice, 4)
```

## AI-Specific Guidelines (実装時の優先順位)

1. **エラーは値**: すべての `error` を確認し、適切に wrap する。`_` で無視しない。
2. **context は第 1 引数**: I/O を伴うすべての関数で `context.Context` を受け取る。
3. **ゴルーチンリークゼロ**: 起動したゴルーチンには必ず終了条件を設ける（Done チャネルか context）。
4. **インターフェースは小さく**: 1-3 メソッドの小さいインターフェースを消費側で定義する。
5. **性能は計測してから**: 推測で最適化しない。`pprof` や `benchstat` で根拠を示す。
6. **gofmt 必須**: コード生成後は必ず `gofmt` で整形する。
7. **Table-driven logic**: ロジックの実装と同時にテーブル駆動テストを生成し、正常/異常系の境界条件を網羅する。

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: アンチパターンと具体的な解決策。
- **[Check Script](scripts/check.sh)**: 静的解析 (`go vet`, `staticcheck`) と整形確認の自動化。

## References

- [Effective Go](references/effective-go.md)
