#!/bin/bash
# X68000 Code Check Script
# Validates Human68k C/Assembly code for common issues
# Usage: ./check.sh [file_or_directory]

set -e
TARGET=${1:-.}

echo "Checking X68000 code in: $TARGET"

# 1. Check for user-mode I/O access without supervisor mode transition
echo "Checking for user-mode I/O access without supervisor call..."
grep -rn '0xE[89ABC][0-9A-Fa-f]\{4\}' "$TARGET" 2>/dev/null | grep -v '_iocs_super\|super\|Supervisor' && \
    echo "[WARN] Direct I/O access found without obvious supervisor mode guard. Verify _iocs_super(0) is used." || \
    echo "[OK] No obvious user-mode I/O access issues."

# 2. Check for odd-address long access (68000 alignment)
echo "Checking for potential odd-address access..."
grep -rn 'volatile.*\*.*0x[0-9A-Fa-f]*[13579BDFbdf]' "$TARGET" 2>/dev/null | grep 'unsigned long\|uint32' && \
    echo "[WARN] Possible odd-address long access detected. MC68000 requires even-aligned word/long access." || \
    echo "[OK] No obvious alignment violations."

# 3. Check for missing volatile on hardware registers
echo "Checking for missing volatile on register pointers..."
grep -rn 'unsigned short \*\|unsigned long \*' "$TARGET" 2>/dev/null | grep -v 'volatile' | grep '0x[C-E]' && \
    echo "[WARN] Hardware register pointer without volatile detected." || \
    echo "[OK] volatile usage looks consistent."

# 4. Basic syntax check for C files (if cross-compiler available)
if command -v gcc &> /dev/null; then
    echo "Running basic syntax check on C files..."
    find "$TARGET" -name "*.c" -exec gcc -fsyntax-only -Wall -Wextra {} + 2>/dev/null || true
else
    echo "gcc not found, skipping syntax check."
fi

echo "X68000 check completed."
