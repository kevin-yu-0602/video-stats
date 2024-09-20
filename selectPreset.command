cd -- "$(dirname "$BASH_SOURCE")"
source ./shared.sh

presetFile=$(zenity --file-selection --filename="$(pwd)/presets/" --file-filter="*.yu")

if [ -z "$presetFile" ]; then
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi

if [ "${presetFile: -3}" != ".yu" ]; then
  zenity --text="Please select a .yu file." --error --no-wrap
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi

premadeDir=$(baseName "$presetFile")_data
newFolder=$(createDataDirectory $premadeDir)
dataFile="data.csv"
excelFile="data.xlsx"

initializeCsv "$newFolder" "$dataFile"

IFS="|"
cat "$presetFile"
presetContents=$(cat "$presetFile")
read -ra dirs <<< "$presetContents"

for d in $dirs; do
  appendToCsv "$newFolder" "$dataFile" "$d"
done

convertToExcel "$newFolder" "$dataFile" "$excelFile"
osascript -e 'tell application "Terminal" to quit' &
exit