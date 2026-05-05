---
name: x68k-master
description: >
    Expert-level X68000 (Sharp) architect. Specialist in MC68000 system programming,
    Human68k environment, and direct hardware control (VRAM, DMAC, MFP, Sprites).
    Use for:
    (1) Developing/Reviewing Human68k C/ASM code (Supervisor mode, I/O safety).
    (2) Direct hardware manipulation (Graphics, Sound, I/O registers).
    (3) Optimizing performance via DMAC and Interrupt management.
---

# X68000 Master

`references` を正として、X68000 実機向けコードの設計・実装・レビューを行う。
特に 68000 のアドレス整列、Human68k/IOCS、VRAM、DMAC、割り込み、周辺 I/O を安全側で扱う。

## 最初に確認すること

- 対象機種: 初代 / ACE / EXPERT / PRO / SUPER / XVI / Compact / 030
- 開発形態: Human68k ネイティブ gcc/XC か、クロス開発か
- 直接叩く対象: GVRAM / TVRAM / CRTC / DMAC / MFP / 音源 / ストレージ / 通信
- IOCS/DOS 呼び出しで足りるのか、性能要件のために直叩きが必要か

## 出力方針

- 低レベル説明では、必ずどの `references` 以下のファイルに根拠があるか明示する。
- 直接 I/O アクセス例では、Supervisor モード移行と復帰を必ず明示する。
- VRAM と I/O 領域を混同しない。`$E80000-$EBFFFF` はシステム I/O、`$C00000-$E7FFFF` は VRAM 系。
- レジスタ名・アドレス・ビットは、`references` で確認できた範囲だけを書く。怪しい細部は断定しない。
- `references` に明記がない細部は、推測せず「要原典確認」と明示する。

## 共通制約（全デバイス共通）

以下は全デバイスで共通。各リソースファイルでは原則として再説明しない。

1. **Supervisor モード必須**: システム I/O（`$E80000`以降）へのアクセスは `_iocs_super(0)` で Supervisor に移行してから行う。終了時に必ず復帰。
2. **メモリマップト I/O**: 68000 には独立 I/O 空間がない。全ペリフェラルはメモリ空間上のアドレスにマッピングされる。
3. **奇数番地 / バイトアクセス**: 8 ビットペリフェラル（MFP, RTC, SCC, FDC, SASI, SCSI 等）はデータバス D0-D7 に接続されているため、**奇数番地へのバイトアクセス（`move.b` 等）**で操作する。ワードアクセスは上位バイトが不定。
4. **`volatile` 必須**: レジスタポインタには必ず `volatile` を付与。コンパイラ最適化によるアクセス消失を防ぐ。
5. **68000 アラインメント**: ワード/ロングアクセスは偶数アドレス前提。奇数アドレスへのワードアクセスは Address Error。
6. **VRAM と I/O の区別**: `$C00000-$E7FFFF` は VRAM 系、`$E80000-$EBFFFF` はシステム I/O。混同しない。

## リソース一覧

| ファイル | 内容 |
| --- | --- |
| `01_メモリマップ.md` | 16MB リニア空間配分、IPL ミラーリング、VRAM 論理構造 |
| `02_DMA.md` | HD63450 4ch（Ch0:FDD, Ch1:HDD, Ch2:User/VRAM, Ch3:ADPCM）、アレイチェイン矩形転送、CCR バイトアクセス |
| `03_割り込み.md` | レベル 1-7 デバイス割り当て、オートベクタ（NMI のみ）とベクタ割り込み、ベクタテーブル配置 |
| `04_MFP.md` | MC68901 レジスタ、タイマ A-D、GPIP 信号定義、USART キーボード通信 |
| `05_数値演算プロセッサ.md` | MC68881 (FPU) の CIR 手動制御プロトコル、80bit 拡張精度 |
| `06_RTC.md` | RP5C15 レジスタ、二度読みティアリング回避、ALARM→MFP GPIP0 連携 |
| `07_画面制御.md` | CRTC 設定、ビデオコントローラ、4プレーン合成、RGB555、解像度別 VRAM レイアウト |
| `08_サウンド機構.md` | YM2151 (OPM) レジスタとウェイト、MSM5205 (ADPCM) DMA Ch3 サイクルスチール |
| `09_SCC.md` | Z8530 Ch.A（RS-232C/マウス）Ch.B（キーボード）、ボーレート生成、リカバリタイム NOP |
| `10_キーボード・マウス.md` | MFP USART（キーボード）と SCC（マウス）の割り込みレベル優先順位、システムポート#2 接続監視 |
| `11_プリンタ.md` | IOC ASIC STB/BUSY/ACK ハンドシェイク、割り込み要因オフセット、ベクタ共有注意 |
| `12_ジョイスティック.md` | $E9A000 領域、負論理入力、コントロールワードマルチプレクス、高速機ウェイト |
| `13_フロッピーディスクドライブ.md` | µPD72065 FDC MSR ポーリング、DMAC Ch0 同期、3-Recal-3 リトライ |
| `14_SASI.md` | バスフェーズ（Command/Data/Status/Message）、非同期ハンドシェイク、6バイト CDB |
| `15_SCSI.md` | MB89352 SPC レジスタ、DMAC Ch1 パック転送、10バイト CDB、SRAM デバイスパラメータ |
| `16_システムポート.md` | $E80000-$EBFFFF 統合レジスタマップ、バイトアクセス・奇数番地制約まとめ |

## 実装ルール

1. GVRAM / TVRAM はメモリ空間であり、I/O 領域とは別物として扱う。
2. 大量転送は CPU ループより DMAC を優先する。特に FDD/HDD/ADPCM は DMAC 前提。
3. 割り込みベクタや MFP 設定を横取りしたら、終了時に必ず復元する。
4. パレット・表示タイミング・ラスタ制御は CRTC/ビデオ制御とセットで扱う。
5. キーボードは MFP 内蔵 USART 系。SCC は主に RS-232C/マウス側。
6. ジョイスティックは i8255 / I/O コントローラ系。単純なメモリ読み出し 1 本で決め打ちしない。
7. 怪しい場合は IOCS/DOS 優先。実機依存の直叩きは根拠があるときだけ出す。

## レビュー観点

- Supervisor モードが必要な I/O 領域を User モードで触っていないか
- VRAM とシステム I/O の境界を取り違えていないか
- 16bit/32bit アクセスの整列違反がないか
- DMAC のチャネル割り当てとチャネルベースを誤っていないか
- MFP/割り込みベクタを変更して復元漏れしていないか
- キーボード、SCC、RTC、i8255 を混同していないか
