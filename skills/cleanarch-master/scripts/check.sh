#!/bin/bash
# Go Clean Architecture Dependency & Boundary Check
#
# Validates the 4-layer variant (Domain / UseCases / Infra Adapters / Presentation)
# against the rules in references/clean-arch-4layer.md.
#
# Checks performed:
#   1. Dependency direction (import graph) between layers
#   2. Technical detail leaks (DB/HTTP/ORM/Framework) into Domain and UseCases
#   3. ORM tags or transport annotations in Domain source files
#   4. context.Context stored in Domain Entity / ValueObject structs
#   5. sql.Tx / DB handle smuggling across boundaries
#
# Usage:
#   ./check.sh                  # check ./...
#   ./check.sh ./internal/...   # check specific packages
#
# Limitations:
#   - Uses heuristics based on directory naming conventions.
#   - Does not perform full AST analysis; some violations may be missed.
#   - Requires a working Go module (go list).

set -uo pipefail

TARGET=${1:-./...}

# --- Resolve module ---
MODULE_NAME=$(go list -m 2>/dev/null) || true
if [ -z "$MODULE_NAME" ]; then
    echo "[ERROR] Go module not found. Run this in a Go project root."
    exit 1
fi

echo "=== Clean Architecture Check ==="
echo "Module : $MODULE_NAME"
echo "Target : $TARGET"
echo ""

errors=0
warns=0

# ----------------------------------------------------------------
# Layer classification helpers
# ----------------------------------------------------------------
# These patterns match directory suffixes under the module path.
# Order matters: more specific patterns should be checked first.

layer_of() {
    local pkg="$1"
    # Infra Adapters (check first — persistence/repository impl is infra)
    if echo "$pkg" | grep -qE '(/infra/|/infrastructure/|/persistence/|/adapter/persistence|/adapter/external|/external/)'; then
        echo "infra"
    # Presentation
    elif echo "$pkg" | grep -qE '(/presentation/|/transport/|/adapter/http|/adapter/grpc|/adapter/api|/handler/|/controller/)'; then
        echo "presentation"
    # UseCases
    elif echo "$pkg" | grep -qE '(/usecase/|/interactor/|/application/|/app/)'; then
        echo "usecase"
    # Domain (broadest — includes entity, domain, model, port/interface definitions)
    elif echo "$pkg" | grep -qE '(/domain/|/entity/|/model/)'; then
        echo "domain"
    else
        echo "other"
    fi
}

# ----------------------------------------------------------------
# Check 1: Dependency Direction (go list import graph)
# ----------------------------------------------------------------
echo "--- 1. Dependency Direction ---"

# Collect go list output into a temp file to avoid subshell variable loss
tmpfile=$(mktemp)
go list -f '{{.ImportPath}} {{join .Imports " "}}' "$TARGET" > "$tmpfile" 2>/dev/null || {
    echo "[ERROR] 'go list' failed. Ensure the project compiles."
    rm -f "$tmpfile"
    exit 1
}

while IFS=' ' read -r pkg imports_str; do
    layer=$(layer_of "$pkg")
    [ "$layer" = "other" ] && continue

    # Skip blank lines
    [ -z "$pkg" ] && continue

    for imp in $imports_str; do
        # Only check imports within the same module
        [[ "$imp" != "$MODULE_NAME"* ]] && continue

        imp_layer=$(layer_of "$imp")
        [ "$imp_layer" = "other" ] && continue
        [ "$imp_layer" = "$layer" ] && continue

        violation=""

        case "$layer" in
            domain)
                # Domain must not depend on any other layer
                violation="Domain '$pkg' imports ${imp_layer} '$imp'"
                ;;
            usecase)
                # UseCases must not depend on Infra or Presentation
                if [ "$imp_layer" = "infra" ] || [ "$imp_layer" = "presentation" ]; then
                    violation="UseCases '$pkg' imports ${imp_layer} '$imp'"
                fi
                ;;
            presentation)
                # Presentation must not depend directly on Infra (bypasses UseCases)
                if [ "$imp_layer" = "infra" ]; then
                    violation="Presentation '$pkg' imports Infra '$imp' (UseCase bypass)"
                fi
                ;;
            infra)
                # Infra must not depend on Presentation
                if [ "$imp_layer" = "presentation" ]; then
                    violation="Infra '$pkg' imports Presentation '$imp'"
                fi
                ;;
        esac

        if [ -n "$violation" ]; then
            echo "  [FAIL] $violation"
            errors=$((errors + 1))
        fi
    done
done < "$tmpfile"
rm -f "$tmpfile"

echo ""

# ----------------------------------------------------------------
# Check 2: Technical Detail Leaks in Domain & UseCases
# ----------------------------------------------------------------
echo "--- 2. Technical Detail Leaks ---"

