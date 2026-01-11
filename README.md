# agents（Skill Repository）

このリポジトリは、Codex などのエージェントに「専門家としてのレビュー/設計/実装の型」を与える **Skill（スキル）集**です。各 skill は `SKILL.md`（トリガー用メタ情報 + 手順/チェックリスト）と、必要に応じて `references/`（ローカル要約）を持ちます。外部リンク依存を避け、ネットワーク無しでも判断できることを重視しています。

## 構成

- `skills/<skill-name>/SKILL.md`: スキル本体（いつ使うか、質問事項、出力契約、レビュー観点）
- `skills/<skill-name>/references/`: 参照用の要約（必要なときだけ読む前提）
- `skills/.system/`: スキル作成/インストール等の補助（通常は触らない）

## 使い方（検証/インストール）

### validate

全スキルの `SKILL.md` を最小ルールで検証します。

```sh
make validate
```

### install

スキルをスキルディレクトリへコピーします（既定: `~/.agents/skills`）。

```sh
make install
```

`skills/.system/` 配下も入れたい場合は:

```sh
make install INCLUDE_SYSTEM=1
```

## Codex での使い方

1) 初回のみ`cd $HOME/.codex; mv skills skills.bak; ln -s $THIS_REPO/skills $HOME/.codex/skills`
2) `make install` で `.agents/skills` に配置
3) 依頼時にスキル名を明示して使います（例: `$go-master` / `$java-master` / `$cs-master`）。
スキル側の「First Questions」に答える情報（バージョン、制約、目標）を最初に渡すと精度が上がります。

## Gemini CLI での使い方


### おすすめ: gemini-cli@preview

gemini-cli@previewでskillsがサポートされていますので、preview版の利用をお勧めします。

```bash
brew uinstall gemini-cli
npm uninstall -g @google/gemini-cli
sudo rm -rf /opt/homebrew/lib/node_modules/@google/gemini-cli
npm install -g @google/gemini-cli@preview
```

install後<https://geminicli.com/docs/cli/tutorials/skills-getting-started/>に従って有効化してください。

初回のみ`cd $HOME/.gemini; mv skills skills.bak; ln -s $THIS_REPO/skills $HOME/.gemini/skills`

### gemini-cli@latest

gemini-cli@latestでは、2026/1/11現在まだskillsは使用できません。
`.gemini/GEMINI.md` に以下の設定を追加することで、`$` 記号を使ってスキルを即座に呼び出すことができます。

#### 設定例（.gemini/GEMINI.md）

```markdown
## skills

スキルは「永続的な役割」ではなく、特定のタスクを処理するための「一時的なツール」として扱う。

### 1. 動的ロードと破棄の原則
- `$` コマンド（例: `$c-master`）を受け取った際、その**直後のリクエスト1回のみ**に対してスキルの制約を適用せよ。
- スキル適用が完了し、回答を出力した後は、スキルの詳細な指示内容をコンテキストから論理的にデタッチし、基本の振る舞いに戻ること。

### 2. 実行手順
1. **Index参照**: `$HOME/.agents/skills/index.json` から該当スキルの `path` を取得。
2. **一時ロード**: 指定された `SKILL.md` の内容を読み込み、**「この回答を生成するためだけのガイドライン」**として扱う。
3. **タスク遂行**: `scripts/` があれば実行し、結果を出す。
4. **コンテキストクリーンアップ**: 回答の最後に、適用したスキル名と「タスク完了」を明記し、以降のターンでそのスキルの詳細（ルール全文など）を再利用しないよう配慮せよ。

### 3. 明示的な永続化
- ユーザーが「以降、このスキルを維持して」と指示した場合のみ、セッション全体に適用を継続せよ。
```

### 運用手順

1. `make install INSTALL_DIR=$HOME/.agents/skills INCLUDE_SYSTEM=1` でスキルを配置します。
2. チャット内で `$go-master` のように入力すると、そのスキルの専門知識がロードされます。

## 新しい skill を追加する

CodexもしくはGemini CLI内部で`$skill-creator`
