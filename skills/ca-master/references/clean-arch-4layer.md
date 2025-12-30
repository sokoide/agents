
- Framework は UseCase を呼び出すだけ
- Infra Adapter は Domain の Port を実装する
- Domain は外部に一切依存しない

---

## 2. 各レイヤーの定義と責務

### Domain（ドメイン層）

**定義**  
ビジネスルールそのものを表現する心臓部。

**構成要素**
- Entity
- Domain Service
- Repository / Gateway Interface（Port）

**責務**
- ビジネスルールの定義
- 永続化・外部連携に対する抽象契約

**依存性**
- 外部依存ゼロ

---

### UseCase（ユースケース層）

**定義**  
アプリケーションとしての具体的な「機能」の手順。

**責務**
- Domain オブジェクトの操作
- 処理の流れ（オーケストレーション）

**依存性**
- Domain のみに依存
- Infra / Framework の存在を知らない

---

### Infra Adapter（インフラアダプタ層）

**定義**  
外部システムとの橋渡しと技術的実装。

**構成要素**
- Repository / Gateway の実装
- DB・外部 API・File system 連携

**責務**
- Domain Port の具体化
- Driver Error を Domain / UseCase 向けに変換

**依存性**
- Domain / UseCase の Interface
- 外部リソース

---

### Framework（フレームワーク層）

**定義**  
最外周の I/O 層。

**構成要素**
- Web / gRPC / CLI
- Controller / Handler / Router

**責務**
- 入力変換（DTO）
- 認証・認可
- UseCase 呼び出し
- レスポンス整形（HTTP status 等）

**依存性**
- UseCase のみに依存

---

## 3. Error 境界ルール

- Infra Adapter は driver error を直接返さない
- Domain / UseCase は domain error を返す
- Framework が transport error に変換する

---

## 4. Data 境界ルール

- UseCase input / output は明示的な構造体で定義する
- Entity を Framework DTO と混在させない
- Mapping の責務を一貫させる（Framework or UseCase に固定）

---

## 5. context.Context の扱い（Go）

### 役割
- キャンセル伝搬
- タイムアウト管理
- トレーシング

### 使い分け
- **引数**：ビジネスロジックに必須なデータ（userID 等）
- **context**：横断的・付加的情報（request ID 等）

---

## 6. 依存性の注入（DI）

- Infra Adapter の具象を UseCase に直接依存させない
- Main / Composition Root で Port に注入する

