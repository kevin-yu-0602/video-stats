createDataDirectory () {
  name="$1"
  if ! mkdir "$name"; then
    baseName="$name"
    n=1
    name="$baseName-$n"
    while ! mkdir "$name"
    do
      n=$((n+1))
      name="$baseName-$n"
    done
  fi
  echo "$name"
}

# arg 1 is directory 2 is data file
initializeCsv () {
  echo "Country,Director Chinese Name,Director English Name,Birth Year,Death Year,Film Year,Film Chinese Name,Film English Name,Rating,@,B:Berlin,C:Cannes,G:Oscar,L:Venice,E:Europe,S:César,H:Horse,J:Japan,Notes,Num Files,Max Size File Extension,Max Size(GB),Original File" >> "./$1/$2"
}

# arg 1 is directory (newFolder) 2 is data file (dataFile) 3 is selected directory
appendToCsv () {
  IFS="/"
  gfind "${3}" -not -path '*/.*' '(' -name *.avi -o -name *.mov -o -name *.rmvb -o -name *.mkv -o -name *.flv -o -name *.webm -o -name *.m2ts -o -name *.m2v -o -name *.viv -o -name *.avchd -o -name *.m2t -o -name *.mk2v -o -name *.vob -o -name *.ogv -o -name *.ogg -o -name *.mng -o -name *.qt -o -name *.wmv -o -name *.yuv -o -name *.rm -o -name *.asf -o -name *.amv -o -name *.mp4 -o -name *.m4p -o -name *.m4v -o -name *.mpg -o -name *.mp2 -o -name *.mpeg -o -name *.mpe -o -name *.mpv -o -name *.m4v -o -name *.svi -o -name *.3gp -o -name *.3g2 -o -name *.mxf -o -name *.roq -o -name *.nsv -o -name *.f4v -o -name *.f4p -o -name *.f4a -o -name *.f4b ')' -type f -exec zsh -c 'echo -n "${0##*.}"' {} \; -printf ' %s %h\n' | sort -k3 -k2,2gr | uniq -f3 -c | sed -E 's/^ *([0-9]+) ([[:alnum:]]+) ([0-9]+) (.+)/\4\/\1\/\2\/\3/' | \
  while read -r i
  do
    # .../directorPart/filmPart/count/ext/size
    read -ra array <<< "$i"
    directorPartMinusOne="${array[@]: -6: 1}"
    directorPart="${array[@]: -5: 1}"
    filmPart="${array[@]: -4: 1}"
    numFiles="${array[@]: -3: 1}"
    ext="${array[@]: -2: 1}"
    maxSize="${array[@]:(-1)}"
    maxSize=$(echo "scale=3; $maxSize/1000000000" | bc -l)

    # 1936 费尔南多·索拉纳斯 Fernando E. Solanas 阿根廷 2020 / 1970 太阳神 Baal 6.4 @Eng B10 C10 G10 L10 E10 S10 H10 J10 ASDJ  Additional: numFiles ext maxSize <original>
    #   1          2                   3        4     5      1    2     3    4   5    6   7   8   9   10 11  12  13  14                  16     17   18        19


    if [[ "$directorPart" =~ 無導演|无导演|Movie|movie ]] || [[ "$directorPartMinusOne" =~ 無導演|无导演|Movie|movie ]]; then
      matchingDirector=$(echo "$filmPart" | perl -C63 -ne "print if s/(?<year>[0-9]{4}) *(?<chName>[\p{Han}\p{Punct}A-Z0-9\x{200B}]*\p{Han}[\p{Han}\p{Punct}A-Z0-9\x{200B}]*)? *(?<engName>(?:(?"'!'" [0-9]\.[0-9])[^\/\p{Han}])+)? *(?<country>[\p{Han}]+)? *(?<rating>[0-9]\.[0-9])? *(?<at>\@[^\s]+)? *(?<b>B[^\s]{1,5})? *(?<c>C[^\s]{1,5})? *(?<g>G[^\s]{1,5})? *(?<l>L[^\s]{1,5})? *(?<e>E[^\s]{1,5})? *(?<s>S[^\s]{1,5})? *(?<h>H[^\s]{1,5})? *(?<j>J[0-9]{1,5})? *(?<notes>.*)$/\"$+{country}\",\"\",\"\",\"\",\"\"/")
      matchingFilm=$(echo "$filmPart" | perl -C63 -ne "print if s/(?<year>[0-9]{4}) *(?<chName>[\p{Han}\p{Punct}A-Z0-9\x{200B}]*\p{Han}[\p{Han}\p{Punct}A-Z0-9\x{200B}]*)? *(?<engName>(?:(?"'!'" [0-9]\.[0-9])[^\/\p{Han}])+)? *(?<country>[\p{Han}]+)? *(?<rating>[0-9]\.[0-9])? *(?<at>\@[^\s]+)? *(?<b>B[^\s]{1,5})? *(?<c>C[^\s]{1,5})? *(?<g>G[^\s]{1,5})? *(?<l>L[^\s]{1,5})? *(?<e>E[^\s]{1,5})? *(?<s>S[^\s]{1,5})? *(?<h>H[^\s]{1,5})? *(?<j>J[0-9]{1,5})? *(?<notes>.*)$/\"$+{year}\",\"$+{chName}\",\"$+{engName}\",\"$+{rating}\",\"$+{at}\",\"$+{b}\",\"$+{c}\",\"$+{g}\",\"$+{l}\",\"$+{e}\",\"$+{s}\",\"$+{h}\",\"$+{j}\",\"$+{notes}\"/")
    else
      matchingDirector=$(echo "$directorPart" | perl -C63 -ne "print if s/([0-9]{4}) *([\p{Han}\p{Punct}A-Z0-9]*[\p{Han}\p{Punct}]+)? *([^\/\p{Han}]+(?<! ))? *([\p{Han}]+) *([0-9]{4})?/\"\4\",\"\2\",\"\3\",\"\1\",\"\5\"/")
      matchingFilm=$(echo "$filmPart" | perl -C63 -ne "print if s/(?<year>[0-9]{4}) *(?<chName>[\p{Han}\p{Punct}A-Z0-9\x{200B}]*\p{Han}[\p{Han}\p{Punct}A-Z0-9\x{200B}]*)? *(?<engName>(?:(?"'!'" [0-9]\.[0-9])[^\/\p{Han}])+)? *(?<rating>[0-9]\.[0-9])? *(?<at>\@[^\s]+)? *(?<b>B[^\s]{1,5})? *(?<c>C[^\s]{1,5})? *(?<g>G[^\s]{1,5})? *(?<l>L[^\s]{1,5})? *(?<e>E[^\s]{1,5})? *(?<s>S[^\s]{1,5})? *(?<h>H[^\s]{1,5})? *(?<j>J[0-9]{1,5})? *(?<notes>.*)$/\"$+{year}\",\"$+{chName}\",\"$+{engName}\",\"$+{rating}\",\"$+{at}\",\"$+{b}\",\"$+{c}\",\"$+{g}\",\"$+{l}\",\"$+{e}\",\"$+{s}\",\"$+{h}\",\"$+{j}\",\"$+{notes}\"/")
    fi

    if [[ -z "$matchingFilm" ]] || [[ -z "$matchingDirector" ]]; then
      echo "$i" >> "./$1/unprocessed.txt"
    else
      echo "$matchingDirector,$matchingFilm,\"$numFiles\",\"$ext\",\"$maxSize\",\"$i\"" >> "./$1/$2"
    fi
  done
}

# 1 is newFolder 2 is dataFile 3 is excelFile
convertToExcel () {
  touch "./$1/$3"
  ssconvert --import-type=Gnumeric_stf:stf_csvtab "./$1/$2" "./$1/$3"
}
