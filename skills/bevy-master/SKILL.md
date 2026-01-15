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
- **実装**: Bevy の慣習（`Startup` で初期化、`Update` で進行、入力 → ゲームロジック → 描画/反映の順序）に沿って、テスト可能な単位に分割する。

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

## Common Pitfalls (よくある間違い)

### ❌ 悪い例

```rust
// NG: Update で毎フレーム spawn
fn spawn_bullets(mut commands: Commands) {
    commands.spawn(BulletBundle::default());  // 際限なく増える
}

// NG: Query で &mut の競合
fn system1(mut query: Query<&mut Transform, With<Player>>) { /* ... */ }
fn system2(mut query: Query<&mut Transform, With<Player>>) { /* ... */ }
// 両方を同時実行すると競合エラー

// NG: System で重い処理
fn update(query: Query<&Position>) {
    for pos in query.iter() {
        expensive_calculation(pos);  // 毎フレーム heavy
    }
}
```

### ✅ 良い例

```rust
// OK: Event + 条件で spawn
fn spawn_on_event(
    mut commands: Commands,
    mut events: EventReader<ShootEvent>,
) {
    for event in events.read() {
        commands.spawn(BulletBundle::from(event));
    }
}

// OK: Query を分割、または順序制約
fn system1(mut query: Query<&mut Transform, (With<Player>, Without<Enemy>)>) { }
fn system2(mut query: Query<&mut Transform, With<Enemy>>) { }
// Or: .before(system2) で順序制御

// OK: 計算結果をキャッシュ、または非同期タスクへ
fn update(
    query: Query<(&Position, &mut CachedResult), Changed<Position>>,
) {
    // Changed でフィルタして必要な時だけ計算
}
```

## AI-Specific Guidelines (実装時の優先順位)

1. **Plugin で機能を隔離**: 各機能（player, enemy, ui など）を独立した Plugin に分け、`app.add_plugins()` で組み立てる。
2. **System の依存は明示**: 順序が重要なら `.before()` / `.after()` で明記。暗黙の依存を作らない。
3. **Query は最小限に**: `With/Without` でフィルタし、不要な Entity を走査しない。
4. **Component は小さく**: 巨大な Component より、複数の小さい Component で組み合わせる。
5. **State で制御**: メニュー/ゲーム中/ポーズなどを `States` で表現し、不要なシステムは該当 State でのみ実行。
6. **Startup で初期化**: エンティティ生成や Resource 初期化は `Startup` に集約し、`Update` を純粋に保つ。

## References

- [Bevy docs.rs (excerpt)](references/docsrs.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](../scripts/check.sh)
