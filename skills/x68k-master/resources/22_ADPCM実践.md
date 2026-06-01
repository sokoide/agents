# X68000 ADPCM 実践

ADPCM 音声の録音・再生・効果音管理の実践的パターン。DMA コントローラ Ch3 で転送。

---

## IOCS 一覧

| 番号 | 名称 | モード | 機能 |
| --- | --- | --- | --- |
| $60 | ADPCMOUT | ブロック | ADPCM再生 |
| $61 | ADPCMINP | ブロック | ADPCM録音 |
| $62 | ADPCMAOT | アレイチェーン | ADPCM再生(長時間) |
| $63 | ADPCMAIN | アレイチェーン | ADPCM録音(長時間) |
| $64 | ADPCMLOT | リンクアレイ | ADPCM再生(非同期) |
| $65 | ADPCMLIN | リンクアレイ | ADPCM録音(非同期) |

## ブロック転送 (基本)

```asm
; 再生
    movea.l    PCMdata,a1      ; PCMデータアドレス
    move.l    PCMlength,d2     ; PCMデータ長
    move    #$403,d1        ; 15.6kHz, 左右出力
    IOCS    _ADPCMOUT($60)
```

### サンプリング周波数とデータ長

| モード (d1) | 周波数 | 1秒のデータ長 | 65280Bの記録時間 |
| --- | --- | --- | --- |
| $403 | 15.6 kHz | 7800 B | 8.3 秒 |
| $303 | 10.4 kHz | 5200 B | 12.5 秒 |
| $203 | 7.8 kHz | 3900 B | 16.7 秒 |
| $103 | 5.2 kHz | 2600 B | 25.1 秒 |
| $003 | 3.9 kHz | 1950 B | 33.4 秒 |

**ブロック上限**: 65,280 バイト ($FF00)。これを超えるとアレイチェーン/リンクアレイを使う。

## アレイチェーン転送 (長時間再生)

複数ブロックを連続再生。テーブル構造: `(addr.l, size.w, ...)` を繰り返す。

```asm
    move.l    #$ff00,d3       ; ブロックサイズ上限
    lea    DMAwork,a0
    moveq    #0,d0            ; ブロック数カウンタ
loopA:
    addq.l    #1,d0
    move.l    a1,(a0)+        ; addr
    adda.l    d3,a1
    cmpi.l    d3,d2
    bls    @f
        move.w    d3,(a0)+    ; size
        sub.l    d3,d2
        bra    loopA
    @@:
    move    d2,(a0)+        ; size (最終ブロック)
    move    d0,d2           ; d2 = ブロック数
    lea    DMAwork,a1
    IOCS    _ADPCMAOT($62)
```

## リンクアレイチェーン転送 (非同期再生)

再生開始後に IOCS が即座に返る。BGM 用途に適する。

テーブル構造: `(addr.l, size.w, next.l)...(*, *, 0)`。next が 0 で終端。

```asm
    IOCS    _ADPCMLOT($64)
```

---

## PCMファイルフォーマット

ヘッダなしの生 ADPCM データ。4 ビットで 1 サンプルを符号化。

- 15.6kHz で 7800 バイト/秒
- 拡張子は通常 .PCM

---

## ADPCMエンコーディングアルゴリズム

16 ビット PCM → 4 ビット ADPCM 変換。

### 予測値テーブル (49エントリ)

```c
static const int step_table[49] = {
    16, 17, 19, 21, 23, 25, 28, 31, 34, 37,
    41, 45, 50, 55, 60, 66, 73, 80, 88, 97,
    107, 118, 130, 143, 157, 173, 190, 209, 230, 253,
    279, 307, 337, 371, 408, 449, 494, 544, 598, 658,
    724, 796, 876, 963, 1060, 1166, 1282, 1411, 1552
};
```

### インデックス補正値 (8エントリ)

```c
static const int index_table[8] = { -1, -1, -1, -1, 2, 4, 6, 8 };
```

### エンコード手順

1. 現在の予測値 (predictor) と入力サンプルの差分を計算
2. 差分の符号を符号ビットとして記録
3. 差分の絶対値を現在のステップ値で量子化 → 4 ビットコード生成
4. コード上位 4 ビットがインデックス補正値の選択に使われる
5. ステップインデックスを補正 (0-48 の範囲にクランプ)
6. 予測値を更新
7. **ビットパッキング**: 下位 4 ビットが先 (リトルエンディアン的配置)

---

## 複数効果音管理

ゲームで複数の効果音を管理するパターン。

### A-Z シンボルマッピング

効果音をアルファベット 1 文字のシンボルで識別。

```c
typedef struct {
    unsigned char *address;   /* PCMデータのメモリアドレス */
    unsigned int   size;      /* PCMデータ長 */
} pcm_entry;                  /* 8バイト/エントリ */

pcm_entry pcm_table[26];     /* A-Z, 最大26種類 */
unsigned char *freearea;      /* 未使用領域の先頭 */
```

### ロード手順

1. PCM ファイルを freearea に読み込む
2. pcm_table[symbol].address = freearea
3. pcm_table[symbol].size = 読み込んだバイト数
4. freearea += size (次の空き領域に進む)

### 再生

```c
void pcm_play(char symbol) {
    int idx = symbol - 'A';
    if (pcm_table[idx].address) {
        /* IOCS ADPCMOUTで再生 */
    }
}
```

---

## サウンドライブラリ構築

複数 PCM ファイルを 1 つのライブラリファイルに結合するフォーマット。

### ファイルフォーマット

```text
[ヘッダ]
  4バイト: マジック 'PCM' + null
  60バイト: シンボルテーブル (A-Z, 各バイト=有効/無効)
  480バイト: オフセット+サイズテーブル (26エントリ × 18バイト)
[データ]
  連結されたADPCMデータ
```

### ライブラリローダ

ファイルからロード後、オフセットを実際のメモリアドレスに再配置:

```c
void load_library(unsigned char *base, char *filename) {
    /* ファイルを読み込む */
    /* ヘッダをパース */
    /* 各シンボルのオフセットに base アドレスを加算して実アドレスを得る */
    for (int i = 0; i < 26; i++) {
        if (symbol_table[i]) {
            pcm_table[i].address = base + offset_table[i];
            pcm_table[i].size = size_table[i];
        }
    }
}
```

最大 60 種類の効果音を 1 ファイルで管理可能。
