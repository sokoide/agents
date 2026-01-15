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

## Codex での使い方

1) `make install` で `.agents/skills` に配置
2) 初回のみ`cd $HOME/.codex; mv skills skills.bak; ln -s ~/.agents/skills`
3) 依頼時にスキル名を明示して使います（例: `$go-master` / `$java-master` / `$cs-master`）。
スキル側の「First Questions」に答える情報（バージョン、制約、目標）を最初に渡すと精度が上がります。

## Gemini CLI での使い方

gemini-cli@0.24.0でskillsがサポートされています。
install後<https://geminicli.com/docs/cli/tutorials/skills-getting-started/>に従って有効化してください。

1) `make install` で `.agents/skills` に配置
2) 初回のみ`cd $HOME/.gemini; mv skills skills.bak; ln -s ~/.agents/skills`
3) 依頼時に「go-masterを使って or using go-master,」と依頼する（例: `go-master`を使ってcode reviewして）
スキル側の「First Questions」に答える情報（バージョン、制約、目標）を最初に渡すと精度が上がります。

## 新しい skill を追加する

以下のように`skill-creator`がありますが、

- Codexで`$skill-creator`
- Gemini CLI内部で`skill-creatorを起動`

Antigravityのchat欄で以下のようにお願いする方がいいかもしれません。

```text
Goのコーディング規約とhttps://go.dev/doc/effective_goをもとに、新しいSkillを作成して。.agent/skills/go-codereviewer/ 内に SKILL.md と必要なスクリプト・リソースを配置して。Code Reviewに特化した品質・パフォーマンス・ソフトウェアデザインのスペシャリストスキル。
```

* このRepoでは共通SKILLを`~/.agent/skills`に配置します
* 上記のプロンプトではProjectごとのAgent SKILLが`$workspace-dir/.agent/skills`(agentsではなく、単数)に作成されます
