cd -- "$(dirname "$BASH_SOURCE")"
source ./shared.sh

presetFile=$(zenity --file-selection --filename="$(pwd)/presets/" --file-filter="*.yu")

if [ -z "$presetFile" ]; then
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi

if [ "${presetFile: -3}" != ".yu" ]; then
  zenity --text="請選擇.yu格式的檔案." --error --no-wrap
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi

premadeDir=$(baseName "$presetFile")_data
newFolder=$(createDataDirectory $premadeDir)
dataFile="data.csv"
excelFile="data.xlsx"

initializeCsv "$newFolder" "$dataFile"

IFS="|"
presetContents=$(cat "$presetFile")
read -ra dirs <<< "$presetContents"

for d in "${dirs[@]}"; do
  appendToCsv "$newFolder" "$dataFile" "$d"
done

convertToExcel "$newFolder" "$dataFile" "$excelFile"
osascript -e 'tell application "Terminal" to quit' &
exit
