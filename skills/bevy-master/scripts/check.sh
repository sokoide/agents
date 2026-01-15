#!/bin/bash
# Bevy Code Check Script
# Usage: ./check.sh [project_root]

TARGET=${1:-.}

echo "Checking Bevy project in: $TARGET"

if [ -f "$TARGET/Cargo.toml" ]; then
    echo "Running cargo check..."
    (cd "$TARGET" && cargo check)

    echo "Running cargo clippy..."
    # Bevy specific clippy constraints could be added here
    (cd "$TARGET" && cargo clippy -- -D warnings)
else
    echo "Cargo.toml not found in $TARGET. Skipping cargo checks."
fi

# Check for Bevy specific dangerous patterns (simple grep)
echo "Checking for naive heavy queries..."
grep -r "Query<&mut" "$TARGET/src" | grep "transform" 2>/dev/null && echo "[INFO] potential heavy transform mutation found (verify conflict)."

echo "Bevy check completed."
