# brew install
# - findutils
# - gnumeric

cd -- "$(dirname "$BASH_SOURCE")"
source ./shared.sh

outputFileName=$(zenity  --file-selection --directory)
dataFile="data.csv"
excelFile="data.xlsx"
if [ -z "$outputFileName" ]; then
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi

premadeDir=$(baseName "$outputFileName")_data
newFolder=$(createDataDirectory "$premadeDir")

initializeCsv "$newFolder" "$dataFile"

appendToCsv "$newFolder" "$dataFile" "$outputFileName"

convertToExcel "$newFolder" "$dataFile" "$excelFile"

osascript -e 'tell application "Terminal" to quit' & exit
