cd -- "$(dirname "$BASH_SOURCE")"

selection=$(zenity --question \
--title="" \
--text="請選擇:" \
--extra-button="創建預設" \
--extra-button="使用預設" \
--extra-button="選擇資料夾" \
--no-wrap \
--switch)

if [ "$selection" = "創建預設" ]; then
  ./createPreset.command
elif [ "$selection" = "使用預設" ]; then
  ./selectPreset.command
elif [ "$selection" = "選擇資料夾" ]; then
  ./收集影片數據.command
fi

osascript -e 'tell application "Terminal" to quit' &
exit
