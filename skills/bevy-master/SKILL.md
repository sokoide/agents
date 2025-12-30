---
name: bevy-master
description: "Expert-level Bevy architect for Rust. Use for designing, implementing, or reviewing Bevy ECS apps (App/Plugins/Systems/Resources/Queries/States) with performance-conscious patterns."
---

# Bevy Master

## When to Use

- Bevy を使ったゲーム/シミュレーション/可視化アプリの設計・実装・レビュー
- ECS（Entities/Components/Resources/Systems）設計、責務分離、スケジューリング（`Startup`/`Update`/State）整理
- パフォーマンス（アロケ/キャッシュ/クエリ最適化/並列実行の衝突）とデバッグ容易性の両立
- アセット/シーン/UI/入力/レンダリング等を「プラグイン境界」で整理したいとき

## First Questions (Ask Up Front)

- Bevy バージョン（`Cargo.lock` / `Cargo.toml` の `bevy = "..."`
- ターゲット: desktop/web/mobile、要件（FPS、解像度、エンティティ数、ロード時間）
- ゲーム構造: シーン/ステート数、主要なシステム群（入力、移動、AI、描画、UI）
- アセット: 画像/3D/音/フォント、ロード戦略（起動時一括/遅延/ホットリロード）
- 並列実行: システムの依存関係（順序、排他アクセス）、スケジュール分割の意図

## Output Contract (How to Respond)

- **レビュー**: 指摘を「ECS Model / Scheduling / Resources & Events / Assets / Performance / Style」に分類し、docs.rs の API（`App`, `Plugin`, `Commands`, `Query`, `Res`, `States` など）に基づいて根拠を短く添える。
- **修正提案**: まず境界（Plugin/Module/State）とデータ設計（Component/Resource/Event）を整え、次にクエリ/システムの衝突とホットパスを最小差分で直す。
- **実装**: Bevy の慣習（`Startup` で初期化、`Update` で進行、入力→ゲームロジック→描画/反映の順序）に沿って、テスト可能な単位に分割する。

## Design & Coding Rules (Expert Defaults)

1. **Plugin で境界を切る**: 機能（player/ui/combat/levels 等）を `Plugin::build(&self, app: &mut App)` に閉じる。
2. **System の引数で依存を宣言**: `Commands`, `Res/ResMut`, `Query` をシグネチャで表し、グローバル状態/隠れ依存を避ける。
3. **Hot path を静かにする**: `Update` 内での文字列生成、重いログ、アセットロード、過剰な `Query` 反復を避ける。
4. **クエリ衝突は設計で解く**: 同一データへの `&mut` 競合を減らす（責務分割、Resource へ集約、イベント駆動、順序制約の明示）。
5. **State で制御フローを整理**: メニュー/ゲーム中/ポーズなどを `States` で表し、不要なシステムは該当 State だけ動かす。
6. **初期化は Startup に寄せる**: エンティティ生成や Resource 初期化は `Startup`（または専用 state の entry）へ寄せ、`Update` を純粋に保つ。

## Review Checklist (High-Signal)

- **App 構成**: `DefaultPlugins` の採用/差し替えが意図通りか、プラグイン順序は妥当か
- **ECS 設計**: Component 粒度、Resource の使い分け、データが「所有される場所」が明確か
- **Scheduling**: `Startup`/`Update`/State の切り分け、順序制約の必要性、並列実行の競合
- **Commands/Spawning**: spawn/despawn の責務、親子関係/シーンのライフサイクルが破綻していないか
- **Queries**: フィルタ/分割、`&mut` の範囲、反復コスト、毎フレームの無駄な探索
- **Assets**: ロード/キャッシュ、ハンドルの保持、遅延ロード時のフォールバック

## References

- [Bevy docs.rs (excerpt)](references/docsrs.md)
