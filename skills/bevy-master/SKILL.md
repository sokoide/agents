---
name: bevy-master
description: >
    Expert-level Bevy architect for Rust. Use for:
    (1) Designing/implementing/reviewing Bevy ECS apps (App/Plugins/Systems/Resources/Queries/States).
    (2) ECS design, separation of concerns, scheduling (Startup/Update/State).
    (3) Performance-conscious patterns (allocation/cache/query optimization) and debugging.
    (4) Organizing assets/scenes/UI/input/rendering with 'Plugin boundaries'.
---

# Bevy Master

This skill provides expert-level Bevy ECS guidance for Rust game/simulation/visualization applications.

## Related Tools

This skill uses: Bash (for cargo commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Bevy version (Check `bevy = "..."` in `Cargo.lock` / `Cargo.toml`).
- Target: desktop/web/mobile, Requirements (FPS, resolution, number of entities, load time).
- Game structure: Scenes/States, main system groups (Inpuy, Movement, AI, Rendering, UI).
- Assets: Image/3D/Sound/Font, loading strategy (Batch at startup / Lazy / Hot reload).
- Parallel execution: System dependencies (Order, exclusive access), intention behind schedule splitting.

## Output Contract (How to Respond)

- **Review**: Classify points as "ECS Model / Scheduling / Resources & Events / Assets / Performance / Style," and provide brief rationale based on docs.rs API (`App`, `Plugin`, `Commands`, `Query`, `Res`, `States`, etc.).
- **Proposed Correction**: First, organize boundaries (Plugin/Module/State) and data design (Component/Resource/Event), then fix query/system conflicts and hot paths with minimal diffs.
- **Implementation**: Follow Bevy conventions (`Startup` for initialization, `Update` for progression, Order: Input → Game Logic → Rendering/Reflection) and split into testable units.

## Design & Coding Rules (Expert Defaults)

1. **Enforce Boundaries with Plugins**: Encapsulate features (player/ui/combat/levels etc.) within `Plugin::build(&self, app: &mut App)`.
2. **Declare Dependencies in System Signatures**: Represent `Commands`, `Res/ResMut`, and `Query` in the signature to avoid global state/hidden dependencies.
3. **Keep the Hot Path Quiet**: Avoid string generation, heavy logging, asset loading, or excessive `Query` iterations within `Update`.
4. **Resolve Query Conflicts via Design**: Reduce `&mut` contention for the same data (responsibility splitting, aggregation to Resources, event-driven, explicit ordering).
5. **Organize Flow with States**: Represent Menu / In-game / Pause etc. using `States`, running necessary systems only in the appropriate State.
6. **Centralize Initialization in Startup**: Perform entity spawning or Resource initialization in `Startup` (or entry of a dedicated state) to keep `Update` pure.

## Review Checklist (High-Signal)

- **App Configuration**: Check if use/replacement of `DefaultPlugins` is intentional and if plugin order is appropriate.
- **ECS Design**: Check Component granularity, appropriate use of Resources, and clarity of data "ownership."
- **Scheduling**: Check segregation of `Startup`/`Update`/State, need for order constraints, and parallel execution conflicts.
- **Commands/Spawning**: Check spawn/despawn responsibilities and integrity of Parent-Child relationships / Scene lifecycle.
- **Queries**: Check filtering/splitting, `&mut` scope, iteration cost, and redundant searches per frame.
- **Assets**: Check loading/caching, handle retention, and fallback during lazy loading.

## Common Pitfalls

### ❌ Bad Examples

```rust
// NG: Spawning every frame in Update
fn spawn_bullets(mut commands: Commands) {
    commands.spawn(BulletBundle::default());  // Increases indefinitely
}

// NG: &mut Conflict in Query
fn system1(mut query: Query<&mut Transform, With<Player>>) { /* ... */ }
fn system2(mut query: Query<&mut Transform, With<Player>>) { /* ... */ }
// Running both simultaneously causes a conflict error

// NG: Heavy computation in a System
fn update(query: Query<&Position>) {
    for pos in query.iter() {
        expensive_calculation(pos);  // Heavy every frame
    }
}
```

### ✅ Good Examples

```rust
// OK: Spawning based on Event + Condition
fn spawn_on_event(
    mut commands: Commands,
    mut events: EventReader<ShootEvent>,
) {
    for event in events.read() {
        commands.spawn(BulletBundle::from(event));
    }
}

// OK: Splitting Query or Order Constraints
fn system1(mut query: Query<&mut Transform, (With<Player>, Without<Enemy>)>) { }
fn system2(mut query: Query<&mut Transform, With<Enemy>>) { }
// Or: Control order with .before(system2)

// OK: Cache computation result or move to Async Task
fn update(
    query: Query<(&Position, &mut CachedResult), Changed<Position>>,
) {
    // Filter with Changed and calculate only when necessary
}
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Isolate Features with Plugins**: Separate each feature (player, enemy, ui, etc.) into an independent Plugin and assemble them with `app.add_plugins()`.
2. **Explicit System Dependencies**: For important ordering, specify with `.before()` / `.after()`. Avoid implicit dependencies.
3. **Minimize Queries**: Use `With/Without` filters to avoid scanning unnecessary Entities.
4. **Small Components**: Prefer combining multiple small Components over using a single massive Component.
5. **Control with States**: Represent Menu / In-game / Pause etc. with `States` and execute systems only in the appropriate State.
6. **Initialize in Startup**: Aggregate entity spawning and Resource initialization in `Startup` to keep `Update` pure.

## References

- [Bevy docs.rs (excerpt)](references/docsrs.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](scripts/check.sh)
