---
name: ebiten-master
description: "Ebitengine (Ebiten) expert for Go 2D games. Use for designing, implementing, or reviewing Ebiten game loops, rendering (Image/GeoM/ColorScale), and input handling with performance-conscious patterns."
---

# Ebiten Master

## When to Use

- Ebitengine (Ebiten) を使った 2D ゲーム実装/改善/レビュー
- ゲームループ（`Update/Draw/Layout`）の設計、状態管理、入力/描画の責務分離
- 画像描画（`DrawImageOptions`, `GeoM`, `ColorScale`）の変換・パフォーマンス最適化
- 入力（`ebiten` + `inpututil`）の edge 検出・操作設計

## First Questions (Ask Up Front)

- Ebitengine バージョン（例: `github.com/hajimehoshi/ebiten/v2` のタグ）、Go バージョン、ターゲット（desktop/web/mobile）
- 画面仕様: 論理解像度（`Layout` の戻り値）、ウィンドウサイズ/フルスクリーン、スケーリング方針（pixel-perfect/伸縮）
- アセット: 画像読み込み方法、スプライトシート有無、フォント/音（要否）
- 入力要件: キー/マウス/ゲームパッド、連射/トグル/長押し判定、リバインド要否
- 性能要件: FPS 目標、解像度、同時スプライト数、GC 許容量

## Output Contract (How to Respond)

- **設計/レビュー**: 指摘を「Game Loop / Rendering / Input / Assets / Performance / Style」に分類し、Ebitengine の API 仕様（cheatsheet）と Go の慣習に基づいて短く根拠を添える。
- **修正提案**: まず責務分離（状態・シーン・リソース管理）と割り当て削減（毎フレームの生成/デコード排除）を優先し、次に座標系/変換/入力のバグを最小差分で直す。
- **コード例**: `Update/Draw/Layout` の最小実装を前提に、必要箇所だけ差分で提示する（不要なフレームワーク化はしない）。

## Design & Coding Rules (Expert Defaults)

1. **Update は論理、Draw は描画**: `Update` にレンダリングを混ぜない。`Draw` は状態を変更しない（副作用最小）。
2. **Layout で論理解像度を決める**: 論理座標系（ゲーム内座標）と外側サイズ（ウィンドウ/デバイス）を混同しない。
3. **毎フレーム allocate しない**: `DrawImageOptions` / `GeoM` / `ColorScale` の作成や `image.Decode` をループ内でしない。再利用・キャッシュする。
4. **変換順序を明示**: `GeoM.Translate/Scale/Rotate` の順序で結果が変わる。回転中心/拡大中心は「原点移動 → 回転/拡大 → 戻す」で表現する。
5. **入力は edge を使う**: トグル/単発アクションは `inpututil.IsKeyJustPressed` / `inpututil.IsMouseButtonJustPressed` を使い、押しっぱなしは `ebiten.IsKeyPressed`。
6. **画像は \*ebiten.Image を所有する**: `SubImage` は `image.Image` を返すので、必要なら `*ebiten.Image` へ変換/管理（スプライトシートの切り出しは一度だけ）。
7. **TPS/FPS Control**: 物理演算は TPS (default 60) に依存させ、`ebiten.SetWindowResizingMode` でリサイズ挙動を制御する。
8. **Audio Context**: `audio.Context` はシングルトンとして管理し、初期化コストとリソースリークを防ぐ。

## Review Checklist (High-Signal)

- **Game Loop**: `Update` の tick 前提（1/60s）で状態更新できているか、`Update` の `error` 伝播が適切か
- **Layout/Scaling**: 論理解像度固定 or 外側に合わせる設計が明確か、座標変換/マウス座標の扱いが一致しているか
- **Rendering**: `DrawImage` の option 再利用、`FilterNearest/FilterLinear` の選択、`Clear/Fill` の使い方
- **Transforms**: `GeoM` の順序、回転中心、スケール、整数座標へのスナップ（pixel art のブレ対策）
- **Input**: edge 判定の誤用（毎フレーム反応してしまう）、同時押し、UI/ゲーム入力の優先順位
- **Performance/GC**: ホットパスの `fmt`/`ebitenutil.DebugPrint` 多用、画像生成/コピー、`SubImage` の多重生成、オブジェクトプール/スライス再利用

## Common Pitfalls (よくある間違い)

### ❌ 悪い例

```go
// NG: Update で描画
func (g *Game) Update() error {
    screen.DrawImage(sprite, nil)  // Update は状態変更のみ
    return nil
}

// NG: 毎フレーム DrawImageOptions を生成
func (g *Game) Draw(screen *ebiten.Image) {
    for _, obj := range g.objects {
        op := &ebiten.DrawImageOptions{}  // GC 圧
        op.GeoM.Translate(obj.X, obj.Y)
        screen.DrawImage(obj.Image, op)
    }
}

// NG: 押しっぱなしで連続発火
func (g *Game) Update() error {
    if ebiten.IsKeyPressed(ebiten.KeySpace) {
        g.Shoot()  // 毎フレーム発射
    }
    return nil
}
```

### ✅ 良い例

```go
// OK: Update は状態のみ
func (g *Game) Update() error {
    g.player.X += g.velocity
    return nil
}

// OK: DrawImageOptions を再利用
type Game struct {
    drawOp ebiten.DrawImageOptions  // フィールドで再利用
}

func (g *Game) Draw(screen *ebiten.Image) {
    for _, obj := range g.objects {
        g.drawOp.GeoM.Reset()
        g.drawOp.GeoM.Translate(obj.X, obj.Y)
        screen.DrawImage(obj.Image, &g.drawOp)
    }
}

// OK: JustPressed で単発検出
func (g *Game) Update() error {
    if inpututil.IsKeyJustPressed(ebiten.KeySpace) {
        g.Shoot()  // 押した瞬間だけ
    }
    return nil
}
```

## AI-Specific Guidelines (実装時の優先順位)

1. **Update/Draw を厳格に分離**: `Update` で状態変更、`Draw` で描画のみ。混ぜない。
2. **Layout で論理解像度を返す**: ゲーム内座標系とウィンドウサイズを分離し、一貫性を保つ。
3. **毎フレーム allocate 禁止**: `DrawImageOptions`, `GeoM`, `ColorScale` は再利用する。
4. **入力は edge 検出**: トグル/単発は `inpututil.IsKeyJustPressed`、ホールドは `ebiten.IsKeyPressed`。
5. **GeoM の順序を意識**: 変換の順序（translate/rotate/scale）で結果が変わる。コメントで意図を明記。
6. **画像は一度だけロード**: スプライトシートの切り出しは初期化時に行い、`SubImage` を毎フレーム生成しない。
7. **Shader Utilization**: 複雑なピクセル操作は CPU ではなく Kage (Shading Language) にオフロードする。

## References

- [Ebitengine Cheatsheet (excerpt)](references/cheatsheet.md)
- [Common Pitfalls](references/pitfalls.md)

## Resources & Scripts

- [Code Check Script](../scripts/check.sh)
