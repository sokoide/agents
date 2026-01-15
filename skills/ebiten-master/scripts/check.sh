#!/bin/bash
# Ebiten Code Check Script
# Usage: ./check.sh [project_root]

TARGET=${1:-.}

echo "Checking Ebiten project in: $TARGET"

if [ -f "$TARGET/go.mod" ]; then
    echo "Running go vet..."
    (cd "$TARGET" && go vet ./...)

    if command -v staticcheck &> /dev/null; then
        echo "Running staticcheck..."
        (cd "$TARGET" && staticcheck ./...)
    else
        echo "staticcheck not found. Recommended install: go install honnef.co/go/tools/cmd/staticcheck@latest"
    fi
else
    echo "go.mod not found in $TARGET. Skipping go checks."
fi

# Ebiten Specific Checks
echo "Checking for allocations in Draw (heuristic)..."
grep -n "func.*Draw" -A 20 "$TARGET"/*.go 2>/dev/null | grep "&ebiten.DrawImageOptions{}" && echo "[WARN] Potential allocation in Draw loop found!"

echo "Ebiten check completed."
