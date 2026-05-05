# X68000 SCSI

SUPER 以降の機種で標準化。SASI から SPC（MB89352 SCSI Protocol Controller）による自律的バス管理へ移行。

## アーキテクチャ概要

SPC がバスフェーズ管理（Phase Handshake Logic）をハードウェアレベルで隠蔽。CPU を複雑な信号操作から解放し、マルチタスク下でも安定したディスク I/O を保証。

## バスフェーズ

1. **Bus Free**: バス解放状態
2. **Selection/Reselection**: ターゲット選択/再選択
3. **Information Transfer**: Command, Data, Status, Message の各相

## I/O マップ（`$E96000`〜、奇数アドレスのみ）

| レジスタ | アドレス | 機能 |
| --- | --- | --- |
| **BDID** | $E96001 | バス ID（自局/ターゲット SCSI ID） |
| **SCTL** | $E96003 | パリティチェック、割り込み許可、動作モード |
| **SCMD** | $E96005 | コマンド（Bus Release, Select, Transfer 等） |
| **INTS** | $E96007 | 割り込みステータス（完了、タイムアウト、バスエラー） |
| **PSNS** | $E96009 | フェーズセンス（現在の SCSI バス信号: REQ, ACK 等） |
| **SDGC** | $E9600B | データガード制御（ハンドシェイク詳細） |
| **SSTS** | $E9600D | SPC 内部状態（Busy/Idle） |
| **SERR** | $E9600F | エラー詳細（パリティ、フェーズミス） |
| **PCTL** | $E96011 | フェーズ制御（期待バスフェーズ設定） |

## SRAM 管理

`$ED0000` 以降の SRAM 領域に SCSI ID、デバイス種別識別子（メディアバイト）、セクタ数・シリンダ数等のデバイスパラメータを格納。IPL-ROM が起動時にスキャンしてブート可能ドライブを特定。

## DMAC 連携（Ch1）

SCSI 転送は DMAC Ch1 を使用。

### 推奨設定

| レジスタ | 値 | 意味 |
| --- | --- | --- |
| DCR | $80 | 68000バスタイプ、8ビットデバイス |
| OCR | $00 | 転送方向: メモリ←デバイス時 |

### Pack Mode

SCSI は 8 ビットデバイス（DPS=0）だが、X68000 メインメモリは 16 ビット。DMAC は「パック転送」で **2回の SCSI アクセスを1回の16ビットメモリ書き込みに集約**し、バス占有率を下げる。

## SPC コマンド実行フロー

1. **Bus Release**: `SCMD` にリセット/バス解放 → Bus Free 確保
2. **Selection**: `BDID` にターゲット ID セット → `SCMD` に Select コマンド
3. **Command Phase**: CDB を UDR 経由で送出
4. **DMA Setup**: DMAC MAR にバッファアドレス、MTC に転送数 → CCR = $80
5. **Transfer**: SPC `SCMD` に Transfer コマンド → DMAC とハンドシェイク開始

## SCSI コマンド

| コマンド | Opcode | 役割 |
| --- | --- | --- |
| TEST UNIT READY | $00 | デバイス動作準備確認 |
| REQUEST SENSE | $03 | CHECK CONDITION 時のエラー詳細（センスデータ）取得 |
| INQUIRY | $12 | ベンダー名、モデル名、デバイスタイプ取得 |
| READ (6) | $08 | 21ビット LBA 指定（小容量ドライブ用） |
| READ (10) | $28 | **32ビット LBA 指定**（高速・大容量標準） |
| MODE SENSE | $1A | ドライブ物理パラメータ（セクタサイズ等）取得 |

ステータスバイトが `$02`（Check Condition）の場合、直ちに `REQUEST SENSE` で詳細を解析する。

## 同期ロジック

- **INTS**（`$E96007`）bit5（`$20`: Command Complete）を監視し、ハードウェアステートマシンが完全遷移したことを確認してから次フェーズへ。
- **DMA 終了**: DMAC CSR の COC ビットと SPC INTS を**二重監視**でデータ整合性を担保。

## エラー処理チェックリスト

- **SERR**（`$E9600F`）: パリティエラー検知（ケーブル長/ターミネータ起因）
- **タイムアウト**: ターゲット無応答時は SPC 強制アボート（`SCMD` 書き込み）→ バス解放
- **フェーズミス**: `PSNS` で現在フェーズ確認、期待と異なる場合はメッセージ処理へ分岐
