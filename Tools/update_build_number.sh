#!/bin/bash

#
# Update Build Number Script
#
# Automatically updates the build number (CURRENT_PROJECT_VERSION) in format: YYYYMMDD.BUILD_NUM
# - YYYYMMDD: Current date
# - BUILD_NUM: CI build number (from GITHUB_RUN_NUMBER) or time HHMM (locally)
#
# USAGE:
#   bash Tools/update_build_number.sh
#   bash Tools/update_build_number.sh --help
#
# For testing CI behavior locally:
#   GITHUB_RUN_NUMBER=123 bash Tools/update_build_number.sh
#
# INTEGRATION OPTIONS:
#
# 1. Manual execution (locally):
#    bash Tools/update_build_number.sh
#    Result: 20260412.1530 (date + time HHMM)
#
# 2. Xcode Build Phase (recommended for automatic updates on Archive):
#    - Open animeal.xcodeproj in Xcode
#    - Select "animeal" target → Build Phases tab
#    - Add "New Run Script Phase" (place it FIRST, before Dependencies)
#    - Add script: bash "${PROJECT_DIR}/Tools/update_build_number.sh"
#    - Uncheck "Based on dependency analysis" to always run
#
# 3. CI Pipeline (GitHub Actions):
#    Add step before build:
#      - name: Update Build Number
#        run: bash Tools/update_build_number.sh
#    
#    GITHUB_RUN_NUMBER is automatically available in GitHub Actions
#    Result: 20260412.45 (date + CI run number)
#

set -e

# Show help if -h or --help is passed
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    sed -n '2,33p' "$0" | sed 's/^# \?//'
    exit 0
fi

# Get current date in YYYYMMDD format
DATE_PART=$(date +%Y%m%d)

# Determine build suffix: CI build number or time
if [ -n "$GITHUB_RUN_NUMBER" ]; then
    # Running in GitHub Actions - use run number
    BUILD_SUFFIX=$GITHUB_RUN_NUMBER
    echo "ℹ️  Detected CI environment (GitHub Actions run #$GITHUB_RUN_NUMBER)"
elif [ -n "$CI_BUILD_NUMBER" ]; then
    # Generic CI build number (for other CI systems)
    BUILD_SUFFIX=$CI_BUILD_NUMBER
    echo "ℹ️  Detected CI environment (build #$CI_BUILD_NUMBER)"
else
    # Local build - use current time HHMM
    BUILD_SUFFIX=$(date +%H%M)
    echo "ℹ️  Local build - using time-based suffix"
fi

BUILD_NUMBER="${DATE_PART}.${BUILD_SUFFIX}"

# Path to project file (relative to project root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_FILE="$PROJECT_DIR/animeal.xcodeproj/project.pbxproj"

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: Project file not found at $PROJECT_FILE"
    exit 1
fi

echo "ℹ️  Updating build number to: $BUILD_NUMBER"

# Update CURRENT_PROJECT_VERSION in project.pbxproj
# Match both old format (8 digits) and new format (YYYYMMDD.* pattern)
# This updates all occurrences except test targets (which have CURRENT_PROJECT_VERSION = 1)
sed -i '' -E "s/CURRENT_PROJECT_VERSION = [0-9]{8}(\.[0-9]+)?;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" "$PROJECT_FILE"

echo "✅ Build number updated successfully to $BUILD_NUMBER"

# Verify the change
echo "ℹ️  Current build numbers in project:"
grep "CURRENT_PROJECT_VERSION" "$PROJECT_FILE" | sort -u
