# Language Conventions Map

Review 時は、対象ファイルの言語に対応する `*-master` スキルを必ず起動し、その言語の標準的な規約とベストプラクティスを参照すること。

## 利用可能な言語専門スキル (*-master)
以下のスキルが環境にインストールされており、言語に応じて自動的に切り替えて使用すること：

- **Go**: `go-master`
- **Rust**: `rs-master`
- **TypeScript/JavaScript**: `ts-master`
- **Python**: `py-master`
- **C++**: `cpp-master`
- **C**: `c-master`
- **C#**: `cs-master`
- **Java**: `java-master`
- **Clean Architecture (General)**: `ca-master`
- **Game/Framework Specific**:
  - `bevy-master` (Rust Bevy)
  - `ebiten-master` (Go Ebitengine)
  - `mui-master` (Material UI)

## 共通のチェック事項
各言語スキルの規約に加え、以下の点を確認すること：
1. **Naming**: 言語標準のケース（CamelCase, snake_case等）とエクスポート規則の遵守。
2. **Error Handling**: 言語推奨の例外処理またはエラー値チェック。
3. **Project Guide**: プロジェクト内に `conductor/code_styleguides/` が存在する場合は、その内容を最優先する。
