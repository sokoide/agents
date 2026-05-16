#!/bin/bash
# Go Clean Architecture Advanced Check Script
#
# このスクリプトは 'go list' を使用してパッケージの依存関係を解析し、
# クリーンアーキテクチャの4レイヤー（Domain, UseCase, Infra, Presentation）の
# 依存規則が守られているかを確認します。

set -e

TARGET=${1:-./...}
MODULE_NAME=$(go list -m 2>/dev/null || echo "")

if [ -z "$MODULE_NAME" ]; then
    echo "[ERROR] Go module not found. Run this in a Go project."
    exit 1
fi

echo "Scanning dependencies for module: $MODULE_NAME"
echo "Target: $TARGET"
echo "--------------------------------------------------------"

# レイヤー判定用パターン
DOMAIN_PAT="(/domain|/entity)"
USECASE_PAT="(/usecase|/interactor|/application)"
INFRA_PAT="(/infra|/persistence|/repository|/external|/adapter/persistence)"
PRESEN_PAT="(/presentation|/http|/grpc|/cli|/handler|/controller|/adapter/api)"

# 禁止されている技術的依存関係（ドメイン/ユースケース層用）
FORBIDDEN_TECH="(net/http|database/sql|github.com/gin-gonic|github.com/labstack/echo|gorm.io|github.com/jmoiron/sqlx)"

errors=0

# 全パッケージのインポート状況を解析
# 出力形式: [PackagePath] [Space separated imports]
go list -f '{{.ImportPath}} {{join .Imports " "}}' "$TARGET" | while read -r line; do
    pkg=$(echo "$line" | cut -d' ' -f1)
    imports=$(echo "$line" | cut -d' ' -f2-)

    # 現在のパッケージのレイヤーを特定
    layer="unknown"
    [[ "$pkg" =~ $DOMAIN_PAT ]] && layer="domain"
    [[ "$pkg" =~ $USECASE_PAT ]] && layer="usecase"
    [[ "$pkg" =~ $INFRA_PAT ]] && layer="infra"
    [[ "$pkg" =~ $PRESEN_PAT ]] && layer="presentation"

    if [ "$layer" == "unknown" ]; then continue; fi

    for imp in $imports; do
        # 1. Domain Layer Rules
        if [ "$layer" == "domain" ]; then
            # ドメインは他の内部パッケージに依存してはならない（他のドメインパッケージは除く）
            if [[ "$imp" == "$MODULE_NAME"* ]] && [[ ! "$imp" =~ $DOMAIN_PAT ]]; then
                echo "[FAIL] Domain layer violation: '$pkg' imports outer layer '$imp'"
                errors=$((errors + 1))
            fi
            # ドメインは技術的詳細（HTTP/SQL/Frameworks）に依存してはならない
            if [[ "$imp" =~ $FORBIDDEN_TECH ]]; then
                echo "[FAIL] Domain layer technical leak: '$pkg' imports '$imp'"
                errors=$((errors + 1))
            fi
        fi

        # 2. UseCase Layer Rules
        if [ "$layer" == "usecase" ]; then
            # ユースケースは Presentation または Infra に依存してはならない
            if [[ "$imp" =~ ($INFRA_PAT|$PRESEN_PAT) ]]; then
                echo "[FAIL] UseCase layer violation: '$pkg' imports outer layer '$imp'"
                errors=$((errors + 1))
            fi
            # ユースケースは技術的詳細に直接依存してはならない（インターフェース経由にすべき）
            if [[ "$imp" =~ $FORBIDDEN_TECH ]]; then
                echo "[FAIL] UseCase layer technical leak: '$pkg' imports '$imp'"
                errors=$((errors + 1))
            fi
        fi

        # 3. Presentation Layer Rules
        if [ "$layer" == "presentation" ]; then
            # プレゼンテーションは Infra に直接依存してはならない（UseCaseをバイパス禁止）
            if [[ "$imp" =~ $INFRA_PAT ]]; then
                echo "[FAIL] Presentation layer bypass: '$pkg' imports Infra layer '$imp' directly"
                errors=$((errors + 1))
            fi
        fi

        # 4. Infra Layer Rules
        if [ "$layer" == "infra" ]; then
            # インフラは Presentation に依存してはならない
            if [[ "$imp" =~ $PRESEN_PAT ]]; then
                echo "[FAIL] Infra layer violation: '$pkg' imports Presentation layer '$imp'"
                errors=$((errors + 1))
            fi
        fi
    done
done

echo "--------------------------------------------------------"
if [ "$errors" -gt 0 ]; then
    echo "Smoke check failed with $errors error(s)."
    exit 1
else
    echo "Clean Architecture smoke check passed!"
    exit 0
fi
