#!/bin/bash
set -e

echo "Running Java checks..."

if [ -f "pom.xml" ]; then
    echo "Found pom.xml, using Maven..."
    mvn clean verify
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    echo "Found build.gradle, using Gradle..."
    if [ -x "./gradlew" ]; then
        ./gradlew build
    else
        gradle build
    fi
else
    echo "No build file (pom.xml or build.gradle) found. Skipping Java checks."
fi

echo "Java checks completed."
