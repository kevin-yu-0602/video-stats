cd -- "$(dirname "$BASH_SOURCE")"

outputFileName=$(zenity  --file-selection --directory)
unprocessedFileName="unprocessed.txt"
dataFile="data.csv"
excelFile="data.xlsx"
if [ -z "$outputFileName" ]; then
  exit 1
fi

newFolder=$(baseName "$outputFileName")_data
if ! mkdir "$newFolder"; then  
  baseName="$newFolder"
  n=1
  newFolder="$baseName-$n"
  while ! mkdir "$newFolder"
  do
    n=$((n+1))
    newFolder="$baseName-$n"
  done
fi

echo "Country,Director Chinese Name,Director English Name,Birth Year,Death Year,Film Year,Film Chinese Name,Film English Name,Rating,@,B,C,G,L,Notes,Num Files,Max Size File Extension,Max Size(bytes),Original File" >> "./$newFolder/$dataFile"

IFS="/"
gfind "${outputFileName}" -not -path '*/.*' '(' -name *.avi -o -name *.mov -o -name *.rmvb -o -name *.mkv -o -name *.flv -o -name *.webm -o -name *.m2ts -o -name *.m2v -o -name *.viv -o -name *.avchd -o -name *.m2t -o -name *.mk2v -o -name *.vob -o -name *.ogv -o -name *.ogg -o -name *.mng -o -name *.qt -o -name *.wmv -o -name *.yuv -o -name *.rm -o -name *.asf -o -name *.amv -o -name *.mp4 -o -name *.m4p -o -name *.m4v -o -name *.mpg -o -name *.mp2 -o -name *.mpeg -o -name *.mpe -o -name *.mpv -o -name *.m4v -o -name *.svi -o -name *.3gp -o -name *.3g2 -o -name *.mxf -o -name *.roq -o -name *.nsv -o -name *.f4v -o -name *.f4p -o -name *.f4a -o -name *.f4b ')' -type f -exec zsh -c 'echo -n "${0##*.}"' {} \; -printf ' %s %h\n' | sort -k3 -k2,2gr | uniq -f3 -c | sed -E 's/^ *([0-9]+) ([[:alnum:]]+) ([0-9]+) (.+)/\4\/\1\/\2\/\3/' | \
while read -r i
do
  # .../directorPart/filmPart/count/ext/size
  read -ra array <<< "$i"
  directorPart="${array[@]: -5: 1}"
  filmPart="${array[@]: -4: 1}"
  numFiles="${array[@]: -3: 1}"
  ext="${array[@]: -2: 1}"
  maxSize="${array[@]:(-1)}"

  # 1936 费尔南多·索拉纳斯 Fernando E. Solanas 阿根廷 2020 / 1970 太阳神 Baal 6.4 @Eng B10 C10 G10 L10 ASDJ  Additional: numFiles ext maxSize <original>
  #   1          2                   3             4     5     1    2     3    4   5    6   7   8   9   10                  16    17   18        19
 
  matchingDirector=$(echo "$directorPart" | perl -C63 -ne "print if s/([0-9]{4}) *([\p{Han}\p{Punct}A-Z0-9]*[\p{Han}\p{Punct}]+)? *([^\/\p{Han}]+(?<! ))? *([\p{Han}]+) *([0-9]{4})?/\"\4\",\"\2\",\"\3\",\"\1\",\"\5\"/")
  matchingFilm=$(echo "$filmPart" | perl -C63 -ne "print if s/(?<year>[0-9]{4}) *(?<chName>[\p{Han}\p{Punct}A-Z0-9]*[\p{Han}\p{Punct}]+)? *(?<engName>(?:(?"'!'" [0-9]\.[0-9])[^\/\p{Han}])+)? *(?<rating>[0-9]\.[0-9])? *(?<at>\@\w+)? *(?<b>B\d{1,3})? *(?<c>C\d{1,3})? *(?<g>G\d{1,3})? *(?<l>L\d{1,3})? *(?<notes>.*)$/\"$+{year}\",\"$+{chName}\",\"$+{engName}\",\"$+{rating}\",\"$+{at}\",\"$+{b}\",\"$+{c}\",\"$+{g}\",\"$+{l}\",\"$+{notes}\"/")

  if [[ -z "$matchingFilm" ]] || [[ -z "$matchingDirector" ]]; then
    echo "$i" >> "./$newFolder/$unprocessedFileName"
  else
    echo "$matchingDirector,$matchingFilm,\"$numFiles\",\"$ext\",\"$maxSize\",\"$i\"" >> "./$newFolder/$dataFile"
  fi
done

touch "./$newFolder/$excelFile"

ssconvert --import-type=Gnumeric_stf:stf_csvtab "./$newFolder/$dataFile" "./$newFolder/$excelFile"

osascript -e 'tell application "Terminal" to quit' &
exit
