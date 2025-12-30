# Bevy docs.rs (Excerpt)

Source: <https://docs.rs/bevy/latest/bevy/>

このファイルは、docs.rs の「高頻度で参照する型/概念」をローカルで参照できるように抜粋・要約したものです。

## App / Schedules

- `bevy::app::App`: アプリのエントリ。プラグイン追加、システム追加、実行を担う。

App（型宣言）:

```rust
pub struct App { /* private fields */ }
```

Schedule labels（抜粋）:

```rust
pub struct Startup;
pub struct Update;
```

## Plugins

```rust
pub trait Plugin:
    Downcast
    + Any
    + Send
    + Sync {
    fn build(&self, app: &mut App);
}
```

設計の主戦場は「機能ごとに Plugin 境界を作り、`build` で Resource/Systems を登録する」こと。

## ECS: Component / Resource

```rust
pub trait Component:
    Send
    + Sync
    + 'static { /* ... */ }
```

```rust
pub trait Resource:
    Send
    + Sync
    + 'static { }
```

## Systems: Commands / Query / Res

`Commands`（システム内でエンティティ作成/破棄などのコマンドを発行）:

```rust
pub struct Commands { /* private fields */ }
```

`Query`（ECS のデータ取得。Filter で絞り込み可能）:

```rust
pub struct Query<'world, 'state, D, F = ()>
where
    D: QueryData,
    F: QueryFilter,
{ /* private fields */ }
```

`Res` / `ResMut`（Resource の共有/可変アクセス）:

```rust
pub struct Res<'w, T>
where
    T: Resource + ?Sized,
{ /* private fields */ }
```

```rust
pub struct ResMut<'w, T>
where
    T: Resource + ?Sized,
{ /* private fields */ }
```

## States

```rust
pub trait States:
    'static
    + Send
    + Sync
    + Clone
    + PartialEq
    + Eq
    + Hash
    + Debug { /* ... */ }
```

## Minimal App Pattern (from docs.rs examples)

`App::new()` から始め、プラグインとシステムを登録して `run()` する:

```rust
use bevy::prelude::*;

fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_systems(Startup, setup)
        .add_systems(Update, update)
        .run();
}

fn setup(mut commands: Commands) {
    // spawn initial entities/resources
}

fn update() {
    // per-frame logic
}
```
