export LANG=en_US.UTF-8



echo "Download localization files"

CSV_LINK="https://docs.google.com/spreadsheets/d/17RGL9BUpknMFavXlIBuy6818hMeFZ3CHwS0FC9o6TvQ/gviz/tq?tqx=out:csv&sheet=Sheet1"

TYPE=$(curl -sI "$CSV_LINK" -w '%{content_type}' -o /dev/null)
if [[ "$TYPE" = "text/csv"* ]]
then
    # curl $CSV_LINK -o ${SRCROOT}/animeal/res/sheet.csv
    curl $CSV_LINK -o ../animeal/res/sheet.csv
else
    echo $TYPE
    echo "Content type is not CSV, invalid URL"
    exit 1
fi


echo "Create localization files"
bundle exec babelish csv2strings --verbose --filename ../animeal/res/sheet.csv --langs English:en Georgian:ka 

# Copy localization files 
cp -v -r  en.lproj ../animeal/res/ ka.lproj ../animeal/res/
# Remove localization files
rm -r en.lproj ka.lproj
