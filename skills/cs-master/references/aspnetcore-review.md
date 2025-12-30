# ASP.NET Core Review Guide (Local)

## 1) Web Layer / Middleware
- Controller/endpoint は薄く（入力変換、認証/認可、ユースケース呼び出し、出力整形）。
- モデルバインディング/バリデーションの責務を境界に寄せ、内部で重複検証しない。
- 例外はグローバルに捕捉し、一貫したエラー形式にする（スタックトレースを返さない）。

## 2) DI Lifetimes
- **Singleton**: 状態を持たない/スレッドセーフのみ。`DbContext` や `HttpContext` 依存は禁止。
- **Scoped**: リクエスト単位の依存（多くのアプリサービス、`DbContext`）。
- **Transient**: 軽量・使い捨て。重い初期化や外部接続は避ける。

## 3) HTTP Client / Outbound Calls
- `HttpClient` の寿命管理を誤らない（使い捨て/新規生成の乱用は避ける）。
- タイムアウト/リトライ/サーキットは責務レイヤーを固定し、重複設定を避ける。

## 4) Operability
- 相関 ID を通し、構造化ログで検索可能にする。
- graceful shutdown で in-flight を扱う（バックグラウンド処理も含む）。
