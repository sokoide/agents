# C++ Core Guidelines (Local Summary)

目的: 「未定義動作を避け、例外安全・資源安全・並行安全をデフォルトにする」ための実務ルール集。

## What to Check First (Review Priorities)
- **Lifetime/Ownership**: 所有者が明確か、参照/ポインタの寿命が安全か（dangling を作っていないか）
- **Bounds**: 配列/スライスの範囲外アクセスが起きないか（インデックス/ポインタ算術）
- **Resource safety**: 例外や早期 return でも解放されるか（RAII）
- **Concurrency**: データ競合・ロック順序・共有可変状態が制御されているか

## Defaults (Expert Baselines)
- **Rule of Zero**: 自前のデストラクタ/コピー/ムーブが不要な設計を優先する。
- **Prefer value types**: 共有所有より値/単独所有（`unique_ptr`）を優先し、共有は必要性を説明できる場合に限定。
- **Express intent in types**: nullable を `T*` で表すなら必ず “nullable” である理由を明確にし、非nullable は `T&` を優先。
- **Minimize raw loops when it helps**: ただし可読性が落ちるなら無理に `<algorithm>` に寄せない。

## Common “Stop the Line” Issues
- 参照/`string_view`/`span` の返却が寿命違反（ローカル・一時の参照）
- move 後オブジェクトの誤用、二重解放、所有権の二重化
- デストラクタから例外送出、例外境界の曖昧さ（basic/strong/no-throw 不明）
- 共有可変状態を無制限に露出（`shared_ptr<T>` + `T` が可変、など）

## Optional Source
原典参照は必要時のみ（外部リンクは本リポジトリには保持しない）。
