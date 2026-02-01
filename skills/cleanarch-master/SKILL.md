---
name: cleanarch-master
description: >
    Clean Architecture master for Go-style 4-layer architecture. Enforces strict
    dependency rules, domain ownership of ports, and clear separation between Framework
    and Infra Adapters. Use for:
    (1) Clean Architecture design/review/refactoring in Go.
    (2) Resolving layer boundary violations (Domain with external deps, UseCase with DB/HTTP).
    (3) Dependency injection (Composition Root) and Port/Adapter separation.
    (4) Enforcing 4-layer strict dependency rules.
---

# Clean Architecture Master

This skill provides Clean Architecture (4-layer) guidance for Go applications, enforcing strict dependency rules and domain ownership of ports.

## Related Tools

This skill uses: Bash (for go commands), Glob, Grep, Read, Edit, Write

## Core Philosophy

This skill **strictly follows the rules defined in** [`references/clean-arch-4layer.md`](references/clean-arch-4layer.md).

All reviews, judgments, and refactoring advice **MUST conform to that document**.

1. **Domain-Centricity**
   ソフトウェアの価値は Domain（ビジネスルール）にある。
   DB・HTTP・Framework は交換可能な詳細である。

2. **Strict Dependency Rule**
   依存関係は常に外側から内側へ向かう。
   Domain は何者にも依存しない。

3. **Explicit Outer Layers**
   外側を以下の 2 種類に分離する。
    - **Framework Layer**（Web / gRPC / CLI）
    - **Infra Adapter Layer**（DB / 外部 API / File）

## Output Contract (How to Respond)

- **診断**: 依存方向違反（import/参照）・責務混入・データ境界/エラー境界の破れを列挙する。
- **修正**: 「Port 定義 → Adapter 切り出し → Framework を薄く」の順で、最小差分の段階的手順を提示する。
- **言い切り条件**: この skill では "好み" ではなく "規約違反" を明確に判定する（根拠は reference）。

## Layer Definitions (Summary)

> 詳細定義は **references/clean-arch-4layer.md** を正とする。

### Domain Layer

- Entity
- Domain Service
- **Repository / Gateway Interface（Port）**
- 外部ライブラリ・外部エラー型に依存しない

### UseCase Layer

- アプリケーション固有の手順（Orchestration）
- Domain の Port を利用する
- 技術的詳細を知らない

### Infra Adapter Layer

- Domain が定義した Port を具体的に実装
- DB / 外部 API / File system 等の技術詳細を含む
- Driver Error を Domain / UseCase 向けに変換する

### Framework Layer

- Web / gRPC / CLI / Job Runner
- 入力変換、認証、レスポンス整形
- UseCase を呼び出すだけ
- Infra Adapter の詳細を直接扱わない

## Review Checklist (Required Output)

- **Dependency Direction**: Domain が外部 package を import していないか、UseCase が Infra Adapter に直接依存していないか、Framework が Domain を直接操作していないか
- **Responsibility Boundaries**: Entity に I/O や手続きが混入していないか、UseCase がビジネスルールを持ちすぎていないか、Infra Adapter が判断ロジックを持っていないか
- **Port Design**: Repository / Gateway interface が Domain に定義されているか、インターフェースが SQL / HTTP などの技術詳細を漏らしていないか
- **Error Boundary**: Infra Adapter が driver error をそのまま返していないか、Domain / UseCase が domain error を返しているか、Framework が transport error（HTTP status 等）に変換しているか
- **Data Boundary**: UseCase input / output が明確に定義されているか、Entity が Framework DTO と混在していないか、Mapping の責務が一貫しているか
- **Transaction Management**: UseCase 層がトランザクション境界を制御しているか、`sql.Tx` などの技術詳細が Domain/UseCase に漏れていないか
- **Configuration Injection**: 設定値（Config struct）は UseCase/Adapter に注入され、Domain は設定値を知らない状態になっているか

## Common Violations (Fast Smell List)

- Domain に `database/sql`, `net/http`, ORM/SDK の型が漏れている
- UseCase が SQL/HTTP/ファイル I/O を直接扱う（Adapter 未分離）
- Framework が Entity を直接永続化/変換し、UseCase を迂回する
- Infra Adapter が domain decision（ビジネス判断）を持つ
- driver error（SQL エラー等）が境界を越えて上位に漏れる

## AI-Specific Guidelines (実装時の優先順位)

1. **依存方向を最優先**: 技術的な容易さ（ライブラリの便利機能等）よりも、レイヤー境界と依存方向の遵守を優先する。
2. **型を安易に共有しない**: レイヤーを跨ぐ際は、面倒でも DTO や Mapping を定義し、Entity が外部（Framework/Infra）の都合に染まらないようにする。
3. **Port は Domain が定義**: 「何が必要か」を Domain が決め、「どう実現するか」を Adapter が決める。インターフェースの定義場所を間違えない。
4. **Error は抽象化**: データベース固有のエラー（`sql.ErrNoRows` 等）を UseCase 以上に漏らさない。必ず Domain Error に変換する。
5. **Context の伝播**: トランザクションやトレース情報の伝播に `context.Context` を正しく使い、関数のシグネチャを一貫させる。

## Positioning

- This skill enforces **architectural correctness**, not coding style.
- Framework や ORM の流儀より **参照規約を優先**する。

## References

- [Clean Arch](references/clean-arch-4layer.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](../scripts/check.sh)
