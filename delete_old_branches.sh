#!/bin/bash

# Get the current date
NOW=$(date +%s)

# Get the list of all branches
BRANCHES=$(git branch)

# Iterate over the branches
for BRANCH in $BRANCHES; do

    # Get the last commit date of the branch
    LAST_COMMIT_DATE=$(git show --no-patch --format=%ci $BRANCH)

    # Calculate the age of the branch in days
    BRANCH_AGE=$((($NOW - $LAST_COMMIT_DATE) / 86400))

    # If the branch is older than 1 year, delete it
    if [[ $BRANCH_AGE -gt 365 ]]; then
        git branch -d $BRANCH
        echo "Deleted branch $BRANCH"
    fi
done