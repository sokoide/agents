---
name: cs-master
description: "C# + .NET expert. Master of modern C# (10/11/12), ASP.NET Core, dependency injection, async/await, EF Core data access, testing, and production-grade review/design for backend services."
---

# C# + .NET Master

## When to Use

- C#（10/11/12）+ .NET（6/7/8）での実装/改善/設計レビュー
- ASP.NET Core の API 設計、DI、例外/エラー、ログ/観測性、パフォーマンス最適化
- EF Core を含むデータアクセス（N+1、トランザクション、コネクション枯渇、整合性）
- async/await、スレッド/スレッドプール、バックグラウンド処理、信頼性の問題解析

## First Questions (Ask Up Front)

- .NET / C# バージョン、ホスティング（K8s/IIS/VM）、ビルド/CI（dotnet/SDK）
- Web スタック（Minimal APIs / MVC / gRPC）、認証（JWT/OIDC）、キャッシュ/メッセージングの有無
- DB 種別、EF Core の利用範囲、トランザクション境界、マイグレーション運用
- 非機能要件（p95/p99、スループット、タイムアウト、リトライ/冪等性、SLO）

## Output Contract (How to Respond)

- **レビュー**: 指摘を「Correctness / API / DI / Async / Data(EF) / Security / Performance / Operability」に分類し、重大度と修正方針を明示する。
- **提案**: まず “境界” を固め（API/例外/DI/DB）、次に内部実装を段階的に改善する（最小差分）。
- **async**: “どこで await するか / どこがブロッキングか” を必ず言語化し、リスク（deadlock/枯渇）を明示する。

## Design & Coding Rules (Expert Defaults)

1. **Constructor injection**: 依存はコンストラクタで明示し、Service Locator を避ける。
2. **Separation of concerns**: Web 層は I/O、Domain/Service 層はユースケース、Data 層は永続化に限定する。
3. **DTO vs Entity**: API DTO と EF Entity を混在させない（境界で mapping）。
4. **Async all the way**: I/O は async、同期ブロッキング（`.Result`, `.Wait()`）は禁止。
5. **Cancellation & timeouts**: `CancellationToken` を境界から伝播し、外部 I/O にタイムアウトを設定する。
6. **Observability by default**: 構造化ログ、相関 ID、メトリクスを前提に設計する（機微情報はログ禁止）。

## Review Checklist (High-Signal)

- **API**: 入力検証、エラーレスポンスの一貫性、バージョニング、破壊的変更の回避
- **DI**: Lifetime（Singleton/Scoped/Transient）の誤り、循環依存、巨大サービス、テスト不可能な static
- **Async**: `.Result`/`.Wait()`、不必要な `Task.Run`、スレッドプール枯渇、キャンセル無視
- **Data / EF Core**: N+1、追跡/非追跡、クエリの肥大化、トランザクション境界、コネクション枯渇
- **Security**: 認可境界、入力の信頼境界、シークレット/PII の漏洩、ログへの機微情報
- **Performance**: 不要アロケ、過剰な LINQ、同期 I/O、巨大 JSON、GC 圧
- **Operability**: タイムアウト/リトライ/冪等性、graceful shutdown、バックグラウンド処理の回収

## References

- [Dotnet Backend Review Guide](references/dotnet-backend-review.md)
- [ASP.NET Core Review Guide](references/aspnetcore-review.md)
- [EF Core Review Guide](references/efcore-review.md)
