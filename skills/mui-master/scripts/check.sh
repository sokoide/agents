#!/bin/bash
# MUI Code Check Script
# Usage: ./check.sh [project_root]

set -e
TARGET=${1:-.}

echo "Checking MUI project in: $TARGET"

if [ -f "$TARGET/package.json" ]; then
    # Install dependencies if node_modules is missing
    if [ ! -d "$TARGET/node_modules" ]; then
        echo "Installing dependencies..."
        (cd "$TARGET" && npm install)
    fi

    # Type checking
    if [ -f "$TARGET/tsconfig.json" ]; then
        echo "Running tsc..."
        (cd "$TARGET" && npx tsc --noEmit)
    else
        echo "No tsconfig.json found, skipping type check."
    fi

    # ESLint
    if [ -f "$TARGET/.eslintrc" ] || [ -f "$TARGET/.eslintrc.js" ] || [ -f "$TARGET/.eslintrc.json" ] || [ -f "$TARGET/eslint.config.js" ] || [ -f "$TARGET/eslint.config.mjs" ]; then
        echo "Running ESLint..."
        (cd "$TARGET" && npx eslint .)
    else
        echo "No ESLint config found, skipping lint."
    fi
else
    echo "package.json not found in $TARGET. Skipping checks."
fi

# MUI-specific heuristics
echo "Checking for hard-coded color values in sx props..."
grep -rn 'sx={{.*#[0-9a-fA-F]\{3,8\}' "$TARGET/src" 2>/dev/null && echo "[WARN] Hard-coded hex colors found in sx props. Prefer theme palette." || echo "[OK] No hard-coded hex colors in sx props."

echo "MUI check completed."
