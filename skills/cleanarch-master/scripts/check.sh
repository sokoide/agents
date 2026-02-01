#!/bin/bash
# Clean Architecture Check Script
# Usage: ./check.sh [root_directory]

TARGET=${1:-.}

echo "Checking Clean Architecture rules in: $TARGET"

# 1. Dependency Rule Check (Simple Grep)
# "domain" package shouldn't import "infrastructure" or "interfaces" (assuming standard folder structure)
echo "Checking for 'domain' importing outer layers..."
grep -r "import" "$TARGET/domain" 2>/dev/null | grep -E "infrastructure|interfaces|framework|drivers" && echo "[FAIL] Domain layer imports outer layer!" || echo "[PASS] Domain imports look clean."

# 2. Framework Dependency in Domain
# Check for common frameworks in domain
echo "Checking for Frameworks in Domain..."
grep -r -E "gin-gonic|echo|gorm|sqlx" "$TARGET/domain" 2>/dev/null && echo "[FAIL] Framework detected in Domain!" || echo "[PASS] No frameworks detected in Domain."

echo "CA check completed."
