#!/bin/bash
set -e

echo "Running Python checks..."

# Check availability of tools and run them
if command -v ruff &> /dev/null; then
    echo "Running ruff..."
    ruff check .
else
    echo "ruff not found, skipping."
fi

if command -v black &> /dev/null; then
    echo "Running black..."
    black --check .
else
    echo "black not found, skipping."
fi

if command -v mypy &> /dev/null; then
    echo "Running mypy..."
    mypy .
else
    echo "mypy not found, skipping."
fi

# Run tests if pytest is available
if command -v pytest &> /dev/null; then
    echo "Running pytest..."
    pytest
else
    echo "pytest not found, skipping."
fi

echo "Python checks completed."
