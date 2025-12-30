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

スキルを Codex のスキルディレクトリへコピーします（既定: `~/.codex/skills`）。

```sh
make install
make install CODEX_HOME=~/.codex
make install INSTALL_DIR=~/somewhere/skills
```

`skills/.system/` 配下も入れたい場合は:

```sh
make install INCLUDE_SYSTEM=1
```

## Codex での使い方

1) `make install` で `CODEX_HOME/skills` に配置  
2) 依頼時にスキル名を明示して使います（例: `$go-master` / `$java-master` / `$cs-master`）。  
スキル側の「First Questions」に答える情報（バージョン、制約、目標）を最初に渡すと精度が上がります。

## Gemini での使い方（手動運用）

Gemini 側に自動の skill ローダが無い場合は、必要なスキルを **添付/貼り付け**して運用します。

- まず `skills/<skill>/SKILL.md` を貼る（もしくはファイル添付）
- 必要に応じて `skills/<skill>/references/*.md` を追加で貼る

運用例（プロンプト）:
> 次の Skill の指示に従ってレビューしてください: `skills/go-master/SKILL.md`  
> 追加参照: `skills/go-master/references/code-review-comments.md`

## 新しい skill を追加する

```sh
python3 skills/.system/skill-creator/scripts/init_skill.py my-skill --path skills/
python3 skills/.system/skill-creator/scripts/quick_validate.py skills/my-skill
```
