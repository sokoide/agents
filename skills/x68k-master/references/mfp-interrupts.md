# MFP (MC68901) / 割り込み実装メモ

> 目的: MFP と割り込み周りで事故りやすい点を先に潰す。

## 割り込みレベル（運用時の目安）

1. FDC / HDC / Printer
2. 拡張スロット
3. DMAC（FDD/HDD/ADPCM など）
4. 拡張スロット
5. SCC（Keyboard / Mouse / Serial）
6. MFP（Timer / GPIP / Raster IRQ）
7. NMI

## MFP 主要レジスタ（奇数アドレス側を使用）

| レジスタ | 用途 |
| :--- | :--- |
| GPIP | 外部入力ピン状態（ラスタ等の信号監視） |
| IERA / IERB | 割り込み要因ごとの許可 |
| IMRA / IMRB | 割り込みマスク |
| ISRA / ISRB | In-Service 状態 |
| IPRA / IPRB | Pending 状態 |
| VR | ベクタベース設定 |
| TACR/TBCR/TCDCR, TA/TB/TC/TD | Timer A/B/C/D 制御 |

## 初期化シーケンス（最小）

1. 既存ハンドラ退避（ベクタ保存）
2. MFP 割り込み禁止（IER/IMR を安全側へ）
3. VR 設定（ベクタベース）
4. Timer/GPIP 条件設定
5. 保留フラグをクリア
6. IER/IMR を有効化
7. ハンドラで要因を判定し、必要な ACK/次回設定を実施

## ラスター割り込み運用

- CRTC 側に割り込みライン番号を書き込む。
- MFP 側で該当要因を許可する。
- ハンドラ内で「次のライン」を再設定し、連続制御する。
- ハンドラは短く保ち、重い処理はフラグ通知＋メインループへ逃がす。

## 典型的な不具合

- IER だけ設定して IMR を忘れる。
- ベクタ差し替え後に復帰処理を入れず常駐破壊する。
- 割り込み中に長時間 VRAM 転送して次 IRQ を取りこぼす。
