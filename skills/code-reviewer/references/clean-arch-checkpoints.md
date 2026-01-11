# Clean Architecture Review Checkpoints

## 1. Dependency Rule
- [ ] 依存関係は常に「内側」に向かっているか？ (Framework -> UseCase -> Domain)
- [ ] Domain 層が外部ライブラリ（DBドライバ、Webフレームワークなど）に依存していないか？
- [ ] 外部の詳細（SQL、HTTPリクエストなど）が Domain/UseCase 層に漏れ出していないか？

## 2. Layer Responsibilities
### Domain
- [ ] ビジネスロジックが Entity または Domain Service に適切に閉じ込められているか？
- [ ] Repository は Interface として定義されているか？

### UseCase
- [ ] ビジネスの手順（オーケストレーション）のみを記述しているか？
- [ ] インフラの実装（DB接続、外部API呼び出しなど）を直接行っていないか？
- [ ] 複数のドメインオブジェクトを組み合わせるロジックがここにあるか？

### Infra Adapters
- [ ] Repository Interface の具象実装がここにあるか？
- [ ] DB固有のエラーが上位レイヤー（UseCase/Domain）に伝播していないか？（適切にラップされているか）

### Framework / Presentation
- [ ] HTTP/CLI の入力を UseCase の入力モデルに変換しているか？
- [ ] UseCase の出力を適切なレスポンス形式に変換しているか？

## 3. Data Flow
- [ ] UseCase の呼び出しに Interface (Input Port) を使用しているか？
- [ ] `context.Context` が適切に伝搬され、キャンセルやタイムアウトが考慮されているか？
- [ ] 認可やロギングなどの横断的関心事が、ビジネスロジックを汚染していないか？
