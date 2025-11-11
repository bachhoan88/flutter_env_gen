#!/bin/bash

echo "Running tests with coverage..."
dart test --coverage=coverage

echo ""
echo "Formatting coverage data..."
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib --check-ignore

echo ""
echo "Generating coverage report..."
if command -v lcov &> /dev/null; then
    lcov --summary coverage/lcov.info
else
    echo "Coverage data generated in coverage/lcov.info"
    echo "To see detailed coverage, install lcov or use an IDE plugin"
fi

echo ""
echo "Done! Check coverage/lcov.info for detailed coverage data"

