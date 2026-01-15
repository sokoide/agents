#!/bin/bash
# C Code Check Script
# Usage: ./check.sh [file.c or directory]

TARGET=${1:-.}

echo "Checking C code in: $TARGET"

# 1. Check for basic compilation errors and warnings (GCC/Clang)
if command -v gcc &> /dev/null; then
    echo "Running gcc syntax check..."
    find "$TARGET" -name "*.c" -exec gcc -fsyntax-only -Wall -Wextra -Werror {} +
else
    echo "gcc not found, skipping syntax check."
fi

# 2. Static Analysis (cppcheck)
if command -v cppcheck &> /dev/null; then
    echo "Running cppcheck..."
    cppcheck --enable=all --inconclusive --error-exitcode=1 "$TARGET"
else
    echo "cppcheck not found. Recommended to install for static analysis."
fi

# 3. Formatter Check (clang-format)
if command -v clang-format &> /dev/null; then
    echo "Running clang-format dry-run..."
    # Note: strict check normally requires diffing, simplified here
    find "$TARGET" -name "*.c" -o -name "*.h" | xargs clang-format -n -Werror
else
    echo "clang-format not found."
fi

echo "C check completed."
