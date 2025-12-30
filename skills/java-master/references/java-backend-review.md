# Java Backend Review Guide (Local)

## 1) Language & API Design

- **Immutability first**: 可能なら `record` / 不変クラスを使い、共有可変状態を最小化する。
- **Exceptions**: “回復可能か” を境界で決める。アプリ例外（意味のある runtime 例外）とインフラ例外を分ける。
- **Collections**: 返り値は空コレクションを基本（`null` を返さない）。引数は defensive copy が必要か判断する。
- **Time**: `java.time` を使い、タイムゾーン/丸め/表現（Instant/LocalDateTime）を設計で固定する。

## 2) Concurrency & Async

- **Threading model**: “どの層が並列性を所有するか” を決める（勝手に `CompletableFuture.supplyAsync` を散らさない）。
- **Executors**: スレッドプールは使い回し、無制限生成を避ける。ブロッキング I/O と CPU-bound を混ぜない。
- **Shared state**: `synchronized`/lock は最終手段。まず不変化・分割・メッセージングで解く。

## 3) Reliability & Boundaries

- **Timeouts**: 外部 I/O は必ずタイムアウトを設定し、再試行は冪等性とセットで検討する。
- **Idempotency**: リトライ可能な API はキー設計/重複排除を含めて設計する。
- **Logging**: 機微情報（token/PII）をログに出さない。例外ログは “原因” と “入力” を分離する。

## 4) Testing Strategy (Default)

- **Unit**: 純粋ロジックは JUnit で高速に。
- **Slice**: MVC は `@WebMvcTest`、JPA は `@DataJpaTest` で境界を狙う。
- **Integration**: 外部依存は Testcontainers 等で再現性を確保（必要最小限）。
