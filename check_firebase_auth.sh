#!/bin/bash

# Check if GOOGLE_APPLICATION_CREDENTIALS is set
if [ -z "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Error: GOOGLE_APPLICATION_CREDENTIALS environment variable is not set."
    echo "Please set it using: export GOOGLE_APPLICATION_CREDENTIALS=\"\$(pwd)/firebase-credentials.json\""
    exit 1
fi

# Check if the file exists
if [ ! -f "$GOOGLE_APPLICATION_CREDENTIALS" ]; then
    echo "Error: Credentials file not found at $GOOGLE_APPLICATION_CREDENTIALS"
    exit 1
fi

echo "Verifying Firebase Authentication..."
firebase projects:list
