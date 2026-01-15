# Common Pitfalls in Bevy

## 1. Mutable Query Conflicts

Two systems querying the same component with at least one `&mut` access cannot run in parallel if they match the same entities, unless explicitly ordered.

**❌ Bad:**

```rust
fn move_player(mut q: Query<&mut Transform, With<Player>>) { ... }
fn damage_player(mut q: Query<&mut Transform, With<Player>>) { ... }
// Bevy scheduler forces sequential execution, or panics if poorly configured
```

**✅ Good:**
Use explicitly disjoint queries or scheduling constraints.

```rust
app.add_systems(Update, (move_player, damage_player).chain());
```

## 2. Heavy Computation in Synchronous Systems

Running expensive tasks in a system blocks the main thread (or the task pool thread), dropping frame rates.

**❌ Bad:**

```rust
fn pathfinding_system(mut q: Query<&mut Path>) {
    for path in q.iter_mut() {
        *path = expensive_astar(); // Blocks frame
    }
}
```

**✅ Good:**
Use `AsyncComputeTaskPool` or spread work across frames.

## 3. Excessive Component Adds/Removes

Adding/removing components (`commands.entity(e).insert(...)`) changes the archetype, which moves memory. Doing this every frame for many entities is slow.

**❌ Bad:**

```rust
fn update(mut commands: Commands, q: Query<Entity>) {
    for e in q.iter() {
        commands.entity(e).insert(Marker); // Moves table row
        commands.entity(e).remove::<Marker>(); // Moves it back
    }
}
```

**✅ Good:**
Use a boolean field inside a component or a `State` if the change is frequent.

## 4. Resource vs Local State

Using `Local<T>` stores state inside the system itself, which is hidden from other systems. Using `Res<T>` makes it globally accessible. Confusing them breaks ownership models.

**❌ Bad:**

```rust
// If multiple systems need 'Score', don't use Local
fn score_system(mut score: Local<u32>) { ... }
```

**✅ Good:**

```rust
#[derive(Resource)]
struct Score(u32);

app.insert_resource(Score(0));
fn score_system(mut score: ResMut<Score>) { ... }
```
