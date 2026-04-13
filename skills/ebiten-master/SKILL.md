---
name: ebiten-master
description: >
    Ebitengine (Ebiten) expert for Go 2D games. Use for:
    (1) Designing/implementing/reviewing Ebiten game loops.
    (2) Rendering (Image/GeoM/ColorScale) optimization.
    (3) Input handling with performance-conscious patterns.
    (4) Go 2D game development guidance.
---

# Ebiten Master

This skill provides expert-level Ebitengine (Ebiten) guidance for Go 2D game development.

## Related Tools

This skill uses: Bash (for go commands), Glob, Grep, Read, Edit, Write

## First Questions (Ask Up Front)

- Ebitengine version (e.g., tag of `github.com/hajimehoshi/ebiten/v2`), Go version, Target (desktop/web/mobile).
- Screen specifications: Logical resolution (`Layout` return value), window size / full screen, scaling policy (pixel-perfect / stretched).
- Assets: Image loading method, presence of sprite sheets, Fonts/Audio (if needed).
- Input requirements: Key/Mouse/Gamepad, rapid-fire / toggle / long-press detection, rebind requirements.
- Performance requirements: Target FPS, resolution, number of simultaneous sprites, GC tolerance.

## Output Contract (How to Respond)

- **Design/Review**: Classify points as "Game Loop / Rendering / Input / Assets / Performance / Style," providing brief rationale based on Ebitengine API specs (cheatsheet) and Go conventions.
- **Proposed Correction**: Prioritize separation of concerns (state, scene, resource management) and allocation reduction (eliminating per-frame generation/decoding); then fix bugs in coordinate systems, transformations, or input with minimal diffs.
- **Code Examples**: Provide diffs for necessary parts assuming a minimal implementation of `Update/Draw/Layout` (Avoid unnecessary framework-building).

## Design & Coding Rules (Expert Defaults)

1. **Update for Logic, Draw for Rendering**: Do not mix rendering into `Update`. `Draw` should not change state (minimal side effects).
2. **Determine Logical Resolution in Layout**: Do not confuse logical coordinate systems (in-game coordinates) with external sizes (window/device).
3. **Do Not Allocate Every Frame**: Avoid creating `DrawImageOptions` / `GeoM` / `ColorScale` or calling `image.Decode` within loops. Reuse or cache them.
4. **Explicit Transformation Order**: The result changes based on the order of `GeoM.Translate/Scale/Rotate`. Represent rotation/scaling centers as "Move to origin → Rotate/Scale → Move back."
5. **Use Input Edges**: For toggles or single actions, use `inpututil.IsKeyJustPressed` / `inpututil.IsMouseButtonJustPressed`; use `ebiten.IsKeyPressed` for continuous holding.
6. **Own *ebiten.Image for Images**: Since `SubImage` returns `image.Image`, convert/manage it as `*ebiten.Image` if necessary (Extract sprite sheets only once).
7. **TPS/FPS Control**: Rely on TPS (default 60) for physics calculations and control resize behavior with `ebiten.SetWindowResizingMode`.
8. **Audio Context**: Manage `audio.Context` as a singleton to avoid initialization costs and resource leaks.

## Review Checklist (High-Signal)

- **Game Loop**: Is state updated based on the tick (1/60s)? Is `Update`'s `error` propagation appropriate?
- **Layout/Scaling**: Is the design for fixed logical resolution or matching the exterior clear? Do coordinate transformations and mouse coordinates align?
- **Rendering**: Reuse of `DrawImage` options, choice of `FilterNearest/FilterLinear`, and usage of `Clear/Fill`.
- **Transforms**: `GeoM` order, rotation center, scale, and snapping to integer coordinates (to prevent jitter in pixel art).
- **Input**: Misuse of edge detection (triggering every frame), simultaneous presses, and priority of UI vs Game input.
- **Performance/GC**: Excessive use of `fmt` or `ebitenutil.DebugPrint` in hot paths, image generation/copying, redundant `SubImage` generation, and reuse of object pools/slices.

## Common Pitfalls

### ❌ Bad Examples

```go
// NG: Drawing in Update
func (g *Game) Update() error {
    screen.DrawImage(sprite, nil)  // Update is only for state changes
    return nil
}

// NG: Generating DrawImageOptions every frame
func (g *Game) Draw(screen *ebiten.Image) {
    for _, obj := range g.objects {
        op := &ebiten.DrawImageOptions{}  // GC pressure
        op.GeoM.Translate(obj.X, obj.Y)
        screen.DrawImage(obj.Image, op)
    }
}

// NG: Continuous trigger while holding
func (g *Game) Update() error {
    if ebiten.IsKeyPressed(ebiten.KeySpace) {
        g.Shoot()  // Fires every frame
    }
    return nil
}
```

### ✅ Good Examples

```go
// OK: Update only for state
func (g *Game) Update() error {
    g.player.X += g.velocity
    return nil
}

// OK: Reuse DrawImageOptions
type Game struct {
    drawOp ebiten.DrawImageOptions  // Reused in a field
}

func (g *Game) Draw(screen *ebiten.Image) {
    for _, obj := range g.objects {
        g.drawOp.GeoM.Reset()
        g.drawOp.GeoM.Translate(obj.X, obj.Y)
        screen.DrawImage(obj.Image, &g.drawOp)
    }
}

// OK: Detect single press with JustPressed
func (g *Game) Update() error {
    if inpututil.IsKeyJustPressed(ebiten.KeySpace) {
        g.Shoot()  // Only when first pressed
    }
    return nil
}
```

## AI-Specific Guidelines (Priorities for Implementation)

1. **Strict Separation of Update/Draw**: State changes in `Update`, rendering only in `Draw`. Do not mix.
2. **Return Logical Resolution in Layout**: Separate in-game coordinates from window size and maintain consistency.
3. **Prohibit Per-Frame Allocation**: Reuse `DrawImageOptions`, `GeoM`, and `ColorScale`.
4. **Use Edge Detection for Input**: `inpututil.IsKeyJustPressed` for toggles/single shots, `ebiten.IsKeyPressed` for holds.
5. **Be Mindful of GeoM Order**: The result changes based on the order of transformations (translate/rotate/scale); document intent in comments.
6. **Load Images Only Once**: Extract sprite sheets during initialization; do not generate `SubImage` every frame.
7. **Shader Utilization**: Offload complex pixel operations to Kage (Shading Language) instead of the CPU.

## References

- [Ebitengine Cheatsheet (excerpt)](references/cheatsheet.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](scripts/check.sh)
