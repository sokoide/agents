# Clean Architecture（Go-style 4-Layer）

このドキュメントは `cleanarch-master` の **唯一の正** です。ここに反する構造は「好み」ではなく **規約違反** として扱います。

## 1. Non-Negotiable Rules（絶対ルール）

- **Framework は UseCase を呼ぶだけ**（入力/認証/レスポンス整形に限定）
- **Infra Adapter は Domain が定義した Port を実装する**（Domain/UseCase に実装を置かない）
- **Domain は外部に一切依存しない**（DB/HTTP/ORM/SDK/Framework の型を import しない）
- **依存方向は常に外→内**（Framework → UseCase → Domain ← Infra Adapter）

## 2. 各レイヤーの定義と責務

### Domain（ドメイン層）

#### Domain 定義

ビジネスルールそのもの（交換不可能な価値）

#### Domain 構成要素

- Entity
- Domain Service
- Repository / Gateway Interface（Port）

#### Domain 責務

- ビジネスルールの定義
- 永続化・外部連携に対する抽象契約（Port）

#### Domain 依存性

- 外部依存ゼロ（標準ライブラリは “ドメイン表現に必要な範囲” のみ）

### UseCase（ユースケース層）

#### UseCase 定義

アプリケーションとしての具体的機能の手順（Orchestration）

#### UseCase 責務

- Domain の操作と手順制御
- トランザクション/リトライ等のアプリ制御（技術詳細ではなく “方針”）
- UseCase の Input/Output（DTO）定義

#### UseCase 依存性

- Domain のみに依存（Infra/Framework の存在を知らない）

### Infra Adapter（インフラアダプタ層）

#### Infra Adapter 定義

外部システム（DB/外部 API/File 等）との橋渡し

#### Infra Adapter 責務

- Domain Port の具体実装
- driver error を domain/usecase 向けのエラーに変換
- 技術詳細（SQL、HTTP、SDK、シリアライザ等）を閉じ込める

#### Infra Adapter 依存性

- Domain（Port/Entity/Domain Error）
- 外部リソース（DB、HTTP、SDK、ファイル）

### Framework（フレームワーク層）

#### Framework 定義

最外周の I/O 層（Web/gRPC/CLI/Job Runner）

#### Framework 責務

- 入力変換（Request → UseCase Input）
- 認証・認可、ルーティング
- UseCase 呼び出し
- 出力変換（UseCase Output → Response、HTTP status 等）

#### Framework 依存性

- UseCase のみに依存（Domain 直触り禁止、Infra 直触り禁止）

## 3. Dependency Matrix（やってよい依存）

- **Domain →** 自前コード + 最小限の標準ライブラリ（例: `time`, `errors`）。`database/sql`, `net/http` など I/O 系は原則禁止。
- **UseCase →** Domain のみ（標準ライブラリは制御に必要な最小限は可）
- **Infra Adapter →** Domain + 外部ドライバ/SDK（ただし外へ漏らさない）
- **Framework →** UseCase（Infra の具象に直接触れず Composition Root 経由）

## 4. Error 境界ルール

- **Infra Adapter は driver error を直接返さない**
- **Domain/UseCase は domain/usecase error を返す**（アプリの意味を持つ）
- **Framework が transport error に変換する**（HTTP status、gRPC status、exit code 等）

## 5. Data 境界ルール

- **UseCase Input/Output は明示的な構造体で定義**
- **Entity を Framework DTO と混在させない**
- **Mapping の責務を固定する**（Framework か UseCase のどちらかに統一）

## 6. context.Context（Go）の扱い

- **役割**: キャンセル/タイムアウト/トレーシング等の横断情報
- **原則**: UseCase/Port の入口に `context.Context` を渡してよいが、Domain の Entity/ValueObject は `context` に依存しない（必要データは引数で渡す）

## 7. DI / Composition Root

- 具象の組み立ては **Main/Composition Root** に集約する（例: `cmd/<app>/main.go`）
- Framework は Port 実装（Infra Adapter）を知らず、UseCase 越しに呼ぶ

## 8. 典型ディレクトリ例（Go）

```text
cmd/app/main.go                  // composition root
internal/domain/...              // entity, domain service, ports, domain errors
internal/usecase/...             // interactors + input/output DTO
internal/infra/...               // db, external api, repo implementations
internal/framework/http/...      // handlers, middleware, routing
```

## 9. アンチパターン（即アウト）

- Domain に DB/HTTP/ORM/SDK の型が漏れる
- UseCase が SQL/HTTP を直接叩く（Port/Adapter 未分離）
- Framework が UseCase を迂回して Domain/Infra を直接操作する
- Infra Adapter がビジネス判断（条件分岐の本体）を持つ
