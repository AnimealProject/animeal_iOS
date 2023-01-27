#!/bin/bash -eux -o pipefail

mkdir -p ~/Library/Developer/Xcode/Templates

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

ln -s "${SCRIPTPATH}/Animeal modules" ~/Library/Developer/Xcode/Templates
