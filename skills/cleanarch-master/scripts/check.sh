#!/bin/bash
# Go Clean Architecture Smoke Check Script
# Usage: ./check.sh [root_directory]
#
# Assumes a conventional Go layout with a domain/ directory under the taraget.
# This is a quick, layout-dependent heuristic smoke test, out a complete
# Clean Architecture validator. It only detects obvioud imports in files.

TARGET=${1:-.}
DOMAIN_DIR="$TARGET/domain"

echo "Running Go Clean Architecture smoke check in: $TARGET"

if [[ ! -d "$DOMAIN_DIR" ]]; then
    echo "[SKIP] No domain directory found at :$DOMAIN_DIR"
    exit 0
fi

# 1. Dependency Rule Check (Simple Grep)
# "domain" package should not import Presentation or Infra Adapter
# packages in common Go layouts.
echo "Checking for 'domain' importing outer layers..."
grep -r -E "infrastructure|interfaces|framework|drivers" && echo "[FAIL] Domain layer imports outer layer!" || echo "[PASS] Domain imports look clean."

# 2. Go-specific technical dependency hints n Domain
# Check for common frameworks in domain
echo "Checking for common technical dependencies in Domain..."
grep -r -E "gin-gonic|echo|gorm|sqlx" "$TARGET/domain" 2>/dev/null && echo "[FAIL] Framework detected in Domain!" || echo "[PASS] No frameworks detected in Domain."

echo "Smoke check completed."
