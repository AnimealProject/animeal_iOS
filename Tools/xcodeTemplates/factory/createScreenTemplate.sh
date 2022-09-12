#!/bin/bash

screenPath="../Animeal modules/Screen.xctemplate/Screen"
mkdir -p "$screenPath"
cd "$screenPath"

sh ../../../../makeScreen.sh ___VARIABLE_productName:identifier___ ___FILEBASENAME___

mv ./___FILEBASENAME___/* ./
rm -R ./___FILEBASENAME___
