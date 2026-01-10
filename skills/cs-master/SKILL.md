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
7. **Global Exception Handling**: ASP.NET Core 8+ では `IExceptionHandler` を実装し、例外処理を一元化する。
8. **Nullable Reference Types**: `<Nullable>enable</Nullable>` を前提とし、null 警告をゼロにする。

## Review Checklist (High-Signal)

- **API**: 入力検証、エラーレスポンスの一貫性、バージョニング、破壊的変更の回避
- **DI**: Lifetime（Singleton/Scoped/Transient）の誤り、循環依存、巨大サービス、テスト不可能な static
- **Async**: `.Result`/`.Wait()`、不必要な `Task.Run`、スレッドプール枯渇、キャンセル無視
- **Data / EF Core**: N+1、追跡/非追跡、クエリの肥大化、トランザクション境界、コネクション枯渇
- **Security**: 認可境界、入力の信頼境界、シークレット/PII の漏洩、ログへの機微情報
- **Performance**: 不要アロケ、過剰な LINQ、同期 I/O、巨大 JSON、GC 圧
- **Operability**: タイムアウト/リトライ/冪等性、graceful shutdown、バックグラウンド処理の回収

## Common Pitfalls (よくある間違い)

### ❌ 悪い例

```csharp
// NG: async で同期ブロッキング
public async Task<User> GetUserAsync(int id) {
    return db.Users.Find(id);  // 同期メソッド
}

// NG: .Result でデッドロック
public void Process() {
    var result = GetDataAsync().Result;  // デッドロックの危険
}

// NG: EF Core で N+1
foreach (var user in users) {
    var orders = db.Orders.Where(o => o.UserId == user.Id).ToList();  // N+1
}

// NG: DI lifetime の誤り
services.AddSingleton<DbContext>();  // DbContext は Scoped であるべき
```

### ✅ 良い例

```csharp
// OK: async を一貫して使用
public async Task<User> GetUserAsync(int id, CancellationToken ct) {
    return await db.Users.FindAsync(id, ct);
}

// OK: await を使う
public async Task ProcessAsync() {
    var result = await GetDataAsync();
}

// OK: Include で一括取得
var users = await db.Users
    .Include(u => u.Orders)
    .ToListAsync(ct);

// OK: 適切な DI lifetime
services.AddScoped<DbContext>();
services.AddScoped<IUserService, UserService>();
```

## AI-Specific Guidelines (実装時の優先順位)

1. **async all the way**: I/O は必ず async、`.Result`/`.Wait()` は絶対に使わない。
2. **CancellationToken を伝播**: すべての async メソッドで `CancellationToken` を受け取り、外部 I/O に渡す。
3. **DI lifetime を正しく**: DbContext は Scoped、ステートレスサービスは Scoped か Transient、キャッシュは Singleton。
4. **EF Core は Include で**: N+1 を避けるため、必要なナビゲーションプロパティは明示的に Include する。
5. **DTO と Entity を分離**: API DTO と EF Entity を混在させず、境界で mapping する（AutoMapper や Mapster）。
6. **構造化ログ**: `ILogger<T>` で構造化ログ、機微情報は絶対にログに出さない。
7. **Resilience**: HTTP リクエストや DB 接続には `Microsoft.Extensions.Http.Resilience` (Polly) でリトライポリシーを適用する。
8. **LINQ Hygiene**: 遅延評価を意識し、多重列挙を避けるため適切なタイミングで `.ToListAsync()` する。

## References

- [Dotnet Backend Review Guide](references/dotnet-backend-review.md)
- [ASP.NET Core Review Guide](references/aspnetcore-review.md)
- [EF Core Review Guide](references/efcore-review.md)
