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

Inside X68000 を正として、X68000 実機向けコードの設計・実装・レビューを行うための skill。
特に 68000 のアドレス整列、Human68k/IOCS、VRAM、DMAC、割り込み、周辺 I/O を安全側で扱う。

## 最初に確認すること

- 対象機種: 初代 / ACE / EXPERT / PRO / SUPER / XVI / Compact / 030
- 開発形態: Human68k ネイティブ gcc/XC か、クロス開発か
- 直接叩く対象: GVRAM / TVRAM / CRTC / DMAC / MFP / 音源 / ストレージ / 通信
- IOCS/DOS 呼び出しで足りるのか、性能要件のために直叩きが必要か

## 出力方針

- 低レベル説明では、必ずどの `references/*.md` に根拠があるか明示する。
- 直接 I/O アクセス例では、Supervisor モード移行と復帰を必ず明示する。
- VRAM と I/O 領域を混同しない。`$E80000-$EBFFFF` はシステム I/O、`$C00000-$E7FFFF` は VRAM 系。
- レジスタ名・アドレス・ビットは、PDF で確認できた範囲だけを書く。怪しい細部は断定しない。
- `Inside X68000` に明記がない細部は、推測せず「要原典確認」と明示する。

## Reference の使い分け

- メモリ空間、I/O 配置、ROM/SRAM: `references/memory-map.md`, `references/user-io-rom.md`
- DMA 転送、チャネル割り付け: `references/dmac.md`
- 画面モード、VRAM、スプライト: `references/video-sprite.md`
- タイマ、割り込み、キーボード系: `references/mfp-interrupts.md`, `references/input-rtc.md`
- FM/ADPCM: `references/sound_adpcm.md`
- FDD/HDC/SASI: `references/storage-controllers.md`

## 優先順位

1. まず `Inside X68000`
2. 次に `references/*.md`
3. それでも不足するときだけ Human68k IOCS / DOS 資料

## 実装ルール

1. システム I/O 直叩きは Supervisor モード前提。`_iocs_super(0)` で入り、必ず元に戻す。
2. GVRAM / TVRAM はメモリ空間であり、I/O 領域とは別物として扱う。
3. `volatile` を外さない。ポーリング対象やレジスタマップは必ず `volatile`。
4. 68000 のワード/ロングアクセスは偶数アドレス前提。奇数アドレスアクセスは Address Error。
5. 大量転送は CPU ループより DMAC を優先する。特に FDD/HDD/ADPCM は DMAC 前提で考える。
6. 割り込みベクタや MFP 設定を横取りしたら、終了時に必ず復元する。
7. パレット・表示タイミング・ラスタ制御は CRTC/ビデオ制御とセットで扱う。
8. キーボードは SCC ではなく MFP 内蔵 USART 系として扱う。SCC は主に RS-232C/マウス側。
9. ジョイスティックは i8255 / I/O コントローラ系。単純なメモリ読み出し 1 本で決め打ちしない。
10. 怪しい場合は IOCS/DOS 優先。実機依存の直叩きは根拠があるときだけ出す。

## レビュー観点

- Supervisor モードが必要な I/O 領域を User モードで触っていないか
- VRAM とシステム I/O の境界を取り違えていないか
- 16bit/32bit アクセスの整列違反がないか
- DMAC のチャネル割り当てとチャネルベースを誤っていないか
- MFP/割り込みベクタを変更して復元漏れしていないか
- キーボード、SCC、RTC、i8255 を混同していないか

## 悪い例

```c
// NG: システム I/O を user mode のまま直叩き
*(volatile unsigned short *)0xE80000 = 0x0001;

// NG: odd address への long access
*(volatile unsigned long *)0x001001 = 0xDEADBEEF;

// NG: キーボードを SCC と決め打ち
*(volatile unsigned char *)0xE98001 = 0x55;
```

## 良い例

```c
// OK: GVRAM はメモリ空間として扱う
void clear_gvram_plane(void) {
    volatile unsigned short *gvram = (volatile unsigned short *)0xC00000;
    for (int i = 0; i < 512 * 1024 / 2; ++i) {
        gvram[i] = 0;
    }
}

// OK: CRTC/システム I/O は supervisor で扱う
void write_crtc(volatile unsigned short *reg, unsigned short value) {
    long old_sp = _iocs_super(0);
    *reg = value;
    _iocs_super(old_sp);
}
```

## Resources

- [Code Check Script](scripts/check.sh)
- [Memory Map](references/memory-map.md)
- [DMAC](references/dmac.md)
- [Video / VRAM / Sprite](references/video-sprite.md)
- [MFP / Interrupts](references/mfp-interrupts.md)
- [Input / SCC / RTC](references/input-rtc.md)
- [Sound](references/sound_adpcm.md)
- [Storage Controllers](references/storage-controllers.md)
- [User I/O / SRAM / ROM](references/user-io-rom.md)

## References

- Inside X68000
- Human68k IOCS / DOS documentation
