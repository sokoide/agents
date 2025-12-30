# .NET Backend Review Guide (Local)

## 1) Language & API Design
- **Immutability**: `record` / init-only / private setters を使い、意図しない変更を防ぐ。
- **Nullability**: nullable reference types を前提にし、警告を握りつぶさない（`!` の多用は臭い）。
- **Exceptions**: 例外は “境界” で変換・整形し、内部の例外をそのまま API に漏らさない。
- **Collections**: 返り値に `null` を返さない。外部公開は読み取り専用インターフェースを検討する。

## 2) Async / Concurrency
- **Async all the way**: 同期ブロック（`.Result`, `.Wait()`）はデッドロック/枯渇の原因。
- **Thread pool hygiene**: I/O-bound を `Task.Run` しない。CPU-bound は明確に隔離する。
- **Cancellation**: `CancellationToken` を入口から末端まで伝播し、キャンセル時の後始末を設計する。

## 3) Reliability Boundaries
- **Timeouts**: 外部 I/O（HTTP/DB/Queue）は必ずタイムアウト設定し、失敗モードを設計で固定する。
- **Retries & idempotency**: リトライは冪等性とセット。重複排除キー/整合性要件を明文化する。
- **Logging**: 例外ログは “原因” と “入力” を分離し、token/PII を出さない。

## 4) Testing Strategy (Default)
- **Unit**: 純粋ロジックは高速に（xUnit/NUnit/MSTest いずれでも可）。
- **Integration**: DB/外部 I/O は再現性を重視（必要最小限）。
- **Contract**: API 互換性が重要なら request/response の契約テストを検討する。
