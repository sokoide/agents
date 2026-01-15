#!/bin/bash
# C++ Code Check Script
# Usage: ./check.sh [file.cpp or directory]

TARGET=${1:-.}

echo "Checking C++ code in: $TARGET"

# 1. Syntax Check (g++/clang++)
if command -v g++ &> /dev/null; then
    echo "Running g++ syntax check..."
    find "$TARGET" -name "*.cpp" -exec g++ -fsyntax-only -Wall -Wextra -Werror -std=c++17 {} +
elif command -v clang++ &> /dev/null; then
    echo "Running clang++ syntax check..."
    find "$TARGET" -name "*.cpp" -exec clang++ -fsyntax-only -Wall -Wextra -Werror -std=c++17 {} +
else
    echo "g++ or clang++ not found, skipping syntax check."
fi

# 2. Clang-Tidy (if available)
if command -v clang-tidy &> /dev/null; then
    echo "Running clang-tidy..."
    # Simplified usage; normally requires compile_commands.json
    find "$TARGET" -name "*.cpp" | xargs clang-tidy --checks="bugprone-*,modernize-*,performance-*" -- -std=c++17
else
    echo "clang-tidy not found."
fi

# 3. Formatter Check (clang-format)
if command -v clang-format &> /dev/null; then
    echo "Running clang-format dry-run..."
    find "$TARGET" -name "*.cpp" -o -name "*.hpp" -o -name "*.h" | xargs clang-format -n -Werror
else
    echo "clang-format not found."
fi

echo "C++ check completed."
