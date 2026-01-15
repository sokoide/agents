#!/bin/bash
# Go Code Review & Quality Check Script
set -e

echo "=== Go Code Quality Check ==="

# 1. 静的解析 (go vet)
echo "Running 'go vet'..."
go vet ./...

# 2. フォーマット確認 (golines)
# プロジェクト規約である120文字制限を確認
if command -v golines &> /dev/null; then
    echo "Checking formatting (120 char limit)..."
    # 実際には変更せず、差分があるかチェック
    # golines -m 120 --dry-run . | grep "diff" && echo "Format issues found!" || echo "Format OK"
    golines -m 120 --dry-run .
else
    echo "Warning: 'golines' not found. Skip formatting check."
fi

# 3. 未使用変数・インポートの確認
echo "Checking for unused items..."
if command -v staticcheck &> /dev/null; then
    staticcheck ./...
else
    echo "staticcheck not found, skipping."
fi

# 4. プロジェクト固有のバリデーション
if [ -f "go/Makefile" ]; then
    echo "Running CALM schema validation..."
    (cd go && make validate)
fi

echo "=== Check Completed ==="
