#!/bin/bash
set -e

echo "Running TypeScript checks..."

# Check if package.json exists
if [ -f "package.json" ]; then
    # Install dependencies if node_modules is missing
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    fi

    # Run Type checking
    if npm list typescript > /dev/null 2>&1; then
        echo "Running tsc..."
        npm exec tsc -- --noEmit
    else
        echo "TypeScript not found in dependencies, skipping tsc."
    fi

    # Run Linter (ESLint)
    if npm list eslint > /dev/null 2>&1; then
        echo "Running eslint..."
        npm exec eslint .
    else
        echo "ESLint not found in dependencies, skipping eslint."
    fi

    # Run Tests
    if grep -q "\"test\":" "package.json"; then
        echo "Running tests..."
        npm test
    fi
else
    echo "No package.json found. Skipping checks."
fi

echo "TypeScript checks completed."
