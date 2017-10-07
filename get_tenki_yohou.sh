#!bin/sh

cd $(dirname $0)

curl -s "http://www.jma.go.jp/jp/week/" | grep "option value=" | sed 's/<.*\"\([0-9]*\.html\)\">\(.*\)<.*/\1 \2/g' | sed 's/<.*>//g' | sed 's/^\([0-9][0-9]*\.html\).*/\1/g' | xargs -I@ curl -s "http://www.jma.go.jp/jp/week/@" | grep "<title>\|<th class=\"[^"][^"]*day\">\|<th colspan=\|<td class=\"for\"" | tr -d '\r' | awk '{if( $0 ~ /<title>/){gsub("</title>","",$NF); title = $NF }; gsub("<th colspan=[^>][^>]*>",title "_",$0);if( $0 !~ /<title>/){print $0}}' | sed 's/\(.*\)<br><input.*/\1\n\1\n\1\n\1\n\1\n\1\n\1/g' | sed 's/<th class=\"[^"][^"]*day\">\([0-9][0-9]*\)<br>\(..*\)<\/th>/\1:\2/g' | sed 's/<[^>][^>]*>//g' | xargs -n7 echo | awk 'BEGIN{hiduke=1;hiduke+=0}{if(NR == hiduke){print $0 > "hiduke.txt"};{print}}' |  sed '/:/d' | split -l 5

ls -f x* | xargs -n 1 -I@ cat hiduke.txt @ | split -l 6 - syukan_tenki_

ls -f syukan_tenki_* | xargs -n 1 -I@ tateyoko @

rm x*
rm syukan_tenki_*
rm hiduke.txt
