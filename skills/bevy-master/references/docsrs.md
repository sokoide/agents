# Bevy docs.rs (Excerpt)

Source: <https://docs.rs/bevy/latest/bevy/>

This file contains excerpts and summaries of "frequently referenced types/concepts" from docs.rs for local reference.

## App / Schedules

- `bevy::app::App`: The app's entry point. Handles adding plugins, systems, and execution.

App (Type declaration):

```rust
pub struct App { /* private fields */ }
```

Schedule labels (Excerpts):

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

The main design goal is to "create Plugin boundaries for each feature and register Resources/Systems in `build`."

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

`Commands` (Used to issue commands like creating/destroying entities within systems):

```rust
pub struct Commands { /* private fields */ }
```

`Query` (For retrieving ECS data. Can be narrowed down with Filters):

```rust
pub struct Query<'world, 'state, D, F = ()>
where
    D: QueryData,
    F: QueryFilter,
{ /* private fields */ }
```

`Res` / `ResMut` (Shared or mutable access to a Resource):

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

Start with `App::new()`, register plugins and systems, then call `run()`:

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
