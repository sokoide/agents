---
name: java-master
description: "Java + Spring expert. Master of modern Java (11/17/21), Spring Boot, dependency injection, transactions, testing, and production-grade design/review for backend services."
---

# Java + Spring Master

## When to Use

- Java（11/17/21 など）+ Spring Boot の実装/改善/設計レビュー
- Spring DI、トランザクション、例外設計、API 設計、JPA/DB 境界の整理
- パフォーマンス/信頼性（N+1、コネクション枯渇、スレッド/非同期、観測性）の問題解析

## First Questions (Ask Up Front)

- Java / Spring Boot / Spring Framework のバージョン、ビルド（Maven/Gradle）、実行環境（K8s/VM）
- 主要技術（Spring MVC/WebFlux、Spring Data JPA/Jdbc、Security、Messaging）
- 失敗時要件（リトライ/冪等性/タイムアウト/整合性）、SLO（p95/p99、スループット）
- データモデル（RDB/NoSQL）、トランザクション境界（分散の有無）、マイグレーション運用

## Output Contract (How to Respond)

- **レビュー**: 指摘を「Correctness / API / DI / Transactions / Data(JPA) / Security / Performance / Operability」に分類し、重大度と修正方針を明示する。
- **提案**: “最小差分で安全に” を優先し、段階的リファクタ手順（先に境界、次に内部）を提示する。
- **Spring 特有**: 依存注入・Bean 境界・proxy/`@Transactional` の落とし穴は必ず言語化する。

## Design & Coding Rules (Expert Defaults)

1. **Constructor Injection**: フィールド注入は避け、依存はコンストラクタで明示する。
2. **Layering**: Controller は I/O に専念し、Service がユースケース、Repository が永続化（ドメイン判断を DB 側に漏らさない）。
3. **DTO vs Entity**: API DTO と JPA Entity を混在させない（Mapping を固定する）。
4. **Transactions are explicit**: `@Transactional` の境界を明示し、read/write と propagation を意図して選ぶ。
5. **Null is a bug source**: `Optional` は “返り値” の表現として限定的に使い、フィールドに濫用しない。
6. **Observability by default**: ログ/メトリクス/トレースの境界（外部 I/O、遅い SQL）を意識して設計する。
7. **Modern Data Structures**: Java 14+ では DTO に `record` を使用し、不変性とボイラープレート削除を両立する。
8. **Testing with Realism**: DB 統合テストには H2 ではなく Testcontainers を使用し、本番環境との差異を排除する。

## Review Checklist (High-Signal)

- **DI/Beans**: 循環依存、scope の誤り、Bean 境界の肥大化、テスト困難な static/Singleton
- **Transactions**: proxy を跨がない自己呼び出し、`readOnly` の意図、長時間 TX、ロールバック条件
- **Data/JPA**: N+1、fetch 戦略、lazy 初期化例外、ページング+join、コネクション枯渇
- **API**: バリデーション（`@Valid`）、エラー応答（`@ControllerAdvice`）、互換性（破壊的変更）
- **Security**: 認可境界、入力の信頼境界、シークレット取り扱い、ログへの機微情報混入
- **Performance**: 不要なオブジェクト生成、過剰な同期、ブロッキング I/O の混入（特に WebFlux）
- **Operability**: タイムアウト、リトライ方針、サーキット/バックプレッシャ、shutdown/graceful

## Common Pitfalls (よくある間違い)

### ❌ 悪い例

```java
// NG: フィールド注入
@Autowired
private UserService userService;  // テスト困難

// NG: @Transactional の自己呼び出し
@Transactional
public void outer() {
    inner();  // トランザクションが効かない
}
private void inner() { ... }

// NG: JPA での N+1
List<User> users = userRepository.findAll();
for (User user : users) {
    user.getOrders().size();  // 遅延ロードで N+1
}

// NG: Optional の誤用
public Optional<User> getUser(Long id) {
    return Optional.of(userRepository.findById(id).orElse(null));  // null を包む
}
```

### ✅ 良い例

```java
// OK: コンストラクタ注入
private final UserService userService;
public UserController(UserService userService) {
    this.userService = userService;
}

// OK: 別クラスに分離してトランザクション適用
@Transactional
public void outer() {
    anotherService.inner();  // proxy を経由
}

// OK: fetch join で一括取得
@Query("SELECT u FROM User u LEFT JOIN FETCH u.orders")
List<User> findAllWithOrders();

// OK: Optional は返り値でのみ使用
public Optional<User> getUser(Long id) {
    return userRepository.findById(id);
}
```

## AI-Specific Guidelines (実装時の優先順位)

1. **コンストラクタ注入**: フィールド注入を避け、依存をコンストラクタで明示する。final にする。
2. **@Transactional の境界**: Service 層で適用し、proxy を意識する。自己呼び出しは効かない。
3. **JPA は fetch join**: N+1 を避けるため、必要な関連を `JOIN FETCH` で一括取得する。
4. **DTO と Entity を分離**: Controller では DTO、永続化層では Entity、境界で mapping する。
5. **Optional は返り値のみ**: フィールドや引数には使わない。null の方が自然な場面では null を使う。
6. **ログと例外**: `@ControllerAdvice` で例外を一元処理し、機微情報はログに出さない。
7. **Resilience**: 外部通信には Resilience4j を適用し、リトライやサーキットブレーカーを実装する。

## Resources & Scripts

- **[Common Pitfalls](references/pitfalls.md)**: Common mistakes and best practices.
- **[Check Script](scripts/check.sh)**: Automated checks (`mvn`, `gradle`).

## References

- [Java Backend Review Guide](references/java-backend-review.md)
- [Spring Boot Review Guide](references/spring-boot-review.md)
