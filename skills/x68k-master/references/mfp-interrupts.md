# MFP (MC68901) & Interrupts

## 割り込みレベル (IPL)

1. FDC, HDC, Printer
2. 拡張スロット
3. DMAC (HD, FD, ADPCM)
4. 拡張スロット
5. SCC (Keyboard, Mouse, Serial)
6. MFP (Timers, Raster IRQ, etc.)
7. NMI

## MFPレジスタ ($E88001〜 奇数アドレスのみ)

- `$E88001` (GPIP): bit6=CRTCラスター, bit4=V-DISP, bit3=FM音源
- `$E88007/09` (IERA/B): 割り込み許可
- `$E88013/15` (IMRA/B): 割り込みマスク
- `$E88017` (VR): ベクタレジスタ（通常 `$40` をセット）
- `$E88019-$E88025`: Timer A,B,C,D 制御およびデータ

## ラスター割り込みの実装

1. CRTC R09 にライン番号を書き込む。
2. MFP GPIP bit6 (CRTC IRQ) の割り込みを許可。
3. 割り込みハンドラ内で、次のラインの R09 を書き換えることで連続ラスター制御が可能。
