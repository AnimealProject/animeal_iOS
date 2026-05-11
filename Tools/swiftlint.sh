#!/bin/bash

echo "ℹ️  CI_ENV=$CI_ENV"
echo "ℹ️  PROJECT_DIR=$PROJECT_DIR"

# Check if the CI environment variable is set
if [ -z "${CI_ENV}" ]; then
  if [[ "$(uname -m)" == arm64 ]]; then
      export PATH="/opt/homebrew/bin:$PATH"
  fi
  
  # The CI environment variable is not set, so run SwiftLint
  if which swiftlint >/dev/null; then
    swiftlint lint --strict --config "${PROJECT_DIR}/.swiftlint.yml"
    SWIFTLINT_EXIT=$?
    echo "Swiftlint finished. Check logs/warnings for details."
    exit $SWIFTLINT_EXIT
  else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
  fi
else
  # The CI environment variable is set, so do nothing
  echo "SwiftLint checked on a separate step in CI"
fi

