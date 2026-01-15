# Common Pitfalls in Ebiten

## 1. Logic in Draw

`Draw` is called every frame (by default 60Hz), but Ebitengine may skip `Draw` frames if performance lags. Game logic here causes inconsistent game speed.

**❌ Bad:**

```go
func (g *Game) Draw(screen *ebiten.Image) {
    g.count++ // Logic!
    screen.DrawImage(g.img, nil)
}
```

**✅ Good:**

```go
func (g *Game) Update() error {
    g.count++ // Logic here
    return nil
}
```

## 2. Allocation in Game Loop

Creating new objects (structs, closures, specialized interfaces) every frame triggers the Garbage Collector (GC), causing lag spikes.

**❌ Bad:**

```go
func (g *Game) Draw(screen *ebiten.Image) {
    op := &ebiten.DrawImageOptions{} // Allocating every frame!
    op.GeoM.Translate(100, 100)
    screen.DrawImage(g.img, op)
}
```

**✅ Good:**
Reuse the options struct.

```go
type Game struct {
    op ebiten.DrawImageOptions
}

func (g *Game) Draw(screen *ebiten.Image) {
    g.op.GeoM.Reset()
    g.op.GeoM.Translate(100, 100)
    screen.DrawImage(g.img, &g.op)
}
```

## 3. Wrong Input Handling (Pressed vs JustPressed)

`IsKeyPressed` returns true _while_ the key is down. `IsKeyJustPressed` returns true only on the _first frame_.

**❌ Bad:**

```go
if ebiten.IsKeyPressed(ebiten.KeySpace) {
    g.Fire() // Fires 60 times a second!
}
```

**✅ Good:**

```go
if inpututil.IsKeyJustPressed(ebiten.KeySpace) {
    g.Fire() // Fires once
}
```

## 4. Large Image Loading

Do not call `ebiten.NewImageFromImage` or `image.Decode` inside `Update` or `Draw`. It kills performance.

**❌ Bad:**

```go
func (g *Game) Update() error {
    img, _ := ebitenutil.NewImageFromFile("sprite.png") // Terribly slow
    g.sprite = img
    return nil
}
```

**✅ Good:**
Load once during `init()` or a specialized `Load()` function called at startup.

## 5. GeoM Translate/Rotate Order

Matrix multiplication order matters. To rotate around a center: Translate to origin -> Rotate -> Translate back.

**❌ Bad:**

```go
// Rotates around (0,0) then moves, often looking like it orbits the origin
op.GeoM.Rotate(theta)
op.GeoM.Translate(x, y)
```

**✅ Good:**

```go
w, h := g.img.Size()
op.GeoM.Translate(-float64(w)/2, -float64(h)/2) // Center to origin
op.GeoM.Rotate(theta)
op.GeoM.Translate(x, y) // Move to destination
```
