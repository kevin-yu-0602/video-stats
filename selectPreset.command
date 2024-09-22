cd -- "$(dirname "$BASH_SOURCE")"

quitApp () {
  osascript -e 'tell application "Terminal" to quit' &
  exit
}

selectNewDir () {
  newSelection=$(zenity --file-selection --directory)
  if [ -z "$newSelection" ]; then
    quitApp
  fi
  echo "$newSelection"
}

convertToNewLines () {
  print -r -- ${1:gs/|/\n}
}

presetSelection=""
first=true
while true; do

  if [ "$first" = true ]; then
    presetSelection="$(selectNewDir)"
    first=false
  else
    presetSelection="${presetSelection}|$(selectNewDir)"
  fi

  # convertToNewLines "$presetSelection"
  confirmationSelection=`zenity --question \
  --title="請選擇" \
  --text="\`printf "已選擇：\n $(echo "${presetSelection//|/\n}")"\`" \
  --extra-button="追加" \
  --extra-button="完成" \
  --extra-button="取消" \
  --no-wrap \
  --switch`

  if [ "$confirmationSelection" = "完成" ]; then
    break
  elif [ "$confirmationSelection" = "取消" ]; then
    quitApp
  fi
done

mkdir presets
fileName=$(zenity --entry --title="輸入預設名稱" --text="請輸入預設名稱:")
if [ -z "$fileName" ]; then
  quitApp
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
quitApp
