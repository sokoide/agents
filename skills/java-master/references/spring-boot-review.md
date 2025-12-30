# Spring Boot Review Guide (Local)

## 1) DI / Configuration

- **Constructor injection** を基本にし、field injection は避ける。
- 設定は `@ConfigurationProperties` で型付けし、起動時に fail-fast する。
- Bean は責務単位で小さくし、巨大な “God Service” を作らない。

## 2) Web Layer (MVC / WebFlux)

- **Controller は薄く**: 変換・認証・入力検証・UseCase 呼び出し・レスポンス整形に限定する。
- **Validation**: `@Valid` と Bean Validation を境界に置き、内部ロジックで再検証しない。
- **Error handling**: `@ControllerAdvice` で一貫したエラー形式にする（例外をそのまま返さない）。
- **WebFlux 注意**: ブロッキング I/O（JDBC 等）を event loop に混ぜない。

## 3) Transactions

- `@Transactional` は “境界” に付ける（Service/UseCase）。
- 自己呼び出しで proxy を跨げないケースを避ける（設計/分割で解く）。
- `readOnly` と隔離レベルは “要件” から決める（推測で強くしない）。

## 4) Data (JPA / JDBC)

- **N+1**: まず SQL を観測し、fetch 戦略（join fetch/entity graph）を検討する。
- **Entity**: API DTO と分離し、永続化都合を外へ漏らさない。
- **Pagination + join**: 結果が壊れやすいので慎重に（count クエリや重複行）。

## 5) Security

- 認証/認可は境界で決め、Service 層に “なんとなく if” を散らさない。
- シークレットは環境変数/secret manager 前提で、コード/ログに残さない。

## 6) Operability

- ヘルスチェック、メトリクス、ログ相関（request id）を前提に設計する。
- タイムアウト/リトライ/サーキットは “どの層で責務を持つか” を固定する。
