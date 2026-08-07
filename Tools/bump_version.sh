#!/bin/bash

#
# Bump Marketing Version Script
#
# Bumps MARKETING_VERSION (semver MAJOR.MINOR.PATCH) for the main app target
# in animeal.xcodeproj/project.pbxproj.
#
# Only the main app target is touched: its three build configurations
# (Test/Debug/Release) hold the version in full X.Y.Z form. Test/UI-test/demo
# targets use the two-part form "1.0" and are never modified.
#
# CURRENT_PROJECT_VERSION (build number) is out of scope — it is managed by
# Tools/update_build_number.sh.
#
# USAGE:
#   bash Tools/bump_version.sh              # patch bump (default): 1.0.0 -> 1.0.1
#   bash Tools/bump_version.sh patch
#   bash Tools/bump_version.sh minor        # 1.0.1 -> 1.1.0
#   bash Tools/bump_version.sh major        # 1.1.0 -> 2.0.0 (requires confirmation)
#   bash Tools/bump_version.sh 1.2.3        # set explicit version
#   bash Tools/bump_version.sh major --yes  # skip interactive major confirmation
#
# A major bump (first number changes) must be confirmed: interactively when
# run in a terminal, or with --yes otherwise.

set -euo pipefail

PROJECT_FILE="$(dirname "$0")/../animeal.xcodeproj/project.pbxproj"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Project file not found: $PROJECT_FILE"
    exit 1
fi

MODE="${1:-patch}"
CONFIRM_FLAG="${2:-}"

# --- Read current version (main target entries are in full X.Y.Z form) ---
CURRENT_VERSIONS=$(grep -oE 'MARKETING_VERSION = [0-9]+\.[0-9]+\.[0-9]+;' "$PROJECT_FILE" | sort -u)
COUNT_UNIQUE=$(echo "$CURRENT_VERSIONS" | grep -c . || true)

if [ "$COUNT_UNIQUE" -eq 0 ]; then
    echo "❌ No X.Y.Z MARKETING_VERSION entries found in $PROJECT_FILE"
    exit 1
fi
if [ "$COUNT_UNIQUE" -gt 1 ]; then
    echo "❌ Main-target MARKETING_VERSION values diverged — fix manually first:"
    echo "$CURRENT_VERSIONS"
    exit 1
fi

CURRENT=$(echo "$CURRENT_VERSIONS" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
ENTRY_COUNT=$(grep -c "MARKETING_VERSION = $CURRENT;" "$PROJECT_FILE")
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# --- Compute new version ---
case "$MODE" in
    patch) NEW="$MAJOR.$MINOR.$((PATCH + 1))" ;;
    minor) NEW="$MAJOR.$((MINOR + 1)).0" ;;
    major) NEW="$((MAJOR + 1)).0.0" ;;
    *)
        if [[ "$MODE" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            NEW="$MODE"
        else
            echo "❌ Invalid argument: '$MODE' (expected patch | minor | major | X.Y.Z)"
            exit 1
        fi
        ;;
esac

if [ "$NEW" = "$CURRENT" ]; then
    echo "ℹ️ Version is already $CURRENT — nothing to do"
    exit 0
fi

# --- Major bump gate ---
NEW_MAJOR="${NEW%%.*}"
if [ "$NEW_MAJOR" != "$MAJOR" ]; then
    if [ "$CONFIRM_FLAG" = "--yes" ]; then
        :
    elif [ -t 0 ]; then
        read -r -p "⚠️ MAJOR bump: $CURRENT -> $NEW. Type 'yes' to confirm: " ANSWER
        if [ "$ANSWER" != "yes" ]; then
            echo "Cancelled"
            exit 1
        fi
    else
        echo "❌ MAJOR bump ($CURRENT -> $NEW) requires confirmation: re-run with --yes"
        exit 1
    fi
fi

# --- Apply ---
sed -i '' "s/MARKETING_VERSION = $CURRENT;/MARKETING_VERSION = $NEW;/g" "$PROJECT_FILE"

NEW_COUNT=$(grep -c "MARKETING_VERSION = $NEW;" "$PROJECT_FILE")
if [ "$NEW_COUNT" -ne "$ENTRY_COUNT" ]; then
    echo "❌ Expected $ENTRY_COUNT replacements, found $NEW_COUNT — reverting"
    sed -i '' "s/MARKETING_VERSION = $NEW;/MARKETING_VERSION = $CURRENT;/g" "$PROJECT_FILE"
    exit 1
fi

echo "✅ MARKETING_VERSION: $CURRENT -> $NEW ($NEW_COUNT configurations)"
