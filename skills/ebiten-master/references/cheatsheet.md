# Ebitengine Cheatsheet (Excerpt)

Source: <https://ebitengine.org/en/documents/cheatsheet.html>

This file contains excerpts of "essential API fragments" from the above cheatsheet for local reference.

## Game Loop

### `ebiten.Game`

```go
type Game interface {
    // Update updates a game by one tick.
    Update() error

    // Draw draw the game screen. The given argument represents a screen image.
    Draw(screen *Image)

    // Layout accepts a native outside size in device-independent pixels and returns the game's logical
    // screen size. On desktops, the outside is a window or a monitor (fullscreen mode)
    //
    // Even though the outside size and the screen size differ, the rendering scale is automatically
    // adjusted to fit with the outside.
    //
    // You can return a fixed screen size if you don't care, or you can also return a calculated screen
    // size adjusted with the given outside size.
    Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int)
}
```

### `ebiten.RunGame`

```go
func RunGame(game Game) error
```

`RunGame` returns an `error` in the following cases:

- When an OpenGL error occurs.
- When an audio error occurs.
- When `game.Update` returns an `error` (the same error is returned).

## Graphics

### `ebiten.Image`

```go
type Image struct {
    // contains filtered or unexported fields
}

func NewImage(width, height int) *Image
func NewImageFromImage(source image.Image) *Image

func (i *Image) Clear()
func (i *Image) Fill(clr color.Color)
func (i *Image) Size() (width, height int)
func (i *Image) SubImage(r image.Rectangle) image.Image
func (i *Image) DrawImage(img *Image, options *DrawImageOptions)
```

### `ebiten.DrawImageOptions`

```go
type DrawImageOptions struct {
    GeoM       GeoM
    ColorScale ColorScale
    Blend      Blend
    Filter     Filter
}
```

### `ebiten.Filter`

```go
type Filter int

const (
    FilterNearest
    FilterLinear
)
```

### `ebiten.GeoM`

```go
type GeoM struct {
    // contains filtered or unexported fields
}

func (g *GeoM) Translate(tx, ty float64)
func (g *GeoM) Scale(x, y float64)
func (g *GeoM) Rotate(theta float64)
```

### `ebiten.ColorScale`

```go
type ColorScale struct {
    // contains filtered or unexported fields
}

func (c *ColorScale) Scale(r, g, b, a float32)
func (c *ColorScale) ScaleAlpha(a float32)
```

### `ebitenutil.DebugPrint`

```go
func DebugPrint(image *ebiten.Image, str string)
```

## Input

### Keyboard

```go
func IsKeyPressed(key Key) bool
```

```go
func IsKeyJustPressed(key ebiten.Key) bool
```

Refer to the cheatsheet for `ebiten.Key` constants (e.g., `KeyA`, `KeyArrowLeft`, `KeySpace`).

### Mouse

```go
func CursorPosition() (x, y int)
func IsMouseButtonPressed(mouseButton MouseButton) bool
```

```go
func IsMouseButtonJustPressed(button ebiten.MouseButton) bool
```

```go
type MouseButton int

const (
    MouseButtonLeft MouseButton
    MouseButtonRight
    MouseButtonMiddle
)
```
