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
4. **変換順序を明示**: `GeoM.Translate/Scale/Rotate` の順序で結果が変わる。回転中心/拡大中心は「原点移動→回転/拡大→戻す」で表現する。
5. **入力は edge を使う**: トグル/単発アクションは `inpututil.IsKeyJustPressed` / `inpututil.IsMouseButtonJustPressed` を使い、押しっぱなしは `ebiten.IsKeyPressed`。
6. **画像は *ebiten.Image を所有する**: `SubImage` は `image.Image` を返すので、必要なら `*ebiten.Image` へ変換/管理（スプライトシートの切り出しは一度だけ）。

## Review Checklist (High-Signal)

- **Game Loop**: `Update` の tick 前提（1/60s）で状態更新できているか、`Update` の `error` 伝播が適切か
- **Layout/Scaling**: 論理解像度固定 or 外側に合わせる設計が明確か、座標変換/マウス座標の扱いが一致しているか
- **Rendering**: `DrawImage` の option 再利用、`FilterNearest/FilterLinear` の選択、`Clear/Fill` の使い方
- **Transforms**: `GeoM` の順序、回転中心、スケール、整数座標へのスナップ（pixel art のブレ対策）
- **Input**: edge 判定の誤用（毎フレーム反応してしまう）、同時押し、UI/ゲーム入力の優先順位
- **Performance/GC**: ホットパスの `fmt`/`ebitenutil.DebugPrint` 多用、画像生成/コピー、`SubImage` の多重生成、オブジェクトプール/スライス再利用

## References

- [Ebitengine Cheatsheet (excerpt)](references/cheatsheet.md)
