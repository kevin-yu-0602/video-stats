cd -- "$(dirname "$BASH_SOURCE")"

presetSelection=$(zenity --file-selection --multiple --directory)
if [ -z "$presetSelection" ]; then
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi
mkdir presets
fileName=$(zenity --entry --title="Preset Name" --text="Enter the name of the preset:")
if [ -z "$fileName" ]; then
  osascript -e 'tell application "Terminal" to quit' &
  exit
fi
fileName="presets/${fileName}"
if [ -f "${fileName}.yu" ]; then
  baseName="$fileName"
  echo $fileName
  n=1
  fileName="$baseName-$n"
  while [ -f "${fileName}.yu" ]
  do
    n=$((n+1))
    echo there
    fileName="$baseName-$n"
  done
fi
echo $presetSelection > "${fileName}.yu"
osascript -e 'tell application "Terminal" to quit' &
exit