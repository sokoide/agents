#!/bin/bash
set -e

echo "Running Rust checks..."

if [ -f "Cargo.toml" ]; then
    # Check format
    echo "Running cargo fmt..."
    cargo fmt --check

    # Lint
    # echo "Running cargo clippy..."
    # cargo clippy -- -D warnings

    # Check
    echo "Running cargo check..."
    cargo check

    # Test
    echo "Running cargo test..."
    cargo test
else
    echo "Cargo.toml not found. Skipping Rust checks."
fi

echo "Rust checks completed."
