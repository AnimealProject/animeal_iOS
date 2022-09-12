#!/bin/bash -eux -o pipefail

mkdir -p ~/Library/Developer/Xcode/Templates

ln -s "$(pwd)/Animeal modules" ~/Library/Developer/Xcode/Templates