TECH_PATTERNS=(
    "net/http"
    "database/sql"
    "github.com/gin-gonic"
    "github.com/labstack/echo"
    "gorm.io"
    "github.com/jmoiron/sqlx"
    "github.com/golang/protobuf"
    "google.golang.org/grpc"
    "google.golang.org/protobuf"
)

for dir in $(find . -type d \( -path '*/domain/*' -o -path '*/entity/*' -o -path '*/usecase/*' -o -path '*/interactor/*' \) 2>/dev/null); do
    for gofile in "$dir"/*.go; do
        [ -f "$gofile" ] || continue
        for pat in "${TECH_PATTERNS[@]}"; do
            if grep -q "\"$pat\"" "$gofile" 2>/dev/null; then
                layer=$(layer_of "$MODULE_NAME${gofile#*.}")
                echo "  [FAIL] $gofile imports '$pat' ($layer layer)"
                errors=$((errors + 1))
            fi
        done
    done
done

echo ""

# ----------------------------------------------------------------
# Check 3: ORM Tags / Transport Annotations in Domain Files
# ----------------------------------------------------------------
echo "--- 3. ORM / Transport Annotations in Domain ---"

ORM_TAG_PATTERNS=(
    'gorm:"'
    'db:"'
    'json:"'
    'yaml:"'
    'protobuf:"'
    'validate:"'
    'binding:"'
    'form:"'
    'query:"'
    'uri:"'
    'xml:"'
)

for dir in $(find . -type d \( -path '*/domain/*' -o -path '*/entity/*' \) 2>/dev/null); do
    for gofile in "$dir"/*.go; do
        [ -f "$gofile" ] || continue
        # Only check struct field tags (lines with backtick)
        for pat in "${ORM_TAG_PATTERNS[@]}"; do
            if grep -q "$pat" "$gofile" 2>/dev/null; then
                echo "  [WARN] $gofile contains struct tag '$pat' — verify it is not a persistence/transport leak"
                warns=$((warns + 1))
                break  # one warning per file is enough
            fi
        done
    done
done

echo ""

# ----------------------------------------------------------------
# Check 4: context.Context in Domain Entity / ValueObject Structs
# ----------------------------------------------------------------
echo "--- 4. context.Context in Domain Structs ---"

for dir in $(find . -type d \( -path '*/domain/*' -o -path '*/entity/*' \) 2>/dev/null); do
    for gofile in "$dir"/*.go; do
        [ -f "$gofile" ] || continue
        # Look for context.Context as a struct field
        if grep -qE '^\s+\w+\s+context\.Context' "$gofile" 2>/dev/null; then
            echo "  [FAIL] $gofile stores context.Context in a struct field (Domain should not hold context)"
            errors=$((errors + 1))
        fi
    done
done

echo ""

# ----------------------------------------------------------------
# Check 5: sql.Tx / DB Handle Smuggling Across Boundaries
# ----------------------------------------------------------------
echo "--- 5. sql.Tx / DB Handle Boundary Leaks ---"

# Check Domain and UseCases for sql.Tx / *sql.DB / *sql.Conn in function signatures
for dir in $(find . -type d \( -path '*/domain/*' -o -path '*/entity/*' -o -path '*/usecase/*' -o -path '*/interactor/*' \) 2>/dev/null); do
    for gofile in "$dir"/*.go; do
        [ -f "$gofile" ] || continue
        if grep -qE '(\*sql\.Tx|\*sql\.DB|\*sql\.Conn|\*gorm\.DB|\*sqlx\.DB)' "$gofile" 2>/dev/null; then
            echo "  [FAIL] $gofile references a DB handle type — transaction details must stay in Infra Adapters"
            errors=$((errors + 1))
        fi
    done
done

# Check for context smuggling (Value keys named after technical resources)
for dir in $(find . -type d \( -path '*/domain/*' -o -path '*/entity/*' \) 2>/dev/null); do
    for gofile in "$dir"/*.go; do
        [ -f "$gofile" ] || continue
        if grep -qE 'context\.WithValue|ctx\.Value' "$gofile" 2>/dev/null; then
            echo "  [WARN] $gofile uses context Value — verify it is not smuggling DB handles or request objects"
            warns=$((warns + 1))
        fi
    done
done

echo ""

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
echo "=== Summary ==="
if [ "$errors" -gt 0 ]; then
    echo "  FAIL  : $errors violation(s) found"
fi
if [ "$warns" -gt 0 ]; then
    echo "  WARN  : $warns warning(s) (review recommended)"
fi
if [ "$errors" -eq 0 ] && [ "$warns" -eq 0 ]; then
    echo "  PASS  : Clean Architecture check passed"
fi

[ "$errors" -gt 0 ] && exit 1
exit 0
