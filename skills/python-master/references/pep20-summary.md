# The Zen of Python (PEP 20) - Local Summary

目的: “読みやすさと明快さ” を設計判断の最優先に置く。

## Practical Interpretations (How to Apply)

- **Readability counts**: 1 回で読める制御フロー、過剰な抽象化/メタプログラミングを避ける。
- **Explicit > implicit**: 省略や暗黙変換に頼らず、意図（型・名前・境界）をコードで示す。
- **Simple > complex**: まず単純な設計で成立させ、必要になってから一般化する。
- **Errors should not pass silently**: 例外/戻り値を握りつぶさず、境界でログ/変換/再送出の方針を決める。
- **Namespaces are one honking great idea**: import 境界を意識し、循環依存や “何でも util” を避ける。

## Review Smells

- ワンライナーに詰め込みすぎ（可読性より短さを優先）
- 例外を握りつぶす `except Exception: pass`
- “賢い” デコレータ/メタクラスで追跡困難（デバッグ不能）

## Optional Source

原典参照は必要時のみ（外部リンクは本リポジトリには保持しない）。
