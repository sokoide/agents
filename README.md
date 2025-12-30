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

Gemini CLI（Serena）では、`.gemini/GEMINI.md` に以下の設定を追加することで、`$` 記号を使ってスキルを即座に呼び出すことができます。

### 設定例（.gemini/GEMINI.md）

```markdown
## skills

- `$HOME/.agents/skills` および `$HOME/.agents/skills/.system` には、再利用可能なスキルが格納されています。
- ユーザーが `$` で始まるコマンドを入力した場合、それがスキル名（ディレクトリ名）と一致するなら、以下の手順で実行してください：

1. `$HOME/.agents/skills/[コマンド名]/SKILL.md` または `$HOME/.agents/skills/.system/[コマンド名]/SKILL.md` を読み込む。
2. スキル内の `description` と指示内容を理解し、現在のコンテキストに適用する。
3. 必要に応じて、そのスキル内の `scripts/` にあるツールを実行する。

### 登録済みスキル例

- `$skill-creator` : スキル作成ガイドを起動
- `$ca-master` : クリーンアーキテクチャの型を適用
- `$go-master` : Go言語のベストプラクティスを適用
- `$ts-master` : TypeScriptの型設計を適用
...
```

### 運用手順

1. `make install INSTALL_DIR=$HOME/.agents/skills INCLUDE_SYSTEM=1` でスキルを配置します。
2. チャット内で `$go-master` のように入力すると、そのスキルの専門知識がロードされます。

## 新しい skill を追加する

CodexもしくはGemini CLI内部で`$skill-creator`
