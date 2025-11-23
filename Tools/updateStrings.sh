#!/bin/bash
export LANG=en_US.UTF-8

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
RES_DIR="$PROJECT_ROOT/animeal/res"

echo "Download localization files"

CSV_LINK="https://docs.google.com/spreadsheets/d/17RGL9BUpknMFavXlIBuy6818hMeFZ3CHwS0FC9o6TvQ/gviz/tq?tqx=out:csv&sheet=Sheet1"

TYPE=$(curl -sI "$CSV_LINK" -w '%{content_type}' -o /dev/null)
if [[ "$TYPE" = "text/csv"* ]]
then
    curl $CSV_LINK -o "$RES_DIR/sheet.csv"
else
    echo $TYPE
    echo "Content type is not CSV, invalid URL"
    exit 1
fi

echo "Create localization files"
cd "$PROJECT_ROOT"
bundle exec babelish csv2strings --verbose --filename "$RES_DIR/sheet.csv" --langs English:en Georgian:ka 

# Move localization files to the correct location
echo "Moving localization files to $RES_DIR"
mv -f en.lproj/Localizable.strings "$RES_DIR/en.lproj/Localizable.strings"
mv -f ka.lproj/Localizable.strings "$RES_DIR/ka.lproj/Localizable.strings"

# Remove temporary directories
rm -r en.lproj ka.lproj

echo "✓ Localization files updated successfully"
