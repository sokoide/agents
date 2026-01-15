#!/bin/bash
set -e

echo "Running C# / .NET checks..."

# Check if project files exist
if [ -f "*.csproj" ] || [ -f "*.sln" ]; then
    # Restore dependencies
    echo "Restoring dependencies..."
    dotnet restore

    # Build check
    echo "Running build..."
    dotnet build --no-restore

    # Run tests if they exist
    if find . -name "*Tests.csproj" -o -name "*Test.csproj" | grep -q .; then
        echo "Running tests..."
        dotnet test --no-build
    fi

    # Format check (dotnet format)
    if dotnet tool list | grep -q "dotnet-format"; then
        echo "Running format check..."
        dotnet format --verify-no-changes
    else
        echo "dotnet-format not installed, skipping format check."
    fi
else
    echo "No .csproj or .sln file found. Skipping checks."
fi

echo "C# / .NET checks completed."
