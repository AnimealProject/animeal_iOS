#!/bin/sh

# Script is used by 'Pre-Actions' Run Script phase for each app scheme: Develop, Testing, Production.

set -e
TARGET_ENVIRONMENT="$1"

# If PROJECT_DIR not set or null, use current directory.
ROOT_DIR=${PROJECT_DIR:-.}

SOURCE_CONFIG_DIR="${ROOT_DIR}/EnvConfigurations/${TARGET_ENVIRONMENT}"
TARGET_CONFIG_DIR="${ROOT_DIR}/animeal/res/Configurations"

if [ -z "${TARGET_ENVIRONMENT}" ]; then
    echo "error: Please pass an environment."
    exit 1
fi

if [ -z "${INFOPLIST_FILE}" ]; then
    INFOPLIST_FILE="Info.plist"
fi

copy_config() {
    local CONFIG="${SOURCE_CONFIG_DIR}/$1"
    
    cp "${CONFIG}" "${TARGET_CONFIG_DIR}"
    touch "${TARGET_CONFIG_DIR}/$1"
}

rm -r $TARGET_CONFIG_DIR
mkdir $TARGET_CONFIG_DIR

copy_config "amplifyconfiguration.json"
copy_config "awsconfiguration.json"
copy_config "GoogleService-Info.plist"

echo "Copied configs for ${TARGET_ENVIRONMENT} target environment!"
